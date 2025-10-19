import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:vegolo/core/ai/gemma_channel.dart';
import 'package:vegolo/core/ai/gemma_response_parser.dart';
import 'package:vegolo/core/ai/generation_options.dart';
import 'package:vegolo/core/ai/model_manager.dart';
import 'package:vegolo/core/ai/tokenizer/gemma_tokenizer.dart';
import 'package:vegolo/core/telemetry/telemetry_service.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

class GemmaAnalysisProgress {
  const GemmaAnalysisProgress({
    required this.partialText,
    required this.delta,
    required this.isFinal,
    this.ttftMs,
    this.latencyMs,
    this.finishReason,
  });

  final String partialText;
  final String delta;
  final bool isFinal;
  final int? ttftMs;
  final int? latencyMs;
  final String? finishReason;
}

@LazySingleton()
class GemmaService {
  GemmaService(this._modelManager, this._runtimeChannel, this._telemetry);

  final ModelManager _modelManager;
  final GemmaRuntimeChannel _runtimeChannel;
  final TelemetryService _telemetry;
  final GemmaResponseParser _parser = const GemmaResponseParser();

  GemmaTokenizer? _tokenizer;
  String? _tokenizerPath;
  _ActiveAnalysisContext? _activeAnalysis;

  Future<VeganAnalysis?> analyze({
    required List<String> ocrTextLines,
    Duration timeout = const Duration(milliseconds: 250),
    double? deviceRamGb,
    GemmaGenerationOptions generationOptions = GemmaGenerationOptions.defaults,
    void Function(GemmaAnalysisProgress progress)? onProgress,
  }) async {
    await _cancelActiveAnalysis();
    await _ensureLoaded(deviceRamGb: deviceRamGb);

    final tokenizer = await _ensureTokenizer();
    final prompt = GemmaPrompt(
      systemPrompt: _systemPrompt,
      userContent: _formatUserContent(ocrTextLines),
    );
    final tokenized = tokenizer.tokenize(prompt);

    try {
      final request = GemmaGenerateRequest(
        prompt: tokenized.prompt,
        maxTokens: generationOptions.maxTokens,
        temperature: generationOptions.temperature,
        topP: generationOptions.topP,
        topK: generationOptions.topK,
        randomSeed: generationOptions.randomSeed,
        timeoutMillis: timeout.inMilliseconds,
      );

      final progressCallback = onProgress;
      final stream = _runtimeChannel.streamGenerate(request);
      final buffer = StringBuffer();
      int? ttftMs;
      GemmaStreamChunk? finalChunk;
      final textCompleter = Completer<String>();
      final context = _ActiveAnalysisContext(
        promptLength: tokenized.prompt.length,
        textCompleter: textCompleter,
      );

      late final StreamSubscription<GemmaStreamChunk> subscription;
      subscription = stream.listen(
        (chunk) {
          buffer
            ..clear()
            ..write(chunk.text);
          ttftMs ??= chunk.ttftMs;
          if (chunk.delta.isNotEmpty) {
            debugPrint('Gemma chunk Δ(${chunk.delta.length}): ${chunk.delta}');
          }
          context.updateChunk(chunk);
          if (progressCallback != null) {
            progressCallback(
              GemmaAnalysisProgress(
                partialText: chunk.text,
                delta: chunk.delta,
                isFinal: chunk.isFinal,
                ttftMs: chunk.ttftMs ?? ttftMs,
                latencyMs: chunk.latencyMs,
                finishReason: chunk.finishReason,
              ),
            );
          }
          if (chunk.isFinal) {
            finalChunk = chunk;
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!textCompleter.isCompleted) {
            textCompleter.completeError(error, stackTrace);
          }
        },
        onDone: () {
          if (!textCompleter.isCompleted) {
            textCompleter.complete(buffer.toString());
          }
        },
        cancelOnError: true,
      );

      context.attach(subscription);
      _activeAnalysis = context;

      String text;
      try {
        text = await textCompleter.future.timeout(timeout);
      } on TimeoutException {
        await context.cancel();
        _recordInference(
          status: GemmaInferenceStatus.timeout,
          context: context,
          ttftMs: ttftMs,
          latencyMs: context.elapsedMs,
          finishReason: 'timeout',
        );
        rethrow;
      } finally {
        if (_activeAnalysis == context) {
          _activeAnalysis = null;
        }
      }

      if (context.cancelled) {
        debugPrint('Gemma analysis cancelled upstream.');
        return null;
      }

      final latency = finalChunk?.latencyMs ?? timeout.inMilliseconds;
      debugPrint(
        'Gemma stream complete (ttft=${ttftMs ?? -1} ms, latency=$latency ms, reason=${finalChunk?.finishReason})',
      );

      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        context.markCompleted();
        _recordInference(
          status: GemmaInferenceStatus.error,
          context: context,
          ttftMs: ttftMs,
          latencyMs: latency,
          finishReason: finalChunk?.finishReason,
          error: 'empty_response',
        );
        return null;
      }

      final parsed = _parser.parse(trimmed);
      if (parsed != null) {
        if (progressCallback != null) {
          progressCallback(
            GemmaAnalysisProgress(
              partialText: trimmed,
              delta: '',
              isFinal: true,
              ttftMs: finalChunk?.ttftMs ?? ttftMs,
              latencyMs: finalChunk?.latencyMs ?? latency,
              finishReason: finalChunk?.finishReason,
            ),
          );
        }
        context.markCompleted();
        _recordInference(
          status: GemmaInferenceStatus.success,
          context: context,
          ttftMs: finalChunk?.ttftMs ?? ttftMs,
          latencyMs: finalChunk?.latencyMs ?? latency,
          finishReason: finalChunk?.finishReason,
          responseLength: trimmed.length,
        );
        return parsed;
      }

      debugPrint(
        'GemmaService parse failure. Raw response: ${trimmed.length > 280 ? '${trimmed.substring(0, 280)}…' : trimmed}',
      );
      context.markCompleted();
      _recordInference(
        status: GemmaInferenceStatus.parseFailure,
        context: context,
        ttftMs: finalChunk?.ttftMs ?? ttftMs,
        latencyMs: finalChunk?.latencyMs ?? latency,
        finishReason: finalChunk?.finishReason,
        error: 'parse_failure',
        responseLength: trimmed.length,
      );
      return null;
    } on TimeoutException catch (error) {
      debugPrint('GemmaService timeout: $error');
      return null;
    } on PlatformException catch (error, stackTrace) {
      debugPrint('GemmaService PlatformException: $error');
      debugPrint('$stackTrace');
      _telemetry.recordGemmaInference(
        GemmaInferenceEvent(
          status: GemmaInferenceStatus.error,
          promptLength: tokenized.prompt.length,
          responseLength: 0,
          variantId: _modelManager.activeVariant?.manifestId,
          error: 'platform:${error.code}',
        ),
      );
      return null;
    } catch (error, stackTrace) {
      debugPrint('GemmaService error: $error');
      debugPrint('$stackTrace');
      _telemetry.recordGemmaInference(
        GemmaInferenceEvent(
          status: GemmaInferenceStatus.error,
          promptLength: tokenized.prompt.length,
          responseLength: 0,
          variantId: _modelManager.activeVariant?.manifestId,
          error: error.runtimeType.toString(),
        ),
      );
      return null;
    }
  }

  Future<void> cancelActiveAnalysis() async {
    await _cancelActiveAnalysis();
  }

  Future<void> _cancelActiveAnalysis() async {
    final context = _activeAnalysis;
    if (context == null) {
      return;
    }
    _activeAnalysis = null;
    await context.cancel();
    _recordInference(
      status: GemmaInferenceStatus.cancelled,
      context: context,
      ttftMs: null,
      latencyMs: context.elapsedMs,
      finishReason: 'cancelled',
    );
  }

  Future<void> unload() async {
    await _modelManager.unload();
    _tokenizer = null;
    _tokenizerPath = null;
  }

  Future<void> _ensureLoaded({double? deviceRamGb}) async {
    if (!_modelManager.isLoaded) {
      await _modelManager.load(deviceRamGb: deviceRamGb, warm: true);
    } else if (!_modelManager.isWarm) {
      await _modelManager.warmModel();
    }
  }

  Future<GemmaTokenizer> _ensureTokenizer() async {
    final cached = _tokenizer;
    if (cached != null) {
      return cached;
    }
    final tokenizerPath = _modelManager.activeTokenizerPath;
    if (tokenizerPath == null) {
      // TODO(ai-phase-2): Provide tokenizer via platform if not bundled.
      throw StateError('Tokenizer path not resolved for active Gemma variant.');
    }
    if (_tokenizer != null && tokenizerPath == _tokenizerPath) {
      return _tokenizer!;
    }
    final tokenizer = await createGemmaTokenizer(tokenizerPath);
    _tokenizer = tokenizer;
    _tokenizerPath = tokenizerPath;
    return tokenizer;
  }

  void _recordInference({
    required GemmaInferenceStatus status,
    required _ActiveAnalysisContext context,
    int? ttftMs,
    int? latencyMs,
    String? finishReason,
    String? error,
    int? responseLength,
  }) {
    _telemetry.recordGemmaInference(
      GemmaInferenceEvent(
        status: status,
        promptLength: context.promptLength,
        responseLength: responseLength ?? context.responseLength,
        variantId: _modelManager.activeVariant?.manifestId,
        ttftMs: ttftMs,
        latencyMs: latencyMs ?? context.elapsedMs,
        finishReason: finishReason,
        error: error,
      ),
    );
  }

  String _formatUserContent(List<String> lines) {
    final buffer = StringBuffer()
      ..writeln('You receive OCR text segments from a food label.')
      ..writeln(
        'Determine whether the product is vegan, non-vegan, or uncertain.',
      )
      ..writeln('OCR lines:');
    for (final line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }
      buffer.writeln('- ${line.trim()}');
    }
    buffer.writeln(
      'Respond with JSON: {"isVegan":bool,"confidence":0..1,"flaggedIngredients":[],"alternatives":[]}.',
    );
    return buffer.toString();
  }
}

const String _systemPrompt = '''
You are Vegolo's on-device vegan ingredient analyst. Combine rule-based hints with reasoning.
If ingredients clearly indicate non-vegan, mark isVegan=false. If you are unsure, set isVegan=false and confidence 0.2, flag uncertainty, and advise manual double-check.
Do not hallucinate new ingredients; rely on provided text.
''';

class _ActiveAnalysisContext {
  _ActiveAnalysisContext({
    required this.promptLength,
    required this.textCompleter,
  }) : _stopwatch = Stopwatch()..start();

  final int promptLength;
  final Completer<String> textCompleter;
  late StreamSubscription<GemmaStreamChunk> subscription;
  bool cancelled = false;
  String latestText = '';
  final Stopwatch _stopwatch;

  void attach(StreamSubscription<GemmaStreamChunk> sub) {
    subscription = sub;
  }

  void updateChunk(GemmaStreamChunk chunk) {
    latestText = chunk.text;
  }

  int get elapsedMs => _stopwatch.elapsedMilliseconds;

  int get responseLength => latestText.length;

  Future<void> cancel() async {
    if (cancelled) return;
    cancelled = true;
    _stopwatch.stop();
    try {
      await subscription.cancel();
    } finally {
      if (!textCompleter.isCompleted) {
        textCompleter.complete('');
      }
    }
  }

  void markCompleted() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }
}
