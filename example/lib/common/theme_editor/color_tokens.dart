import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The groups the editor lists a scheme's colours in.
enum ColorTokenGroup {
  brand('Brand'),
  surfaces('Surfaces'),
  text('Text'),
  fills('Fills'),
  lines('Lines'),
  status('Status'),
  charts('Charts'),
  sidebar('Sidebar');

  const ColorTokenGroup(this.label);

  final String label;
}

/// One colour of a [ColorScheme]: how to read it (fallbacks resolved) and
/// how to set it.
@immutable
class ColorToken {
  const ColorToken(this.name, this.group, this.read, this.write);

  final String name;
  final ColorTokenGroup group;
  final Color Function(ColorScheme scheme) read;
  final ColorScheme Function(ColorScheme scheme, Color color) write;

  /// The name in words: `primaryForeground` is "Primary foreground".
  String get label {
    final words = name
        .replaceAllMapped(RegExp('([a-z])([A-Z0-9])'), (m) => '${m[1]} ${m[2]}')
        .toLowerCase();
    return words[0].toUpperCase() + words.substring(1);
  }

  static ColorToken byName(String name) =>
      colorTokens.firstWhere((t) => t.name == name);
}

/// Every colour of a [ColorScheme], grouped.
final colorTokens = <ColorToken>[
  ColorToken(
    'primary',
    .brand,
    (s) => s.primary,
    (s, c) => s.copyWith(primary: c),
  ),
  ColorToken(
    'primaryForeground',
    .brand,
    (s) => s.primaryForeground,
    (s, c) => s.copyWith(primaryForeground: c),
  ),
  ColorToken('tint', .brand, (s) => s.tint, (s, c) => s.copyWith(tint: c)),
  ColorToken(
    'tintForeground',
    .brand,
    (s) => s.tintForeground,
    (s, c) => s.copyWith(tintForeground: c),
  ),
  ColorToken(
    'accent',
    .brand,
    (s) => s.accent,
    (s, c) => s.copyWith(accent: c),
  ),
  ColorToken(
    'accentForeground',
    .brand,
    (s) => s.accentForeground,
    (s, c) => s.copyWith(accentForeground: c),
  ),
  ColorToken(
    'accentBorder',
    .brand,
    (s) => s.accentBorder,
    (s, c) => s.copyWith(accentBorder: c),
  ),
  ColorToken('ring', .brand, (s) => s.ring, (s, c) => s.copyWith(ring: c)),
  ColorToken(
    'selection',
    .brand,
    (s) => s.selection,
    (s, c) => s.copyWith(selection: c),
  ),
  ColorToken(
    'background',
    .surfaces,
    (s) => s.background,
    (s, c) => s.copyWith(background: c),
  ),
  ColorToken('card', .surfaces, (s) => s.card, (s, c) => s.copyWith(card: c)),
  ColorToken(
    'popover',
    .surfaces,
    (s) => s.popover,
    (s, c) => s.copyWith(popover: c),
  ),
  ColorToken('bar', .surfaces, (s) => s.bar, (s, c) => s.copyWith(bar: c)),
  ColorToken(
    'foreground',
    .text,
    (s) => s.foreground,
    (s, c) => s.copyWith(foreground: c),
  ),
  ColorToken(
    'cardForeground',
    .text,
    (s) => s.cardForeground,
    (s, c) => s.copyWith(cardForeground: c),
  ),
  ColorToken(
    'popoverForeground',
    .text,
    (s) => s.popoverForeground,
    (s, c) => s.copyWith(popoverForeground: c),
  ),
  ColorToken(
    'foregroundSubtle',
    .text,
    (s) => s.foregroundSubtle,
    (s, c) => s.copyWith(foregroundSubtle: c),
  ),
  ColorToken(
    'mutedForeground',
    .text,
    (s) => s.mutedForeground,
    (s, c) => s.copyWith(mutedForeground: c),
  ),
  ColorToken(
    'secondary',
    .fills,
    (s) => s.secondary,
    (s, c) => s.copyWith(secondary: c),
  ),
  ColorToken(
    'secondaryForeground',
    .fills,
    (s) => s.secondaryForeground,
    (s, c) => s.copyWith(secondaryForeground: c),
  ),
  ColorToken('muted', .fills, (s) => s.muted, (s, c) => s.copyWith(muted: c)),
  ColorToken(
    'border',
    .lines,
    (s) => s.border,
    (s, c) => s.copyWith(border: c),
  ),
  ColorToken('input', .lines, (s) => s.input, (s, c) => s.copyWith(input: c)),
  ColorToken(
    'borderStrong',
    .lines,
    (s) => s.borderStrong,
    (s, c) => s.copyWith(borderStrong: c),
  ),
  ColorToken(
    'destructive',
    .status,
    (s) => s.destructive,
    (s, c) => s.copyWith(destructive: c),
  ),
  ColorToken(
    'destructiveForeground',
    .status,
    (s) => s.destructiveForeground,
    (s, c) => s.copyWith(destructiveForeground: c),
  ),
  ColorToken(
    'success',
    .status,
    (s) => s.success,
    (s, c) => s.copyWith(success: c),
  ),
  ColorToken(
    'successMuted',
    .status,
    (s) => s.successMuted,
    (s, c) => s.copyWith(successMuted: c),
  ),
  ColorToken(
    'warning',
    .status,
    (s) => s.warning,
    (s, c) => s.copyWith(warning: c),
  ),
  ColorToken(
    'chart1',
    .charts,
    (s) => s.chart1,
    (s, c) => s.copyWith(chart1: c),
  ),
  ColorToken(
    'chart2',
    .charts,
    (s) => s.chart2,
    (s, c) => s.copyWith(chart2: c),
  ),
  ColorToken(
    'chart3',
    .charts,
    (s) => s.chart3,
    (s, c) => s.copyWith(chart3: c),
  ),
  ColorToken(
    'chart4',
    .charts,
    (s) => s.chart4,
    (s, c) => s.copyWith(chart4: c),
  ),
  ColorToken(
    'chart5',
    .charts,
    (s) => s.chart5,
    (s, c) => s.copyWith(chart5: c),
  ),
  ColorToken(
    'sidebar',
    .sidebar,
    (s) => s.sidebar,
    (s, c) => s.copyWith(sidebar: c),
  ),
  ColorToken(
    'sidebarForeground',
    .sidebar,
    (s) => s.sidebarForeground,
    (s, c) => s.copyWith(sidebarForeground: c),
  ),
  ColorToken(
    'sidebarPrimary',
    .sidebar,
    (s) => s.sidebarPrimary,
    (s, c) => s.copyWith(sidebarPrimary: c),
  ),
  ColorToken(
    'sidebarPrimaryForeground',
    .sidebar,
    (s) => s.sidebarPrimaryForeground,
    (s, c) => s.copyWith(sidebarPrimaryForeground: c),
  ),
  ColorToken(
    'sidebarAccent',
    .sidebar,
    (s) => s.sidebarAccent,
    (s, c) => s.copyWith(sidebarAccent: c),
  ),
  ColorToken(
    'sidebarAccentForeground',
    .sidebar,
    (s) => s.sidebarAccentForeground,
    (s, c) => s.copyWith(sidebarAccentForeground: c),
  ),
  ColorToken(
    'sidebarBorder',
    .sidebar,
    (s) => s.sidebarBorder,
    (s, c) => s.copyWith(sidebarBorder: c),
  ),
  ColorToken(
    'sidebarRing',
    .sidebar,
    (s) => s.sidebarRing,
    (s, c) => s.copyWith(sidebarRing: c),
  ),
];

/// The colours picked by hand for one brightness, by token name.
///
/// A value type, so two configurations with the same edits are equal.
@immutable
class ColorEdits {
  const ColorEdits([this.colors = const {}]);

  final Map<String, Color> colors;

  bool get isEmpty => colors.isEmpty;

  Color? operator [](String name) => colors[name];

  ColorEdits withColor(String name, Color? color) {
    final next = {...colors};
    if (color == null) {
      next.remove(name);
    } else {
      next[name] = color;
    }
    return ColorEdits(Map.unmodifiable(next));
  }

  /// These edits without the chart colours, for a new chart palette.
  ColorEdits get withoutCharts {
    if (!colors.keys.any((name) => name.startsWith('chart'))) return this;
    return ColorEdits(
      Map.unmodifiable({
        for (final MapEntry(:key, :value) in colors.entries)
          if (!key.startsWith('chart')) key: value,
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ColorEdits && mapEquals(other.colors, colors);

  @override
  int get hashCode => Object.hashAllUnordered([
    for (final MapEntry(:key, :value) in colors.entries)
      Object.hash(key, value),
  ]);
}

/// Where a token's colour in one brightness comes from.
enum ColorSource {
  /// The scheme's own.
  scheme,

  /// Picked by hand in this brightness.
  pinned,

  /// Derived from a colour picked in the other brightness.
  derived,
}

/// [base] with [own] edits applied and every edit made only in the other
/// brightness carried over: the other side's change from its scheme
/// ([otherBase] to the edit) re-applied to this side's colour.
ColorScheme applyColorEdits({
  required ColorScheme base,
  required ColorScheme otherBase,
  required ColorEdits own,
  required ColorEdits other,
}) {
  var scheme = base;
  for (final token in colorTokens) {
    final pinned = own[token.name];
    if (pinned != null) {
      scheme = token.write(scheme, pinned);
      continue;
    }
    final edited = other[token.name];
    if (edited == null) continue;
    scheme = token.write(
      scheme,
      deriveCounterpart(
        from: token.read(otherBase),
        to: edited,
        counterpart: token.read(base),
      ),
    );
  }
  return scheme;
}

/// Carries a change of colour, [from] → [to], over to [counterpart], the
/// same token in the other brightness.
///
/// In OKLCH: the counterpart takes the new hue, its strength scaled as the
/// edit scaled it (or the edit's own, where the original was grey), half
/// the change in lightness (a dark palette sits elsewhere on the lightness
/// scale, and a full shift there reads as twice the change) and the change
/// in opacity.
Color deriveCounterpart({
  required Color from,
  required Color to,
  required Color counterpart,
}) {
  final a = Oklch.of(from);
  final b = Oklch.of(to);
  final c = Oklch.of(counterpart);
  const grey = .02;
  final chroma = a.c < grey ? b.c : c.c * (b.c / a.c);
  final lightness = (c.l + (b.l - a.l) * .5).clamp(0.0, 1.0);
  final alpha = from.a == 0 ? to.a : (counterpart.a * to.a / from.a);
  return Oklch(
    lightness,
    chroma,
    b.c < grey && c.c >= grey ? c.h : b.h,
  ).toColor(alpha: alpha.clamp(0.0, 1.0));
}

/// A colour in OKLCH: lightness 0–1, chroma, hue in degrees.
@immutable
class Oklch {
  const Oklch(this.l, this.c, this.h);

  factory Oklch.of(Color color) {
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
    return Oklch(
      lightness,
      math.sqrt(aa * aa + bb * bb),
      (math.atan2(bb, aa) * 180 / math.pi + 360) % 360,
    );
  }

  final double l;
  final double c;
  final double h;

  /// The sRGB colour, its chroma lowered until it fits.
  Color toColor({double alpha = 1}) {
    for (var chroma = c; ; chroma = math.max(chroma - .002, 0)) {
      final rgb = _toRgb(chroma);
      if (rgb != null || chroma == 0) {
        final (r, g, b) = rgb ?? (l, l, l);
        return Color.from(alpha: alpha, red: r, green: g, blue: b);
      }
    }
  }

  (double, double, double)? _toRgb(double chroma) {
    final a = chroma * math.cos(h * math.pi / 180);
    final b = chroma * math.sin(h * math.pi / 180);
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
}
