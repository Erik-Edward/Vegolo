abstract class SettingsRepository {
  Future<bool> getSaveFullImages();
  Future<void> setSaveFullImages(bool value);

  Future<bool> getAiAnalysisEnabled();
  Future<void> setAiAnalysisEnabled(bool value);
}
