import 'package:example/common/theme_editor/color_tokens.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/common/theme_editor/style_field.dart';
import 'package:example/common/theme_editor/style_fields.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The colour options the editor offers: the six built-in schemes, and
/// more made from a seed colour with `ColorScheme.fromSeed`, which builds
/// them on the same ladder of lightness.
enum ColorPalette {
  ocean('Ocean', scheme: ColorSchemes.ocean),
  graphite('Graphite', scheme: ColorSchemes.graphite),
  forest('Forest', scheme: ColorSchemes.forest),
  iris('Iris', scheme: ColorSchemes.iris),
  ember('Ember', scheme: ColorSchemes.ember),
  rose('Rose', scheme: ColorSchemes.rose),
  sky('Sky', seed: Color(0xFF0EA5E9)),
  cyan('Lagoon', seed: Color(0xFF0891B2)),
  teal('Teal', seed: Color(0xFF0D9488)),
  emerald('Emerald', seed: Color(0xFF059669)),
  moss('Moss', seed: Color(0xFF65A30D)),
  gold('Gold', seed: Color(0xFFCA8A04)),
  amber('Amber', seed: Color(0xFFD97706)),
  coral('Coral', seed: Color(0xFFF2643C)),
  crimson('Crimson', seed: Color(0xFFDC2626)),
  berry('Berry', seed: Color(0xFFDB2777)),
  orchid('Orchid', seed: Color(0xFFC026D3)),
  violet('Violet', seed: Color(0xFF7C3AED)),
  indigo('Indigo', seed: Color(0xFF4F46E5)),
  slate('Slate', seed: Color(0xFF64748B)),
  sand('Sand', seed: Color(0xFF8A8178));

  const ColorPalette(this.label, {this.scheme, this.seed});

  final String label;

  /// The built-in scheme, for the first six.
  final ColorSchemes? scheme;

  /// The seed, for the rest.
  final Color? seed;

  /// The palette [config] is on, or null for a seed picked by hand.
  static ColorPalette? of(ThemeEditorConfig config) {
    for (final palette in values) {
      if (palette.seed == config.seed &&
          (palette.seed != null || palette.scheme == config.colors)) {
        return palette;
      }
    }
    return null;
  }

  /// [config] on this palette, with no colour picked by hand.
  ThemeEditorConfig applyTo(ThemeEditorConfig config) => config.copyWith(
    colors: scheme ?? config.colors,
    seed: () => seed,
    lightColors: const ColorEdits(),
    darkColors: const ColorEdits(),
  );

  /// The dot shown for it: its light primary — or, for a monochrome one,
  /// its dark primary, which reads on the panel's dark surface.
  Color get swatch {
    final light = seed != null ? ColorScheme.fromSeed(seed!) : scheme!.light;
    final dark = seed != null
        ? ColorScheme.fromSeed(seed!, brightness: Brightness.dark)
        : scheme!.dark;
    return light.primary == light.foreground ? dark.primary : light.primary;
  }
}

/// The radius presets. [style] follows the selected style's own radius —
/// 10 for Fluid — which is what the package does when no radius is given.
/// The others are shadcn/ui's `--radius` presets; components use
/// `--radius-md`, which is `--radius * 0.8`.
enum RadiusPreset {
  style('Default', null),
  none('None', 0),
  small('Small', 7.2 * 0.8),
  medium('Medium', 10 * 0.8),
  large('Large', 14 * 0.8);

  const RadiusPreset(this.label, this.value);

  final String label;

  /// The `md` radius in logical pixels, or null to use the style's.
  final double? value;
}

/// The package's four styles: Fluid, its own, and Crisp, Pebble and
/// Sharp, made from shadcn/ui's.
///
/// Each is a preset over [StyleTokens] — corner radii, focus-ring
/// thickness and opacity, and label typography — so picking one reshapes every
/// component at once.
enum StylePreset {
  fluid('Fluid'),
  crisp('Crisp'),
  pebble('Pebble'),
  sharp('Sharp');

  const StylePreset(this.label);

  final String label;

  StyleTokens get tokens => StyleTokens.fromName(name);
}

/// The menu surface colour, mirroring shadcn's `menuColor` "Default/Inverted".
enum MenuSurfaceColor {
  standard('Default'),
  inverted('Inverted');

  const MenuSurfaceColor(this.label);

  final String label;
}

/// The menu surface finish: shadcn's "Solid/Translucent", after the option
/// to leave it to the style — glass in Una, solid in the shadcn styles.
enum MenuSurfaceFinish {
  style('Style'),
  solid('Solid'),
  translucent('Translucent');

  const MenuSurfaceFinish(this.label);

  final String label;
}

/// How strongly a menu highlights its selected item.
enum EditorMenuAccent {
  subtle('Subtle'),
  bold('Bold');

  const EditorMenuAccent(this.label);

  final String label;
}

/// Where a focused control draws its ring.
///
/// [outside] is the package default: a ring around the control. [inside]
/// is `ThemeData(disableSecondaryBorder: true)`, which recolours the
/// control's own border instead — the look for dense layouts where an
/// outward ring would overlap the neighbours.
enum FocusRingPlacement {
  outside('Outside'),
  inside('Inside');

  const FocusRingPlacement(this.label);

  final String label;
}

/// How much room the components take: a named step on the spacing scale.
///
/// Every metric a style writes in spacing units — control heights, paddings,
/// gaps — is a multiple of `Spacing.step`, so this one number makes the whole
/// UI denser or roomier.
enum Density {
  compact('Compact', 3.5),
  normal('Default', 4),
  comfortable('Comfortable', 4.5),
  spacious('Spacious', 5);

  const Density(this.label, this.step);

  final String label;

  /// `Spacing.step`, in logical pixels.
  final double step;
}

/// Which of a style's two sets of metrics the app is laid out with.
/// Where the app draws with Liquid Glass. A preview setting: it lets the
/// glass be seen on any platform, where `auto` shows it on Apple ones only.
enum EditorLiquidGlass {
  /// Liquid Glass on iOS and macOS, frosted glass elsewhere: the package's
  /// default.
  auto('Auto', LiquidGlassMode.auto),

  /// Liquid Glass on every platform.
  on('On', LiquidGlassMode.always),

  /// una's frosted glass on every platform.
  off('Off', LiquidGlassMode.never);

  const EditorLiquidGlass(this.label, this.mode);

  final String label;

  final LiquidGlassMode mode;
}

enum EditorFormFactor {
  /// Follow the width the page has, as `UnaApp` does by itself.
  auto('Auto', null),

  /// The desktop layout, whatever the width.
  desktop('Desktop', FormFactor.desktop),

  /// The phone layout, whatever the width.
  mobile('Mobile', FormFactor.mobile);

  const EditorFormFactor(this.label, this.forced);

  final String label;

  /// The form factor to pin, or null to follow the width.
  final FormFactor? forced;

  /// The form factor for a page [pageWidth] wide, where anything narrower
  /// than [breakpoint] is a phone.
  FormFactor resolve(double pageWidth, {required double breakpoint}) =>
      forced ??
      (pageWidth < breakpoint ? FormFactor.mobile : FormFactor.desktop);
}

/// Everything the editor configures, and the [ThemeData] it produces.
///
/// Three kinds of fields:
///
/// * the **look** — style, colours, fonts, radius, the glass and layout
///   overrides, the menu options. A `ThemePreset` is a set of these, and
///   [toDartSnippet] exports them;
/// * the **preview** — [formFactor] and [textScale], which belong to the
///   device rather than to the theme;
/// * [brightness], which `App` sets itself: it builds this configuration
///   twice, once per brightness.
@immutable
class ThemeEditorConfig {
  const ThemeEditorConfig({
    this.brightness = Brightness.light,
    this.style = StylePreset.fluid,
    this.colors = ColorSchemes.ocean,
    this.seed,
    this.lightColors = const ColorEdits(),
    this.darkColors = const ColorEdits(),
    this.styleEdits = const StyleEdits(),
    this.mobileStyleEdits = const StyleEdits(),
    this.headingFontTitle,
    this.fontTitle = 'Geist',
    this.radius = RadiusPreset.style,
    this.customRadius,
    this.focusRing = FocusRingPlacement.outside,
    this.cardOpacity,
    this.cardBlur,
    this.barOpacity,
    this.glassBlur,
    this.density = Density.normal,
    this.pageMarginScale = 1,
    this.cardPaddingScale = 1,
    this.bottomBarFloating,
    this.menuColor = MenuSurfaceColor.standard,
    this.menuFinish = MenuSurfaceFinish.style,
    this.menuAccent = EditorMenuAccent.subtle,
    this.formFactor = EditorFormFactor.auto,
    this.textScale = 1,
    this.liquidGlass = EditorLiquidGlass.auto,
  });

  final Brightness brightness;
  final StylePreset style;

  /// The colour theme every colour starts from.
  final ColorSchemes colors;

  /// A seed colour the scheme is made from (`ColorScheme.fromSeed`); when
  /// set it stands in for [colors].
  final Color? seed;

  /// The colours picked by hand in light mode, and in dark. A colour picked
  /// in one only is carried over to the other (see [applyColorEdits]).
  final ColorEdits lightColors;
  final ColorEdits darkColors;

  /// Style fields set by hand in "All settings": on the desktop metrics
  /// (and the phone's, where the two share the value), and on the phone's
  /// alone. Applied over the quick controls above them.
  final StyleEdits styleEdits;
  final StyleEdits mobileStyleEdits;

  /// Null means "same as body", shadcn's `fontHeading: "inherit"`.
  final String? headingFontTitle;
  final String fontTitle;

  final RadiusPreset radius;
  final double? customRadius;

  final FocusRingPlacement focusRing;

  /// The opacity of a card's fill, in both brightnesses. Null keeps the
  /// style's own, which may differ between light and dark.
  final double? cardOpacity;

  /// Whether a translucent card blurs what is behind it. Null keeps the
  /// style's own.
  final bool? cardBlur;

  /// The opacity of the app and navigation bars, in both brightnesses. Null
  /// keeps the style's own.
  final double? barOpacity;

  /// The backdrop blur sigma behind glass surfaces, bars and blurred cards.
  /// Null keeps the style's own.
  final double? glassBlur;

  final Density density;

  /// Multiplies the style's page margins — each form factor's own, so 1.5
  /// turns 24 into 36 on a desktop and 16 into 24 on a phone.
  final double pageMarginScale;

  /// Multiplies the style's card padding, per form factor like
  /// [pageMarginScale].
  final double cardPaddingScale;

  /// Whether the phone's bottom navigation bar floats as a pill. Null keeps
  /// the style's own.
  final bool? bottomBarFloating;

  final MenuSurfaceColor menuColor;
  final MenuSurfaceFinish menuFinish;
  final EditorMenuAccent menuAccent;

  /// Preview only: which layout the app shows.
  final EditorFormFactor formFactor;

  /// Preview only: the platform text scale the app is shown at.
  final double textScale;

  /// Preview: where the app draws with Liquid Glass. Kept across presets,
  /// like the other preview settings, but exported when it is not `auto`:
  /// it is a theme setting an app can make too.
  final EditorLiquidGlass liquidGlass;

  /// The `md` radius in logical pixels: a custom value, the preset's, or the
  /// selected style's own.
  double get effectiveRadius =>
      customRadius ?? radius.value ?? style.tokens.radius;

  /// Whether the radius is the style's own, so [build] leaves it to the
  /// package and the exported snippet does not mention it.
  bool get usesStyleRadius => customRadius == null && radius.value == null;

  Spacing get spacing => Spacing(step: density.step);

  EditorFont get font => EditorFont.byTitle(fontTitle);

  EditorFont? get headingFont =>
      headingFontTitle == null ? null : EditorFont.byTitle(headingFontTitle!);

  /// Every font this configuration renders with, for loading them before it
  /// is applied.
  Set<EditorFont> get fonts => {font, ?headingFont};

  // --- What the glass and layout controls show ----------------------------
  //
  // An override that is null shows the style's own value. For the opacities
  // that is the light one: the panel does not know which brightness the app
  // is showing, and the two are close.

  double get effectiveCardOpacity => cardOpacity ?? style.tokens.cardOpacity;

  bool get effectiveCardBlur => cardBlur ?? style.tokens.cardBlur;

  /// Whether a card lets anything through in either brightness. An opaque
  /// card has nothing to blur, so the blur switch is locked while this is
  /// false.
  bool get cardsAreTranslucent {
    final tokens = style.tokens;
    return cardOpacity != null
        ? cardOpacity! < 1
        : tokens.cardOpacity < 1 ||
              (tokens.cardOpacityDark ?? tokens.cardOpacity) < 1;
  }

  double get effectiveBarOpacity => barOpacity ?? style.tokens.barOpacity;

  double get effectiveGlassBlur => glassBlur ?? style.tokens.glassBlur;

  bool get effectiveBottomBarFloating =>
      bottomBarFloating ?? style.tokens.bottomNavigationFloating;

  /// [ValueGetter]s for the nullable overrides, so that `() => null` can
  /// clear one: a plain nullable parameter cannot tell "leave it" from
  /// "reset it".
  ThemeEditorConfig copyWith({
    Brightness? brightness,
    StylePreset? style,
    ColorSchemes? colors,
    ValueGetter<Color?>? seed,
    ColorEdits? lightColors,
    ColorEdits? darkColors,
    StyleEdits? styleEdits,
    StyleEdits? mobileStyleEdits,
    String? headingFontTitle,
    bool clearHeadingFont = false,
    String? fontTitle,
    RadiusPreset? radius,
    double? customRadius,
    bool clearCustomRadius = false,
    FocusRingPlacement? focusRing,
    ValueGetter<double?>? cardOpacity,
    ValueGetter<bool?>? cardBlur,
    ValueGetter<double?>? barOpacity,
    ValueGetter<double?>? glassBlur,
    Density? density,
    double? pageMarginScale,
    double? cardPaddingScale,
    ValueGetter<bool?>? bottomBarFloating,
    MenuSurfaceColor? menuColor,
    MenuSurfaceFinish? menuFinish,
    EditorMenuAccent? menuAccent,
    EditorFormFactor? formFactor,
    double? textScale,
    EditorLiquidGlass? liquidGlass,
  }) {
    return ThemeEditorConfig(
      brightness: brightness ?? this.brightness,
      style: style ?? this.style,
      colors: colors ?? this.colors,
      seed: seed == null ? this.seed : seed(),
      lightColors: lightColors ?? this.lightColors,
      darkColors: darkColors ?? this.darkColors,
      styleEdits: styleEdits ?? this.styleEdits,
      mobileStyleEdits: mobileStyleEdits ?? this.mobileStyleEdits,
      headingFontTitle: clearHeadingFont
          ? null
          : (headingFontTitle ?? this.headingFontTitle),
      fontTitle: fontTitle ?? this.fontTitle,
      radius: radius ?? this.radius,
      customRadius: clearCustomRadius
          ? null
          : (customRadius ?? this.customRadius),
      focusRing: focusRing ?? this.focusRing,
      cardOpacity: cardOpacity == null ? this.cardOpacity : cardOpacity(),
      cardBlur: cardBlur == null ? this.cardBlur : cardBlur(),
      barOpacity: barOpacity == null ? this.barOpacity : barOpacity(),
      glassBlur: glassBlur == null ? this.glassBlur : glassBlur(),
      density: density ?? this.density,
      pageMarginScale: pageMarginScale ?? this.pageMarginScale,
      cardPaddingScale: cardPaddingScale ?? this.cardPaddingScale,
      bottomBarFloating: bottomBarFloating == null
          ? this.bottomBarFloating
          : bottomBarFloating(),
      menuColor: menuColor ?? this.menuColor,
      menuFinish: menuFinish ?? this.menuFinish,
      menuAccent: menuAccent ?? this.menuAccent,
      formFactor: formFactor ?? this.formFactor,
      textScale: textScale ?? this.textScale,
      liquidGlass: liquidGlass ?? this.liquidGlass,
    );
  }

  /// This configuration with everything that is not part of the look —
  /// [brightness] and the two preview fields — set to its default.
  ///
  /// Two configurations with the same [look] are the same *theme*, however
  /// they are being viewed: this is what a preset is matched against.
  ThemeEditorConfig get look => copyWith(
    brightness: Brightness.light,
    formFactor: EditorFormFactor.auto,
    textScale: 1,
    liquidGlass: EditorLiquidGlass.auto,
  );

  /// A value type, so a no-op edit — re-picking the option that is already
  /// selected, a slider settling on the value it started from — does not
  /// notify the config signal and rebuild the whole app for nothing.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeEditorConfig &&
        other.brightness == brightness &&
        other.style == style &&
        other.colors == colors &&
        other.seed == seed &&
        other.lightColors == lightColors &&
        other.darkColors == darkColors &&
        other.styleEdits == styleEdits &&
        other.mobileStyleEdits == mobileStyleEdits &&
        other.headingFontTitle == headingFontTitle &&
        other.fontTitle == fontTitle &&
        other.radius == radius &&
        other.customRadius == customRadius &&
        other.focusRing == focusRing &&
        other.cardOpacity == cardOpacity &&
        other.cardBlur == cardBlur &&
        other.barOpacity == barOpacity &&
        other.glassBlur == glassBlur &&
        other.density == density &&
        other.pageMarginScale == pageMarginScale &&
        other.cardPaddingScale == cardPaddingScale &&
        other.bottomBarFloating == bottomBarFloating &&
        other.menuColor == menuColor &&
        other.menuFinish == menuFinish &&
        other.menuAccent == menuAccent &&
        other.formFactor == formFactor &&
        other.textScale == textScale &&
        other.liquidGlass == liquidGlass;
  }

  @override
  int get hashCode => Object.hashAll([
    brightness,
    style,
    colors,
    seed,
    lightColors,
    darkColors,
    styleEdits,
    mobileStyleEdits,
    headingFontTitle,
    fontTitle,
    radius,
    customRadius,
    focusRing,
    cardOpacity,
    cardBlur,
    barOpacity,
    glassBlur,
    density,
    pageMarginScale,
    cardPaddingScale,
    bottomBarFloating,
    menuColor,
    menuFinish,
    menuAccent,
    formFactor,
    textScale,
    liquidGlass,
  ]);

  /// The palette, fully resolved for [brightness]: the colour theme, then
  /// the colours picked by hand.
  ColorScheme get colorScheme => _scheme(brightness);

  ColorScheme _scheme(Brightness b) {
    final dark = b == Brightness.dark;
    final key = (colors, seed, lightColors, darkColors, dark);
    final cached = _schemes[key];
    if (cached != null) return cached;
    if (_schemes.length >= _maxCachedStyles) {
      _schemes.remove(_schemes.keys.first);
    }
    return _schemes[key] = applyColorEdits(
      base: baseScheme(b),
      otherBase: baseScheme(dark ? Brightness.light : Brightness.dark),
      own: dark ? darkColors : lightColors,
      other: dark ? lightColors : darkColors,
    );
  }

  static final _schemes =
      <(ColorSchemes, Color?, ColorEdits, ColorEdits, bool), ColorScheme>{};

  /// The scheme before any colour picked by hand: the seed's, or the
  /// colour theme's.
  ColorScheme baseScheme(Brightness b) => seed != null
      ? _seeded[(seed!, b)] ??= ColorScheme.fromSeed(seed!, brightness: b)
      : colors.of(b);

  static final _seeded = <(Color, Brightness), ColorScheme>{};

  /// The colour picked by hand for [token] in [b], or null.
  ColorEdits colorEditsFor(Brightness b) =>
      b == Brightness.dark ? darkColors : lightColors;

  /// Where [token]'s colour in [b] comes from.
  ColorSource colorSource(ColorToken token, Brightness b) {
    final dark = b == Brightness.dark;
    if ((dark ? darkColors : lightColors)[token.name] != null) {
      return ColorSource.pinned;
    }
    if ((dark ? lightColors : darkColors)[token.name] != null) {
      return ColorSource.derived;
    }
    return ColorSource.scheme;
  }

  /// This configuration with [token] set to [color] in [b], or handed back
  /// to the scheme (and to the other brightness) with null.
  ///
  /// A colour equal to the one the token has without it is no edit at all:
  /// picking the original back leaves the token as it was.
  ThemeEditorConfig withColor(ColorToken token, Brightness b, Color? color) {
    ThemeEditorConfig set(Color? value) => b == Brightness.dark
        ? copyWith(darkColors: darkColors.withColor(token.name, value))
        : copyWith(lightColors: lightColors.withColor(token.name, value));
    final without = set(null);
    if (color == null) return without;
    final original = token.read(without._scheme(b));
    return color == original ? without : set(color);
  }

  /// The style tokens [formFactor] is laid out with.
  StyleTokens tokensFor(FormFactor formFactor) {
    final tokens = styleTokens;
    return formFactor == FormFactor.mobile
        ? tokens.forFormFactor(FormFactor.mobile)
        : tokens;
  }

  /// Whether [field] was set by hand for [formFactor].
  bool styleEdited(StyleField field, FormFactor formFactor) =>
      formFactor == FormFactor.mobile
      ? mobileStyleEdits[field.name] != null ||
            (styleEdits[field.name] != null && _shared(field))
      : styleEdits[field.name] != null;

  /// Whether [field] has one value on both of the style's token sets, so a
  /// desktop edit carries to the phone.
  bool _shared(StyleField field) {
    final base = style.tokens;
    final a = field.read(base);
    final b = field.read(base.forFormFactor(FormFactor.mobile));
    return a is List && b is List ? listEquals(a, b) : a == b;
  }

  /// This configuration with [field] set to [value] for [formFactor], or
  /// handed back with null. On the desktop a field the phone shares is set
  /// for both, as `StyleTokens.copyWith` does; on the phone only there.
  ThemeEditorConfig withStyleValue(
    StyleField field,
    FormFactor formFactor,
    Object? value,
  ) {
    if (value != null) {
      // The value it has without this edit is no edit at all: setting a
      // field back to the original leaves it as it was.
      final without = withStyleValue(field, formFactor, null);
      final original = field.read(without.tokensFor(formFactor));
      final same = value is List && original is List
          ? listEquals(value, original)
          : value == original;
      if (same) return without;
    }
    if (formFactor == FormFactor.desktop) {
      return copyWith(styleEdits: styleEdits.withValue(field.name, value));
    }
    if (value == null) {
      return copyWith(
        mobileStyleEdits: mobileStyleEdits.withValue(field.name, null),
        styleEdits: _shared(field)
            ? styleEdits.withValue(field.name, null)
            : styleEdits,
      );
    }
    return copyWith(
      mobileStyleEdits: mobileStyleEdits.withValue(field.name, value),
    );
  }

  /// The palette menus draw from, or null when they follow the page.
  ///
  /// shadcn implements "Inverted" by giving every menu surface the `dark`
  /// class — the whole dark token set, not a couple of recoloured slots — so
  /// an inverted menu is simply built from the dark counterpart of the same
  /// configuration. In dark mode that *is* the page palette, which matches
  /// the reference: inverted menus only differ in light mode.
  ColorScheme? get menuColorScheme =>
      menuColor == MenuSurfaceColor.inverted && brightness == Brightness.light
      ? _scheme(Brightness.dark)
      : null;

  /// The body text theme, with the heading styles swapped to the heading font
  /// when one is chosen.
  ///
  /// shadcn exposes body and heading fonts separately (`fontHeading:
  /// "inherit"` means "same as body"). A [TextTheme] carries one family,
  /// so the heading font is applied by overriding just the h1..h4 styles.
  TextTheme get textTheme {
    final body = font.textTheme();
    final heading = headingFont;
    if (heading == null || heading == font) return body;

    final headingBase = heading.textTheme();
    return body.copyWith(
      h1Large: headingBase.h1Large,
      h1: headingBase.h1,
      h2: headingBase.h2,
      h3: headingBase.h3,
      h4: headingBase.h4,
    );
  }

  /// The selected style with the glass and layout overrides applied — to its
  /// phone metrics too.
  ///
  /// A style's phone metrics are a second token set (`StyleTokens.mobile`,
  /// or one `forFormFactor` derives), and what the app shows on a phone is
  /// that set. So the overrides are resolved against each set separately,
  /// and the phone one is attached explicitly wherever `copyWith` on the
  /// style would not have produced it by itself — a scaled page margin, for
  /// one, is a different number on each.
  ///
  /// With nothing overridden this is the package's own constant.
  StyleTokens get styleTokens => _resolveStyle().tokens;

  _ResolvedStyle _resolveStyle() {
    final base = style.tokens;
    final mobileBase = base.forFormFactor(FormFactor.mobile);
    final desktop = StyleOverrides.resolve(this, base);
    final mobile = StyleOverrides.resolve(this, mobileBase);
    if (desktop.isEmpty &&
        mobile.isEmpty &&
        styleEdits.isEmpty &&
        mobileStyleEdits.isEmpty) {
      return (
        tokens: base,
        desktop: desktop,
        mobile: mobile,
        explicitMobile: false,
      );
    }

    // `StyleTokens` compares by value, so the cache is not what keeps two
    // builds of one configuration equal; it saves copying ~200 fields a few
    // times per build, and `App` builds every configuration twice.
    final key = (style, desktop, mobile, styleEdits, mobileStyleEdits);
    final cached = _styles[key];
    if (cached != null) return cached;
    if (_styles.length >= _maxCachedStyles) {
      _styles.remove(_styles.keys.first);
    }

    final overridden = styleEdits.apply(desktop.apply(base), styleFields);
    // The phone takes the desktop's edits to the fields it shares, then
    // its own.
    final phone = mobileStyleEdits.apply(
      StyleEdits({
        for (final field in styleFields)
          if (styleEdits[field.name] case final value? when _shared(field))
            field.name: value,
      }).apply(mobile.apply(mobileBase), styleFields),
      styleFields,
    );
    // What the desktop `copyWith` alone gives a phone is asked of the
    // package rather than assumed, so this — and the exported snippet,
    // which follows it — stays right whichever fields a `copyWith` carries
    // over to the phone tokens.
    final explicitMobile = overridden.forFormFactor(FormFactor.mobile) != phone;
    return _styles[key] = (
      tokens: explicitMobile ? overridden.copyWith(mobile: phone) : overridden,
      desktop: desktop,
      mobile: mobile,
      explicitMobile: explicitMobile,
    );
  }

  /// A slider drag makes one style per value it passes; keep the recent few.
  static const _maxCachedStyles = 32;
  static final _styles =
      <
        (StylePreset, StyleOverrides, StyleOverrides, StyleEdits, StyleEdits),
        _ResolvedStyle
      >{};

  /// Builds the theme.
  ///
  /// [customTextStyles] is merged into the text theme's `custom` map — the
  /// app hands its own named styles down this way, since the editor owns the
  /// whole [TextTheme] and would otherwise drop them.
  ThemeData build({Map<String, TextStyle> customTextStyles = const {}}) {
    // Null hands the choice to the package, which reads the style's radius.
    final borderRadius = usesStyleRadius
        ? null
        : BorderRadius.all(Radius.circular(effectiveRadius));

    // The menu options are the library's own — the same semantics as
    // shadcn's create editor: inverted menus take the dark palette,
    // translucent ones the blurred 70% surface, and a bold accent rewrites
    // the scheme's accent pair with its primary. Left to the style, menus
    // are glass in Una and solid in the shadcn styles.
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      radius: borderRadius,
      textTheme: customTextStyles.isEmpty
          ? textTheme
          : textTheme.copyWith(custom: customTextStyles),
      style: styleTokens,
      // Null leaves it to `UnaApp`, which follows the window.
      formFactor: formFactor.forced,
      spacing: spacing,
      disableSecondaryBorder: focusRing == FocusRingPlacement.inside,
      menuColorScheme: menuColorScheme,
      menuTranslucent: switch (menuFinish) {
        MenuSurfaceFinish.style => null,
        MenuSurfaceFinish.solid => false,
        MenuSurfaceFinish.translucent => true,
      },
      menuAccent: switch (menuAccent) {
        EditorMenuAccent.subtle => MenuAccent.subtle,
        EditorMenuAccent.bold => MenuAccent.bold,
      },
      // Null for `auto`, so the default configuration is still exactly the
      // package's default theme.
      liquidGlass: liquidGlass == EditorLiquidGlass.auto
          ? null
          : LiquidGlassTheme(mode: liquidGlass.mode),
    );
  }

  // --- Code export ---------------------------------------------------------

  /// The `ThemeData(...)` expression that reproduces this configuration for
  /// [brightness].
  ///
  /// Only what differs from the package defaults is written, so the default
  /// configuration is `ThemeData` with nothing but its font — the package
  /// bundles none.
  String toDartSnippet() {
    final dark = brightness == Brightness.dark;
    final lines = <String>[
      if (dark) 'brightness: Brightness.dark,',
      if (colors != ColorSchemes.ocean ||
          seed != null ||
          !lightColors.isEmpty ||
          !darkColors.isEmpty)
        ..._prefixed('colorScheme: ', _schemeCode(brightness)),
      if (!usesStyleRadius)
        'radius: BorderRadius.circular(${_number(effectiveRadius)}),',
      ..._prefixed('textTheme: ', _textThemeCode()),
      if (styleTokens != StyleTokens.fluid)
        ..._prefixed('style: ', _styleCode()),
      if (density != Density.normal)
        'spacing: const Spacing(step: ${_number(density.step)}),',
      if (focusRing == FocusRingPlacement.inside)
        'disableSecondaryBorder: true,',
      if (menuColor == MenuSurfaceColor.inverted && !dark)
        ..._prefixed('menuColorScheme: ', _schemeCode(Brightness.dark)),
      if (menuFinish == MenuSurfaceFinish.translucent) 'menuTranslucent: true,',
      if (menuFinish == MenuSurfaceFinish.solid) 'menuTranslucent: false,',
      if (menuAccent == EditorMenuAccent.bold) 'menuAccent: MenuAccent.bold,',
      if (liquidGlass != EditorLiquidGlass.auto)
        'liquidGlass: const LiquidGlassTheme('
            'mode: LiquidGlassMode.${liquidGlass.mode.name}),',
    ];
    return ['ThemeData(', ..._indented(lines), ')'].join('\n');
  }

  /// The `UnaApp(...)` that reproduces the whole configuration: the
  /// light theme, the dark one, and the form factor when one is pinned.
  ///
  /// This is what the panel shows and copies. [textScale] is left out: it
  /// previews the platform's text-size setting, which an app does not set.
  String toAppSnippet() {
    final light = copyWith(brightness: Brightness.light).toDartSnippet();
    final dark = copyWith(brightness: Brightness.dark).toDartSnippet();
    final forced = formFactor.forced;
    return [
      // Every editor font comes from Google Fonts. An app can also bundle
      // the face itself and pass `TextTheme(family: 'Inter')`.
      '// flutter pub add google_fonts',
      'UnaApp(',
      ..._indented(_prefixed('theme: ', '$light,'.split('\n'))),
      ..._indented(_prefixed('darkTheme: ', '$dark,'.split('\n'))),
      if (forced != null) '  formFactor: FormFactor.${forced.name},',
      '  // home, routes and the rest of your app.',
      ')',
    ].join('\n');
  }

  /// The colour scheme expression for [b], ending in a comma: the colour
  /// theme's, with every colour that differs from it.
  List<String> _schemeCode(Brightness b) {
    final name = colors.name;
    final hex = seed == null
        ? null
        : '0x${seed!.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    final base = hex != null
        ? 'ColorScheme.fromSeed(const Color($hex)'
              '${b == Brightness.dark ? ', brightness: Brightness.dark' : ''})'
        : 'const ${name[0].toUpperCase()}${name.substring(1)}ColorScheme'
              '.${b.name}()';
    final theme = baseScheme(b);
    final resolved = _scheme(b);
    final changed = [
      for (final token in colorTokens)
        if (token.read(resolved) != token.read(theme))
          '  ${token.name}: '
              'const Color(0x${token.read(resolved).toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}),',
    ];
    if (changed.isEmpty) return ['$base,'];
    return ['$base.copyWith(', ...changed, '),'];
  }

  /// The text theme expression, ending in a comma.
  List<String> _textThemeCode() {
    String themeOf(EditorFont font) =>
        'TextTheme.fromGoogleFont(GoogleFonts.${_camel(font.family)})';

    final heading = headingFont;
    if (heading == null || heading == font) return ['${themeOf(font)},'];
    return [
      '${themeOf(font)}.copyWith(',
      for (final style in const ['h1Large', 'h1', 'h2', 'h3', 'h4'])
        '  $style: ${themeOf(heading)}.$style,',
      '),',
    ];
  }

  /// The style expression, ending in a comma.
  List<String> _styleCode() {
    final resolved = _resolveStyle();
    final name = 'StyleTokens.${style.name}';
    String edit(StyleField field, Object value) =>
        '${field.name}: ${field.toSource(value)}';
    final desktopLines = [
      ...resolved.desktop.code,
      for (final field in styleFields)
        if (styleEdits[field.name] case final value?) edit(field, value),
    ];
    final mobileLines = [
      ...resolved.mobile.code,
      for (final field in styleFields)
        if (mobileStyleEdits[field.name] case final value?) edit(field, value),
    ];
    if (desktopLines.isEmpty && !resolved.explicitMobile) return ['$name,'];

    final mobileName = '$name.forFormFactor(FormFactor.mobile)';
    return [
      '$name.copyWith(',
      for (final line in desktopLines) '  $line,',
      // The phone metrics are a second token set. Where the overrides
      // above do not leave it as it should be, it is spelled out.
      if (resolved.explicitMobile)
        if (mobileLines.isEmpty)
          '  mobile: $mobileName,'
        else ...[
          '  mobile: $mobileName.copyWith(',
          for (final line in mobileLines) '    $line,',
          '  ),',
        ],
      '),',
    ];
  }

  static List<String> _prefixed(String prefix, List<String> lines) => [
    '$prefix${lines.first}',
    ...lines.skip(1),
  ];

  static List<String> _indented(List<String> lines) => [
    for (final line in lines) '  $line',
  ];

  /// The name of `GoogleFonts`' accessor for [family]: "Space Grotesk" is
  /// `spaceGrotesk`, "JetBrains Mono" `jetBrainsMono` and "IBM Plex Sans"
  /// `ibmPlexSans` — lower camel case, where a leading acronym is lowered
  /// whole and any other first word only loses its capital.
  static String _camel(String family) {
    final parts = family.split(RegExp(r'[\s_]+'));
    final first = parts.first;
    return [
      first == first.toUpperCase()
          ? first.toLowerCase()
          : first[0].toLowerCase() + first.substring(1),
      ...parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)),
    ].join();
  }
}

/// A style with a configuration's overrides applied: the tokens, what was
/// changed on the style and on its phone metrics, and whether the phone
/// metrics had to be attached by hand.
typedef _ResolvedStyle = ({
  StyleTokens tokens,
  StyleOverrides desktop,
  StyleOverrides mobile,
  bool explicitMobile,
});

/// `1` rather than `1.0`, and no binary-fraction noise: a slider that lands
/// on 0.7 by arithmetic must not export `0.7000000000000001`.
String _number(double value) {
  final rounded = double.parse(value.toStringAsFixed(3));
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

/// The [StyleTokens] fields a [ThemeEditorConfig] changes on one token set.
///
/// Resolved against the tokens it will be applied to, so it holds only what
/// actually differs: [apply] and [code] — the theme and the exported snippet
/// — are driven by the same fields and cannot disagree.
@immutable
class StyleOverrides {
  const StyleOverrides({
    this.cardOpacity,
    this.cardOpacityDark,
    this.cardBlur,
    this.barOpacity,
    this.barOpacityDark,
    this.glassBlur,
    this.pagePaddingX,
    this.pagePaddingY,
    this.cardPadding,
    this.bottomNavigationFloating,
  });

  /// What [config] changes on [tokens] — a style, or its phone counterpart.
  factory StyleOverrides.resolve(ThemeEditorConfig config, StyleTokens tokens) {
    // Null unless the configuration asks for something [tokens] is not.
    T? changed<T extends Object>(T? wanted, T current) =>
        wanted == null || wanted == current ? null : wanted;
    // Whole pixels: a margin of 21.6 is not a design decision.
    double scaled(double value, double scale) =>
        scale == 1 ? value : (value * scale).roundToDouble();

    return StyleOverrides(
      cardOpacity: changed(config.cardOpacity, tokens.cardOpacity),
      // The override is one number for both brightnesses, so the dark
      // value has to be stated wherever the style would have gone its own
      // way.
      cardOpacityDark: changed(
        config.cardOpacity,
        tokens.cardOpacityDark ?? tokens.cardOpacity,
      ),
      cardBlur: changed(config.cardBlur, tokens.cardBlur),
      barOpacity: changed(config.barOpacity, tokens.barOpacity),
      barOpacityDark: changed(
        config.barOpacity,
        tokens.barOpacityDark ?? tokens.barOpacity,
      ),
      glassBlur: changed(config.glassBlur, tokens.glassBlur),
      pagePaddingX: changed(
        scaled(tokens.pagePaddingX, config.pageMarginScale),
        tokens.pagePaddingX,
      ),
      pagePaddingY: changed(
        scaled(tokens.pagePaddingY, config.pageMarginScale),
        tokens.pagePaddingY,
      ),
      cardPadding: changed(
        scaled(tokens.cardPadding, config.cardPaddingScale),
        tokens.cardPadding,
      ),
      bottomNavigationFloating: changed(
        config.bottomBarFloating,
        tokens.bottomNavigationFloating,
      ),
    );
  }

  final double? cardOpacity;
  final double? cardOpacityDark;
  final bool? cardBlur;
  final double? barOpacity;
  final double? barOpacityDark;
  final double? glassBlur;
  final double? pagePaddingX;
  final double? pagePaddingY;
  final double? cardPadding;
  final bool? bottomNavigationFloating;

  List<Object?> get _values => [
    cardOpacity,
    cardOpacityDark,
    cardBlur,
    barOpacity,
    barOpacityDark,
    glassBlur,
    pagePaddingX,
    pagePaddingY,
    cardPadding,
    bottomNavigationFloating,
  ];

  bool get isEmpty => _values.every((v) => v == null);

  /// [tokens] with these fields replaced.
  StyleTokens apply(StyleTokens tokens) => isEmpty
      ? tokens
      : tokens.copyWith(
          cardOpacity: cardOpacity,
          cardOpacityDark: cardOpacityDark,
          cardBlur: cardBlur,
          barOpacity: barOpacity,
          barOpacityDark: barOpacityDark,
          glassBlur: glassBlur,
          pagePaddingX: pagePaddingX,
          pagePaddingY: pagePaddingY,
          cardPadding: cardPadding,
          bottomNavigationFloating: bottomNavigationFloating,
        );

  /// The `copyWith` arguments [apply] passes, as source: `cardOpacity: 0.7`.
  List<String> get code => [
    if (cardOpacity != null) 'cardOpacity: ${_number(cardOpacity!)}',
    if (cardOpacityDark != null)
      'cardOpacityDark: ${_number(cardOpacityDark!)}',
    if (cardBlur != null) 'cardBlur: $cardBlur',
    if (barOpacity != null) 'barOpacity: ${_number(barOpacity!)}',
    if (barOpacityDark != null) 'barOpacityDark: ${_number(barOpacityDark!)}',
    if (glassBlur != null) 'glassBlur: ${_number(glassBlur!)}',
    if (pagePaddingX != null) 'pagePaddingX: ${_number(pagePaddingX!)}',
    if (pagePaddingY != null) 'pagePaddingY: ${_number(pagePaddingY!)}',
    if (cardPadding != null) 'cardPadding: ${_number(cardPadding!)}',
    if (bottomNavigationFloating != null)
      'bottomNavigationFloating: $bottomNavigationFloating',
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StyleOverrides) return false;
    final a = _values;
    final b = other._values;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_values);
}
