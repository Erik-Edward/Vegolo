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
      appBar: AppBar(title: const Text('History')),
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
    final icon = entry.analysis.isVegan
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
      trailing: icon,
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
      body: Padding(
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
            Row(
              children: [
                Icon(
                  entry.analysis.isVegan ? Icons.check_circle : Icons.error,
                  color: entry.analysis.isVegan ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.analysis.isVegan ? 'Vegan' : 'Non‑vegan',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Confidence: '
                '${(entry.analysis.confidence * 100).toStringAsFixed(0)}%'),
            if (entry.analysis.flaggedIngredients.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Flagged: ${entry.analysis.flaggedIngredients.join(', ')}'),
            ],
          ],
        ),
      ),
    );
  }
}

