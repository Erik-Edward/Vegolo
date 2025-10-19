import 'dart:convert';

class GemmaGenerationOptions {
  const GemmaGenerationOptions({
    required this.maxTokens,
    required this.temperature,
    required this.topP,
    required this.topK,
    this.randomSeed,
  });

  final int maxTokens;
  final double temperature;
  final double topP;
  final int topK;
  final int? randomSeed;

  static const GemmaGenerationOptions defaults = GemmaGenerationOptions(
    maxTokens: 128,
    temperature: 0.6,
    topP: 0.9,
    topK: 40,
    randomSeed: null,
  );

  GemmaGenerationOptions copyWith({
    int? maxTokens,
    double? temperature,
    double? topP,
    int? topK,
    int? randomSeed,
  }) {
    return GemmaGenerationOptions(
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      topK: topK ?? this.topK,
      randomSeed: randomSeed ?? this.randomSeed,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'maxTokens': maxTokens,
      'temperature': temperature,
      'topP': topP,
      'topK': topK,
      'randomSeed': randomSeed,
    };
  }

  static GemmaGenerationOptions fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    int parseInt(dynamic value, int fallback) {
      if (value is num) return value.toInt();
      return fallback;
    }

    return GemmaGenerationOptions(
      maxTokens: parseInt(json['maxTokens'], defaults.maxTokens),
      temperature: parseDouble(json['temperature'], defaults.temperature),
      topP: parseDouble(json['topP'], defaults.topP),
      topK: parseInt(json['topK'], defaults.topK),
      randomSeed: json['randomSeed'] is num
          ? (json['randomSeed'] as num).toInt()
          : null,
    );
  }

  static GemmaGenerationOptions fromEncoded(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return GemmaGenerationOptions.defaults;
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return GemmaGenerationOptions.fromJson(decoded);
      }
    } catch (_) {
      // fall through to defaults
    }
    return GemmaGenerationOptions.defaults;
  }

  String encode() => jsonEncode(toJson());
}
