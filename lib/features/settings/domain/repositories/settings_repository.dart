import 'package:vegolo/core/ai/generation_options.dart';

abstract class SettingsRepository {
  Future<bool> getSaveFullImages();
  Future<void> setSaveFullImages(bool value);

  Future<bool> getAiAnalysisEnabled();
  Future<void> setAiAnalysisEnabled(bool value);

  Future<GemmaGenerationOptions> getGemmaGenerationOptions();
  Future<void> setGemmaGenerationOptions(GemmaGenerationOptions value);

  Future<bool> getTelemetryAnalyticsEnabled();
  Future<void> setTelemetryAnalyticsEnabled(bool value);
}
