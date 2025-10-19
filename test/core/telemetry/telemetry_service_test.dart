import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/telemetry/telemetry_service.dart';

void main() {
  test('AggregatingTelemetryService records counts and averages', () {
    final service = AggregatingTelemetryService();

    final event1 = GemmaInferenceEvent(
      status: GemmaInferenceStatus.success,
      promptLength: 120,
      responseLength: 45,
      variantId: 'nano',
      ttftMs: 180,
      latencyMs: 420,
      finishReason: 'success',
    );

    final event2 = GemmaInferenceEvent(
      status: GemmaInferenceStatus.timeout,
      promptLength: 100,
      responseLength: 0,
      variantId: 'nano',
      latencyMs: 250,
      finishReason: 'timeout',
    );

    service.recordGemmaInference(event1);
    service.recordGemmaInference(event2);

    final summary = service.currentGemmaSummary;

    expect(summary.total, 2);
    expect(summary.success, 1);
    expect(summary.timeout, 1);
    expect(summary.cancelled, 0);
    expect(summary.error, 0);
    expect(summary.parseFailure, 0);
    expect(summary.ttftSamples, 1);
    expect(summary.averageTtftMs, closeTo(180, 1e-6));
    expect(summary.latencySamples, 2);
    expect(summary.averageLatencyMs, closeTo((420 + 250) / 2, 1e-6));
    expect(summary.lastEvent, equals(event2));
  });
}
