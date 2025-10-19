import 'package:injectable/injectable.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/ai/gemma_service.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';
import 'package:vegolo/features/scanning/domain/services/rule_based_analyzer.dart';

/// Coordinates rule-based analysis and defers to AI (future) when needed.
@lazySingleton
class PerformScanAnalysis {
  PerformScanAnalysis(
    this._ruleBasedAnalyzer,
    this._gemmaService,
    this._settingsRepository,
  );

  final RuleBasedAnalyzer _ruleBasedAnalyzer;
  final GemmaService _gemmaService;
  final SettingsRepository _settingsRepository;
  final AiAnalysisConfig _config = const AiAnalysisConfig();

  Future<VeganAnalysis> call(
    OcrResult result, {
    void Function(GemmaAnalysisProgress progress)? onAiProgress,
  }) async {
    final ruleAnalysis = await _ruleBasedAnalyzer.analyze(result);

    final aiEnabled =
        _config.aiEnabledOverride ??
        await _settingsRepository.getAiAnalysisEnabled();
    final generationOptions = await _settingsRepository
        .getGemmaGenerationOptions();

    if (!aiEnabled) {
      return ruleAnalysis;
    }

    if (!_shouldConsultAi(ruleAnalysis)) {
      return ruleAnalysis;
    }

    final aiAnalysis = await _gemmaService.analyze(
      ocrTextLines: _extractLines(result),
      timeout: _config.aiTimeout,
      generationOptions: generationOptions,
      onProgress: onAiProgress,
    );

    if (aiAnalysis == null) {
      return ruleAnalysis;
    }

    return _mergeAnalyses(ruleAnalysis, aiAnalysis);
  }

  bool _shouldConsultAi(VeganAnalysis ruleAnalysis) {
    if (!ruleAnalysis.isVegan && ruleAnalysis.flaggedIngredients.isNotEmpty) {
      // Deterministic non-vegan decision stays authoritative.
      return false;
    }
    return ruleAnalysis.confidence < _config.minRuleConfidence;
  }

  List<String> _extractLines(OcrResult result) {
    if (result.fullText.isEmpty) {
      return const [];
    }
    return result.fullText.split('\n');
  }

  VeganAnalysis _mergeAnalyses(
    VeganAnalysis ruleAnalysis,
    VeganAnalysis aiAnalysis,
  ) {
    final mergedFlagged = aiAnalysis.flaggedIngredients.isNotEmpty
        ? aiAnalysis.flaggedIngredients
        : ruleAnalysis.flaggedIngredients;
    final mergedAlternatives = {
      ...ruleAnalysis.alternatives,
      ...aiAnalysis.alternatives,
    }.toList(growable: false);

    return ruleAnalysis.copyWith(
      isVegan: aiAnalysis.isVegan,
      confidence: aiAnalysis.confidence,
      flaggedIngredients: mergedFlagged,
      alternatives: mergedAlternatives,
    );
  }

  Future<void> cancelAi() => _gemmaService.cancelActiveAnalysis();
}

class AiAnalysisConfig {
  const AiAnalysisConfig({
    this.aiEnabledOverride,
    this.minRuleConfidence = 0.75,
    this.aiTimeout = const Duration(milliseconds: 220),
  });

  final bool? aiEnabledOverride;
  final double minRuleConfidence;
  final Duration aiTimeout;
}
