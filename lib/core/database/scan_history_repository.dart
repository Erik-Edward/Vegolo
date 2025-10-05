import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';

abstract class ScanHistoryLocalDataSource {
  Future<void> save(ScanHistoryEntry entry);
  Stream<List<ScanHistoryEntry>> watchAll();
  Future<void> deleteAll();
}
