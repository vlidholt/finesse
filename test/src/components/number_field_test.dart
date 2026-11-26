import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// A parent that takes every value it is told, like most do.
class _Host extends StatefulWidget {
  const _Host({
    required this.initial,
    this.min,
    this.max,
    this.step = 1,
    this.decimalDigits = 0,
    this.format,
    this.variant = NumberFieldVariant.field,
    this.changes,
    this.accept = true,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
  });

  final num? initial;
  final num? min;
  final num? max;
  final num step;
  final int decimalDigits;
  final NumberFormat? format;
  final NumberFieldVariant variant;
  final List<num?>? changes;

  /// Whether the parent takes the values it is told.
  final bool accept;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late num? value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return NumberField(
      value: value,
      min: widget.min,
      max: widget.max,
      step: widget.step,
      decimalDigits: widget.decimalDigits,
      format: widget.format,
      variant: widget.variant,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      semanticLabel: 'Guests',
      onChanged: (next) {
        widget.changes?.add(next);
        if (widget.accept) setState(() => value = next);
      },
    );
  }
}

Widget _app(
  Widget child, {
  ThemeData? theme,
  FormFactor? formFactor,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
}) {
  return UnaApp(
    theme: theme,
    formFactor: formFactor,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: direction,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 240, child: child),
                const SizedBox(height: 20),
                // Somewhere else for the focus to go.
                const Focus(child: SizedBox(key: Key('elsewhere'), height: 20)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

String _text(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

final _up = find.byIcon(PhosphorIconsRegular.caretUp);
final _down = find.byIcon(PhosphorIconsRegular.caretDown);
final _plus = find.byIcon(PhosphorIconsRegular.plus);
final _minus = find.byIcon(PhosphorIconsRegular.minus);

Future<void> _blur(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.pump();
}

void main() {
  // Haptics are silent under `flutter test` unless a test asks.
  setUp(() => Haptics.debugEnabledInTests = true);
  tearDown(() => Haptics.debugEnabledInTests = false);

  late List<MethodCall> haptics;

  setUp(() {
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('field, desktop', () {
    testWidgets('shows the value with a pair of stacked carets at the end', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const _Host(initial: 3)));
      expect(_text(tester), '3');
      expect(_up, findsOneWidget);
      expect(_down, findsOneWidget);
      expect(_plus, findsNothing);
      final field = tester.getRect(find.byType(TextField));
      final up = tester.getRect(_up);
      final down = tester.getRect(_down);
      expect(up.center.dx, greaterThan(field.center.dx));
      expect(up.center.dy, lessThan(down.center.dy));
      expect(up.center.dx, down.center.dx);
      // The buttons are inside the field's own height.
      expect(up.top, greaterThanOrEqualTo(field.top));
      expect(down.bottom, lessThanOrEqualTo(field.bottom));
    });

    testWidgets('is exactly as tall as a text field, in every style', (
      tester,
    ) async {
      for (final style in [
        StyleTokens.una,
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        for (final formFactor in FormFactor.values) {
          for (final variant in NumberFieldVariant.values) {
            final theme = ThemeData(style: style).withFormFactor(formFactor);
            await tester.pumpWidget(
              _app(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TextField(key: Key('plain')),
                    _Host(initial: 3, variant: variant),
                  ],
                ),
                theme: theme,
                formFactor: formFactor,
              ),
            );
            expect(
              tester.getSize(find.byType(NumberField)).height,
              tester.getSize(find.byKey(const Key('plain'))).height,
              reason: '$variant $formFactor',
            );
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      }
    });

    testWidgets('the carets step and stop at the bounds', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(_Host(initial: 9, min: 0, max: 10, changes: changes)),
      );
      await tester.tap(_up, kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(_text(tester), '10');
      await tester.tap(_up, kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(changes, [10]);

      await tester.tap(_down, kind: PointerDeviceKind.mouse);
      await tester.tap(_down, kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(changes, [10, 9, 8]);
      expect(_text(tester), '8');
      // A mouse is not told to tick.
      expect(haptics, isEmpty);
    });

    testWidgets('a held button repeats, faster and faster, and stops at the '
        'bound and on release', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(_Host(initial: 0, max: 30, changes: changes)),
      );
      final gesture = await tester.startGesture(tester.getCenter(_up));
      await tester.pump();
      expect(changes, [1]);
      // Nothing more until the hold has lasted.
      await tester.pump(const Duration(milliseconds: 300));
      expect(changes, [1]);
      await tester.pump(const Duration(milliseconds: 150));
      expect(changes.length, 2);

      // The second half-second takes more steps than the first.
      final before = changes.length;
      await tester.pump(const Duration(milliseconds: 500));
      final first = changes.length - before;
      await tester.pump(const Duration(milliseconds: 500));
      final second = changes.length - before - first;
      expect(first, greaterThan(2));
      expect(second, greaterThan(first));

      await gesture.up();
      final released = changes.length;
      await tester.pump(const Duration(seconds: 1));
      expect(changes.length, released);

      // Held to the bound, it stops there.
      final hold = await tester.startGesture(tester.getCenter(_up));
      await tester.pump(const Duration(seconds: 5));
      expect(changes.last, 30);
      expect(_text(tester), '30');
      final atBound = changes.length;
      await tester.pump(const Duration(seconds: 1));
      expect(changes.length, atBound);
      await hold.up();
    });

    testWidgets('the keyboard steps: arrows, Shift, Page Up and Down, Home '
        'and End', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(_Host(initial: 50, min: 0, max: 100, changes: changes)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(changes, [51, 50, 49, 59, 49, 39, 0, 100]);
      expect(_text(tester), '100');
    });

    testWidgets('typing reports numbers within the bounds as they are '
        'typed, and leaving the field clamps and rewrites', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(_Host(initial: 12, min: 10, max: 20, changes: changes)),
      );
      await tester.enterText(find.byType(EditableText), '1');
      await tester.pump();
      // On the way to something in bounds: not reported, not rewritten.
      expect(changes, isEmpty);
      expect(_text(tester), '1');
      await tester.enterText(find.byType(EditableText), '15');
      await tester.pump();
      expect(changes, [15]);

      await tester.enterText(find.byType(EditableText), '150');
      await tester.pump();
      expect(changes, [15]);
      await _blur(tester);
      expect(changes, [15, 20]);
      expect(_text(tester), '20');
    });

    testWidgets('Enter commits and reports through onSubmitted', (
      tester,
    ) async {
      num? submitted;
      num? value = 5;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => NumberField(
              value: value,
              min: 0,
              max: 9,
              onChanged: (next) => setState(() => value = next),
              onSubmitted: (next) => submitted = next,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), '42');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submitted, 9);
      expect(value, 9);
      expect(_text(tester), '9');
    });

    testWidgets('an emptied field reports null; one step from nothing lands '
        'on the bound nearest zero', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(_Host(initial: 7, min: 2, changes: changes)),
      );
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(changes, [null]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(changes, [null, 2]);
    });

    testWidgets('only what makes a number can be typed', (tester) async {
      await tester.pumpWidget(_app(const _Host(initial: 5, min: 0)));
      await tester.enterText(find.byType(EditableText), '5a');
      expect(_text(tester), '5');
      // No sign with a floor at zero, no point without decimals.
      await tester.enterText(find.byType(EditableText), '-5');
      expect(_text(tester), '5');
      await tester.enterText(find.byType(EditableText), '5.5');
      expect(_text(tester), '5');
    });

    testWidgets('decimals: typed with a point or a comma, rounded, and free '
        'of floating-point crumbs when stepped', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(
          _Host(initial: .1, step: .1, decimalDigits: 2, changes: changes),
        ),
      );
      expect(_text(tester), '0.10');
      await tester.tap(_up);
      await tester.tap(_up);
      await tester.pump();
      // .1 + .1 + .1 is not .30000000000000004 here.
      expect(changes, [.2, .3]);
      expect(_text(tester), '0.30');

      await tester.enterText(find.byType(EditableText), '1,5');
      await tester.pump();
      expect(changes.last, 1.5);
      // The parent echoing 1.5 back does not rewrite what is being typed.
      expect(_text(tester), '1,5');
      await _blur(tester);
      expect(_text(tester), '1.50');

      await tester.enterText(find.byType(EditableText), '2.456');
      await _blur(tester);
      expect(changes.last, 2.46);
      expect(_text(tester), '2.46');
    });

    testWidgets('whole numbers are reported as ints', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(_app(_Host(initial: 1, changes: changes)));
      await tester.tap(_up);
      await tester.pump();
      expect(changes.single, isA<int>());
    });

    testWidgets('a format writes and reads the number', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(
          _Host(
            initial: 1234.5,
            decimalDigits: 2,
            format: NumberFormat.currency(locale: 'en_US', symbol: r'$'),
            changes: changes,
          ),
        ),
      );
      expect(_text(tester), r'$1,234.50');
      await tester.tap(_up);
      await tester.pump();
      expect(changes, [1235.5]);
      expect(_text(tester), r'$1,235.50');

      // Typed plainly, it is still read.
      await tester.enterText(find.byType(EditableText), '99');
      await _blur(tester);
      expect(changes.last, 99);
      expect(_text(tester), r'$99.00');
    });

    testWidgets('the parent has the last word: a refused value is written '
        'back, an outside change is shown', (tester) async {
      await tester.pumpWidget(_app(const _Host(initial: 5, accept: false)));
      await tester.enterText(find.byType(EditableText), '8');
      await _blur(tester);
      expect(_text(tester), '5');

      // Not while typing, though.
      num? value = 1;
      late StateSetter set;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return NumberField(value: value, onChanged: (_) {});
            },
          ),
        ),
      );
      set(() => value = 42);
      await tester.pump();
      expect(_text(tester), '42');
    });

    testWidgets('a parent that rebuilds without taking a step is asked for '
        'the same step again', (tester) async {
      for (final variant in NumberFieldVariant.values) {
        final changes = <num?>[];
        await tester.pumpWidget(
          _app(
            StatefulBuilder(
              builder: (context, setState) => NumberField(
                value: 5,
                max: 10,
                variant: variant,
                onChanged: (v) => setState(() => changes.add(v)),
              ),
            ),
          ),
        );
        final up = variant == NumberFieldVariant.field ? _up : _plus;
        for (var i = 0; i < 2; i++) {
          await tester.tap(up, kind: PointerDeviceKind.mouse);
          await tester.pump();
          await tester.pump();
        }
        expect(changes, [6, 6], reason: '$variant');
        if (variant == NumberFieldVariant.field) expect(_text(tester), '5');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('read-only shows no buttons and takes no steps; disabled '
        'dims them', (tester) async {
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(_Host(initial: 5, readOnly: true, changes: changes)),
      );
      expect(_up, findsNothing);
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(changes, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _app(_Host(initial: 5, enabled: false, changes: changes)),
      );
      await tester.tap(_up, warnIfMissed: false);
      await tester.pump();
      expect(changes, isEmpty);
    });

    testWidgets('a step by button does not take the focus', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(_Host(initial: 5, focusNode: focusNode)),
      );
      await tester.tap(_up);
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
    });
  });

  group('field, phone', () {
    testWidgets('a minus at the start and a plus at the end, touch sized, '
        'around a centred value', (tester) async {
      await tester.pumpWidget(
        _app(const _Host(initial: 3), formFactor: FormFactor.mobile),
      );
      expect(_up, findsNothing);
      final field = tester.getRect(find.byType(TextField));
      final minus = tester.getRect(_minus);
      final plus = tester.getRect(_plus);
      expect(minus.center.dx, lessThan(field.center.dx));
      expect(plus.center.dx, greaterThan(field.center.dx));
      expect(field.height, greaterThanOrEqualTo(44));
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.textAlign, TextAlign.center);

      // A tap well inside the 44-point square at either end steps.
      await tester.tapAt(field.centerRight - const Offset(8, 0));
      await tester.pump();
      expect(_text(tester), '4');
      await tester.tapAt(field.centerLeft + const Offset(40, 0));
      await tester.pump();
      expect(_text(tester), '3');
    });

    testWidgets('each step by touch is a tick of haptic feedback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const _Host(initial: 3, max: 4),
          formFactor: FormFactor.mobile,
        ),
      );
      await tester.tap(_plus);
      await tester.pump();
      expect(haptics, hasLength(1));
      expect(haptics.single.arguments, 'HapticFeedbackType.selectionClick');
      // At the bound nothing moves, so nothing ticks.
      await tester.tap(_plus);
      await tester.pump();
      expect(haptics, hasLength(1));
    });

    testWidgets('is mirrored in a right-to-left locale', (tester) async {
      await tester.pumpWidget(
        _app(
          const _Host(initial: 3),
          formFactor: FormFactor.mobile,
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getCenter(_minus).dx,
        greaterThan(tester.getCenter(_plus).dx),
      );
    });
  });

  group('stepper', () {
    testWidgets('is a compact pill with no text field', (tester) async {
      await tester.pumpWidget(
        _app(
          const Align(
            child: _Host(initial: 2, variant: NumberFieldVariant.stepper),
          ),
        ),
      );
      expect(find.byType(EditableText), findsNothing);
      expect(find.text('2'), findsOneWidget);
      final size = tester.getSize(find.byType(NumberField));
      expect(size.width, lessThan(160));
      final minus = tester.getCenter(_minus);
      final value = tester.getCenter(find.text('2'));
      final plus = tester.getCenter(_plus);
      expect(minus.dx, lessThan(value.dx));
      expect(value.dx, lessThan(plus.dx));
    });

    testWidgets('steps by button and by key, and stops at the bounds', (
      tester,
    ) async {
      final changes = <num?>[];
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          Align(
            child: _Host(
              initial: 1,
              min: 1,
              max: 3,
              variant: NumberFieldVariant.stepper,
              focusNode: focusNode,
              changes: changes,
            ),
          ),
        ),
      );
      await tester.tap(_minus);
      await tester.pump();
      expect(changes, isEmpty);
      await tester.tap(_plus);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);

      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(changes, [2, 3, 2, 1, 3]);
    });

    testWidgets('left and right swap in a right-to-left locale', (
      tester,
    ) async {
      final changes = <num?>[];
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          Align(
            child: _Host(
              initial: 5,
              variant: NumberFieldVariant.stepper,
              focusNode: focusNode,
              changes: changes,
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(changes, [6]);
      expect(
        tester.getCenter(_minus).dx,
        greaterThan(tester.getCenter(_plus).dx),
      );
    });

    testWidgets('the value switches in motion and comes to rest; with no '
        'motion it is there at once', (tester) async {
      for (final theme in [null, ThemeData(motion: Motion.none)]) {
        await tester.pumpWidget(
          _app(
            const Align(
              child: _Host(initial: 1, variant: NumberFieldVariant.stepper),
            ),
            theme: theme,
          ),
        );
        await tester.tap(_plus);
        await tester.pump();
        expect(find.text('2'), findsOneWidget);
        if (theme != null) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.hasRunningAnimations, isFalse);
        }
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('grows with the text scale without overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Align(
            child: _Host(initial: 128, variant: NumberFieldVariant.stepper),
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      final pill = tester.getRect(find.byType(NumberField));
      final label = tester.getRect(find.text('128'));
      expect(label.top, greaterThanOrEqualTo(pill.top));
      expect(label.bottom, lessThanOrEqualTo(pill.bottom));
      expect(label.left, greaterThan(tester.getRect(_minus).right));
      expect(label.right, lessThan(tester.getRect(_plus).left));
    });
  });

  group('semantics', () {
    testWidgets('the stepper is one adjustable node with its value', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(
          Align(
            child: _Host(
              initial: 2,
              min: 1,
              max: 3,
              variant: NumberFieldVariant.stepper,
              changes: changes,
            ),
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(NumberField));
      expect(node.label, 'Guests');
      expect(node.value, '2');
      expect(node.increasedValue, '3');
      expect(node.decreasedValue, '1');
      final data = node.getSemanticsData();
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);

      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.increase,
      );
      await tester.pumpAndSettle();
      expect(changes, [3]);
      // At the top there is nothing more to increase to.
      final top = tester
          .getSemantics(find.byType(NumberField))
          .getSemanticsData();
      expect(top.hasAction(SemanticsAction.increase), isFalse);
      expect(top.hasAction(SemanticsAction.decrease), isTrue);
      handle.dispose();
    });

    testWidgets('the field can be adjusted around a text field, and its '
        'buttons are not separate stops', (tester) async {
      final handle = tester.ensureSemantics();
      final changes = <num?>[];
      await tester.pumpWidget(
        _app(_Host(initial: 2, min: 1, max: 3, changes: changes)),
      );
      final node = tester.getSemantics(find.byType(NumberField));
      final data = node.getSemanticsData();
      expect(data.label, 'Guests');
      expect(data.value, '2');
      expect(data.increasedValue, '3');
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);
      final field = tester.getSemantics(
        find.byElementPredicate((e) => e.renderObject is RenderEditable),
      );
      expect(field.flagsCollection.isTextField, isTrue);
      expect(field.value, '2');
      // Nothing else under it: the carets are the node's own actions.
      expect(find.bySemanticsLabel(RegExp('Increase|Decrease')), findsNothing);
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.decrease,
      );
      await tester.pump();
      expect(changes, [1]);
      handle.dispose();
    });
  });

  testWidgets('NumberFormField validates, saves and resets', (tester) async {
    final formKey = GlobalKey<UnaFormState>();
    await tester.pumpWidget(
      _app(
        UnaForm(
          key: formKey,
          child: NumberFormField(
            id: 'guests',
            label: const Text('Guests'),
            initialValue: 2,
            min: 0,
            max: 12,
            validator: (value) =>
                (value ?? 0) < 1 ? 'At least one guest' : null,
          ),
        ),
      ),
    );
    expect(_text(tester), '2');
    await tester.tap(_down);
    await tester.tap(_down);
    await tester.pump();
    expect(formKey.currentState!.value['guests'], 0);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('At least one guest'), findsOneWidget);

    formKey.currentState!.reset();
    await tester.pump();
    expect(_text(tester), '2');
    expect(formKey.currentState!.value['guests'], 2);
  });
}
