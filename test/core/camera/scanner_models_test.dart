import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/camera/scanner_models.dart';

void main() {
  group('ScannerConfig', () {
    test('copyWith updates provided values', () {
      const config = ScannerConfig();
      final updated = config.copyWith(
        lensDirection: CameraLensDirection.front,
        resolutionPreset: ResolutionPreset.high,
        targetFps: 24,
        processEveryNthFrame: 2,
        enableAutoFocus: false,
      );

      expect(updated.lensDirection, CameraLensDirection.front);
      expect(updated.resolutionPreset, ResolutionPreset.high);
      expect(updated.targetFps, 24);
      expect(updated.processEveryNthFrame, 2);
      expect(updated.enableAutoFocus, isFalse);
      expect(updated.enableAutoExposure, isTrue);
    });

    test('equatable implementation compares field values', () {
      const a = ScannerConfig(targetFps: 60);
      const b = ScannerConfig(targetFps: 60);

      expect(a, equals(b));
    });
  });

  group('ScannerFrame', () {
    test('equatable compares payloads', () {
      final timestamp = DateTime.now();
      final bytes = Uint8List.fromList([1, 2, 3]);

      final frameA = ScannerFrame(
        bytes: bytes,
        timestamp: timestamp,
        width: 100,
        height: 50,
        rotation: 90,
        isFlashOn: true,
        bytesPerRow: 120,
      );
      final frameB = ScannerFrame(
        bytes: bytes,
        timestamp: timestamp,
        width: 100,
        height: 50,
        rotation: 90,
        isFlashOn: true,
        bytesPerRow: 120,
      );

      expect(frameA, equals(frameB));
      expect(frameA.hashCode, equals(frameB.hashCode));
    });
  });
}
