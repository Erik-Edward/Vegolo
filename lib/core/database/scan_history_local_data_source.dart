import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:injectable/injectable.dart';
import 'package:vegolo/core/database/app_database.dart';
import 'package:vegolo/features/history/data/models/scan_history_entry_model.dart';
import 'package:vegolo/features/scanning/data/models/vegan_analysis_model.dart';

abstract class ScanHistoryLocalDataSource {
  Future<void> insertEntry(ScanHistoryEntryModel entry);
  Stream<List<ScanHistoryEntryModel>> watchEntries();
  Future<List<ScanHistoryEntryModel>> getAllEntries();
  Future<void> clear();
}

@LazySingleton(as: ScanHistoryLocalDataSource)
class DriftScanHistoryLocalDataSource implements ScanHistoryLocalDataSource {
  DriftScanHistoryLocalDataSource(this._db);

  final AppDatabase _db;

  @override
  Future<void> insertEntry(ScanHistoryEntryModel entry) async {
    final companion = ScanHistoryEntriesCompanion(
      id: drift.Value(entry.id),
      scannedAt: drift.Value(entry.scannedAt),
      analysisJson: drift.Value(jsonEncode(entry.analysis.toJson())),
      productName: drift.Value(entry.productName),
      barcode: drift.Value(entry.barcode),
      thumbnailPath: drift.Value(entry.thumbnailPath),
      fullImagePath: drift.Value(entry.fullImagePath),
      hasFullImage: drift.Value(entry.hasFullImage),
      detectedIngredientsJson: drift.Value(
        jsonEncode(entry.detectedIngredients),
      ),
    );

    await _db.into(_db.scanHistoryEntries).insertOnConflictUpdate(companion);
  }

  @override
  Stream<List<ScanHistoryEntryModel>> watchEntries() {
    return _db.select(_db.scanHistoryEntries).watch().map(_mapRows);
  }

  @override
  Future<List<ScanHistoryEntryModel>> getAllEntries() async {
    final rows = await _db.select(_db.scanHistoryEntries).get();
    return _mapRows(rows);
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.scanHistoryEntries).go();
  }

  List<ScanHistoryEntryModel> _mapRows(List<ScanHistoryEntry> rows) {
    return rows
        .map(
          (row) => ScanHistoryEntryModel(
            id: row.id,
            scannedAt: row.scannedAt,
            analysis: VeganAnalysisModel.fromJson(
              jsonDecode(row.analysisJson) as Map<String, dynamic>,
            ),
            productName: row.productName,
            barcode: row.barcode,
            thumbnailPath: row.thumbnailPath,
            fullImagePath: row.fullImagePath,
            hasFullImage: row.hasFullImage,
            detectedIngredients: List<String>.from(
              (jsonDecode(row.detectedIngredientsJson) as List<dynamic>?) ??
                  const <dynamic>[],
            ),
          ),
        )
        .toList(growable: false);
  }
}
