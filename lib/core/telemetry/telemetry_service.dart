import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'gemma_telemetry_summary.dart';
import 'telemetry_exporter.dart';

enum GemmaInferenceStatus { success, timeout, cancelled, error, parseFailure }

class GemmaInferenceEvent {
  const GemmaInferenceEvent({
    required this.status,
    required this.promptLength,
    required this.responseLength,
    this.variantId,
    this.ttftMs,
    this.latencyMs,
    this.finishReason,
    this.error,
  });

  final GemmaInferenceStatus status;
  final int promptLength;
  final int responseLength;
  final String? variantId;
  final int? ttftMs;
  final int? latencyMs;
  final String? finishReason;
  final String? error;

  @override
  String toString() {
    return 'GemmaInferenceEvent(status=$status, prompt=$promptLength, '
        'response=$responseLength, variant=$variantId, '
        'ttftMs=$ttftMs, latencyMs=$latencyMs, '
        'finishReason=$finishReason, error=$error)';
  }
}

abstract class TelemetryService {
  void recordGemmaInference(GemmaInferenceEvent event);

  ValueListenable<GemmaTelemetrySummary> get gemmaSummary;

  GemmaTelemetrySummary get currentGemmaSummary;

  void registerExporter(TelemetryExporter exporter);
}

@LazySingleton(as: TelemetryService)
class AggregatingTelemetryService implements TelemetryService {
  AggregatingTelemetryService()
      : _summary = ValueNotifier(const GemmaTelemetrySummary.initial());

  final ValueNotifier<GemmaTelemetrySummary> _summary;
  final List<TelemetryExporter> _exporters = [];

  @override
  ValueListenable<GemmaTelemetrySummary> get gemmaSummary => _summary;

  @override
  GemmaTelemetrySummary get currentGemmaSummary => _summary.value;

  @override
  void recordGemmaInference(GemmaInferenceEvent event) {
    if (kDebugMode) {
      debugPrint('[telemetry][gemma] $event');
    }
    final updated = _summary.value.updatedWith(event);
    _summary.value = updated;
    for (final exporter in _exporters) {
      unawaited(exporter.handleGemmaInference(event, updated));
    }
  }

  @override
  void registerExporter(TelemetryExporter exporter) {
    if (_exporters.contains(exporter)) {
      return;
    }
    _exporters.add(exporter);
  }
}
