import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/camera/ocr_processor.dart';
import 'package:vegolo/core/camera/scanner_models.dart';
import 'package:vegolo/core/camera/scanner_service.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/features/scanning/domain/usecases/perform_scan_analysis.dart';
import 'package:vegolo/features/scanning/presentation/bloc/scanning_bloc.dart';
import 'package:vegolo/core/ai/gemma_service.dart';

class _MockScannerService extends Mock implements ScannerService {}

class _MockOcrProcessor extends Mock implements OcrProcessor {}

class _MockPerformScanAnalysis extends Mock implements PerformScanAnalysis {}

class _ScannerFrameFake extends Fake implements ScannerFrame {
  @override
  Uint8List get bytes => Uint8List(0);

  @override
  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(0);

  @override
  int? get width => 0;

  @override
  int? get height => 0;

  @override
  int? get rotation => 0;

  @override
  bool? get isFlashOn => false;

  @override
  int? get bytesPerRow => 0;
}

class _FakeProgressCallback extends Fake {
  void call(GemmaAnalysisProgress progress) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockScannerService scannerService;
  late _MockOcrProcessor ocrProcessor;
  late _MockPerformScanAnalysis performScanAnalysis;
  late StreamController<ScannerFrame> frameController;
  late ScanningBloc bloc;

  setUpAll(() {
    registerFallbackValue(const ScannerConfig());
    registerFallbackValue(FlashMode.off);
    registerFallbackValue(_ScannerFrameFake());
    registerFallbackValue(const VeganAnalysis(isVegan: true, confidence: 1));
    registerFallbackValue(
      OcrResult(fullText: '', blocks: const [], frame: _ScannerFrameFake()),
    );
    registerFallbackValue(_FakeProgressCallback());
  });

  setUp(() {
    scannerService = _MockScannerService();
    ocrProcessor = _MockOcrProcessor();
    performScanAnalysis = _MockPerformScanAnalysis();
    frameController = StreamController<ScannerFrame>.broadcast();

    when(() => scannerService.initialize(any())).thenAnswer((_) async {});
    when(
      () => scannerService.frames(),
    ).thenAnswer((_) => frameController.stream);
    when(() => scannerService.pause()).thenAnswer((_) async {});
    when(() => scannerService.resume()).thenAnswer((_) async {});
    when(() => scannerService.updateFlashMode(any())).thenAnswer((_) async {});
    when(() => scannerService.dispose()).thenAnswer((_) async {});
    when(() => scannerService.openAppSettings()).thenAnswer((_) async {});
    when(() => scannerService.captureStill()).thenAnswer((_) async => null);
    when(
      () => scannerService.ensurePermissions(),
    ).thenAnswer((_) async => CameraAuthorizationStatus.granted);
    when(() => ocrProcessor.dispose()).thenAnswer((_) async {});
    when(() => ocrProcessor.processFrame(any())).thenAnswer((invocation) async {
      final frame = invocation.positionalArguments.first as ScannerFrame;
      return OcrResult(
        fullText: 'detected text',
        blocks: const [],
        frame: frame,
      );
    });
    when(
      () =>
          performScanAnalysis(any(), onAiProgress: any(named: 'onAiProgress')),
    ).thenAnswer((_) async {
      return const VeganAnalysis(isVegan: true, confidence: 0.8);
    });
    when(() => performScanAnalysis.cancelAi()).thenAnswer((_) async {});

    bloc = ScanningBloc(
      scannerService: scannerService,
      ocrProcessor: ocrProcessor,
      performScanAnalysis: performScanAnalysis,
    );
  });

  tearDown(() async {
    if (!bloc.isClosed) {
      await bloc.close();
    }
    await frameController.close();
  });

  test('starts in idle state', () {
    expect(bloc.state.status, ScanningStatus.idle);
  });

  test('emits scanning then success when frame received', () async {
    bloc.add(const ScanningStarted());
    await pumpEventQueue();

    final frame = ScannerFrame(
      bytes: Uint8List.fromList([0]),
      timestamp: DateTime.utc(2024),
      width: 1,
      height: 1,
      bytesPerRow: 1,
    );
    frameController.add(frame);
    await pumpEventQueue();

    expect(bloc.state.status, ScanningStatus.success);
    expect(bloc.state.latestFrame, equals(frame));
    expect(bloc.state.ocrResult?.fullText, 'detected text');
    verify(() => ocrProcessor.processFrame(frame)).called(1);
    verify(
      () =>
          performScanAnalysis(any(), onAiProgress: any(named: 'onAiProgress')),
    ).called(1);
    expect(bloc.state.analysis?.isVegan, isTrue);
  });

  test('pause triggers scanner pause and updates state', () async {
    bloc.add(const ScanningStarted());
    await pumpEventQueue();

    bloc.add(const ScanningPaused());
    await pumpEventQueue();

    verify(() => scannerService.pause()).called(1);
    expect(bloc.state.status, ScanningStatus.paused);
  });

  test('stop pauses scanner and resets state', () async {
    bloc.add(const ScanningStarted());
    await pumpEventQueue();

    bloc.add(const ScanningStopped());
    await pumpEventQueue();

    verify(() => scannerService.pause()).called(1);
    expect(bloc.state.status, ScanningStatus.idle);
    expect(bloc.state.latestFrame, isNull);
    expect(bloc.state.ocrResult, isNull);
    expect(bloc.state.analysis, isNull);
  });

  test(
    'keeps scanning and surfaces soft error when OCR processing throws',
    () async {
      when(
        () => ocrProcessor.processFrame(any()),
      ).thenThrow(Exception('ocr failed'));

      bloc.add(const ScanningStarted());
      await pumpEventQueue();

      frameController.add(
        ScannerFrame(
          bytes: Uint8List.fromList([1]),
          timestamp: DateTime.now(),
          width: 1,
          height: 1,
          bytesPerRow: 1,
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.status, ScanningStatus.scanning);
      expect(bloc.state.errorMessage, contains('Uncertain'));
      expect(bloc.state.analysis, isNull);
      verifyNever(
        () => performScanAnalysis(
          any(),
          onAiProgress: any(named: 'onAiProgress'),
        ),
      );
    },
  );

  test('open settings event forwards to scanner service', () async {
    bloc.add(const ScanningOpenSettingsRequested());
    await pumpEventQueue();

    verify(() => scannerService.openAppSettings()).called(1);
  });

  test('close disposes OCR processor', () async {
    await bloc.close();

    verify(() => ocrProcessor.dispose()).called(1);
  });
}
