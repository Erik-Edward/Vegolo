import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'scanner_models.dart';

abstract class ScannerService {
  Stream<ScannerFrame> frames();
  Future<CameraAuthorizationStatus> ensurePermissions();
  Future<void> initialize(ScannerConfig config);
  Future<void> pause();
  Future<void> resume();
  Future<void> updateFlashMode(FlashMode mode);
  Future<void> dispose();
  Future<void> openAppSettings();
  // Expose controller for UI preview (read-only; may be null before init).
  CameraController? get previewController;
  // Set focus/exposure point in normalized [0..1] coordinates.
  Future<void> setFocusAndExposurePoint(Offset point);
  // Capture a still image and return the file path if successful.
  Future<String?> captureStill();
}

@LazySingleton(as: ScannerService)
class CameraScannerService implements ScannerService {
  CameraScannerService();

  CameraController? _controller;
  StreamController<ScannerFrame>? _frameController;
  ScannerConfig _config = const ScannerConfig();
  int _frameCounter = 0;

  bool get _isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  @override
  CameraController? get previewController => _controller;

  @override
  Future<void> setFocusAndExposurePoint(Offset point) async {
    final controller = _controller;
    if (!_isInitialized || controller == null) return;
    try {
      // Ensure AF/AE are enabled, then set points.
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);
    } catch (_) {
      // Best-effort; ignore on unsupported platforms/modes.
    }
  }

  @override
  Future<String?> captureStill() async {
    final controller = _controller;
    if (!_isInitialized || controller == null) return null;
    try {
      await _stopStreaming();
      final file = await controller.takePicture();
      return file.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<ScannerFrame> frames() {
    final controller = _frameController;
    if (controller == null || controller.isClosed) {
      throw StateError('Scanner has not been initialized.');
    }
    return controller.stream;
  }

  @override
  Future<CameraAuthorizationStatus> ensurePermissions() async {
    final status = await ph.Permission.camera.status;
    if (status.isGranted) {
      return CameraAuthorizationStatus.granted;
    }

    final result = await ph.Permission.camera.request();
    if (result.isGranted) {
      return CameraAuthorizationStatus.granted;
    }
    if (result.isPermanentlyDenied) {
      return CameraAuthorizationStatus.permanentlyDenied;
    }
    return CameraAuthorizationStatus.denied;
  }

  @override
  Future<void> initialize(ScannerConfig config) async {
    WidgetsFlutterBinding.ensureInitialized();
    await dispose();

    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == config.lensDirection,
      orElse: () => cameras.isNotEmpty
          ? cameras.first
          : (throw StateError('No cameras available on device.')),
    );

    final controller = CameraController(
      camera,
      config.resolutionPreset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    // Try to enable AF/AE for better text sharpness.
    try {
      if (_config.enableAutoFocus) {
        await controller.setFocusMode(FocusMode.auto);
      }
      if (_config.enableAutoExposure) {
        await controller.setExposureMode(ExposureMode.auto);
      }
    } catch (_) {
      // Some platforms or modes may not support these; ignore.
    }

    _controller = controller;
    _config = config;
    _frameCounter = 0;
    _frameController = StreamController<ScannerFrame>.broadcast(
      onListen: () => unawaited(_startStreaming()),
      onCancel: () {
        if (!(_frameController?.hasListener ?? false)) {
          unawaited(_stopStreaming());
        }
      },
    );

    if (_frameController!.hasListener) {
      await _startStreaming();
    }
  }

  @override
  Future<void> pause() async {
    if (!_isInitialized) {
      return;
    }
    await _stopStreaming();
    await _controller!.pausePreview();
  }

  @override
  Future<void> resume() async {
    if (!_isInitialized) {
      return;
    }
    await _controller!.resumePreview();
    await _startStreaming();
  }

  @override
  Future<void> updateFlashMode(FlashMode mode) async {
    if (!_isInitialized) {
      return;
    }
    await _controller!.setFlashMode(mode);
  }

  @override
  Future<void> dispose() async {
    if (_controller != null) {
      await _stopStreaming();
      await _controller!.dispose();
      _controller = null;
    }

    await _frameController?.close();
    _frameController = null;
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  Future<void> _startStreaming() async {
    final controller = _controller;
    if (controller == null || controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream(_handleCameraImage);
  }

  Future<void> _stopStreaming() async {
    final controller = _controller;
    if (controller == null || !controller.value.isStreamingImages) {
      return;
    }
    await controller.stopImageStream();
  }

  void _handleCameraImage(CameraImage image) {
    final frameStream = _frameController;
    final controller = _controller;
    if (frameStream == null || frameStream.isClosed) {
      return;
    }

    if (!frameStream.hasListener) {
      return;
    }

    _frameCounter += 1;
    if (_frameCounter % _config.processEveryNthFrame != 0) {
      return;
    }

    final bytes = _nv21FromCameraImage(image);

    final frame = ScannerFrame(
      bytes: bytes,
      timestamp: DateTime.now(),
      width: image.width,
      height: image.height,
      rotation: controller?.description.sensorOrientation,
      isFlashOn: controller?.value.flashMode != FlashMode.off,
      bytesPerRow: image.planes.isNotEmpty
          ? image.planes.first.bytesPerRow
          : null,
    );

    frameStream.add(frame);
  }

  // Returns NV21 byte buffer from CameraImage (YUV420_888 on Android).
  // For ML Kit on Android, NV21 is the expected input.
  Uint8List _nv21FromCameraImage(CameraImage image) {
    // Most devices deliver planes as Y, U, V. NV21 expects Y + interleaved VU.
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;

    final Uint8List y = image.planes[0].bytes;
    final Uint8List u = image.planes.length > 1 ? image.planes[1].bytes : Uint8List(0);
    final Uint8List v = image.planes.length > 2 ? image.planes[2].bytes : Uint8List(0);

    // Fast path when strides align: many devices have contiguous Y and half-size UV planes.
    final nv21 = Uint8List(ySize + (ySize >> 1));
    nv21.setRange(0, y.length, y);

    // Interleave V and U for NV21. Fall back to naive interleave ignoring row/pixel strides.
    // This works on most devices delivering tightly packed chroma planes.
    int uvIndex = ySize;
    final int minLen = (u.length < v.length) ? u.length : v.length;
    for (int i = 0; i < minLen; i++) {
      final int vByte = v[i];
      final int uByte = u[i];
      if (uvIndex + 1 >= nv21.length) break;
      nv21[uvIndex++] = vByte;
      nv21[uvIndex++] = uByte;
    }
    return nv21;
  }
}
