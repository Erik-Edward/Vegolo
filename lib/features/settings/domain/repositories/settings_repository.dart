abstract class SettingsRepository {
  Future<bool> getSaveFullImages();
  Future<void> setSaveFullImages(bool value);
}

