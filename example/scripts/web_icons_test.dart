import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/common/una_logo.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// Paints the web app's icons in `web/` from the Una mark, in the light
/// primary of the editor's Slate palette.
///
/// Not part of the suite (it is outside `test/`). From `example/`:
///
///     flutter test scripts/web_icons_test.dart
///
/// The favicon and the plain icons are the [UnaLogo] widget itself,
/// rendered at a higher pixel ratio; the full-bleed squares a platform
/// masks itself (the maskable icons, the Apple touch icon) are its
/// [UnaMarkPainter] with square corners.
void main() {
  const slateSeed = Color(0xFF64748B);

  testWidgets('writes the web icons', (tester) async {
    final scheme = ColorScheme.fromSeed(slateSeed);
    final theme = ThemeData(colorScheme: scheme);
    // ignore: avoid_print
    print(
      'Slate primary ${_hex(scheme.primary)}, ink '
      '${_hex(scheme.primaryForeground)}, page ${_hex(scheme.background)}',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      Theme(
        data: theme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: const UnaLogo(showWordmark: false),
            ),
          ),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final tile = boundary.size.width;

    Future<void> logo(String path, int size) async {
      final image = await boundary.toImage(pixelRatio: size / tile);
      await _write(path, image);
    }

    Future<void> square(String path, int size, {required double glyph}) async {
      final recorder = ui.PictureRecorder();
      UnaMarkPainter(
        color: scheme.primary,
        ink: scheme.primaryForeground,
        radius: 0,
        glyph: glyph,
      ).paint(Canvas(recorder), Size.square(size.toDouble()));
      await _write(path, await recorder.endRecording().toImage(size, size));
    }

    await tester.runAsync(() async {
      await logo('web/favicon.png', 32);
      await logo('web/icons/Icon-192.png', 192);
      await logo('web/icons/Icon-512.png', 512);
      // iOS rounds the touch icon itself and fills transparency with black.
      await square('web/icons/apple-touch-icon.png', 180, glyph: .62);
      // The art inside the maskable safe zone, the middle 80 %.
      await square('web/icons/Icon-maskable-192.png', 192, glyph: .5);
      await square('web/icons/Icon-maskable-512.png', 512, glyph: .5);
    });
  });
}

Future<void> _write(String path, ui.Image image) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

String _hex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
