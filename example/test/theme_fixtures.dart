import 'package:example/common/theme_editor/editor_config.dart';
import 'package:una/una.dart';

/// The curated themes at the top of the customizer.
///
/// Each is a whole [ThemeEditorConfig] — style, palette, fonts, radius, glass
/// and menu options at once — chosen to look unlike the others and to hold
/// together in light and dark. `test/theme_presets_test.dart` checks the
/// contrast of every one of them in both.
enum ThemePreset {
  /// The package default, and the look the Demo app was designed in: soft
  /// blue glass, set in Geist.
  original('Original', ThemeEditorConfig()),

  /// The shadcn/ui look: compact Crisp in Graphite, opaque cards, Inter,
  /// and a bottom bar docked to the edge.
  classic(
    'Classic',
    ThemeEditorConfig(
      style: StylePreset.crisp,
      colors: ColorSchemes.graphite,
      fontTitle: 'Inter',
      bottomBarFloating: false,
    ),
  ),

  /// Soft and round: pill-shaped Pebble in Rose, on warm greys,
  /// the largest radius, Figtree under Outfit headings, and see-through
  /// menus.
  bloom(
    'Bloom',
    ThemeEditorConfig(
      style: StylePreset.pebble,
      colors: ColorSchemes.rose,
      fontTitle: 'Figtree',
      headingFontTitle: 'Outfit',
      radius: RadiusPreset.large,
      menuFinish: MenuSurfaceFinish.translucent,
    ),
  ),

  /// Sharp and editorial: square Sharp in deep green, monospaced body under
  /// serif headlines, inverted menus with a bold highlight, the focus ring
  /// drawn inside the control, and a docked bottom bar.
  press(
    'Press',
    ThemeEditorConfig(
      style: StylePreset.sharp,
      colors: ColorSchemes.forest,
      fontTitle: 'JetBrains Mono',
      headingFontTitle: 'Playfair Display',
      radius: RadiusPreset.none,
      focusRing: FocusRingPlacement.inside,
      bottomBarFloating: false,
      menuColor: MenuSurfaceColor.inverted,
      menuAccent: EditorMenuAccent.bold,
    ),
  ),

  /// Fluid's glass turned up: thinner cards and bars over a stronger
  /// blur, in Iris violet, set in Manrope.
  ///
  /// The one preset whose cards blur what is behind them. The package's
  /// styles leave that off — a card lies on the flat page, where a blur
  /// shows nothing and costs a backdrop filter per card per frame — and
  /// this is where the opt-in is shown: it is the preset to pick to see
  /// what card blur costs on a phone.
  frost(
    'Frost',
    ThemeEditorConfig(
      colors: ColorSchemes.iris,
      fontTitle: 'Manrope',
      cardOpacity: .7,
      cardBlur: true,
      barOpacity: .8,
      glassBlur: 32,
      menuFinish: MenuSurfaceFinish.translucent,
    ),
  );

  const ThemePreset(this.label, this.config);

  final String label;

  /// The configuration selecting this preset applies.
  final ThemeEditorConfig config;

  /// The preset [config] is showing, or null when it has been customised.
  ///
  /// Matched on the look alone: light or dark, the form factor and the text
  /// scale are how a theme is being *viewed*, and changing them does not
  /// make it a different one.
  static ThemePreset? of(ThemeEditorConfig config) {
    final look = config.look;
    for (final preset in values) {
      if (preset.config == look) return preset;
    }
    return null;
  }

  /// This preset's configuration, viewed the way [current] is being viewed.
  ThemeEditorConfig applyTo(ThemeEditorConfig current) => config.copyWith(
    brightness: current.brightness,
    formFactor: current.formFactor,
    textScale: current.textScale,
    liquidGlass: current.liquidGlass,
  );
}
