import 'dart:io';

import 'package:flutter/foundation.dart';

/// Describes the prompt template applied to Gemma variants.
class GemmaPrompt {
  const GemmaPrompt({
    required this.systemPrompt,
    required this.userContent,
    this.context,
  });

  final String systemPrompt;
  final String userContent;
  final String? context;

  String buildInput() {
    final buffer = StringBuffer()
      ..writeln(systemPrompt.trim())
      ..write(userContent.trim());
    if (context != null && context!.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('<context>')
        ..write(context!.trim())
        ..writeln()
        ..write('</context>');
    }
    return buffer.toString();
  }
}

/// Tokens produced by the tokenizer for an input prompt.
class TokenizedPrompt {
  const TokenizedPrompt({required this.inputIds, required this.prompt});

  final List<int> inputIds;
  final String prompt;
}

abstract class GemmaTokenizer {
  TokenizedPrompt tokenize(GemmaPrompt prompt);
  List<int> encode(String text);
  String decode(List<int> tokens);
}

/// Temporary placeholder until the SentencePiece tokenizer is wired in.
class PlaceholderGemmaTokenizer implements GemmaTokenizer {
  PlaceholderGemmaTokenizer(this.modelPath) {
    final file = File(modelPath);
    if (!file.existsSync()) {
      debugPrint(
        'PlaceholderGemmaTokenizer: tokenizer file missing at $modelPath. '
        'The placeholder tokenizer will still operate using ASCII splitting.',
      );
    }
  }

  final String modelPath;

  @override
  List<int> encode(String text) {
    // TODO(ai-phase-2): Replace with SentencePiece tokenizer output.
    return text.codeUnits;
  }

  @override
  String decode(List<int> tokens) {
    // TODO(ai-phase-2): Replace with SentencePiece tokenizer decode.
    return String.fromCharCodes(tokens);
  }

  @override
  TokenizedPrompt tokenize(GemmaPrompt prompt) {
    final input = prompt.buildInput();
    return TokenizedPrompt(inputIds: encode(input), prompt: input);
  }
}

/// Resolves the tokenizer artifact and returns a tokenizer implementation.
///
/// The `tokenizerPath` is resolved from the active model manifest. The path is
/// expected to point to a SentencePiece `.model` file once artifacts are
/// delivered alongside the TFLite model archives.
Future<GemmaTokenizer> createGemmaTokenizer(String tokenizerPath) async {
  // TODO(ai-phase-2): Switch to SentencePiece native binding (likely via a
  // MethodChannel or a Dart FFI bridge) once redistribution terms are finalised.
  return PlaceholderGemmaTokenizer(tokenizerPath);
}
