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

/// Everything the editor configures, and the [ThemeData] it produces.
@immutable
class ThemeEditorConfig {
  const ThemeEditorConfig({
    this.brightness = Brightness.light,
    this.style = StylePreset.finesse,
    this.baseColor = BaseColor.teal,
    this.accentColor = AccentColor.base,
    this.chartColor = AccentColor.base,
    this.headingFontTitle,
    this.fontTitle = 'Geist',
    this.radius = RadiusPreset.style,
    this.customRadius,
    this.menuColor = MenuSurfaceColor.standard,
    this.menuFinish = MenuSurfaceFinish.solid,
    this.menuAccent = EditorMenuAccent.subtle,
    this.textScale = 1,
    this.spacingStep = 4,
  });

  final Brightness brightness;
  final StylePreset style;
  final BaseColor baseColor;
  final AccentColor accentColor;

  /// The chart ramp's hue, pickable independently of the main accent.
  final AccentColor chartColor;

  /// Null means "same as body", shadcn's `fontHeading: "inherit"`.
  final String? headingFontTitle;
  final String fontTitle;

  final RadiusPreset radius;
  final double? customRadius;

  final MenuSurfaceColor menuColor;
  final MenuSurfaceFinish menuFinish;
  final EditorMenuAccent menuAccent;

  final double textScale;

  /// One step on the spacing scale, shadcn's `--spacing`.
  final double spacingStep;

  /// The `md` radius in logical pixels: a custom value, the preset's, or the
  /// selected style's own.
  double get effectiveRadius =>
      customRadius ?? radius.value ?? style.tokens.radius;

  /// Whether the radius is the style's own, so [build] leaves it to the
  /// package and the exported snippet does not mention it.
  bool get usesStyleRadius => customRadius == null && radius.value == null;

  Spacing get spacing => Spacing(step: spacingStep);

  EditorFont get font => EditorFont.byTitle(fontTitle);

  EditorFont? get headingFont =>
      headingFontTitle == null ? null : EditorFont.byTitle(headingFontTitle!);

  ThemeEditorConfig copyWith({
    Brightness? brightness,
    StylePreset? style,
    BaseColor? baseColor,
    AccentColor? accentColor,
    AccentColor? chartColor,
    String? headingFontTitle,
    bool clearHeadingFont = false,
    String? fontTitle,
    RadiusPreset? radius,
    double? customRadius,
    bool clearCustomRadius = false,
    MenuSurfaceColor? menuColor,
    MenuSurfaceFinish? menuFinish,
    EditorMenuAccent? menuAccent,
    double? textScale,
    double? spacingStep,
  }) {
    return ThemeEditorConfig(
      brightness: brightness ?? this.brightness,
      style: style ?? this.style,
      baseColor: baseColor ?? this.baseColor,
      accentColor: accentColor ?? this.accentColor,
      chartColor: chartColor ?? this.chartColor,
      headingFontTitle: clearHeadingFont
          ? null
          : (headingFontTitle ?? this.headingFontTitle),
      fontTitle: fontTitle ?? this.fontTitle,
      radius: radius ?? this.radius,
      customRadius: clearCustomRadius
          ? null
          : (customRadius ?? this.customRadius),
      menuColor: menuColor ?? this.menuColor,
      menuFinish: menuFinish ?? this.menuFinish,
      menuAccent: menuAccent ?? this.menuAccent,
      textScale: textScale ?? this.textScale,
      spacingStep: spacingStep ?? this.spacingStep,
    );
  }

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
        other.chartColor == chartColor &&
        other.headingFontTitle == headingFontTitle &&
        other.fontTitle == fontTitle &&
        other.radius == radius &&
        other.customRadius == customRadius &&
        other.menuColor == menuColor &&
        other.menuFinish == menuFinish &&
        other.menuAccent == menuAccent &&
        other.textScale == textScale &&
        other.spacingStep == spacingStep;
  }

  @override
  int get hashCode => Object.hash(
    brightness,
    style,
    baseColor,
    accentColor,
    chartColor,
    headingFontTitle,
    fontTitle,
    radius,
    customRadius,
    menuColor,
    menuFinish,
    menuAccent,
    textScale,
    spacingStep,
  );

  /// The palette, fully resolved for [brightness]: base, accent, then chart.
  ColorScheme get colorScheme => _scheme(brightness);

  ColorScheme _scheme(Brightness b) {
    var scheme = baseColor.scheme(b);

    final accent = accentColor.scheme(b);
    if (accent != null) scheme = scheme.applyAccentScheme(accent);

    final chart = chartColor.scheme(b);
    if (chart != null) {
      scheme = scheme.copyWith(
        chart1: chart.chart1,
        chart2: chart.chart2,
        chart3: chart.chart3,
        chart4: chart.chart4,
        chart5: chart.chart5,
      );
    }

    return scheme;
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
      style: style.tokens,
      spacing: spacing,
      menuColorScheme: menuColorScheme,
      menuTranslucent: menuFinish == MenuSurfaceFinish.translucent,
      menuAccent: switch (menuAccent) {
        EditorMenuAccent.subtle => MenuAccent.subtle,
        EditorMenuAccent.bold => MenuAccent.bold,
      },
    );
  }

  /// A copy-pasteable snippet reproducing this configuration.
  String toDartSnippet() {
    final buffer = StringBuffer()
      ..writeln('ThemeData(')
      ..writeln('  brightness: Brightness.${brightness.name},');

    final cap =
        '${baseColor.name[0].toUpperCase()}${baseColor.name.substring(1)}';
    final ctor = 'const ${cap}ColorScheme.${brightness.name}()';

    if (accentColor == AccentColor.base) {
      buffer.writeln('  colorScheme: $ctor,');
    } else {
      buffer
        ..writeln('  colorScheme: $ctor.applyAccentScheme(')
        ..writeln(
          '    AccentScheme.${accentColor.name}'
          '${brightness == Brightness.light ? 'Light' : 'Dark'},',
        )
        ..writeln('  ),');
    }

    if (!usesStyleRadius) {
      buffer.writeln(
        '  radius: BorderRadius.circular('
        '${effectiveRadius.toStringAsFixed(1)}),',
      );
    }
    // Every editor font comes from Google Fonts. An app can also bundle the
    // face itself and pass `TextTheme(family: 'Inter')`.
    buffer.writeln(
      '  // flutter pub add google_fonts\n'
      '  textTheme: TextTheme.fromGoogleFont('
      "GoogleFonts.${_camel(font.family)}),",
    );
    buffer.writeln('  style: StyleTokens.${style.name},');
    if (spacingStep != 4) {
      buffer.writeln(
        '  spacing: Spacing(step: ${spacingStep.toStringAsFixed(1)}),',
      );
    }
    if (menuColor == MenuSurfaceColor.inverted &&
        brightness == Brightness.light) {
      final cap =
          '${baseColor.name[0].toUpperCase()}${baseColor.name.substring(1)}';
      final darkCtor = 'const ${cap}ColorScheme.dark()';
      if (accentColor == AccentColor.base) {
        buffer.writeln('  menuColorScheme: $darkCtor,');
      } else {
        buffer
          ..writeln('  menuColorScheme: $darkCtor.applyAccentScheme(')
          ..writeln('    AccentScheme.${accentColor.name}Dark,')
          ..writeln('  ),');
      }
    }
    if (menuFinish == MenuSurfaceFinish.translucent) {
      buffer.writeln('  menuTranslucent: true,');
    }
    if (menuAccent == EditorMenuAccent.bold) {
      buffer.writeln('  menuAccent: MenuAccent.bold,');
    }
    buffer.write(')');
    return buffer.toString();
  }

  /// "Space Grotesk" -> "spaceGrotesk", matching google_fonts' accessors.
  static String _camel(String family) {
    final parts = family.split(RegExp(r'[\s_]+'));
    return [
      parts.first.toLowerCase(),
      ...parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)),
    ].join();
  }
}
