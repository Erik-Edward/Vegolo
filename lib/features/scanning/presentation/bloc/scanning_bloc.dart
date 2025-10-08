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
import 'package:vegolo/core/barcode/barcode_scanner.dart';
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
    on<ScanningModeChanged>(_onModeChanged);
    on<ScanningDetailShown>(_onDetailShown);
  }

  final ScannerService _scannerService;
  final ScannerConfig _config;
  final OcrProcessor _ocrProcessor;
  final PerformScanAnalysis _performScanAnalysis;
  bool _isProcessingFrame = false;
  StreamSubscription<ScannerFrame>? _frameSubscription;
  DateTime? _lastOcrAt;
  String? _lastNormalizedOcr;
  static const Duration _minOcrInterval = Duration(milliseconds: 300);
  DateTime? _lastBarcodeAt;
  static const Duration _minBarcodeInterval = Duration(milliseconds: 250);
  bool _autoStoppingBarcode = false;

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

  Future<void> _onModeChanged(
    ScanningModeChanged event,
    Emitter<ScanningState> emit,
  ) async {
    final newMode = event.mode;
    if (newMode == state.mode) return;
    try {
      if (newMode == ScanMode.barcode) {
        await _scannerService.setProcessEveryNthFrame(6);
        emit(state.copyWith(mode: newMode, suspendOcr: true));
      } else {
        await _scannerService.setProcessEveryNthFrame(3);
        emit(state.copyWith(
          mode: newMode,
          suspendOcr: false,
          clearBarcode: true,
          clearOffImageUrl: true,
          clearOffLastUpdated: true,
          clearOffIngredients: true,
          clearOffIngredientsText: true,
        ));
      }
    } catch (_) {
      emit(state.copyWith(mode: newMode));
    }
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
    ScanHistoryEntry? pendingEntry;
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
        pendingEntry = entry;
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
        pendingDetailEntry: pendingEntry,
      ),
    );
    _autoStoppingBarcode = false;
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

    // In barcode mode, auto-stop once when a product has been received.
    if (state.mode == ScanMode.barcode && !_autoStoppingBarcode) {
      _autoStoppingBarcode = true;
      add(const ScanningStopped());
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

  Future<void> _onDetailShown(
    ScanningDetailShown event,
    Emitter<ScanningState> emit,
  ) async {
    emit(state.copyWith(clearPendingDetail: true));
  }

  Future<void> _onFrameReceived(
    _ScannerFrameReceived event,
    Emitter<ScanningState> emit,
  ) async {
    // Barcode mode: detect barcodes, no OCR.
    if (state.mode == ScanMode.barcode) {
      final now = DateTime.now();
      if (_lastBarcodeAt != null && now.difference(_lastBarcodeAt!) < _minBarcodeInterval) {
        return;
      }
      _lastBarcodeAt = now;
      try {
        final code = await getIt<BarcodeScannerService>().detectBarcode(event.frame);
        if (code != null) {
          final product = await getIt<BarcodeRepository>().fetchOffProduct(code);
          add(ScanningBarcodeProductReceived(
            barcode: code,
            productName: product?.productName,
            imageUrl: product?.imageUrl,
            lastUpdated: product?.lastUpdated,
            ingredients: product?.ingredients,
            ingredientsText: product?.ingredientsText,
          ));
        }
      } catch (_) {}
      return;
    }
    // Do not process OCR when suspended or when a barcode/ OFF product is active.
    if (state.suspendOcr || state.barcode != null) {
      return;
    }
    // Time-based throttle to avoid excessive OCR calls.
    final now = DateTime.now();
    if (_lastOcrAt != null && now.difference(_lastOcrAt!) < _minOcrInterval) {
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
      _lastOcrAt = now;
      // Debug summary: length + first 80 chars (strip newlines)
      final brief = ocrResult.fullText.replaceAll('\n', ' ');
      // ignore: avoid_print
      print('[OCR] len=${brief.length} head="${brief.length > 80 ? brief.substring(0, 80) : brief}"');
      // Debounce analysis if text hasn't materially changed.
      final normalized = TextNormalizer.normalizeForIngredients(ocrResult.fullText);
      if (_lastNormalizedOcr != null && _lastNormalizedOcr == normalized) {
        emit(
          state.copyWith(
            status: ScanningStatus.scanning,
            ocrResult: ocrResult,
            latestFrame: event.frame,
            clearError: true,
          ),
        );
        return;
      }
      _lastNormalizedOcr = normalized;

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

  @override
  void onEvent(ScanningEvent event) {
    super.onEvent(event);
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
    final lines = TextNormalizer.extractIngredientLines(result.fullText);
    return lines.toSet().toList(growable: false);
  }
}
