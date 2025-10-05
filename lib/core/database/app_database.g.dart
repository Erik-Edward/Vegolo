// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScanHistoryEntriesTable extends ScanHistoryEntries
    with TableInfo<$ScanHistoryEntriesTable, ScanHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analysisJsonMeta = const VerificationMeta(
    'analysisJson',
  );
  @override
  late final GeneratedColumn<String> analysisJson = GeneratedColumn<String>(
    'analysis_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullImagePathMeta = const VerificationMeta(
    'fullImagePath',
  );
  @override
  late final GeneratedColumn<String> fullImagePath = GeneratedColumn<String>(
    'full_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasFullImageMeta = const VerificationMeta(
    'hasFullImage',
  );
  @override
  late final GeneratedColumn<bool> hasFullImage = GeneratedColumn<bool>(
    'has_full_image',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_full_image" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _detectedIngredientsJsonMeta =
      const VerificationMeta('detectedIngredientsJson');
  @override
  late final GeneratedColumn<String> detectedIngredientsJson =
      GeneratedColumn<String>(
        'detected_ingredients_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scannedAt,
    analysisJson,
    productName,
    barcode,
    thumbnailPath,
    fullImagePath,
    hasFullImage,
    detectedIngredientsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    if (data.containsKey('analysis_json')) {
      context.handle(
        _analysisJsonMeta,
        analysisJson.isAcceptableOrUnknown(
          data['analysis_json']!,
          _analysisJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_analysisJsonMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('full_image_path')) {
      context.handle(
        _fullImagePathMeta,
        fullImagePath.isAcceptableOrUnknown(
          data['full_image_path']!,
          _fullImagePathMeta,
        ),
      );
    }
    if (data.containsKey('has_full_image')) {
      context.handle(
        _hasFullImageMeta,
        hasFullImage.isAcceptableOrUnknown(
          data['has_full_image']!,
          _hasFullImageMeta,
        ),
      );
    }
    if (data.containsKey('detected_ingredients_json')) {
      context.handle(
        _detectedIngredientsJsonMeta,
        detectedIngredientsJson.isAcceptableOrUnknown(
          data['detected_ingredients_json']!,
          _detectedIngredientsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
      analysisJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_json'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      fullImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_image_path'],
      ),
      hasFullImage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_full_image'],
      )!,
      detectedIngredientsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_ingredients_json'],
      )!,
    );
  }

  @override
  $ScanHistoryEntriesTable createAlias(String alias) {
    return $ScanHistoryEntriesTable(attachedDatabase, alias);
  }
}

class ScanHistoryEntry extends DataClass
    implements Insertable<ScanHistoryEntry> {
  final String id;
  final DateTime scannedAt;
  final String analysisJson;
  final String? productName;
  final String? barcode;
  final String? thumbnailPath;
  final String? fullImagePath;
  final bool hasFullImage;
  final String detectedIngredientsJson;
  const ScanHistoryEntry({
    required this.id,
    required this.scannedAt,
    required this.analysisJson,
    this.productName,
    this.barcode,
    this.thumbnailPath,
    this.fullImagePath,
    required this.hasFullImage,
    required this.detectedIngredientsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    map['analysis_json'] = Variable<String>(analysisJson);
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || fullImagePath != null) {
      map['full_image_path'] = Variable<String>(fullImagePath);
    }
    map['has_full_image'] = Variable<bool>(hasFullImage);
    map['detected_ingredients_json'] = Variable<String>(
      detectedIngredientsJson,
    );
    return map;
  }

  ScanHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return ScanHistoryEntriesCompanion(
      id: Value(id),
      scannedAt: Value(scannedAt),
      analysisJson: Value(analysisJson),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      fullImagePath: fullImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(fullImagePath),
      hasFullImage: Value(hasFullImage),
      detectedIngredientsJson: Value(detectedIngredientsJson),
    );
  }

  factory ScanHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanHistoryEntry(
      id: serializer.fromJson<String>(json['id']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
      analysisJson: serializer.fromJson<String>(json['analysisJson']),
      productName: serializer.fromJson<String?>(json['productName']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      fullImagePath: serializer.fromJson<String?>(json['fullImagePath']),
      hasFullImage: serializer.fromJson<bool>(json['hasFullImage']),
      detectedIngredientsJson: serializer.fromJson<String>(
        json['detectedIngredientsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
      'analysisJson': serializer.toJson<String>(analysisJson),
      'productName': serializer.toJson<String?>(productName),
      'barcode': serializer.toJson<String?>(barcode),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'fullImagePath': serializer.toJson<String?>(fullImagePath),
      'hasFullImage': serializer.toJson<bool>(hasFullImage),
      'detectedIngredientsJson': serializer.toJson<String>(
        detectedIngredientsJson,
      ),
    };
  }

  ScanHistoryEntry copyWith({
    String? id,
    DateTime? scannedAt,
    String? analysisJson,
    Value<String?> productName = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<String?> fullImagePath = const Value.absent(),
    bool? hasFullImage,
    String? detectedIngredientsJson,
  }) => ScanHistoryEntry(
    id: id ?? this.id,
    scannedAt: scannedAt ?? this.scannedAt,
    analysisJson: analysisJson ?? this.analysisJson,
    productName: productName.present ? productName.value : this.productName,
    barcode: barcode.present ? barcode.value : this.barcode,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    fullImagePath: fullImagePath.present
        ? fullImagePath.value
        : this.fullImagePath,
    hasFullImage: hasFullImage ?? this.hasFullImage,
    detectedIngredientsJson:
        detectedIngredientsJson ?? this.detectedIngredientsJson,
  );
  ScanHistoryEntry copyWithCompanion(ScanHistoryEntriesCompanion data) {
    return ScanHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      analysisJson: data.analysisJson.present
          ? data.analysisJson.value
          : this.analysisJson,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      fullImagePath: data.fullImagePath.present
          ? data.fullImagePath.value
          : this.fullImagePath,
      hasFullImage: data.hasFullImage.present
          ? data.hasFullImage.value
          : this.hasFullImage,
      detectedIngredientsJson: data.detectedIngredientsJson.present
          ? data.detectedIngredientsJson.value
          : this.detectedIngredientsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryEntry(')
          ..write('id: $id, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('fullImagePath: $fullImagePath, ')
          ..write('hasFullImage: $hasFullImage, ')
          ..write('detectedIngredientsJson: $detectedIngredientsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scannedAt,
    analysisJson,
    productName,
    barcode,
    thumbnailPath,
    fullImagePath,
    hasFullImage,
    detectedIngredientsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanHistoryEntry &&
          other.id == this.id &&
          other.scannedAt == this.scannedAt &&
          other.analysisJson == this.analysisJson &&
          other.productName == this.productName &&
          other.barcode == this.barcode &&
          other.thumbnailPath == this.thumbnailPath &&
          other.fullImagePath == this.fullImagePath &&
          other.hasFullImage == this.hasFullImage &&
          other.detectedIngredientsJson == this.detectedIngredientsJson);
}

class ScanHistoryEntriesCompanion extends UpdateCompanion<ScanHistoryEntry> {
  final Value<String> id;
  final Value<DateTime> scannedAt;
  final Value<String> analysisJson;
  final Value<String?> productName;
  final Value<String?> barcode;
  final Value<String?> thumbnailPath;
  final Value<String?> fullImagePath;
  final Value<bool> hasFullImage;
  final Value<String> detectedIngredientsJson;
  final Value<int> rowid;
  const ScanHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.analysisJson = const Value.absent(),
    this.productName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.fullImagePath = const Value.absent(),
    this.hasFullImage = const Value.absent(),
    this.detectedIngredientsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanHistoryEntriesCompanion.insert({
    required String id,
    required DateTime scannedAt,
    required String analysisJson,
    this.productName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.fullImagePath = const Value.absent(),
    this.hasFullImage = const Value.absent(),
    this.detectedIngredientsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scannedAt = Value(scannedAt),
       analysisJson = Value(analysisJson);
  static Insertable<ScanHistoryEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? scannedAt,
    Expression<String>? analysisJson,
    Expression<String>? productName,
    Expression<String>? barcode,
    Expression<String>? thumbnailPath,
    Expression<String>? fullImagePath,
    Expression<bool>? hasFullImage,
    Expression<String>? detectedIngredientsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (analysisJson != null) 'analysis_json': analysisJson,
      if (productName != null) 'product_name': productName,
      if (barcode != null) 'barcode': barcode,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (fullImagePath != null) 'full_image_path': fullImagePath,
      if (hasFullImage != null) 'has_full_image': hasFullImage,
      if (detectedIngredientsJson != null)
        'detected_ingredients_json': detectedIngredientsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanHistoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? scannedAt,
    Value<String>? analysisJson,
    Value<String?>? productName,
    Value<String?>? barcode,
    Value<String?>? thumbnailPath,
    Value<String?>? fullImagePath,
    Value<bool>? hasFullImage,
    Value<String>? detectedIngredientsJson,
    Value<int>? rowid,
  }) {
    return ScanHistoryEntriesCompanion(
      id: id ?? this.id,
      scannedAt: scannedAt ?? this.scannedAt,
      analysisJson: analysisJson ?? this.analysisJson,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fullImagePath: fullImagePath ?? this.fullImagePath,
      hasFullImage: hasFullImage ?? this.hasFullImage,
      detectedIngredientsJson:
          detectedIngredientsJson ?? this.detectedIngredientsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    if (analysisJson.present) {
      map['analysis_json'] = Variable<String>(analysisJson.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (fullImagePath.present) {
      map['full_image_path'] = Variable<String>(fullImagePath.value);
    }
    if (hasFullImage.present) {
      map['has_full_image'] = Variable<bool>(hasFullImage.value);
    }
    if (detectedIngredientsJson.present) {
      map['detected_ingredients_json'] = Variable<String>(
        detectedIngredientsJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('fullImagePath: $fullImagePath, ')
          ..write('hasFullImage: $hasFullImage, ')
          ..write('detectedIngredientsJson: $detectedIngredientsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, IngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rationaleMeta = const VerificationMeta(
    'rationale',
  );
  @override
  late final GeneratedColumn<String> rationale = GeneratedColumn<String>(
    'rationale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _uncertaintyMeta = const VerificationMeta(
    'uncertainty',
  );
  @override
  late final GeneratedColumn<double> uncertainty = GeneratedColumn<double>(
    'uncertainty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processingAidMeta = const VerificationMeta(
    'processingAid',
  );
  @override
  late final GeneratedColumn<bool> processingAid = GeneratedColumn<bool>(
    'processing_aid',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("processing_aid" IN (0, 1))',
    ),
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    status,
    category,
    rationale,
    sourceUrl,
    lastVerifiedAt,
    uncertainty,
    processingAid,
    normalizedName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('rationale')) {
      context.handle(
        _rationaleMeta,
        rationale.isAcceptableOrUnknown(data['rationale']!, _rationaleMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('uncertainty')) {
      context.handle(
        _uncertaintyMeta,
        uncertainty.isAcceptableOrUnknown(
          data['uncertainty']!,
          _uncertaintyMeta,
        ),
      );
    }
    if (data.containsKey('processing_aid')) {
      context.handle(
        _processingAidMeta,
        processingAid.isAcceptableOrUnknown(
          data['processing_aid']!,
          _processingAidMeta,
        ),
      );
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      rationale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rationale'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
      uncertainty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}uncertainty'],
      ),
      processingAid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}processing_aid'],
      ),
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class IngredientRow extends DataClass implements Insertable<IngredientRow> {
  final String id;
  final String name;
  final int status;
  final String? category;
  final String? rationale;
  final String? sourceUrl;
  final DateTime? lastVerifiedAt;
  final double? uncertainty;
  final bool? processingAid;
  final String normalizedName;
  const IngredientRow({
    required this.id,
    required this.name,
    required this.status,
    this.category,
    this.rationale,
    this.sourceUrl,
    this.lastVerifiedAt,
    this.uncertainty,
    this.processingAid,
    required this.normalizedName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || rationale != null) {
      map['rationale'] = Variable<String>(rationale);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    if (!nullToAbsent || uncertainty != null) {
      map['uncertainty'] = Variable<double>(uncertainty);
    }
    if (!nullToAbsent || processingAid != null) {
      map['processing_aid'] = Variable<bool>(processingAid);
    }
    map['normalized_name'] = Variable<String>(normalizedName);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      status: Value(status),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      rationale: rationale == null && nullToAbsent
          ? const Value.absent()
          : Value(rationale),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
      uncertainty: uncertainty == null && nullToAbsent
          ? const Value.absent()
          : Value(uncertainty),
      processingAid: processingAid == null && nullToAbsent
          ? const Value.absent()
          : Value(processingAid),
      normalizedName: Value(normalizedName),
    );
  }

  factory IngredientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<int>(json['status']),
      category: serializer.fromJson<String?>(json['category']),
      rationale: serializer.fromJson<String?>(json['rationale']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
      uncertainty: serializer.fromJson<double?>(json['uncertainty']),
      processingAid: serializer.fromJson<bool?>(json['processingAid']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<int>(status),
      'category': serializer.toJson<String?>(category),
      'rationale': serializer.toJson<String?>(rationale),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
      'uncertainty': serializer.toJson<double?>(uncertainty),
      'processingAid': serializer.toJson<bool?>(processingAid),
      'normalizedName': serializer.toJson<String>(normalizedName),
    };
  }

  IngredientRow copyWith({
    String? id,
    String? name,
    int? status,
    Value<String?> category = const Value.absent(),
    Value<String?> rationale = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
    Value<double?> uncertainty = const Value.absent(),
    Value<bool?> processingAid = const Value.absent(),
    String? normalizedName,
  }) => IngredientRow(
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
    category: category.present ? category.value : this.category,
    rationale: rationale.present ? rationale.value : this.rationale,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
    uncertainty: uncertainty.present ? uncertainty.value : this.uncertainty,
    processingAid: processingAid.present
        ? processingAid.value
        : this.processingAid,
    normalizedName: normalizedName ?? this.normalizedName,
  );
  IngredientRow copyWithCompanion(IngredientsCompanion data) {
    return IngredientRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      category: data.category.present ? data.category.value : this.category,
      rationale: data.rationale.present ? data.rationale.value : this.rationale,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
      uncertainty: data.uncertainty.present
          ? data.uncertainty.value
          : this.uncertainty,
      processingAid: data.processingAid.present
          ? data.processingAid.value
          : this.processingAid,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('rationale: $rationale, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('uncertainty: $uncertainty, ')
          ..write('processingAid: $processingAid, ')
          ..write('normalizedName: $normalizedName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    status,
    category,
    rationale,
    sourceUrl,
    lastVerifiedAt,
    uncertainty,
    processingAid,
    normalizedName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.status == this.status &&
          other.category == this.category &&
          other.rationale == this.rationale &&
          other.sourceUrl == this.sourceUrl &&
          other.lastVerifiedAt == this.lastVerifiedAt &&
          other.uncertainty == this.uncertainty &&
          other.processingAid == this.processingAid &&
          other.normalizedName == this.normalizedName);
}

class IngredientsCompanion extends UpdateCompanion<IngredientRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> status;
  final Value<String?> category;
  final Value<String?> rationale;
  final Value<String?> sourceUrl;
  final Value<DateTime?> lastVerifiedAt;
  final Value<double?> uncertainty;
  final Value<bool?> processingAid;
  final Value<String> normalizedName;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.category = const Value.absent(),
    this.rationale = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.uncertainty = const Value.absent(),
    this.processingAid = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required String id,
    required String name,
    required int status,
    this.category = const Value.absent(),
    this.rationale = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.uncertainty = const Value.absent(),
    this.processingAid = const Value.absent(),
    required String normalizedName,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       status = Value(status),
       normalizedName = Value(normalizedName);
  static Insertable<IngredientRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? status,
    Expression<String>? category,
    Expression<String>? rationale,
    Expression<String>? sourceUrl,
    Expression<DateTime>? lastVerifiedAt,
    Expression<double>? uncertainty,
    Expression<bool>? processingAid,
    Expression<String>? normalizedName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (rationale != null) 'rationale': rationale,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (uncertainty != null) 'uncertainty': uncertainty,
      if (processingAid != null) 'processing_aid': processingAid,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? status,
    Value<String?>? category,
    Value<String?>? rationale,
    Value<String?>? sourceUrl,
    Value<DateTime?>? lastVerifiedAt,
    Value<double?>? uncertainty,
    Value<bool?>? processingAid,
    Value<String>? normalizedName,
    Value<int>? rowid,
  }) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      category: category ?? this.category,
      rationale: rationale ?? this.rationale,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      uncertainty: uncertainty ?? this.uncertainty,
      processingAid: processingAid ?? this.processingAid,
      normalizedName: normalizedName ?? this.normalizedName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rationale.present) {
      map['rationale'] = Variable<String>(rationale.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (uncertainty.present) {
      map['uncertainty'] = Variable<double>(uncertainty.value);
    }
    if (processingAid.present) {
      map['processing_aid'] = Variable<bool>(processingAid.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('rationale: $rationale, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('uncertainty: $uncertainty, ')
          ..write('processingAid: $processingAid, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientAliasesTable extends IngredientAliases
    with TableInfo<$IngredientAliasesTable, IngredientAliasRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id)',
    ),
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedAliasMeta = const VerificationMeta(
    'normalizedAlias',
  );
  @override
  late final GeneratedColumn<String> normalizedAlias = GeneratedColumn<String>(
    'normalized_alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ingredientId,
    alias,
    normalizedAlias,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientAliasRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('normalized_alias')) {
      context.handle(
        _normalizedAliasMeta,
        normalizedAlias.isAcceptableOrUnknown(
          data['normalized_alias']!,
          _normalizedAliasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedAliasMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientAliasRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientAliasRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      normalizedAlias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_alias'],
      )!,
    );
  }

  @override
  $IngredientAliasesTable createAlias(String alias) {
    return $IngredientAliasesTable(attachedDatabase, alias);
  }
}

class IngredientAliasRow extends DataClass
    implements Insertable<IngredientAliasRow> {
  final int id;
  final String ingredientId;
  final String alias;
  final String normalizedAlias;
  const IngredientAliasRow({
    required this.id,
    required this.ingredientId,
    required this.alias,
    required this.normalizedAlias,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['alias'] = Variable<String>(alias);
    map['normalized_alias'] = Variable<String>(normalizedAlias);
    return map;
  }

  IngredientAliasesCompanion toCompanion(bool nullToAbsent) {
    return IngredientAliasesCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      alias: Value(alias),
      normalizedAlias: Value(normalizedAlias),
    );
  }

  factory IngredientAliasRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientAliasRow(
      id: serializer.fromJson<int>(json['id']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      alias: serializer.fromJson<String>(json['alias']),
      normalizedAlias: serializer.fromJson<String>(json['normalizedAlias']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'alias': serializer.toJson<String>(alias),
      'normalizedAlias': serializer.toJson<String>(normalizedAlias),
    };
  }

  IngredientAliasRow copyWith({
    int? id,
    String? ingredientId,
    String? alias,
    String? normalizedAlias,
  }) => IngredientAliasRow(
    id: id ?? this.id,
    ingredientId: ingredientId ?? this.ingredientId,
    alias: alias ?? this.alias,
    normalizedAlias: normalizedAlias ?? this.normalizedAlias,
  );
  IngredientAliasRow copyWithCompanion(IngredientAliasesCompanion data) {
    return IngredientAliasRow(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      alias: data.alias.present ? data.alias.value : this.alias,
      normalizedAlias: data.normalizedAlias.present
          ? data.normalizedAlias.value
          : this.normalizedAlias,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientAliasRow(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('alias: $alias, ')
          ..write('normalizedAlias: $normalizedAlias')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ingredientId, alias, normalizedAlias);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientAliasRow &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.alias == this.alias &&
          other.normalizedAlias == this.normalizedAlias);
}

class IngredientAliasesCompanion extends UpdateCompanion<IngredientAliasRow> {
  final Value<int> id;
  final Value<String> ingredientId;
  final Value<String> alias;
  final Value<String> normalizedAlias;
  const IngredientAliasesCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.alias = const Value.absent(),
    this.normalizedAlias = const Value.absent(),
  });
  IngredientAliasesCompanion.insert({
    this.id = const Value.absent(),
    required String ingredientId,
    required String alias,
    required String normalizedAlias,
  }) : ingredientId = Value(ingredientId),
       alias = Value(alias),
       normalizedAlias = Value(normalizedAlias);
  static Insertable<IngredientAliasRow> custom({
    Expression<int>? id,
    Expression<String>? ingredientId,
    Expression<String>? alias,
    Expression<String>? normalizedAlias,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (alias != null) 'alias': alias,
      if (normalizedAlias != null) 'normalized_alias': normalizedAlias,
    });
  }

  IngredientAliasesCompanion copyWith({
    Value<int>? id,
    Value<String>? ingredientId,
    Value<String>? alias,
    Value<String>? normalizedAlias,
  }) {
    return IngredientAliasesCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      alias: alias ?? this.alias,
      normalizedAlias: normalizedAlias ?? this.normalizedAlias,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (normalizedAlias.present) {
      map['normalized_alias'] = Variable<String>(normalizedAlias.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientAliasesCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('alias: $alias, ')
          ..write('normalizedAlias: $normalizedAlias')
          ..write(')'))
        .toString();
  }
}

class $IngredientENumbersTable extends IngredientENumbers
    with TableInfo<$IngredientENumbersTable, IngredientENumberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientENumbersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id)',
    ),
  );
  static const VerificationMeta _enumberMeta = const VerificationMeta(
    'enumber',
  );
  @override
  late final GeneratedColumn<String> enumber = GeneratedColumn<String>(
    'enumber',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ingredientId, enumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_e_numbers';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientENumberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('enumber')) {
      context.handle(
        _enumberMeta,
        enumber.isAcceptableOrUnknown(data['enumber']!, _enumberMeta),
      );
    } else if (isInserting) {
      context.missing(_enumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientENumberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientENumberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      enumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enumber'],
      )!,
    );
  }

  @override
  $IngredientENumbersTable createAlias(String alias) {
    return $IngredientENumbersTable(attachedDatabase, alias);
  }
}

class IngredientENumberRow extends DataClass
    implements Insertable<IngredientENumberRow> {
  final int id;
  final String ingredientId;
  final String enumber;
  const IngredientENumberRow({
    required this.id,
    required this.ingredientId,
    required this.enumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['enumber'] = Variable<String>(enumber);
    return map;
  }

  IngredientENumbersCompanion toCompanion(bool nullToAbsent) {
    return IngredientENumbersCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      enumber: Value(enumber),
    );
  }

  factory IngredientENumberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientENumberRow(
      id: serializer.fromJson<int>(json['id']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      enumber: serializer.fromJson<String>(json['enumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'enumber': serializer.toJson<String>(enumber),
    };
  }

  IngredientENumberRow copyWith({
    int? id,
    String? ingredientId,
    String? enumber,
  }) => IngredientENumberRow(
    id: id ?? this.id,
    ingredientId: ingredientId ?? this.ingredientId,
    enumber: enumber ?? this.enumber,
  );
  IngredientENumberRow copyWithCompanion(IngredientENumbersCompanion data) {
    return IngredientENumberRow(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      enumber: data.enumber.present ? data.enumber.value : this.enumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientENumberRow(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('enumber: $enumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ingredientId, enumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientENumberRow &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.enumber == this.enumber);
}

class IngredientENumbersCompanion
    extends UpdateCompanion<IngredientENumberRow> {
  final Value<int> id;
  final Value<String> ingredientId;
  final Value<String> enumber;
  const IngredientENumbersCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.enumber = const Value.absent(),
  });
  IngredientENumbersCompanion.insert({
    this.id = const Value.absent(),
    required String ingredientId,
    required String enumber,
  }) : ingredientId = Value(ingredientId),
       enumber = Value(enumber);
  static Insertable<IngredientENumberRow> custom({
    Expression<int>? id,
    Expression<String>? ingredientId,
    Expression<String>? enumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (enumber != null) 'enumber': enumber,
    });
  }

  IngredientENumbersCompanion copyWith({
    Value<int>? id,
    Value<String>? ingredientId,
    Value<String>? enumber,
  }) {
    return IngredientENumbersCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      enumber: enumber ?? this.enumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (enumber.present) {
      map['enumber'] = Variable<String>(enumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientENumbersCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('enumber: $enumber')
          ..write(')'))
        .toString();
  }
}

class $IngredientAlternativesTable extends IngredientAlternatives
    with TableInfo<$IngredientAlternativesTable, IngredientAlternativeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientAlternativesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id)',
    ),
  );
  static const VerificationMeta _alternativeMeta = const VerificationMeta(
    'alternative',
  );
  @override
  late final GeneratedColumn<String> alternative = GeneratedColumn<String>(
    'alternative',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ingredientId, alternative];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_alternatives';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientAlternativeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('alternative')) {
      context.handle(
        _alternativeMeta,
        alternative.isAcceptableOrUnknown(
          data['alternative']!,
          _alternativeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alternativeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientAlternativeRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientAlternativeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      alternative: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternative'],
      )!,
    );
  }

  @override
  $IngredientAlternativesTable createAlias(String alias) {
    return $IngredientAlternativesTable(attachedDatabase, alias);
  }
}

class IngredientAlternativeRow extends DataClass
    implements Insertable<IngredientAlternativeRow> {
  final int id;
  final String ingredientId;
  final String alternative;
  const IngredientAlternativeRow({
    required this.id,
    required this.ingredientId,
    required this.alternative,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['alternative'] = Variable<String>(alternative);
    return map;
  }

  IngredientAlternativesCompanion toCompanion(bool nullToAbsent) {
    return IngredientAlternativesCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      alternative: Value(alternative),
    );
  }

  factory IngredientAlternativeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientAlternativeRow(
      id: serializer.fromJson<int>(json['id']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      alternative: serializer.fromJson<String>(json['alternative']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'alternative': serializer.toJson<String>(alternative),
    };
  }

  IngredientAlternativeRow copyWith({
    int? id,
    String? ingredientId,
    String? alternative,
  }) => IngredientAlternativeRow(
    id: id ?? this.id,
    ingredientId: ingredientId ?? this.ingredientId,
    alternative: alternative ?? this.alternative,
  );
  IngredientAlternativeRow copyWithCompanion(
    IngredientAlternativesCompanion data,
  ) {
    return IngredientAlternativeRow(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      alternative: data.alternative.present
          ? data.alternative.value
          : this.alternative,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientAlternativeRow(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('alternative: $alternative')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ingredientId, alternative);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientAlternativeRow &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.alternative == this.alternative);
}

class IngredientAlternativesCompanion
    extends UpdateCompanion<IngredientAlternativeRow> {
  final Value<int> id;
  final Value<String> ingredientId;
  final Value<String> alternative;
  const IngredientAlternativesCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.alternative = const Value.absent(),
  });
  IngredientAlternativesCompanion.insert({
    this.id = const Value.absent(),
    required String ingredientId,
    required String alternative,
  }) : ingredientId = Value(ingredientId),
       alternative = Value(alternative);
  static Insertable<IngredientAlternativeRow> custom({
    Expression<int>? id,
    Expression<String>? ingredientId,
    Expression<String>? alternative,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (alternative != null) 'alternative': alternative,
    });
  }

  IngredientAlternativesCompanion copyWith({
    Value<int>? id,
    Value<String>? ingredientId,
    Value<String>? alternative,
  }) {
    return IngredientAlternativesCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      alternative: alternative ?? this.alternative,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (alternative.present) {
      map['alternative'] = Variable<String>(alternative.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientAlternativesCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('alternative: $alternative')
          ..write(')'))
        .toString();
  }
}

class $IngredientRegionRulesTable extends IngredientRegionRules
    with TableInfo<$IngredientRegionRulesTable, IngredientRegionRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientRegionRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id)',
    ),
  );
  static const VerificationMeta _regionCodeMeta = const VerificationMeta(
    'regionCode',
  );
  @override
  late final GeneratedColumn<String> regionCode = GeneratedColumn<String>(
    'region_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleMeta = const VerificationMeta('rule');
  @override
  late final GeneratedColumn<String> rule = GeneratedColumn<String>(
    'rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ingredientId, regionCode, rule];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_region_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientRegionRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('region_code')) {
      context.handle(
        _regionCodeMeta,
        regionCode.isAcceptableOrUnknown(data['region_code']!, _regionCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_regionCodeMeta);
    }
    if (data.containsKey('rule')) {
      context.handle(
        _ruleMeta,
        rule.isAcceptableOrUnknown(data['rule']!, _ruleMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientRegionRuleRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientRegionRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      regionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_code'],
      )!,
      rule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule'],
      )!,
    );
  }

  @override
  $IngredientRegionRulesTable createAlias(String alias) {
    return $IngredientRegionRulesTable(attachedDatabase, alias);
  }
}

class IngredientRegionRuleRow extends DataClass
    implements Insertable<IngredientRegionRuleRow> {
  final int id;
  final String ingredientId;
  final String regionCode;
  final String rule;
  const IngredientRegionRuleRow({
    required this.id,
    required this.ingredientId,
    required this.regionCode,
    required this.rule,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['region_code'] = Variable<String>(regionCode);
    map['rule'] = Variable<String>(rule);
    return map;
  }

  IngredientRegionRulesCompanion toCompanion(bool nullToAbsent) {
    return IngredientRegionRulesCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      regionCode: Value(regionCode),
      rule: Value(rule),
    );
  }

  factory IngredientRegionRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientRegionRuleRow(
      id: serializer.fromJson<int>(json['id']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      regionCode: serializer.fromJson<String>(json['regionCode']),
      rule: serializer.fromJson<String>(json['rule']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'regionCode': serializer.toJson<String>(regionCode),
      'rule': serializer.toJson<String>(rule),
    };
  }

  IngredientRegionRuleRow copyWith({
    int? id,
    String? ingredientId,
    String? regionCode,
    String? rule,
  }) => IngredientRegionRuleRow(
    id: id ?? this.id,
    ingredientId: ingredientId ?? this.ingredientId,
    regionCode: regionCode ?? this.regionCode,
    rule: rule ?? this.rule,
  );
  IngredientRegionRuleRow copyWithCompanion(
    IngredientRegionRulesCompanion data,
  ) {
    return IngredientRegionRuleRow(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      regionCode: data.regionCode.present
          ? data.regionCode.value
          : this.regionCode,
      rule: data.rule.present ? data.rule.value : this.rule,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientRegionRuleRow(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('regionCode: $regionCode, ')
          ..write('rule: $rule')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ingredientId, regionCode, rule);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientRegionRuleRow &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.regionCode == this.regionCode &&
          other.rule == this.rule);
}

class IngredientRegionRulesCompanion
    extends UpdateCompanion<IngredientRegionRuleRow> {
  final Value<int> id;
  final Value<String> ingredientId;
  final Value<String> regionCode;
  final Value<String> rule;
  const IngredientRegionRulesCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.regionCode = const Value.absent(),
    this.rule = const Value.absent(),
  });
  IngredientRegionRulesCompanion.insert({
    this.id = const Value.absent(),
    required String ingredientId,
    required String regionCode,
    required String rule,
  }) : ingredientId = Value(ingredientId),
       regionCode = Value(regionCode),
       rule = Value(rule);
  static Insertable<IngredientRegionRuleRow> custom({
    Expression<int>? id,
    Expression<String>? ingredientId,
    Expression<String>? regionCode,
    Expression<String>? rule,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (regionCode != null) 'region_code': regionCode,
      if (rule != null) 'rule': rule,
    });
  }

  IngredientRegionRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? ingredientId,
    Value<String>? regionCode,
    Value<String>? rule,
  }) {
    return IngredientRegionRulesCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      regionCode: regionCode ?? this.regionCode,
      rule: rule ?? this.rule,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (regionCode.present) {
      map['region_code'] = Variable<String>(regionCode.value);
    }
    if (rule.present) {
      map['rule'] = Variable<String>(rule.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientRegionRulesCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('regionCode: $regionCode, ')
          ..write('rule: $rule')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScanHistoryEntriesTable scanHistoryEntries =
      $ScanHistoryEntriesTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $IngredientAliasesTable ingredientAliases =
      $IngredientAliasesTable(this);
  late final $IngredientENumbersTable ingredientENumbers =
      $IngredientENumbersTable(this);
  late final $IngredientAlternativesTable ingredientAlternatives =
      $IngredientAlternativesTable(this);
  late final $IngredientRegionRulesTable ingredientRegionRules =
      $IngredientRegionRulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scanHistoryEntries,
    ingredients,
    ingredientAliases,
    ingredientENumbers,
    ingredientAlternatives,
    ingredientRegionRules,
  ];
}

typedef $$ScanHistoryEntriesTableCreateCompanionBuilder =
    ScanHistoryEntriesCompanion Function({
      required String id,
      required DateTime scannedAt,
      required String analysisJson,
      Value<String?> productName,
      Value<String?> barcode,
      Value<String?> thumbnailPath,
      Value<String?> fullImagePath,
      Value<bool> hasFullImage,
      Value<String> detectedIngredientsJson,
      Value<int> rowid,
    });
typedef $$ScanHistoryEntriesTableUpdateCompanionBuilder =
    ScanHistoryEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> scannedAt,
      Value<String> analysisJson,
      Value<String?> productName,
      Value<String?> barcode,
      Value<String?> thumbnailPath,
      Value<String?> fullImagePath,
      Value<bool> hasFullImage,
      Value<String> detectedIngredientsJson,
      Value<int> rowid,
    });

class $$ScanHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ScanHistoryEntriesTable> {
  $$ScanHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullImagePath => $composableBuilder(
    column: $table.fullImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasFullImage => $composableBuilder(
    column: $table.hasFullImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedIngredientsJson => $composableBuilder(
    column: $table.detectedIngredientsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanHistoryEntriesTable> {
  $$ScanHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullImagePath => $composableBuilder(
    column: $table.fullImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasFullImage => $composableBuilder(
    column: $table.hasFullImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedIngredientsJson => $composableBuilder(
    column: $table.detectedIngredientsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanHistoryEntriesTable> {
  $$ScanHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullImagePath => $composableBuilder(
    column: $table.fullImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasFullImage => $composableBuilder(
    column: $table.hasFullImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedIngredientsJson => $composableBuilder(
    column: $table.detectedIngredientsJson,
    builder: (column) => column,
  );
}

class $$ScanHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanHistoryEntriesTable,
          ScanHistoryEntry,
          $$ScanHistoryEntriesTableFilterComposer,
          $$ScanHistoryEntriesTableOrderingComposer,
          $$ScanHistoryEntriesTableAnnotationComposer,
          $$ScanHistoryEntriesTableCreateCompanionBuilder,
          $$ScanHistoryEntriesTableUpdateCompanionBuilder,
          (
            ScanHistoryEntry,
            BaseReferences<
              _$AppDatabase,
              $ScanHistoryEntriesTable,
              ScanHistoryEntry
            >,
          ),
          ScanHistoryEntry,
          PrefetchHooks Function()
        > {
  $$ScanHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $ScanHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanHistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
                Value<String> analysisJson = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> fullImagePath = const Value.absent(),
                Value<bool> hasFullImage = const Value.absent(),
                Value<String> detectedIngredientsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanHistoryEntriesCompanion(
                id: id,
                scannedAt: scannedAt,
                analysisJson: analysisJson,
                productName: productName,
                barcode: barcode,
                thumbnailPath: thumbnailPath,
                fullImagePath: fullImagePath,
                hasFullImage: hasFullImage,
                detectedIngredientsJson: detectedIngredientsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime scannedAt,
                required String analysisJson,
                Value<String?> productName = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> fullImagePath = const Value.absent(),
                Value<bool> hasFullImage = const Value.absent(),
                Value<String> detectedIngredientsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanHistoryEntriesCompanion.insert(
                id: id,
                scannedAt: scannedAt,
                analysisJson: analysisJson,
                productName: productName,
                barcode: barcode,
                thumbnailPath: thumbnailPath,
                fullImagePath: fullImagePath,
                hasFullImage: hasFullImage,
                detectedIngredientsJson: detectedIngredientsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanHistoryEntriesTable,
      ScanHistoryEntry,
      $$ScanHistoryEntriesTableFilterComposer,
      $$ScanHistoryEntriesTableOrderingComposer,
      $$ScanHistoryEntriesTableAnnotationComposer,
      $$ScanHistoryEntriesTableCreateCompanionBuilder,
      $$ScanHistoryEntriesTableUpdateCompanionBuilder,
      (
        ScanHistoryEntry,
        BaseReferences<
          _$AppDatabase,
          $ScanHistoryEntriesTable,
          ScanHistoryEntry
        >,
      ),
      ScanHistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      required String id,
      required String name,
      required int status,
      Value<String?> category,
      Value<String?> rationale,
      Value<String?> sourceUrl,
      Value<DateTime?> lastVerifiedAt,
      Value<double?> uncertainty,
      Value<bool?> processingAid,
      required String normalizedName,
      Value<int> rowid,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> status,
      Value<String?> category,
      Value<String?> rationale,
      Value<String?> sourceUrl,
      Value<DateTime?> lastVerifiedAt,
      Value<double?> uncertainty,
      Value<bool?> processingAid,
      Value<String> normalizedName,
      Value<int> rowid,
    });

final class $$IngredientsTableReferences
    extends BaseReferences<_$AppDatabase, $IngredientsTable, IngredientRow> {
  $$IngredientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IngredientAliasesTable, List<IngredientAliasRow>>
  _ingredientAliasesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ingredientAliases,
        aliasName: $_aliasNameGenerator(
          db.ingredients.id,
          db.ingredientAliases.ingredientId,
        ),
      );

  $$IngredientAliasesTableProcessedTableManager get ingredientAliasesRefs {
    final manager = $$IngredientAliasesTableTableManager(
      $_db,
      $_db.ingredientAliases,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ingredientAliasesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $IngredientENumbersTable,
    List<IngredientENumberRow>
  >
  _ingredientENumbersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ingredientENumbers,
        aliasName: $_aliasNameGenerator(
          db.ingredients.id,
          db.ingredientENumbers.ingredientId,
        ),
      );

  $$IngredientENumbersTableProcessedTableManager get ingredientENumbersRefs {
    final manager = $$IngredientENumbersTableTableManager(
      $_db,
      $_db.ingredientENumbers,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ingredientENumbersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $IngredientAlternativesTable,
    List<IngredientAlternativeRow>
  >
  _ingredientAlternativesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ingredientAlternatives,
        aliasName: $_aliasNameGenerator(
          db.ingredients.id,
          db.ingredientAlternatives.ingredientId,
        ),
      );

  $$IngredientAlternativesTableProcessedTableManager
  get ingredientAlternativesRefs {
    final manager = $$IngredientAlternativesTableTableManager(
      $_db,
      $_db.ingredientAlternatives,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ingredientAlternativesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $IngredientRegionRulesTable,
    List<IngredientRegionRuleRow>
  >
  _ingredientRegionRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ingredientRegionRules,
        aliasName: $_aliasNameGenerator(
          db.ingredients.id,
          db.ingredientRegionRules.ingredientId,
        ),
      );

  $$IngredientRegionRulesTableProcessedTableManager
  get ingredientRegionRulesRefs {
    final manager = $$IngredientRegionRulesTableTableManager(
      $_db,
      $_db.ingredientRegionRules,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ingredientRegionRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get uncertainty => $composableBuilder(
    column: $table.uncertainty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get processingAid => $composableBuilder(
    column: $table.processingAid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ingredientAliasesRefs(
    Expression<bool> Function($$IngredientAliasesTableFilterComposer f) f,
  ) {
    final $$IngredientAliasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingredientAliases,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientAliasesTableFilterComposer(
            $db: $db,
            $table: $db.ingredientAliases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ingredientENumbersRefs(
    Expression<bool> Function($$IngredientENumbersTableFilterComposer f) f,
  ) {
    final $$IngredientENumbersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingredientENumbers,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientENumbersTableFilterComposer(
            $db: $db,
            $table: $db.ingredientENumbers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ingredientAlternativesRefs(
    Expression<bool> Function($$IngredientAlternativesTableFilterComposer f) f,
  ) {
    final $$IngredientAlternativesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ingredientAlternatives,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientAlternativesTableFilterComposer(
                $db: $db,
                $table: $db.ingredientAlternatives,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> ingredientRegionRulesRefs(
    Expression<bool> Function($$IngredientRegionRulesTableFilterComposer f) f,
  ) {
    final $$IngredientRegionRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ingredientRegionRules,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientRegionRulesTableFilterComposer(
                $db: $db,
                $table: $db.ingredientRegionRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get uncertainty => $composableBuilder(
    column: $table.uncertainty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get processingAid => $composableBuilder(
    column: $table.processingAid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get rationale =>
      $composableBuilder(column: $table.rationale, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get uncertainty => $composableBuilder(
    column: $table.uncertainty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get processingAid => $composableBuilder(
    column: $table.processingAid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  Expression<T> ingredientAliasesRefs<T extends Object>(
    Expression<T> Function($$IngredientAliasesTableAnnotationComposer a) f,
  ) {
    final $$IngredientAliasesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ingredientAliases,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientAliasesTableAnnotationComposer(
                $db: $db,
                $table: $db.ingredientAliases,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ingredientENumbersRefs<T extends Object>(
    Expression<T> Function($$IngredientENumbersTableAnnotationComposer a) f,
  ) {
    final $$IngredientENumbersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ingredientENumbers,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientENumbersTableAnnotationComposer(
                $db: $db,
                $table: $db.ingredientENumbers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ingredientAlternativesRefs<T extends Object>(
    Expression<T> Function($$IngredientAlternativesTableAnnotationComposer a) f,
  ) {
    final $$IngredientAlternativesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ingredientAlternatives,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientAlternativesTableAnnotationComposer(
                $db: $db,
                $table: $db.ingredientAlternatives,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ingredientRegionRulesRefs<T extends Object>(
    Expression<T> Function($$IngredientRegionRulesTableAnnotationComposer a) f,
  ) {
    final $$IngredientRegionRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ingredientRegionRules,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientRegionRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.ingredientRegionRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          IngredientRow,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (IngredientRow, $$IngredientsTableReferences),
          IngredientRow,
          PrefetchHooks Function({
            bool ingredientAliasesRefs,
            bool ingredientENumbersRefs,
            bool ingredientAlternativesRefs,
            bool ingredientRegionRulesRefs,
          })
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> rationale = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<double?> uncertainty = const Value.absent(),
                Value<bool?> processingAid = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion(
                id: id,
                name: name,
                status: status,
                category: category,
                rationale: rationale,
                sourceUrl: sourceUrl,
                lastVerifiedAt: lastVerifiedAt,
                uncertainty: uncertainty,
                processingAid: processingAid,
                normalizedName: normalizedName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int status,
                Value<String?> category = const Value.absent(),
                Value<String?> rationale = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<double?> uncertainty = const Value.absent(),
                Value<bool?> processingAid = const Value.absent(),
                required String normalizedName,
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion.insert(
                id: id,
                name: name,
                status: status,
                category: category,
                rationale: rationale,
                sourceUrl: sourceUrl,
                lastVerifiedAt: lastVerifiedAt,
                uncertainty: uncertainty,
                processingAid: processingAid,
                normalizedName: normalizedName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ingredientAliasesRefs = false,
                ingredientENumbersRefs = false,
                ingredientAlternativesRefs = false,
                ingredientRegionRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ingredientAliasesRefs) db.ingredientAliases,
                    if (ingredientENumbersRefs) db.ingredientENumbers,
                    if (ingredientAlternativesRefs) db.ingredientAlternatives,
                    if (ingredientRegionRulesRefs) db.ingredientRegionRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ingredientAliasesRefs)
                        await $_getPrefetchedData<
                          IngredientRow,
                          $IngredientsTable,
                          IngredientAliasRow
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._ingredientAliasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientAliasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ingredientENumbersRefs)
                        await $_getPrefetchedData<
                          IngredientRow,
                          $IngredientsTable,
                          IngredientENumberRow
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._ingredientENumbersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientENumbersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ingredientAlternativesRefs)
                        await $_getPrefetchedData<
                          IngredientRow,
                          $IngredientsTable,
                          IngredientAlternativeRow
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._ingredientAlternativesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientAlternativesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ingredientRegionRulesRefs)
                        await $_getPrefetchedData<
                          IngredientRow,
                          $IngredientsTable,
                          IngredientRegionRuleRow
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._ingredientRegionRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientRegionRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      IngredientRow,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (IngredientRow, $$IngredientsTableReferences),
      IngredientRow,
      PrefetchHooks Function({
        bool ingredientAliasesRefs,
        bool ingredientENumbersRefs,
        bool ingredientAlternativesRefs,
        bool ingredientRegionRulesRefs,
      })
    >;
typedef $$IngredientAliasesTableCreateCompanionBuilder =
    IngredientAliasesCompanion Function({
      Value<int> id,
      required String ingredientId,
      required String alias,
      required String normalizedAlias,
    });
typedef $$IngredientAliasesTableUpdateCompanionBuilder =
    IngredientAliasesCompanion Function({
      Value<int> id,
      Value<String> ingredientId,
      Value<String> alias,
      Value<String> normalizedAlias,
    });

final class $$IngredientAliasesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IngredientAliasesTable,
          IngredientAliasRow
        > {
  $$IngredientAliasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        $_aliasNameGenerator(
          db.ingredientAliases.ingredientId,
          db.ingredients.id,
        ),
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IngredientAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientAliasesTable> {
  $$IngredientAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedAlias => $composableBuilder(
    column: $table.normalizedAlias,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientAliasesTable> {
  $$IngredientAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedAlias => $composableBuilder(
    column: $table.normalizedAlias,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientAliasesTable> {
  $$IngredientAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get normalizedAlias => $composableBuilder(
    column: $table.normalizedAlias,
    builder: (column) => column,
  );

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientAliasesTable,
          IngredientAliasRow,
          $$IngredientAliasesTableFilterComposer,
          $$IngredientAliasesTableOrderingComposer,
          $$IngredientAliasesTableAnnotationComposer,
          $$IngredientAliasesTableCreateCompanionBuilder,
          $$IngredientAliasesTableUpdateCompanionBuilder,
          (IngredientAliasRow, $$IngredientAliasesTableReferences),
          IngredientAliasRow,
          PrefetchHooks Function({bool ingredientId})
        > {
  $$IngredientAliasesTableTableManager(
    _$AppDatabase db,
    $IngredientAliasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientAliasesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<String> normalizedAlias = const Value.absent(),
              }) => IngredientAliasesCompanion(
                id: id,
                ingredientId: ingredientId,
                alias: alias,
                normalizedAlias: normalizedAlias,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ingredientId,
                required String alias,
                required String normalizedAlias,
              }) => IngredientAliasesCompanion.insert(
                id: id,
                ingredientId: ingredientId,
                alias: alias,
                normalizedAlias: normalizedAlias,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientAliasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ingredientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ingredientId,
                                referencedTable:
                                    $$IngredientAliasesTableReferences
                                        ._ingredientIdTable(db),
                                referencedColumn:
                                    $$IngredientAliasesTableReferences
                                        ._ingredientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IngredientAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientAliasesTable,
      IngredientAliasRow,
      $$IngredientAliasesTableFilterComposer,
      $$IngredientAliasesTableOrderingComposer,
      $$IngredientAliasesTableAnnotationComposer,
      $$IngredientAliasesTableCreateCompanionBuilder,
      $$IngredientAliasesTableUpdateCompanionBuilder,
      (IngredientAliasRow, $$IngredientAliasesTableReferences),
      IngredientAliasRow,
      PrefetchHooks Function({bool ingredientId})
    >;
typedef $$IngredientENumbersTableCreateCompanionBuilder =
    IngredientENumbersCompanion Function({
      Value<int> id,
      required String ingredientId,
      required String enumber,
    });
typedef $$IngredientENumbersTableUpdateCompanionBuilder =
    IngredientENumbersCompanion Function({
      Value<int> id,
      Value<String> ingredientId,
      Value<String> enumber,
    });

final class $$IngredientENumbersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IngredientENumbersTable,
          IngredientENumberRow
        > {
  $$IngredientENumbersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        $_aliasNameGenerator(
          db.ingredientENumbers.ingredientId,
          db.ingredients.id,
        ),
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IngredientENumbersTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientENumbersTable> {
  $$IngredientENumbersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enumber => $composableBuilder(
    column: $table.enumber,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientENumbersTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientENumbersTable> {
  $$IngredientENumbersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enumber => $composableBuilder(
    column: $table.enumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientENumbersTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientENumbersTable> {
  $$IngredientENumbersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get enumber =>
      $composableBuilder(column: $table.enumber, builder: (column) => column);

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientENumbersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientENumbersTable,
          IngredientENumberRow,
          $$IngredientENumbersTableFilterComposer,
          $$IngredientENumbersTableOrderingComposer,
          $$IngredientENumbersTableAnnotationComposer,
          $$IngredientENumbersTableCreateCompanionBuilder,
          $$IngredientENumbersTableUpdateCompanionBuilder,
          (IngredientENumberRow, $$IngredientENumbersTableReferences),
          IngredientENumberRow,
          PrefetchHooks Function({bool ingredientId})
        > {
  $$IngredientENumbersTableTableManager(
    _$AppDatabase db,
    $IngredientENumbersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientENumbersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientENumbersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientENumbersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<String> enumber = const Value.absent(),
              }) => IngredientENumbersCompanion(
                id: id,
                ingredientId: ingredientId,
                enumber: enumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ingredientId,
                required String enumber,
              }) => IngredientENumbersCompanion.insert(
                id: id,
                ingredientId: ingredientId,
                enumber: enumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientENumbersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ingredientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ingredientId,
                                referencedTable:
                                    $$IngredientENumbersTableReferences
                                        ._ingredientIdTable(db),
                                referencedColumn:
                                    $$IngredientENumbersTableReferences
                                        ._ingredientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IngredientENumbersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientENumbersTable,
      IngredientENumberRow,
      $$IngredientENumbersTableFilterComposer,
      $$IngredientENumbersTableOrderingComposer,
      $$IngredientENumbersTableAnnotationComposer,
      $$IngredientENumbersTableCreateCompanionBuilder,
      $$IngredientENumbersTableUpdateCompanionBuilder,
      (IngredientENumberRow, $$IngredientENumbersTableReferences),
      IngredientENumberRow,
      PrefetchHooks Function({bool ingredientId})
    >;
typedef $$IngredientAlternativesTableCreateCompanionBuilder =
    IngredientAlternativesCompanion Function({
      Value<int> id,
      required String ingredientId,
      required String alternative,
    });
typedef $$IngredientAlternativesTableUpdateCompanionBuilder =
    IngredientAlternativesCompanion Function({
      Value<int> id,
      Value<String> ingredientId,
      Value<String> alternative,
    });

final class $$IngredientAlternativesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IngredientAlternativesTable,
          IngredientAlternativeRow
        > {
  $$IngredientAlternativesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        $_aliasNameGenerator(
          db.ingredientAlternatives.ingredientId,
          db.ingredients.id,
        ),
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IngredientAlternativesTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientAlternativesTable> {
  $$IngredientAlternativesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternative => $composableBuilder(
    column: $table.alternative,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAlternativesTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientAlternativesTable> {
  $$IngredientAlternativesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternative => $composableBuilder(
    column: $table.alternative,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAlternativesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientAlternativesTable> {
  $$IngredientAlternativesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alternative => $composableBuilder(
    column: $table.alternative,
    builder: (column) => column,
  );

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAlternativesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientAlternativesTable,
          IngredientAlternativeRow,
          $$IngredientAlternativesTableFilterComposer,
          $$IngredientAlternativesTableOrderingComposer,
          $$IngredientAlternativesTableAnnotationComposer,
          $$IngredientAlternativesTableCreateCompanionBuilder,
          $$IngredientAlternativesTableUpdateCompanionBuilder,
          (IngredientAlternativeRow, $$IngredientAlternativesTableReferences),
          IngredientAlternativeRow,
          PrefetchHooks Function({bool ingredientId})
        > {
  $$IngredientAlternativesTableTableManager(
    _$AppDatabase db,
    $IngredientAlternativesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientAlternativesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IngredientAlternativesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IngredientAlternativesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<String> alternative = const Value.absent(),
              }) => IngredientAlternativesCompanion(
                id: id,
                ingredientId: ingredientId,
                alternative: alternative,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ingredientId,
                required String alternative,
              }) => IngredientAlternativesCompanion.insert(
                id: id,
                ingredientId: ingredientId,
                alternative: alternative,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientAlternativesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ingredientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ingredientId,
                                referencedTable:
                                    $$IngredientAlternativesTableReferences
                                        ._ingredientIdTable(db),
                                referencedColumn:
                                    $$IngredientAlternativesTableReferences
                                        ._ingredientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IngredientAlternativesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientAlternativesTable,
      IngredientAlternativeRow,
      $$IngredientAlternativesTableFilterComposer,
      $$IngredientAlternativesTableOrderingComposer,
      $$IngredientAlternativesTableAnnotationComposer,
      $$IngredientAlternativesTableCreateCompanionBuilder,
      $$IngredientAlternativesTableUpdateCompanionBuilder,
      (IngredientAlternativeRow, $$IngredientAlternativesTableReferences),
      IngredientAlternativeRow,
      PrefetchHooks Function({bool ingredientId})
    >;
typedef $$IngredientRegionRulesTableCreateCompanionBuilder =
    IngredientRegionRulesCompanion Function({
      Value<int> id,
      required String ingredientId,
      required String regionCode,
      required String rule,
    });
typedef $$IngredientRegionRulesTableUpdateCompanionBuilder =
    IngredientRegionRulesCompanion Function({
      Value<int> id,
      Value<String> ingredientId,
      Value<String> regionCode,
      Value<String> rule,
    });

final class $$IngredientRegionRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IngredientRegionRulesTable,
          IngredientRegionRuleRow
        > {
  $$IngredientRegionRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        $_aliasNameGenerator(
          db.ingredientRegionRules.ingredientId,
          db.ingredients.id,
        ),
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IngredientRegionRulesTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientRegionRulesTable> {
  $$IngredientRegionRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientRegionRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientRegionRulesTable> {
  $$IngredientRegionRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientRegionRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientRegionRulesTable> {
  $$IngredientRegionRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rule =>
      $composableBuilder(column: $table.rule, builder: (column) => column);

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientRegionRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientRegionRulesTable,
          IngredientRegionRuleRow,
          $$IngredientRegionRulesTableFilterComposer,
          $$IngredientRegionRulesTableOrderingComposer,
          $$IngredientRegionRulesTableAnnotationComposer,
          $$IngredientRegionRulesTableCreateCompanionBuilder,
          $$IngredientRegionRulesTableUpdateCompanionBuilder,
          (IngredientRegionRuleRow, $$IngredientRegionRulesTableReferences),
          IngredientRegionRuleRow,
          PrefetchHooks Function({bool ingredientId})
        > {
  $$IngredientRegionRulesTableTableManager(
    _$AppDatabase db,
    $IngredientRegionRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientRegionRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IngredientRegionRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IngredientRegionRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<String> regionCode = const Value.absent(),
                Value<String> rule = const Value.absent(),
              }) => IngredientRegionRulesCompanion(
                id: id,
                ingredientId: ingredientId,
                regionCode: regionCode,
                rule: rule,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ingredientId,
                required String regionCode,
                required String rule,
              }) => IngredientRegionRulesCompanion.insert(
                id: id,
                ingredientId: ingredientId,
                regionCode: regionCode,
                rule: rule,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientRegionRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ingredientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ingredientId,
                                referencedTable:
                                    $$IngredientRegionRulesTableReferences
                                        ._ingredientIdTable(db),
                                referencedColumn:
                                    $$IngredientRegionRulesTableReferences
                                        ._ingredientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IngredientRegionRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientRegionRulesTable,
      IngredientRegionRuleRow,
      $$IngredientRegionRulesTableFilterComposer,
      $$IngredientRegionRulesTableOrderingComposer,
      $$IngredientRegionRulesTableAnnotationComposer,
      $$IngredientRegionRulesTableCreateCompanionBuilder,
      $$IngredientRegionRulesTableUpdateCompanionBuilder,
      (IngredientRegionRuleRow, $$IngredientRegionRulesTableReferences),
      IngredientRegionRuleRow,
      PrefetchHooks Function({bool ingredientId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScanHistoryEntriesTableTableManager get scanHistoryEntries =>
      $$ScanHistoryEntriesTableTableManager(_db, _db.scanHistoryEntries);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$IngredientAliasesTableTableManager get ingredientAliases =>
      $$IngredientAliasesTableTableManager(_db, _db.ingredientAliases);
  $$IngredientENumbersTableTableManager get ingredientENumbers =>
      $$IngredientENumbersTableTableManager(_db, _db.ingredientENumbers);
  $$IngredientAlternativesTableTableManager get ingredientAlternatives =>
      $$IngredientAlternativesTableTableManager(
        _db,
        _db.ingredientAlternatives,
      );
  $$IngredientRegionRulesTableTableManager get ingredientRegionRules =>
      $$IngredientRegionRulesTableTableManager(_db, _db.ingredientRegionRules);
}
