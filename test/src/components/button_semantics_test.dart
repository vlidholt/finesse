import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// A button is one semantics node: its role, its label, whether it can be
/// pressed, and the tap. It used to be two — the role on a parent, the label
/// and the tap on a child — so a screen reader stopped on it twice and said
/// "button" about nothing.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(UnaApp(home: Center(child: child)));
  }

  /// The node that carries [label], and nothing else about it.
  SemanticsData dataOf(WidgetTester tester, String label) =>
      tester.getSemantics(find.bySemanticsLabel(label)).getSemanticsData();

  /// How many nodes under the page say they are buttons.
  int buttonNodes(WidgetTester tester) {
    var count = 0;
    void visit(SemanticsNode node) {
      if (node.flagsCollection.isButton) count++;
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    var root = tester.getSemantics(find.byType(Center).first);
    while (root.parent != null) {
      root = root.parent!;
    }
    visit(root);
    return count;
  }

  group('Button semantics', () {
    testWidgets('one node has the role, the label, the enabled state and the '
        'tap', (tester) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await pump(
        tester,
        Button(
          onPressed: () => presses++,
          leading: const PhosphorIcon(PhosphorIconsRegular.floppyDisk),
          child: const Text('Save'),
        ),
      );

      expect(
        tester.getSemantics(find.text('Save')),
        matchesSemantics(
          label: 'Save',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(buttonNodes(tester), 1);

      final node = tester.getSemantics(find.text('Save'));
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      expect(presses, 1);
      handle.dispose();
    });

    testWidgets('the text beside a button is not part of its name', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        // One container above both, as a card or a list row is.
        Semantics(
          container: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Billing address'),
              Button.outline(onPressed: () {}, child: const Text('Edit')),
              Button.ghost(onPressed: () {}, child: const Text('Remove')),
            ],
          ),
        ),
      );

      expect(dataOf(tester, 'Edit').label, 'Edit');
      expect(dataOf(tester, 'Remove').label, 'Remove');
      expect(dataOf(tester, 'Edit').flagsCollection.isButton, isTrue);
      final text = dataOf(tester, 'Billing address');
      expect(text.flagsCollection.isButton, isFalse);
      expect(text.hasAction(SemanticsAction.tap), isFalse);
      expect(buttonNodes(tester), 2);
      handle.dispose();
    });

    testWidgets('a disabled button is a button that cannot be pressed or '
        'focused', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        Button(enabled: false, onPressed: () {}, child: const Text('Save')),
      );

      expect(
        tester.getSemantics(find.text('Save')),
        matchesSemantics(
          label: 'Save',
          isButton: true,
          hasEnabledState: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a button with nothing to do is there, and offers no tap', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const Button(child: Text('Later')));

      final data = dataOf(tester, 'Later');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('loading announces busy on the same node, keeps the label and '
        'the focus, and takes the tap away', (tester) async {
      final handle = tester.ensureSemantics();
      var loading = false;
      late StateSetter setOuter;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return Button(
              loading: loading,
              onPressed: () {},
              child: const Text('Save'),
            );
          },
        ),
      );
      expect(dataOf(tester, 'Save').value, isEmpty);

      setOuter(() => loading = true);
      // Fixed frames: a spinner never settles.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final busy = dataOf(tester, 'Save');
      expect(busy.label, 'Save');
      expect(busy.value, 'Loading');
      expect(busy.flagsCollection.isButton, isTrue);
      expect(busy.flagsCollection.isEnabled, Tristate.isFalse);
      expect(busy.flagsCollection.isFocused, isNot(Tristate.none));
      expect(busy.hasAction(SemanticsAction.tap), isFalse);
      expect(buttonNodes(tester), 1);
      // The spinner is not a second thing to stop on.
      expect(find.bySemanticsLabel('Loading'), findsNothing);

      setOuter(() => loading = false);
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final idle = dataOf(tester, 'Save');
      expect(idle.value, isEmpty);
      expect(idle.flagsCollection.isEnabled, Tristate.isTrue);
      expect(idle.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('a semantic label stands in for the content', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        Button(
          semanticLabel: 'Save the draft',
          onPressed: () {},
          child: const Text('Save'),
        ),
      );
      expect(find.bySemanticsLabel('Save'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Save the draft')),
        matchesSemantics(
          label: 'Save the draft',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a long press is offered when there is one', (tester) async {
      final handle = tester.ensureSemantics();
      var held = 0;
      await pump(
        tester,
        Button(
          onPressed: () {},
          onLongPress: () => held++,
          child: const Text('Send'),
        ),
      );
      final node = tester.getSemantics(find.text('Send'));
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.longPress),
        isTrue,
      );
      node.owner!.performAction(node.id, SemanticsAction.longPress);
      expect(held, 1);
      handle.dispose();
    });
  });

  group('IconButton semantics', () {
    testWidgets('is one node named by its label, with no node for the icon', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        IconButton.ghost(
          semanticLabel: 'Archive',
          onPressed: () {},
          icon: const PhosphorIcon(
            PhosphorIconsRegular.archive,
            semanticLabel: 'box',
          ),
        ),
      );
      expect(find.bySemanticsLabel('box'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Archive')),
        matchesSemantics(
          label: 'Archive',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(buttonNodes(tester), 1);
      handle.dispose();
    });
  });

  group('Toggle semantics', () {
    testWidgets('is one node that says whether it is on', (tester) async {
      final handle = tester.ensureSemantics();
      var on = false;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Toggle(
            value: on,
            semanticLabel: 'Bold',
            onChanged: (value) => setState(() => on = value),
            child: const PhosphorIcon(PhosphorIconsRegular.textB),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Bold')),
        matchesSemantics(
          label: 'Bold',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasToggledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      final node = tester.getSemantics(find.bySemanticsLabel('Bold'));
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(on, isTrue);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Bold'))
            .getSemanticsData()
            .flagsCollection
            .isToggled,
        Tristate.isTrue,
      );
      expect(buttonNodes(tester), 1);
      handle.dispose();
    });
  });
}
