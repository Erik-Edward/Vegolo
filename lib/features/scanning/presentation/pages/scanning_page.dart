import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import '../bloc/scanning_bloc.dart';
import '../../../../shared/utils/constants.dart';
import '../../../../shared/widgets/chameleon_mascot.dart';
import '../../../../shared/widgets/scan_result_card.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/camera/scanner_service.dart';
import 'package:vegolo/features/history/presentation/pages/history_page.dart';
import 'package:vegolo/features/ingredients/data/seed/ingredient_seed_loader.dart';
import 'package:vegolo/features/scanning/presentation/pages/barcode_scan_page.dart';
import 'package:vegolo/features/scanning/domain/repositories/barcode_repository.dart';

class ScanningPage extends StatefulWidget {
  const ScanningPage({super.key});

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> with WidgetsBindingObserver {
  bool _showOcrOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<ScanningBloc>();
    switch (state) {
      case AppLifecycleState.resumed:
        bloc.add(const ScanningAppResumed());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        bloc.add(const ScanningAppPaused());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          _FlashToggleButton(),
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              // Suspend OCR while in barcode mode.
              context.read<ScanningBloc>().add(const ScanningOcrSuspended());
              final code = await Navigator.of(context)
                  .push<String>(
                MaterialPageRoute(builder: (_) => const BarcodeScanPage()),
              )
                  .whenComplete(() {
                // Resume OCR if no barcode result active.
                if (mounted) {
                  context.read<ScanningBloc>().add(const ScanningOcrResumed());
                }
              });
              if (!mounted || code == null) return;
              // Opt-in: only fetch OFF after explicit scan.
              final repo = getIt<BarcodeRepository>();
              final product = await repo.fetchOffProduct(code);
              if (!mounted) return;
              context.read<ScanningBloc>().add(
                    ScanningBarcodeProductReceived(
                      barcode: code,
                      productName: product?.productName,
                      imageUrl: product?.imageUrl,
                      lastUpdated: product?.lastUpdated,
                      ingredients: product?.ingredients,
                      ingredientsText: product?.ingredientsText,
                    ),
                  );
            },
          ),
          IconButton(
            tooltip: _showOcrOverlay ? 'Hide OCR' : 'Show OCR',
            icon: Icon(_showOcrOverlay ? Icons.bug_report : Icons.text_snippet),
            onPressed: () => setState(() => _showOcrOverlay = !_showOcrOverlay),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'history') {
                // Handled by FAB too; kept here for convenience.
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              } else if (value == 'seed') {
                // Best-effort refresh of ingredient seed
                try {
                  await getIt<IngredientSeedLoader>().refreshSeed();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingredient seed refreshed')),
                  );
                } catch (_) {}
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'seed', child: Text('Refresh ingredient seed')),
            ],
          ),
        ],
      ),
      // History is accessible via bottom navigation in AppShell.
      body: BlocBuilder<ScanningBloc, ScanningState>(
        builder: (context, state) {
          final bloc = context.read<ScanningBloc>();
          final (color, statusLabel) = _statusVisuals(state.status);
          final scannerService = getIt<ScannerService>();
          final detectedText = state.ocrResult?.fullText.trim();
          final analysis = state.analysis;
          final subtitle =
              state.errorMessage ??
              switch (true) {
                _ when state.permanentlyDenied == true =>
                  'Enable camera permissions in settings to resume scanning.',
                _ when state.permissionDenied == true =>
                  'Camera access is required for scanning.',
                _ when analysis != null =>
                  analysis.isVegan
                      ? 'Likely vegan (rule-based)'
                      : 'Potentially non-vegan',
                _ when detectedText != null && detectedText.isNotEmpty =>
                  'Detected text: $detectedText',
                _ => _statusSubtitle(state.status),
              };

          final (primaryLabel, primaryAction) = _primaryAction(
            state.status,
            bloc,
          );
          final bool showStopButton = switch (state.status) {
            ScanningStatus.idle || ScanningStatus.failure => false,
            ScanningStatus.initializing => false,
            _ => true,
          };
          final showSettingsButton = state.permanentlyDenied == true;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Camera preview area
                  _CameraPreviewArea(scannerService: scannerService, status: state.status),
                  const SizedBox(height: 16),
                  ChameleonMascot(statusColor: color),
                  const SizedBox(height: 16),
                  ScanResultCard(
                    title: statusLabel,
                    subtitle: subtitle,
                    trailing: Icon(_statusIcon(state.status), color: color),
                  ),
                  if (state.barcode != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            label: const Text('OFF'),
                            avatar: const Icon(Icons.inventory_2, size: 16),
                          ),
                          if (state.productName != null)
                            Text(
                              state.productName!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          if (state.offLastUpdated != null)
                            Text(
                              'Last updated: '
                              '${state.offLastUpdated!.toLocal().toIso8601String().split('T').first}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Unofficial info. Double-check label if unsure.',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.black54),
                      ),
                    ),
                  ],
                  if (_showOcrOverlay) ...[
                    const SizedBox(height: 8),
                    _OcrDebugPanel(text: detectedText ?? ''),
                  ],
                  if (analysis != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Confidence: ${(analysis.confidence * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (analysis.flaggedIngredients.isNotEmpty)
                      Text(
                        'Flagged: ${analysis.flaggedIngredients.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: primaryAction,
                    child: Text(primaryLabel),
                  ),
                  if (showStopButton) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => bloc.add(const ScanningStopped()),
                      child: const Text('Stop scanning'),
                    ),
                  ],
                  if (showSettingsButton) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          bloc.add(const ScanningOpenSettingsRequested()),
                      child: const Text('Open settings'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  (Color, String) _statusVisuals(ScanningStatus status) {
    return switch (status) {
      ScanningStatus.idle => (Colors.blueGrey, 'Ready to scan'),
      ScanningStatus.initializing => (Colors.lightBlue, 'Initializing camera'),
      ScanningStatus.scanning => (Colors.yellow, 'Scanning…'),
      ScanningStatus.paused => (Colors.orange, 'Scanner paused'),
      ScanningStatus.success => (Colors.green, 'Capturing frames'),
      ScanningStatus.failure => (Colors.red, 'Something went wrong'),
    };
  }

  String _statusSubtitle(ScanningStatus status) {
    return switch (status) {
      ScanningStatus.idle => 'Point the camera at an ingredient list to begin.',
      ScanningStatus.initializing => 'Preparing on-device OCR and camera.',
      ScanningStatus.scanning => 'Hold steady while Vegolo analyzes text.',
      ScanningStatus.paused => 'Resume scanning when you are ready.',
      ScanningStatus.success => 'Analyzing latest frame.',
      ScanningStatus.failure => 'Tap retry to reinitialize the scanner.',
    };
  }

  (String, VoidCallback?) _primaryAction(
    ScanningStatus status,
    ScanningBloc bloc,
  ) {
    return switch (status) {
      ScanningStatus.idle || ScanningStatus.failure => (
        'Begin scanning',
        () => bloc.add(const ScanningStarted()),
      ),
      ScanningStatus.initializing => ('Initializing…', null),
      ScanningStatus.scanning || ScanningStatus.success => (
        'Pause scanning',
        () => bloc.add(const ScanningPaused()),
      ),
      ScanningStatus.paused => (
        'Resume scanning',
        () => bloc.add(const ScanningResumed()),
      ),
    };
  }

  IconData _statusIcon(ScanningStatus status) {
    return switch (status) {
      ScanningStatus.idle => Icons.visibility,
      ScanningStatus.initializing => Icons.hourglass_top,
      ScanningStatus.scanning => Icons.autorenew,
      ScanningStatus.paused => Icons.pause_circle,
      ScanningStatus.success => Icons.check_circle,
      ScanningStatus.failure => Icons.error,
    };
  }
}

class _FlashToggleButton extends StatefulWidget {
  @override
  State<_FlashToggleButton> createState() => _FlashToggleButtonState();
}

class _FlashToggleButtonState extends State<_FlashToggleButton> {
  FlashMode _mode = FlashMode.off;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = getIt<ScannerService>().previewController;
      if (c != null) {
        setState(() => _mode = c.value.flashMode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = switch (_mode) {
      FlashMode.off => 'Flash: Off',
      FlashMode.auto => 'Flash: Auto',
      FlashMode.always => 'Flash: On',
      FlashMode.torch => 'Flash: Torch',
    };

    final icon = switch (_mode) {
      FlashMode.off => Icons.flash_off,
      FlashMode.auto => Icons.flash_auto,
      FlashMode.always => Icons.flash_on,
      FlashMode.torch => Icons.highlight,
    };

    return IconButton(
      tooltip: tooltip,
      icon: _busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      onPressed: _busy ? null : _toggle,
    );
  }

  Future<void> _toggle() async {
    final service = getIt<ScannerService>();
    final next = switch (_mode) {
      FlashMode.off => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
      FlashMode.auto => FlashMode.torch,
      FlashMode.always => FlashMode.off,
    };
    setState(() => _busy = true);
    try {
      await service.updateFlashMode(next);
      setState(() => _mode = next);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flash not supported: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _CameraPreviewArea extends StatefulWidget {
  const _CameraPreviewArea({
    required this.scannerService,
    required this.status,
  });

  final ScannerService scannerService;
  final ScanningStatus status;

  @override
  State<_CameraPreviewArea> createState() => _CameraPreviewAreaState();
}

class _CameraPreviewAreaState extends State<_CameraPreviewArea> {
  Offset? _lastTapPos;
  DateTime? _lastTapAt;

  @override
  Widget build(BuildContext context) {
    final CameraController? controller = widget.scannerService.previewController;
    final bool ready = controller != null && controller.value.isInitialized;

    Widget content;
    // If not actively scanning, show a placeholder to avoid building preview
    // on a disposed/paused controller.
    if (widget.status == ScanningStatus.idle ||
        widget.status == ScanningStatus.failure) {
      content = _placeholder();
    } else if (ready) {
      final media = MediaQuery.of(context).size;
      final isPortrait = media.height > media.width;
      final previewSize = controller.value.previewSize;
      double ratio;
      if (previewSize != null) {
        // previewSize is typically landscape; invert for portrait.
        ratio = isPortrait
            ? (previewSize.height / previewSize.width)
            : (previewSize.width / previewSize.height);
      } else {
        // Fallback to controller aspect ratio, inverted for portrait.
        final ar = controller.value.aspectRatio;
        ratio = isPortrait ? (1 / ar) : ar;
      }

      content = AspectRatio(
        aspectRatio: ratio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) async {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = details.localPosition;
                final size = box.size;
                final nx = (local.dx / size.width).clamp(0.0, 1.0);
                final ny = (local.dy / size.height).clamp(0.0, 1.0);
                setState(() {
                  _lastTapPos = local;
                  _lastTapAt = DateTime.now();
                });
                await widget.scannerService
                    .setFocusAndExposurePoint(Offset(nx, ny));
              },
            ),
            if (_lastTapPos != null && _recentTap)
              Positioned(
                left: _lastTapPos!.dx - 20,
                top: _lastTapPos!.dy - 20,
                child: _Reticle(),
              ),
          ],
        ),
      );
    } else {
      content = _placeholder();
    }

    final maxH = math.min(MediaQuery.of(context).size.height * 0.4, 360.0);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.photo_camera_back, size: 48, color: Colors.black45),
        ),
      ),
    );
  }

  bool get _recentTap {
    final t = _lastTapAt;
    if (t == null) return false;
    return DateTime.now().difference(t) < const Duration(seconds: 1);
  }
}

class _Reticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 2),
      ),
    );
  }
}

class _OcrDebugPanel extends StatelessWidget {
  const _OcrDebugPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final summary = lines.take(6).join('\n');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(fontFamily: 'monospace'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OCR characters: ${text.length}'),
            const SizedBox(height: 4),
            Text(summary.isEmpty ? '(no text)' : summary),
          ],
        ),
      ),
    );
  }
}
