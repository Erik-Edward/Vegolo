import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:vegolo/core/database/scan_history_local_data_source.dart';
import 'package:vegolo/features/history/data/models/scan_history_entry_model.dart';
import 'package:vegolo/features/history/data/thumbnail_generator.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/history/domain/repositories/scan_history_repository.dart';

@LazySingleton(as: ScanHistoryRepository)
class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  const ScanHistoryRepositoryImpl(
    this._thumbnailGenerator,
    this._localDataSource,
  );

  final ThumbnailGenerator _thumbnailGenerator;
  final ScanHistoryLocalDataSource _localDataSource;

  @override
  Future<void> clearHistory() async {
    final entries = await _localDataSource.getAllEntries();
    for (final entry in entries) {
      if (entry.thumbnailPath != null) {
        final file = File(entry.thumbnailPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    await _localDataSource.clear();
  }

  @override
  Future<void> saveEntry(ScanHistoryEntry entry) async {
    final preparedEntry = await _ensureThumbnail(entry);
    // TODO(eriklinux): Persist preparedEntry to local database/storage and
    // schedule thumbnail cleanup when entries are deleted.
    await _localDataSource.insertEntry(
      ScanHistoryEntryModel.fromDomain(preparedEntry),
    );
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
