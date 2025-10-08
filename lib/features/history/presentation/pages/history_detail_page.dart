import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.entry});

  final ScanHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final thumbPath = entry.fullImagePath ?? entry.thumbnailPath;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Detail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbPath != null && File(thumbPath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(thumbPath)),
                ),
              const SizedBox(height: 16),
              Text(
                entry.productName ?? 'Unknown product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (entry.barcode != null) Text('Barcode: ${entry.barcode}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    entry.analysis.isVegan ? Icons.check_circle : Icons.error,
                    color: entry.analysis.isVegan ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(entry.analysis.isVegan ? 'Vegan' : 'Non‑vegan'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Confidence: ${(entry.analysis.confidence * 100).toStringAsFixed(0)}%',
              ),
              if (entry.analysis.flaggedIngredients.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Flagged ingredients',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(entry.analysis.flaggedIngredients.join(', ')),
              ],
              if (entry.detectedIngredients.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Detected ingredients',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...entry.detectedIngredients.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $line'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Note: Ingredient text is OCR’d from the package and may contain recognition errors. Double‑check the label if unsure.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

