import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegolo/core/ai/gemma_service.dart';
import 'package:vegolo/core/ai/model_manager.dart';
import 'package:vegolo/core/camera/ocr_processor.dart';
import 'package:vegolo/core/camera/scanner_service.dart';
import 'package:vegolo/core/di/injection.dart';
import 'package:vegolo/features/history/data/repositories/scan_history_repository_impl.dart';
import 'package:vegolo/features/history/domain/repositories/scan_history_repository.dart';
import 'package:vegolo/features/ingredients/data/repositories/ingredient_repository_impl.dart';
import 'package:vegolo/features/ingredients/domain/repositories/ingredient_repository.dart';
import 'package:vegolo/features/scanning/data/repositories/scanning_repository_impl.dart';
import 'package:vegolo/features/scanning/domain/repositories/scanning_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('configureDependencies registers core services', () async {
    await configureDependencies();

    expect(getIt.isRegistered<GemmaService>(), isTrue);
    expect(getIt.isRegistered<ModelManager>(), isTrue);
    expect(getIt<ScannerService>(), isA<CameraScannerService>());
    expect(getIt<OcrProcessor>(), isA<MlKitOcrProcessor>());
    expect(getIt<ScanHistoryRepository>(), isA<ScanHistoryRepositoryImpl>());
    expect(getIt<IngredientRepository>(), isA<IngredientRepositoryImpl>());
    expect(getIt<ScanningRepository>(), isA<ScanningRepositoryImpl>());
  });
}
