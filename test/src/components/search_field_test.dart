import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

Widget _app(
  Widget child, {
  ThemeData? theme,
  TextDirection direction = TextDirection.ltr,
  bool disableAnimations = false,
  VoidCallback? onEscape,
}) {
  return UnaApp(
    theme: theme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                onEscape?.call(),
          },
          child: Directionality(
            textDirection: direction,
            child: Center(child: SizedBox(width: 320, child: child)),
          ),
        ),
      ),
    ),
  );
}

final _clear = find.bySemanticsLabel('Clear');

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('shows a magnifier and the localized prompt, with the '
      "keyboard's search action", (tester) async {
    await tester.pumpWidget(_app(const SearchField()));
    expect(find.text('Search'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.magnifyingGlass), findsOneWidget);
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.textInputAction, TextInputAction.search);
    expect(find.bySemanticsLabel('Search'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _app(const SearchField(placeholder: Text('Search people'))),
    );
    expect(find.text('Search people'), findsOneWidget);
  });

  testWidgets('is exactly as tall as a text field, in every style and form '
      'factor', (tester) async {
    for (final style in [
      StyleTokens.una,
      StyleTokens.nova,
      StyleTokens.maia,
      StyleTokens.lyra,
    ]) {
      for (final formFactor in FormFactor.values) {
        final theme = ThemeData(style: style).withFormFactor(formFactor);
        await tester.pumpWidget(
          _app(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(key: Key('plain')),
                SearchField(initialValue: 'query', showCancel: true),
              ],
            ),
            theme: theme,
          ),
        );
        await _settle(tester);
        expect(
          tester.getSize(find.byType(TextField).last).height,
          tester.getSize(find.byKey(const Key('plain'))).height,
          reason: '$formFactor',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('reports typing, submitting and clearing', (tester) async {
    final changes = <String>[];
    final submitted = <String>[];
    var cleared = 0;
    await tester.pumpWidget(
      _app(
        SearchField(
          onChanged: changes.add,
          onSubmitted: submitted.add,
          onCleared: () => cleared++,
        ),
      ),
    );
    expect(_clear, findsNothing);
    await tester.enterText(find.byType(SearchField), 'teal');
    await _settle(tester);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(changes, ['teal']);
    expect(submitted, ['teal']);

    await tester.tap(_clear);
    await _settle(tester);
    expect(changes, ['teal', '']);
    expect(cleared, 1);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('Escape clears a query, and with none is left to whatever '
      'encloses the field', (tester) async {
    final changes = <String>[];
    var cleared = 0;
    var escaped = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      _app(
        SearchField(
          focusNode: focusNode,
          onChanged: changes.add,
          onCleared: () => cleared++,
        ),
        onEscape: () => escaped++,
      ),
    );
    await tester.enterText(find.byType(SearchField), 'teal');
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(changes, ['teal', '']);
    expect(cleared, 1);
    expect(escaped, 0);
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(escaped, 1);
    expect(cleared, 1);
  });

  testWidgets('clearOnEscape: false leaves Escape alone', (tester) async {
    var escaped = 0;
    await tester.pumpWidget(
      _app(
        const SearchField(clearOnEscape: false),
        onEscape: () => escaped++,
      ),
    );
    await tester.enterText(find.byType(SearchField), 'teal');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(escaped, 1);
    expect(find.text('teal'), findsOneWidget);
  });

  testWidgets('loading swaps the magnifier for a spinner of the same size', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SearchField()));
    final icon = tester.getRect(
      find.byIcon(PhosphorIconsRegular.magnifyingGlass),
    );
    final text = tester.getRect(find.byType(EditableText));
    await tester.pumpWidget(_app(const SearchField(loading: true)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(PhosphorIconsRegular.magnifyingGlass), findsNothing);
    expect(tester.getRect(find.byType(Spinner)).size, icon.size);
    // Nothing moved.
    expect(tester.getRect(find.byType(EditableText)), text);
  });

  group('showCancel', () {
    final cancel = find.text('Cancel');

    testWidgets('slides in with the focus, monotonically, and settles', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const SearchField(showCancel: true)));
      final wide = tester.getSize(find.byType(TextField)).width;
      expect(wide, 320);
      expect(cancel.hitTestable(), findsNothing);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      final widths = <double>[];
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        widths.add(tester.getSize(find.byType(TextField)).width);
      }
      // The field only ever narrows on the way in.
      for (var i = 1; i < widths.length; i++) {
        expect(widths[i], lessThanOrEqualTo(widths[i - 1] + .01));
      }
      await tester.pumpAndSettle();
      final narrow = tester.getSize(find.byType(TextField)).width;
      expect(narrow, lessThan(wide - 20));
      expect(cancel.hitTestable(), findsOneWidget);
      // Beside the field, not over it.
      expect(
        tester.getRect(cancel).left,
        greaterThan(tester.getRect(find.byType(TextField)).right),
      );
    });

    testWidgets('Cancel clears, unfocuses and reports; the button leaves', (
      tester,
    ) async {
      final changes = <String>[];
      var cancelled = 0;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          SearchField(
            showCancel: true,
            focusNode: focusNode,
            onChanged: changes.add,
            onCancel: () => cancelled++,
          ),
        ),
      );
      await tester.enterText(find.byType(SearchField), 'teal');
      await tester.pumpAndSettle();
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(changes, ['teal', '']);
      expect(cancelled, 1);
      expect(focusNode.hasFocus, isFalse);
      expect(cancel.hitTestable(), findsNothing);
      expect(tester.getSize(find.byType(TextField)).width, 320);
    });

    testWidgets('interrupted on the way in it turns round without a jump', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(SearchField(showCancel: true, focusNode: focusNode)),
      );
      focusNode.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final mid = tester.getSize(find.byType(TextField)).width;
      expect(mid, lessThan(320));
      focusNode.unfocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final next = tester.getSize(find.byType(TextField)).width;
      // One frame later it is still about where it was.
      expect((next - mid).abs(), lessThan(20));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(TextField)).width, 320);
    });

    testWidgets('appears at once with reduced motion and with none', (
      tester,
    ) async {
      for (final (theme, reduced) in [
        (ThemeData(motion: Motion.none), false),
        (null, true),
      ]) {
        await tester.pumpWidget(
          _app(
            const SearchField(showCancel: true),
            theme: theme,
            disableAnimations: reduced,
          ),
        );
        await tester.tap(find.byType(TextField));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(cancel.hitTestable(), findsOneWidget);
        expect(tester.getSize(find.byType(TextField)).width, lessThan(300));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('is at the end in a right-to-left locale too', (tester) async {
      await tester.pumpWidget(
        _app(
          const SearchField(showCancel: true, autofocus: true),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(cancel).right,
        lessThan(tester.getRect(find.byType(TextField)).left),
      );
    });

    testWidgets('is not a Tab stop while hidden', (tester) async {
      final after = FocusNode();
      final fieldNode = FocusNode();
      addTearDown(after.dispose);
      addTearDown(fieldNode.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchField(showCancel: true, focusNode: fieldNode),
              Focus(
                focusNode: after,
                autofocus: true,
                child: const SizedBox(height: 10),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(after.hasPrimaryFocus, isTrue);
      // Backwards from what follows: the field, not the hidden button.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(fieldNode.hasFocus, isTrue);
    });
  });

  testWidgets('onTap fires on a field that already has the focus', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_app(SearchField(onTap: () => taps++)));
    await tester.tap(find.byType(SearchField));
    await tester.pump();
    await tester.tap(find.byType(SearchField));
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('a controller swapped in keeps working, and one taken away '
      'leaves the text', (tester) async {
    final controller = TextEditingController(text: 'one');
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(SearchField(controller: controller)));
    expect(find.text('one'), findsOneWidget);
    await tester.pumpWidget(_app(const SearchField()));
    expect(find.text('one'), findsOneWidget);
    await tester.enterText(find.byType(SearchField), 'two');
    await tester.pump();
    expect(controller.text, 'one');
    expect(tester.takeException(), isNull);
  });

  group('shortcut', () {
    Future<bool> chord(
      WidgetTester tester,
      List<LogicalKeyboardKey> modifiers,
    ) async {
      var matched = false;
      bool handler(KeyEvent event) {
        if (SearchField.isSearchShortcut(event)) matched = true;
        return false;
      }

      HardwareKeyboard.instance.addHandler(handler);
      for (final modifier in modifiers) {
        await tester.sendKeyDownEvent(modifier);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      for (final modifier in modifiers.reversed) {
        await tester.sendKeyUpEvent(modifier);
      }
      HardwareKeyboard.instance.removeHandler(handler);
      return matched;
    }

    testWidgets('is ⌘K on Apple platforms and Ctrl+K elsewhere, with no '
        'other modifier', (tester) async {
      await tester.pumpWidget(_app(const SizedBox()));
      const meta = LogicalKeyboardKey.metaLeft;
      const control = LogicalKeyboardKey.controlLeft;
      const alt = LogicalKeyboardKey.altLeft;

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(SearchField.shortcutLabel, '⌘K');
      expect(await chord(tester, [meta]), isTrue);
      expect(await chord(tester, [control]), isFalse);
      expect(await chord(tester, [meta, control]), isFalse);
      expect(await chord(tester, []), isFalse);

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(SearchField.shortcutLabel, 'Ctrl K');
      expect(await chord(tester, [control]), isTrue);
      expect(await chord(tester, [meta]), isFalse);
      // AltGr on Windows.
      expect(await chord(tester, [control, alt]), isFalse);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
