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
            builder: (context) {
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
            builder: (context) => const SizedBox(
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

    testWidgets('handed from a controller to open: and back, it follows '
        'whichever it has', (tester) async {
      final first = PopoverController();
      addTearDown(first.dispose);
      final second = PopoverController();
      addTearDown(second.dispose);
      Widget app({PopoverController? controller, bool? open}) =>
          createTestWidget(
            Center(
              child: Popover(
                controller: controller,
                open: open,
                builder: (_) => const Text('panel'),
                child: const Text('anchor'),
              ),
            ),
          );
      await tester.pumpWidget(app(controller: first));
      await tester.pumpWidget(app(open: true));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('panel'), findsOneWidget);

      // The controller it had is not listened to any more.
      first
        ..open()
        ..close();
      await tester.pumpAndSettle();
      expect(find.text('panel'), findsOneWidget);

      await tester.pumpWidget(app(open: false));
      await tester.pumpAndSettle();
      expect(find.text('panel'), findsNothing);

      // From its own controller to one of the caller's, which is open.
      second.open();
      await tester.pumpWidget(app(controller: second));
      await tester.pumpAndSettle();
      expect(find.text('panel'), findsOneWidget);
      second.close();
      await tester.pumpAndSettle();
      expect(find.text('panel'), findsNothing);
    });
  });
}
