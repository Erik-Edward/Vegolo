class OffProduct {
  const OffProduct({
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
  final List<String>? ingredients; // tokenized/lines
  final String? ingredientsText; // raw text if provided
}
