import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/kbd.dart';
import 'package:una/src/theme/theme.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('Kbd', () {
    testWidgets('keeps its own height inside a stretched row', (tester) async {
      // Regression: the key cap had no height of its own, so in a row that
      // stretches its children — a button's content row, for one — it grew to
      // the full height of the row instead of staying key-shaped.
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Kbd('K')],
            ),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(Kbd)));
      final cap = tester.getSize(
        find.descendant(
          of: find.byType(Kbd),
          matching: find.byType(Container),
        ),
      );

      expect(cap.height, theme.kbdTheme.height);
      expect(cap.height, lessThan(80));
    });

    testWidgets('keeps its own width inside a stretched column', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Kbd('K')],
            ),
          ),
        ),
      );

      final cap = tester.getSize(
        find.descendant(
          of: find.byType(Kbd),
          matching: find.byType(Container),
        ),
      );

      expect(cap.width, lessThan(400));
    });

    testWidgets('height follows the theme', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const Center(child: Kbd('K', height: 32))),
      );

      expect(tester.getSize(find.byType(Kbd)).height, 32);
    });
  });

  group('Kbd', () {
    Widget wrap(Widget child) => UnaApp(home: Center(child: child));

    testWidgets('renders a single cap', (tester) async {
      await tester.pumpWidget(wrap(const Kbd('K')));
      expect(find.text('K'), findsOneWidget);
    });

    testWidgets('renders a group of caps', (tester) async {
      await tester.pumpWidget(wrap(const Kbd.group(['⌘', 'K'])));
      expect(find.text('⌘'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
    });
  });
}
