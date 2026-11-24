/// The Phosphor icon set, bundled with finesse.
///
/// Six weights, each a class of `IconData` constants named after the icon:
/// `PhosphorIconsRegular`, `PhosphorIconsBold`, `PhosphorIconsFill`,
/// `PhosphorIconsLight`, `PhosphorIconsThin` and `PhosphorIconsDuotone`.
///
/// ```dart
/// const Icon(PhosphorIconsRegular.house)
/// const Icon(PhosphorIconsFill.house) // the selected state
/// ```
///
/// The fonts ship in this package (`fonts/phosphor/`), so no other
/// dependency is needed, and a release build keeps only the glyphs an app
/// uses.
///
/// Phosphor Icons are (c) 2020-2021 Phosphor Icons and MIT licensed; see this
/// package's LICENSE.
library;

export 'phosphor_duotone_icon.dart';
export 'phosphor_icons_bold.dart';
export 'phosphor_icons_duotone.dart';
export 'phosphor_icons_fill.dart';
export 'phosphor_icons_light.dart';
export 'phosphor_icons_regular.dart';
export 'phosphor_icons_thin.dart';
