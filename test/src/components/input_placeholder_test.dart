import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// The placeholder used to be driven by a ValueListenableBuilder wrapped
/// around the whole field, so every keystroke — and every cursor move, since
/// TextEditingController notifies on selection changes too — rebuilt
/// EditableText, the decorator, the scrollbar and the leading/trailing row.
/// It is now driven by a derived notifier scoped to the placeholder alone.
/// These tests pin the visible behaviour that refactor had to preserve.
///
/// A placeholder that is not shown stays in the tree, unseen
/// (`Opacity(opacity: 0)`): it is still the field's name for assistive
/// technology. `shown` reads what is painted.
void main() {
  Widget wrap(Widget child) => UnaApp(home: child);

  final shown = _Shown();

  testWidgets('placeholder shows when empty and hides once text is typed', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const TextField(placeholder: Text('Email'))),
    );

    expect(find.text('Email'), shown);

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    expect(find.text('Email'), isNot(shown));

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.text('Email'), shown);
  });

  testWidgets('placeholder is hidden when an initialValue is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const TextField(initialValue: 'hello', placeholder: Text('Email')),
      ),
    );

    expect(find.text('Email'), isNot(shown));
  });

  testWidgets('placeholder follows an external controller', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        TextField(controller: controller, placeholder: const Text('Email')),
      ),
    );
    expect(find.text('Email'), shown);

    controller.text = 'typed externally';
    await tester.pump();
    expect(find.text('Email'), isNot(shown));

    controller.clear();
    await tester.pump();
    expect(find.text('Email'), shown);
  });

  testWidgets('placeholder follows a swapped controller', (tester) async {
    final first = TextEditingController(text: 'filled');
    final second = TextEditingController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(
      wrap(TextField(controller: first, placeholder: const Text('Email'))),
    );
    expect(find.text('Email'), isNot(shown));

    await tester.pumpWidget(
      wrap(TextField(controller: second, placeholder: const Text('Email'))),
    );
    expect(find.text('Email'), shown);

    // The old controller must no longer drive the placeholder.
    first.text = 'still filled';
    await tester.pump();
    expect(find.text('Email'), shown);
  });

  testWidgets('moving the cursor does not toggle the placeholder', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'abc');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        TextField(controller: controller, placeholder: const Text('Email')),
      ),
    );
    expect(find.text('Email'), isNot(shown));

    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();
    expect(find.text('Email'), isNot(shown));
  });
}

/// Matches a finder for a placeholder that is painted: found once, under no
/// `Opacity` of zero.
class _Shown extends Matcher {
  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) {
    final finder = item! as Finder;
    final found = finder.evaluate().toList();
    if (found.length != 1) return false;
    var hidden = false;
    found.single.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Opacity && widget.opacity == 0) hidden = true;
      return !hidden;
    });
    return !hidden;
  }

  @override
  Description describe(Description description) =>
      description.add('a placeholder that is painted');
}
