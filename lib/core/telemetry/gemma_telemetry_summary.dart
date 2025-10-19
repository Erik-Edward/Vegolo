import 'package:equatable/equatable.dart';

import 'telemetry_service.dart';

class GemmaTelemetrySummary extends Equatable {
  const GemmaTelemetrySummary({
    required this.total,
    required this.success,
    required this.timeout,
    required this.cancelled,
    required this.error,
    required this.parseFailure,
    required this.ttftSamples,
    required this.averageTtftMs,
    required this.latencySamples,
    required this.averageLatencyMs,
    this.lastEvent,
  });

  const GemmaTelemetrySummary.initial()
      : total = 0,
        success = 0,
        timeout = 0,
        cancelled = 0,
        error = 0,
        parseFailure = 0,
        ttftSamples = 0,
        averageTtftMs = null,
        latencySamples = 0,
        averageLatencyMs = null,
        lastEvent = null;

  final int total;
  final int success;
  final int timeout;
  final int cancelled;
  final int error;
  final int parseFailure;
  final int ttftSamples;
  final double? averageTtftMs;
  final int latencySamples;
  final double? averageLatencyMs;
  final GemmaInferenceEvent? lastEvent;

  GemmaTelemetrySummary updatedWith(GemmaInferenceEvent event) {
    final newTotal = total + 1;
    final statusCounts = _incrementStatus(event.status);

    final (newTtftSamples, newTtftAvg) = _updateAverage(
      samples: ttftSamples,
      currentAverage: averageTtftMs,
      value: event.ttftMs,
    );
    final (newLatencySamples, newLatencyAvg) = _updateAverage(
      samples: latencySamples,
      currentAverage: averageLatencyMs,
      value: event.latencyMs,
    );

    return GemmaTelemetrySummary(
      total: newTotal,
      success: success + statusCounts.success,
      timeout: timeout + statusCounts.timeout,
      cancelled: cancelled + statusCounts.cancelled,
      error: error + statusCounts.error,
      parseFailure: parseFailure + statusCounts.parseFailure,
      ttftSamples: newTtftSamples,
      averageTtftMs: newTtftAvg,
      latencySamples: newLatencySamples,
      averageLatencyMs: newLatencyAvg,
      lastEvent: event,
    );
  }

  ({int success, int timeout, int cancelled, int error, int parseFailure})
  _incrementStatus(GemmaInferenceStatus status) {
    switch (status) {
      case GemmaInferenceStatus.success:
        return (success: 1, timeout: 0, cancelled: 0, error: 0, parseFailure: 0);
      case GemmaInferenceStatus.timeout:
        return (success: 0, timeout: 1, cancelled: 0, error: 0, parseFailure: 0);
      case GemmaInferenceStatus.cancelled:
        return (success: 0, timeout: 0, cancelled: 1, error: 0, parseFailure: 0);
      case GemmaInferenceStatus.error:
        return (success: 0, timeout: 0, cancelled: 0, error: 1, parseFailure: 0);
      case GemmaInferenceStatus.parseFailure:
        return (success: 0, timeout: 0, cancelled: 0, error: 0, parseFailure: 1);
    }
  }

  (int, double?) _updateAverage({
    required int samples,
    required double? currentAverage,
    required int? value,
  }) {
    if (value == null) {
      return (samples, currentAverage);
    }
    final newSamples = samples + 1;
    final newAverage = samples == 0
        ? value.toDouble()
        : (((currentAverage ?? 0) * samples) + value) / newSamples;
    return (newSamples, newAverage);
  }

  @override
  List<Object?> get props => [
        total,
        success,
        timeout,
        cancelled,
        error,
        parseFailure,
        ttftSamples,
        averageTtftMs,
        latencySamples,
        averageLatencyMs,
        lastEvent,
      ];
}
