import 'package:flutter/foundation.dart';

class TelemetryConfig {
  const TelemetryConfig({
    required this.endpoint,
    required this.apiKey,
    required this.appVersion,
  });

  final String endpoint;
  final String apiKey;
  final String appVersion;

  factory TelemetryConfig.fromEnvironment() {
    const endpoint = String.fromEnvironment('TELEMETRY_ENDPOINT');
    const apiKey = String.fromEnvironment('TELEMETRY_API_KEY');
    const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

    if (endpoint.isEmpty) {
      throw StateError(
        'TELEMETRY_ENDPOINT not provided. Supply via --dart-define.',
      );
    }
    if (apiKey.isEmpty && !kDebugMode) {
      throw StateError(
        'TELEMETRY_API_KEY not provided. Supply via --dart-define in release builds.',
      );
    }
    return TelemetryConfig(
      endpoint: endpoint,
      apiKey: apiKey,
      appVersion: appVersion,
    );
  }
}
