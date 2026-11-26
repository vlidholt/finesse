// Generates the six built-in colour schemes in lib/src/theme/color_scheme/.
//
//   dart run scripts/generate_color_schemes.dart
//
// Every scheme is the Ocean scheme's ladder of lightness — measured,
// hand-tuned and held to the package's contrast tests — with two hues of
// its own: one for its greys (and how far they lean towards it) and one for
// its accent. Lightness is kept in OKLCH, so an accent of one hue is as
// strong as an accent of another: no theme is loud and no theme washed
// out. Graphite has no accent hue; its primary is its ink.
//
// Status colours (destructive, success, warning) and the chart ramp's last
// three steps are the same in every scheme.

import 'dart:io';
import 'dart:math' as math;

void main() {
  for (final spec in _specs) {
    final file = File('lib/src/theme/color_scheme/${spec.file}.dart');
    file.writeAsStringSync(_render(spec));
    stdout.writeln('wrote ${file.path}');
  }
}

/// How a token follows a scheme's hues.
enum _Role {
  /// A grey: the template's lightness, the scheme's grey hue.
  neutral,

  /// A colour of the accent: the template's lightness, the accent hue.
  accent,

  /// The same in every scheme.
  fixed,
}

class _Spec {
  const _Spec({
    required this.name,
    required this.file,
    required this.doc,
    required this.greyHue,
    required this.greyChroma,
    this.accentHue,
  });

  final String name;
  final String file;
  final String doc;

  /// The hue the greys lean towards, in degrees.
  final double greyHue;

  /// How far they lean, relative to Ocean's greys.
  final double greyChroma;

  /// The accent's hue, or null for a monochrome scheme.
  final double? accentHue;

  String get className => '${name}ColorScheme';
}

const _specs = [
  _Spec(
    name: 'Ocean',
    file: 'ocean',
    doc: "Una's default palette: a standard blue on a cool grey page.",
    greyHue: _oceanGreyHue,
    greyChroma: 1,
    accentHue: _oceanAccentHue,
  ),
  _Spec(
    name: 'Graphite',
    file: 'graphite',
    doc: 'Monochrome: near-black ink as the primary, near-white in the dark.',
    greyHue: 255,
    greyChroma: .35,
  ),
  _Spec(
    name: 'Forest',
    file: 'forest',
    doc: 'A deep green on greys with a breath of sage.',
    greyHue: 165,
    greyChroma: .5,
    accentHue: 152,
  ),
  _Spec(
    name: 'Iris',
    file: 'iris',
    doc: 'A clear violet on cool, faintly violet greys.',
    greyHue: 290,
    greyChroma: .7,
    accentHue: 292,
  ),
  _Spec(
    name: 'Ember',
    file: 'ember',
    doc: 'A burnt orange on warm stone greys.',
    greyHue: 65,
    greyChroma: .7,
    accentHue: 42,
  ),
  _Spec(
    name: 'Rose',
    file: 'rose',
    doc: 'A rose red on soft, warm greys.',
    greyHue: 20,
    greyChroma: .5,
    accentHue: 12,
  ),
];

// The hues of Ocean's own greys and accent, measured from its template.
const _oceanGreyHue = 262.0;
const _oceanAccentHue = 263.0;

/// One token of the template: its Ocean value and how it follows a scheme.
typedef _Token = (String name, int argb, _Role role);

/// Ocean, light: the template every scheme's light palette is made from.
const _light = <_Token>[
  ('background', 0xfff4f5f7, _Role.neutral),
  ('foreground', 0xff161a22, _Role.neutral),
  ('card', 0xffffffff, _Role.fixed),
  ('cardForeground', 0xff161a22, _Role.neutral),
  ('popover', 0xffffffff, _Role.fixed),
  ('popoverForeground', 0xff161a22, _Role.neutral),
  ('primary', 0xff2563eb, _Role.accent),
  ('primaryForeground', 0xffffffff, _Role.fixed),
  ('secondary', 0x14161a22, _Role.neutral),
  ('secondaryForeground', 0xff161a22, _Role.neutral),
  ('muted', 0x0b161a22, _Role.neutral),
  ('mutedForeground', 0xff5f6775, _Role.neutral),
  ('accent', 0xffeaf1fe, _Role.accent),
  ('accentForeground', 0xff1d4ed8, _Role.accent),
  ('destructive', 0xffdc2626, _Role.fixed),
  ('destructiveForeground', 0xffffffff, _Role.fixed),
  ('border', 0x17161a22, _Role.neutral),
  ('input', 0x17161a22, _Role.neutral),
  ('ring', 0xff2563eb, _Role.accent),
  ('selection', 0x3d2563eb, _Role.accent),
  ('chart1', 0xff2563eb, _Role.accent),
  ('chart2', 0xff60a5fa, _Role.accent),
  ('chart3', 0xff15803d, _Role.fixed),
  ('chart4', 0xffb45309, _Role.fixed),
  ('chart5', 0xffdc2626, _Role.fixed),
  ('sidebar', 0xffffffff, _Role.fixed),
  ('sidebarForeground', 0xff161a22, _Role.neutral),
  ('sidebarPrimary', 0xff2563eb, _Role.accent),
  ('sidebarPrimaryForeground', 0xffffffff, _Role.fixed),
  ('sidebarAccent', 0xffeaf1fe, _Role.accent),
  ('sidebarAccentForeground', 0xff1d4ed8, _Role.accent),
  ('sidebarBorder', 0x17161a22, _Role.neutral),
  ('sidebarRing', 0xff2563eb, _Role.accent),
  ('foregroundSubtle', 0xff3a414e, _Role.neutral),
  ('tint', 0xff1d4ed8, _Role.accent),
  ('tintForeground', 0xffffffff, _Role.fixed),
  ('success', 0xff13753a, _Role.fixed),
  ('successMuted', 0xffe7f3ec, _Role.fixed),
  ('warning', 0xffb45309, _Role.fixed),
  ('borderStrong', 0x2e161a22, _Role.neutral),
  ('accentBorder', 0x522563eb, _Role.accent),
  ('bar', 0xffffffff, _Role.fixed),
];

/// Ocean, dark.
const _dark = <_Token>[
  ('background', 0xff141a26, _Role.neutral),
  ('foreground', 0xffeef1f5, _Role.neutral),
  ('card', 0xff1c222e, _Role.neutral),
  ('cardForeground', 0xffeef1f5, _Role.neutral),
  ('popover', 0xff1c222e, _Role.neutral),
  ('popoverForeground', 0xffeef1f5, _Role.neutral),
  ('primary', 0xff2563eb, _Role.accent),
  ('primaryForeground', 0xffffffff, _Role.fixed),
  ('secondary', 0x1ae8edf5, _Role.neutral),
  ('secondaryForeground', 0xffeef1f5, _Role.neutral),
  ('muted', 0x0fe8edf5, _Role.neutral),
  ('mutedForeground', 0xff97a1af, _Role.neutral),
  ('accent', 0x522563eb, _Role.accent),
  ('accentForeground', 0xff93c5fd, _Role.accent),
  ('destructive', 0xffdc2626, _Role.fixed),
  ('destructiveForeground', 0xffffffff, _Role.fixed),
  ('border', 0x14e8edf5, _Role.neutral),
  ('input', 0x14e8edf5, _Role.neutral),
  ('ring', 0xff6eb0fb, _Role.accent),
  ('selection', 0x4c6eb0fb, _Role.accent),
  ('chart1', 0xff6eb0fb, _Role.accent),
  ('chart2', 0xff2563eb, _Role.accent),
  ('chart3', 0xff86d3a8, _Role.fixed),
  ('chart4', 0xfffbbf24, _Role.fixed),
  ('chart5', 0xfff87171, _Role.fixed),
  ('sidebar', 0xff1c222e, _Role.neutral),
  ('sidebarForeground', 0xffeef1f5, _Role.neutral),
  ('sidebarPrimary', 0xff6eb0fb, _Role.accent),
  ('sidebarPrimaryForeground', 0xff141a26, _Role.neutral),
  ('sidebarAccent', 0x522563eb, _Role.accent),
  ('sidebarAccentForeground', 0xff93c5fd, _Role.accent),
  ('sidebarBorder', 0x14e8edf5, _Role.neutral),
  ('sidebarRing', 0xff6eb0fb, _Role.accent),
  ('foregroundSubtle', 0xffc6ccd6, _Role.neutral),
  ('tint', 0xff6eb0fb, _Role.accent),
  ('tintForeground', 0xff141a26, _Role.neutral),
  ('success', 0xff86d3a8, _Role.fixed),
  ('successMuted', 0x243e8e67, _Role.fixed),
  ('warning', 0xfffbbf24, _Role.fixed),
  ('borderStrong', 0x29e8edf5, _Role.neutral),
  ('accentBorder', 0x666eb0fb, _Role.accent),
  ('bar', 0xff171d29, _Role.neutral),
];

/// Graphite's accent tokens, which follow its ink rather than a hue: the
/// primary is the foreground, its washes are greys.
int? _graphite(String name, bool dark, Map<String, int> greys) {
  final ink = greys['foreground']!;
  final page = greys['background']!;
  final rgb = ink & 0xffffff;
  return switch ((name, dark)) {
    ('primary' || 'ring' || 'chart1' || 'sidebarPrimary' || 'sidebarRing', _) ||
    ('tint' || 'accentForeground' || 'sidebarAccentForeground', _) => ink,
    (
      'primaryForeground' || 'tintForeground' || 'sidebarPrimaryForeground',
      _,
    ) =>
      dark ? page : 0xffffffff,
    ('accent' || 'sidebarAccent', false) => 0x12000000 | rgb,
    ('accent' || 'sidebarAccent', true) => 0x1f000000 | rgb,
    ('selection', _) => 0x33000000 | rgb,
    ('accentBorder', _) => 0x3d000000 | rgb,
    ('chart2', _) => greys['mutedForeground'],
    _ => null,
  };
}

String _render(_Spec spec) {
  final light = _resolve(spec, _light, dark: false);
  final dark = _resolve(spec, _dark, dark: true);
  String hex(int argb) => argb.toRadixString(16).padLeft(8, '0');
  String fields(Map<String, int> values) => [
    for (final MapEntry(:key, :value) in values.entries)
      '    super.$key = const Color(0x${hex(value)}),',
  ].join('\n');
  final names = [for (final (name, _, _) in _light) name];
  bool optional(String name) =>
      name.startsWith('chart') || _optional.contains(name);
  final parameters = [
    for (final n in names)
      if (optional(n)) '    super.$n,' else '    required super.$n,',
  ].join('\n');

  return '''
// GENERATED by scripts/generate_color_schemes.dart. Do not edit by hand:
// change the generator and run it again.

import 'package:flutter/widgets.dart';
import 'package:una/src/theme/color_scheme/base.dart';

/// ${spec.doc}
///
/// One of the six built-in schemes, all made from one ladder of lightness
/// so none is louder than another. It sets every optional token, and its
/// fills, borders and muted surfaces are translucent washes of the
/// foreground, so they sit correctly on glass.
@immutable
class ${spec.className} extends ColorScheme {
  /// Creates a scheme from explicit colours.
  const ${spec.className}({
$parameters
    super.custom,
  });

  /// The light palette.
  const ${spec.className}.light({
${fields(light)}
    super.custom,
  });

  /// The dark palette.
  const ${spec.className}.dark({
${fields(dark)}
    super.custom,
  });
}
''';
}

const _optional = {
  'sidebar',
  'sidebarForeground',
  'sidebarPrimary',
  'sidebarPrimaryForeground',
  'sidebarAccent',
  'sidebarAccentForeground',
  'sidebarBorder',
  'sidebarRing',
  'foregroundSubtle',
  'tint',
  'tintForeground',
  'success',
  'successMuted',
  'warning',
  'borderStrong',
  'accentBorder',
  'bar',
};

Map<String, int> _resolve(
  _Spec spec,
  List<_Token> tokens, {
  required bool dark,
}) {
  // Ocean is the template itself, not a round trip through OKLCH.
  if (spec.name == 'Ocean') {
    return {for (final (name, argb, _) in tokens) name: argb};
  }
  final out = <String, int>{};
  for (final (name, argb, role) in tokens) {
    out[name] = switch (role) {
      _Role.fixed => argb,
      _Role.neutral => _shift(argb, spec.greyHue, spec.greyChroma),
      _Role.accent when spec.accentHue == null => argb, // replaced below
      _Role.accent => _shift(argb, spec.accentHue!, 1),
    };
  }
  if (spec.accentHue == null) {
    for (final (name, _, role) in tokens) {
      if (role == _Role.accent || name.endsWith('Foreground')) {
        final value = _graphite(name, dark, out);
        if (value != null) out[name] = value;
      }
    }
  }
  return out;
}

/// [argb] with its OKLCH hue moved to [hue] and its chroma scaled by
/// [chroma], keeping its lightness and alpha; brought into sRGB by
/// lowering the chroma, never the lightness.
int _shift(int argb, double hue, double chroma) {
  final alpha = argb >>> 24;
  final (l, c, _) = _toOklch(argb);
  var target = c * chroma;
  var rgb = _fromOklch(l, target, hue);
  while (rgb == null && target > 0) {
    target -= .002;
    rgb = _fromOklch(l, math.max(target, 0), hue);
  }
  return (alpha << 24) | rgb!;
}

(double, double, double) _toOklch(int argb) {
  double lin(int v) {
    final c = v / 255;
    return c <= .04045
        ? c / 12.92
        : math.pow((c + .055) / 1.055, 2.4) as double;
  }

  final r = lin((argb >> 16) & 0xff);
  final g = lin((argb >> 8) & 0xff);
  final b = lin(argb & 0xff);
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
  final L = .2104542553 * l + .7936177850 * m - .0040720468 * s;
  final A = 1.9779984951 * l - 2.4285922050 * m + .4505937099 * s;
  final B = .0259040371 * l + .7827717662 * m - .8086757660 * s;
  final h = (math.atan2(B, A) * 180 / math.pi + 360) % 360;
  return (L, math.sqrt(A * A + B * B), h);
}

/// The sRGB colour (no alpha) for an OKLCH colour, or null outside sRGB.
int? _fromOklch(double L, double C, double h) {
  final a = C * math.cos(h * math.pi / 180);
  final b = C * math.sin(h * math.pi / 180);
  final l = math.pow(L + .3963377774 * a + .2158037573 * b, 3);
  final m = math.pow(L - .1055613458 * a - .0638541728 * b, 3);
  final s = math.pow(L - .0894841775 * a - 1.2914855480 * b, 3);
  final rl = 4.0767416621 * l - 3.3077115913 * m + .2309699292 * s;
  final gl = -1.2684380046 * l + 2.6097574011 * m - .3413193965 * s;
  final bl = -.0041960863 * l - .7034186147 * m + 1.7076147010 * s;
  int? channel(double x) {
    if (x < -1e-4 || x > 1 + 1e-4) return null;
    final v = x.clamp(0.0, 1.0);
    final c = v <= .0031308 ? 12.92 * v : 1.055 * math.pow(v, 1 / 2.4) - .055;
    return (c * 255).round().clamp(0, 255);
  }

  final r = channel(rl);
  final g = channel(gl);
  final bb = channel(bl);
  if (r == null || g == null || bb == null) return null;
  return (r << 16) | (g << 8) | bb;
}
