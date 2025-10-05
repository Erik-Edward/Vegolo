import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/camera/scanner_models.dart';

void main() {
  group('OcrResult', () {
    test('stores full text and block metadata', () {
      final frame = ScannerFrame(
        bytes: Uint8List.fromList([0, 1]),
        timestamp: DateTime.utc(2024),
      );
      const block = OcrTextBlock(
        text: 'vegan',
        languageCode: 'en',
        boundingBox: OcrBoundingBox(left: 1, top: 2, right: 10, bottom: 12),
      );

      final result = OcrResult(
        fullText: 'vegan ingredient',
        blocks: const [block],
        frame: frame,
      );

      expect(result.fullText, 'vegan ingredient');
      expect(result.blocks, equals(const [block]));
      expect(result.frame, equals(frame));
    });
  });
}
