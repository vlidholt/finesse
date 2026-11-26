import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.initial = const [],
    this.maxTags,
    this.options,
    this.changes,
    this.enabled = true,
    this.focusNode,
  });

  final List<String> initial;
  final int? maxTags;
  final List<String>? options;
  final List<List<String>>? changes;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<String> values = widget.initial;

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    return TagField<String>(
      values: values,
      maxTags: widget.maxTags,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      placeholder: const Text('Add a topic'),
      semanticLabel: 'Topics',
      labelBuilder: (context, tag) => Text(tag),
      optionsBuilder: options == null
          ? null
          : (value) => options.where(
              (option) =>
                  value.text.isNotEmpty &&
                  option.toLowerCase().startsWith(value.text.toLowerCase()),
            ),
      onChanged: (next) {
        widget.changes?.add(next);
        setState(() => values = next);
      },
    );
  }
}

Widget _app(
  Widget child, {
  ThemeData? theme,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double width = 320,
}) {
  return UnaApp(
    theme: theme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: direction,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: width, child: child),
                  const SizedBox(height: 16),
                  const Focus(child: SizedBox(height: 20, width: 20)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(EditableText), text);
  await tester.pump();
}

Future<void> _enter(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await _settle(tester);
}

String _input(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

Finder _remove(String tag) => find.bySemanticsLabel('Remove $tag');

void main() {
  testWidgets('empty, it is exactly a text field: same height, the '
      'placeholder where a text field has it', (tester) async {
    for (final style in [
      StyleTokens.fluid,
      StyleTokens.crisp,
      StyleTokens.pebble,
      StyleTokens.sharp,
    ]) {
      for (final formFactor in FormFactor.values) {
        final theme = ThemeData(style: style).withFormFactor(formFactor);
        for (final initial in [
          <String>[],
          ['design'],
        ]) {
          await tester.pumpWidget(
            _app(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TextField(
                    key: Key('plain'),
                    placeholder: Text('Add a topic'),
                  ),
                  _Host(initial: initial),
                ],
              ),
              theme: theme,
            ),
          );
          expect(
            tester.getSize(find.byType(TagField<String>)).height,
            tester.getSize(find.byKey(const Key('plain'))).height,
            reason: '$formFactor, $initial',
          );
          if (initial.isEmpty) {
            expect(
              tester.getRect(find.text('Add a topic').last).left,
              tester.getRect(find.text('Add a topic').first).left,
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    }
  });

  testWidgets('with tags or without, it is as wide as a text field where '
      'its parent lets it be narrower; unbounded, as wide as its tags', (
    tester,
  ) async {
    for (final initial in [
      <String>[],
      ['dart', 'flutter'],
    ]) {
      // A column that does not stretch hands its children loose
      // constraints, as a form field's does.
      await tester.pumpWidget(
        _app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(key: Key('plain')),
              _Host(initial: initial),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(TagField<String>)).width,
        tester.getSize(find.byKey(const Key('plain'))).width,
        reason: '$initial',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
    await tester.pumpWidget(
      _app(
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _Host(initial: ['dart']),
        ),
      ),
    );
    expect(tester.getSize(find.byType(TagField<String>)).width, lessThan(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Enter turns the text into a tag and stays for the next', (
    tester,
  ) async {
    final changes = <List<String>>[];
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      _app(_Host(changes: changes, focusNode: focusNode)),
    );
    await _type(tester, 'design');
    await _enter(tester);
    expect(changes, [
      ['design'],
    ]);
    expect(find.text('design'), findsOneWidget);
    expect(_input(tester), isEmpty);
    expect(focusNode.hasFocus, isTrue);
    // The placeholder is gone once there is a tag.
    expect(find.text('Add a topic'), findsNothing);

    await _type(tester, '  motion ');
    await _enter(tester);
    expect(changes.last, ['design', 'motion']);
  });

  testWidgets('a separator ends a tag while typing, and a pasted list '
      'becomes that many tags', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(_app(_Host(changes: changes)));
    await _type(tester, 'design,');
    expect(changes.last, ['design']);
    expect(_input(tester), isEmpty);

    await _type(tester, 'motion, type ,, colour');
    await _settle(tester);
    expect(changes.last, ['design', 'motion', 'type']);
    // What follows the last separator is still being typed.
    expect(_input(tester), ' colour');
  });

  testWidgets('a tag is not added twice, nor an empty one', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(_Host(initial: const ['design'], changes: changes)),
    );
    await _type(tester, 'design');
    await _enter(tester);
    await _type(tester, '   ');
    await _enter(tester);
    expect(changes, isEmpty);
    expect(_input(tester), isEmpty);
  });

  testWidgets('leaving the field keeps what was typed, as a tag', (
    tester,
  ) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(_app(_Host(changes: changes)));
    await _type(tester, 'design');
    FocusManager.instance.primaryFocus!.unfocus();
    await _settle(tester);
    expect(changes.last, ['design']);
  });

  testWidgets('the remove button removes its tag', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(_Host(initial: const ['design', 'motion'], changes: changes)),
    );
    await tester.tap(_remove('design'));
    await _settle(tester);
    expect(changes.last, ['motion']);
    expect(find.text('design'), findsNothing);
  });

  group('keyboard', () {
    testWidgets('Backspace in an empty input marks the last tag, and again '
        'removes it; then the next', (tester) async {
      final handle = tester.ensureSemantics();
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(_Host(initial: const ['a', 'b', 'c'], changes: changes)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(changes, isEmpty);
      expect(
        tester
            .getSemantics(find.text('c'))
            .flagsCollection
            .isSelected
            .toString(),
        contains('isTrue'),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await _settle(tester);
      expect(changes.last, ['a', 'b']);
      // The mark moved on to the new last tag: one more press removes it.
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await _settle(tester);
      expect(changes.last, ['a']);
      handle.dispose();
    });

    testWidgets('with text in the input Backspace only edits the text', (
      tester,
    ) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(_Host(initial: const ['a'], changes: changes)),
      );
      await _type(tester, 'xy');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(changes, isEmpty);
    });

    testWidgets('the arrows move the mark along the tags and back into the '
        'input; Delete removes the marked tag; typing drops the mark', (
      tester,
    ) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(_Host(initial: const ['a', 'b', 'c'], changes: changes)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await _settle(tester);
      expect(changes.last, ['a', 'c']);

      // Right, past the last tag, is the input again: Backspace then marks
      // rather than removes.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await _settle(tester);
      expect(changes.last, ['a', 'c']);

      await _type(tester, 'd');
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await _settle(tester);
      expect(changes.last, ['a', 'c']);
    });

    testWidgets('left and right swap in a right-to-left locale', (
      tester,
    ) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(
          _Host(initial: const ['a', 'b'], changes: changes),
          direction: TextDirection.rtl,
        ),
      );
      // The first tag is at the right.
      expect(
        tester.getCenter(find.text('a')).dx,
        greaterThan(tester.getCenter(find.text('b')).dx),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await _settle(tester);
      expect(changes.last, ['b']);
    });
  });

  testWidgets('maxTags: nothing is added past it and the input is closed', (
    tester,
  ) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(_Host(initial: const ['a'], maxTags: 2, changes: changes)),
    );
    await _type(tester, 'b,c,d,');
    await _settle(tester);
    expect(changes.last, ['a', 'b']);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );
    // A removed tag opens it again.
    await tester.tap(_remove('a'));
    await _settle(tester);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isFalse,
    );
  });

  testWidgets('parse decides what a text stands for, and may refuse', (
    tester,
  ) async {
    var values = <int>[];
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => TagField<int>(
            values: values,
            parse: int.tryParse,
            labelBuilder: (context, tag) => Text('#$tag'),
            onChanged: (next) => setState(() => values = next),
          ),
        ),
      ),
    );
    await _type(tester, '42');
    await _enter(tester);
    await _type(tester, 'nope');
    await _enter(tester);
    expect(values, [42]);
    expect(find.text('#42'), findsOneWidget);
  });

  group('suggestions', () {
    const options = ['Design', 'Development', 'Data', 'Motion'];

    testWidgets('open under the field, leave out tags already there, and '
        'Enter takes the highlighted one', (tester) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(
          _Host(
            initial: const ['Data'],
            options: options,
            changes: changes,
          ),
        ),
      );
      await _type(tester, 'd');
      await _settle(tester);
      expect(find.text('Design').hitTestable(), findsOneWidget);
      expect(find.text('Development').hitTestable(), findsOneWidget);
      // Already a tag: only the tag itself reads "Data".
      expect(find.text('Data'), findsOneWidget);
      final field = tester.getRect(find.byType(TagField<String>));
      expect(tester.getRect(find.text('Design')).top, greaterThan(field.top));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(changes.last, ['Data', 'Development']);
      expect(_input(tester), isEmpty);
      // The list is gone and the focus is still in the input.
      expect(find.text('Design'), findsNothing);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
    });

    testWidgets('a click takes one; Escape closes the list and keeps the '
        'text', (tester) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        _app(_Host(options: options, changes: changes)),
      );
      await _type(tester, 'mo');
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(find.text('Motion'), findsNothing);
      expect(_input(tester), 'mo');

      await _type(tester, 'mot');
      await _settle(tester);
      await tester.tap(find.text('Motion'));
      await _settle(tester);
      expect(changes.last, ['Motion']);
    });
  });

  testWidgets('many tags wrap onto further lines and the field grows; a tap '
      'anywhere in it focuses the input', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      _app(
        _Host(
          initial: [for (var i = 0; i < 9; i++) 'topic $i'],
          focusNode: focusNode,
        ),
        width: 260,
      ),
    );
    expect(tester.takeException(), isNull);
    final field = tester.getRect(find.byType(TagField<String>));
    expect(field.height, greaterThan(80));
    for (var i = 0; i < 9; i++) {
      final tag = tester.getRect(find.text('topic $i'));
      expect(tag.left, greaterThanOrEqualTo(field.left));
      expect(tag.right, lessThanOrEqualTo(field.right));
    }
    await tester.tapAt(field.bottomRight - const Offset(6, 6));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('a long tag is cut short rather than overflowing; a large text '
      'scale grows the tags', (tester) async {
    await tester.pumpWidget(
      _app(
        const _Host(
          initial: ['a tag far too long to fit the field it is put in'],
        ),
        width: 200,
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(const _Host(initial: ['design'])));
    final resting = tester.getSize(find.byType(TagField<String>)).height;

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _app(const _Host(initial: ['design']), textScale: 2),
    );
    expect(tester.takeException(), isNull);
    final field = tester.getRect(find.byType(TagField<String>));
    final label = tester.getRect(find.text('design'));
    expect(field.height, greaterThan(resting));
    expect(label.top, greaterThanOrEqualTo(field.top));
    expect(label.bottom, lessThanOrEqualTo(field.bottom));
  });

  testWidgets('disabled, it changes nothing', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(
        _Host(initial: const ['design'], enabled: false, changes: changes),
      ),
    );
    // Its tags have no remove button, as a disabled `Chip` has none, and
    // neither a tap nor the keyboard takes one away.
    expect(_remove('design'), findsNothing);
    expect(find.byIcon(PhosphorIconsBold.x), findsNothing);
    await tester.tap(find.text('design'), warnIfMissed: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await _settle(tester);
    expect(changes, isEmpty);
    expect(find.text('design'), findsOneWidget);
  });

  testWidgets('announces what was added and removed', (tester) async {
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
    await tester.pumpWidget(_app(const _Host()));
    await _type(tester, 'design');
    await _enter(tester);
    await tester.tap(_remove('design'));
    await _settle(tester);
    expect(announcements, ['design added', 'design removed']);
  });

  testWidgets('a new tag arrives in motion and settles; the tags the field '
      'was built with are simply there', (tester) async {
    await tester.pumpWidget(_app(const _Host(initial: ['design'])));
    // Nothing of the tag's is in motion: it is at full size from the first
    // frame.
    final first = tester.getSize(find.text('design'));
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.getSize(find.text('design')), first);
    await tester.pumpAndSettle();

    await _type(tester, 'motion');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    expect(find.text('motion'), findsOneWidget);
  });
}
