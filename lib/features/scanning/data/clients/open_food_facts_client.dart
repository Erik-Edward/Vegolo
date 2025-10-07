import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class OpenFoodFactsClient {
  OpenFoodFactsClient(this._http);

  final http.Client _http;

  // Fetch OFF product by barcode. Returns JSON map or null on error.
  Future<Map<String, dynamic>?> fetchProductJson(String barcode) async {
    final uri = Uri.https('world.openfoodfacts.org', '/api/v2/product/$barcode.json');
    try {
      final resp = await _http.get(uri);
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Uint8List?> downloadImageBytes(String url) async {
    try {
      final uri = Uri.parse(url);
      final resp = await _http.get(uri);
      if (resp.statusCode == 200) {
        return resp.bodyBytes;
      }
    } catch (_) {}
    return null;
  }
}

