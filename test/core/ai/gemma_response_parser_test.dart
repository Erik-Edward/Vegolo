import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/core/ai/gemma_response_parser.dart';
import 'package:vegolo/features/scanning/domain/entities/vegan_analysis.dart';

void main() {
  const parser = GemmaResponseParser();

  VeganAnalysis? parse(String raw) => parser.parse(raw);

  test('parses straightforward JSON payload', () {
    final result = parse(
      '{"isVegan": true, "confidence": 0.92, "flaggedIngredients": [], "alternatives": ["oat milk"]}',
    );

    expect(result, isNotNull);
    expect(result!.isVegan, isTrue);
    expect(result.confidence, closeTo(0.92, 1e-6));
    expect(result.flaggedIngredients, isEmpty);
    expect(result.alternatives, ['oat milk']);
  });

  test('handles fenced JSON with extra commentary', () {
    final raw = '''
Sure thing!
```json
{
  "isVegan": false,
  "confidence": 0.35,
  "flaggedIngredients": ["casein", "whey"],
  "alternatives": ["oat-based spread"]
}
```
Let me know if you need more context.
''';

    final result = parse(raw);

    expect(result, isNotNull);
    expect(result!.isVegan, isFalse);
    expect(result.confidence, closeTo(0.35, 1e-6));
    expect(result.flaggedIngredients, ['casein', 'whey']);
    expect(result.alternatives, ['oat-based spread']);
  });

  test('converts string booleans and numbers', () {
    final result = parse(
      '{"isVegan": "false", "confidence": "0.2", "flaggedIngredients": "gelatin, honey", "alternatives": "agar"}',
    );

    expect(result, isNotNull);
    expect(result!.isVegan, isFalse);
    expect(result.confidence, closeTo(0.2, 1e-6));
    expect(result.flaggedIngredients, ['gelatin', 'honey']);
    expect(result.alternatives, ['agar']);
  });

  test('returns null when mandatory fields are missing', () {
    final result = parse('{"confidence": 0.5}');
    expect(result, isNull);
  });

  test('returns null when JSON cannot be found', () {
    expect(parse('No JSON present'), isNull);
  });
}
