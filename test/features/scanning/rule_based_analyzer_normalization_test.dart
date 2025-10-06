import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';
import 'package:vegolo/features/ingredients/domain/repositories/ingredient_repository.dart';
import 'package:vegolo/features/scanning/domain/services/rule_based_analyzer.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/camera/scanner_models.dart';

class _FakeRepo implements IngredientRepository {
  final Map<String, Ingredient> _byName = {
    'milk solids': Ingredient(
      id: 'milk-solids',
      name: 'milk solids',
      status: VeganStatus.nonVegan,
      alternatives: const ['plant milk'],
      aliases: const ['milk-solid'],
      enumbers: const [],
      regionRules: const {},
    ),
  };

  @override
  Future<int> count() async => 1;

  @override
  Future<Ingredient?> findByName(String name) async => _byName[name];

  @override
  Future<List<Ingredient>> searchByAlias(String query) async {
    final matches = <Ingredient>[];
    for (final ing in _byName.values) {
      if (ing.aliases.contains(query)) matches.add(ing);
    }
    return matches;
  }

  @override
  Future<List<Ingredient>> searchByENumber(String code) async => const [];

  @override
  Future<void> upsertAll(Iterable<Ingredient> ingredients) async {}
}

void main() {
  test('finds non-vegan by normalized tokens and ngrams', () async {
    final analyzer = RuleBasedAnalyzer(_FakeRepo());
    const text = 'INGREDIENTS: • MILK solids, sugar';
    final frame = ScannerFrame(
      bytes: Uint8List(0),
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    );
    final result = OcrResult(fullText: text, blocks: const [], frame: frame);
    final analysis = await analyzer.analyze(result);
    expect(analysis.isVegan, isFalse);
    expect(analysis.flaggedIngredients, contains('milk solids'));
  });
}
