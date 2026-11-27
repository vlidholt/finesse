import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:una/src/liquid_glass/liquid_glass.dart' show LiquidGlassBridge;
import 'package:una/una.dart';

import '../una_harness.dart';

void main() {
  for (final kind in ['ours', 'package']) {
    for (final speed in [3.0, 25.0]) {
      testWidgets('capture $kind $speed', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final key = GlobalKey();
        var value = .3;
        await pumpUna(
          tester,
          RepaintBoundary(
            key: key,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, -0.97),
                  colors: [Color(0xffffffff), Color(0xffe8ecf2)],
                  tileMode: TileMode.repeated,
                ),
              ),
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState) => SizedBox(
                    width: 300,
                    child: kind == 'ours'
                        ? Slider(
                            value: value,
                            onChanged: (v) => setState(() => value = v),
                          )
                        : LiquidGlassBridge(
                            child: lg.GlassSlider(
                              value: value,
                              thumbRadius: 14,
                              activeColor: const Color(0xff4b72a8),
                              onChanged: (v) => setState(() => value = v),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          formFactor: FormFactor.mobile,
          theme: ThemeData(
            liquidGlass: const LiquidGlassTheme(mode: LiquidGlassMode.always),
          ),
        );
        final c = tester.getCenter(find.byKey(key));
        final g = await tester.startGesture(
          Offset(c.dx - 150 + 300 * .3, c.dy),
        );
        for (var i = 0; i < 10; i++) {
          await g.moveBy(Offset(speed, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.runAsync(() async {
          final b =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await (b.debugLayer! as OffsetLayer).toImage(
            Offset.zero & b.size,
            pixelRatio: 3,
          );
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('build/imp_${kind}_${speed.round()}.png')
              .writeAsBytesSync(png!.buffer.asUint8List());
        });
        await g.up();
        await tester.pump(const Duration(seconds: 1));
        debugDefaultTargetPlatformOverride = null;
      });
    }
  }
}
