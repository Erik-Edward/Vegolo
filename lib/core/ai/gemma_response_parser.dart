import 'dart:convert';

import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

/// Parses streamed Gemma responses into a [VeganAnalysis].
class GemmaResponseParser {
  const GemmaResponseParser();

  VeganAnalysis? parse(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }

    final jsonCandidate = _extractJson(raw);
    if (jsonCandidate == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonCandidate);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final isVegan = _parseBool(decoded['isVegan']);
      final confidence = _parseConfidence(decoded['confidence']);
      if (isVegan == null || confidence == null) {
        return null;
      }

      final flagged = _parseStringList(decoded['flaggedIngredients']);
      final alternatives = _parseStringList(decoded['alternatives']);

      return VeganAnalysis(
        isVegan: isVegan,
        confidence: confidence.clamp(0.0, 1.0),
        flaggedIngredients: flagged,
        alternatives: alternatives,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  String? _extractJson(String raw) {
    final trimmed = raw.replaceAll('```json', '').replaceAll('```', '').trim();

    final start = trimmed.indexOf('{');
    if (start == -1) {
      return null;
    }

    var depth = 0;
    for (var index = start; index < trimmed.length; index++) {
      final char = trimmed[index];
      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          return trimmed.substring(start, index + 1);
        }
      }
    }

    return null;
  }

  bool? _parseBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lowered = value.toLowerCase().trim();
      if (lowered == 'true') return true;
      if (lowered == 'false') return false;
    }
    return null;
  }

  double? _parseConfidence(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final sanitized = value.trim();
      if (sanitized.isEmpty) {
        return null;
      }
      final parsed = double.tryParse(sanitized);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  List<String> _parseStringList(Object? value) {
    if (value == null) return const [];
    if (value is List) {
      final entries = value
          .whereType<Object?>()
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(growable: false);
      return List.unmodifiable(entries);
    }
    if (value is String) {
      final parts = value
          .split(RegExp(r'[,\n]'))
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toSet()
          .toList(growable: false);
      return List.unmodifiable(parts);
    }
    return const [];
  }
}
