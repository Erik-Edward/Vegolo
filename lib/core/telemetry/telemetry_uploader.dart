import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import 'telemetry_config.dart';

abstract class TelemetryUploader {
  Future<void> upload(Map<String, Object?> payload);
}

@LazySingleton(as: TelemetryUploader)
class HttpTelemetryUploader implements TelemetryUploader {
  HttpTelemetryUploader(this._client, this._config);

  final http.Client _client;
  final TelemetryConfig _config;

  @override
  Future<void> upload(Map<String, Object?> payload) async {
    final uri = Uri.parse(_config.endpoint);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_config.apiKey.isNotEmpty) 'Authorization': 'Bearer ${_config.apiKey}',
    };

    final sessionId = payload['session_id'];
    if (sessionId is String && sessionId.isNotEmpty) {
      headers['X-Session-Id'] = sessionId;
    }
    headers['X-Client-Version'] = _config.appVersion;

    final body = jsonEncode(payload);
    const maxAttempts = 3;
    var attempt = 0;
    while (true) {
      try {
        final response = await _client.post(uri, headers: headers, body: body);
        if (response.statusCode < 400) {
          return;
        }
        if (_shouldRetryStatus(response.statusCode) && attempt < maxAttempts - 1) {
          attempt++;
          await _backoff(attempt);
          continue;
        }
        throw TelemetryUploadException(response.statusCode, response.body);
      } on SocketException catch (error) {
        if (attempt >= maxAttempts - 1) {
          throw TelemetryUploadException(-1, error.message);
        }
        attempt++;
        await _backoff(attempt);
      }
    }
  }

  bool _shouldRetryStatus(int statusCode) => statusCode >= 500 || statusCode == 429;

  Future<void> _backoff(int attempt) async {
    final delay = Duration(milliseconds: 500 * (1 << (attempt - 1)));
    await Future<void>.delayed(delay);
  }
}

class TelemetryUploadException implements Exception {
  TelemetryUploadException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'TelemetryUploadException($statusCode, $body)';
}
