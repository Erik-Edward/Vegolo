import 'package:equatable/equatable.dart';

enum VeganStatus { vegan, nonVegan, maybe }

class Ingredient extends Equatable {
  const Ingredient({
    required this.id,
    required this.name,
    required this.status,
    this.category,
    this.alternatives = const [],
    this.aliases = const [],
    this.enumbers = const [],
    this.regionRules = const {},
    this.rationale,
    this.sourceUrl,
    this.lastVerifiedAt,
    this.uncertainty,
    this.processingAid,
  });

  final String id;
  final String name;
  final VeganStatus status;
  final String? category;
  final List<String> alternatives;
  final List<String> aliases;
  final List<String> enumbers;
  final Map<String, String> regionRules;
  final String? rationale;
  final String? sourceUrl;
  final DateTime? lastVerifiedAt;
  final double? uncertainty;
  final bool? processingAid;

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    category,
    alternatives,
    aliases,
    enumbers,
    regionRules,
    rationale,
    sourceUrl,
    lastVerifiedAt,
    uncertainty,
    processingAid,
  ];
}
