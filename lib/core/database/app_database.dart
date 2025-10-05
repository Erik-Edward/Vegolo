import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// Ingredient schema (v2+ will extend if needed)
@DataClassName('IngredientRow')
class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get status => integer()();
  TextColumn get category => text().nullable()();
  TextColumn get rationale => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();
  RealColumn get uncertainty => real().nullable()();
  BoolColumn get processingAid => boolean().nullable()();
  TextColumn get normalizedName => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('IngredientAliasRow')
class IngredientAliases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  TextColumn get alias => text()();
  TextColumn get normalizedAlias => text()();
}

@DataClassName('IngredientENumberRow')
class IngredientENumbers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  TextColumn get enumber => text()();
}

@DataClassName('IngredientAlternativeRow')
class IngredientAlternatives extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  TextColumn get alternative => text()();
}

@DataClassName('IngredientRegionRuleRow')
class IngredientRegionRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  TextColumn get regionCode => text()();
  TextColumn get rule => text()();
}

class ScanHistoryEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get scannedAt => dateTime()();
  TextColumn get analysisJson => text()();
  TextColumn get productName => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get fullImagePath => text().nullable()();
  BoolColumn get hasFullImage => boolean().withDefault(const Constant(false))();
  TextColumn get detectedIngredientsJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'vegolo.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@LazySingleton()
@DriftDatabase(tables: [
  ScanHistoryEntries,
  Ingredients,
  IngredientAliases,
  IngredientENumbers,
  IngredientAlternatives,
  IngredientRegionRules,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Test-only: create an in-memory database.
  AppDatabase.test() : super(NativeDatabase.memory());
}
