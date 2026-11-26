import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

const _fruits = ['Apple', 'Apricot', 'Avocado', 'Banana', 'Blueberry'];

Iterable<String> _filter(TextEditingValue value) {
  final query = value.text.toLowerCase();
  if (query.isEmpty) return const [];
  return _fruits.where((fruit) => fruit.toLowerCase().startsWith(query));
}

Widget _app(
  Widget child, {
  ThemeData? theme,
  TextDirection direction = TextDirection.ltr,
  VoidCallback? onEscape,
  FocusNode? after,
  double textScale = 1,
  AlignmentGeometry alignment = Alignment.topCenter,
}) {
  return UnaApp(
    theme: theme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                onEscape?.call(),
          },
          child: Directionality(
            textDirection: direction,
            child: Align(
              alignment: alignment,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      child,
                      if (after != null)
                        Focus(
                          focusNode: after,
                          child: const SizedBox(height: 20, width: 20),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Past the popover's entrance.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await _settle(tester);
}

final _rows = find.byWidgetPredicate(
  (widget) => '${widget.runtimeType}'.startsWith('AutocompleteOptionRow'),
);

/// The option rows showing, as their texts in order.
List<String> _shown(WidgetTester tester) => [
  for (final fruit in _fruits)
    if (find
        .descendant(of: _rows, matching: find.text(fruit))
        .hitTestable()
        .evaluate()
        .isNotEmpty)
      fruit,
];

/// The fill of the row with [text], or null when it has none.
Color? _fillOf(WidgetTester tester, String text) {
  final box = tester.widget<DecoratedBox>(
    find
        .ancestor(of: find.text(text), matching: find.byType(DecoratedBox))
        .first,
  );
  return (box.decoration as BoxDecoration).color;
}

void main() {
  testWidgets('typing opens the options under the field, as wide as it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const Autocomplete<String>(optionsBuilder: _filter)),
    );
    expect(_shown(tester), isEmpty);

    await _type(tester, 'a');
    expect(_shown(tester), ['Apple', 'Apricot', 'Avocado']);
    final field = tester.getRect(find.byType(TextField));
    final first = tester.getRect(find.text('Apple'));
    expect(first.top, greaterThan(field.bottom));
    // The surface is the field's width.
    final surface = tester.getRect(
      find
          .ancestor(of: find.text('Apple'), matching: find.byType(Decorator))
          .first,
    );
    expect(surface.width, moreOrLessEquals(field.width, epsilon: .5));
    expect(surface.left, moreOrLessEquals(field.left, epsilon: .5));

    await _type(tester, 'ap');
    expect(_shown(tester), ['Apple', 'Apricot']);

    // Nothing matches: with no empty builder the list goes.
    await _type(tester, 'zz');
    expect(_shown(tester), isEmpty);
  });

  testWidgets('the focus stays in the field while the list is open and '
      'while it is clicked', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    String? selected;
    await tester.pumpWidget(
      _app(
        Autocomplete<String>(
          optionsBuilder: _filter,
          focusNode: focusNode,
          onSelected: (value) => selected = value,
        ),
      ),
    );
    await _type(tester, 'a');
    expect(focusNode.hasPrimaryFocus, isTrue);

    await tester.tap(find.text('Apricot'));
    await _settle(tester);
    expect(selected, 'Apricot');
    expect(find.text('Apricot'), findsOneWidget);
    expect(_shown(tester), isEmpty);
    expect(focusNode.hasPrimaryFocus, isTrue);
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller.text, 'Apricot');
    expect(editable.controller.selection.baseOffset, 'Apricot'.length);
  });

  group('keyboard', () {
    testWidgets('arrows move the highlight and wrap; Enter takes it', (
      tester,
    ) async {
      final changes = <String>[];
      final submitted = <String>[];
      String? selected;
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            optionsBuilder: _filter,
            onChanged: changes.add,
            onSubmitted: submitted.add,
            onSelected: (value) => selected = value,
          ),
        ),
      );
      await _type(tester, 'a');
      final theme = Theme.of(tester.element(find.byType(TextField)));
      final lit = theme.selectOptionTheme.hoveredBackgroundColor;
      // Nothing is highlighted until an arrow says so.
      expect(_fillOf(tester, 'Apple'), isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_fillOf(tester, 'Apple'), lit);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_fillOf(tester, 'Apple'), isNull);
      expect(_fillOf(tester, 'Apricot'), lit);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // Past the end is the start again.
      expect(_fillOf(tester, 'Apple'), lit);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(_fillOf(tester, 'Avocado'), lit);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(selected, 'Avocado');
      expect(changes.last, 'Avocado');
      expect(submitted, isEmpty);
      expect(_shown(tester), isEmpty);
    });

    testWidgets('Enter with nothing highlighted submits the text as typed', (
      tester,
    ) async {
      final submitted = <String>[];
      String? selected;
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            optionsBuilder: _filter,
            onSubmitted: submitted.add,
            onSelected: (value) => selected = value,
          ),
        ),
      );
      await _type(tester, 'ap');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submitted, ['ap']);
      expect(selected, isNull);
    });

    testWidgets('autoHighlight lets Enter and the action key take the first', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            optionsBuilder: _filter,
            autoHighlight: true,
            onSelected: (value) => selected = value,
          ),
        ),
      );
      await _type(tester, 'b');
      final theme = Theme.of(tester.element(find.byType(TextField)));
      expect(
        _fillOf(tester, 'Banana'),
        theme.selectOptionTheme.hoveredBackgroundColor,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);
      expect(selected, 'Banana');
    });

    testWidgets('Escape closes the list and nothing else; the next Escape is '
        "the page's; typing or an arrow brings the list back", (
      tester,
    ) async {
      var escaped = 0;
      await tester.pumpWidget(
        _app(
          const Autocomplete<String>(optionsBuilder: _filter),
          onEscape: () => escaped++,
        ),
      );
      await _type(tester, 'a');
      expect(_shown(tester), isNotEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(_shown(tester), isEmpty);
      expect(escaped, 0);
      expect(find.text('a'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(escaped, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      expect(_shown(tester), ['Apple', 'Apricot', 'Avocado']);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      await _type(tester, 'ap');
      expect(_shown(tester), ['Apple', 'Apricot']);
    });

    testWidgets('Tab goes on to what follows the field, not into the list, '
        'and the list closes', (tester) async {
      final after = FocusNode();
      addTearDown(after.dispose);
      await tester.pumpWidget(
        _app(
          const Autocomplete<String>(optionsBuilder: _filter),
          after: after,
        ),
      );
      await _type(tester, 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await _settle(tester);
      expect(after.hasPrimaryFocus, isTrue);
      expect(_shown(tester), isEmpty);
    });

    testWidgets("with the list closed the arrows are the field's own", (
      tester,
    ) async {
      final controller = TextEditingController(text: 'zzz');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            optionsBuilder: _filter,
            controller: controller,
            autofocus: true,
          ),
        ),
      );
      await tester.pump();
      controller.selection = const TextSelection.collapsed(offset: 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      // Up in a single-line field is "to the start".
      expect(controller.selection.baseOffset, 0);
    });
  });

  group('pointer', () {
    testWidgets('a moving pointer highlights the row under it, at once', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const Autocomplete<String>(optionsBuilder: _filter)),
      );
      await _type(tester, 'a');
      final theme = Theme.of(tester.element(find.byType(TextField)));
      final lit = theme.selectOptionTheme.hoveredBackgroundColor;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(1, 1));
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Apricot')));
      // One frame: there or not, no fade.
      await tester.pump();
      expect(_fillOf(tester, 'Apricot'), lit);
      expect(_fillOf(tester, 'Apple'), isNull);

      // The keyboard takes over from where the pointer left it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_fillOf(tester, 'Avocado'), lit);
      expect(_fillOf(tester, 'Apricot'), isNull);
    });

    testWidgets('a tap outside closes the list; a tap on the field brings '
        'it back', (tester) async {
      await tester.pumpWidget(
        _app(const Autocomplete<String>(optionsBuilder: _filter)),
      );
      await _type(tester, 'a');
      await tester.tapAt(const Offset(700, 500));
      await _settle(tester);
      expect(_shown(tester), isEmpty);

      await tester.tap(find.byType(TextField));
      await _settle(tester);
      expect(_shown(tester), ['Apple', 'Apricot', 'Avocado']);
    });
  });

  group('asynchronous options', () {
    testWidgets('a late answer to an old question is dropped', (tester) async {
      final answers = <String, Completer<Iterable<String>>>{};
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            debounce: Duration.zero,
            optionsBuilder: (value) {
              final completer = Completer<Iterable<String>>();
              answers[value.text] = completer;
              return completer.future;
            },
          ),
        ),
      );
      await _type(tester, 'a');
      await _type(tester, 'b');
      // The newer question is answered first.
      answers['b']!.complete(['Banana']);
      await _settle(tester);
      expect(_shown(tester), ['Banana']);
      answers['a']!.complete(['Apple']);
      await _settle(tester);
      expect(_shown(tester), ['Banana']);
    });

    testWidgets('once the builder has answered with a future it is asked '
        'only after typing has paused', (tester) async {
      final asked = <String>[];
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            debounce: const Duration(milliseconds: 300),
            optionsBuilder: (value) async {
              asked.add(value.text);
              return _filter(value);
            },
          ),
        ),
      );
      // The first question is asked at once: nothing says yet that the
      // builder is slow.
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      expect(asked, ['a']);

      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'apr');
      await tester.pump(const Duration(milliseconds: 100));
      expect(asked, ['a']);
      await tester.pump(const Duration(milliseconds: 300));
      expect(asked, ['a', 'apr']);
      await _settle(tester);
      expect(_shown(tester), ['Apricot']);
    });

    testWidgets('a synchronous builder is asked on every change', (
      tester,
    ) async {
      final asked = <String>[];
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            optionsBuilder: (value) {
              asked.add(value.text);
              return _filter(value);
            },
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'a');
      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump();
      expect(asked, ['a', 'ap']);
    });

    testWidgets('loadingBuilder and emptyBuilder fill the list', (
      tester,
    ) async {
      final answer = Completer<Iterable<String>>();
      await tester.pumpWidget(
        _app(
          Autocomplete<String>(
            optionsBuilder: (value) => answer.future,
            loadingBuilder: (context) => const Text('Searching'),
            emptyBuilder: (context) => const Text('Nothing found'),
          ),
        ),
      );
      await _type(tester, 'q');
      expect(find.text('Searching').hitTestable(), findsOneWidget);
      answer.complete(const []);
      await _settle(tester);
      expect(find.text('Searching'), findsNothing);
      expect(find.text('Nothing found').hitTestable(), findsOneWidget);
    });

    testWidgets('an answer after the field is gone is ignored', (tester) async {
      final answer = Completer<Iterable<String>>();
      await tester.pumpWidget(
        _app(Autocomplete<String>(optionsBuilder: (value) => answer.future)),
      );
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      answer.complete(['Apple']);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('openOnFocus asks before anything is typed', (tester) async {
    await tester.pumpWidget(
      _app(
        Autocomplete<String>(
          openOnFocus: true,
          optionsBuilder: (value) =>
              value.text.isEmpty ? _fruits.take(2) : _filter(value),
        ),
      ),
    );
    expect(_shown(tester), isEmpty);
    await tester.tap(find.byType(TextField));
    await _settle(tester);
    expect(_shown(tester), ['Apple', 'Apricot']);
  });

  testWidgets('options of any type: display string and row builder', (
    tester,
  ) async {
    ({String name, int id})? selected;
    const people = [(name: 'Ada', id: 1), (name: 'Alan', id: 2)];
    await tester.pumpWidget(
      _app(
        Autocomplete<({String name, int id})>(
          optionsBuilder: (value) => people.where(
            (p) => p.name.toLowerCase().startsWith(value.text.toLowerCase()),
          ),
          displayStringForOption: (person) => person.name,
          optionBuilder: (context, person) => Text('#${person.id}'),
          onSelected: (person) => selected = person,
        ),
      ),
    );
    await _type(tester, 'a');
    expect(find.text('#1'), findsOneWidget);
    await tester.tap(find.text('#2'));
    await _settle(tester);
    expect(selected, people[1]);
    expect(find.text('Alan'), findsOneWidget);
  });

  testWidgets('opens above when there is no room below', (tester) async {
    await tester.pumpWidget(
      _app(
        const Autocomplete<String>(optionsBuilder: _filter),
        alignment: Alignment.bottomCenter,
      ),
    );
    await _type(tester, 'a');
    final field = tester.getRect(find.byType(TextField));
    expect(tester.getRect(find.text('Apple')).bottom, lessThan(field.top));
  });

  testWidgets('a long list scrolls, and the arrows keep the highlight in '
      'view', (tester) async {
    final many = [for (var i = 0; i < 40; i++) 'Option $i'];
    await tester.pumpWidget(
      _app(
        Autocomplete<String>(
          maxOptionsHeight: 160,
          optionsBuilder: (value) => value.text.isEmpty ? const [] : many,
        ),
      ),
    );
    await _type(tester, 'o');
    final surface = tester.getRect(
      find
          .ancestor(of: find.text('Option 0'), matching: find.byType(Decorator))
          .first,
    );
    expect(surface.height, lessThanOrEqualTo(162));
    expect(find.text('Option 20').hitTestable(), findsNothing);
    for (var i = 0; i < 21; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    await tester.pump();
    expect(find.text('Option 20').hitTestable(), findsOneWidget);
    final row = tester.getRect(find.text('Option 20'));
    expect(row.top, greaterThanOrEqualTo(surface.top));
    expect(row.bottom, lessThanOrEqualTo(surface.bottom));
  });

  testWidgets('announces how many options there are', (tester) async {
    final announcements = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (message) async {
        final data = (message as Map)['data'] as Map;
        announcements.add(data['message'] as String);
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility,
            null,
          ),
    );
    await tester.pumpWidget(
      _app(const Autocomplete<String>(optionsBuilder: _filter)),
    );
    await _type(tester, 'a');
    await _type(tester, 'ban');
    await _type(tester, 'zz');
    expect(announcements, [
      '3 results available',
      '1 result available',
      'No results',
    ]);
  });

  testWidgets('semantics: the rows are buttons, the highlighted one '
      'selected', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const Autocomplete<String>(optionsBuilder: _filter)),
    );
    await _type(tester, 'a');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final apple = tester.getSemantics(find.text('Apple'));
    expect(apple.flagsCollection.isButton, isTrue);
    expect(apple.flagsCollection.isSelected.toString(), contains('isTrue'));
    expect(
      tester
          .getSemantics(find.text('Apricot'))
          .flagsCollection
          .isSelected
          .toString(),
      contains('isFalse'),
    );
    handle.dispose();
  });

  testWidgets('right-to-left, a large text scale and every style lay out '
      'without overflow', (tester) async {
    for (final style in [
      StyleTokens.una,
      StyleTokens.nova,
      StyleTokens.maia,
      StyleTokens.lyra,
    ]) {
      for (final formFactor in FormFactor.values) {
        await tester.pumpWidget(
          _app(
            const Autocomplete<String>(optionsBuilder: _filter),
            theme: ThemeData(style: style).withFormFactor(formFactor),
            direction: TextDirection.rtl,
            textScale: 2,
          ),
        );
        await _type(tester, 'a');
        expect(_shown(tester), isNotEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('settles: nothing animates at rest, open or closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const Autocomplete<String>(optionsBuilder: _filter)),
    );
    await tester.enterText(find.byType(TextField), 'a');
    // The caret blinks on a timer, not a ticker: this returns only if the
    // popover's entrance comes to rest.
    await tester.pumpAndSettle();
    expect(_shown(tester), isNotEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_shown(tester), isEmpty);
  });

  testWidgets('disabled, it neither opens nor asks', (tester) async {
    var asked = 0;
    await tester.pumpWidget(
      _app(
        Autocomplete<String>(
          enabled: false,
          openOnFocus: true,
          optionsBuilder: (value) {
            asked++;
            return _fruits;
          },
        ),
      ),
    );
    await tester.tap(find.byType(TextField), warnIfMissed: false);
    await _settle(tester);
    expect(_shown(tester), isEmpty);
    expect(asked, 0);
  });
}
