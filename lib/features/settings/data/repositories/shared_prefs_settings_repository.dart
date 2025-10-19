import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegolo/core/ai/generation_options.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _keySaveFullImages = 'save_full_images';
  static const _keyAiAnalysisEnabled = 'ai_analysis_enabled';
  static const _keyGemmaDecodeOptions = 'gemma_decode_options';

  @override
  Future<bool> getSaveFullImages() async {
    // Default: disabled (thumbnails only)
    return _prefs.getBool(_keySaveFullImages) ?? false;
  }

  @override
  Future<void> setSaveFullImages(bool value) async {
    await _prefs.setBool(_keySaveFullImages, value);
  }

  @override
  Future<bool> getAiAnalysisEnabled() async {
    return _prefs.getBool(_keyAiAnalysisEnabled) ?? false;
  }

  @override
  Future<void> setAiAnalysisEnabled(bool value) async {
    await _prefs.setBool(_keyAiAnalysisEnabled, value);
  }

  @override
  Future<GemmaGenerationOptions> getGemmaGenerationOptions() async {
    final raw = _prefs.getString(_keyGemmaDecodeOptions);
    return GemmaGenerationOptions.fromEncoded(raw);
  }

  @override
  Future<void> setGemmaGenerationOptions(GemmaGenerationOptions value) async {
    await _prefs.setString(_keyGemmaDecodeOptions, value.encode());
  }
}
