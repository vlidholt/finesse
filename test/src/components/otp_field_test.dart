import 'dart:ui' as ui;

import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/otp_field.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/color_scheme/neutral.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/material.dart' hide TextField, Theme, ThemeData;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child, {ThemeData? theme}) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      theme: theme,
      home: Scaffold(body: child),
    );
  }

  group('OtpField', () {
    testWidgets('OtpField matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const OtpField(
            maxLength: 6,
            children: [
              OtpFieldGroup(
                children: [
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                ],
              ),
              Icon(PhosphorIconsRegular.dotOutline),
              OtpFieldGroup(
                children: [
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                ],
              ),
            ],
          ),
        ),
      );

      await expectLater(
        find.byType(OtpField),
        matchesGoldenFile('goldens/input_otp.png'),
      );
    });
  });

  group('slot rendering', () {
    const strip = OtpField(
      maxLength: 6,
      initialValue: 'ABC',
      children: [
        OtpFieldGroup(
          children: [
            OtpFieldSlot(),
            OtpFieldSlot(),
            OtpFieldSlot(),
          ],
        ),
        // A fixed-width separator keeps every slot at an integer offset so
        // the pixel samples below never land on an anti-aliased edge.
        SizedBox(width: 16),
        OtpFieldGroup(
          children: [
            OtpFieldSlot(),
            OtpFieldSlot(),
            OtpFieldSlot(),
          ],
        ),
      ],
    );

    testWidgets('glyphs are centred and unclipped in their slots', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(strip));
      await tester.pump();

      final slotRect = tester.getRect(find.byType(OtpFieldSlot).first);
      final editable = tester.allRenderObjects
          .whereType<RenderEditable>()
          .first;
      final points = editable.getEndpointsForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 1),
      );
      final glyphLeft = editable.localToGlobal(points.first.point).dx;
      final glyphRight = editable.localToGlobal(points.last.point).dx;

      // Inside the slot — the 12px field padding used to leave the glyph
      // less horizontal room than its own width, which clipped it.
      expect(glyphLeft, greaterThanOrEqualTo(slotRect.left));
      expect(glyphRight, lessThanOrEqualTo(slotRect.right));

      // And centred on the slot's midline, caret reservation compensated.
      final glyphCenter = (glyphLeft + glyphRight) / 2;
      expect(glyphCenter, closeTo(slotRect.center.dx, 1));
    });

    testWidgets('focused ring paints above the neighbouring slots', (
      tester,
    ) async {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        createTestWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: const ColoredBox(
              color: Color(0xFFFFFFFF),
              child: Padding(padding: EdgeInsets.all(16), child: strip),
            ),
          ),
          // The pixel maths below needs transparent slots and an opaque
          // hairline to tell "ring over hairline" from the reverse. That is
          // shadcn's nova on neutral; finesse fills its slots with a
          // translucent wash and outlines them with one, which blend to
          // within the tolerance in either order.
          theme: ThemeData(
            style: StyleTokens.nova,
            colorScheme: const NeutralColorScheme.light(),
          ),
        ),
      );
      // The first slot of the second group: its ring overlaps the next
      // slot, whose hairlines used to be painted across it.
      await tester.tap(find.byType(OtpFieldSlot).at(3));
      await tester.pump();

      late final ui.Image image;
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        image = await boundary.toImage();
      });
      final data = (await tester.runAsync(() => image.toByteData()))!;

      final boundaryRect = tester.getRect(find.byKey(boundaryKey));
      Color pixel(Offset global) {
        final local = global - boundaryRect.topLeft;
        final index = (local.dy.floor() * image.width + local.dx.floor()) * 4;
        return Color.fromARGB(
          data.getUint8(index + 3),
          data.getUint8(index),
          data.getUint8(index + 1),
          data.getUint8(index + 2),
        );
      }

      void expectColor(Color actual, Color expected, String reason) {
        for (final (a, b) in [
          (actual.r, expected.r),
          (actual.g, expected.g),
          (actual.b, expected.b),
        ]) {
          expect((a - b).abs(), lessThan(3 / 255), reason: reason);
        }
      }

      final theme = Theme.of(tester.element(find.byType(OtpField)));
      final ringWidth = theme.style.ringWidth;
      final ring = theme.colorScheme.ring.withValues(
        alpha: theme.style.ringOpacity,
      );
      const white = Color(0xFFFFFFFF);
      final hairline = Color.alphaBlend(theme.colorScheme.input, white);

      final slotRect = tester.getRect(find.byType(OtpFieldSlot).at(3));

      // Mid-height of the ring's overhang into the next slot: the ring over
      // the white background.
      expectColor(
        pixel(Offset(slotRect.right + ringWidth / 2, slotRect.center.dy)),
        Color.alphaBlend(ring, white),
        'ring should overhang into the neighbouring slot',
      );

      // The same overhang where the neighbour's top hairline runs: the ring
      // must be painted over the hairline, not the other way round.
      expectColor(
        pixel(Offset(slotRect.right + ringWidth / 2, slotRect.top + 0.5)),
        Color.alphaBlend(ring, hairline),
        "the neighbour's hairline should sit under the ring",
      );

      // The ring's outer corner is rounded (the slot radius grown by the
      // ring width), so the corner of its bounding box stays unpainted.
      expectColor(
        pixel(
          Offset(
            slotRect.left - ringWidth + 0.5,
            slotRect.top - ringWidth + 0.5,
          ),
        ),
        white,
        'the ring should follow the rounded corner',
      );
    });

    testWidgets(
      'no-secondary-border variant leaves the ring to the decorator',
      (tester) async {
        await tester.pumpWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            theme: ThemeData(disableSecondaryBorder: true),
            home: const Scaffold(body: strip),
          ),
        );
        await tester.pump();
        await tester.tap(find.byType(OtpFieldSlot).at(3));
        await tester.pump();

        // This variant focuses with an inner 2px border instead of an
        // outward ring, so the strip must not paint one: the slot's
        // decoration reaches the input with the secondary border still
        // enabled (the theme-wide flag is what disables it), and no custom
        // paint in the strip draws outside the focused slot.
        final input = tester.widget<TextField>(
          find.descendant(
            of: find.byType(OtpFieldSlot).at(3),
            matching: find.byType(TextField),
          ),
        );
        expect(input.decoration?.disableSecondaryBorder, isNot(true));
      },
    );
  });

  testWidgets('slots grow with the text scale', (tester) async {
    // A slot is a fixed box around one glyph, so it has to follow the text
    // scaler or the digit is clipped.
    Future<Size> slotSize(double scale) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: createTestWidget(
            const OtpField(
              maxLength: 2,
              children: [
                OtpFieldGroup(
                  children: [OtpFieldSlot(), OtpFieldSlot()],
                ),
              ],
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(OtpFieldSlot).first);
    }

    final normal = await slotSize(1);
    final large = await slotSize(2);

    expect(large.width, normal.width * 2);
    expect(large.height, normal.height * 2);
  });
}
