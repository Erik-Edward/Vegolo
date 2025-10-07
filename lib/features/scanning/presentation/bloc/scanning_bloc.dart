import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:vegolo/core/camera/ocr_models.dart';
import 'package:vegolo/core/camera/ocr_processor.dart';
import 'package:vegolo/core/camera/scanner_models.dart';
import 'package:vegolo/core/camera/scanner_service.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';
import 'package:vegolo/core/di/injection.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/history/domain/repositories/scan_history_repository.dart';
import 'package:vegolo/features/history/data/thumbnail_generator.dart';
import 'package:vegolo/features/scanning/domain/usecases/perform_scan_analysis.dart';
import 'package:vegolo/features/scanning/domain/repositories/barcode_repository.dart';
import 'package:vegolo/shared/utils/text_normalizer.dart';

part 'scanning_event.dart';
part 'scanning_state.dart';

@injectable
class ScanningBloc extends Bloc<ScanningEvent, ScanningState> {
  ScanningBloc({
    required ScannerService scannerService,
    required OcrProcessor ocrProcessor,
    required PerformScanAnalysis performScanAnalysis,
  }) : _scannerService = scannerService,
       _ocrProcessor = ocrProcessor,
       _performScanAnalysis = performScanAnalysis,
       _config = const ScannerConfig(),
       super(const ScanningState.initial()) {
    on<ScanningStarted>(_onScanningStarted);
    on<ScanningPaused>(_onScanningPaused);
    on<ScanningResumed>(_onScanningResumed);
    on<ScanningStopped>(_onScanningStopped);
    on<_ScannerFrameReceived>(_onFrameReceived);
    on<_ScanningFailed>(_onFailed);
    on<ScanningPermissionRequested>(_onPermissionRequested);
    on<ScanningPermissionDenied>(_onPermissionDenied);
    on<ScanningAppPaused>(_onAppPaused);
    on<ScanningAppResumed>(_onAppResumed);
    on<ScanningOpenSettingsRequested>(_onOpenSettingsRequested);
    on<ScanningBarcodeProductReceived>(_onBarcodeProductReceived);
    on<ScanningClearBarcodeInfo>(_onClearBarcodeInfo);
    on<ScanningOcrSuspended>(_onOcrSuspended);
    on<ScanningOcrResumed>(_onOcrResumed);
  }

  final ScannerService _scannerService;
  final ScannerConfig _config;
  final OcrProcessor _ocrProcessor;
  final PerformScanAnalysis _performScanAnalysis;
  bool _isProcessingFrame = false;
  StreamSubscription<ScannerFrame>? _frameSubscription;

  Future<void> _onScanningStarted(
    ScanningStarted event,
    Emitter<ScanningState> emit,
  ) async {
    if (state.status == ScanningStatus.initializing ||
        state.status == ScanningStatus.scanning) {
      return;
    }

    emit(state.copyWith(
      status: ScanningStatus.initializing,
      clearError: true,
      clearProduct: true,
      clearBarcode: true,
      clearOffImageUrl: true,
      clearOffLastUpdated: true,
      clearOffIngredients: true,
      clearOffIngredientsText: true,
    ));

    add(const ScanningPermissionRequested());
  }

  Future<void> _onPermissionRequested(
    ScanningPermissionRequested event,
    Emitter<ScanningState> emit,
  ) async {
    try {
      final permissionStatus = await _scannerService.ensurePermissions();
      if (permissionStatus == CameraAuthorizationStatus.granted) {
        await _scannerService.initialize(_config);
        await _listenToFrames();
        emit(
          state.copyWith(
            status: ScanningStatus.scanning,
            permissionDenied: false,
            permanentlyDenied: false,
          ),
        );
        return;
      }
      add(
        ScanningPermissionDenied(
          permanentlyDenied:
              permissionStatus == CameraAuthorizationStatus.permanentlyDenied,
        ),
      );
    } catch (error) {
      add(_ScanningFailed(error.toString()));
    }
  }

  Future<void> _onPermissionDenied(
    ScanningPermissionDenied event,
    Emitter<ScanningState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanningStatus.failure,
        errorMessage: event.permanentlyDenied
            ? 'Camera access permanently denied. Update settings to proceed.'
            : 'Camera permission denied. Please allow access to continue.',
        permissionDenied: true,
        permanentlyDenied: event.permanentlyDenied,
        clearFrame: true,
        clearOcr: true,
        clearAnalysis: true,
      ),
    );
  }

  Future<void> _onAppPaused(
    ScanningAppPaused event,
    Emitter<ScanningState> emit,
  ) async {
    await _scannerService.pause();
    emit(state.copyWith(status: ScanningStatus.paused));
  }

  Future<void> _onAppResumed(
    ScanningAppResumed event,
    Emitter<ScanningState> emit,
  ) async {
    if (state.permanentlyDenied == true) {
      return;
    }
    add(const ScanningStarted());
  }

  Future<void> _onOpenSettingsRequested(
    ScanningOpenSettingsRequested event,
    Emitter<ScanningState> emit,
  ) async {
    await _scannerService.openAppSettings();
  }

  Future<void> _onScanningPaused(
    ScanningPaused event,
    Emitter<ScanningState> emit,
  ) async {
    try {
      await _scannerService.pause();
      emit(state.copyWith(status: ScanningStatus.paused));
    } catch (error) {
      add(_ScanningFailed(error.toString()));
    }
  }

  Future<void> _onScanningResumed(
    ScanningResumed event,
    Emitter<ScanningState> emit,
  ) async {
    try {
      await _scannerService.resume();
      await _listenToFrames();
      emit(state.copyWith(status: ScanningStatus.scanning));
    } catch (error) {
      add(_ScanningFailed(error.toString()));
    }
  }

  Future<void> _onScanningStopped(
    ScanningStopped event,
    Emitter<ScanningState> emit,
  ) async {
    await _frameSubscription?.cancel();
    _frameSubscription = null;

    // Capture a still before pausing preview to avoid platform-specific
    // takePicture limitations when preview is paused.
    String? fullPath;
    try {
      fullPath = await _scannerService.captureStill();
    } catch (_) {
      fullPath = null;
    }

    // Pause camera to stop preview safely (keep controller alive for UI).
    try {
      await _scannerService.pause();
    } catch (_) {}

    // Best-effort save to history (fallback to 'uncertain' analysis when absent).
    try {
      if (getIt.isRegistered<ScanHistoryRepository>()) {
        final repo = getIt<ScanHistoryRepository>();
        final analysis = state.analysis ?? const VeganAnalysis(
          isVegan: false,
          confidence: 0.0,
          flaggedIngredients: ['uncertain'],
        );
        String? thumbnailPath;
        // Prefer OFF product image for thumbnail if available.
        final offUrl = state.offImageUrl;
        if (offUrl != null && offUrl.isNotEmpty) {
          try {
            final barcodeRepo = getIt<BarcodeRepository>();
            final bytes = await barcodeRepo.fetchImageBytes(offUrl);
            if (bytes != null) {
              final thumbGen = getIt<ThumbnailGenerator>();
              final thumbBytes = await thumbGen.createThumbnail(bytes);
              thumbnailPath = await thumbGen.persistThumbnail(thumbBytes);
            }
          } catch (_) {}
        }

        final detected = state.offIngredients ??
            _buildDetectedIngredients(state.ocrResult);
        final entry = ScanHistoryEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          scannedAt: DateTime.now(),
          analysis: analysis,
          productName: state.productName,
          barcode: state.barcode,
          thumbnailPath: thumbnailPath,
          fullImagePath: fullPath,
          hasFullImage: fullPath != null,
          detectedIngredients: detected,
        );
        await repo.saveEntry(entry);
      }
    } catch (_) {
      // Ignore save failures in MVP.
    }

    emit(
      state.copyWith(
        status: ScanningStatus.idle,
        clearFrame: true,
        clearError: true,
        clearOcr: true,
        clearAnalysis: true,
      ),
    );
  }

  Future<void> _onBarcodeProductReceived(
    ScanningBarcodeProductReceived event,
    Emitter<ScanningState> emit,
  ) async {
    emit(state.copyWith(
      productName: event.productName,
      barcode: event.barcode,
      offImageUrl: event.imageUrl,
      offLastUpdated: event.lastUpdated,
      offIngredients: event.ingredients,
      offIngredientsText: event.ingredientsText,
    ));

    // Analyze OFF ingredients without invoking OCR.
    final ingredientsText = event.ingredientsText ??
        (event.ingredients?.join(', ') ?? '');
    if (ingredientsText.trim().isNotEmpty) {
      try {
        final dummyFrame = ScannerFrame(
          bytes: Uint8List(0),
          timestamp: DateTime.now(),
        );
        final offOcr = OcrResult(
          fullText: ingredientsText,
          blocks: const [],
          frame: dummyFrame,
        );
        final analysis = await _performScanAnalysis(offOcr);
        emit(state.copyWith(analysis: analysis));
      } catch (_) {}
    }
  }

  Future<void> _onClearBarcodeInfo(
    ScanningClearBarcodeInfo event,
    Emitter<ScanningState> emit,
  ) async {
    emit(state.copyWith(
      clearProduct: true,
      clearBarcode: true,
      clearOffImageUrl: true,
      clearOffLastUpdated: true,
      clearOffIngredients: true,
      clearOffIngredientsText: true,
    ));
  }

  Future<void> _onOcrSuspended(
    ScanningOcrSuspended event,
    Emitter<ScanningState> emit,
  ) async {
    emit(state.copyWith(suspendOcr: true));
  }

  Future<void> _onOcrResumed(
    ScanningOcrResumed event,
    Emitter<ScanningState> emit,
  ) async {
    // Only resume OCR if there is no active barcode product.
    if (state.barcode == null) {
      emit(state.copyWith(suspendOcr: false));
    }
  }

  Future<void> _onFrameReceived(
    _ScannerFrameReceived event,
    Emitter<ScanningState> emit,
  ) async {
    // Do not process OCR when suspended or when a barcode/ OFF product is active.
    if (state.suspendOcr || state.barcode != null) {
      return;
    }
    if (_isProcessingFrame) {
      return;
    }

    _isProcessingFrame = true;
    emit(
      state.copyWith(
        status: ScanningStatus.scanning,
        latestFrame: event.frame,
        clearError: true,
      ),
    );

    try {
      final ocrResult = await _ocrProcessor.processFrame(event.frame);
      // Debug summary: length + first 80 chars (strip newlines)
      final brief = ocrResult.fullText.replaceAll('\n', ' ');
      // ignore: avoid_print
      print('[OCR] len=${brief.length} head="${brief.length > 80 ? brief.substring(0, 80) : brief}"');
      final analysis = await _performScanAnalysis(ocrResult);
      emit(
        state.copyWith(
          status: ScanningStatus.success,
          ocrResult: ocrResult,
          analysis: analysis,
          latestFrame: event.frame,
          clearError: true,
        ),
      );
    } catch (error) {
      // Softly handle OCR/analysis errors: keep scanning active and surface
      // uncertainty instead of failing the whole pipeline.
      emit(
        state.copyWith(
          status: ScanningStatus.scanning,
          errorMessage: 'Uncertain — OCR could not read this frame',
          clearAnalysis: true,
        ),
      );
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _onFailed(
    _ScanningFailed event,
    Emitter<ScanningState> emit,
  ) async {
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    emit(
      state.copyWith(
        status: ScanningStatus.failure,
        errorMessage: event.message,
        clearOcr: true,
        clearAnalysis: true,
      ),
    );
  }

  Future<void> _listenToFrames() async {
    await _frameSubscription?.cancel();
    try {
      _frameSubscription = _scannerService.frames().listen(
        (frame) => add(_ScannerFrameReceived(frame)),
        onError: (Object error, StackTrace stackTrace) {
          add(_ScanningFailed(error.toString()));
        },
      );
    } catch (error) {
      add(_ScanningFailed(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    await _scannerService.dispose();
    await _ocrProcessor.dispose();
    return super.close();
  }

  List<String> _buildDetectedIngredients(OcrResult? result) {
    if (result == null) return const [];
    final lines = result.fullText.split('\n');
    final cleaned = <String>{};
    for (final line in lines) {
      final norm = TextNormalizer.normalizeLineForIngredients(line);
      if (norm.isEmpty) continue;
      // Skip tiny non-informative lines
      if (norm.length < 3) continue;
      cleaned.add(norm);
    }
    // Return full set (deduplicated); UI can handle long lists with scrolling.
    return cleaned.toList(growable: false);
  }
}
