import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';

abstract class ScanHistoryRepository {
  Future<void> saveEntry(ScanHistoryEntry entry);
  Stream<List<ScanHistoryEntry>> watchHistory();
  Future<void> clearHistory();
  Future<void> deleteEntry(String id);
  Future<void> deleteEntryImageData(String id);
}
