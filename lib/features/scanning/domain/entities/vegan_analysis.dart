import 'package:equatable/equatable.dart';

class VeganAnalysis extends Equatable {
  const VeganAnalysis({
    required this.isVegan,
    required this.confidence,
    this.flaggedIngredients = const [],
    this.alternatives = const [],
  });

  final bool isVegan;
  final double confidence;
  final List<String> flaggedIngredients;
  final List<String> alternatives;

  @override
  List<Object?> get props => [
    isVegan,
    confidence,
    flaggedIngredients,
    alternatives,
  ];
}
