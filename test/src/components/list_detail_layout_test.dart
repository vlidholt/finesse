import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// [ListDetailLayout]: two panes on a desktop, a list with its detail
/// pushed over it on a phone.

/// Counts taps, to tell whether its state was kept.
class _Counter extends StatefulWidget {
  const _Counter(this.name, {super.key});

  final String name;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => taps++),
    child: SizedBox.expand(child: Text('${widget.name} $taps')),
  );
}

/// An app that opens item 1 or 2 from its list.
class _Mail extends StatefulWidget {
  const _Mail({this.resizable = false, this.closes, super.key});

  final bool resizable;
  final List<int>? closes;

  @override
  State<_Mail> createState() => _MailState();
}

class _MailState extends State<_Mail> {
  int? open;

  @override
  Widget build(BuildContext context) {
    return ListDetailLayout(
      resizable: widget.resizable,
      list: Column(
        children: [
          for (final id in [1, 2])
            GestureDetector(
              onTap: () => setState(() => open = id),
              child: Text('open $id'),
            ),
          const Expanded(child: _Counter('list')),
        ],
      ),
      detail: open == null
          ? null
          : _Counter('detail $open', key: ValueKey(open)),
      placeholder: const Text('nothing chosen'),
      onDetailClosed: () {
        widget.closes?.add(open!);
        setState(() => open = null);
      },
    );
  }
}

void main() {
  group('on a desktop', () {
    testWidgets('the list is a column at the start, a hairline, and the '
        'detail or the placeholder in the rest', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpUna(tester, const _Mail(), textDirection: direction);
        final ltr = direction == TextDirection.ltr;
        final list = tester.getRect(find.text('list 0'));
        expect(list.width, 360);
        expect(ltr ? list.left : list.right, ltr ? 0 : 1280);
        expect(find.text('nothing chosen'), findsOneWidget);
        final placeholder = tester.getTopLeft(find.text('nothing chosen'));
        if (ltr) expect(placeholder.dx, 361);

        await tester.tap(find.text('open 1'));
        await tester.pump();
        expect(find.text('nothing chosen'), findsNothing);
        final detail = tester.getRect(find.text('detail 1 0'));
        expect(detail.width, 1280 - 361);
        expect(ltr ? detail.left : detail.right, ltr ? 361 : 1280 - 361);
        expect(detail.height, 800);
        // No page was pushed: both are simply there.
        expect(find.byType(Navigator), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('each choice has its own detail; the list keeps its state', (
      tester,
    ) async {
      await pumpUna(tester, const _Mail());
      await tester.tap(find.text('list 0'));
      await tester.tap(find.text('open 1'));
      await tester.pump();
      await tester.tap(find.text('detail 1 0'));
      await tester.pump();
      expect(find.text('detail 1 1'), findsOneWidget);
      await tester.tap(find.text('open 2'));
      await tester.pump();
      expect(find.text('detail 2 0'), findsOneWidget);
      expect(find.text('list 1'), findsOneWidget);
    });

    testWidgets('resizable, the line between the two can be dragged', (
      tester,
    ) async {
      await pumpUna(tester, const _Mail(resizable: true));
      expect(tester.takeException(), isNull);
      final before = tester.getSize(find.text('list 0')).width;
      expect(before, moreOrLessEquals(360, epsilon: 8));
      await tester.dragFrom(Offset(before + 1, 400), const Offset(120, 0));
      await tester.pump();
      expect(tester.getSize(find.text('list 0')).width, greaterThan(before));
      // The divider waits a moment for a second tap.
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('on a phone', () {
    testWidgets('the list has the screen, and a detail is pushed over it '
        'as a page and popped when it goes', (tester) async {
      final closes = <int>[];
      await pumpUna(
        tester,
        _Mail(closes: closes),
        formFactor: FormFactor.mobile,
      );
      expect(tester.getSize(find.text('list 0')).width, 390);
      expect(find.text('nothing chosen'), findsNothing);

      await tester.tap(find.text('open 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      // Arriving from the end side, with the list still under it.
      final arriving = tester.getTopLeft(find.text('detail 1 0')).dx;
      expect(arriving, greaterThan(0));
      expect(find.text('list 0'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('detail 1 0')).left, 0);
      expect(tester.getSize(find.text('detail 1 0')).width, 390);
      expect(find.text('list 0'), findsNothing);
      expect(
        ModalRoute.of(tester.element(find.text('detail 1 0'))),
        isA<UnaPageRoute<void>>(),
      );

      // The system's back goes to this page, not to the app's.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(closes, [1]);
      expect(find.textContaining('detail'), findsNothing);
      expect(find.text('list 0'), findsOneWidget);
    });

    testWidgets('a swipe from the start edge goes back on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final closes = <int>[];
      await pumpUna(
        tester,
        _Mail(closes: closes),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.text('open 2'));
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(4, 400), const Offset(260, 0));
      await tester.pumpAndSettle();
      expect(closes, [2]);
      expect(find.text('list 0'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('the list keeps its state under the detail', (tester) async {
      await pumpUna(tester, const _Mail(), formFactor: FormFactor.mobile);
      await tester.tap(find.text('list 0'));
      await tester.pump();
      await tester.tap(find.text('open 1'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('list 1'), findsOneWidget);
    });

    testWidgets("with nothing open the system back is the app's", (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        UnaApp(
          navigatorKey: navigator,
          formFactor: FormFactor.mobile,
          home: const SizedBox(),
        ),
      );
      navigator.currentState!.push(
        UnaPageRoute<void>(builder: (context) => const _Mail()),
      );
      await tester.pumpAndSettle();
      expect(find.text('list 0'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('list 0'), findsNothing);
    });
  });

  testWidgets('both keep their state when the form factor changes', (
    tester,
  ) async {
    Widget app(FormFactor formFactor) => UnaApp(
      formFactor: formFactor,
      home: const _Mail(key: Key('mail')),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 700);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(FormFactor.desktop));
    await tester.tap(find.text('list 0'));
    await tester.tap(find.text('open 1'));
    await tester.pump();
    await tester.tap(find.text('detail 1 0'));
    await tester.pump();
    expect(find.text('detail 1 1'), findsOneWidget);

    await tester.pumpWidget(app(FormFactor.mobile));
    await tester.pumpAndSettle();
    // The detail is the page on top, as it was left.
    expect(find.text('detail 1 1'), findsOneWidget);
    expect(find.text('list 1', skipOffstage: false), findsOneWidget);

    await tester.pumpWidget(app(FormFactor.desktop));
    await tester.pumpAndSettle();
    expect(find.text('detail 1 1'), findsOneWidget);
    expect(find.text('list 1'), findsOneWidget);
  });
}
