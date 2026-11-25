import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// An overlay must not outlive the part of the tree its anchor is in.
///
/// A popover's overlay is built in the nearest `Overlay`, not next to its
/// anchor. When the anchor's branch goes inactive — the other child of an
/// `IndexedStack` is shown, with tickers disabled for the one that is not —
/// the overlay used to stay on screen over whatever replaced it, and its
/// exit animation, driven by a muted ticker, never finished: the account
/// menu of the example app sat over the component library and nothing
/// closed it.
void main() {
  /// Two "sections" in an IndexedStack, the way an app keeps both alive and
  /// lets only the showing one tick.
  Widget sections({required int index, required Widget first}) => IndexedStack(
    index: index,
    children: [
      TickerMode(
        enabled: index == 0,
        child: Center(child: first),
      ),
      TickerMode(
        enabled: index == 1,
        child: const Center(child: Text('Second section')),
      ),
    ],
  );

  // The overlay is painted in the app's `Overlay`, but its *element* hangs
  // under its anchor — in the child of the `IndexedStack` that has just
  // gone off stage. A finder that skips off-stage elements would call a
  // menu still on screen "gone".
  Finder shown(String text) => find.text(text, skipOffstage: false);

  testWidgets('a menu closed while its section is switched away is removed', (
    tester,
  ) async {
    var index = 0;
    late StateSetter setState;
    await pumpFinesse(
      tester,
      StatefulBuilder(
        builder: (context, set) {
          setState = set;
          return sections(
            index: index,
            first: DropdownMenu(
              items: [
                MenuItem(
                  // The item switches section and the menu then closes
                  // itself — in that order, as `onPressed` runs first.
                  onPressed: () => setState(() => index = 1),
                  child: const Text('Browse components'),
                ),
              ],
              builder: (context, controller, _) => Button(
                onPressed: controller.toggle,
                child: const Text('Account'),
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Account'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Browse components'), findsOneWidget);

    await tester.tap(find.text('Browse components'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(index, 1);
    expect(find.text('Second section'), findsOneWidget);
    expect(shown('Browse components'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an open popover is hidden while its section is away, and '
      'comes back with it', (tester) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    Widget app(int index) => sections(
      index: index,
      first: Popover(
        controller: controller,
        builder: (context) => const Text('Popover content'),
        child: const Text('Anchor'),
      ),
    );

    await pumpFinesse(tester, app(0));
    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Popover content'), findsOneWidget);

    await pumpFinesse(tester, app(1));
    expect(shown('Popover content'), findsNothing);

    // Closing it while it is away takes effect at once: there is no ticker
    // to run the exit animation.
    controller.close();
    await tester.pump();
    await pumpFinesse(tester, app(0));
    expect(shown('Popover content'), findsNothing);

    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Popover content'), findsOneWidget);
    await pumpFinesse(tester, app(1));
    expect(shown('Popover content'), findsNothing);
    await pumpFinesse(tester, app(0));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Popover content'), findsOneWidget);
  });

  testWidgets('a tooltip does not stay over the section that replaced its '
      'trigger', (tester) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    Widget app(int index) => sections(
      index: index,
      first: Tooltip(
        controller: controller,
        builder: (context) => const Text('Tooltip text'),
        child: const SizedBox(key: Key('trigger'), width: 80, height: 40),
      ),
    );

    await pumpFinesse(tester, app(0));
    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Tooltip text'), findsOneWidget);

    await pumpFinesse(tester, app(1));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Second section'), findsOneWidget);
    expect(shown('Tooltip text'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
