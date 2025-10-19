import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Exception thrown when the manifest is missing required information.
class ModelManifestException implements FormatException {
  const ModelManifestException(this.message, [this.source, this.offset = 0]);

  @override
  final String message;

  @override
  final dynamic source;

  @override
  final int offset;

  @override
  String toString() => 'ModelManifestException: $message';
}

enum ModelArtifactType { model, tokenizer, support }

class ModelArtifactFile {
  const ModelArtifactFile({
    required this.type,
    required this.path,
    required this.sha256,
    required this.sizeBytes,
  });

  final ModelArtifactType type;
  final String path;
  final String sha256;
  final int sizeBytes;

  factory ModelArtifactFile.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'];
    if (rawType is! String || rawType.isEmpty) {
      throw ModelManifestException('Artifact file type is missing or empty.');
    }
    final type = _parseType(rawType);

    final path = json['path'];
    if (path is! String || path.isEmpty) {
      throw ModelManifestException('Artifact file path is missing or empty.');
    }
    final sha = json['sha256'];
    if (sha is! String || sha.isEmpty) {
      throw ModelManifestException(
        'Artifact file "$path" is missing sha256 checksum.',
      );
    }
    final size = json['size_bytes'];
    if (size is! int || size < 0) {
      throw ModelManifestException(
        'Artifact file "$path" has invalid size_bytes.',
      );
    }
    return ModelArtifactFile(
      type: type,
      path: path,
      sha256: sha,
      sizeBytes: size,
    );
  }

  static ModelArtifactType _parseType(String raw) {
    switch (raw.toLowerCase()) {
      case 'model':
        return ModelArtifactType.model;
      case 'tokenizer':
        return ModelArtifactType.tokenizer;
      case 'support':
        return ModelArtifactType.support;
      default:
        throw ModelManifestException('Unknown artifact type "$raw".');
    }
  }
}

class ModelVariantManifest {
  const ModelVariantManifest({
    required this.id,
    required this.displayName,
    required this.minRamGb,
    required this.recommendedRamGb,
    required this.maxSequenceLength,
    required this.quantization,
    required this.modelType,
    required this.compression,
    required this.archiveSha256,
    required this.archiveSizeBytes,
    this.archivePath,
    required this.files,
  });

  final String id;
  final String displayName;
  final double minRamGb;
  final double recommendedRamGb;
  final int maxSequenceLength;
  final String quantization;
  final String modelType;
  final String compression;
  final String archiveSha256;
  final int archiveSizeBytes;
  final String? archivePath;
  final List<ModelArtifactFile> files;

  factory ModelVariantManifest.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw ModelManifestException('Variant id is missing.');
    }
    final displayName = json['display_name'];
    if (displayName is! String || displayName.isEmpty) {
      throw ModelManifestException('Variant "$id" display_name is missing.');
    }
    final minRam = json['min_ram_gb'];
    if (minRam is! num) {
      throw ModelManifestException('Variant "$id" min_ram_gb is invalid.');
    }
    final recommendedRam = json['recommended_ram_gb'];
    if (recommendedRam is! num) {
      throw ModelManifestException(
        'Variant "$id" recommended_ram_gb is invalid.',
      );
    }
    final maxSeq = json['max_sequence_length'];
    if (maxSeq is! int || maxSeq <= 0) {
      throw ModelManifestException(
        'Variant "$id" max_sequence_length must be positive.',
      );
    }
    final quantization = json['quantization'];
    if (quantization is! String || quantization.isEmpty) {
      throw ModelManifestException('Variant "$id" quantization is missing.');
    }
    final modelType = json['model_type'];
    if (modelType is! String || modelType.isEmpty) {
      throw ModelManifestException('Variant "$id" model_type is missing.');
    }
    final compression = json['compression'];
    if (compression is! String || compression.isEmpty) {
      throw ModelManifestException('Variant "$id" compression is missing.');
    }
    final archiveSha256 = json['archive_sha256'];
    if (archiveSha256 is! String || archiveSha256.isEmpty) {
      throw ModelManifestException('Variant "$id" archive_sha256 is missing.');
    }
    final sizeBytes = json['archive_size_bytes'];
    if (sizeBytes is! int || sizeBytes < 0) {
      throw ModelManifestException(
        'Variant "$id" archive_size_bytes is invalid.',
      );
    }
    final rawArchivePath = json['archive_path'];
    String? archivePath;
    if (rawArchivePath != null) {
      if (rawArchivePath is! String || rawArchivePath.isEmpty) {
        throw ModelManifestException(
          'Variant "$id" archive_path must be a non-empty string when provided.',
        );
      }
      archivePath = rawArchivePath;
    }
    final rawFiles = json['files'];
    if (rawFiles is! List || rawFiles.isEmpty) {
      throw ModelManifestException(
        'Variant "$id" must list at least one file.',
      );
    }
    final files = rawFiles
        .map<ModelArtifactFile>((dynamic item) {
          if (item is! Map<String, dynamic>) {
            throw ModelManifestException(
              'Variant "$id" has malformed file entry.',
            );
          }
          return ModelArtifactFile.fromJson(item);
        })
        .toList(growable: false);

    final hasModel = files.any((file) => file.type == ModelArtifactType.model);
    if (!hasModel) {
      throw ModelManifestException(
        'Variant "$id" must include a model artifact.',
      );
    }

    return ModelVariantManifest(
      id: id,
      displayName: displayName,
      minRamGb: minRam.toDouble(),
      recommendedRamGb: recommendedRam.toDouble(),
      maxSequenceLength: maxSeq,
      quantization: quantization,
      modelType: modelType,
      compression: compression,
      archiveSha256: archiveSha256,
      archiveSizeBytes: sizeBytes,
      archivePath: archivePath,
      files: files,
    );
  }
}

class ModelManifest {
  const ModelManifest({
    required this.schemaVersion,
    required this.generatedAt,
    required this.artifactsBaseUrl,
    required this.variants,
  });

  final int schemaVersion;
  final DateTime generatedAt;
  final String artifactsBaseUrl;
  final List<ModelVariantManifest> variants;

  ModelVariantManifest? maybeVariant(String id) {
    for (final variant in variants) {
      if (variant.id == id) {
        return variant;
      }
    }
    return null;
  }

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schema_version'];
    if (schemaVersion is! int || schemaVersion <= 0) {
      throw ModelManifestException(
        'schema_version must be a positive integer.',
      );
    }
    final generatedAt = json['generated_at'];
    if (generatedAt is! String || generatedAt.isEmpty) {
      throw ModelManifestException('generated_at timestamp is missing.');
    }
    late DateTime parsedGeneratedAt;
    try {
      parsedGeneratedAt = DateTime.parse(generatedAt).toUtc();
    } on FormatException {
      throw ModelManifestException('generated_at must use ISO-8601 format.');
    }

    final baseUrl = json['artifacts_base_url'];
    if (baseUrl is! String || baseUrl.isEmpty) {
      throw ModelManifestException('artifacts_base_url is missing.');
    }

    final rawVariants = json['variants'];
    if (rawVariants is! List || rawVariants.isEmpty) {
      throw ModelManifestException('variants array is missing or empty.');
    }
    final variants = rawVariants
        .map<ModelVariantManifest>((dynamic item) {
          if (item is! Map<String, dynamic>) {
            throw ModelManifestException('Variant entry is malformed.');
          }
          return ModelVariantManifest.fromJson(item);
        })
        .toList(growable: false);

    return ModelManifest(
      schemaVersion: schemaVersion,
      generatedAt: parsedGeneratedAt,
      artifactsBaseUrl: baseUrl,
      variants: variants,
    );
  }
}

@LazySingleton()
class ModelManifestLoader {
  ModelManifestLoader() : _bundle = rootBundle;

  @visibleForTesting
  ModelManifestLoader.test(this._bundle);

  static const String defaultAssetPath = 'lib/core/ai/model_manifest.json';

  final AssetBundle _bundle;

  Future<ModelManifest> load({String assetPath = defaultAssetPath}) async {
    try {
      final jsonString = await _bundle.loadString(assetPath);
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const ModelManifestException('Manifest root must be a JSON map.');
      }
      return ModelManifest.fromJson(decoded);
    } on FlutterError catch (error) {
      throw ModelManifestException('Failed to load manifest asset: $error');
    } on ModelManifestException {
      rethrow;
    } on FormatException catch (error) {
      throw ModelManifestException(error.message);
    }
  }
}
