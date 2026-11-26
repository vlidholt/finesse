import 'package:flutter/material.dart' hide TextField, ThemeData;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/otp_field.dart';
import 'package:una/src/components/text_field.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/style.dart';

void main() {
  // Switching styles animates every component theme through
  // `AnimatedTheme`. Mid-flight a boxed field's border lerps towards an
  // underlined (`sera`) or borderless (`maia`) one: three sides fade out
  // while the bottom crosses to another colour, so the sides momentarily
  // disagree — which `Border.paint` refuses to combine with a border radius.
  // `UnaBoxBorder` exists to paint exactly that state; this walks every
  // style pair to pin it.
  testWidgets('fields survive animated transitions between all styles', (
    tester,
  ) async {
    Widget app(StyleTokens style) => UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      theme: ThemeData(style: style),
      home: const Scaffold(
        body: Column(
          children: [
            TextField(),
            OtpField(
              maxLength: 2,
              children: [
                OtpFieldGroup(
                  children: [OtpFieldSlot(), OtpFieldSlot()],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    for (final from in StyleTokens.all) {
      for (final to in StyleTokens.all) {
        if (identical(from, to)) continue;
        await tester.pumpWidget(app(from));
        await tester.pumpAndSettle();
        await tester.pumpWidget(app(to));
        // Paint a handful of frames across the 200ms theme lerp.
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          expect(
            tester.takeException(),
            isNull,
            reason: 'painting ${from.name} → ${to.name} at ${(i + 1) * 50}ms',
          );
        }
      }
    }
  });
}
