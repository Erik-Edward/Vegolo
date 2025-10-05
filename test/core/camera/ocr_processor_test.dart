import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vegolo/core/camera/ocr_processor.dart';
import 'package:vegolo/core/camera/scanner_models.dart';

class _MockTextRecognizer extends Mock implements TextRecognizer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dispose closes the underlying text recognizer', () async {
    final recognizer = _MockTextRecognizer();
    when(() => recognizer.close()).thenAnswer((_) async {});

    final processor = MlKitOcrProcessor.test(recognizer);

    await processor.dispose();

    verify(() => recognizer.close()).called(1);
  });

  test('processFrame throws when width or height missing', () async {
    final recognizer = _MockTextRecognizer();
    final processor = MlKitOcrProcessor.test(recognizer);

    expect(
      () => processor.processFrame(
        ScannerFrame(bytes: Uint8List.fromList([0]), timestamp: DateTime.now()),
      ),
      throwsArgumentError,
    );
  });
}
