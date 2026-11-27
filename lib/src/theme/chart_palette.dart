import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The colours charts draw their series in: five for a light page and five
/// for a dark one.
///
/// `ThemeData(chartPalette:)` writes a palette into the colour scheme's
/// `chart1`…`chart5`, which `LineChart`, `BarChart`, `DonutChart`,
/// `Sparkline` and `ChartLegend` read (a `ChartTheme.palette` still wins for
/// the charts under it). The built-in colour schemes chart in [green].
///
/// The presets follow shadcn/ui's chart themes: five shades of one of
/// Tailwind's colours, plus [multicolor], shadcn's categorical set. The
/// shades alternate between lighter and darker around the one a single
/// series is drawn in, so neighbouring series and slices stay apart, and
/// that first shade is the one that reads best on the page: a step darker
/// on a light page, a step lighter on a dark one.
///
/// Make your own with any colours:
///
/// ```dart
/// ThemeData(
///   chartPalette: const ChartPalette(
///     light: [Color(0xff0f766e), Color(0xfff59e0b), Color(0xff6366f1)],
///     dark: [Color(0xff2dd4bf), Color(0xfffbbf24), Color(0xff818cf8)],
///   ),
/// )
/// ```
///
/// A palette may hold any number of colours: the scheme takes the first
/// five, repeating from the start when there are fewer, and a chart with
/// more series than colours starts again from the first.
@immutable
class ChartPalette {
  /// A palette with [light] colours for a light page and [dark] ones for a
  /// dark page. Neither may be empty.
  const ChartPalette({required this.light, required this.dark});

  /// A palette with the same [colors] on a light and a dark page.
  const ChartPalette.same(List<Color> colors)
    : this(light: colors, dark: colors);

  /// The colours on a light page, first series first.
  final List<Color> light;

  /// The colours on a dark page, first series first.
  final List<Color> dark;

  /// The colours for a page of [brightness].
  List<Color> of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// The five colours `chart1`…`chart5` take for [brightness].
  List<Color> tokensFor(Brightness brightness) {
    final colors = of(brightness);
    return [for (var i = 0; i < 5; i++) colors[i % colors.length]];
  }

  /// shadcn/ui's categorical chart colours: an orange, a teal, a deep blue,
  /// a yellow and an amber on a light page; a blue, an emerald, an amber, a
  /// purple and a rose on a dark one.
  static const multicolor = ChartPalette(
    light: [
      Color(0xfff54900),
      Color(0xff009689),
      Color(0xff104e64),
      Color(0xffffb900),
      Color(0xfffe9a00),
    ],
    dark: [
      Color(0xff1447e6),
      Color(0xff00bc7d),
      Color(0xfffe9a00),
      Color(0xffad46ff),
      Color(0xffff2056),
    ],
  );

  /// Shades of Tailwind's slate.
  static const slate = ChartPalette(
    light: [
      Color(0xff45556c),
      Color(0xff90a1b9),
      Color(0xff1d293d),
      Color(0xff62748e),
      Color(0xff314158),
    ],
    dark: [
      Color(0xff62748e),
      Color(0xffcad5e2),
      Color(0xff314158),
      Color(0xff90a1b9),
      Color(0xff45556c),
    ],
  );

  /// Shades of Tailwind's red.
  static const red = ChartPalette(
    light: [
      Color(0xffe7000b),
      Color(0xffff6467),
      Color(0xff9f0712),
      Color(0xfffb2c36),
      Color(0xffc10007),
    ],
    dark: [
      Color(0xfffb2c36),
      Color(0xffffa2a2),
      Color(0xffc10007),
      Color(0xffff6467),
      Color(0xffe7000b),
    ],
  );

  /// Shades of Tailwind's orange.
  static const orange = ChartPalette(
    light: [
      Color(0xfff54900),
      Color(0xffff8904),
      Color(0xff9f2d00),
      Color(0xffff6900),
      Color(0xffca3500),
    ],
    dark: [
      Color(0xffff6900),
      Color(0xffffb86a),
      Color(0xffca3500),
      Color(0xffff8904),
      Color(0xfff54900),
    ],
  );

  /// Shades of Tailwind's amber.
  static const amber = ChartPalette(
    light: [
      Color(0xffe17100),
      Color(0xffffb900),
      Color(0xff973c00),
      Color(0xfffe9a00),
      Color(0xffbb4d00),
    ],
    dark: [
      Color(0xfffe9a00),
      Color(0xffffd230),
      Color(0xffbb4d00),
      Color(0xffffb900),
      Color(0xffe17100),
    ],
  );

  /// Shades of Tailwind's lime.
  static const lime = ChartPalette(
    light: [
      Color(0xff5ea500),
      Color(0xff9ae600),
      Color(0xff3c6300),
      Color(0xff7ccf00),
      Color(0xff497d00),
    ],
    dark: [
      Color(0xff7ccf00),
      Color(0xffbbf451),
      Color(0xff497d00),
      Color(0xff9ae600),
      Color(0xff5ea500),
    ],
  );

  /// Shades of Tailwind's green. una's default.
  static const green = ChartPalette(
    light: [
      Color(0xff00a63e),
      Color(0xff05df72),
      Color(0xff016630),
      Color(0xff00c950),
      Color(0xff008236),
    ],
    dark: [
      Color(0xff00c950),
      Color(0xff7bf1a8),
      Color(0xff008236),
      Color(0xff05df72),
      Color(0xff00a63e),
    ],
  );

  /// Shades of Tailwind's emerald.
  static const emerald = ChartPalette(
    light: [
      Color(0xff009966),
      Color(0xff00d492),
      Color(0xff006045),
      Color(0xff00bc7d),
      Color(0xff007a55),
    ],
    dark: [
      Color(0xff00bc7d),
      Color(0xff5ee9b5),
      Color(0xff007a55),
      Color(0xff00d492),
      Color(0xff009966),
    ],
  );

  /// Shades of Tailwind's teal.
  static const teal = ChartPalette(
    light: [
      Color(0xff009689),
      Color(0xff00d5be),
      Color(0xff005f5a),
      Color(0xff00bba7),
      Color(0xff00786f),
    ],
    dark: [
      Color(0xff00bba7),
      Color(0xff46ecd5),
      Color(0xff00786f),
      Color(0xff00d5be),
      Color(0xff009689),
    ],
  );

  /// Shades of Tailwind's cyan.
  static const cyan = ChartPalette(
    light: [
      Color(0xff0092b8),
      Color(0xff00d3f2),
      Color(0xff005f78),
      Color(0xff00b8db),
      Color(0xff007595),
    ],
    dark: [
      Color(0xff00b8db),
      Color(0xff53eafd),
      Color(0xff007595),
      Color(0xff00d3f2),
      Color(0xff0092b8),
    ],
  );

  /// Shades of Tailwind's sky.
  static const sky = ChartPalette(
    light: [
      Color(0xff0084d1),
      Color(0xff00bcff),
      Color(0xff00598a),
      Color(0xff00a6f4),
      Color(0xff0069a8),
    ],
    dark: [
      Color(0xff00a6f4),
      Color(0xff74d4ff),
      Color(0xff0069a8),
      Color(0xff00bcff),
      Color(0xff0084d1),
    ],
  );

  /// Shades of Tailwind's blue.
  static const blue = ChartPalette(
    light: [
      Color(0xff155dfc),
      Color(0xff51a2ff),
      Color(0xff193cb8),
      Color(0xff2b7fff),
      Color(0xff1447e6),
    ],
    dark: [
      Color(0xff2b7fff),
      Color(0xff8ec5ff),
      Color(0xff1447e6),
      Color(0xff51a2ff),
      Color(0xff155dfc),
    ],
  );

  /// Shades of Tailwind's indigo.
  static const indigo = ChartPalette(
    light: [
      Color(0xff4f39f6),
      Color(0xff7c86ff),
      Color(0xff372aac),
      Color(0xff615fff),
      Color(0xff432dd7),
    ],
    dark: [
      Color(0xff615fff),
      Color(0xffa3b3ff),
      Color(0xff432dd7),
      Color(0xff7c86ff),
      Color(0xff4f39f6),
    ],
  );

  /// Shades of Tailwind's violet.
  static const violet = ChartPalette(
    light: [
      Color(0xff7f22fe),
      Color(0xffa684ff),
      Color(0xff5d0ec0),
      Color(0xff8e51ff),
      Color(0xff7008e7),
    ],
    dark: [
      Color(0xff8e51ff),
      Color(0xffc4b4ff),
      Color(0xff7008e7),
      Color(0xffa684ff),
      Color(0xff7f22fe),
    ],
  );

  /// Shades of Tailwind's purple.
  static const purple = ChartPalette(
    light: [
      Color(0xff9810fa),
      Color(0xffc27aff),
      Color(0xff6e11b0),
      Color(0xffad46ff),
      Color(0xff8200db),
    ],
    dark: [
      Color(0xffad46ff),
      Color(0xffdab2ff),
      Color(0xff8200db),
      Color(0xffc27aff),
      Color(0xff9810fa),
    ],
  );

  /// Shades of Tailwind's fuchsia.
  static const fuchsia = ChartPalette(
    light: [
      Color(0xffc800de),
      Color(0xffed6aff),
      Color(0xff8a0194),
      Color(0xffe12afb),
      Color(0xffa800b7),
    ],
    dark: [
      Color(0xffe12afb),
      Color(0xfff4a8ff),
      Color(0xffa800b7),
      Color(0xffed6aff),
      Color(0xffc800de),
    ],
  );

  /// Shades of Tailwind's pink.
  static const pink = ChartPalette(
    light: [
      Color(0xffe60076),
      Color(0xfffb64b6),
      Color(0xffa3004c),
      Color(0xfff6339a),
      Color(0xffc6005c),
    ],
    dark: [
      Color(0xfff6339a),
      Color(0xfffda5d5),
      Color(0xffc6005c),
      Color(0xfffb64b6),
      Color(0xffe60076),
    ],
  );

  /// Shades of Tailwind's rose.
  static const rose = ChartPalette(
    light: [
      Color(0xffec003f),
      Color(0xffff637e),
      Color(0xffa50036),
      Color(0xffff2056),
      Color(0xffc70036),
    ],
    dark: [
      Color(0xffff2056),
      Color(0xffffa1ad),
      Color(0xffc70036),
      Color(0xffff637e),
      Color(0xffec003f),
    ],
  );

  /// Every preset, in the order a picker shows them: [multicolor], [slate],
  /// then the colours around the wheel from [red] to [rose].
  static const presets = <ChartPalette>[
    multicolor,
    slate,
    red,
    orange,
    amber,
    lime,
    green,
    emerald,
    teal,
    cyan,
    sky,
    blue,
    indigo,
    violet,
    purple,
    fuchsia,
    pink,
    rose,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartPalette &&
          listEquals(other.light, light) &&
          listEquals(other.dark, dark);

  @override
  int get hashCode => Object.hash(Object.hashAll(light), Object.hashAll(dark));
}
