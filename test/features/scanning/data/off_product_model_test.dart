import 'package:flutter_test/flutter_test.dart';
import 'package:vegolo/features/scanning/data/models/off_product_model.dart';

void main() {
  test('parses OFF product json', () {
    final json = {
      'code': '1234567890123',
      'product': {
        'code': '1234567890123',
        'product_name': 'Vegan Snack',
        'brands': 'Veg Co',
        'image_small_url': 'https://images.off/small.jpg',
        'last_modified_t': 1700000000,
      },
      'status': 1,
    };

    final model = OffProductModel.fromJson(json);
    expect(model.barcode, '1234567890123');
    expect(model.productName, 'Vegan Snack');
    expect(model.imageUrl, isNotEmpty);
    expect(model.lastUpdated, isNotNull);
    final domain = model.toDomain();
    expect(domain.barcode, '1234567890123');
    expect(domain.productName, 'Vegan Snack');
  });
}
