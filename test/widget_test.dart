import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/camera/ocr_processor.dart';
import 'package:vegolo/core/camera/scanner_models.dart';
import 'package:vegolo/core/camera/scanner_service.dart';
import 'package:vegolo/core/di/injection.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/features/scanning/domain/usecases/perform_scan_analysis.dart';
import 'package:vegolo/features/scanning/presentation/bloc/scanning_bloc.dart';
import 'package:vegolo/main.dart';
import 'package:vegolo/shared/utils/constants.dart';
import 'package:vegolo/features/history/domain/repositories/scan_history_repository.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

class _DummyScannerService implements ScannerService {
  const _DummyScannerService();

  @override
  CameraController? get previewController => null;

  @override
  Future<void> setFocusAndExposurePoint(Offset point) async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<ScannerFrame> frames() => const Stream.empty();

  @override
  Future<void> initialize(ScannerConfig config) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> updateFlashMode(FlashMode mode) async {}

  @override
  Future<CameraAuthorizationStatus> ensurePermissions() async =>
      CameraAuthorizationStatus.granted;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<String?> captureStill() async => null;

  @override
  Future<void> setProcessEveryNthFrame(int n) async {}
}

class _DummyOcrProcessor implements OcrProcessor {
  const _DummyOcrProcessor();

  @override
  Future<void> dispose() async {}

  @override
  Future<OcrResult> processFrame(ScannerFrame frame) async {
    return OcrResult(fullText: '', blocks: const [], frame: frame);
  }
}

class _DummyPerformScanAnalysis implements PerformScanAnalysis {
  @override
  Future<VeganAnalysis> call(OcrResult result) async {
    return const VeganAnalysis(isVegan: true, confidence: 0.5);
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt
      ..registerLazySingleton<ScannerService>(
        () => const _DummyScannerService(),
      )
      ..registerLazySingleton<OcrProcessor>(() => const _DummyOcrProcessor())
      ..registerLazySingleton<PerformScanAnalysis>(
        () => _DummyPerformScanAnalysis(),
      )
      ..registerFactory<ScanningBloc>(
        () => ScanningBloc(
          scannerService: getIt(),
          ocrProcessor: getIt(),
          performScanAnalysis: getIt(),
        ),
      )
      ..registerLazySingleton<ScanHistoryRepository>(
        () => _DummyHistoryRepo(),
      )
      ..registerLazySingleton<SettingsRepository>(
        () => _DummySettingsRepo(),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('VegoloApp renders scanning shell', (tester) async {
    await tester.pumpWidget(const VegoloApp());

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Ready to scan'), findsOneWidget);
    expect(find.text('Begin scanning'), findsOneWidget);
  });
}

class _DummyHistoryRepo implements ScanHistoryRepository {
  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteEntry(String id) async {}

  @override
  Future<void> deleteEntryImageData(String id) async {}

  @override
  Future<void> saveEntry(ScanHistoryEntry entry) async {}

  @override
  Stream<List<ScanHistoryEntry>> watchHistory() => const Stream.empty();
}

class _DummySettingsRepo implements SettingsRepository {
  bool _v = false;
  @override
  Future<bool> getSaveFullImages() async => _v;

  @override
  Future<void> setSaveFullImages(bool value) async {
    _v = value;
  }

  @override
  Future<bool> getAiAnalysisEnabled() async => false;

  @override
  Future<void> setAiAnalysisEnabled(bool value) async {}
}
