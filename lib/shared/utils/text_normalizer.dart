class TextNormalizer {
  // Common headers for ingredients across several languages.
  // This is a non-exhaustive starter set we will expand over time.
  static final List<RegExp> _ingredientHeaderPatterns = [
    RegExp(r"^\s*ingredients?\s*:?", caseSensitive: false), // en
    RegExp(r"^\s*ingredientes?\s*:?", caseSensitive: false), // es/pt
    RegExp(r"^\s*ingr[ée]dients?\s*:?", caseSensitive: false), // fr
    RegExp(r"^\s*ingredienti\s*:?", caseSensitive: false), // it
    RegExp(r"^\s*zutaten\s*:?", caseSensitive: false), // de
    RegExp(r"^\s*ingrediënten\s*:?", caseSensitive: false), // nl
    RegExp(r"^\s*składniki\s*:?", caseSensitive: false), // pl
    RegExp(r"^\s*состав\s*:?") , // ru
    RegExp(r"^\s*összetevők\s*:?") , // hu
    RegExp(r"^\s*ingredienser\s*:?") , // sv/no/da
  ];

  // Heuristic stopping headers/phrases that usually indicate we've left
  // the ingredient section.
  static final List<RegExp> _sectionStopPatterns = [
    RegExp(r"^\s*nutrition|^\s*valeurs|^\s*valori|^\s*per\s+100\s*g", caseSensitive: false),
    RegExp(r"^\s*storage|^\s*keep\s+refrigerated|^\s*best\s+before", caseSensitive: false),
    RegExp(r"^\s*manufactur|^\s*packed\s+by|^\s*made\s+in", caseSensitive: false),
    RegExp(r"^\s*allergen|^\s*warning", caseSensitive: false),
  ];

  /// Extracts the most likely ingredient section from arbitrary packaging text.
  /// Fallbacks to the original text when no header is found.
  static String extractIngredientsText(String input) {
    if (input.trim().isEmpty) return input;
    final lines = input.split(RegExp(r"\r?\n+"));
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final l = line.toLowerCase();
      if (_ingredientHeaderPatterns.any((re) => re.hasMatch(l))) {
        start = i;
        break;
      }
    }
    if (start == -1) {
      // No explicit header; return whole text for now.
      return input;
    }

    final buffer = StringBuffer();
    for (int i = start; i < lines.length; i++) {
      var line = lines[i];
      final l = line.toLowerCase();
      // First line: trim everything up to the first ':' if present.
      if (i == start) {
        final idx = line.indexOf(':');
        if (idx != -1 && idx + 1 < line.length) {
          line = line.substring(idx + 1);
        }
      } else {
        // Stop when hitting a likely new section header.
        if (_sectionStopPatterns.any((re) => re.hasMatch(l))) {
          break;
        }
      }
      if (line.trim().isEmpty) continue;
      buffer.writeln(line.trim());
    }
    final rawSection = buffer.toString().trim();
    if (rawSection.isEmpty) return input;
    return rawSection;
  }

  /// Splits the extracted ingredient section into normalized, de-noised lines,
  /// merging visually wrapped rows.
  static List<String> extractIngredientLines(String input) {
    final section = extractIngredientsText(input);
    final rawLines = section.split(RegExp(r"\r?\n+"));
    final merged = <String>[];
    final current = StringBuffer();
    for (final raw in rawLines) {
      final line = normalizeLineForIngredients(raw);
      if (line.isEmpty) continue;
      // Heuristic: if line ends with comma/semicolon-like pause (after cleaning),
      // keep merging with next line; else, push and reset.
      current.write(line);
      if (line.endsWith(',')) {
        current.write(' ');
        continue;
      }
      merged.add(current.toString());
      current.clear();
    }
    if (current.isNotEmpty) {
      merged.add(current.toString());
    }
    // Drop lines that are obvious marketing copy remnants.
    final filtered = merged.where((l) {
      if (l.length < 3) return false;
      if (RegExp(r"^made with|^crafted|^tasty|^delicious", caseSensitive: false).hasMatch(l)) {
        return false;
      }
      return true;
    }).toList(growable: false);
    return filtered;
  }
  /// Light normalization for ingredient list matching.
  /// - Lowercases
  /// - Replaces bullets and various dashes with spaces
  /// - Removes most punctuation noise
  /// - Merges newlines into spaces
  /// - Collapses repeated whitespace
  static String normalizeForIngredients(String input) {
    // Prefer focusing on the ingredient section when present.
    var s = extractIngredientsText(input);
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
    s = s.toLowerCase().trim();
    return s;
  }
}
