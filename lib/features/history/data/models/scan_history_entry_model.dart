import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/scanning/data/models/vegan_analysis_model.dart';

class ScanHistoryEntryModel {
  const ScanHistoryEntryModel({
    required this.id,
    required this.scannedAt,
    required this.analysis,
    this.productName,
    this.barcode,
    this.thumbnailPath,
    this.fullImagePath,
    this.hasFullImage = false,
    this.detectedIngredients = const [],
  });

  final String id;
  final DateTime scannedAt;
  final VeganAnalysisModel analysis;
  final String? productName;
  final String? barcode;
  final String? thumbnailPath;
  final String? fullImagePath;
  final bool hasFullImage;
  final List<String> detectedIngredients;

  factory ScanHistoryEntryModel.fromDomain(ScanHistoryEntry entry) {
    return ScanHistoryEntryModel(
      id: entry.id,
      scannedAt: entry.scannedAt,
      analysis: VeganAnalysisModel.fromDomain(entry.analysis),
      productName: entry.productName,
      barcode: entry.barcode,
      thumbnailPath: entry.thumbnailPath,
      fullImagePath: entry.fullImagePath,
      hasFullImage: entry.hasFullImage,
      detectedIngredients: List.of(entry.detectedIngredients),
    );
  }

  ScanHistoryEntry toDomain() {
    return ScanHistoryEntry(
      id: id,
      scannedAt: scannedAt,
      analysis: analysis.toDomain(),
      productName: productName,
      barcode: barcode,
      thumbnailPath: thumbnailPath,
      fullImagePath: fullImagePath,
      hasFullImage: hasFullImage,
      detectedIngredients: List.unmodifiable(detectedIngredients),
    );
  }
}
