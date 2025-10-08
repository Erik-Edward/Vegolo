import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/camera/ocr_processor.dart';
import 'package:vegolo/core/camera/scanner_models.dart';
import 'package:vegolo/core/camera/scanner_service.dart';

/// Integration-style scaffold that simulates the camera → OCR flow without
/// depending on device plugins. Acts as a template for future end-to-end tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Camera → OCR pipeline (scaffold)', () {
    late FakeScannerService scannerService;
    late StubOcrProcessor ocrProcessor;

    setUp(() {
      scannerService = FakeScannerService();
      ocrProcessor = StubOcrProcessor();
    });

    tearDown(() async {
      await scannerService.dispose();
      await ocrProcessor.dispose();
    });

    test('emits frames and forwards them to OCR', () async {
      final frame = ScannerFrame(
        bytes: Uint8List.fromList([1, 2, 3]),
        timestamp: DateTime.utc(2024),
        width: 2,
        height: 2,
        rotation: 0,
        bytesPerRow: 2,
      );
      scannerService.enqueue(frame);

      final frames = <ScannerFrame>[];
      final subscription = scannerService.frames().listen(frames.add);
      await scannerService.initialize(const ScannerConfig());
      await pumpEventQueue();
      await subscription.cancel();

      expect(frames, [frame]);

      ocrProcessor.stubResult = OcrResult(
        fullText: 'vegan sugar',
        blocks: const [],
        frame: frame,
      );

      final result = await ocrProcessor.processFrame(frames.first);

      expect(ocrProcessor.processedFrames, contains(frame));
      expect(result.fullText, 'vegan sugar');
    });
  });
}

class FakeScannerService implements ScannerService {
  final _controller = StreamController<ScannerFrame>.broadcast();
  final _pendingFrames = <ScannerFrame>[];
  bool _initialized = false;

  @override
  CameraController? get previewController => null;

  @override
  Future<void> setFocusAndExposurePoint(Offset point) async {}

  void enqueue(ScannerFrame frame) {
    if (_initialized) {
      _controller.add(frame);
    } else {
      _pendingFrames.add(frame);
    }
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
    _pendingFrames.clear();
    _initialized = false;
  }

  @override
  Stream<ScannerFrame> frames() => _controller.stream;

  @override
  Future<void> initialize(ScannerConfig config) async {
    _initialized = true;
    for (final frame in _pendingFrames) {
      _controller.add(frame);
    }
    _pendingFrames.clear();
  }

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

class StubOcrProcessor extends Mock implements OcrProcessor {
  StubOcrProcessor();

  final processedFrames = <ScannerFrame>[];
  OcrResult? stubResult;

  @override
  Future<OcrResult> processFrame(ScannerFrame frame) async {
    processedFrames.add(frame);
    return stubResult ??
        OcrResult(fullText: '', blocks: const [], frame: frame);
  }

  @override
  Future<void> dispose() async {}
}
