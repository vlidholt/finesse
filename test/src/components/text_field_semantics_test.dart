import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../announcements.dart';
import '../../una_harness.dart';

/// A text field is one node that names itself: by its placeholder (kept
/// once there is text), by its `semanticLabel`, or by the label of the
/// form field around it, whose description and error it carries as well.
void main() {
  SemanticsNode fieldNode(WidgetTester tester, [int index = 0]) =>
      tester.getSemantics(find.byType(EditableText).at(index));

  testWidgets('the placeholder names the field, before and after typing', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      const Center(
        child: SizedBox(
          width: 300,
          child: TextField(placeholder: Text('Email')),
        ),
      ),
    );
    expect(
      fieldNode(tester),
      matchesSemantics(
        label: 'Email',
        isTextField: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
    // The tap focuses the field, as a pointer's does.
    tester.semantics.tap(find.semantics.byLabel('Email'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );

    await tester.enterText(find.byType(EditableText), 'ada@example.com');
    await tester.pump();
    final node = fieldNode(tester);
    expect(node.label, 'Email');
    expect(node.value, 'ada@example.com');
    // The placeholder is not painted once there is text.
    final opacity = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('Email'), matching: find.byType(Opacity))
          .first,
    );
    expect(opacity.opacity, 0);
    expect(opacity.alwaysIncludeSemantics, isTrue);
    handle.dispose();
  });

  testWidgets('semanticLabel names the field ahead of its placeholder', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      const Center(
        child: SizedBox(
          width: 300,
          child: TextField(
            semanticLabel: 'Email address',
            placeholder: Text('name@example.com'),
          ),
        ),
      ),
    );
    expect(fieldNode(tester).label, 'Email address\nname@example.com');
    handle.dispose();
  });

  testWidgets('the adornments are buttons of their own', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      const Center(
        child: SizedBox(
          width: 300,
          child: TextField(
            initialValue: 'x',
            clearable: true,
            semanticLabel: 'Name',
          ),
        ),
      ),
    );
    expect(fieldNode(tester).label, 'Name');
    expect(find.bySemanticsLabel('Clear'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('SearchField, TagField and Autocomplete name their field', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SearchField(semanticLabel: 'Search mail'),
              TagField<String>(
                values: const [],
                onChanged: (_) {},
                labelBuilder: (_, tag) => Text(tag),
                semanticLabel: 'Recipients',
              ),
              Autocomplete<String>(
                semanticLabel: 'City',
                optionsBuilder: (_) => const [],
              ),
              const Textarea(semanticLabel: 'Message'),
            ],
          ),
        ),
      ),
    );
    expect(fieldNode(tester).label, startsWith('Search mail'));
    expect(fieldNode(tester, 1).label, 'Recipients');
    expect(fieldNode(tester, 2).label, 'City');
    expect(fieldNode(tester, 3).label, 'Message');
    handle.dispose();
  });

  group('in a form field', () {
    Widget form({String? error, Widget? description}) => Center(
      child: SizedBox(
        width: 300,
        child: TextFormField(
          label: const Text('Email'),
          description: description ?? const Text('We never share it.'),
          placeholder: const Text('name@example.com'),
          forceErrorText: error,
        ),
      ),
    );

    testWidgets('the field takes the label and the description', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, form());
      final node = fieldNode(tester);
      expect(node.label, 'Email\nname@example.com');
      expect(node.hint, 'We never share it.');
      // Read once, on the field: the painted copies are out of the tree.
      expect(find.bySemanticsLabel('Email'), findsNothing);
      expect(find.bySemanticsLabel('We never share it.'), findsNothing);
      expect(
        node.getSemanticsData().validationResult,
        SemanticsValidationResult.none,
      );
      handle.dispose();
    });

    testWidgets('an error is in the hint, marks the field invalid and is '
        'announced', (tester) async {
      final handle = tester.ensureSemantics();
      final error = ValueNotifier<String?>(null);
      addTearDown(error.dispose);
      await pumpUna(
        tester,
        ValueListenableBuilder(
          valueListenable: error,
          builder: (context, value, _) => form(error: value),
        ),
      );
      final said = captureAnnouncements(tester);

      error.value = 'Required';
      await tester.pump();
      final node = fieldNode(tester);
      expect(node.hint, 'Required\nWe never share it.');
      expect(
        node.getSemanticsData().validationResult,
        SemanticsValidationResult.invalid,
      );
      expect(find.bySemanticsLabel('Required'), findsNothing);
      expect(said.map((a) => a.message), ['Required']);
      expect(said.single.assertiveness, Assertiveness.assertive.index);

      // A rebuild with the same error says nothing; a new error is said.
      error.notifyListeners();
      await tester.pump();
      expect(said, hasLength(1));
      error.value = 'Too short';
      await tester.pump();
      expect(said.map((a) => a.message), ['Required', 'Too short']);
      error.value = null;
      await tester.pump();
      expect(
        fieldNode(tester).getSemanticsData().validationResult,
        SemanticsValidationResult.none,
      );
      handle.dispose();
    });

    testWidgets('a description that is not text stays where it is painted', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        form(
          description: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text('See the '), Text('policy')],
          ),
        ),
      );
      expect(fieldNode(tester).hint, isEmpty);
      expect(find.bySemanticsLabel(RegExp('policy')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a control that does not read the scope leaves the label '
        'where it is painted', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const InputDecorator(
          label: Text('Volume'),
          child: SizedBox(width: 10, height: 10),
        ),
      );
      expect(find.bySemanticsLabel('Volume'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a field in a popover under a form field is not named by it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        Center(
          child: InputDecorator(
            label: const Text('Country'),
            child: Popover(
              controller: controller,
              builder: (_) => const SizedBox(
                width: 200,
                child: TextField(placeholder: Text('Filter')),
              ),
              child: const SizedBox(width: 100, height: 20),
            ),
          ),
        ),
      );
      controller.open();
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(fieldNode(tester).label, 'Filter');
      // Nothing claimed the label: it is still read where it is painted.
      expect(find.bySemanticsLabel('Country'), findsOneWidget);
      handle.dispose();
    });
  });

  group('adornment targets', () {
    testWidgets('the clear button is drawn at a line height and takes taps '
        'over 24 points', (tester) async {
      String? changed;
      await pumpUna(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: TextField(
              initialValue: 'abc',
              clearable: true,
              onChanged: (value) => changed = value,
            ),
          ),
        ),
      );
      final button = find.bySemanticsLabel('Clear');
      final box = tester.getRect(button);
      expect(box.height, lessThan(24));
      final fieldHeight = tester.getSize(find.byType(TextField)).height;

      // Just above and just past the end of the drawn button.
      final slop = (24 - box.height) / 2;
      await tester.tapAt(
        Offset(box.right + slop - .5, box.top - slop + .5),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(changed, '');
      // And the field is as tall as before.
      expect(tester.getSize(find.byType(TextField)).height, fieldHeight);
    });

    testWidgets('the show-password button takes taps beside it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Center(
          child: SizedBox(
            width: 300,
            child: TextField.password(initialValue: 'secret'),
          ),
        ),
      );
      final box = tester.getRect(find.bySemanticsLabel('Show password'));
      final slop = (24 - box.height) / 2;
      expect(slop, greaterThan(0));
      await tester.tapAt(
        Offset(box.left - slop + .5, box.bottom + slop - .5),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      handle.dispose();
    });
  });

  testWidgets('the textarea resize grip is no node of its own', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      const Center(
        child: SizedBox(width: 300, child: Textarea(semanticLabel: 'Notes')),
      ),
    );
    final actions = <SemanticsAction>{};
    void visit(SemanticsNode node) {
      final data = node.getSemanticsData();
      if (data.label.isEmpty && !data.flagsCollection.isTextField) {
        for (final action in SemanticsAction.values) {
          if (data.hasAction(action)) actions.add(action);
        }
      }
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    expect(actions, isNot(contains(SemanticsAction.scrollUp)));
    expect(actions, isNot(contains(SemanticsAction.scrollDown)));
    handle.dispose();
  });
}
