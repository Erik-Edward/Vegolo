import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton()
class OffCache {
  OffCache(this._prefs);

  final SharedPreferences _prefs;
  static const _prefix = 'off_product_';

  Future<Map<String, dynamic>?> get(String barcode, {Duration ttl = const Duration(days: 30)}) async {
    final key = '$_prefix$barcode';
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = map['cachedAt'] as int?;
      if (ts == null) return null;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > ttl.inMilliseconds) return null;
      return map['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> put(String barcode, Map<String, dynamic> json) async {
    final key = '$_prefix$barcode';
    final payload = jsonEncode({
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': json,
    });
    await _prefs.setString(key, payload);
  }

  Future<int> sizeBytes() async {
    int total = 0;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        total += (_prefs.getString(key)?.length ?? 0);
      }
    }
    return total;
  }

  Future<int> itemCount() async {
    int count = 0;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_prefix)) count++;
    }
    return count;
  }

  Future<void> clear() async {
    final toRemove = <String>[];
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_prefix)) toRemove.add(key);
    }
    for (final k in toRemove) {
      await _prefs.remove(k);
    }
  }
}
