import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/ai/generation_options.dart';
import 'package:vegolo/core/database/scan_history_local_data_source.dart';
import 'package:vegolo/features/history/data/models/scan_history_entry_model.dart';
import 'package:vegolo/features/history/data/repositories/scan_history_repository_impl.dart';
import 'package:vegolo/features/history/data/thumbnail_generator.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

class _DS implements ScanHistoryLocalDataSource {
  final Map<String, ScanHistoryEntryModel> _m = {};
  @override
  Future<void> clear() async => _m.clear();
  @override
  Future<void> deleteById(String id) async => _m.remove(id);
  @override
  Future<List<ScanHistoryEntryModel>> getAllEntries() async =>
      _m.values.toList();
  @override
  Future<ScanHistoryEntryModel?> getById(String id) async => _m[id];
  @override
  Future<void> insertEntry(ScanHistoryEntryModel entry) async =>
      _m[entry.id] = entry;
  @override
  Stream<List<ScanHistoryEntryModel>> watchEntries() async* {
    yield _m.values.toList();
  }
}

class _TG extends ThumbnailGenerator {}

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
  test('deleteEntryImageData removes files but keeps row', () async {
    final ds = _DS();
    final repo = ScanHistoryRepositoryImpl(_TG(), ds, _Settings());

    final tmp = await Directory.systemTemp.createTemp('vegolo_');
    final thumb = File('${tmp.path}/t.jpg');
    final full = File('${tmp.path}/f.jpg');
    await thumb.writeAsBytes([1]);
    await full.writeAsBytes([2]);

    final entry = ScanHistoryEntry(
      id: 'x',
      scannedAt: DateTime.now(),
      analysis: const VeganAnalysis(isVegan: true, confidence: 0.5),
      thumbnailPath: thumb.path,
      fullImagePath: full.path,
      hasFullImage: true,
    );
    await ds.insertEntry(ScanHistoryEntryModel.fromDomain(entry));

    await repo.deleteEntryImageData('x');

    expect(await thumb.exists(), isFalse);
    expect(await full.exists(), isFalse);
    final updated = await ds.getById('x');
    expect(updated, isNotNull);
    expect(updated!.thumbnailPath, isNull);
    expect(updated.fullImagePath, isNull);
    expect(updated.hasFullImage, isFalse);
  });
}
