import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/ai/generation_options.dart';
import 'package:vegolo/features/history/data/models/scan_history_entry_model.dart';
import 'package:vegolo/features/history/data/repositories/scan_history_repository_impl.dart';
import 'package:vegolo/features/history/data/thumbnail_generator.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/core/database/scan_history_local_data_source.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

class _FakeThumbnailGenerator extends ThumbnailGenerator {}

class _LocalDs implements ScanHistoryLocalDataSource {
  final Map<String, ScanHistoryEntryModel> _map = {};

  @override
  Future<void> clear() async => _map.clear();

  @override
  Future<void> deleteById(String id) async => _map.remove(id);

  @override
  Future<List<ScanHistoryEntryModel>> getAllEntries() async =>
      _map.values.toList();

  @override
  Future<ScanHistoryEntryModel?> getById(String id) async => _map[id];

  @override
  Future<void> insertEntry(ScanHistoryEntryModel entry) async =>
      _map[entry.id] = entry;

  @override
  Stream<List<ScanHistoryEntryModel>> watchEntries() async* {
    yield _map.values.toList();
  }
}

class _Settings implements SettingsRepository {
  GemmaGenerationOptions _options = GemmaGenerationOptions.defaults;
  @override
  Future<bool> getSaveFullImages() async => false;

  @override
  Future<void> setSaveFullImages(bool value) async {}

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
  test('deleteEntry removes files and db row', () async {
    final tmpDir = await Directory.systemTemp.createTemp('vegolo_hist_');
    final thumb = File('${tmpDir.path}/thumb.jpg');
    final full = File('${tmpDir.path}/full.jpg');
    await thumb.writeAsBytes([1, 2, 3]);
    await full.writeAsBytes([4, 5, 6]);

    final ds = _LocalDs();
    final repo = ScanHistoryRepositoryImpl(
      _FakeThumbnailGenerator(),
      ds,
      _Settings(),
    );

    final entry = ScanHistoryEntry(
      id: 'id1',
      scannedAt: DateTime.now(),
      analysis: const VeganAnalysis(isVegan: true, confidence: 0.5),
      thumbnailPath: thumb.path,
      fullImagePath: full.path,
    );
    await ds.insertEntry(ScanHistoryEntryModel.fromDomain(entry));

    await repo.deleteEntry('id1');

    expect(await thumb.exists(), isFalse);
    expect(await full.exists(), isFalse);
    expect(await ds.getById('id1'), isNull);
  });
}
