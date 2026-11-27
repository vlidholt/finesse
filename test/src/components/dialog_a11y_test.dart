import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// Whether the primary focus is on the control that shows [label].
bool _focused(String label) {
  final node = FocusManager.instance.primaryFocus;
  // A scope holds every control below it.
  if (node is FocusScopeNode) return false;
  final focus = node?.context;
  if (focus == null) return false;
  var found = false;
  void visit(Element element) {
    if (found) return;
    final widget = element.widget;
    if (widget is Text && widget.data == label) found = true;
    element.visitChildren(visit);
  }

  (focus as Element).visitChildren(visit);
  return found;
}

void main() {
  Future<void> open(
    WidgetTester tester,
    WidgetBuilder builder, {
    FormFactor formFactor = FormFactor.desktop,
  }) async {
    await pumpUna(
      tester,
      Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () =>
                showDialog<void>(context: context, builder: builder),
            child: const Text('Open'),
          ),
        ),
      ),
      formFactor: formFactor,
    );
    await tester.tap(find.text('Open'));
    await settle(tester);
  }

  SemanticsNode dialogNode(WidgetTester tester) {
    var node = tester.getSemantics(find.text('Edit profile'));
    while (node.getSemanticsData().role != SemanticsRole.dialog &&
        node.getSemanticsData().role != SemanticsRole.alertDialog) {
      node = node.parent!;
    }
    return node;
  }

  group('semantics', () {
    testWidgets('a dialog is a dialog, named by its title, a heading', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(
        tester,
        (context) => const Dialog(title: Text('Edit profile')),
      );
      expect(dialogNode(tester).getSemanticsData().role, SemanticsRole.dialog);
      expect(
        tester.getSemantics(find.text('Edit profile')),
        isSemantics(label: 'Edit profile', isHeader: true, namesRoute: true),
      );
      handle.dispose();
    });

    testWidgets('an alert dialog is an alert dialog', (tester) async {
      final handle = tester.ensureSemantics();
      await open(
        tester,
        (context) => const Dialog.alert(title: Text('Edit profile')),
      );
      expect(
        dialogNode(tester).getSemanticsData().role,
        SemanticsRole.alertDialog,
      );
      handle.dispose();
    });

    testWidgets('a semanticLabel names it instead of the title', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(
        tester,
        (context) => const Dialog(
          semanticLabel: 'Profile editor',
          title: Text('Edit profile'),
        ),
      );
      final dialog = dialogNode(tester).getSemanticsData();
      expect(dialog.label, 'Profile editor');
      expect(dialog.flagsCollection.namesRoute, isTrue);
      expect(
        tester.getSemantics(find.text('Edit profile')),
        isSemantics(label: 'Edit profile', isHeader: true),
      );
      expect(
        tester
            .getSemantics(find.text('Edit profile'))
            .getSemanticsData()
            .flagsCollection
            .namesRoute,
        isFalse,
      );
      handle.dispose();
    });

    testWidgets('the command palette is named', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Builder(
          builder: (context) => Center(
            child: Button(
              onPressed: () => showCommandDialog<void>(
                context: context,
                groups: [
                  const CommandGroup(items: [CommandItem(label: 'Settings')]),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await settle(tester);
      expect(
        find.bySemanticsLabel('Command palette'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('focus on open', () {
    testWidgets('goes to the first control', (tester) async {
      await open(
        tester,
        (context) => Dialog(
          title: const Text('Edit profile'),
          actions: [
            Button.outline(onPressed: () {}, child: const Text('Cancel')),
            Button(onPressed: () {}, child: const Text('Save')),
          ],
        ),
      );
      expect(_focused('Cancel'), isTrue);
    });

    testWidgets('passes over a text field', (tester) async {
      await open(
        tester,
        (context) => Dialog(
          title: const Text('Edit profile'),
          actions: [
            Button(onPressed: () {}, child: const Text('Save')),
          ],
          child: const TextField(placeholder: Text('Name')),
        ),
      );
      expect(_focused('Save'), isTrue);
    });

    testWidgets('leaves a field that asked for it alone', (tester) async {
      await open(
        tester,
        (context) => Dialog(
          title: const Text('Edit profile'),
          actions: [
            Button(onPressed: () {}, child: const Text('Save')),
          ],
          child: const TextField(autofocus: true, placeholder: Text('Name')),
        ),
      );
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<EditableText>(),
        isNotNull,
      );
    });

    testWidgets('in an alert, goes to the first action that is not '
        'destructive', (tester) async {
      await open(
        tester,
        (context) => Dialog.alert(
          title: const Text('Delete the file?'),
          actions: [
            Button.destructive(onPressed: () {}, child: const Text('Delete')),
            Button.outline(onPressed: () {}, child: const Text('Keep')),
          ],
        ),
      );
      expect(_focused('Keep'), isTrue);
    });

    testWidgets('not with autofocus false', (tester) async {
      await open(
        tester,
        (context) => Dialog(
          autofocus: false,
          title: const Text('Edit profile'),
          actions: [
            Button(onPressed: () {}, child: const Text('Save')),
          ],
        ),
      );
      expect(_focused('Save'), isFalse);
    });
  });

  group('the close button', () {
    for (final (formFactor, side) in [
      (FormFactor.desktop, 24.0),
      (FormFactor.mobile, 44.0),
    ]) {
      testWidgets('takes a press across $side points on '
          '${formFactor.name}, drawn where it was', (tester) async {
        var closed = 0;
        await open(
          tester,
          (context) => Dialog(
            showCloseButton: true,
            onDismissed: () => closed++,
            title: const Text('Edit profile'),
          ),
          formFactor: formFactor,
        );
        final icon = find.byIcon(PhosphorIconsRegular.x);
        final button = tester.getRect(
          find.ancestor(of: icon, matching: find.byType(IconButton)),
        );
        expect(button.size, const Size(20, 20));

        // Just outside the drawn button, inside the target: towards the
        // dialog's middle, away from its corner.
        final reach = (side - 20) / 2;
        await tester.tapAt(button.bottomLeft + Offset(-reach + 1, reach - 1));
        await settle(tester);
        expect(closed, 1);

        // Past the target: nothing.
        await tester.tapAt(button.bottomLeft + Offset(-side, side));
        await settle(tester);
        expect(closed, 1);
      });
    }
  });
}
