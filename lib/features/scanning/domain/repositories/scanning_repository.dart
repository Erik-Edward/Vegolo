import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

abstract class ScanningRepository {
  Future<VeganAnalysis> analyzeIngredients({required List<String> ingredients});
}
