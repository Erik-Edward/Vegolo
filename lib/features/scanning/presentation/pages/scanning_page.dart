import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
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
import 'package:vegolo/features/history/presentation/pages/history_detail_page.dart';
import 'package:vegolo/features/ingredients/data/seed/ingredient_seed_loader.dart';
import 'package:vegolo/features/scanning/domain/repositories/barcode_repository.dart';
import 'package:vegolo/core/barcode/barcode_scanner.dart';
import 'package:vegolo/core/telemetry/telemetry_service.dart';
import 'package:vegolo/core/telemetry/gemma_telemetry_summary.dart';

class ScanningPage extends StatefulWidget {
  const ScanningPage({super.key});

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage>
    with WidgetsBindingObserver {
  bool _showOcrOverlay = false;
  bool _showTelemetry = false;

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
          _ModeToggle(),
          _BarcodeSingleShotButton(),
          if (kDebugMode)
            IconButton(
              tooltip: _showTelemetry
                  ? 'Hide Gemma telemetry'
                  : 'Show Gemma telemetry',
              icon: Icon(
                _showTelemetry ? Icons.analytics : Icons.analytics_outlined,
              ),
              onPressed: () => setState(() => _showTelemetry = !_showTelemetry),
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
                if (!context.mounted) return;
                await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
                return;
              }
              if (value == 'seed') {
                // Best-effort refresh of ingredient seed
                try {
                  await getIt<IngredientSeedLoader>().refreshSeed();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingredient seed refreshed')),
                  );
                } catch (_) {}
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'seed',
                child: Text('Refresh ingredient seed'),
              ),
            ],
          ),
        ],
      ),
      // History is accessible via bottom navigation in AppShell.
      body: BlocListener<ScanningBloc, ScanningState>(
        listenWhen: (prev, curr) =>
            prev.pendingDetailEntry == null && curr.pendingDetailEntry != null,
        listener: (context, state) async {
          final entry = state.pendingDetailEntry!;
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => HistoryDetailPage(entry: entry)),
          );
          if (context.mounted) {
            context.read<ScanningBloc>().add(const ScanningDetailShown());
          }
        },
        child: BlocBuilder<ScanningBloc, ScanningState>(
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
              state.mode,
              bloc,
            );
            final bool showStopButton =
                (state.mode != ScanMode.barcode) &&
                switch (state.status) {
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
                    Stack(
                      children: [
                        _CameraPreviewArea(
                          scannerService: scannerService,
                          status: state.status,
                        ),
                        // Accessibility: announce mode change and overlay.
                        Semantics(
                          container: true,
                          label: state.mode == ScanMode.barcode
                              ? 'Barcode scanning active. Align barcode in the box.'
                              : 'Text scanning active.',
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: state.mode == ScanMode.barcode
                                ? const _BarcodeOverlay(
                                    key: ValueKey('barcodeOverlay'),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('noOverlay'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ChameleonMascot(statusColor: color),
                    const SizedBox(height: 16),
                    ScanResultCard(
                      title: statusLabel,
                      subtitle: subtitle,
                      trailing: Icon(_statusIcon(state.status), color: color),
                    ),
                    if (state.aiInFlight ||
                        state.aiPartialResponse != null ||
                        state.aiFinishReason != null) ...[
                      const SizedBox(height: 12),
                      _AiProgressIndicator(
                        inFlight: state.aiInFlight,
                        partial: state.aiPartialResponse,
                        ttftMs: state.aiTtftMs,
                        latencyMs: state.aiLatencyMs,
                        finishReason: state.aiFinishReason,
                        onCancel: state.aiInFlight
                            ? () => bloc.add(const ScanningAiCancelRequested())
                            : null,
                      ),
                    ],
                    if (kDebugMode && _showTelemetry) ...[
                      const SizedBox(height: 12),
                      const _GemmaTelemetryPanel(),
                    ],
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unofficial info. Double-check label if unsure.',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.black54),
                            ),
                            if ((state.offIngredients == null ||
                                    state.offIngredients!.isEmpty) &&
                                (state.offIngredientsText == null ||
                                    state.offIngredientsText!.trim().isEmpty))
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Ingredients unavailable on OFF for this product.',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ),
                          ],
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
                    if (primaryAction != null)
                      FilledButton(
                        onPressed: primaryAction,
                        child: Text(primaryLabel),
                      )
                    else
                      FilledButton.tonal(
                        onPressed: null,
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
    ScanMode mode,
    ScanningBloc bloc,
  ) {
    return switch (status) {
      ScanningStatus.idle || ScanningStatus.failure => (
        'Begin scanning',
        () => bloc.add(const ScanningStarted()),
      ),
      ScanningStatus.initializing => ('Initializing…', null),
      ScanningStatus.scanning || ScanningStatus.success =>
        mode == ScanMode.barcode
            ? ('Scanning…', null)
            : ('Pause scanning', () => bloc.add(const ScanningPaused())),
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

class _AiProgressIndicator extends StatelessWidget {
  const _AiProgressIndicator({
    required this.inFlight,
    required this.partial,
    required this.ttftMs,
    required this.latencyMs,
    required this.finishReason,
    this.onCancel,
  });

  final bool inFlight;
  final String? partial;
  final int? ttftMs;
  final int? latencyMs;
  final String? finishReason;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final telemetryParts = <String>[];
    if (ttftMs != null) {
      telemetryParts.add('TTFT: $ttftMs ms');
    }
    if (latencyMs != null) {
      telemetryParts.add('Latency: $latencyMs ms');
    }
    if (!inFlight && finishReason != null && finishReason!.isNotEmpty) {
      telemetryParts.add('Reason: $finishReason');
    }
    final telemetry = telemetryParts.join(' • ');

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (inFlight)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    finishReason == 'cancelled'
                        ? Icons.stop_circle
                        : Icons.analytics,
                    color: theme.colorScheme.primary,
                  ),
                const SizedBox(width: 8),
                Text(
                  inFlight ? 'Gemma analyzing…' : 'Gemma analysis complete',
                  style: theme.textTheme.labelLarge,
                ),
                if (onCancel != null) ...[
                  const Spacer(),
                  TextButton(onPressed: onCancel, child: const Text('Cancel')),
                ],
              ],
            ),
            if (partial != null && partial!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(partial!, style: theme.textTheme.bodySmall),
            ],
            if (telemetry.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                telemetry,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GemmaTelemetryPanel extends StatelessWidget {
  const _GemmaTelemetryPanel();

  @override
  Widget build(BuildContext context) {
    final telemetry = getIt<TelemetryService>();
    return ValueListenableBuilder<GemmaTelemetrySummary>(
      valueListenable: telemetry.gemmaSummary,
      builder: (context, summary, _) {
        if (summary.total == 0) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gemma telemetry', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _TelemetryChip(label: 'total', value: summary.total),
                    _TelemetryChip(label: 'success', value: summary.success),
                    _TelemetryChip(label: 'timeout', value: summary.timeout),
                    _TelemetryChip(
                      label: 'cancelled',
                      value: summary.cancelled,
                    ),
                    _TelemetryChip(label: 'error', value: summary.error),
                    _TelemetryChip(label: 'parse', value: summary.parseFailure),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'TTFT avg: '
                  '${summary.averageTtftMs != null ? summary.averageTtftMs!.toStringAsFixed(1) : '—'} ms '
                  '(n=${summary.ttftSamples})',
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  'Latency avg: '
                  '${summary.averageLatencyMs != null ? summary.averageLatencyMs!.toStringAsFixed(1) : '—'} ms '
                  '(n=${summary.latencySamples})',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TelemetryChip extends StatelessWidget {
  const _TelemetryChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      backgroundColor: theme.colorScheme.secondaryContainer.withValues(
        alpha: 0.4,
      ),
      label: Text('$label: $value'),
    );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Flash not supported: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _ModeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScanningBloc>().state;
    final selected = {state.mode};
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: SegmentedButton<ScanMode>(
        segments: const [
          ButtonSegment(
            value: ScanMode.ingredients,
            label: Text('Text'),
            icon: Icon(Icons.text_fields),
          ),
          ButtonSegment(
            value: ScanMode.barcode,
            label: Text('Barcode'),
            icon: Icon(Icons.qr_code_scanner),
          ),
        ],
        selected: selected,
        showSelectedIcon: false,
        onSelectionChanged: (values) {
          final mode = values.first;
          context.read<ScanningBloc>().add(ScanningModeChanged(mode));
        },
      ),
    );
  }
}

class _BarcodeSingleShotButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScanningBloc>().state;
    if (state.mode != ScanMode.barcode) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Snap barcode (single-shot)',
      icon: const Icon(Icons.camera),
      onPressed: () async {
        final scanner = getIt<ScannerService>();
        final path = await scanner.captureStill();
        try {
          // Ensure preview resumes for continuity.
          await scanner.resume();
        } catch (_) {}
        if (path == null) return;
        final barcodeService = getIt<BarcodeScannerService>();
        final code = await barcodeService.detectBarcodeFromFile(path);
        if (code == null) return;
        final repo = getIt<BarcodeRepository>();
        final product = await repo.fetchOffProduct(code);
        if (!context.mounted) return;
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
    );
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
    final CameraController? controller =
        widget.scannerService.previewController;
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
                await widget.scannerService.setFocusAndExposurePoint(
                  Offset(nx, ny),
                );
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
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DefaultTextStyle(
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(fontFamily: 'monospace'),
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

class _BarcodeOverlay extends StatefulWidget {
  const _BarcodeOverlay({super.key});
  @override
  State<_BarcodeOverlay> createState() => _BarcodeOverlayState();
}

class _BarcodeOverlayState extends State<_BarcodeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Barcode scan area',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          // Define a centered box; wide orientation works well for 1D codes.
          final boxWidth = width * 0.8;
          final boxHeight = boxWidth * 0.6;
          final left = (width - boxWidth) / 2;
          final top = (height - boxHeight) / 2;
          final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _BarcodeMaskPainter(rect: rect, t: _ctrl.value),
            ),
          );
        },
      ),
    );
  }
}

class _BarcodeMaskPainter extends CustomPainter {
  _BarcodeMaskPainter({required this.rect, required this.t});
  final Rect rect;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = const Color(0xAA000000);
    final clear = Paint()..blendMode = BlendMode.clear;
    final border = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Darken everything
    canvas.drawRect(Offset.zero & size, overlay);
    // Clear scan box area
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, clear);
    // Draw border
    canvas.drawRRect(rrect, border);
    // Animated scan line
    final y = rect.top + rect.height * t;
    final line = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2;
    canvas.drawLine(Offset(rect.left + 8, y), Offset(rect.right - 8, y), line);
  }

  @override
  bool shouldRepaint(covariant _BarcodeMaskPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.rect != rect;
  }
}
