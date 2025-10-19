import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vegolo/core/ai/gemma_service.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/camera/scanner_models.dart';
import 'package:vegolo/features/ingredients/domain/entities/ingredient.dart';
import 'package:vegolo/features/ingredients/domain/repositories/ingredient_repository.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/features/scanning/domain/services/rule_based_analyzer.dart';
import 'package:vegolo/features/scanning/domain/usecases/perform_scan_analysis.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

class _StubIngredientRepository implements IngredientRepository {
  @override
  Future<int> count() async => 0;

  @override
  Future<Ingredient?> findByName(String name) async => null;

  @override
  Future<List<Ingredient>> searchByAlias(String query) async => const [];

  @override
  Future<List<Ingredient>> searchByENumber(String code) async => const [];

  @override
  Future<void> upsertAll(Iterable<Ingredient> ingredients) async {}
}

class _StubRuleAnalyzer extends RuleBasedAnalyzer {
  _StubRuleAnalyzer(this._analysis) : super(_StubIngredientRepository());

  final VeganAnalysis _analysis;

  @override
  Future<VeganAnalysis> analyze(OcrResult result) async => _analysis;
}

class _FakeSettingsRepository implements SettingsRepository {
  bool aiEnabled = false;

  @override
  Future<bool> getAiAnalysisEnabled() async => aiEnabled;

  @override
  Future<bool> getSaveFullImages() async => false;

  @override
  Future<void> setAiAnalysisEnabled(bool value) async {
    aiEnabled = value;
  }

  @override
  Future<void> setSaveFullImages(bool value) async {}
}

class _MockGemmaService extends Mock implements GemmaService {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(const Duration(milliseconds: 1));
    registerFallbackValue(0.0);
  });

  group('PerformScanAnalysis', () {
    late _FakeSettingsRepository settings;
    late _MockGemmaService gemma;

    setUp(() {
      settings = _FakeSettingsRepository();
      gemma = _MockGemmaService();
    });

    test('skips Gemma when feature disabled', () async {
      settings.aiEnabled = false;
      final ruleResult = VeganAnalysis(isVegan: true, confidence: 0.2);
      final usecase = PerformScanAnalysis(
        _StubRuleAnalyzer(ruleResult),
        gemma,
        settings,
      );

      final result = await usecase(
        OcrResult(
          fullText: 'oat',
          blocks: const [],
          frame: ScannerFrame(
            bytes: Uint8List(0),
            timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ),
      );

      verifyNever(() => gemma.analyze(ocrTextLines: any(named: 'ocrTextLines')));
      expect(result, equals(ruleResult));
    });

    test('invokes Gemma when enabled and rule uncertain', () async {
      settings.aiEnabled = true;
      final ruleResult = VeganAnalysis(isVegan: true, confidence: 0.2);
      final aiResult = VeganAnalysis(isVegan: false, confidence: 0.8);

      when(
        () => gemma.analyze(
          ocrTextLines: any<List<String>>(named: 'ocrTextLines'),
          timeout: any(named: 'timeout'),
          deviceRamGb: any(named: 'deviceRamGb'),
        ),
      ).thenAnswer((_) async => aiResult);

      final usecase = PerformScanAnalysis(
        _StubRuleAnalyzer(ruleResult),
        gemma,
        settings,
      );

      final result = await usecase(
        OcrResult(
          fullText: 'may contain whey',
          blocks: const [],
          frame: ScannerFrame(
            bytes: Uint8List(0),
            timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ),
      );

      verify(
        () => gemma.analyze(
          ocrTextLines: any<List<String>>(named: 'ocrTextLines'),
          timeout: any(named: 'timeout'),
          deviceRamGb: any(named: 'deviceRamGb'),
        ),
      ).called(1);
      expect(result, equals(aiResult));
    });

    test('keeps deterministic non-vegan rule decision', () async {
      settings.aiEnabled = true;
      final ruleResult = VeganAnalysis(
        isVegan: false,
        confidence: 0.9,
        flaggedIngredients: const ['gelatin'],
      );

      final usecase = PerformScanAnalysis(
        _StubRuleAnalyzer(ruleResult),
        gemma,
        settings,
      );

      final result = await usecase(
        OcrResult(
          fullText: 'gelatin',
          blocks: const [],
          frame: ScannerFrame(
            bytes: Uint8List(0),
            timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ),
      );

      verifyNever(
        () => gemma.analyze(
          ocrTextLines: any<List<String>>(named: 'ocrTextLines'),
          timeout: any(named: 'timeout'),
          deviceRamGb: any(named: 'deviceRamGb'),
        ),
      );
      expect(result, equals(ruleResult));
    });
  });
}
