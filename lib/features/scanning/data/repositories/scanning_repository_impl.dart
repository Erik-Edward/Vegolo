import 'package:injectable/injectable.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/features/scanning/domain/repositories/scanning_repository.dart';

@LazySingleton(as: ScanningRepository)
class ScanningRepositoryImpl implements ScanningRepository {
  const ScanningRepositoryImpl();

  @override
  Future<VeganAnalysis> analyzeIngredients({
    required List<String> ingredients,
  }) async {
    throw UnimplementedError('ScanningRepositoryImpl.analyzeIngredients');
  }
}
