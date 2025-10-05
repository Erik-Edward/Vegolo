import 'package:injectable/injectable.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

@LazySingleton()
class GemmaService {
  const GemmaService();

  Future<VeganAnalysis> analyze({required List<String> ocrTextLines}) async {
    throw UnimplementedError('GemmaService.analyze');
  }
}
