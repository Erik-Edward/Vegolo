import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'gemma_telemetry_summary.dart';
import 'telemetry_exporter.dart';
import 'telemetry_service.dart';
import 'telemetry_uploader.dart';
import 'telemetry_config.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton()
class AnalyticsTelemetryExporter implements TelemetryExporter {
  AnalyticsTelemetryExporter(
    this._settingsRepository,
    this._uploader,
    this._config,
  ) : _random = Random.secure();

  final SettingsRepository _settingsRepository;
  final TelemetryUploader _uploader;
  final TelemetryConfig _config;
  final Random _random;
  late final String _sessionId = _generateSessionId();
  bool _optedIn = false;

  Future<void> refreshOptIn() async {
    try {
      _optedIn = await _settingsRepository.getTelemetryAnalyticsEnabled();
    } catch (_) {
      _optedIn = false;
    }
  }

  void updateOptIn(bool value) {
    _optedIn = value;
  }

  @override
  Future<void> handleGemmaInference(
    GemmaInferenceEvent event,
    GemmaTelemetrySummary summary,
  ) async {
    if (!_optedIn) {
      return;
    }

    final payload = _cleanPayload({
      'app_version': _config.appVersion,
      'variant': event.variantId,
      'status': event.status.name,
      'prompt_length': event.promptLength,
      'response_length': event.responseLength,
      'ttft_ms': event.ttftMs,
      'latency_ms': event.latencyMs,
      'finish_reason': event.finishReason,
      'session_id': _sessionId,
      'sent_at': DateTime.now().toUtc().toIso8601String(),
      'totals': {
        'total': summary.total,
        'success': summary.success,
        'timeout': summary.timeout,
        'cancelled': summary.cancelled,
        'error': summary.error,
        'parse_failure': summary.parseFailure,
        'avg_ttft_ms': summary.averageTtftMs,
        'avg_latency_ms': summary.averageLatencyMs,
      },
    });

    if (kDebugMode) {
      debugPrint('[analytics][gemma] $payload');
    }
    await _uploader.upload(payload);
  }

  Map<String, Object?> _cleanPayload(Map<String, Object?> map) {
    final result = <String, Object?>{};
    map.forEach((key, value) {
      if (value == null) return;
      if (value is Map<String, Object?>) {
        final nested = _cleanPayload(value);
        if (nested.isNotEmpty) {
          result[key] = nested;
        }
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBits = _random.nextInt(0x7fffffff).toRadixString(16);
    return '$timestamp-$randomBits';
  }
}
