import 'dart:collection';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../domain/entities/off_product.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../clients/open_food_facts_client.dart';
import '../cache/off_cache.dart';
import '../models/off_product_model.dart';

@LazySingleton(as: BarcodeRepository)
class BarcodeRepositoryImpl implements BarcodeRepository {
  BarcodeRepositoryImpl(this._client, this._cache);

  final OpenFoodFactsClient _client;
  final OffCache _cache;

  // In-memory LRU cache for OFF products (session-only)
  static const _maxEntries = 64;
  final _lru = _LruCache<String, OffProduct>(_maxEntries);

  @override
  Future<OffProduct?> fetchOffProduct(String barcode) async {
    final cached = _lru.get(barcode);
    if (cached != null) return cached;

    // Disk cache (short TTL) to avoid repeated calls and enable offline.
    Map<String, dynamic>? json = await _cache.get(barcode);
    json ??= await _client.fetchProductJson(barcode);
    if (json != null) {
      // Store to disk cache for future use.
      await _cache.put(barcode, json);
    }
    if (json == null) return null;
    final model = OffProductModel.fromJson(json);
    final product = model.toDomain();
    if (product.productName != null || product.imageUrl != null) {
      _lru.put(barcode, product);
    }
    return product;
  }

  @override
  Future<Uint8List?> fetchImageBytes(String url) {
    return _client.downloadImageBytes(url);
  }
}

class _LruCache<K, V> {
  _LruCache(this._capacity);
  final int _capacity;
  final _map = LinkedHashMap<K, V>();

  V? get(K key) {
    final v = _map.remove(key);
    if (v != null) {
      _map[key] = v; // re-insert to mark as most-recent
    }
    return v;
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= _capacity && _map.isNotEmpty) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }
}
