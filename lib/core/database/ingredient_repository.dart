import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';

abstract class IngredientLocalDataSource {
  Future<void> upsert(Ingredient ingredient);
  Future<Ingredient?> findById(String id);
  Future<List<Ingredient>> search(String query);
}
