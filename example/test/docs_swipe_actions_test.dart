import 'package:example/docs/docs.dart';
import 'package:example/docs/pages/swipe_actions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/una.dart';

import 'support.dart' show setUpFonts;

/// The Swipe Actions page as the component library shows it, inside the
/// docs' `SelectionArea`: a row swipes with a finger and with a mouse, on a
/// phone and on a desktop.
void main() {
  setUpAll(setUpFonts);

  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    for (final width in [390.0, 1280.0]) {
      testWidgets('a ${kind.name} drag swipes a row at $width wide', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          UnaApp(
            builder: (context, child) => UnaMaterial(child: child!),
            home: Scaffold(body: ComponentDocPage(doc: swipeActionsDoc)),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        final row = find.text('Julian Reyes');
        final before = tester.getTopLeft(row).dx;
        final gesture = await tester.startGesture(
          tester.getCenter(row),
          kind: kind,
        );
        for (var i = 0; i < 10; i++) {
          await gesture.moveBy(const Offset(-12, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(tester.getTopLeft(row).dx, lessThan(before - 60));
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 500));
      });
    }
  }
}
