import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:vegolo/core/ai/gemma_channel.dart';
import 'package:vegolo/core/ai/model_manager.dart';
import 'package:vegolo/core/ai/tokenizer/gemma_tokenizer.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

@LazySingleton()
class GemmaService {
  GemmaService(this._modelManager, this._runtimeChannel);

  final ModelManager _modelManager;
  final GemmaRuntimeChannel _runtimeChannel;

  GemmaTokenizer? _tokenizer;
  String? _tokenizerPath;

  Future<VeganAnalysis?> analyze({
    required List<String> ocrTextLines,
    Duration timeout = const Duration(milliseconds: 250),
    double? deviceRamGb,
  }) async {
    await _ensureLoaded(deviceRamGb: deviceRamGb);

    final tokenizer = await _ensureTokenizer();
    final prompt = GemmaPrompt(
      systemPrompt: _systemPrompt,
      userContent: _formatUserContent(ocrTextLines),
    );
    final tokenized = tokenizer.tokenize(prompt);

    try {
      final response = await _runtimeChannel.generate(
        GemmaGenerateRequest(
          prompt: tokenized.prompt,
          maxTokens: 128,
          timeoutMillis: timeout.inMilliseconds,
        ),
      );
      if (response.finishReason == 'not_implemented') {
        return null;
      }

      // TODO(ai-phase-2): Parse AI response and convert to VeganAnalysis.
      return VeganAnalysis(isVegan: true, confidence: 0.5);
    } on PlatformException catch (error, stackTrace) {
      debugPrint('GemmaService PlatformException: $error');
      debugPrint('$stackTrace');
      return null;
    } catch (error, stackTrace) {
      debugPrint('GemmaService error: $error');
      debugPrint('$stackTrace');
      return null;
    }
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
