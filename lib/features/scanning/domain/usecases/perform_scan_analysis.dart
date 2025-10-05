import 'package:injectable/injectable.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/features/scanning/domain/services/rule_based_analyzer.dart';

/// Coordinates rule-based analysis and defers to AI (future) when needed.
@lazySingleton
class PerformScanAnalysis {
  PerformScanAnalysis(this._ruleBasedAnalyzer);

  final RuleBasedAnalyzer _ruleBasedAnalyzer;

  Future<VeganAnalysis> call(OcrResult result) async {
    return _ruleBasedAnalyzer.analyze(result);
  }
}
