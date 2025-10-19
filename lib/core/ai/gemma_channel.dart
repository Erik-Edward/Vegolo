import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:vegolo/core/ai/model_manager.dart';

class GemmaRuntimeStatus {
  const GemmaRuntimeStatus({required this.loaded, this.variant});

  final bool loaded;
  final ModelVariant? variant;
}

class GemmaGenerateRequest {
  const GemmaGenerateRequest({
    required this.prompt,
    required this.maxTokens,
    this.temperature = 0.0,
    this.topP = 0.0,
    this.timeoutMillis = 250,
  });

  final String prompt;
  final int maxTokens;
  final double temperature;
  final double topP;
  final int timeoutMillis;
}

class GemmaGenerateResult {
  const GemmaGenerateResult({
    required this.text,
    required this.latencyMs,
    required this.finishReason,
  });

  final String text;
  final int latencyMs;
  final String finishReason;
}

/// Thin Dart-side wrapper around the Android LiteRT-LM MethodChannel.
@LazySingleton()
class GemmaRuntimeChannel {
  GemmaRuntimeChannel() : _channel = const MethodChannel('vegolo/gemma');

  @visibleForTesting
  GemmaRuntimeChannel.test(MethodChannel channel) : _channel = channel;

  final MethodChannel _channel;

  Future<void> loadVariant({
    required ModelVariant variant,
    required String modelPath,
    String? tokenizerPath,
    Map<String, Object?> options = const {},
  }) async {
    await _channel.invokeMethod<void>('loadVariant', {
      'variantId': variant.manifestId,
      'modelPath': modelPath,
      'tokenizerPath': tokenizerPath,
      'options': options,
    });
  }

  Future<void> unload() => _channel.invokeMethod<void>('unload');

  Future<GemmaRuntimeStatus> status() async {
    final response =
        await _channel.invokeMapMethod<String, dynamic>('isReady') ?? {};
    final loaded = response['loaded'] == true;
    final variantId = response['variantId'] as String?;

    return GemmaRuntimeStatus(
      loaded: loaded,
      variant: variantId != null ? _variantFromId(variantId) : null,
    );
  }

  Future<GemmaGenerateResult> generate(GemmaGenerateRequest request) async {
    final response =
        await _channel.invokeMapMethod<String, dynamic>('generate', {
          'prompt': request.prompt,
          'maxTokens': request.maxTokens,
          'temperature': request.temperature,
          'topP': request.topP,
          'timeoutMillis': request.timeoutMillis,
        }) ??
        {};

    return GemmaGenerateResult(
      text: (response['text'] as String?) ?? '',
      latencyMs: (response['latencyMs'] as int?) ?? 0,
      finishReason: (response['reason'] as String?) ?? 'unknown',
    );
  }

  ModelVariant _variantFromId(String id) {
    switch (id) {
      case 'nano':
        return ModelVariant.nano;
      case 'standard':
        return ModelVariant.standard;
      case 'full':
        return ModelVariant.full;
      default:
        throw ArgumentError.value(id, 'id', 'Unknown Gemma variant id.');
    }
  }
}
