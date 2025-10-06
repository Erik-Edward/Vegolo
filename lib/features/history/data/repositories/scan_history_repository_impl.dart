import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:vegolo/core/database/scan_history_local_data_source.dart';
import 'package:vegolo/features/history/data/models/scan_history_entry_model.dart';
import 'package:vegolo/features/history/data/thumbnail_generator.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/history/domain/repositories/scan_history_repository.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton(as: ScanHistoryRepository)
class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  const ScanHistoryRepositoryImpl(
    this._thumbnailGenerator,
    this._localDataSource,
    this._settingsRepository,
  );

  final ThumbnailGenerator _thumbnailGenerator;
  final ScanHistoryLocalDataSource _localDataSource;
  final SettingsRepository _settingsRepository;

  @override
  Future<void> clearHistory() async {
    final entries = await _localDataSource.getAllEntries();
    for (final entry in entries) {
      await _deleteImageFiles(entry.thumbnailPath, entry.fullImagePath);
    }

    await _localDataSource.clear();
  }

  @override
  Future<void> saveEntry(ScanHistoryEntry entry) async {
    final preparedEntry = await _ensureThumbnail(entry);

    // Enforce thumbnails-by-default unless user opts in.
    final saveFull = await _settingsRepository.getSaveFullImages();
    ScanHistoryEntry adjusted = preparedEntry;
    if (!saveFull && preparedEntry.fullImagePath != null) {
      try {
        final file = File(preparedEntry.fullImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore deletion failures in MVP.
      }
      adjusted = ScanHistoryEntry(
        id: preparedEntry.id,
        scannedAt: preparedEntry.scannedAt,
        analysis: preparedEntry.analysis,
        productName: preparedEntry.productName,
        barcode: preparedEntry.barcode,
        thumbnailPath: preparedEntry.thumbnailPath,
        fullImagePath: null,
        hasFullImage: false,
        detectedIngredients: preparedEntry.detectedIngredients,
      );
    }

    await _localDataSource.insertEntry(
      ScanHistoryEntryModel.fromDomain(adjusted),
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    final existing = await _localDataSource.getById(id);
    if (existing != null) {
      await _deleteImageFiles(existing.thumbnailPath, existing.fullImagePath);
    }
    await _localDataSource.deleteById(id);
  }

  @override
  Future<void> deleteEntryImageData(String id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) return;

    // Remove files
    await _deleteImageFiles(existing.thumbnailPath, existing.fullImagePath);

    // Keep metadata, null out image fields
    final updated = ScanHistoryEntryModel(
      id: existing.id,
      scannedAt: existing.scannedAt,
      analysis: existing.analysis,
      productName: existing.productName,
      barcode: existing.barcode,
      thumbnailPath: null,
      fullImagePath: null,
      hasFullImage: false,
      detectedIngredients: existing.detectedIngredients,
    );
    await _localDataSource.insertEntry(updated);
  }

  Future<void> _deleteImageFiles(String? thumbPath, String? fullPath) async {
    Future<void> tryDelete(String? path) async {
      if (path == null) return;
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    await tryDelete(thumbPath);
    await tryDelete(fullPath);
  }

  @override
  Stream<List<ScanHistoryEntry>> watchHistory() {
    return _localDataSource.watchEntries().map(
      (models) => models.map((m) => m.toDomain()).toList(growable: false),
    );
  }

  Future<ScanHistoryEntry> _ensureThumbnail(ScanHistoryEntry entry) async {
    if (entry.thumbnailPath != null) {
      return entry;
    }

    final bytes = await _loadSourceImage(entry);
    if (bytes == null) {
      return entry;
    }

    final thumbnailBytes = await _thumbnailGenerator.createThumbnail(bytes);
    final thumbnailPath = await _thumbnailGenerator.persistThumbnail(
      thumbnailBytes,
    );

    return ScanHistoryEntry(
      id: entry.id,
      scannedAt: entry.scannedAt,
      analysis: entry.analysis,
      productName: entry.productName,
      barcode: entry.barcode,
      thumbnailPath: thumbnailPath,
      fullImagePath: entry.fullImagePath,
      hasFullImage: entry.hasFullImage,
      detectedIngredients: entry.detectedIngredients,
    );
  }

  Future<Uint8List?> _loadSourceImage(ScanHistoryEntry entry) async {
    if (entry.fullImagePath == null) {
      return null;
    }

    final file = File(entry.fullImagePath!);
    if (!await file.exists()) {
      return null;
    }

    return file.readAsBytes();
  }
}
