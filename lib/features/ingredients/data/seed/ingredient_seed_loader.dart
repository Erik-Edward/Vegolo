import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';
import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';
import 'package:vegolo/features/ingredients/domain/repositories/ingredient_repository.dart';

@LazySingleton()
class IngredientSeedLoader {
  IngredientSeedLoader(this._repo);

  final IngredientRepository _repo;

  Future<void> ensureSeededIfEmpty() async {
    try {
      final existing = await _repo.count();
      if (existing > 0) {
        return;
      }

      final jsonStr = await rootBundle.loadString('assets/seed/ingredients.json');
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      final items = data.map(_fromJson).toList();
      await _repo.upsertAll(items);
    } catch (_) {
      // Ignore seeding errors in early MVP; log later.
    }
  }

  // Allows refreshing the bundled seed at any time (upsert semantics).
  Future<void> refreshSeed() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/seed/ingredients.json');
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      final items = data.map(_fromJson).toList();
      await _repo.upsertAll(items);
    } catch (_) {
      // Ignore seed refresh errors in early MVP.
    }
  }

  Ingredient _fromJson(dynamic raw) {
    final m = raw as Map<String, dynamic>;
    return Ingredient(
      id: m['id'] as String,
      name: m['name'] as String,
      status: _status(m['status'] as String?),
      category: m['category'] as String?,
      alternatives: (m['alternatives'] as List<dynamic>? ?? const []).cast<String>(),
      aliases: (m['aliases'] as List<dynamic>? ?? const []).cast<String>(),
      enumbers: (m['enumbers'] as List<dynamic>? ?? const []).cast<String>(),
      regionRules: (m['regionRules'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, v as String)),
      rationale: m['rationale'] as String?,
      sourceUrl: m['sourceUrl'] as String?,
      lastVerifiedAt: null,
      uncertainty: (m['uncertainty'] as num?)?.toDouble(),
      processingAid: m['processingAid'] as bool?,
    );
  }

  VeganStatus _status(String? s) {
    switch ((s ?? 'maybe').toLowerCase()) {
      case 'vegan':
        return VeganStatus.vegan;
      case 'nonvegan':
      case 'non_vegan':
      case 'non-vegan':
        return VeganStatus.nonVegan;
      default:
        return VeganStatus.maybe;
    }
  }
}
