import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:una/una.dart';

/// A selectable font, mirroring shadcn/ui's `FONT_DEFINITIONS`.
///
/// Every face is resolved through `google_fonts` at runtime: una bundles no
/// fonts, and neither does this app, which is why the list can be as long as
/// the original's without shipping any font assets.
///
/// Each font names its own `GoogleFonts` method ([builder]) and nothing
/// looks a family up by name. `GoogleFonts.getFont` and `GoogleFonts.asMap`
/// reach every one of the package's 1,700 families, so a single call to
/// either keeps all of them — their file names and hashes — in the compiled
/// app: 8.5 MB of the web build's 13 MB of JavaScript, before this was
/// changed, for twenty-six fonts.
@immutable
class EditorFont {
  const EditorFont({
    required this.title,
    required this.family,
    required this.builder,
    this.category = FontCategory.sans,
  });

  /// The display name, and the Google Fonts family name.
  final String title;

  /// The Google Fonts family name.
  final String family;

  /// The `GoogleFonts` method for this family, as a `FontBuilder`.
  ///
  /// A static tear-off, so it is the same object every time: `TextTheme`
  /// compares `googleFontBuilder` by identity, and theme equality is
  /// load-bearing (see CLAUDE.md).
  final FontBuilder builder;

  final FontCategory category;

  /// One text theme per family.
  static final _textThemes = <String, TextTheme>{};

  /// Builds the text theme for this font.
  TextTheme textTheme() =>
      _textThemes[family] ??= TextTheme.fromGoogleFont(builder);

  /// The regular face, for showing the font's own name in a picker.
  ///
  /// **Asking for it is what starts the download**: a `GoogleFonts` method
  /// begins fetching a face the moment it is called, whether or not anything
  /// is ever drawn with the result. So this must be called from the `build`
  /// of the row that shows it, never while assembling a list of options —
  /// that fetched all twenty-six families every time the panel opened.
  TextStyle previewStyle() => _previews[family] ??= builder();
  static final _previews = <String, TextStyle>{};

  /// The families [previewStyle] has been asked for so far, in order.
  @visibleForTesting
  static List<String> get debugPreviewedFamilies => _previews.keys.toList();

  /// Forgets which previews were requested, so a test can count its own.
  @visibleForTesting
  static void debugResetPreviews() => _previews.clear();

  /// The weights the text roles use. Fetching them up front means switching
  /// fonts reflows the text once, not once per weight as each arrives.
  static const _weights = [
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
  ];

  /// Fetches this font's faces and completes once they are registered.
  ///
  /// Completes normally when fetching fails or is disabled (offline, tests):
  /// the text then renders in the fallback face, which is the best there is.
  Future<void> load({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      for (final weight in _weights) {
        builder(fontWeight: weight);
      }
      // …and whatever else the text theme itself asks for: its blockquote
      // is italic, which no weight above covers. Building the theme is what
      // requests those faces; left out, the italic arrived after the font
      // had been applied and reflowed the page a second time.
      textTheme();
      await GoogleFonts.pendingFonts().timeout(timeout);
    } on Object {
      // Offline, blocked or runtime fetching disabled: keep the fallback.
    }
  }

  /// shadcn/ui's font list, in its order.
  static const all = <EditorFont>[
    EditorFont(
      title: 'Inter',
      family: 'Inter',
      builder: GoogleFonts.inter,
    ),
    EditorFont(
      title: 'Geist',
      family: 'Geist',
      builder: GoogleFonts.geist,
    ),
    EditorFont(
      title: 'Noto Sans',
      family: 'Noto Sans',
      builder: GoogleFonts.notoSans,
    ),
    EditorFont(
      title: 'Nunito Sans',
      family: 'Nunito Sans',
      builder: GoogleFonts.nunitoSans,
    ),
    EditorFont(
      title: 'Figtree',
      family: 'Figtree',
      builder: GoogleFonts.figtree,
    ),
    EditorFont(
      title: 'Roboto',
      family: 'Roboto',
      builder: GoogleFonts.roboto,
    ),
    EditorFont(
      title: 'Raleway',
      family: 'Raleway',
      builder: GoogleFonts.raleway,
    ),
    EditorFont(
      title: 'DM Sans',
      family: 'DM Sans',
      builder: GoogleFonts.dmSans,
    ),
    EditorFont(
      title: 'Public Sans',
      family: 'Public Sans',
      builder: GoogleFonts.publicSans,
    ),
    EditorFont(
      title: 'Outfit',
      family: 'Outfit',
      builder: GoogleFonts.outfit,
    ),
    EditorFont(
      title: 'Oxanium',
      family: 'Oxanium',
      builder: GoogleFonts.oxanium,
    ),
    EditorFont(
      title: 'Manrope',
      family: 'Manrope',
      builder: GoogleFonts.manrope,
    ),
    EditorFont(
      title: 'Space Grotesk',
      family: 'Space Grotesk',
      builder: GoogleFonts.spaceGrotesk,
    ),
    EditorFont(
      title: 'Montserrat',
      family: 'Montserrat',
      builder: GoogleFonts.montserrat,
    ),
    EditorFont(
      title: 'IBM Plex Sans',
      family: 'IBM Plex Sans',
      builder: GoogleFonts.ibmPlexSans,
    ),
    EditorFont(
      title: 'Source Sans 3',
      family: 'Source Sans 3',
      builder: GoogleFonts.sourceSans3,
    ),
    EditorFont(
      title: 'Instrument Sans',
      family: 'Instrument Sans',
      builder: GoogleFonts.instrumentSans,
    ),
    EditorFont(
      title: 'JetBrains Mono',
      family: 'JetBrains Mono',
      builder: GoogleFonts.jetBrainsMono,
      category: FontCategory.mono,
    ),
    EditorFont(
      title: 'Geist Mono',
      family: 'Geist Mono',
      builder: GoogleFonts.geistMono,
      category: FontCategory.mono,
    ),
    EditorFont(
      title: 'Noto Serif',
      family: 'Noto Serif',
      builder: GoogleFonts.notoSerif,
      category: FontCategory.serif,
    ),
    EditorFont(
      title: 'Roboto Slab',
      family: 'Roboto Slab',
      builder: GoogleFonts.robotoSlab,
      category: FontCategory.serif,
    ),
    EditorFont(
      title: 'Merriweather',
      family: 'Merriweather',
      builder: GoogleFonts.merriweather,
      category: FontCategory.serif,
    ),
    EditorFont(
      title: 'Lora',
      family: 'Lora',
      builder: GoogleFonts.lora,
      category: FontCategory.serif,
    ),
    EditorFont(
      title: 'Playfair Display',
      family: 'Playfair Display',
      builder: GoogleFonts.playfairDisplay,
      category: FontCategory.serif,
    ),
    EditorFont(
      title: 'EB Garamond',
      family: 'EB Garamond',
      builder: GoogleFonts.ebGaramond,
      category: FontCategory.serif,
    ),
    EditorFont(
      title: 'Instrument Serif',
      family: 'Instrument Serif',
      builder: GoogleFonts.instrumentSerif,
      category: FontCategory.serif,
    ),
  ];

  static EditorFont byTitle(String title) =>
      all.firstWhere((f) => f.title == title, orElse: () => all.first);

  @override
  bool operator ==(Object other) => other is EditorFont && other.title == title;

  @override
  int get hashCode => title.hashCode;
}

enum FontCategory { sans, serif, mono }
