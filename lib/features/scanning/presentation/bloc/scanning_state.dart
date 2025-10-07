part of 'scanning_bloc.dart';

enum ScanningStatus { idle, initializing, scanning, paused, success, failure }

class ScanningState extends Equatable {
  const ScanningState({
    required this.status,
    this.latestFrame,
    this.errorMessage,
    this.ocrResult,
    this.analysis,
    this.permissionDenied,
    this.permanentlyDenied,
    this.productName,
    this.barcode,
    this.offImageUrl,
    this.offLastUpdated,
    this.offIngredients,
    this.offIngredientsText,
    this.suspendOcr = false,
  });

  const ScanningState.initial() : this(status: ScanningStatus.idle);

  final ScanningStatus status;
  final ScannerFrame? latestFrame;
  final String? errorMessage;
  final OcrResult? ocrResult;
  final VeganAnalysis? analysis;
  final bool? permissionDenied;
  final bool? permanentlyDenied;
  final String? productName;
  final String? barcode;
  final String? offImageUrl;
  final DateTime? offLastUpdated;
  final List<String>? offIngredients;
  final String? offIngredientsText;
  final bool suspendOcr;

  ScanningState copyWith({
    ScanningStatus? status,
    ScannerFrame? latestFrame,
    bool clearFrame = false,
    String? errorMessage,
    bool clearError = false,
    OcrResult? ocrResult,
    bool clearOcr = false,
    VeganAnalysis? analysis,
    bool clearAnalysis = false,
    bool? permissionDenied,
    bool? permanentlyDenied,
    String? productName,
    bool clearProduct = false,
    String? barcode,
    bool clearBarcode = false,
    String? offImageUrl,
    bool clearOffImageUrl = false,
    DateTime? offLastUpdated,
    bool clearOffLastUpdated = false,
    List<String>? offIngredients,
    bool clearOffIngredients = false,
    String? offIngredientsText,
    bool clearOffIngredientsText = false,
    bool? suspendOcr,
  }) {
    return ScanningState(
      status: status ?? this.status,
      latestFrame: clearFrame ? null : (latestFrame ?? this.latestFrame),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      ocrResult: clearOcr ? null : (ocrResult ?? this.ocrResult),
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      permissionDenied: permissionDenied ?? this.permissionDenied,
      permanentlyDenied: permanentlyDenied ?? this.permanentlyDenied,
      productName: clearProduct ? null : (productName ?? this.productName),
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      offImageUrl:
          clearOffImageUrl ? null : (offImageUrl ?? this.offImageUrl),
      offLastUpdated: clearOffLastUpdated
          ? null
          : (offLastUpdated ?? this.offLastUpdated),
      offIngredients: clearOffIngredients
          ? null
          : (offIngredients ?? this.offIngredients),
      offIngredientsText: clearOffIngredientsText
          ? null
          : (offIngredientsText ?? this.offIngredientsText),
      suspendOcr: suspendOcr ?? this.suspendOcr,
    );
  }

  @override
  List<Object?> get props => [
    status,
    latestFrame,
    errorMessage,
    ocrResult,
    analysis,
    permissionDenied,
    permanentlyDenied,
    productName,
    barcode,
    offImageUrl,
    offLastUpdated,
    offIngredients,
    offIngredientsText,
    suspendOcr,
  ];
}
