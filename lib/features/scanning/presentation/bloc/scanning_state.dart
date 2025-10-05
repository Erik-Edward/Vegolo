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
  });

  const ScanningState.initial() : this(status: ScanningStatus.idle);

  final ScanningStatus status;
  final ScannerFrame? latestFrame;
  final String? errorMessage;
  final OcrResult? ocrResult;
  final VeganAnalysis? analysis;
  final bool? permissionDenied;
  final bool? permanentlyDenied;

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
  }) {
    return ScanningState(
      status: status ?? this.status,
      latestFrame: clearFrame ? null : (latestFrame ?? this.latestFrame),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      ocrResult: clearOcr ? null : (ocrResult ?? this.ocrResult),
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      permissionDenied: permissionDenied ?? this.permissionDenied,
      permanentlyDenied: permanentlyDenied ?? this.permanentlyDenied,
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
  ];
}
