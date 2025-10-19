import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
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

      final modelPath = await _resolveModelPath(variantManifest);
      final tokenizerPath = await _resolveTokenizerPath(variantManifest);

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

  Future<String> _resolveModelPath(ModelVariantManifest variantManifest) async {
    final artifact = variantManifest.files.firstWhere(
      (file) => file.type == ModelArtifactType.model,
    );

    // TODO(ai-phase-2): Resolve to the extracted file location under
    // ApplicationSupportDirectory before returning the path.
    return artifact.path;
  }

  Future<String?> _resolveTokenizerPath(
    ModelVariantManifest variantManifest,
  ) async {
    ModelArtifactFile? tokenizer;
    for (final file in variantManifest.files) {
      if (file.type == ModelArtifactType.tokenizer) {
        tokenizer = file;
        break;
      }
    }
    if (tokenizer == null) {
      return null;
    }

    // TODO(ai-phase-2): Resolve to extracted tokenizer file.
    return tokenizer.path;
  }
}
