import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Updates Gemma manifest archive metadata by computing SHA-256 checksums and
/// sizes for the provided archive files. Usage:
///
/// ```
/// dart tool/update_gemma_manifest.dart \
///   --nano path/to/gemma-nano.zip \
///   --standard path/to/gemma-standard.zip \
///   --full path/to/gemma-full.zip \
///   [--manifest lib/core/ai/model_manifest.json] \
///   [--doc docs/Gemma/README.md] \
///   [--dry-run]
/// ```
///
/// The script updates both the JSON manifest and the documentation snippet in
/// `docs/Gemma/README.md`.
Future<void> main(List<String> args) async {
  final options = _ArgumentParser(args);

  final manifestPath =
      options.option('manifest') ?? 'lib/core/ai/model_manifest.json';
  final docPath = options.option('doc') ?? 'docs/Gemma/README.md';
  final dryRun = options.hasFlag('dry-run');

  final archives = <String, String?>{
    'nano': options.option('nano'),
    'standard': options.option('standard'),
    'full': options.option('full'),
  };

  final missing = archives.entries
      .where((entry) => entry.value == null)
      .map((entry) => '--${entry.key}')
      .toList(growable: false);

  if (missing.isNotEmpty) {
    _stderr(
      'Missing archive argument(s): ${missing.join(', ')}\n'
      'Provide paths to the zipped LiteRT-LM artefacts using `--variant path`.',
    );
    exitCode = 64; // EX_USAGE
    return;
  }

  final updates = <String, _ArchiveMetadata>{};
  for (final entry in archives.entries) {
    final path = entry.value!;
    final file = File(path);
    if (!await file.exists()) {
      _stderr('Archive not found: $path');
      exitCode = 66; // EX_NOINPUT
      return;
    }
    final length = await file.length();
    final digest = await _sha256ForFile(file);
    final archivePath = 'archives/${p.basename(path)}';
    updates[entry.key] = _ArchiveMetadata(
      sha256: digest,
      sizeBytes: length,
      archivePath: archivePath,
    );
  }

  await _updateManifest(manifestPath, updates, dryRun: dryRun);
  await _updateDocumentation(docPath, updates, dryRun: dryRun);

  if (dryRun) {
    stdout.writeln('Dry-run complete. No files were modified.');
  } else {
    stdout.writeln('Updated manifest and documentation with archive metadata.');
  }
}

Future<void> _updateManifest(
  String manifestPath,
  Map<String, _ArchiveMetadata> updates, {
  required bool dryRun,
}) async {
  final file = File(manifestPath);
  if (!await file.exists()) {
    _stderr('Manifest file not found at $manifestPath');
    exitCode = 66;
    return;
  }
  final content = await file.readAsString();
  final json = jsonDecode(content) as Map<String, dynamic>;
  final variants = (json['variants'] as List<dynamic>?) ?? [];
  final logBuffer = StringBuffer();

  for (final variant in variants) {
    if (variant is! Map<String, dynamic>) continue;
    final id = variant['id'] as String?;
    if (id == null) continue;
    final metadata = updates[id];
    if (metadata == null) continue;

    logBuffer.writeln(
      ' - $id: sha256=${metadata.sha256} size=${metadata.sizeBytes} path=${metadata.archivePath}',
    );

    variant['archive_sha256'] = metadata.sha256;
    variant['archive_size_bytes'] = metadata.sizeBytes;
    variant['archive_path'] = metadata.archivePath;
  }

  if (logBuffer.isNotEmpty) {
    stdout.writeln('Manifest updates:\n${logBuffer.toString()}');
  }

  if (!dryRun) {
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(json)}\n');
  }
}

Future<void> _updateDocumentation(
  String docPath,
  Map<String, _ArchiveMetadata> updates, {
  required bool dryRun,
}) async {
  final file = File(docPath);
  if (!await file.exists()) {
    _stderr('Documentation file not found at $docPath');
    exitCode = 66;
    return;
  }
  var content = await file.readAsString();

  for (final entry in updates.entries) {
    content = _replaceDocField(
      content,
      entry.key,
      'archive_sha256',
      '"${entry.value.sha256}"',
    );
    content = _replaceDocField(
      content,
      entry.key,
      'archive_size_bytes',
      entry.value.sizeBytes.toString(),
    );
    content = _replaceDocField(
      content,
      entry.key,
      'archive_path',
      entry.value.archivePath == null ? 'null' : '"${entry.value.archivePath}"',
    );
  }

  if (!dryRun) {
    await file.writeAsString(content);
  }
}

String _replaceDocField(
  String content,
  String variantId,
  String key,
  String replacement,
) {
  final blockPattern = RegExp(
    '"id"\\s*:\\s*"$variantId"[\\s\\S]*?"$key"\\s*:\\s*[^,]+',
  );
  return content.replaceFirstMapped(blockPattern, (match) {
    final block = match.group(0)!;
    final fieldPattern = RegExp('"$key"\\s*:\\s*[^,]+');
    return block.replaceFirst(fieldPattern, '"$key": $replacement');
  });
}

Future<String> _sha256ForFile(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}

void _stderr(String message) {
  stderr.writeln(message);
}

class _ArchiveMetadata {
  const _ArchiveMetadata({
    required this.sha256,
    required this.sizeBytes,
    required this.archivePath,
  });

  final String sha256;
  final int sizeBytes;
  final String? archivePath;
}

class _ArgumentParser {
  _ArgumentParser(List<String> args) {
    String? pending;
    for (final arg in args) {
      if (arg.startsWith('--')) {
        final value = arg.substring(2);
        final parts = value.split('=');
        if (parts.length == 2) {
          _options[parts[0]] = parts[1];
          pending = null;
        } else {
          pending = parts.first;
        }
      } else if (pending != null) {
        _options[pending] = arg;
        pending = null;
      }
    }

    // Remaining pending flag without value implies boolean flag.
    if (pending != null) {
      _flags.add(pending);
    }
  }

  final Map<String, String> _options = {};
  final Set<String> _flags = {};

  String? option(String key) => _options[key];

  bool hasFlag(String key) => _flags.contains(key);
}
