import 'dart:async';

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
    this.temperature,
    this.topP,
    this.topK,
    this.randomSeed,
    this.timeoutMillis = 250,
  });

  final String prompt;
  final int maxTokens;
  final double? temperature;
  final double? topP;
  final int? topK;
  final int? randomSeed;
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

class GemmaStreamChunk {
  const GemmaStreamChunk({
    required this.streamId,
    required this.text,
    required this.delta,
    required this.isFinal,
    this.timestampMs,
    this.ttftMs,
    this.latencyMs,
    this.finishReason,
  });

  final String streamId;
  final String text;
  final String delta;
  final bool isFinal;
  final int? timestampMs;
  final int? ttftMs;
  final int? latencyMs;
  final String? finishReason;
}

/// Thin Dart-side wrapper around the Android LiteRT-LM MethodChannel.
@LazySingleton()
class GemmaRuntimeChannel {
  GemmaRuntimeChannel()
    : _channel = const MethodChannel('vegolo/gemma'),
      _streamChannel = const EventChannel('vegolo/gemma_stream');

  @visibleForTesting
  GemmaRuntimeChannel.test(MethodChannel channel)
    : _channel = channel,
      _streamChannel = const EventChannel('vegolo/gemma_stream');

  final MethodChannel _channel;
  final EventChannel _streamChannel;
  int _streamSequence = 0;

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
          'topK': request.topK,
          'randomSeed': request.randomSeed,
          'timeoutMillis': request.timeoutMillis,
        }) ??
        {};

    return GemmaGenerateResult(
      text: (response['text'] as String?) ?? '',
      latencyMs: (response['latencyMs'] as int?) ?? 0,
      finishReason: (response['reason'] as String?) ?? 'unknown',
    );
  }

  Stream<GemmaStreamChunk> streamGenerate(GemmaGenerateRequest request) {
    final streamId = 'stream-${_streamSequence++}';
    late StreamSubscription<dynamic> subscription;
    StreamController<GemmaStreamChunk>? controller;

    controller = StreamController<GemmaStreamChunk>.broadcast(
      onListen: () async {
        subscription = _streamChannel
            .receiveBroadcastStream({'streamId': streamId})
            .cast<Map<dynamic, dynamic>>()
            .listen(
          (event) {
            final chunk = _parseStreamChunk(streamId, event);
            final ctrl = controller;
            if (ctrl == null) {
              subscription.cancel();
              return;
            }
            ctrl.add(chunk);
            if (chunk.isFinal) {
              subscription.cancel();
              ctrl.close();
            }
          },
          onError: (error, stackTrace) {
            final ctrl = controller;
            if (ctrl != null) {
              ctrl
                ..addError(error, stackTrace)
                ..close();
            }
            subscription.cancel();
          },
        );

        await _channel.invokeMethod<void>('generateStream', {
          'streamId': streamId,
          'prompt': request.prompt,
          'maxTokens': request.maxTokens,
          'temperature': request.temperature,
          'topP': request.topP,
          'topK': request.topK,
          'randomSeed': request.randomSeed,
          'timeoutMillis': request.timeoutMillis,
        });
      },
      onCancel: () async {
        await _channel.invokeMethod<void>('cancelStream', {
          'streamId': streamId,
        });
        await subscription.cancel();
      },
    );

    return controller.stream;
  }

  GemmaStreamChunk _parseStreamChunk(
    String streamId,
    Map<dynamic, dynamic> payload,
  ) {
    final text = (payload['text'] as String?) ?? '';
    final delta = (payload['delta'] as String?) ?? '';
    final isFinal = payload['done'] == true;
    return GemmaStreamChunk(
      streamId: streamId,
      text: text,
      delta: delta,
      isFinal: isFinal,
      timestampMs: payload['timestampMs'] as int?,
      ttftMs: payload['ttftMs'] as int?,
      latencyMs: payload['latencyMs'] as int?,
      finishReason: payload['reason'] as String?,
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
