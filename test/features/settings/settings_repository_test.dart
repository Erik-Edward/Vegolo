import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegolo/features/settings/data/repositories/shared_prefs_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('telemetry analytics preference defaults to false and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPrefsSettingsRepository(prefs);

    expect(await repo.getTelemetryAnalyticsEnabled(), isFalse);

    await repo.setTelemetryAnalyticsEnabled(true);
    expect(await repo.getTelemetryAnalyticsEnabled(), isTrue);

    final repo2 = SharedPrefsSettingsRepository(prefs);
    expect(await repo2.getTelemetryAnalyticsEnabled(), isTrue);
  });
}
