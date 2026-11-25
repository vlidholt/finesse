import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('Popover', () {
    testWidgets('Popover matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Popover(
            open: true,
            popover: (context) {
              return const Text('Popover');
            },
            child: const Text('Child'),
          ),
        ),
      );

      await expectLater(
        find.byType(Popover),
        matchesGoldenFile('goldens/popover.png'),
      );
    });

    testWidgets('popover content is start-aligned, not centred', (
      tester,
    ) async {
      // Regression: the popover forced TextAlign.center on its content, which
      // centred every select option, menu item and form label inside it.
      await tester.pumpWidget(
        createTestWidget(
          Popover(
            open: true,
            popover: (context) => const SizedBox(
              width: 200,
              child: Text('Popover'),
            ),
            child: const Text('Child'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final style = DefaultTextStyle.of(
        tester.element(find.text('Popover')),
      );
      expect(style.textAlign, TextAlign.start);
    });
  });
}
