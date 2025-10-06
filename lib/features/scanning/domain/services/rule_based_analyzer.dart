import 'package:injectable/injectable.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';
import 'package:vegolo/features/ingredients/domain/repositories/ingredient_repository.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/shared/utils/text_normalizer.dart';

/// Deterministic rule layer that interprets OCR output before invoking AI.
@LazySingleton()
class RuleBasedAnalyzer {
  RuleBasedAnalyzer(this._ingredientRepository);

  final IngredientRepository _ingredientRepository;
  final Map<String, List<Ingredient>> _matchCache = {};

  Future<VeganAnalysis> analyze(OcrResult result) async {
    final raw = result.fullText.trim();
    if (raw.isEmpty) {
      return const VeganAnalysis(
        isVegan: false,
        confidence: 0.0,
        flaggedIngredients: ['no text detected'],
      );
    }

    final normalized = TextNormalizer.normalizeForIngredients(raw);
    final flagged = await _findFlaggedIngredients(
      rawLower: raw.toLowerCase(),
      normalized: normalized,
    );
    if (flagged.isNotEmpty) {
      return VeganAnalysis(
        isVegan: false,
        confidence: 0.7,
        flaggedIngredients: flagged.map((it) => it.name).toList(),
        alternatives: flagged.expand((it) => it.alternatives).toList(),
      );
    }

    // TODO(eriklinux): Fold in ingredient repository signals (aliases, regions)
    // before defaulting to vegan.
    return const VeganAnalysis(isVegan: true, confidence: 0.5);
  }

  Future<List<Ingredient>> _findFlaggedIngredients({
    required String rawLower,
    required String normalized,
  }) async {
    final tokens = normalized
        .split(RegExp(r'\s+'))
        .map((token) => token.trim().toLowerCase())
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
    final keywords = tokens.toSet();

    // Generate 2- and 3-grams for multi-word matches like "milk solids".
    final ngrams = <String>{};
    for (int n = 2; n <= 3; n++) {
      for (int i = 0; i + n <= tokens.length; i++) {
        ngrams.add(tokens.sublist(i, i + n).join(' '));
      }
    }

    final Map<String, Ingredient> matches = {};
    Future<void> searchPhrase(String phrase) async {
      final keyword = phrase;
      final cached = _matchCache[keyword];
      if (cached != null) {
        for (final ingredient in cached) {
          matches[ingredient.id] = ingredient;
        }
        return;
      }

      final results = <Ingredient>[];
      final match = await _ingredientRepository.findByName(keyword);
      if (match != null && match.status == VeganStatus.nonVegan) {
        results.add(match);
      }

      final aliasMatches = await _ingredientRepository.searchByAlias(keyword);
      results.addAll(
        aliasMatches.where(
          (ingredient) => ingredient.status == VeganStatus.nonVegan,
        ),
      );

      _matchCache[keyword] = results;
      for (final ingredient in results) {
        matches[ingredient.id] = ingredient;
      }
    }

    // Prefer longer phrases first.
    for (final phrase in ngrams) {
      await searchPhrase(phrase);
    }
    for (final token in keywords) {
      await searchPhrase(token);
    }

    // E-number pass: find E-codes in text and map to ingredients.
    final ecodeMatches = RegExp(r'\b(e[-\s]?\d{1,3}[a-z]?)\b', caseSensitive: false)
        .allMatches(rawLower)
        .map((m) => m.group(1)!)
        .toSet();
    for (final code in ecodeMatches) {
      final eResults = await _ingredientRepository.searchByENumber(code);
      for (final ing in eResults) {
        if (ing.status == VeganStatus.nonVegan) {
          matches[ing.id] = ing;
        }
      }
    }

    return matches.values.toList(growable: false);
  }
}
