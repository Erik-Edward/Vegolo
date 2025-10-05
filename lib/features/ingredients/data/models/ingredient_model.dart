import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';

class IngredientModel {
  const IngredientModel({
    required this.id,
    required this.name,
    required this.status,
    this.category,
    this.alternatives = const [],
    this.aliases = const [],
    this.enumbers = const [],
    this.regionRules = const {},
    this.rationale,
    this.sourceUrl,
    this.lastVerifiedAt,
    this.uncertainty,
    this.processingAid,
  });

  final String id;
  final String name;
  final VeganStatus status;
  final String? category;
  final List<String> alternatives;
  final List<String> aliases;
  final List<String> enumbers;
  final Map<String, String> regionRules;
  final String? rationale;
  final String? sourceUrl;
  final DateTime? lastVerifiedAt;
  final double? uncertainty;
  final bool? processingAid;

  factory IngredientModel.fromDomain(Ingredient ingredient) {
    return IngredientModel(
      id: ingredient.id,
      name: ingredient.name,
      status: ingredient.status,
      category: ingredient.category,
      alternatives: List.of(ingredient.alternatives),
      aliases: List.of(ingredient.aliases),
      enumbers: List.of(ingredient.enumbers),
      regionRules: Map.of(ingredient.regionRules),
      rationale: ingredient.rationale,
      sourceUrl: ingredient.sourceUrl,
      lastVerifiedAt: ingredient.lastVerifiedAt,
      uncertainty: ingredient.uncertainty,
      processingAid: ingredient.processingAid,
    );
  }

  Ingredient toDomain() {
    return Ingredient(
      id: id,
      name: name,
      status: status,
      category: category,
      alternatives: List.unmodifiable(alternatives),
      aliases: List.unmodifiable(aliases),
      enumbers: List.unmodifiable(enumbers),
      regionRules: Map.unmodifiable(regionRules),
      rationale: rationale,
      sourceUrl: sourceUrl,
      lastVerifiedAt: lastVerifiedAt,
      uncertainty: uncertainty,
      processingAid: processingAid,
    );
  }
}
