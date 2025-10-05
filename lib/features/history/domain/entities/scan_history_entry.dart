import 'package:equatable/equatable.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

class ScanHistoryEntry extends Equatable {
  const ScanHistoryEntry({
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
  final VeganAnalysis analysis;
  final String? productName;
  final String? barcode;
  final String? thumbnailPath;
  final String? fullImagePath;
  final bool hasFullImage;
  final List<String> detectedIngredients;

  @override
  List<Object?> get props => [
    id,
    scannedAt,
    analysis,
    productName,
    barcode,
    thumbnailPath,
    fullImagePath,
    hasFullImage,
    detectedIngredients,
  ];
}
