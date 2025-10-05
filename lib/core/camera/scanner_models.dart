import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

/// Configuration options for the camera stream.
class ScannerConfig extends Equatable {
  const ScannerConfig({
    this.lensDirection = CameraLensDirection.back,
    this.resolutionPreset = ResolutionPreset.high,
    this.targetFps = 30,
    this.processEveryNthFrame = 3,
    this.enableAutoExposure = true,
    this.enableAutoFocus = true,
  }) : assert(processEveryNthFrame > 0, 'processEveryNthFrame must be > 0');

  final CameraLensDirection lensDirection;
  final ResolutionPreset resolutionPreset;
  final int targetFps;
  final int processEveryNthFrame;
  final bool enableAutoExposure;
  final bool enableAutoFocus;

  ScannerConfig copyWith({
    CameraLensDirection? lensDirection,
    ResolutionPreset? resolutionPreset,
    int? targetFps,
    int? processEveryNthFrame,
    bool? enableAutoExposure,
    bool? enableAutoFocus,
  }) {
    return ScannerConfig(
      lensDirection: lensDirection ?? this.lensDirection,
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      targetFps: targetFps ?? this.targetFps,
      processEveryNthFrame: processEveryNthFrame ?? this.processEveryNthFrame,
      enableAutoExposure: enableAutoExposure ?? this.enableAutoExposure,
      enableAutoFocus: enableAutoFocus ?? this.enableAutoFocus,
    );
  }

  @override
  List<Object?> get props => [
    lensDirection,
    resolutionPreset,
    targetFps,
    processEveryNthFrame,
    enableAutoExposure,
    enableAutoFocus,
  ];
}

/// A camera frame emitted by [ScannerService].
class ScannerFrame extends Equatable {
  const ScannerFrame({
    required this.bytes,
    required this.timestamp,
    this.width,
    this.height,
    this.rotation,
    this.isFlashOn,
    this.bytesPerRow,
  });

  final Uint8List bytes;
  final DateTime timestamp;
  final int? width;
  final int? height;
  final int? rotation;
  final bool? isFlashOn;
  final int? bytesPerRow;

  @override
  List<Object?> get props => [
    bytes,
    timestamp,
    width,
    height,
    rotation,
    isFlashOn,
    bytesPerRow,
  ];
}

enum CameraAuthorizationStatus { granted, denied, permanentlyDenied }
