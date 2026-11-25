import 'package:finesse/src/icons/phosphor_duotone_icon.dart';
import 'package:finesse/src/icons/phosphor_icons_bold.dart';
import 'package:finesse/src/icons/phosphor_icons_duotone.dart';
import 'package:finesse/src/icons/phosphor_icons_fill.dart';
import 'package:finesse/src/icons/phosphor_icons_light.dart';
import 'package:finesse/src/icons/phosphor_icons_regular.dart';
import 'package:finesse/src/icons/phosphor_icons_thin.dart';
import 'package:flutter/widgets.dart';

/// Keeps one glyph of every bundled icon font in use, so that a release
/// build can shrink each font to the glyphs the app draws.
///
/// Flutter's icon tree-shaking subsets a font to the code points of the
/// `IconData` constants left in the compiled app. A font with **no**
/// constant left is not shrunk to nothing: it is skipped, and bundled
/// whole. finesse ships six Phosphor fonts of about half a megabyte each,
/// and an app that draws only regular icons therefore shipped the other
/// five complete — 2.6 MB of fonts it never uses, all of which a web build
/// downloads before its first frame.
///
/// `Theme` puts this widget above its child, and it holds one constant of
/// each family, so every font has at least one glyph in use and is cut
/// down to it (a kilobyte or two) unless the app uses more.
///
/// The glyphs are fields that [updateShouldNotify] reads, on purpose: a
/// constant that nothing reads is removed by the compiler before the fonts
/// are looked at.
class PhosphorFontAnchor extends InheritedWidget {
  /// Creates the anchor around [child], with one glyph of every font.
  ///
  /// Each glyph is passed where the anchor is built, not defaulted here and
  /// not gathered in a list: the tool that looks for the icon constants in
  /// use reads the expressions of the app's code, and looks neither at a
  /// parameter's default nor inside a constant list. Both were tried.
  const PhosphorFontAnchor({
    required super.child,
    required this.regular,
    required this.bold,
    required this.fill,
    required this.light,
    required this.thin,
    required this.duotone,
    super.key,
  });

  /// The anchor around [child], holding a glyph of each bundled font.
  factory PhosphorFontAnchor.all({required Widget child}) => PhosphorFontAnchor(
    regular: PhosphorIconsRegular.dot,
    bold: PhosphorIconsBold.dot,
    fill: PhosphorIconsFill.dot,
    light: PhosphorIconsLight.dot,
    thin: PhosphorIconsThin.dot,
    duotone: PhosphorIconsDuotone.dot,
    child: child,
  );

  /// A glyph of the regular font.
  final IconData regular;

  /// A glyph of the bold font.
  final IconData bold;

  /// A glyph of the fill font.
  final IconData fill;

  /// A glyph of the light font.
  final IconData light;

  /// A glyph of the thin font.
  final IconData thin;

  /// A glyph of the duotone font.
  final PhosphorDuotoneIconData duotone;

  @override
  bool updateShouldNotify(PhosphorFontAnchor oldWidget) =>
      !identical(regular, oldWidget.regular) ||
      !identical(bold, oldWidget.bold) ||
      !identical(fill, oldWidget.fill) ||
      !identical(light, oldWidget.light) ||
      !identical(thin, oldWidget.thin) ||
      !identical(duotone, oldWidget.duotone);
}
