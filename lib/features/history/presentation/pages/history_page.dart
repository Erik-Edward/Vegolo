import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vegolo/core/di/injection.dart';
import 'package:vegolo/features/history/domain/entities/scan_history_entry.dart';
import 'package:vegolo/features/history/domain/repositories/scan_history_repository.dart';
import 'package:vegolo/features/history/presentation/thumbnail_cache.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<ScanHistoryRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Delete all history',
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete all history?'),
                  content: const Text(
                    'This will remove all saved scans and thumbnails. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await repo.clearHistory();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ScanHistoryEntry>>(
        stream: repo.watchHistory(),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <ScanHistoryEntry>[];
          if (entries.isEmpty) {
            return const Center(
              child: Text('No scans yet. Start scanning to build history.'),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              return _HistoryListTile(entry: e);
            },
          );
        },
      ),
    );
  }
}

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({required this.entry});

  final ScanHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().add_jm().format(entry.scannedAt);
    final title = entry.productName ?? 'Scanned on $dateStr';
    final subtitle = entry.analysis.isVegan
        ? 'Vegan • ${(entry.analysis.confidence * 100).toStringAsFixed(0)}%'
        : (entry.analysis.flaggedIngredients.isNotEmpty
            ? 'Non‑vegan: ${entry.analysis.flaggedIngredients.join(', ')}'
            : 'Non‑vegan');
    final statusIcon = entry.analysis.isVegan
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.error, color: Colors.red);

    final thumbPath = entry.thumbnailPath;
    Widget leading;
    if (thumbPath != null && File(thumbPath).existsSync()) {
      leading = FutureBuilder(
        future: thumbnailCache.load(thumbPath),
        builder: (context, snapshot) {
          final provider = snapshot.data;
          if (provider == null) {
            return const _ThumbPlaceholder();
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image(
              image: provider,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          );
        },
      );
    } else {
      leading = const _ThumbPlaceholder();
    }

    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          statusIcon,
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Delete image data',
            icon: const Icon(Icons.image_not_supported_outlined),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete image data?'),
                  content: const Text('Keep the entry metadata but remove images.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete images'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await getIt<ScanHistoryRepository>().deleteEntryImageData(entry.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image data deleted')),
                );
              }
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete this entry?'),
                  content: const Text('Remove this scan and its image data.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await getIt<ScanHistoryRepository>().deleteEntry(entry.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry deleted')),
                );
              }
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _HistoryDetailPage(entry: entry)),
        );
      },
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.black45),
    );
  }
}

class _HistoryDetailPage extends StatelessWidget {
  const _HistoryDetailPage({required this.entry});

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
                )
              else
                const _ThumbPlaceholder(),
              const SizedBox(height: 16),
              Text(
                entry.productName ?? 'Unknown product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (entry.barcode != null)
                Text('Barcode: ${entry.barcode}'),
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
