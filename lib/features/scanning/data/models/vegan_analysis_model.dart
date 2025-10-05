import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

class VeganAnalysisModel {
  const VeganAnalysisModel({
    required this.isVegan,
    required this.confidence,
    this.flaggedIngredients = const [],
    this.alternatives = const [],
  });

  final bool isVegan;
  final double confidence;
  final List<String> flaggedIngredients;
  final List<String> alternatives;

  factory VeganAnalysisModel.fromDomain(VeganAnalysis analysis) {
    return VeganAnalysisModel(
      isVegan: analysis.isVegan,
      confidence: analysis.confidence,
      flaggedIngredients: List.of(analysis.flaggedIngredients),
      alternatives: List.of(analysis.alternatives),
    );
  }

  VeganAnalysis toDomain() {
    return VeganAnalysis(
      isVegan: isVegan,
      confidence: confidence,
      flaggedIngredients: List.unmodifiable(flaggedIngredients),
      alternatives: List.unmodifiable(alternatives),
    );
  }

  factory VeganAnalysisModel.fromJson(Map<String, dynamic> json) {
    return VeganAnalysisModel(
      isVegan: json['isVegan'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      flaggedIngredients:
          (json['flaggedIngredients'] as List<dynamic>? ?? const [])
              .cast<String>()
              .toList(),
      alternatives: (json['alternatives'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVegan': isVegan,
      'confidence': confidence,
      'flaggedIngredients': flaggedIngredients,
      'alternatives': alternatives,
    };
  }
}
