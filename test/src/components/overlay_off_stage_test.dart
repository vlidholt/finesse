import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// An overlay must not stay on screen when its anchor is no longer shown.
///
/// The overlay is painted in the app's `Overlay`, not where its anchor is,
/// so hiding the anchor's part of the tree does not hide it. Disabled
/// tickers are one sign of that (`popover_ticker_mode_test.dart`), but not
/// the only one, and not the usual one: a bare `IndexedStack` keeps the
/// tickers of its hidden children running and only reports them invisible
/// (`Visibility.of`), and an `Offstage` — or anything else that simply does
/// not paint its child — reports nothing at all.
void main() {
  /// Ways of hiding [child] while keeping its state.
  final hiders = <String, Widget Function(bool shown, Widget child)>{
    'a bare IndexedStack': (shown, child) => IndexedStack(
      index: shown ? 0 : 1,
      children: [
        child,
        const Center(child: Text('Other')),
      ],
    ),
    'Visibility(maintainState: true)': (shown, child) => Stack(
      children: [
        Visibility(visible: shown, maintainState: true, child: child),
        if (!shown) const Center(child: Text('Other')),
      ],
    ),
    'Visibility.maintain': (shown, child) => Stack(
      children: [
        Visibility.maintain(visible: shown, child: child),
        if (!shown) const Center(child: Text('Other')),
      ],
    ),
    'Offstage': (shown, child) => Stack(
      children: [
        Offstage(offstage: !shown, child: child),
        if (!shown) const Center(child: Text('Other')),
      ],
    ),
    'an Opacity of zero': (shown, child) => Stack(
      children: [
        Opacity(opacity: shown ? 1 : 0, child: child),
        if (!shown) const Center(child: Text('Other')),
      ],
    ),
  };

  /// Overlays, each with a way to open and close it from outside.
  final subjects =
      <
        String,
        ({
          ChangeNotifier Function() controller,
          Widget Function(ChangeNotifier controller) build,
          void Function(ChangeNotifier controller, {required bool open}) set,
        })
      >{
        'a Popover': (
          controller: PopoverController.new,
          build: (controller) => Popover(
            controller: controller as PopoverController,
            builder: (context) => const Text('Floating'),
            child: const Text('Anchor'),
          ),
          set: (controller, {required open}) =>
              (controller as PopoverController).setOpen(open),
        ),
        'a Tooltip': (
          controller: PopoverController.new,
          build: (controller) => Tooltip(
            controller: controller as PopoverController,
            builder: (context) => const Text('Floating'),
            child: const SizedBox(width: 80, height: 40),
          ),
          set: (controller, {required open}) =>
              (controller as PopoverController).setOpen(open),
        ),
        'a DropdownMenu': (
          controller: PopoverController.new,
          build: (controller) => DropdownMenu(
            controller: controller as PopoverController,
            items: [
              MenuItem(onPressed: () {}, child: const Text('Floating')),
            ],
            builder: (context, controller, _) => const Text('Anchor'),
          ),
          set: (controller, {required open}) =>
              (controller as PopoverController).setOpen(open),
        ),
        'a Select': (
          controller: PopoverController.new,
          build: (controller) => Select<String>(
            onChanged: (_) {},
            controller: controller as PopoverController,
            placeholder: const Text('Pick'),
            options: const [
              SelectOption(value: 'a', child: Text('Floating')),
            ],
            selectedOptionBuilder: (context, value) => Text(value),
          ),
          set: (controller, {required open}) =>
              (controller as PopoverController).setOpen(open),
        ),
        'a DatePicker': (
          controller: PopoverController.new,
          build: (controller) => DatePicker(
            value: null,
            onChanged: (_) {},
            controller: controller as PopoverController,
            // The caption is what the test looks for.
            calendarTheme: CalendarTheme(
              formatMonthYear: (_) => 'Floating',
            ),
          ),
          set: (controller, {required open}) =>
              (controller as PopoverController).setOpen(open),
        ),
      };

  // The overlay's *element* hangs under its anchor, in the hidden branch: a
  // finder that skips off-stage elements would call an overlay that is
  // still on screen "gone".
  final floating = find.text('Floating', skipOffstage: false);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  for (final MapEntry(key: how, value: hide) in hiders.entries) {
    for (final MapEntry(key: what, value: subject) in subjects.entries) {
      testWidgets('$what is hidden while its anchor is hidden by $how, and '
          'comes back with it', (tester) async {
        final controller = subject.controller();
        addTearDown(controller.dispose);
        // One widget for the subject, so hiding it does not rebuild it:
        // an `Offstage` changes nothing but paint.
        final anchored = Center(child: subject.build(controller));
        Widget app({required bool shown}) =>
            FinesseApp(home: hide(shown, anchored));

        await tester.pumpWidget(app(shown: true));
        subject.set(controller, open: true);
        await settle(tester);
        expect(floating, findsOneWidget);

        await tester.pumpWidget(app(shown: false));
        // At most one frame later.
        await tester.pump();
        expect(floating, findsNothing, reason: 'still over what replaced it');
        await settle(tester);
        expect(floating, findsNothing);

        // Still open, it is back when its anchor is.
        await tester.pumpWidget(app(shown: true));
        await settle(tester);
        expect(floating, findsOneWidget);

        // Closed while away, the close is complete at once: nothing plays
        // an exit over the page that replaced the anchor, or later.
        await tester.pumpWidget(app(shown: false));
        await tester.pump();
        subject.set(controller, open: false);
        await tester.pump();
        await tester.pumpWidget(app(shown: true));
        await tester.pump();
        expect(floating, findsNothing);
        await settle(tester);
        expect(floating, findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('a popover on a kept-alive page is hidden while another page '
      'shows', (tester) async {
    final controller = PopoverController();
    final pages = PageController();
    addTearDown(controller.dispose);
    addTearDown(pages.dispose);
    await tester.pumpWidget(
      FinesseApp(
        home: PageView(
          controller: pages,
          children: [
            _KeepAlive(
              child: Center(
                child: Popover(
                  controller: controller,
                  builder: (context) => const Text('Floating'),
                  child: const Text('Anchor'),
                ),
              ),
            ),
            const Center(child: Text('Other')),
          ],
        ),
      ),
    );
    controller.open();
    await settle(tester);
    expect(floating, findsOneWidget);

    pages.jumpToPage(1);
    await tester.pump();
    await tester.pump();
    expect(find.text('Anchor', skipOffstage: false), findsOneWidget);
    expect(floating, findsNothing);

    pages.jumpToPage(0);
    await settle(tester);
    expect(floating, findsOneWidget);
  });

  testWidgets('scrolled out of the viewport but still built, the anchor '
      'keeps its popover', (tester) async {
    // Not painted is not the same as scrolled away: the overlay follows
    // its anchor to the edge of the screen, as it always has.
    final controller = PopoverController();
    final scroll = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      FinesseApp(
        home: ListView(
          controller: scroll,
          children: [
            Center(
              child: Popover(
                controller: controller,
                builder: (context) => const Text('Floating'),
                child: const SizedBox(height: 40, child: Text('Anchor')),
              ),
            ),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );
    controller.open();
    await settle(tester);
    expect(floating, findsOneWidget);
    scroll.jumpTo(100);
    await settle(tester);
    expect(find.text('Anchor', skipOffstage: false), findsOneWidget);
    expect(floating, findsOneWidget);
  });
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
