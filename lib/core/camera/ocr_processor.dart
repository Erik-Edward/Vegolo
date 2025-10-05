import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:injectable/injectable.dart';

import 'ocr_models.dart';
import 'scanner_models.dart';

abstract class OcrProcessor {
  Future<OcrResult> processFrame(ScannerFrame frame);
  Future<void> dispose();
}

@LazySingleton(as: OcrProcessor)
class MlKitOcrProcessor implements OcrProcessor {
  MlKitOcrProcessor() : _textRecognizer = TextRecognizer();

  @visibleForTesting
  MlKitOcrProcessor.test(TextRecognizer textRecognizer)
    : _textRecognizer = textRecognizer;

  final TextRecognizer _textRecognizer;

  @override
  Future<OcrResult> processFrame(ScannerFrame frame) async {
    if (frame.bytes.isEmpty) {
      throw ArgumentError('ScannerFrame bytes must not be empty.');
    }

    final width = frame.width;
    final height = frame.height;
    if (width == null || height == null) {
      throw ArgumentError('ScannerFrame width and height are required.');
    }

    final metadata = InputImageMetadata(
      size: Size(width.toDouble(), height.toDouble()),
      rotation:
          InputImageRotationValue.fromRawValue(frame.rotation ?? 0) ??
          InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21,
      bytesPerRow: frame.bytesPerRow ?? width,
    );

    final inputImage = InputImage.fromBytes(
      bytes: frame.bytes,
      metadata: metadata,
    );

    final recognizedText = await _textRecognizer.processImage(inputImage);

    final blocks = recognizedText.blocks
        .map(
          (block) => OcrTextBlock(
            text: block.text,
            languageCode: block.recognizedLanguages.isNotEmpty
                ? block.recognizedLanguages.first
                : null,
            boundingBox: _mapBoundingBox(block.boundingBox),
          ),
        )
        .toList(growable: false);

    return OcrResult(
      fullText: recognizedText.text,
      blocks: blocks,
      frame: frame,
    );
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    try {
      await _textRecognizer.close();
    } on MissingPluginException {
      // Ignore when plugin channel unavailable (e.g., widget tests).
    }
  }

  OcrBoundingBox? _mapBoundingBox(Rect? bounds) {
    if (bounds == null) {
      return null;
    }
    return OcrBoundingBox(
      left: bounds.left,
      top: bounds.top,
      right: bounds.right,
      bottom: bounds.bottom,
    );
  }
}
