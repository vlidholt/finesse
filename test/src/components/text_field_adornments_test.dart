import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

Widget _app(Widget child, {ThemeData? theme, double textScale = 1}) {
  return UnaApp(
    theme: theme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Center(child: SizedBox(width: 320, child: child)),
      ),
    ),
  );
}

final _clear = find.bySemanticsLabel('Clear');
final _reveal = find.bySemanticsLabel('Show password');

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('clearable', () {
    testWidgets('the button shows only while there is text, clears, keeps '
        'the focus and reports the change', (tester) async {
      final changes = <String>[];
      var cleared = 0;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          TextField(
            clearable: true,
            focusNode: focusNode,
            onChanged: changes.add,
            onCleared: () => cleared++,
          ),
        ),
      );
      expect(_clear, findsNothing);

      await tester.enterText(find.byType(TextField), 'hello');
      await _settle(tester);
      expect(_clear, findsOneWidget);
      expect(changes, ['hello']);

      await tester.tap(_clear);
      await _settle(tester);
      expect(find.text('hello'), findsNothing);
      expect(changes, ['hello', '']);
      expect(cleared, 1);
      expect(focusNode.hasFocus, isTrue);
      expect(_clear, findsNothing);
    });

    testWidgets("a controller's text shows it too, and it is not a Tab "
        'stop', (tester) async {
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);
      final after = FocusNode();
      addTearDown(after.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                clearable: true,
                autofocus: true,
              ),
              Focus(focusNode: after, child: const SizedBox(height: 10)),
            ],
          ),
        ),
      );
      await _settle(tester);
      expect(_clear, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(after.hasPrimaryFocus, isTrue);

      controller.clear();
      await _settle(tester);
      expect(_clear, findsNothing);
    });

    testWidgets('not shown while disabled or read-only', (tester) async {
      for (final field in const [
        TextField(initialValue: 'abc', clearable: true, enabled: false),
        TextField(initialValue: 'abc', clearable: true, readOnly: true),
      ]) {
        await tester.pumpWidget(_app(field));
        await _settle(tester);
        expect(_clear, findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('does not make the field taller, in any style, at any '
        'text scale', (tester) async {
      for (final style in [StyleTokens.fluid, StyleTokens.crisp]) {
        for (final formFactor in FormFactor.values) {
          for (final scale in [1.0, 2.0]) {
            final theme = ThemeData(style: style).withFormFactor(formFactor);
            await tester.pumpWidget(
              _app(
                const TextField(initialValue: 'abc'),
                theme: theme,
                textScale: scale,
              ),
            );
            final plain = tester.getSize(find.byType(TextField)).height;
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpWidget(
              _app(
                const TextField(
                  initialValue: 'abc',
                  clearable: true,
                  revealable: true,
                  obscureText: true,
                ),
                theme: theme,
                textScale: scale,
              ),
            );
            await _settle(tester);
            expect(_clear, findsOneWidget);
            expect(
              tester.getSize(find.byType(TextField)).height,
              plain,
              reason: '$formFactor at $scale',
            );
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      }
    });

    testWidgets('sits at the end, mirrored in a right-to-left locale', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          _app(
            Directionality(
              textDirection: direction,
              child: const TextField(initialValue: 'abc', clearable: true),
            ),
          ),
        );
        await _settle(tester);
        final field = tester.getRect(find.byType(TextField));
        final button = tester.getRect(_clear);
        expect(
          button.center.dx > field.center.dx,
          direction == TextDirection.ltr,
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  });

  group('password', () {
    testWidgets('is obscured, with the right keyboard and hints', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const TextField.password()));
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.obscureText, isTrue);
      expect(editable.autocorrect, isFalse);
      expect(editable.enableSuggestions, isFalse);
      expect(editable.keyboardType, TextInputType.visiblePassword);
      expect(editable.autofillHints, [AutofillHints.password]);
    });

    testWidgets('the toggle reveals and hides, by pointer and keyboard, and '
        'says which', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const TextField.password(initialValue: 'secret')),
      );
      bool obscured() =>
          tester.widget<EditableText>(find.byType(EditableText)).obscureText;
      expect(obscured(), isTrue);
      // The icon shows the state: crossed out while hidden.
      expect(find.byIcon(PhosphorIconsRegular.eyeSlash), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.eye), findsNothing);
      expect(
        tester.getSemantics(_reveal),
        isSemantics(
          label: 'Show password',
          isButton: true,
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      await tester.tap(_reveal);
      await _settle(tester);
      expect(obscured(), isFalse);
      expect(find.byIcon(PhosphorIconsRegular.eye), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.eyeSlash), findsNothing);
      expect(
        tester.getSemantics(_reveal).flagsCollection.isToggled.toString(),
        contains('isTrue'),
      );

      // Tab from the field reaches the toggle; Space flips it back.
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await _settle(tester);
      expect(obscured(), isTrue);
      handle.dispose();
    });

    testWidgets('revealable does nothing without obscureText', (tester) async {
      await tester.pumpWidget(
        _app(const TextField(initialValue: 'abc', revealable: true)),
      );
      expect(_reveal, findsNothing);
    });

    testWidgets('TextFormField.password validates like any field', (
      tester,
    ) async {
      final formKey = GlobalKey<UnaFormState>();
      await tester.pumpWidget(
        _app(
          UnaForm(
            key: formKey,
            child: TextFormField.password(
              id: 'password',
              validator: (value) => value.length < 8 ? 'Too short' : null,
            ),
          ),
        ),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
      expect(_reveal, findsOneWidget);
      await tester.enterText(find.byType(TextField), 'abc');
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Too short'), findsOneWidget);
      expect(formKey.currentState!.value['password'], 'abc');
    });
  });

  group('counter', () {
    testWidgets('counts against the limit and announces reaching it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const TextField(showCounter: true, maxLength: 5)),
      );
      expect(find.text('0/5'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('3/5'), findsOneWidget);
      final counting = tester.getSemantics(
        find.bySemanticsLabel('3 of 5 characters'),
      );
      expect(counting.flagsCollection.isLiveRegion, isFalse);

      await tester.enterText(find.byType(TextField), 'abcdefgh');
      await tester.pump();
      // The formatter holds it to the limit.
      expect(find.text('5/5'), findsOneWidget);
      final full = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Character limit reached')),
      );
      expect(full.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('counts characters as the user sees them', (tester) async {
      await tester.pumpWidget(
        _app(const TextField(showCounter: true, initialValue: '👨‍👩‍👧é')),
      );
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('is at the end, under the text, after the bottom widget', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const TextField(
            showCounter: true,
            maxLength: 80,
            initialValue: 'abc',
            bottom: Text('hint'),
          ),
        ),
      );
      final field = tester.getRect(find.byType(TextField));
      final counter = tester.getRect(find.text('3/80'));
      final text = tester.getRect(find.byType(EditableText));
      expect(counter.top, greaterThanOrEqualTo(text.bottom));
      expect(counter.right, lessThan(field.right));
      expect(counter.center.dx, greaterThan(field.center.dx));
      expect(
        tester.getRect(find.text('hint')).left,
        lessThan(counter.left),
      );
    });

    testWidgets('Textarea and the form fields take it too', (tester) async {
      await tester.pumpWidget(
        _app(const Textarea(showCounter: true, maxLength: 200)),
      );
      expect(find.text('0/200'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());

      await tester.pumpWidget(
        _app(
          UnaForm(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  id: 'name',
                  showCounter: true,
                  maxLength: 20,
                  clearable: true,
                  initialValue: 'Ada',
                ),
                TextareaFormField(id: 'bio', showCounter: true),
              ],
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(find.text('3/20'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(_clear, findsOneWidget);
    });
  });

  testWidgets('the adornments keep leading and trailing in place', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const TextField(
          initialValue: 'abc',
          clearable: true,
          leading: SizedBox(key: Key('lead'), width: 16, height: 16),
          trailing: SizedBox(key: Key('trail'), width: 16, height: 16),
        ),
      ),
    );
    await _settle(tester);
    final lead = tester.getRect(find.byKey(const Key('lead')));
    final text = tester.getRect(find.byType(EditableText));
    final clear = tester.getRect(_clear);
    final trail = tester.getRect(find.byKey(const Key('trail')));
    final gap = Theme.of(
      tester.element(find.byType(TextField)),
    ).textFieldTheme.gap!;
    expect(text.left - lead.right, gap);
    expect(clear.left, greaterThanOrEqualTo(text.right + gap - .5));
    expect(trail.left - clear.right, gap);
    expect(tester.takeException(), isNull);
    // Painted in order, nothing overlapping.
    expect(
      tester.renderObject<RenderBox>(find.byType(TextField)).size.width,
      320,
    );
  });
}
