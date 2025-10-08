part of 'scanning_bloc.dart';

abstract class ScanningEvent extends Equatable {
  const ScanningEvent();

  @override
  List<Object?> get props => const [];
}

class ScanningStarted extends ScanningEvent {
  const ScanningStarted();
}

class ScanningPaused extends ScanningEvent {
  const ScanningPaused();
}

class ScanningResumed extends ScanningEvent {
  const ScanningResumed();
}

class ScanningStopped extends ScanningEvent {
  const ScanningStopped();
}

class ScanningPermissionRequested extends ScanningEvent {
  const ScanningPermissionRequested();
}

class ScanningPermissionDenied extends ScanningEvent {
  const ScanningPermissionDenied({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  List<Object?> get props => [permanentlyDenied];
}

class ScanningAppResumed extends ScanningEvent {
  const ScanningAppResumed();
}

class ScanningOpenSettingsRequested extends ScanningEvent {
  const ScanningOpenSettingsRequested();
}

class ScanningAppPaused extends ScanningEvent {
  const ScanningAppPaused();
}

class _ScannerFrameReceived extends ScanningEvent {
  const _ScannerFrameReceived(this.frame);

  final ScannerFrame frame;

  @override
  List<Object?> get props => [frame];
}

class _ScanningFailed extends ScanningEvent {
  const _ScanningFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ScanningOcrSuspended extends ScanningEvent {
  const ScanningOcrSuspended();
}

class ScanningOcrResumed extends ScanningEvent {
  const ScanningOcrResumed();
}

class ScanningModeChanged extends ScanningEvent {
  const ScanningModeChanged(this.mode);
  final ScanMode mode;

  @override
  List<Object?> get props => [mode];
}

class ScanningDetailShown extends ScanningEvent {
  const ScanningDetailShown();
}

class ScanningBarcodeProductReceived extends ScanningEvent {
  const ScanningBarcodeProductReceived({
    required this.barcode,
    this.productName,
    this.imageUrl,
    this.lastUpdated,
    this.ingredients,
    this.ingredientsText,
  });

  final String barcode;
  final String? productName;
  final String? imageUrl;
  final DateTime? lastUpdated;
  final List<String>? ingredients;
  final String? ingredientsText;

  @override
  List<Object?> get props => [
        barcode,
        productName,
        imageUrl,
        lastUpdated,
        ingredients,
        ingredientsText,
      ];
}

class ScanningClearBarcodeInfo extends ScanningEvent {
  const ScanningClearBarcodeInfo();
}
