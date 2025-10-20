import 'telemetry_service.dart';
import 'gemma_telemetry_summary.dart';

abstract class TelemetryExporter {
  Future<void> handleGemmaInference(
    GemmaInferenceEvent event,
    GemmaTelemetrySummary summary,
  );
}

class NoopTelemetryExporter implements TelemetryExporter {
  const NoopTelemetryExporter();

  @override
  Future<void> handleGemmaInference(
    GemmaInferenceEvent event,
    GemmaTelemetrySummary summary,
  ) async {}
}
