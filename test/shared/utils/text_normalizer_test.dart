import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/shared/utils/text_normalizer.dart';

void main() {
  test('normalizes bullets, punctuation, and whitespace', () {
    const raw = 'INGREDIENTS:\n• MILK solids, sugar — cocoa (1%)';
    final norm = TextNormalizer.normalizeForIngredients(raw);
    // lowercased
    expect(norm.contains('milk solids'), isTrue);
    // bullets removed
    expect(norm.contains('•'), isFalse);
    // punctuation removed
    expect(norm.contains('('), isFalse);
    expect(norm.contains(')'), isFalse);
    // dashes normalized
    expect(norm.contains('—'), isFalse);
  });
}
