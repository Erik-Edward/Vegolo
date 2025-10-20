import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/telemetry/telemetry_service.dart';
import 'package:vegolo/core/telemetry/telemetry_exporter.dart';
import 'package:vegolo/core/telemetry/gemma_telemetry_summary.dart';

void main() {
  test('AggregatingTelemetryService records counts and averages', () async {
    final service = AggregatingTelemetryService();
    final recorded = <GemmaInferenceEvent>[];
    service.registerExporter(_ListExporter(recorded));

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

    await Future<void>.delayed(Duration.zero);

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
    expect(recorded, equals([event1, event2]));
  });
}

class _ListExporter implements TelemetryExporter {
  _ListExporter(this.events);

  final List<GemmaInferenceEvent> events;

  @override
  Future<void> handleGemmaInference(
    GemmaInferenceEvent event,
    GemmaTelemetrySummary summary,
  ) async {
    events.add(event);
  }
}
