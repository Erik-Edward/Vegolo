import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:vegolo/core/barcode/barcode_scanner.dart';
import 'package:vegolo/core/camera/scanner_service.dart';
import 'package:vegolo/core/di/injection.dart';
import 'package:vegolo/core/camera/scanner_models.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  StreamSubscription<ScannerFrame>? _sub;
  String? _hint;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final scanner = getIt<ScannerService>();
    final barcodeService = getIt<BarcodeScannerService>();
    setState(() => _hint = 'Align barcode in view');
    _sub = scanner.frames().listen((frame) async {
      if (_busy) return;
      _busy = true;
      try {
        final code = await barcodeService.detectBarcode(frame);
        if (!mounted) return;
        if (code != null) {
          Navigator.of(context).pop(code);
        }
      } catch (_) {
        // ignore
      } finally {
        _busy = false;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = getIt<ScannerService>().previewController;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan barcode'),
        actions: [
          IconButton(
            tooltip: 'Cancel',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ctrl != null && ctrl.value.isInitialized)
                CameraPreview(ctrl)
              else
                Container(color: Colors.black12),
              _Overlay(hint: _hint ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.hint});
  final String hint;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30, width: 2),
      ),
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              hint,
              style: const TextStyle(
                color: Colors.white,
                shadows: [Shadow(blurRadius: 2, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
