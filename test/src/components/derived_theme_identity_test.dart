import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// `ThemeData.copyWith` runs the theme factory again: every component theme
/// is derived anew. A widget that re-themes its subtree therefore derives
/// that theme once per ambient theme, never once per build — and a `Theme`
/// handed the identical data does not make its dependents compare fifty
/// component themes to find out nothing changed.
void main() {
  /// The data of the nearest [Theme] above [finder].
  ThemeData themeAbove(WidgetTester tester, Finder finder) => tester
      .widget<Theme>(
        find.ancestor(of: finder, matching: find.byType(Theme)).first,
      )
      .data;

  testWidgets('a narrow dialog derives the theme of its full-width actions '
      'once, not on every build', (tester) async {
    late StateSetter rebuild;
    var builds = 0;
    await pumpFinesse(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          builds++;
          return Center(
            // A new widget each time, so the dialog itself is built again.
            child: Dialog(
              title: Text('Build $builds'),
              actions: [
                Button.outline(onPressed: () {}, child: const Text('Cancel')),
                Button(onPressed: () {}, child: const Text('Save')),
              ],
            ),
          );
        },
      ),
      formFactor: FormFactor.mobile,
    );
    final ambient = Theme.of(tester.element(find.byType(Dialog)));
    final first = themeAbove(tester, find.text('Save'));
    // It is the re-themed subtree: below the `sm` breakpoint the actions
    // are stacked and each is as wide as the dialog's content.
    expect(first, isNot(same(ambient)));
    expect(first.primaryButtonTheme.expands, isTrue);
    expect(
      tester.getSize(find.byType(Button).first).width,
      tester.getSize(find.byType(Button).last).width,
    );
    expect(
      tester.getSize(find.byType(Button).first).width,
      greaterThan(250),
    );

    for (var i = 0; i < 3; i++) {
      rebuild(() {});
      await tester.pump();
      expect(find.text('Build $builds'), findsOneWidget);
      expect(
        themeAbove(tester, find.text('Save')),
        same(first),
        reason: 'the theme factory ran again on rebuild $i',
      );
    }
    expect(builds, 4);

    // A different ambient theme is a different derived one.
    await pumpFinesse(
      tester,
      Center(
        child: Dialog(
          title: const Text('Title'),
          actions: [Button(onPressed: () {}, child: const Text('Save'))],
        ),
      ),
      formFactor: FormFactor.mobile,
      theme: ThemeData(radius: const BorderRadius.all(Radius.circular(2))),
    );
    final other = themeAbove(tester, find.text('Save'));
    expect(other, isNot(same(first)));
    expect(other.radius, const BorderRadius.all(Radius.circular(2)));
    expect(other.primaryButtonTheme.expands, isTrue);
  });

  testWidgets('a wide dialog does not re-theme its actions at all', (
    tester,
  ) async {
    await pumpFinesse(
      tester,
      Center(
        child: Dialog(
          title: const Text('Title'),
          actions: [Button(onPressed: () {}, child: const Text('Save'))],
        ),
      ),
    );
    expect(
      themeAbove(tester, find.text('Save')),
      same(Theme.of(tester.element(find.byType(Dialog)))),
    );
  });

  testWidgets("a tooltip derives its content's theme once per ambient theme, "
      'whichever tooltip shows and however often it builds', (tester) async {
    late StateSetter rebuild;
    await pumpFinesse(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return Center(
            child: FinesseRow(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  builder: (context) => const Text('first tip'),
                  child: const Text('first'),
                ),
                Tooltip(
                  builder: (context) => const Text('second tip'),
                  child: const Text('second'),
                ),
              ],
            ),
          );
        },
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(1, 1));
    addTearDown(gesture.removePointer);

    Future<ThemeData> show(String trigger) async {
      await gesture.moveTo(tester.getCenter(find.text(trigger)));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      return themeAbove(tester, find.text('$trigger tip'));
    }

    final first = await show('first');
    // The inverted key caps are what the content theme is for.
    expect(
      first.kbdTheme.foregroundColor,
      first.colorScheme.background,
    );
    rebuild(() {});
    await tester.pump();
    expect(
      themeAbove(tester, find.text('first tip')),
      same(first),
      reason: 'the theme factory ran again when the tooltip rebuilt',
    );
    expect(
      await show('second'),
      same(first),
      reason: 'a second tooltip derived the same theme again',
    );
  });

  testWidgets('an app with no theme of its own keeps one default theme '
      'across builds', (tester) async {
    Widget app(String label) => FinesseApp(
      formFactor: FormFactor.desktop,
      home: Text(label, textDirection: TextDirection.ltr),
    );
    // What the app hands its `CrossFadeTheme`: the `Theme` below it does
    // not notify for an equal theme, so what a dependant reads says nothing
    // about what each build cost.
    ThemeData handed() =>
        tester.widget<CrossFadeTheme>(find.byType(CrossFadeTheme)).data;
    await tester.pumpWidget(app('one'));
    final first = handed();
    await tester.pumpWidget(app('two'));
    expect(find.text('two'), findsOneWidget);
    expect(
      handed(),
      same(first),
      reason: 'the default theme was built again for a rebuilt app',
    );

    // On a phone the form factor's theme is derived from it, once.
    Widget phone(String label) => FinesseApp(
      formFactor: FormFactor.mobile,
      home: Text(label, textDirection: TextDirection.ltr),
    );
    await tester.pumpWidget(phone('three'));
    final mobile = handed();
    expect(mobile.formFactor, FormFactor.mobile);
    await tester.pumpWidget(phone('four'));
    expect(handed(), same(mobile));
  });
}
