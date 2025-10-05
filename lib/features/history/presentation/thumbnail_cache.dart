import 'dart:collection';
import 'dart:io';

import 'package:flutter/widgets.dart';

/// A simple in-memory LRU cache for decoded thumbnail images.
class ThumbnailCache {
  ThumbnailCache({this.capacity = 128});

  final int capacity;
  final _map = LinkedHashMap<String, ImageProvider>(
    equals: (a, b) => a == b,
    hashCode: (k) => k.hashCode,
  );

  ImageProvider? get(String path) {
    final existing = _map.remove(path);
    if (existing != null) {
      // Re-insert to mark as most recently used
      _map[path] = existing;
      return existing;
    }
    return null;
  }

  void put(String path, ImageProvider provider) {
    if (_map.length >= capacity && !_map.containsKey(path)) {
      // Evict least-recently-used (first entry)
      _map.remove(_map.keys.first);
    }
    _map[path] = provider;
  }

  Future<ImageProvider> load(String path) async {
    final hit = get(path);
    if (hit != null) return hit;
    final bytes = await File(path).readAsBytes();
    final provider = MemoryImage(bytes);
    put(path, provider);
    return provider;
  }
}

final thumbnailCache = ThumbnailCache();
