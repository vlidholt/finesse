import 'package:flutter/widgets.dart';

/// How the app's own chrome sets code: the docs' code blocks, the inline
/// `code` in their prose and the theme editor's exported snippet.
///
/// The face is JetBrains Mono, vendored in `example/fonts/` and declared in
/// the pubspec. It is named here and nowhere else, and it does not follow
/// the theme being edited: code stays in a mono face under every preset.
/// (The package has no mono text style — it bundles no fonts.)
///
/// ```dart
/// Text(source, style: CodeStyle.block.copyWith(color: ink));
/// ```
abstract final class CodeStyle {
  /// The font family of code.
  static const family = 'JetBrainsMono';

  /// A block of code: 13 points on an open line.
  static const block = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 1.6,
  );

  /// Code inside a sentence: the block's size, on the sentence's own line.
  static const inline = TextStyle(fontFamily: family, fontSize: 13);

  /// A snippet in a dialog: a size down, 12/18.
  static const compact = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 18 / 12,
  );
}
