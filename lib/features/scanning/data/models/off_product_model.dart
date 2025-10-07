import '../../domain/entities/off_product.dart';

class OffProductModel {
  const OffProductModel({
    required this.barcode,
    this.productName,
    this.imageUrl,
    this.lastUpdated,
    this.brands,
    this.ingredients,
    this.ingredientsText,
  });

  final String barcode;
  final String? productName;
  final String? imageUrl;
  final DateTime? lastUpdated;
  final String? brands;
  final List<String>? ingredients;
  final String? ingredientsText;

  factory OffProductModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final code = (json['code'] ?? product?['code'] ?? '').toString();
    final updatedTs = int.tryParse((product?['last_modified_t'] ?? '').toString());
    // Ingredients: prefer explicit ingredients_text (any language),
    // fallback to joining ingredients[].text.
    String? ingredientsText;
    if (product != null) {
      // Common fields: ingredients_text, ingredients_text_<lang>
      ingredientsText = product['ingredients_text']?.toString();
      if (ingredientsText == null || ingredientsText.trim().isEmpty) {
        // Try English/localized variants
        for (final key in product.keys) {
          if (key.startsWith('ingredients_text_')) {
            final val = product[key]?.toString();
            if (val != null && val.trim().isNotEmpty) {
              ingredientsText = val;
              break;
            }
          }
        }
      }
    }
    List<String>? ingredients;
    if ((ingredientsText == null || ingredientsText.trim().isEmpty) &&
        product?['ingredients'] is List) {
      final list = product?['ingredients'] as List<dynamic>;
      ingredients = list
          .map((e) => (e is Map<String, dynamic>)
              ? (e['text']?.toString() ?? '')
              : e.toString())
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
      if (ingredients.isNotEmpty) {
        ingredientsText = ingredients.join(', ');
      }
    } else if (ingredientsText != null) {
      // Split roughly on separators for a list
      ingredients = ingredientsText
          .split(RegExp(r'[\n,;•·]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return OffProductModel(
      barcode: code,
      productName: (product?['product_name'] ?? product?['generic_name'])?.toString(),
      imageUrl: (product?['image_small_url'] ?? product?['image_url'])?.toString(),
      lastUpdated: updatedTs != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedTs * 1000, isUtc: true)
          : null,
      brands: product?['brands']?.toString(),
      ingredients: ingredients,
      ingredientsText: ingredientsText,
    );
  }

  OffProduct toDomain() {
    return OffProduct(
      barcode: barcode,
      productName: productName,
      imageUrl: imageUrl,
      lastUpdated: lastUpdated,
      brands: brands,
      ingredients: ingredients,
      ingredientsText: ingredientsText,
    );
  }
}
