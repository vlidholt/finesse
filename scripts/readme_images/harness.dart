import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// `DefaultStyles` is what `UnaApp` puts under a theme (the root icon
// theme and selection colours). A panel with a theme of its own needs it too.
import 'package:una/src/theme/theme_scope.dart' show DefaultStyles;
import 'package:una/una.dart';

/// Where the images are written, relative to the package root.
const outputDirectory = 'doc/images';

/// Where the lossless renders are kept before they are encoded.
const renderDirectory = 'build/readme_images';

/// The text font of every image: Geist, which the default look was designed
/// around. A variable font: one file serves every weight.
const fontFamily = 'Geist';

/// Loads Geist and the bundled Phosphor icon fonts.
///
/// flutter_test draws every glyph of a font it does not know as a box, so
/// nothing would be legible without this.
Future<void> loadFonts() async {
  Future<void> load(String family, String path) async {
    final bytes = File(path).readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  await load(fontFamily, 'scripts/readme_images/fonts/Geist.ttf');
  const phosphor = {
    'PhosphorRegular': 'Phosphor',
    'PhosphorBold': 'Phosphor-Bold',
    'PhosphorFill': 'Phosphor-Fill',
    'PhosphorLight': 'Phosphor-Light',
    'PhosphorThin': 'Phosphor-Thin',
    'PhosphorDuotone': 'Phosphor-Duotone',
  };
  for (final MapEntry(key: family, value: file) in phosphor.entries) {
    await load('packages/una/$family', 'fonts/phosphor/$file.ttf');
  }
}

/// A theme for an image: [style] on [colorScheme], set in Geist.
ThemeData imageTheme({
  StyleTokens? style,
  ColorScheme? colorScheme,
  Brightness brightness = Brightness.light,
}) {
  return ThemeData(
    style: style,
    brightness: brightness,
    colorScheme:
        colorScheme ??
        (brightness == Brightness.light
            ? const SlateColorScheme.light()
            : const SlateColorScheme.dark()),
    textTheme: TextTheme(family: fontFamily),
  );
}

/// Renders [scene] at [size] logical pixels, at twice that resolution, to
/// `build/readme_images/<name>.png`, and encodes it as
/// `doc/images/<name>.webp` with `cwebp`.
///
/// WebP keeps the images about a fifth of the size of a PNG with no visible
/// loss in the text.
///
/// The scene is pumped for [settle] in small steps first, so entrances
/// (an open menu, a toast) have finished.
Future<void> shoot(
  WidgetTester tester,
  String name,
  Size size,
  Widget scene, {
  Duration settle = const Duration(milliseconds: 1500),
  double pixelRatio = 2,
}) async {
  debugDisableShadows = false;
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    UnaApp(
      formFactor: FormFactor.desktop,
      theme: imageTheme(),
      home: RepaintBoundary(key: key, child: scene),
    ),
  );
  const step = Duration(milliseconds: 50);
  for (var t = Duration.zero; t < settle; t += step) {
    await tester.pump(step);
  }

  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final png = File('$renderDirectory/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
    final webp = '$outputDirectory/$name.webp';
    Directory(outputDirectory).createSync(recursive: true);
    final ProcessResult result;
    try {
      result = await Process.run('cwebp', [
        '-quiet',
        '-q',
        '88',
        '-m',
        '6',
        '-metadata',
        'none',
        png.path,
        '-o',
        webp,
      ]);
    } on ProcessException {
      fail(
        'cwebp was not found. Install it (brew install webp, or apt install '
        'webp) and run again; the PNG is in ${png.path}.',
      );
    }
    if (result.exitCode != 0) fail('cwebp failed: ${result.stderr}');
    final kb = (File(webp).lengthSync() / 1024).round();
    // ignore: avoid_print
    print('Wrote $webp ($kb KB)');
  });
  debugDisableShadows = true;
}

/// A part of an image under a theme of its own.
///
/// It gives its subtree what `UnaApp` gives an app: the theme at
/// [formFactor], the default text and icon styles, the page background and
/// an overlay of its own, so a menu opened inside is drawn inside and under
/// this theme. With a [size] it also tells its subtree that is the screen,
/// with [padding] as the system's safe area.
class Panel extends StatelessWidget {
  /// Creates a panel.
  const Panel({
    required this.theme,
    required this.child,
    this.formFactor = FormFactor.desktop,
    this.size,
    this.padding = EdgeInsets.zero,
    this.background = true,
    super.key,
  });

  /// The theme of the subtree.
  final ThemeData theme;

  /// The form factor the theme is resolved for.
  final FormFactor formFactor;

  /// The screen size the subtree is told about, and the panel's size.
  final Size? size;

  /// The safe area the subtree is told about.
  final EdgeInsets padding;

  /// Whether to fill the panel with the theme's background colour.
  final bool background;

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = theme.withFormFactor(formFactor);
    var result = Overlay.wrap(child: child);
    if (background) {
      result = ColoredBox(color: data.colorScheme.background, child: result);
    }
    result = DefaultTextStyle(
      style: data.textTheme.p.copyWith(color: data.colorScheme.foreground),
      child: result,
    );
    result = Theme(
      data: data,
      child: DefaultStyles(data: data, child: result),
    );
    if (size case final size?) {
      result = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          size: size,
          padding: padding,
          viewPadding: padding,
          platformBrightness: data.brightness,
        ),
        child: SizedBox.fromSize(size: size, child: result),
      );
    }
    return result;
  }
}
