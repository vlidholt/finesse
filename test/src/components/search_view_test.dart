import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

const _people = ['Ada Lovelace', 'Alan Turing', 'Grace Hopper'];

/// A page with a button that opens the search and shows what it returned.
class _Opener extends StatefulWidget {
  const _Opener({
    this.debounce = const Duration(milliseconds: 200),
    this.queries,
    this.initialQuery = '',
    this.rows = 0,
  });

  final Duration debounce;

  /// Every query the builder was called with.
  final List<String>? queries;
  final String initialQuery;

  /// Extra rows, to make the results longer than the view.
  final int rows;

  @override
  State<_Opener> createState() => _OpenerState();
}

class _OpenerState extends State<_Opener> {
  String result = 'none';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button(
            onPressed: () async {
              final person = await showSearch<String>(
                context: context,
                placeholder: const Text('Search people'),
                debounce: widget.debounce,
                initialQuery: widget.initialQuery,
                builder: (context, query, close) {
                  widget.queries?.add(query);
                  final matches = [
                    for (final person in _people)
                      if (person.toLowerCase().contains(query.toLowerCase()))
                        person,
                  ];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (query.isEmpty) const Text('Type a name'),
                      for (final person in matches)
                        ListTile(
                          title: Text(person),
                          onTap: () => close(person),
                        ),
                      for (var i = 0; i < widget.rows; i++)
                        ListTile(title: Text('Row $i'), onTap: () {}),
                    ],
                  );
                },
              );
              if (mounted) setState(() => result = person ?? 'dismissed');
            },
            child: const Text('Open'),
          ),
          Text('Result: $result'),
        ],
      ),
    );
  }
}

Widget _app(
  Widget child, {
  FormFactor formFactor = FormFactor.desktop,
  ThemeData? theme,
  TextDirection direction = TextDirection.ltr,
}) {
  return UnaApp(
    theme: theme,
    formFactor: formFactor,
    builder: (context, app) =>
        Directionality(textDirection: direction, child: app!),
    home: Scaffold(body: child),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 14; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await _settle(tester);
}

bool _focusIsInside(Finder finder) {
  final focus = FocusManager.instance.primaryFocus?.context;
  if (focus == null) return false;
  final target = finder.evaluate().toSet();
  var inside = false;
  focus.visitAncestorElements((element) {
    if (target.contains(element)) {
      inside = true;
      return false;
    }
    return true;
  });
  return inside;
}

void main() {
  for (final formFactor in FormFactor.values) {
    group('$formFactor', () {
      testWidgets('opens with the field focused, builds for the query and '
          'returns what the builder closes with', (tester) async {
        await tester.pumpWidget(
          _app(const _Opener(), formFactor: formFactor),
        );
        await _open(tester);
        expect(find.byType(SearchField), findsOneWidget);
        expect(find.text('Search people'), findsOneWidget);
        expect(find.text('Type a name'), findsOneWidget);
        expect(_focusIsInside(find.byType(SearchField)), isTrue);

        await tester.enterText(find.byType(SearchField), 'grace');
        await _settle(tester);
        expect(find.text('Grace Hopper'), findsOneWidget);
        expect(find.text('Ada Lovelace'), findsNothing);

        await tester.tap(find.text('Grace Hopper'));
        await _settle(tester);
        expect(find.byType(SearchField), findsNothing);
        expect(find.text('Result: Grace Hopper'), findsOneWidget);
      });

      testWidgets('Escape clears the query, then leaves with null', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(const _Opener(), formFactor: formFactor),
        );
        await _open(tester);
        await tester.enterText(find.byType(SearchField), 'ada');
        await _settle(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await _settle(tester);
        expect(find.byType(SearchField), findsOneWidget);
        expect(find.text('Type a name'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await _settle(tester);
        expect(find.byType(SearchField), findsNothing);
        expect(find.text('Result: dismissed'), findsOneWidget);
      });

      testWidgets('the arrows and Tab walk from the field into the results; '
          'Enter takes one; Escape leaves from one', (tester) async {
        await tester.pumpWidget(
          _app(const _Opener(), formFactor: formFactor),
        );
        await _open(tester);
        await tester.enterText(find.byType(SearchField), 'a');
        await _settle(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(
          _focusIsInside(find.widgetWithText(ListTile, 'Ada Lovelace')),
          isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(
          _focusIsInside(find.widgetWithText(ListTile, 'Alan Turing')),
          isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(_focusIsInside(find.byType(SearchField)), isTrue);
        // The arrows stop at the ends.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(_focusIsInside(find.byType(SearchField)), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await _settle(tester);
        expect(find.text('Result: Alan Turing'), findsOneWidget);

        // From a result, Escape leaves at once: there is no query of the
        // result's to clear.
        await _open(tester);
        await tester.enterText(find.byType(SearchField), 'a');
        await _settle(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await _settle(tester);
        expect(find.byType(SearchField), findsNothing);
        expect(find.text('Result: dismissed'), findsOneWidget);
      });

      testWidgets('long results scroll inside the view without overflowing', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(const _Opener(rows: 60), formFactor: formFactor),
        );
        await _open(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('Row 0'), findsOneWidget);
        expect(find.text('Row 59').hitTestable(), findsNothing);
        await tester.dragUntilVisible(
          find.text('Row 59'),
          find.byType(SingleChildScrollView).last,
          const Offset(0, -400),
        );
        await tester.pump();
        expect(find.text('Row 59').hitTestable(), findsOneWidget);
        // The field stays put above the results.
        expect(find.byType(SearchField).hitTestable(), findsOneWidget);
      });
    });
  }

  testWidgets('phone: a page with a back button that leaves with null', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(const _Opener(), formFactor: FormFactor.mobile),
    );
    await _open(tester);
    // It covers the page that opened it.
    expect(find.text('Open').hitTestable(), findsNothing);
    final field = tester.getRect(find.byType(SearchField));
    expect(field.top, lessThan(80));
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    final back = find.bySemanticsLabel('Close search');
    expect(tester.getRect(back).right, lessThanOrEqualTo(field.left));
    await tester.tap(back);
    await _settle(tester);
    expect(find.text('Result: dismissed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone, right-to-left: the back button is at the other end and '
      'points the other way', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        const _Opener(),
        formFactor: FormFactor.mobile,
        direction: TextDirection.rtl,
      ),
    );
    await _open(tester);
    expect(
      find.descendant(
        of: find.byType(BackButton),
        matching: find.byIcon(PhosphorIconsRegular.caretRight),
      ),
      findsOneWidget,
    );
    expect(
      tester.getRect(find.bySemanticsLabel('Close search')).left,
      greaterThanOrEqualTo(tester.getRect(find.byType(SearchField)).right),
    );
  });

  testWidgets('desktop: a palette on the command surface, over the page, '
      'that a click outside dismisses', (tester) async {
    await tester.pumpWidget(_app(const _Opener()));
    await _open(tester);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(
      tester.getSize(find.byType(SearchField)).width,
      lessThanOrEqualTo(560),
    );
    // Towards the top, where it stays while the results change its height.
    expect(tester.getRect(find.byType(SearchField)).top, lessThan(200));
    final theme = Theme.of(tester.element(find.byType(SearchField)));
    expect(
      tester.getSize(find.byType(TextField)).height,
      theme.commandTheme.searchHeight,
    );

    await tester.tapAt(const Offset(10, 10));
    await _settle(tester);
    expect(find.byType(SearchField), findsNothing);
    expect(find.text('Result: dismissed'), findsOneWidget);
  });

  testWidgets('the builder is asked once typing has paused, and at once '
      'when the field is emptied or the search key is pressed', (
    tester,
  ) async {
    final queries = <String>[];
    await tester.pumpWidget(
      _app(
        _Opener(
          debounce: const Duration(milliseconds: 300),
          queries: queries,
        ),
      ),
    );
    await _open(tester);
    queries.clear();

    await tester.enterText(find.byType(SearchField), 'a');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(SearchField), 'ad');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(SearchField), 'ada');
    await tester.pump(const Duration(milliseconds: 100));
    expect(queries.where((q) => q.isNotEmpty), isEmpty);
    await tester.pump(const Duration(milliseconds: 300));
    expect(queries.toSet(), {'ada'});

    queries.clear();
    await tester.enterText(find.byType(SearchField), '');
    await tester.pump();
    expect(queries, contains(''));

    queries.clear();
    await tester.enterText(find.byType(SearchField), 'gr');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(queries, contains('gr'));
  });

  testWidgets('initialQuery fills the field and the first results', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const _Opener(initialQuery: 'alan')));
    await _open(tester);
    expect(find.text('Alan Turing'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsNothing);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'alan',
    );
  });

  testWidgets('settles, in every style, and is there at once with no motion', (
    tester,
  ) async {
    for (final formFactor in FormFactor.values) {
      for (final theme in [
        ThemeData(),
        ThemeData(style: StyleTokens.crisp),
        ThemeData(motion: Motion.none),
      ]) {
        await tester.pumpWidget(
          _app(const _Opener(), formFactor: formFactor, theme: theme),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(SearchField).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}
