import 'dart:typed_data';

import '../entities/off_product.dart';

abstract class BarcodeRepository {
  Future<OffProduct?> fetchOffProduct(String barcode);

  // Small helper to fetch image bytes for thumbnailing when needed.
  Future<Uint8List?> fetchImageBytes(String url);
}

