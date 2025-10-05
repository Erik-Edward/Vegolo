import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';

abstract class IngredientRepository {
  Future<Ingredient?> findByName(String name);
  Future<List<Ingredient>> searchByAlias(String query);
  Future<List<Ingredient>> searchByENumber(String code);
  Future<void> upsertAll(Iterable<Ingredient> ingredients);
  Future<int> count();
}
