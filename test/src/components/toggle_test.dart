import 'dart:ui' show Tristate;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  group('Toggle', () {
    Widget wrap(Widget child) => UnaApp(home: Center(child: child));

    testWidgets('calls onChanged with the flipped value', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        wrap(
          Toggle(
            value: false,
            onChanged: changes.add,
            child: const Text('Bold'),
          ),
        ),
      );

      await tester.tap(find.byType(Toggle));
      await tester.pumpAndSettle();
      expect(changes, [true]);
    });

    testWidgets('does not fire when disabled', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        wrap(
          Toggle(
            value: false,
            enabled: false,
            onChanged: changes.add,
            child: const Text('Bold'),
          ),
        ),
      );

      await tester.tap(find.byType(Toggle), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('outline uses the outline toggle theme', (tester) async {
      await tester.pumpWidget(
        wrap(
          Toggle.outline(
            value: false,
            onChanged: (_) {},
            child: const Text('Bold'),
          ),
        ),
      );

      final theme = Theme.of(
        tester.element(find.byType(Toggle)),
      );
      expect(theme.outlineToggleTheme.decoration?.border?.top?.width, 1);
      expect(theme.toggleTheme.decoration?.border?.top?.width, 0);
    });

    testWidgets('exposes its toggled state to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          Toggle(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Bold',
            child: const Text('B'),
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(Toggle));
      // The explicit label replaces the child's text rather than merging.
      expect(node.label, 'Bold');
      expect(node.flagsCollection.isButton, isTrue);
      // isToggled/isEnabled are tri-state: unset, true or false.
      expect(node.flagsCollection.isToggled, Tristate.isTrue);
      expect(node.flagsCollection.isEnabled, Tristate.isTrue);
      handle.dispose();
    });
  });
}
