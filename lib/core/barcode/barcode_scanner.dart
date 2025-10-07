import 'package:flutter/widgets.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:injectable/injectable.dart';

import '../camera/scanner_models.dart';

/// Lightweight service to detect barcodes from camera frames.
abstract class BarcodeScannerService {
  Future<String?> detectBarcode(ScannerFrame frame);
  Future<void> dispose();
}

@LazySingleton(as: BarcodeScannerService)
class MlKitBarcodeScannerService implements BarcodeScannerService {
  MlKitBarcodeScannerService()
      : _scanner = BarcodeScanner(
          formats: [
            BarcodeFormat.ean8,
            BarcodeFormat.ean13,
            BarcodeFormat.upca,
            BarcodeFormat.upce,
          ],
        );

  @visibleForTesting
  MlKitBarcodeScannerService.test(BarcodeScanner scanner) : _scanner = scanner;

  final BarcodeScanner _scanner;

  @override
  Future<String?> detectBarcode(ScannerFrame frame) async {
    if (frame.bytes.isEmpty) return null;
    final width = frame.width;
    final height = frame.height;
    if (width == null || height == null) return null;

    final metadata = InputImageMetadata(
      size: Size(width.toDouble(), height.toDouble()),
      rotation: InputImageRotationValue.fromRawValue(frame.rotation ?? 0) ??
          InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21,
      bytesPerRow: frame.bytesPerRow ?? width,
    );

    final input = InputImage.fromBytes(bytes: frame.bytes, metadata: metadata);
    final barcodes = await _scanner.processImage(input);
    if (barcodes.isEmpty) return null;
    for (final b in barcodes) {
      final value = b.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    await _scanner.close();
  }
}
