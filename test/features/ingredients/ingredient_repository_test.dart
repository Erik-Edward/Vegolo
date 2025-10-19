import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/database/app_database.dart' as adb;
import 'package:vegolo/features/ingredients/data/repositories/ingredient_repository_impl.dart';
import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';

void main() {
  group('IngredientRepositoryImpl (in-memory)', () {
    late adb.AppDatabase db;
    late IngredientRepositoryImpl repo;

    setUp(() {
      db = adb.AppDatabase.test();
      repo = IngredientRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('upsertAll + findByName', () async {
      final milk = Ingredient(
        id: 'milk',
        name: 'Milk',
        status: VeganStatus.nonVegan,
        aliases: const ['lactose', 'milk solids'],
      );
      final oat = Ingredient(
        id: 'oat-milk',
        name: 'Oat Milk',
        status: VeganStatus.vegan,
        aliases: const ['oat drink'],
      );

      await repo.upsertAll([milk, oat]);

      final foundMilk = await repo.findByName('milk');
      expect(foundMilk, isNotNull);
      expect(foundMilk!.status, VeganStatus.nonVegan);

      final foundByAlias = await repo.findByName('lactose');
      expect(foundByAlias, isNotNull);
      expect(foundByAlias!.id, 'milk');

      final aliasHits = await repo.searchByAlias('drink');
      expect(aliasHits.map((e) => e.id), contains('oat-milk'));
    });
  });
}
