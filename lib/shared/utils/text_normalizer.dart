class TextNormalizer {
  /// Light normalization for ingredient list matching.
  /// - Lowercases
  /// - Replaces bullets and various dashes with spaces
  /// - Removes most punctuation noise
  /// - Merges newlines into spaces
  /// - Collapses repeated whitespace
  static String normalizeForIngredients(String input) {
    var s = input;
    // Newlines and tabs -> space
    s = s.replaceAll(RegExp(r"[\r\n\t]+"), ' ');
    // Common bullets
    s = s.replaceAll(RegExp(r"[•·◦▪●]"), ' ');
    // Dashes
    s = s.replaceAll(RegExp(r"[–—−]"), ' ');
    // Punctuation to drop -> space (keep alnum and spaces only)
    s = s.replaceAll(RegExp(r"[^0-9a-zA-Z\s]"), ' ');
    // Collapse whitespace
    s = s.replaceAll(RegExp(r"\s+"), ' ');
    s = s.toLowerCase().trim();
    return s;
  }

  /// Normalizes a single line while preserving line boundaries.
  /// Intended for building richer detectedIngredients lists.
  static String normalizeLineForIngredients(String line) {
    var s = line;
    // Replace bullets and exotic dashes
    s = s.replaceAll(RegExp(r"[•·◦▪●]"), ' ');
    s = s.replaceAll(RegExp(r"[–—−]"), ' ');
    // Remove most punctuation except spaces and alnum
    s = s.replaceAll(RegExp(r"[^0-9a-zA-Z\s]"), ' ');
    // Collapse whitespace
    s = s.replaceAll(RegExp(r"\s+"), ' ');
    return s.toLowerCase().trim();
  }
}
