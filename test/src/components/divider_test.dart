import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Divider, DividerTheme, ThemeData;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  group('Divider', () {
    group('.horizontal', () {
      testWidgets('correctly reads theme data', (tester) async {
        const dividerTheme = DividerTheme(
          thickness: 12,
          horizontalMargin: EdgeInsets.symmetric(vertical: 100), // really wide
          color: Color(0xFFF44336), // red
        );

        final widget = UnaApp(
          theme: ThemeData(
            colorScheme: const IrisColorScheme.dark(),
            brightness: Brightness.light,
            dividerTheme: dividerTheme,
          ),
          home: const Column(
            children: [SizedBox(width: 40), Divider()],
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Padding &&
                widget.padding == const EdgeInsets.symmetric(vertical: 100),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                (widget.decoration as BoxDecoration).border!.bottom.color ==
                    const Color(0xFFF44336),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.height == 12,
          ),
          findsOne,
        );
      });

      testWidgets('correctly uses parameters', (tester) async {
        const widget = UnaApp(
          home: Column(
            children: [
              SizedBox(width: 40),
              Divider(
                thickness: 12,
                margin: EdgeInsets.symmetric(vertical: 100),
                color: Color(0xFFF44336),
              ),
            ],
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Padding &&
                widget.padding == const EdgeInsets.symmetric(vertical: 100),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                (widget.decoration as BoxDecoration).border!.bottom.color ==
                    const Color(0xFFF44336),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.height == 12,
          ),
          findsOne,
        );
      });

      testWidgets('matches goldens', (tester) async {
        const widget = UnaApp(
          home: Column(
            children: [
              SizedBox(width: 40),
              Divider(),
            ],
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Divider),
          matchesGoldenFile('goldens/horizontal_separator.png'),
        );
      });
    });

    group('.vertical', () {
      testWidgets('correctly reads theme data', (tester) async {
        const dividerTheme = DividerTheme(
          thickness: 12,
          verticalMargin: EdgeInsets.symmetric(horizontal: 100), // really tall
          color: Color(0xFFF44336), // red
        );

        final widget = UnaApp(
          theme: ThemeData(
            colorScheme: const IrisColorScheme.dark(),
            brightness: Brightness.light,
            dividerTheme: dividerTheme,
          ),
          home: const Row(
            children: [SizedBox(height: 40), Divider.vertical()],
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Padding &&
                widget.padding == const EdgeInsets.symmetric(horizontal: 100),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                ((widget.decoration as BoxDecoration).border! as Border)
                        .left
                        .color ==
                    const Color(0xFFF44336),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == 12,
          ),
          findsOne,
        );
      });

      testWidgets('correctly uses parameters', (tester) async {
        const widget = UnaApp(
          home: Row(
            children: [
              SizedBox(height: 40),
              Divider.vertical(
                thickness: 12,
                margin: EdgeInsets.symmetric(horizontal: 100),
                color: Color(0xFFF44336),
              ),
            ],
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Padding &&
                widget.padding == const EdgeInsets.symmetric(horizontal: 100),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                ((widget.decoration as BoxDecoration).border! as Border)
                        .left
                        .color ==
                    const Color(0xFFF44336),
          ),
          findsOne,
        );

        expect(
          find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == 12,
          ),
          findsOne,
        );
      });

      testWidgets('matches goldens', (tester) async {
        const widget = UnaApp(
          home: Row(
            children: [
              SizedBox(height: 40),
              Divider.vertical(),
            ],
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Divider),
          matchesGoldenFile('goldens/vertical_separator.png'),
        );
      });
    });
  });
}
