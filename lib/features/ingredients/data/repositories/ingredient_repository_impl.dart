import 'package:drift/drift.dart' as drift;
import 'package:injectable/injectable.dart';
import 'package:vegolo/core/database/app_database.dart' as adb;
import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';
import 'package:vegolo/features/ingredients/domain/repositories/ingredient_repository.dart';

String _norm(String s) => s.trim().toLowerCase();

@LazySingleton(as: IngredientRepository)
class IngredientRepositoryImpl implements IngredientRepository {
  IngredientRepositoryImpl(this._db);

  final adb.AppDatabase _db;

  // Normalizes E-numbers like "e-120", "E 120" to canonical "E120".
  String _normalizeENumber(String raw) {
    final s = raw.trim().toUpperCase();
    // Remove spaces and hyphens between E and digits/letter suffix.
    final cleaned = s.replaceAll(RegExp(r'\s|-'), '');
    if (cleaned.startsWith('E')) return cleaned;
    return 'E$cleaned';
  }

  @override
  Future<Ingredient?> findByName(String name) async {
    final norm = _norm(name);
    // 1) Try direct name match
    final ing = await (_db.select(_db.ingredients)
          ..where((t) => t.normalizedName.equals(norm)))
        .getSingleOrNull();
    if (ing != null) {
      return _toDomainWithChildren(ing);
    }
    // 2) Try alias match
    final aliasJoin = await (_db.select(_db.ingredients).join([
      drift.innerJoin(
        _db.ingredientAliases,
        _db.ingredientAliases.ingredientId.equalsExp(_db.ingredients.id) &
            _db.ingredientAliases.normalizedAlias.equals(norm),
      )
    ]))
        .getSingleOrNull();
    if (aliasJoin != null) {
      final row = aliasJoin.readTable(_db.ingredients);
      return _toDomainWithChildren(row);
    }
    return null;
  }

  @override
  Future<List<Ingredient>> searchByAlias(String query) async {
    final norm = '%${_norm(query)}%';
    final rows = await (_db.select(_db.ingredients).join([
      drift.innerJoin(
        _db.ingredientAliases,
        _db.ingredientAliases.ingredientId.equalsExp(_db.ingredients.id) &
            _db.ingredientAliases.normalizedAlias.like(norm),
      )
    ])).get();
    final ingredients = <Ingredient>[];
    for (final j in rows) {
      final row = j.readTable(_db.ingredients);
      ingredients.add(await _toDomainWithChildren(row));
    }
    return ingredients;
  }

  @override
  Future<List<Ingredient>> searchByENumber(String code) async {
    final normCode = _normalizeENumber(code);
    final joins = await (_db.select(_db.ingredients).join([
      drift.innerJoin(
        _db.ingredientENumbers,
        _db.ingredientENumbers.ingredientId.equalsExp(_db.ingredients.id) &
            _db.ingredientENumbers.enumber.equals(normCode),
      )
    ])).get();
    final results = <Ingredient>[];
    for (final j in joins) {
      final row = j.readTable(_db.ingredients);
      results.add(await _toDomainWithChildren(row));
    }
    return results;
  }

  @override
  Future<void> upsertAll(Iterable<Ingredient> ingredients) async {
    await _db.transaction(() async {
      for (final ing in ingredients) {
        final entity = adb.IngredientsCompanion(
          id: drift.Value(ing.id),
          name: drift.Value(ing.name),
          status: drift.Value(_statusToInt(ing.status)),
          category: drift.Value(ing.category),
          rationale: drift.Value(ing.rationale),
          sourceUrl: drift.Value(ing.sourceUrl),
          lastVerifiedAt: drift.Value(ing.lastVerifiedAt),
          uncertainty: drift.Value(ing.uncertainty),
          processingAid: drift.Value(ing.processingAid),
          normalizedName: drift.Value(_norm(ing.name)),
        );
        await _db.into(_db.ingredients).insertOnConflictUpdate(entity);
        // Replace children
        await (_db.delete(_db.ingredientAliases)
              ..where((t) => t.ingredientId.equals(ing.id)))
            .go();
        await (_db.delete(_db.ingredientENumbers)
              ..where((t) => t.ingredientId.equals(ing.id)))
            .go();
        await (_db.delete(_db.ingredientAlternatives)
              ..where((t) => t.ingredientId.equals(ing.id)))
            .go();
        await (_db.delete(_db.ingredientRegionRules)
              ..where((t) => t.ingredientId.equals(ing.id)))
            .go();

        for (final alias in ing.aliases) {
          await _db.into(_db.ingredientAliases).insert(
                adb.IngredientAliasesCompanion(
                  ingredientId: drift.Value(ing.id),
                  alias: drift.Value(alias),
                  normalizedAlias: drift.Value(_norm(alias)),
                ),
              );
        }
        for (final en in ing.enumbers) {
          final normEn = _normalizeENumber(en);
          await _db.into(_db.ingredientENumbers).insert(
                adb.IngredientENumbersCompanion(
                  ingredientId: drift.Value(ing.id),
                  enumber: drift.Value(normEn),
                ),
              );
        }
        for (final alt in ing.alternatives) {
          await _db.into(_db.ingredientAlternatives).insert(
                adb.IngredientAlternativesCompanion(
                  ingredientId: drift.Value(ing.id),
                  alternative: drift.Value(alt),
                ),
              );
        }
        for (final entry in ing.regionRules.entries) {
          await _db.into(_db.ingredientRegionRules).insert(
                adb.IngredientRegionRulesCompanion(
                  ingredientId: drift.Value(ing.id),
                  regionCode: drift.Value(entry.key),
                  rule: drift.Value(entry.value),
                ),
              );
        }
      }
    });
  }

  @override
  Future<int> count() async {
    final countExp = _db.ingredients.id.count();
    final query = _db.selectOnly(_db.ingredients)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<Ingredient> _toDomainWithChildren(adb.IngredientRow row) async {
    final aliasesRows = await (_db.select(_db.ingredientAliases)
          ..where((t) => t.ingredientId.equals(row.id)))
        .get();
    final enumberRows = await (_db.select(_db.ingredientENumbers)
          ..where((t) => t.ingredientId.equals(row.id)))
        .get();
    final altRows = await (_db.select(_db.ingredientAlternatives)
          ..where((t) => t.ingredientId.equals(row.id)))
        .get();
    final regionRows = await (_db.select(_db.ingredientRegionRules)
          ..where((t) => t.ingredientId.equals(row.id)))
        .get();

    return Ingredient(
      id: row.id,
      name: row.name,
      status: _intToStatus(row.status),
      category: row.category,
      alternatives:
          altRows.map((e) => e.alternative).toList(growable: false),
      aliases: aliasesRows.map((e) => e.alias).toList(growable: false),
      enumbers: enumberRows.map((e) => e.enumber).toList(growable: false),
      regionRules: {
        for (final r in regionRows) r.regionCode: r.rule,
      },
      rationale: row.rationale,
      sourceUrl: row.sourceUrl,
      lastVerifiedAt: row.lastVerifiedAt,
      uncertainty: row.uncertainty,
      processingAid: row.processingAid,
    );
  }

  // Deprecated minimal mapper removed in favor of _toDomainWithChildren.

  VeganStatus _intToStatus(int v) {
    switch (v) {
      case 0:
        return VeganStatus.vegan;
      case 1:
        return VeganStatus.nonVegan;
      default:
        return VeganStatus.maybe;
    }
  }

  int _statusToInt(VeganStatus s) {
    switch (s) {
      case VeganStatus.vegan:
        return 0;
      case VeganStatus.nonVegan:
        return 1;
      case VeganStatus.maybe:
        return 2;
    }
  }
}
