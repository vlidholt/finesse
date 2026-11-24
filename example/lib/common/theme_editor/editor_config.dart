import 'package:example/common/theme_editor/fonts.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The package's *base colours*: Finesse's own teal, and the three shadcn/ui
/// neutrals it kept.
enum BaseColor {
  teal('Teal'),
  neutral('Neutral'),
  stone('Stone'),
  zinc('Zinc');

  const BaseColor(this.label);

  final String label;

  ColorScheme scheme(Brightness brightness) =>
      ColorScheme.fromName(name, brightness: brightness);

  /// The scheme's class name, as the exported snippet spells it.
  String get className =>
      '${name[0].toUpperCase()}${name.substring(1)}ColorScheme';

  /// The dot shown in the picker.
  ///
  /// Not `primary` for the neutrals: there it is near-black, which
  /// disappears against the customizer's dark surface. The muted foreground is
  /// the same hue at a lightness that reads on either background. Teal's
  /// primary is the brand colour itself.
  Color get swatch => this == BaseColor.teal
      ? scheme(Brightness.light).primary
      : scheme(Brightness.light).mutedForeground;
}

/// shadcn/ui's accent *themes*, layered over a [BaseColor].
enum AccentColor {
  base('Base'),
  amber('Amber'),
  blue('Blue'),
  cyan('Cyan'),
  emerald('Emerald'),
  fuchsia('Fuchsia'),
  green('Green'),
  indigo('Indigo'),
  lime('Lime'),
  orange('Orange'),
  pink('Pink'),
  purple('Purple'),
  red('Red'),
  rose('Rose'),
  sky('Sky'),
  teal('Teal'),
  violet('Violet'),
  yellow('Yellow');

  const AccentColor(this.label);

  final String label;

  AccentScheme? scheme(Brightness brightness) => this == AccentColor.base
      ? null
      : AccentScheme.fromName(name, brightness: brightness);

  /// The dot shown in the picker.
  ///
  /// "Base" means "keep the base colour's own hue", so it shows that palette's
  /// swatch rather than its `primary`, which is near-black and reads as a
  /// missing image.
  Color swatch(Brightness brightness, BaseColor base) =>
      scheme(brightness)?.primary ?? base.swatch;
}

/// The radius presets. [style] follows the selected style's own radius —
/// 10 for Finesse — which is what the package does when no radius is given.
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

/// The package's named styles: Finesse's own, and the three shadcn/ui
/// styles it kept.
///
/// Each is a preset over [StyleTokens] — corner radii, focus-ring
/// thickness and opacity, and label typography — so picking one reshapes every
/// component at once.
enum StylePreset {
  finesse('Finesse'),
  nova('Nova'),
  maia('Maia'),
  lyra('Lyra');

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

/// The menu surface finish, mirroring shadcn's "Solid/Translucent".
enum MenuSurfaceFinish {
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
enum EditorFormFactor {
  /// Follow the width the page has, as `FinesseApp` does by itself.
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
    this.style = StylePreset.finesse,
    this.baseColor = BaseColor.teal,
    this.accentColor = AccentColor.base,
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
    this.menuFinish = MenuSurfaceFinish.solid,
    this.menuAccent = EditorMenuAccent.subtle,
    this.formFactor = EditorFormFactor.auto,
    this.textScale = 1,
  });

  final Brightness brightness;
  final StylePreset style;
  final BaseColor baseColor;
  final AccentColor accentColor;

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
    BaseColor? baseColor,
    AccentColor? accentColor,
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
  }) {
    return ThemeEditorConfig(
      brightness: brightness ?? this.brightness,
      style: style ?? this.style,
      baseColor: baseColor ?? this.baseColor,
      accentColor: accentColor ?? this.accentColor,
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
        other.baseColor == baseColor &&
        other.accentColor == accentColor &&
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
        other.textScale == textScale;
  }

  @override
  int get hashCode => Object.hashAll([
    brightness,
    style,
    baseColor,
    accentColor,
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
  ]);

  /// The palette, fully resolved for [brightness]: the base, then the accent.
  ColorScheme get colorScheme => _scheme(brightness);

  ColorScheme _scheme(Brightness b) {
    final scheme = baseColor.scheme(b);
    final accent = accentColor.scheme(b);
    if (accent == null) return scheme;

    // `applyAccentScheme` re-tints the primary pair and picks a tint that
    // reads on the page from the accent's own ramp.
    return scheme.applyAccentScheme(accent);
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
    if (desktop.isEmpty && mobile.isEmpty) {
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
    final key = (style, desktop, mobile);
    final cached = _styles[key];
    if (cached != null) return cached;
    if (_styles.length >= _maxCachedStyles) {
      _styles.remove(_styles.keys.first);
    }

    final overridden = desktop.apply(base);
    final phone = mobile.apply(mobileBase);
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
      <(StylePreset, StyleOverrides, StyleOverrides), _ResolvedStyle>{};

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
    // the scheme's accent pair with its primary.
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      radius: borderRadius,
      textTheme: customTextStyles.isEmpty
          ? textTheme
          : textTheme.copyWith(custom: customTextStyles),
      style: styleTokens,
      // Null leaves it to `FinesseApp`, which follows the window.
      formFactor: formFactor.forced,
      spacing: spacing,
      disableSecondaryBorder: focusRing == FocusRingPlacement.inside,
      menuColorScheme: menuColorScheme,
      menuTranslucent: menuFinish == MenuSurfaceFinish.translucent,
      menuAccent: switch (menuAccent) {
        EditorMenuAccent.subtle => MenuAccent.subtle,
        EditorMenuAccent.bold => MenuAccent.bold,
      },
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
      if (baseColor != BaseColor.teal || accentColor != AccentColor.base)
        ..._prefixed('colorScheme: ', _schemeCode(brightness)),
      if (!usesStyleRadius)
        'radius: BorderRadius.circular(${_number(effectiveRadius)}),',
      ..._prefixed('textTheme: ', _textThemeCode()),
      if (styleTokens != StyleTokens.finesse)
        ..._prefixed('style: ', _styleCode()),
      if (density != Density.normal)
        'spacing: const Spacing(step: ${_number(density.step)}),',
      if (focusRing == FocusRingPlacement.inside)
        'disableSecondaryBorder: true,',
      if (menuColor == MenuSurfaceColor.inverted && !dark)
        ..._prefixed('menuColorScheme: ', _schemeCode(Brightness.dark)),
      if (menuFinish == MenuSurfaceFinish.translucent) 'menuTranslucent: true,',
      if (menuAccent == EditorMenuAccent.bold) 'menuAccent: MenuAccent.bold,',
    ];
    return ['ThemeData(', ..._indented(lines), ')'].join('\n');
  }

  /// The `FinesseApp(...)` that reproduces the whole configuration: the
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
      'FinesseApp(',
      ..._indented(_prefixed('theme: ', '$light,'.split('\n'))),
      ..._indented(_prefixed('darkTheme: ', '$dark,'.split('\n'))),
      if (forced != null) '  formFactor: FormFactor.${forced.name},',
      '  // home, routes and the rest of your app.',
      ')',
    ].join('\n');
  }

  /// The colour scheme expression for [b], ending in a comma.
  List<String> _schemeCode(Brightness b) {
    final base = 'const ${baseColor.className}.${b.name}()';
    if (accentColor == AccentColor.base) return ['$base,'];

    final accent =
        'AccentScheme.${accentColor.name}'
        '${b == Brightness.light ? 'Light' : 'Dark'}';
    return ['$base.applyAccentScheme(', '  $accent,', '),'];
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
    if (resolved.desktop.isEmpty && !resolved.explicitMobile) return ['$name,'];

    final mobileName = '$name.forFormFactor(FormFactor.mobile)';
    return [
      '$name.copyWith(',
      for (final line in resolved.desktop.code) '  $line,',
      // The phone metrics are a second token set. Where the overrides
      // above do not leave it as it should be, it is spelled out.
      if (resolved.explicitMobile)
        if (resolved.mobile.isEmpty)
          '  mobile: $mobileName,'
        else ...[
          '  mobile: $mobileName.copyWith(',
          for (final line in resolved.mobile.code) '    $line,',
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

/// A [ColorScheme.tint] chosen for an accent: the colour, what goes on it,
/// and the `AccentScheme` field it was read from, for the exported code.

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
