import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/src/theme/color_scheme/base.dart';
import 'package:una/src/theme/color_scheme/ocean.dart';

// `ColorScheme.fromSeed`: a whole scheme from one colour, made the way the
// six built-in schemes are (scripts/generate_color_schemes.dart): Ocean's
// lightness, token by token, with the seed's hue for the accent and a
// breath of it in the greys.

/// How a token follows the seed.
enum _Role { neutral, accent, fixed }

const _roles = <String, _Role>{
  'background': _Role.neutral,
  'foreground': _Role.neutral,
  'card': _Role.neutral,
  'cardForeground': _Role.neutral,
  'popover': _Role.neutral,
  'popoverForeground': _Role.neutral,
  'primary': _Role.accent,
  'primaryForeground': _Role.fixed,
  'secondary': _Role.neutral,
  'secondaryForeground': _Role.neutral,
  'muted': _Role.neutral,
  'mutedForeground': _Role.neutral,
  'accent': _Role.accent,
  'accentForeground': _Role.accent,
  'destructive': _Role.fixed,
  'destructiveForeground': _Role.fixed,
  'border': _Role.neutral,
  'input': _Role.neutral,
  'ring': _Role.accent,
  'selection': _Role.accent,
  'chart1': _Role.accent,
  'chart2': _Role.accent,
  'chart3': _Role.fixed,
  'chart4': _Role.fixed,
  'chart5': _Role.fixed,
  'sidebar': _Role.neutral,
  'sidebarForeground': _Role.neutral,
  'sidebarPrimary': _Role.accent,
  'sidebarPrimaryForeground': _Role.fixed,
  'sidebarAccent': _Role.accent,
  'sidebarAccentForeground': _Role.accent,
  'sidebarBorder': _Role.neutral,
  'sidebarRing': _Role.accent,
  'foregroundSubtle': _Role.neutral,
  'tint': _Role.accent,
  'tintForeground': _Role.fixed,
  'success': _Role.fixed,
  'successMuted': _Role.fixed,
  'warning': _Role.fixed,
  'borderStrong': _Role.neutral,
  'accentBorder': _Role.accent,
  'bar': _Role.neutral,
};

Map<String, Color> _tokens(ColorScheme s) => {
  'background': s.background,
  'foreground': s.foreground,
  'card': s.card,
  'cardForeground': s.cardForeground,
  'popover': s.popover,
  'popoverForeground': s.popoverForeground,
  'primary': s.primary,
  'primaryForeground': s.primaryForeground,
  'secondary': s.secondary,
  'secondaryForeground': s.secondaryForeground,
  'muted': s.muted,
  'mutedForeground': s.mutedForeground,
  'accent': s.accent,
  'accentForeground': s.accentForeground,
  'destructive': s.destructive,
  'destructiveForeground': s.destructiveForeground,
  'border': s.border,
  'input': s.input,
  'ring': s.ring,
  'selection': s.selection,
  'chart1': s.chart1,
  'chart2': s.chart2,
  'chart3': s.chart3,
  'chart4': s.chart4,
  'chart5': s.chart5,
  'sidebar': s.sidebar,
  'sidebarForeground': s.sidebarForeground,
  'sidebarPrimary': s.sidebarPrimary,
  'sidebarPrimaryForeground': s.sidebarPrimaryForeground,
  'sidebarAccent': s.sidebarAccent,
  'sidebarAccentForeground': s.sidebarAccentForeground,
  'sidebarBorder': s.sidebarBorder,
  'sidebarRing': s.sidebarRing,
  'foregroundSubtle': s.foregroundSubtle,
  'tint': s.tint,
  'tintForeground': s.tintForeground,
  'success': s.success,
  'successMuted': s.successMuted,
  'warning': s.warning,
  'borderStrong': s.borderStrong,
  'accentBorder': s.accentBorder,
  'bar': s.bar,
};

/// Ocean primary's strength (OKLCH chroma): a seed this strong gives an
/// accent as strong as Ocean's.
final _oceanAccentChroma = _toOklch(const OceanColorScheme.light().primary).$2;

/// The scheme made from [seed] for [brightness]; see
/// [ColorScheme.fromSeed].
ColorScheme schemeFromSeed(
  Color seed,
  Brightness brightness, {
  Color? neutral,
}) {
  final dark = brightness == Brightness.dark;
  final template = _tokens(
    dark ? const OceanColorScheme.dark() : const OceanColorScheme.light(),
  );
  final (_, chroma, hue) = _toOklch(seed);
  // Below this a colour reads as grey: the scheme is monochrome, its
  // primary its ink, as Graphite's is.
  final grey = chroma < .035;
  final accent = (chroma / _oceanAccentChroma).clamp(.45, 1.15);
  // The greys lean towards [neutral] as far as it leans itself (a pure
  // grey not at all, a slate as far as Ocean's), or else a little towards
  // the seed.
  final (_, neutralChroma, neutralHue) = neutral == null
      ? (0.0, 0.0, hue)
      : _toOklch(neutral);
  final greyHue = neutral == null ? hue : neutralHue;
  final greys = neutral != null
      ? (neutralChroma / .035).clamp(0.0, 1.5)
      : grey
      ? (chroma / .035) * .35
      : .6;
  final out = <String, Color>{
    for (final MapEntry(key: name, value: color) in template.entries)
      name: switch (_roles[name]!) {
        _Role.fixed => color,
        _Role.neutral => _shift(color, greyHue, greys),
        _Role.accent => grey ? color : _shift(color, hue, accent),
      },
  };
  if (grey) {
    final ink = out['foreground']!;
    final page = out['background']!;
    Color wash(double alpha) => ink.withValues(alpha: alpha);
    for (final name in ['primary', 'ring', 'chart1', 'sidebarPrimary']) {
      out[name] = ink;
    }
    for (final name in ['sidebarRing', 'tint', 'accentForeground']) {
      out[name] = ink;
    }
    out['sidebarAccentForeground'] = ink;
    final onInk = dark ? page : const Color(0xffffffff);
    out['primaryForeground'] = onInk;
    out['tintForeground'] = onInk;
    out['sidebarPrimaryForeground'] = onInk;
    out['accent'] = wash(dark ? .12 : .07);
    out['sidebarAccent'] = out['accent']!;
    out['selection'] = wash(.2);
    out['accentBorder'] = wash(.24);
    out['chart2'] = out['mutedForeground']!;
  }
  Color t(String name) => out[name]!;
  return ColorScheme(
    background: t('background'),
    foreground: t('foreground'),
    card: t('card'),
    cardForeground: t('cardForeground'),
    popover: t('popover'),
    popoverForeground: t('popoverForeground'),
    primary: t('primary'),
    primaryForeground: t('primaryForeground'),
    secondary: t('secondary'),
    secondaryForeground: t('secondaryForeground'),
    muted: t('muted'),
    mutedForeground: t('mutedForeground'),
    accent: t('accent'),
    accentForeground: t('accentForeground'),
    destructive: t('destructive'),
    destructiveForeground: t('destructiveForeground'),
    border: t('border'),
    input: t('input'),
    ring: t('ring'),
    selection: t('selection'),
    chart1: t('chart1'),
    chart2: t('chart2'),
    chart3: t('chart3'),
    chart4: t('chart4'),
    chart5: t('chart5'),
    sidebar: t('sidebar'),
    sidebarForeground: t('sidebarForeground'),
    sidebarPrimary: t('sidebarPrimary'),
    sidebarPrimaryForeground: t('sidebarPrimaryForeground'),
    sidebarAccent: t('sidebarAccent'),
    sidebarAccentForeground: t('sidebarAccentForeground'),
    sidebarBorder: t('sidebarBorder'),
    sidebarRing: t('sidebarRing'),
    foregroundSubtle: t('foregroundSubtle'),
    tint: t('tint'),
    tintForeground: t('tintForeground'),
    success: t('success'),
    successMuted: t('successMuted'),
    warning: t('warning'),
    borderStrong: t('borderStrong'),
    accentBorder: t('accentBorder'),
    bar: t('bar'),
  );
}

/// [color] with its OKLCH hue moved to [hue] and its chroma scaled by
/// [factor], keeping its lightness and opacity; brought into sRGB by
/// lowering the chroma, never the lightness.
Color _shift(Color color, double hue, double factor) {
  final (l, c, _) = _toOklch(color);
  var target = c * factor;
  while (true) {
    final rgb = _fromOklch(l, target, hue);
    if (rgb != null) {
      return Color.from(
        alpha: color.a,
        red: rgb.$1,
        green: rgb.$2,
        blue: rgb.$3,
      );
    }
    if (target <= 0) {
      return color;
    }
    target = math.max(target - .002, 0);
  }
}

(double, double, double) _toOklch(Color color) {
  double lin(double v) =>
      v <= .04045 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
  final r = lin(color.r);
  final g = lin(color.g);
  final b = lin(color.b);
  final l = math.pow(
    .4122214708 * r + .5363325363 * g + .0514459929 * b,
    1 / 3,
  );
  final m = math.pow(
    .2119034982 * r + .6806995451 * g + .1073969566 * b,
    1 / 3,
  );
  final s = math.pow(
    .0883024619 * r + .2817188376 * g + .6299787005 * b,
    1 / 3,
  );
  final lightness = .2104542553 * l + .7936177850 * m - .0040720468 * s;
  final aa = 1.9779984951 * l - 2.4285922050 * m + .4505937099 * s;
  final bb = .0259040371 * l + .7827717662 * m - .8086757660 * s;
  final hue = (math.atan2(bb, aa) * 180 / math.pi + 360) % 360;
  return (lightness, math.sqrt(aa * aa + bb * bb), hue);
}

(double, double, double)? _fromOklch(double l, double c, double h) {
  final a = c * math.cos(h * math.pi / 180);
  final b = c * math.sin(h * math.pi / 180);
  final l3 = math.pow(l + .3963377774 * a + .2158037573 * b, 3);
  final m3 = math.pow(l - .1055613458 * a - .0638541728 * b, 3);
  final s3 = math.pow(l - .0894841775 * a - 1.2914855480 * b, 3);
  double? gamma(double x) {
    if (x < -1e-4 || x > 1 + 1e-4) return null;
    final v = x.clamp(0.0, 1.0);
    return v <= .0031308 ? 12.92 * v : 1.055 * math.pow(v, 1 / 2.4) - .055;
  }

  final r = gamma(4.0767416621 * l3 - 3.3077115913 * m3 + .2309699292 * s3);
  final g = gamma(-1.2684380046 * l3 + 2.6097574011 * m3 - .3413193965 * s3);
  final bl = gamma(-.0041960863 * l3 - .7034186147 * m3 + 1.7076147010 * s3);
  if (r == null || g == null || bl == null) return null;
  return (r, g, bl);
}
