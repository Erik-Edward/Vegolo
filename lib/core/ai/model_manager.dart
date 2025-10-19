import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vegolo/core/ai/model_manifest_loader.dart';
import 'package:vegolo/core/ai/gemma_channel.dart';

enum ModelVariant { nano, standard, full }

extension ModelVariantManifestId on ModelVariant {
  String get manifestId {
    switch (this) {
      case ModelVariant.nano:
        return 'nano';
      case ModelVariant.standard:
        return 'standard';
      case ModelVariant.full:
        return 'full';
    }
  }
}

@LazySingleton()
class ModelManager {
  ModelManager(this._manifestLoader, this._runtimeChannel);

  final ModelManifestLoader _manifestLoader;
  final GemmaRuntimeChannel _runtimeChannel;

  ModelManifest? _manifest;
  ModelVariant? _activeVariant;
  bool _isWarm = false;
  bool _isLoading = false;
  String? _activeModelPath;
  String? _activeTokenizerPath;

  ModelManifest get manifest {
    final cached = _manifest;
    if (cached == null) {
      throw StateError(
        'Model manifest has not been loaded yet. Call initialise() first.',
      );
    }
    return cached;
  }

  ModelVariant? get activeVariant => _activeVariant;

  bool get isLoaded => _activeVariant != null;

  bool get isWarm => _isWarm;

  bool get isLoading => _isLoading;

  String? get activeModelPath => _activeModelPath;

  String? get activeTokenizerPath => _activeTokenizerPath;

  /// Loads the manifest from assets if it has not already been cached.
  Future<void> initialise() async {
    if (_manifest != null) {
      return;
    }
    _manifest = await _manifestLoader.load();
  }

  /// Selects the best variant for the provided RAM figure.
  ModelVariant selectVariantForRam(double ramGb) {
    final manifest = _manifest;
    if (manifest == null) {
      throw StateError('Model manifest must be loaded before selection.');
    }
    final sorted = manifest.variants.toList()
      ..sort((a, b) => b.minRamGb.compareTo(a.minRamGb));
    for (final variant in sorted) {
      if (ramGb >= variant.minRamGb) {
        return _variantFromManifestId(variant.id);
      }
    }
    // Fallback to the smallest available option when device RAM is too low.
    return _variantFromManifestId(sorted.last.id);
  }

  /// Loads the model variant, optionally forcing a specific variant.
  Future<void> load({
    double? deviceRamGb,
    ModelVariant? overrideVariant,
    bool warm = true,
  }) async {
    if (_isLoading) {
      debugPrint('ModelManager.load invoked while another load is running.');
      return;
    }
    _isLoading = true;
    try {
      await initialise();
      final manifest = this.manifest;
      final variant =
          overrideVariant ??
          (deviceRamGb != null
              ? selectVariantForRam(deviceRamGb)
              : ModelVariant.standard);
      final variantManifest =
          manifest.maybeVariant(variant.manifestId) ??
          (throw StateError(
            'Manifest missing entry for variant ${variant.manifestId}.',
          ));

      if (_activeVariant == variant) {
        if (warm && !_isWarm) {
          await warmModel();
        }
        return;
      }

      // TODO(ai-phase-2): Download archive if not present locally using
      // variantManifest.archiveSha256 and artifactsBaseUrl, then verify checksum.

      // TODO(ai-phase-2): Extract archive to mmap-friendly location.

      final artifacts = await _prepareVariantArtifacts(variantManifest);
      final modelPath = artifacts.modelPath;
      final tokenizerPath = artifacts.tokenizerPath;

      await _runtimeChannel.loadVariant(
        variant: variant,
        modelPath: modelPath,
        tokenizerPath: tokenizerPath,
      );

      _activeVariant = variant;
      _activeModelPath = modelPath;
      _activeTokenizerPath = tokenizerPath;
      _isWarm = false;

      if (warm) {
        await warmModel();
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Warms the active model so the first inference has minimal latency.
  Future<void> warmModel() async {
    if (_activeVariant == null) {
      throw StateError('Cannot warm model before loading a variant.');
    }
    if (_isWarm) {
      return;
    }

    // TODO(ai-phase-2): Optionally run a startup prompt via generate() to
    // prime the interpreter and kv-cache.
    await _runtimeChannel.status();

    _isWarm = true;
  }

  /// Unloads the current model variant from memory.
  Future<void> unload() async {
    if (_activeVariant == null) {
      return;
    }

    await _runtimeChannel.unload();

    _activeVariant = null;
    _isWarm = false;
    _activeModelPath = null;
    _activeTokenizerPath = null;
  }

  ModelVariant _variantFromManifestId(String id) {
    switch (id) {
      case 'nano':
        return ModelVariant.nano;
      case 'standard':
        return ModelVariant.standard;
      case 'full':
        return ModelVariant.full;
      default:
        throw StateError('Unknown model variant id "$id".');
    }
  }

  Future<_VariantArtifacts> _prepareVariantArtifacts(
    ModelVariantManifest variantManifest,
  ) async {
    final variantDir = await _ensureVariantDirectory(variantManifest.id);

    if (_hasArchive(variantManifest)) {
      await _ensureArchiveExtracted(variantManifest, variantDir);
    }

    String? modelPath;
    String? tokenizerPath;

    for (final artifact in variantManifest.files) {
      final localPath = await _ensureArtifactAvailable(
        variantManifest,
        artifact,
        variantDir,
      );
      switch (artifact.type) {
        case ModelArtifactType.model:
          modelPath = localPath;
          break;
        case ModelArtifactType.tokenizer:
          tokenizerPath = localPath;
          break;
        case ModelArtifactType.support:
          break;
      }
    }

    if (modelPath == null) {
      throw ModelDownloadException(
        'Variant ${variantManifest.id} is missing a model artifact.',
      );
    }

    return _VariantArtifacts(
      modelPath: modelPath,
      tokenizerPath: tokenizerPath,
    );
  }

  Future<Directory> _ensureVariantDirectory(String variantId) async {
    final supportDir = await getApplicationSupportDirectory();
    final root = Directory(
      p.join(supportDir.path, 'vegolo', 'gemma3n', variantId),
    );
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  bool _hasArchive(ModelVariantManifest variantManifest) {
    final checksum = _sanitiseChecksum(variantManifest.archiveSha256);
    return checksum != null &&
        variantManifest.compression.toLowerCase() == 'zip';
  }

  Future<String> _ensureArtifactAvailable(
    ModelVariantManifest variantManifest,
    ModelArtifactFile artifact,
    Directory variantDir,
  ) async {
    final relative = _normaliseRelativePath(artifact.path);
    final localPath = p.join(variantDir.path, relative);
    final file = File(localPath);
    final expectedSha = _sanitiseChecksum(artifact.sha256);
    final expectedSize = artifact.sizeBytes > 0 ? artifact.sizeBytes : null;

    if (await _isFileValid(
      file,
      expectedSha: expectedSha,
      expectedSize: expectedSize,
    )) {
      return file.path;
    }

    if (_hasArchive(variantManifest)) {
      await _ensureArchiveExtracted(variantManifest, variantDir, force: true);
      if (await _isFileValid(
        file,
        expectedSha: expectedSha,
        expectedSize: expectedSize,
      )) {
        return file.path;
      }
      throw ModelDownloadException(
        'Extracted archive for variant ${variantManifest.id} but could not validate artifact "${artifact.path}".',
      );
    }

    final uri = _resolveUri(manifest.artifactsBaseUrl, relative);
    await file.parent.create(recursive: true);
    await _downloadFile(
      uri,
      file,
      expectedSha: expectedSha,
      expectedSize: expectedSize,
    );
    return file.path;
  }

  Future<void> _ensureArchiveExtracted(
    ModelVariantManifest variantManifest,
    Directory variantDir, {
    bool force = false,
  }) async {
    final archivePath = p.join(variantDir.path, '${variantManifest.id}.zip');
    final archiveFile = File(archivePath);
    if (!await _isArchiveValid(archiveFile, variantManifest)) {
      await _downloadArchive(variantManifest, archiveFile);
    }

    final markerFile = File(p.join(variantDir.path, '.archive_extracted'));
    final expectedMarker =
        _sanitiseChecksum(variantManifest.archiveSha256) ?? '';

    if (!force && await markerFile.exists()) {
      final content = await markerFile.readAsString();
      if (content == expectedMarker) {
        return;
      }
    }

    await _extractArchive(archiveFile, variantDir);
    if (expectedMarker.isNotEmpty) {
      await markerFile.writeAsString(expectedMarker);
    } else if (await markerFile.exists()) {
      await markerFile.delete();
    }
  }

  Future<bool> _isArchiveValid(
    File archiveFile,
    ModelVariantManifest variantManifest,
  ) {
    final expectedSha = _sanitiseChecksum(variantManifest.archiveSha256);
    final expectedSize = variantManifest.archiveSizeBytes > 0
        ? variantManifest.archiveSizeBytes
        : null;
    return _isFileValid(
      archiveFile,
      expectedSha: expectedSha,
      expectedSize: expectedSize,
    );
  }

  Future<void> _downloadArchive(
    ModelVariantManifest variantManifest,
    File archiveFile,
  ) async {
    final relative = variantManifest.archivePath ?? '${variantManifest.id}.zip';
    final uri = _resolveUri(manifest.artifactsBaseUrl, relative);
    final expectedSha = _sanitiseChecksum(variantManifest.archiveSha256);
    final expectedSize = variantManifest.archiveSizeBytes > 0
        ? variantManifest.archiveSizeBytes
        : null;

    await archiveFile.parent.create(recursive: true);
    await _downloadFile(
      uri,
      archiveFile,
      expectedSha: expectedSha,
      expectedSize: expectedSize,
    );
  }

  Future<void> _extractArchive(File archiveFile, Directory variantDir) async {
    final bytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);

    for (final entry in archive) {
      final segments = _sanitisePathSegments(entry.name);
      if (segments.isEmpty) {
        continue;
      }
      final outputPath = p.joinAll([variantDir.path, ...segments]);
      if (!p.isWithin(variantDir.path, outputPath)) {
        debugPrint('Skipping suspicious archive entry: ${entry.name}');
        continue;
      }

      if (entry.isFile) {
        final file = File(outputPath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(entry.content as List<int>, flush: true);
      } else {
        await Directory(outputPath).create(recursive: true);
      }
    }
  }

  Future<bool> _isFileValid(
    File file, {
    String? expectedSha,
    int? expectedSize,
  }) async {
    if (!await file.exists()) {
      return false;
    }
    if (expectedSize != null) {
      final size = await file.length();
      if (size != expectedSize) {
        return false;
      }
    }
    if (expectedSha != null) {
      final cachedDigest = await _readCachedDigest(file);
      if (cachedDigest != null && cachedDigest == expectedSha) {
        return true;
      }
      final digest = await _computeFileSha256(file);
      if (digest != expectedSha) {
        return false;
      }
      await _writeCachedDigest(file, digest);
    }
    return true;
  }

  Future<void> _downloadFile(
    Uri uri,
    File target, {
    String? expectedSha,
    int? expectedSize,
  }) async {
    final tempFile = File('${target.path}.download');
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw ModelDownloadException(
          'Failed to download $uri (HTTP ${response.statusCode}).',
        );
      }

      final sink = tempFile.openWrite();
      int received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
      }

      await sink.close();
      var digestString = await _computeFileSha256(tempFile);

      if (expectedSize != null && received != expectedSize) {
        await tempFile.delete();
        throw ModelDownloadException(
          'Size mismatch for $uri (expected $expectedSize, got $received).',
        );
      }

      if (expectedSha != null && digestString != expectedSha) {
        await tempFile.delete();
        throw ModelDownloadException('Checksum mismatch for $uri.');
      }

      if (await target.exists()) {
        await target.delete();
      }
      await tempFile.rename(target.path);

      await _writeCachedDigest(target, digestString);
    } on http.ClientException catch (error) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      throw ModelDownloadException(
        'Network failure while downloading $uri: $error',
      );
    } finally {
      client.close();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  Future<String?> _readCachedDigest(File file) async {
    final digestFile = File('${file.path}.sha256');
    if (!await digestFile.exists()) {
      return null;
    }
    try {
      return (await digestFile.readAsString()).trim();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCachedDigest(File file, String digest) async {
    final digestFile = File('${file.path}.sha256');
    await digestFile.writeAsString(digest);
  }

  Future<String> _computeFileSha256(File file) async {
    final digest = await crypto.sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  String _normaliseRelativePath(String relativePath) {
    final segments = _sanitisePathSegments(relativePath);
    return segments.join('/');
  }

  List<String> _sanitisePathSegments(String relativePath) {
    final rawSegments = p.posix.split(relativePath);
    final segments = <String>[];
    for (final segment in rawSegments) {
      if (segment.isEmpty || segment == '.' || segment == '..') {
        continue;
      }
      segments.add(segment);
    }
    if (segments.isEmpty) {
      throw ModelDownloadException('Invalid artifact path "$relativePath".');
    }
    return segments;
  }

  Uri _resolveUri(String base, String relativePath) {
    final baseUri = Uri.parse(base);
    final normalised = _normaliseRelativePath(relativePath);
    return baseUri.resolve(normalised);
  }

  String? _sanitiseChecksum(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'tbd') {
      return null;
    }
    return trimmed;
  }
}

class _VariantArtifacts {
  const _VariantArtifacts({required this.modelPath, this.tokenizerPath});

  final String modelPath;
  final String? tokenizerPath;
}

class ModelDownloadException implements Exception {
  ModelDownloadException(this.message);

  final String message;

  @override
  String toString() => 'ModelDownloadException: $message';
}
