import 'package:equatable/equatable.dart';

import 'scanner_models.dart';

class OcrTextBlock extends Equatable {
  const OcrTextBlock({required this.text, this.languageCode, this.boundingBox});

  final String text;
  final String? languageCode;
  final OcrBoundingBox? boundingBox;

  @override
  List<Object?> get props => [text, languageCode, boundingBox];
}

class OcrBoundingBox extends Equatable {
  const OcrBoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  List<Object?> get props => [left, top, right, bottom];
}

class OcrResult extends Equatable {
  const OcrResult({
    required this.fullText,
    required this.blocks,
    required this.frame,
  });

  final String fullText;
  final List<OcrTextBlock> blocks;
  final ScannerFrame frame;

  @override
  List<Object?> get props => [fullText, blocks, frame];
}
