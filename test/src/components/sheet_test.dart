import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../decoration_finders.dart';
import '../../una_harness.dart';

/// The page a sheet is opened from: a button, and the context to open with.
class _Opener extends StatelessWidget {
  const _Opener({required this.onOpen});

  final void Function(BuildContext context) onOpen;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Button(
        onPressed: () => onOpen(context),
        child: const Text('Open'),
      ),
    );
  }
}

const _phone = Size(390, 844);
const _desktop = Size(1280, 800);

/// The rectangle the sheet's surface is painted in.
Rect _surface(WidgetTester tester) {
  final decorated = find.descendant(
    of: find.byType(Sheet),
    matching: find.byType(DecoratedBox),
  );
  return tester.getRect(decorated.first);
}

Future<void> _open(
  WidgetTester tester, {
  required WidgetBuilder builder,
  FormFactor formFactor = FormFactor.mobile,
  SheetSide? side,
  bool dismissible = true,
  TextDirection textDirection = TextDirection.ltr,
  ThemeData? theme,
  void Function(Object? result)? onResult,
  bool settleAfter = true,
}) async {
  await pumpUna(
    tester,
    _Opener(
      onOpen: (context) async {
        final result = await showSheet<Object?>(
          context: context,
          side: side,
          dismissible: dismissible,
          builder: builder,
        );
        onResult?.call(result);
      },
    ),
    formFactor: formFactor,
    textDirection: textDirection,
    theme: theme,
  );
  await tester.tap(find.text('Open'));
  if (settleAfter) await tester.pumpAndSettle();
}

/// Thirty rows: more than any sheet shows at once.
Widget _rows(ScrollController controller) => ListView.builder(
  controller: controller,
  itemCount: 30,
  itemExtent: 48,
  itemBuilder: (context, i) => Text('Row $i'),
);

void main() {
  group('layout', () {
    testWidgets('a phone sheet spans the bottom and is as tall as its '
        'content', (tester) async {
      await _open(
        tester,
        builder: (context) => const Sheet(
          title: Text('Title'),
          child: SizedBox(height: 100),
        ),
      );
      final rect = _surface(tester);
      expect(rect.left, 0);
      expect(rect.right, _phone.width);
      expect(rect.bottom, _phone.height);
      expect(rect.height, greaterThan(100));
      expect(rect.height, lessThan(300));
    });

    testWidgets('a desktop sheet from the bottom is capped and centred', (
      tester,
    ) async {
      await _open(
        tester,
        formFactor: FormFactor.desktop,
        builder: (context) => const Sheet(child: SizedBox(height: 100)),
      );
      final rect = _surface(tester);
      expect(rect.width, 640);
      expect(rect.center.dx, _desktop.width / 2);
      expect(rect.bottom, _desktop.height);
    });

    testWidgets('a sheet from a side is full height and three quarters of a '
        'narrow page, 384 at most', (tester) async {
      await _open(
        tester,
        side: SheetSide.left,
        builder: (context) => const Sheet(child: Text('Side')),
      );
      var rect = _surface(tester);
      expect(rect.left, 0);
      expect(rect.top, 0);
      expect(rect.height, _phone.height);
      expect(rect.width, moreOrLessEquals(_phone.width * .75));

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(
        tester,
        formFactor: FormFactor.desktop,
        side: SheetSide.right,
        builder: (context) => const Sheet(child: Text('Side')),
      );
      rect = _surface(tester);
      expect(rect.right, _desktop.width);
      expect(rect.width, 384);
      expect(rect.height, _desktop.height);
    });

    for (final direction in TextDirection.values) {
      testWidgets('start and end follow the text direction ($direction)', (
        tester,
      ) async {
        final ltr = direction == TextDirection.ltr;
        await _open(
          tester,
          side: SheetSide.start,
          textDirection: direction,
          builder: (context) => const Sheet(child: Text('Side')),
        );
        var rect = _surface(tester);
        expect(ltr ? rect.left : rect.right, ltr ? 0 : _phone.width);

        await tester.pumpWidget(const SizedBox.shrink());
        await _open(
          tester,
          side: SheetSide.end,
          textDirection: direction,
          builder: (context) => const Sheet(child: Text('Side')),
        );
        rect = _surface(tester);
        expect(ltr ? rect.right : rect.left, ltr ? _phone.width : 0);
      });
    }

    test('SheetSide.resolve leaves the physical sides alone', () {
      for (final side in [
        SheetSide.top,
        SheetSide.bottom,
        SheetSide.left,
        SheetSide.right,
      ]) {
        expect(side.resolve(TextDirection.rtl), side);
      }
      expect(SheetSide.start.resolve(TextDirection.ltr), SheetSide.left);
      expect(SheetSide.start.resolve(TextDirection.rtl), SheetSide.right);
      expect(SheetSide.end.resolve(TextDirection.ltr), SheetSide.right);
      expect(SheetSide.end.resolve(TextDirection.rtl), SheetSide.left);
    });

    testWidgets('constraints set the width of a side sheet', (tester) async {
      await _open(
        tester,
        side: SheetSide.right,
        builder: (context) => const Sheet(
          style: SheetTheme(constraints: BoxConstraints.tightFor(width: 288)),
          child: Text('Side'),
        ),
      );
      expect(_surface(tester).width, 288);
    });

    testWidgets('each detent is measured against the room', (tester) async {
      Future<double> heightAt(SheetDetent detent) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await _open(
          tester,
          builder: (context) => Sheet(
            detents: [detent],
            child: const Text('Content'),
          ),
        );
        return _surface(tester).height;
      }

      expect(await heightAt(SheetDetent.medium), _phone.height / 2);
      expect(
        await heightAt(const SheetDetent.fraction(.25)),
        _phone.height / 4,
      );
      expect(await heightAt(const SheetDetent.height(320)), 320);
      expect(await heightAt(SheetDetent.full), _phone.height);
      // A strip of the page stays visible above a large sheet.
      final large = await heightAt(SheetDetent.large);
      expect(large, lessThan(_phone.height - 30));
      expect(large, greaterThan(_phone.height - 80));
      // Never more than there is.
      expect(await heightAt(const SheetDetent.height(5000)), _phone.height);
    });

    testWidgets('initialDetent picks where it opens', (tester) async {
      await _open(
        tester,
        builder: (context) => const Sheet(
          detents: [SheetDetent.medium, SheetDetent.full],
          initialDetent: SheetDetent.full,
          child: Text('Content'),
        ),
      );
      expect(_surface(tester).height, _phone.height);
    });

    testWidgets('content taller than the room scrolls, under a strip of the '
        'page', (tester) async {
      await _open(
        tester,
        builder: (context) => const Sheet(child: SizedBox(height: 3000)),
      );
      final rect = _surface(tester);
      expect(rect.top, greaterThan(30));
      expect(rect.bottom, _phone.height);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('unbounded constraints are reported with a hint', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const SingleChildScrollView(child: Sheet(child: Text('Lost'))),
      );
      final error = tester.takeException();
      expect(error, isFlutterError);
      expect('$error', contains('unbounded'));
    });

    testWidgets('the content keeps clear of the home indicator, and of the '
        'status bar at full height', (tester) async {
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
      await _open(
        tester,
        builder: (context) => const Sheet(
          style: SheetTheme(padding: EdgeInsets.zero),
          showCloseButton: false,
          showDragHandle: false,
          detents: [SheetDetent.medium, SheetDetent.full],
          scrollable: false,
          child: ColoredBox(
            key: ValueKey('content'),
            color: Color(0xff00ff00),
            child: SizedBox.expand(),
          ),
        ),
      );
      var content = tester.getRect(find.byKey(const ValueKey('content')));
      var surface = _surface(tester);
      expect(surface.bottom, _phone.height);
      expect(
        content.bottom,
        moreOrLessEquals(_phone.height - 34, epsilon: 1.5),
      );
      // At half height the status bar is far away.
      expect(content.top, moreOrLessEquals(surface.top, epsilon: 1.5));

      final sheet = tester.widget<Sheet>(find.byType(Sheet));
      expect(sheet.detents, hasLength(2));
      await tester.fling(
        find.byKey(const ValueKey('content')),
        const Offset(0, -300),
        2000,
      );
      await tester.pumpAndSettle();
      surface = _surface(tester);
      content = tester.getRect(find.byKey(const ValueKey('content')));
      expect(surface.top, 0);
      expect(content.top, moreOrLessEquals(47, epsilon: 1.5));
    });
  });

  group('haptics', () {
    late List<String> calls;

    setUp(() {
      calls = [];
      Haptics.debugEnabledInTests = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              calls.add('${call.arguments}');
            }
            return null;
          });
    });

    tearDown(() {
      Haptics.debugEnabledInTests = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    Widget sheet(BuildContext context) => const Sheet(
      style: SheetTheme(padding: EdgeInsets.zero),
      showCloseButton: false,
      detents: [SheetDetent.medium, SheetDetent.full],
      scrollable: false,
      // Opaque, so the sheet's own recognizer hears the drag.
      child: ColoredBox(
        key: ValueKey('content'),
        color: Color(0xff00ff00),
        child: SizedBox.expand(),
      ),
    );

    testWidgets('a finger that moves a sheet to another detent ticks once '
        'through Haptics', (tester) async {
      await _open(tester, builder: sheet);
      final top = _surface(tester).top;
      await tester.timedDrag(
        find.byKey(const ValueKey('content')),
        const Offset(0, -300),
        const Duration(milliseconds: 400),
      );
      await tester.pumpAndSettle();
      expect(_surface(tester).top, lessThan(top));
      // A browser has no haptics to give.
      expect(calls, kIsWeb ? isEmpty : ['HapticFeedbackType.selectionClick']);
    });

    testWidgets('ThemeData(haptics: false) keeps the detent silent', (
      tester,
    ) async {
      await _open(
        tester,
        builder: sheet,
        theme: ThemeData(haptics: false),
      );
      await tester.timedDrag(
        find.byKey(const ValueKey('content')),
        const Offset(0, -300),
        const Duration(milliseconds: 400),
      );
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });
  });

  group('modal', () {
    testWidgets('pops with a value', (tester) async {
      Object? result = 'unset';
      await _open(
        tester,
        onResult: (value) => result = value,
        builder: (context) => Sheet(
          child: Button(
            onPressed: () => Navigator.of(context).pop('picked'),
            child: const Text('Pick'),
          ),
        ),
      );
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(result, 'picked');
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('a tap on the barrier and Escape close a dismissible sheet', (
      tester,
    ) async {
      await _open(
        tester,
        builder: (context) => const Sheet(child: Text('Content')),
      );
      await tester.tapAt(const Offset(200, 100));
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('dismissible: false keeps it through a barrier tap and a '
        'drag', (tester) async {
      await _open(
        tester,
        dismissible: false,
        builder: (context) => const Sheet(
          title: Text('Stay'),
          child: SizedBox(height: 200),
        ),
      );
      await tester.tapAt(const Offset(200, 100));
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);

      // It gives a little under the finger and comes back.
      final resting = tester.getTopLeft(find.text('Stay')).dy;
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Stay')),
      );
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      final pulled = tester.getTopLeft(find.text('Stay')).dy;
      expect(pulled, greaterThan(resting + 5));
      expect(pulled, lessThan(resting + 120));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(tester.getTopLeft(find.text('Stay')).dy, resting);
    });

    testWidgets('has no close button unless the widget or the theme asks '
        'for one', (tester) async {
      await _open(
        tester,
        builder: (context) => const Sheet(title: Text('Title')),
      );
      expect(find.bySemanticsLabel('Close'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(
        tester,
        builder: (context) =>
            const Sheet(title: Text('Title'), showCloseButton: true),
      );
      final close = find.bySemanticsLabel('Close');
      expect(close, findsOneWidget);
      // In the top end corner.
      expect(tester.getCenter(close).dx, greaterThan(_phone.width - 60));
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(
        tester,
        theme: ThemeData(sheetTheme: const SheetTheme(showCloseButton: true)),
        builder: (context) => const Sheet(title: Text('Title')),
      );
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
    });

    testWidgets('the close button is on the left in a right-to-left app', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _phone;
      addTearDown(tester.view.reset);
      late BuildContext opener;
      await tester.pumpWidget(
        UnaApp(
          formFactor: FormFactor.mobile,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              opener = context;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      unawaited(
        showSheet<void>(
          context: opener,
          builder: (context) =>
              const Sheet(title: Text('Title'), showCloseButton: true),
        ),
      );
      await tester.pumpAndSettle();
      final close = find.bySemanticsLabel('Close');
      expect(tester.getCenter(close).dx, lessThan(60));
      // And the title starts at the right.
      expect(
        tester.getTopRight(find.text('Title')).dx,
        greaterThan(_phone.width - 60),
      );
    });

    testWidgets('names its route with the title, or the label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(
        tester,
        builder: (context) => const Sheet(title: Text('Share')),
      );
      expect(
        tester.getSemantics(find.text('Share')),
        isSemantics(namesRoute: true, isHeader: true, label: 'Share'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(
        tester,
        builder: (context) => const Sheet(
          title: Text('Share'),
          semanticLabel: 'Share this post',
        ),
      );
      expect(find.bySemanticsLabel('Share this post'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Share')),
        isSemantics(isHeader: true, label: 'Share'),
      );
      handle.dispose();
    });

    testWidgets('holds the focus and gives it back', (tester) async {
      await _open(
        tester,
        builder: (context) => Sheet(
          child: Button(onPressed: () {}, child: const Text('Inside')),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.descendant(
          of: find.byType(Sheet),
          matching: find.byWidget(focused.widget),
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('actions stack full width on a phone, first at the bottom, '
        'and sit in a row at the end on a desktop', (tester) async {
      Widget sheet(BuildContext context) => Sheet(
        title: const Text('Title'),
        actions: [
          Button.outline(onPressed: () {}, child: const Text('Cancel')),
          Button(onPressed: () {}, child: const Text('Save')),
        ],
      );
      await _open(tester, builder: sheet);
      var cancel = tester.getRect(find.widgetWithText(Button, 'Cancel'));
      var save = tester.getRect(find.widgetWithText(Button, 'Save'));
      expect(cancel.width, save.width);
      expect(cancel.width, greaterThan(300));
      expect(cancel.top, greaterThan(save.bottom));

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(tester, formFactor: FormFactor.desktop, builder: sheet);
      cancel = tester.getRect(find.widgetWithText(Button, 'Cancel'));
      save = tester.getRect(find.widgetWithText(Button, 'Save'));
      expect(cancel.top, save.top);
      expect(cancel.right, lessThan(save.left));
      expect(save.right, greaterThan(_surface(tester).right - 40));
    });

    testWidgets('a side sheet pins its actions to the bottom', (tester) async {
      await _open(
        tester,
        formFactor: FormFactor.desktop,
        side: SheetSide.end,
        builder: (context) => Sheet(
          title: const Text('Title'),
          actions: [Button(onPressed: () {}, child: const Text('Save'))],
          child: const Text('Short'),
        ),
      );
      final save = tester.getRect(find.widgetWithText(Button, 'Save'));
      expect(save.bottom, greaterThan(_desktop.height - 40));
    });

    testWidgets('nothing overflows at twice the text size', (tester) async {
      await pumpUna(
        tester,
        MediaQuery.withClampedTextScaling(
          minScaleFactor: 2,
          maxScaleFactor: 2,
          child: Builder(
            builder: (context) => _Opener(
              onOpen: (context) => showSheet<void>(
                context: context,
                builder: (context) => MediaQuery.withClampedTextScaling(
                  minScaleFactor: 2,
                  maxScaleFactor: 2,
                  child: Sheet(
                    title: const Text('A longer title than usual'),
                    description: const Text(
                      'A description that takes more than one line of the '
                      'sheet at this size.',
                    ),
                    actions: [
                      Button.outline(
                        onPressed: () {},
                        child: const Text('Cancel'),
                      ),
                      Button(
                        onPressed: () {},
                        child: const Text('Save changes'),
                      ),
                    ],
                    child: const TextField(placeholder: Text('Name')),
                  ),
                ),
              ),
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  group('motion', () {
    testWidgets('slides in from its edge without overshooting, and out '
        'again', (tester) async {
      await _open(
        tester,
        settleAfter: false,
        builder: (context) => const Sheet(
          title: Text('Title'),
          child: SizedBox(height: 200),
        ),
      );
      final title = find.text('Title');
      await tester.pump();
      final tops = <double>[];
      for (var i = 0; i < 40; i++) {
        tops.add(tester.getTopLeft(title).dy);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      final resting = tester.getTopLeft(title).dy;
      // It starts below the screen's edge region and only ever moves up.
      expect(tops.first, greaterThan(resting + 100));
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i], lessThanOrEqualTo(tops[i - 1] + .01));
        expect(tops[i], greaterThanOrEqualTo(resting - .01));
      }

      await tester.tapAt(const Offset(200, 50));
      await tester.pump();
      final leaving = <double>[];
      for (var i = 0; i < 30 && title.evaluate().isNotEmpty; i++) {
        leaving.add(tester.getTopLeft(title).dy);
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(leaving.length, greaterThan(3));
      for (var i = 1; i < leaving.length; i++) {
        expect(leaving[i], greaterThanOrEqualTo(leaving[i - 1] - .01));
      }
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('sliding in, out and under a finger builds nothing', (
      tester,
    ) async {
      var builds = 0;
      var frames = 0;
      await _open(
        tester,
        settleAfter: false,
        builder: (context) => Sheet(
          title: const Text('Title'),
          child: Builder(
            builder: (context) {
              builds++;
              return const SizedBox(height: 200);
            },
          ),
        ),
      );
      await tester.pump();
      final element = tester.element(find.byType(Sheet));
      // Anything under the sheet that is rebuilt would mark its element.
      void countDirty(Element e) {
        if (e.dirty) frames++;
        e.visitChildren(countDirty);
      }

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        countDirty(element);
      }
      await tester.pumpAndSettle();
      expect(builds, 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
      );
      await gesture.moveBy(const Offset(0, 30));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, 8));
        countDirty(element);
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(builds, 1);
      expect(frames, 0);
    });

    testWidgets('with reduced motion it fades in place', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await _open(
        tester,
        settleAfter: false,
        builder: (context) => const Sheet(
          title: Text('Title'),
          child: SizedBox(height: 200),
        ),
      );
      await tester.pump();
      final first = tester.getTopLeft(find.text('Title')).dy;
      await tester.pump(const Duration(milliseconds: 30));
      final fade = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(Sheet),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Title')).dy, first);
      expect(fade.opacity.value, 1);
    });

    testWidgets('with no motion it is there at once', (tester) async {
      await _open(
        tester,
        theme: ThemeData(motion: Motion.none),
        settleAfter: false,
        builder: (context) => const Sheet(
          title: Text('Title'),
          child: SizedBox(height: 200),
        ),
      );
      await tester.pump();
      final first = _surface(tester);
      expect(first.bottom, _phone.height);
      await tester.pumpAndSettle();
      expect(_surface(tester), first);
    });
  });

  group('dragging', () {
    Widget sheet(BuildContext context) => const Sheet(
      title: Text('Title'),
      child: SizedBox(height: 300),
    );

    testWidgets('follows the finger, lightens the barrier, and comes back '
        'from a short pull', (tester) async {
      await _open(tester, builder: sheet);
      final route = ModalRoute.of(tester.element(find.byType(Sheet)))!;
      final resting = tester.getTopLeft(find.text('Title')).dy;
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
      );
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      expect(tester.getTopLeft(find.text('Title')).dy, resting + 60);
      expect(route.animation!.value, lessThan(1));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(tester.getTopLeft(find.text('Title')).dy, resting);
      expect(route.animation!.value, 1);
    });

    testWidgets('a pull past half way closes it', (tester) async {
      await _open(tester, builder: sheet);
      final height = _surface(tester).height;
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
      );
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(Offset(0, height * .6));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('a fling closes it from anywhere', (tester) async {
      await _open(tester, builder: sheet);
      await tester.fling(find.text('Title'), const Offset(0, 80), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('a PopScope that refuses sends it back up', (tester) async {
      await _open(
        tester,
        builder: (context) => const PopScope(
          canPop: false,
          child: Sheet(title: Text('Title'), child: SizedBox(height: 300)),
        ),
      );
      final resting = tester.getTopLeft(find.text('Title')).dy;
      await tester.fling(find.text('Title'), const Offset(0, 120), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(tester.getTopLeft(find.text('Title')).dy, resting);
    });

    testWidgets('a mouse drags it by the handle only, unless draggable is '
        'true', (tester) async {
      await _open(tester, builder: sheet);
      final resting = tester.getTopLeft(find.text('Title')).dy;
      var gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      expect(tester.getTopLeft(find.text('Title')).dy, resting);
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(
        tester,
        builder: (context) => const Sheet(
          draggable: true,
          title: Text('Title'),
          child: SizedBox(height: 300),
        ),
      );
      gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      expect(tester.getTopLeft(find.text('Title')).dy, resting + 60);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('draggable: false holds it still and hides the handle', (
      tester,
    ) async {
      await _open(
        tester,
        builder: (context) => const Sheet(
          draggable: false,
          title: Text('Title'),
          child: SizedBox(height: 300),
        ),
      );
      expect(find.bySemanticsLabel('Resize'), findsNothing);
      final resting = tester.getTopLeft(find.text('Title')).dy;
      await tester.fling(find.text('Title'), const Offset(0, 200), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(tester.getTopLeft(find.text('Title')).dy, resting);
    });

    testWidgets('a side sheet is swiped back to its edge', (tester) async {
      await _open(
        tester,
        side: SheetSide.left,
        builder: (context) => const Sheet(title: Text('Title')),
      );
      await tester.fling(find.text('Title'), const Offset(-80, 0), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });
  });

  group('detents', () {
    const detents = [SheetDetent.medium, SheetDetent.large];

    testWidgets('a drag moves it to the nearest detent and reports it', (
      tester,
    ) async {
      final changes = <SheetDetent>[];
      await _open(
        tester,
        builder: (context) => Sheet(
          detents: detents,
          onDetentChanged: changes.add,
          title: const Text('Title'),
          child: const Text('Content'),
        ),
      );
      expect(_surface(tester).height, _phone.height / 2);

      // Most of the way up: it goes on to large.
      var gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
      );
      await gesture.moveBy(const Offset(0, -30));
      await gesture.moveBy(const Offset(0, -300));
      await tester.pump();
      expect(_surface(tester).height, _phone.height / 2 + 300);
      await gesture.up();
      await tester.pumpAndSettle();
      final large = _surface(tester).height;
      expect(large, greaterThan(_phone.height - 80));
      expect(changes, [SheetDetent.large]);

      // A little way down: it comes back.
      gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
      );
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_surface(tester).height, large);
      expect(changes, [SheetDetent.large]);

      // A fling down: one detent, not out.
      await tester.fling(find.text('Title'), const Offset(0, 60), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(_surface(tester).height, _phone.height / 2);
      expect(changes, [SheetDetent.large, SheetDetent.medium]);
    });

    testWidgets('settles without overshooting and pumpAndSettle returns', (
      tester,
    ) async {
      final controller = SheetController();
      addTearDown(controller.dispose);
      await _open(
        tester,
        builder: (context) => Sheet(
          controller: controller,
          detents: detents,
          child: const Text('Content'),
        ),
      );
      controller.animateTo(SheetDetent.large);
      await tester.pump();
      final heights = <double>[];
      for (var i = 0; i < 40; i++) {
        heights.add(_surface(tester).height);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      final large = _surface(tester).height;
      for (var i = 1; i < heights.length; i++) {
        expect(heights[i], greaterThanOrEqualTo(heights[i - 1] - .01));
        expect(heights[i], lessThanOrEqualTo(large + .5));
      }
      expect(heights.first, lessThan(large));
    });

    testWidgets('SheetController moves, jumps, reports and closes', (
      tester,
    ) async {
      final controller = SheetController();
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);
      await _open(
        tester,
        builder: (context) => Sheet(
          controller: controller,
          detents: detents,
          child: const Text('Content'),
        ),
      );
      expect(controller.isAttached, isTrue);
      expect(controller.detent, SheetDetent.medium);

      controller.animateTo(SheetDetent.large);
      expect(controller.detent, SheetDetent.large);
      expect(notified, 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // Under way, not there yet.
      expect(
        _surface(tester).height,
        inExclusiveRange(_phone.height / 2, _phone.height - 60),
      );
      await tester.pumpAndSettle();
      expect(_surface(tester).height, greaterThan(_phone.height - 80));

      controller.jumpTo(SheetDetent.medium);
      await tester.pump();
      expect(_surface(tester).height, _phone.height / 2);
      expect(notified, 2);

      controller.close();
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
      expect(controller.isAttached, isFalse);
    });

    testWidgets('the handle resizes with the arrow keys, a tap and a screen '
        'reader', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(
        tester,
        builder: (context) => const Sheet(
          detents: detents,
          child: Text('Content'),
        ),
      );
      final grabber = find.bySemanticsLabel('Resize');
      expect(grabber, findsOneWidget);
      expect(
        tester.getSemantics(grabber),
        isSemantics(
          isButton: true,
          hasTapAction: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
          label: 'Resize',
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      // Tab reaches the handle, then the close button.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, greaterThan(_phone.height - 80));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, _phone.height / 2);
      // Down again does not close it: Escape does that.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);

      await tester.tap(grabber);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, greaterThan(_phone.height - 80));
      await tester.tap(grabber);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, _phone.height / 2);

      tester.semantics.increase(find.semantics.byLabel('Resize'));
      await tester.pumpAndSettle();
      expect(_surface(tester).height, greaterThan(_phone.height - 80));
      tester.semantics.decrease(find.semantics.byLabel('Resize'));
      await tester.pumpAndSettle();
      expect(_surface(tester).height, _phone.height / 2);
      handle.dispose();
    });

    testWidgets('a mouse drags the handle', (tester) async {
      await _open(
        tester,
        formFactor: FormFactor.desktop,
        builder: (context) => const Sheet(
          detents: detents,
          child: Text('Content'),
        ),
      );
      final grabber = find.bySemanticsLabel('Resize');
      final gesture = await tester.startGesture(
        tester.getCenter(grabber),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, -30));
      await gesture.moveBy(const Offset(0, -200));
      await tester.pump();
      expect(_surface(tester).height, _desktop.height / 2 + 200);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_surface(tester).height, greaterThan(_desktop.height - 80));
    });

    testWidgets('a content detent beside others is measured while the sheet '
        'is elsewhere', (tester) async {
      final controller = SheetController();
      addTearDown(controller.dispose);
      await _open(
        tester,
        builder: (context) => Sheet(
          controller: controller,
          detents: const [SheetDetent.content, SheetDetent.large],
          initialDetent: SheetDetent.large,
          showDragHandle: false,
          showCloseButton: false,
          style: const SheetTheme(padding: EdgeInsets.zero),
          child: const SizedBox(height: 200),
        ),
      );
      expect(_surface(tester).height, greaterThan(_phone.height - 80));
      controller.animateTo(SheetDetent.content);
      await tester.pumpAndSettle();
      // The content and the sheet's hairline.
      expect(_surface(tester).height, moreOrLessEquals(202, epsilon: .5));
    });

    testWidgets('a change of detents keeps the sheet where it was if it '
        'can', (tester) async {
      var list = const [SheetDetent.medium, SheetDetent.large];
      late StateSetter rebuild;
      await _open(
        tester,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Sheet(
              detents: list,
              initialDetent: SheetDetent.large,
              child: const Text('Content'),
            );
          },
        ),
      );
      final large = _surface(tester).height;
      rebuild(() => list = const [SheetDetent.large, SheetDetent.full]);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, large);
      rebuild(() => list = const [SheetDetent.medium]);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, _phone.height / 2);
    });
  });

  group('a list that drives the sheet', () {
    Widget sheet(BuildContext context) => Sheet(
      detents: const [SheetDetent.medium, SheetDetent.large],
      title: const Text('Rows'),
      builder: (context, controller) => _rows(controller),
    );

    double offset(WidgetTester tester) =>
        tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;

    testWidgets('a pull up grows the sheet before the list scrolls', (
      tester,
    ) async {
      await _open(tester, builder: sheet);
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Row 2')),
      );
      await gesture.moveBy(const Offset(0, -30));
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump();
      expect(_surface(tester).height, greaterThan(_phone.height / 2 + 90));
      expect(offset(tester), 0);

      // On up to the largest detent, and then the list takes over.
      await gesture.moveBy(const Offset(0, -400));
      await tester.pump();
      final large = _surface(tester).height;
      expect(large, greaterThan(_phone.height - 80));
      expect(offset(tester), greaterThan(50));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_surface(tester).height, large);
    });

    testWidgets('a pull down scrolls the list back first, then lowers the '
        'sheet, then closes it', (tester) async {
      await _open(
        tester,
        builder: (context) => Sheet(
          detents: const [SheetDetent.medium, SheetDetent.large],
          initialDetent: SheetDetent.large,
          title: const Text('Rows'),
          builder: (context, controller) => _rows(controller),
        ),
      );
      final large = _surface(tester).height;
      await tester.drag(find.text('Row 4'), const Offset(0, -150));
      await tester.pumpAndSettle();
      final scrolled = offset(tester);
      expect(scrolled, greaterThan(100));
      expect(_surface(tester).height, large);

      // Scrolled: the list moves, the sheet does not.
      final gesture = await tester.startGesture(const Offset(200, 500));
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
      expect(offset(tester), lessThan(scrolled));
      expect(_surface(tester).height, large);
      // At the top of the list the rest of the pull lowers the sheet.
      await gesture.moveBy(const Offset(0, 400));
      await tester.pump();
      expect(offset(tester), 0);
      expect(_surface(tester).height, lessThan(large - 100));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(_surface(tester).height, _phone.height / 2);

      // From the smallest detent a fling takes it away.
      await tester.fling(find.text('Row 1'), const Offset(0, 120), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });

    Future<SheetController> scrolledAtLarge(WidgetTester tester) async {
      final controller = SheetController();
      addTearDown(controller.dispose);
      await _open(
        tester,
        builder: (context) => Sheet(
          controller: controller,
          detents: const [SheetDetent.medium, SheetDetent.large],
          initialDetent: SheetDetent.large,
          builder: (context, scroll) => _rows(scroll),
        ),
      );
      // At its largest detent a pull up only scrolls the list: the sheet
      // is offered the drag and takes none of it.
      await tester.drag(find.text('Row 3'), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(offset(tester), greaterThan(100));
      return controller;
    }

    testWidgets('after a drag that only scrolled the list, the sheet '
        'settles on a detent it is sent to', (tester) async {
      final controller = await scrolledAtLarge(tester);
      final scrolled = offset(tester);
      controller.animateTo(SheetDetent.medium);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, _phone.height / 2);

      // A short pull down on a list scrolled into the middle scrolls it
      // back; the sheet stays where it is.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump();
      }
      expect(offset(tester), lessThan(scrolled));
      expect(_surface(tester).height, _phone.height / 2);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_surface(tester).height, _phone.height / 2);
    });

    testWidgets('after a drag that only scrolled the list, a detent the '
        'controller chose follows a resize', (tester) async {
      final controller = await scrolledAtLarge(tester);
      controller.animateTo(SheetDetent.medium);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, _phone.height / 2);

      tester.view.physicalSize = const Size(390, 700);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, 350);
    });

    testWidgets('a wheel scrolls the list and leaves the sheet alone', (
      tester,
    ) async {
      await _open(tester, builder: sheet);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      final where = tester.getCenter(find.text('Row 2'));
      await tester.sendEventToBinding(pointer.hover(where));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 120)));
      await tester.pumpAndSettle();
      expect(offset(tester), greaterThan(0));
      expect(_surface(tester).height, _phone.height / 2);
    });

    testWidgets('long content in a plain sheet is pulled down from its top '
        'to close', (tester) async {
      await _open(
        tester,
        builder: (context) => Sheet(
          child: Column(
            children: [for (var i = 0; i < 40; i++) Text('Line $i')],
          ),
        ),
      );
      expect(find.byType(Sheet), findsOneWidget);
      await tester.fling(find.text('Line 3'), const Offset(0, 150), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('a list that ends the sheet runs under the home indicator', (
      tester,
    ) async {
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      await _open(tester, builder: sheet);
      final list = tester.getRect(find.byType(ListView));
      // Down to the sheet's bottom padding, not stopped above the inset.
      expect(list.bottom, greaterThan(_phone.height - 34));
      // And it pads its last row clear of it.
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pump();
      expect(
        tester.getRect(find.text('Row 29')).bottom,
        lessThanOrEqualTo(_phone.height - 34),
      );
    });
  });

  group('inline', () {
    Widget host(Widget sheet) => Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Button(onPressed: () {}, child: const Text('Behind')),
          ),
        ),
        Positioned(left: 0, right: 0, bottom: 0, top: 0, child: sheet),
      ],
    );

    testWidgets('sits in the tree with no route and no barrier', (
      tester,
    ) async {
      var pressed = 0;
      await pumpUna(
        tester,
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Button(
                onPressed: () => pressed++,
                child: const Text('Behind'),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Sheet(
                title: Text('Now playing'),
                child: SizedBox(height: 80),
              ),
            ),
          ],
        ),
        formFactor: FormFactor.mobile,
      );
      // The page's own route is the only one.
      expect(
        Navigator.of(tester.element(find.byType(Sheet))).canPop(),
        isFalse,
      );
      final rect = _surface(tester);
      expect(rect.bottom, _phone.height);
      expect(rect.width, _phone.width);
      expect(rect.height, lessThan(250));
      // No route to close, so no close button.
      expect(find.bySemanticsLabel('Close'), findsNothing);
      // The page behind is still in use.
      await tester.tap(find.text('Behind'));
      expect(pressed, 1);
    });

    testWidgets('measures its detents against its parent and cannot be '
        'dragged away', (tester) async {
      await pumpUna(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 600,
            child: host(
              const Align(
                alignment: Alignment.bottomCenter,
                child: Sheet(
                  detents: [SheetDetent.height(120), SheetDetent.medium],
                  title: Text('Peek'),
                  child: Text('Content'),
                ),
              ),
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      expect(_surface(tester).height, 120);
      await tester.fling(find.text('Peek'), const Offset(0, -100), 1500);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, 300);

      // Down to the smallest detent and no further.
      await tester.fling(find.text('Peek'), const Offset(0, 100), 1500);
      await tester.pumpAndSettle();
      expect(_surface(tester).height, 120);
      await tester.fling(find.text('Peek'), const Offset(0, 100), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(_surface(tester).height, 120);
      expect(_surface(tester).bottom, _phone.height);
    });

    testWidgets('a close button asked for calls onDismissed', (
      tester,
    ) async {
      var closed = 0;
      final controller = SheetController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: Sheet(
            controller: controller,
            onDismissed: () => closed++,
            showCloseButton: true,
            title: const Text('Title'),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.bySemanticsLabel('Close'));
      expect(closed, 1);
      controller.close();
      expect(closed, 2);
    });

    testWidgets('a sheet inside a modal sheet is an inline one', (
      tester,
    ) async {
      await _open(
        tester,
        builder: (context) => const Sheet(
          detents: [SheetDetent.full],
          scrollable: false,
          showCloseButton: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Sheet(key: ValueKey('inner'), title: Text('Inner')),
          ),
        ),
      );
      // The inner one has no route of its own to close.
      expect(find.bySemanticsLabel('Close'), findsNothing);
      await tester.fling(find.text('Inner'), const Offset(0, 100), 1500);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('inner')), findsOneWidget);
    });
  });

  group('theme', () {
    testWidgets('the variant gives every style a sheet surface', (
      tester,
    ) async {
      for (final style in [
        StyleTokens.fluid,
        StyleTokens.crisp,
        StyleTokens.pebble,
        StyleTokens.sharp,
      ]) {
        for (final brightness in Brightness.values) {
          final theme = ThemeData(brightness: brightness, style: style);
          final sheet = theme.sheetTheme;
          expect(sheet.backgroundColor, theme.colorScheme.background);
          expect(sheet.showCloseButton, isNull);
          expect(sheet.padding, isNotNull);
          expect(sheet.titleStyle, isNotNull);
          expect(sheet.borderRadius, isNotNull);
        }
      }
    });

    testWidgets('a phone sheet rounds the corners of its open edge', (
      tester,
    ) async {
      await _open(
        tester,
        builder: (context) => const Sheet(child: SizedBox(height: 100)),
      );
      final theme = Theme.of(tester.element(find.byType(Sheet)));
      final clip = tester.widget<ClipRRect>(
        find
            .descendant(
              of: find.byType(Sheet),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      final radius = clip.borderRadius as BorderRadius;
      expect(radius.topLeft, theme.sheetTheme.borderRadius!.topLeft);
      expect(radius.topLeft.x, greaterThan(0));
      expect(radius.bottomLeft, Radius.zero);
      expect(radius.bottomRight, Radius.zero);
    });

    testWidgets('SheetTheme and the widget override the look', (tester) async {
      await _open(
        tester,
        theme: ThemeData(
          sheetTheme: const SheetTheme(
            backgroundColor: Color(0xff112233),
            showDragHandle: false,
            side: SheetSide.top,
          ),
        ),
        builder: (context) => const Sheet(child: SizedBox(height: 100)),
      );
      expect(_surface(tester).top, 0);
      expect(find.bySemanticsLabel('Resize'), findsNothing);
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(Sheet),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        boxDecorationOf(box.decoration)!.color,
        const Color(0xff112233),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(
        tester,
        builder: (context) => const Sheet(
          style: SheetTheme(borderRadius: BorderRadius.all(Radius.circular(3))),
          child: SizedBox(height: 100),
        ),
      );
      final clip = tester.widget<ClipRRect>(
        find
            .descendant(
              of: find.byType(Sheet),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      expect(clip.borderRadius, const BorderRadius.all(Radius.circular(3)));
    });

    testWidgets('builds in every layout', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => Align(
          alignment: Alignment.bottomCenter,
          child: Sheet(
            title: const Text('Title'),
            description: const Text('Description'),
            actions: [Button(onPressed: () {}, child: const Text('Done'))],
            child: const Text('Content'),
          ),
        ),
      );
    });

    testWidgets('the handle shows on a phone, and on a desktop only with '
        'several detents', (tester) async {
      await _open(
        tester,
        builder: (context) => const Sheet(child: Text('Content')),
      );
      // One detent: something to drag, nothing to resize.
      expect(find.bySemanticsLabel('Resize'), findsNothing);
      expect(
        tester.getSize(find.byType(Sheet)).height,
        greaterThan(0),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(
        tester,
        formFactor: FormFactor.desktop,
        builder: (context) => const Sheet(
          detents: [SheetDetent.medium, SheetDetent.large],
          child: Text('Content'),
        ),
      );
      expect(find.bySemanticsLabel('Resize'), findsOneWidget);
    });
  });

  test('SheetDetent compares by value', () {
    // Through a variable: written out, the analyzer asks for the constant.
    SheetDetent fraction(double value) => SheetDetent.fraction(value);
    expect(fraction(.5), SheetDetent.medium);
    expect(fraction(1), SheetDetent.full);
    expect(fraction(.5).hashCode, SheetDetent.medium.hashCode);
    expect(const SheetDetent.height(100), const SheetDetent.height(100));
    expect(
      const SheetDetent.height(100),
      isNot(const SheetDetent.height(101)),
    );
    expect(SheetDetent.content, isNot(SheetDetent.large));
    expect('${SheetDetent.large}', 'SheetDetent.large');
  });
}
