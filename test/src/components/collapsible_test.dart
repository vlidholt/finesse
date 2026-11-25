import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Collapsible', () {
    Widget wrap(Widget child) => FinesseApp(home: Center(child: child));

    testWidgets('hides content until opened', (tester) async {
      final controller = CollapsibleController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          Collapsible(
            controller: controller,
            child: const Text('Hidden'),
          ),
        ),
      );
      expect(find.text('Hidden'), findsNothing);

      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('Hidden'), findsOneWidget);

      controller.close();
      await tester.pumpAndSettle();
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('keeps content mounted with maintainState', (tester) async {
      final controller = CollapsibleController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          Collapsible(
            controller: controller,
            maintainState: true,
            child: const Text('Hidden'),
          ),
        ),
      );
      expect(find.text('Hidden'), findsOneWidget);
    });
  });
}
