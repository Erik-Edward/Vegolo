import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/ai/generation_options.dart';
import 'package:vegolo/features/history/data/models/scan_history_entry_model.dart';
import 'package:vegolo/features/history/data/repositories/scan_history_repository_impl.dart';
import 'package:vegolo/features/history/data/thumbnail_generator.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/core/database/scan_history_local_data_source.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

class _FakeThumbnailGenerator extends ThumbnailGenerator {
  @override
  Future<Uint8List> createThumbnail(
    Uint8List sourceBytes, {
    int maxDimension = 200,
  }) async {
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<String> persistThumbnail(Uint8List thumbnailBytes) async {
    // Pretend we wrote a file but don't actually touch disk.
    return '/tmp/fake_thumb.jpg';
  }
}

class _InMemoryHistoryDataSource implements ScanHistoryLocalDataSource {
  final List<ScanHistoryEntryModel> _items = [];

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<List<ScanHistoryEntryModel>> getAllEntries() async => List.of(_items);

  @override
  Future<ScanHistoryEntryModel?> getById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteById(String id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> insertEntry(ScanHistoryEntryModel entry) async {
    _items.removeWhere((e) => e.id == entry.id);
    _items.add(entry);
  }

  @override
  Stream<List<ScanHistoryEntryModel>> watchEntries() async* {
    yield List.of(_items);
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._saveFull);
  bool _saveFull;
  GemmaGenerationOptions _options = GemmaGenerationOptions.defaults;

  @override
  Future<bool> getSaveFullImages() async => _saveFull;

  @override
  Future<void> setSaveFullImages(bool value) async {
    _saveFull = value;
  }

  @override
  Future<bool> getAiAnalysisEnabled() async => false;

  @override
  Future<void> setAiAnalysisEnabled(bool value) async {}

  @override
  Future<GemmaGenerationOptions> getGemmaGenerationOptions() async => _options;

  @override
  Future<void> setGemmaGenerationOptions(GemmaGenerationOptions value) async {
    _options = value;
  }

  @override
  Future<bool> getTelemetryAnalyticsEnabled() async => false;

  @override
  Future<void> setTelemetryAnalyticsEnabled(bool value) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deletes full image when saveFullImages is disabled', () async {
    // Arrange: create a temporary full-size image file
    final tmpDir = Directory.systemTemp.createTempSync('vegolo_test_');
    final full = File('${tmpDir.path}/full.jpg');
    await full.writeAsBytes(List.filled(10, 42));

    final repo = ScanHistoryRepositoryImpl(
      _FakeThumbnailGenerator(),
      _InMemoryHistoryDataSource(),
      _FakeSettingsRepository(false),
    );

    final entry = ScanHistoryEntry(
      id: '1',
      scannedAt: DateTime.now(),
      analysis: const VeganAnalysis(isVegan: true, confidence: 0.5),
      fullImagePath: full.path,
      hasFullImage: true,
    );

    // Act
    await repo.saveEntry(entry);

    // Assert
    expect(
      await full.exists(),
      isFalse,
      reason: 'full image should be deleted',
    );
  });

  test('keeps full image when saveFullImages is enabled', () async {
    final tmpDir = Directory.systemTemp.createTempSync('vegolo_test_');
    final full = File('${tmpDir.path}/full.jpg');
    await full.writeAsBytes(List.filled(10, 7));

    final repo = ScanHistoryRepositoryImpl(
      _FakeThumbnailGenerator(),
      _InMemoryHistoryDataSource(),
      _FakeSettingsRepository(true),
    );

    final entry = ScanHistoryEntry(
      id: '2',
      scannedAt: DateTime.now(),
      analysis: const VeganAnalysis(isVegan: true, confidence: 0.5),
      fullImagePath: full.path,
      hasFullImage: true,
    );

    await repo.saveEntry(entry);

    expect(await full.exists(), isTrue, reason: 'full image should remain');
  });
}
