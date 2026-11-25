import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(FinesseApp(home: home));
    await tester.pump();
  }

  Widget page({
    List<Widget> actions = const [],
    bool imply = true,
    Widget? endDrawer,
    bool sliver = false,
  }) => Scaffold(
    endDrawer: endDrawer,
    appBar: sliver
        ? null
        : AppBar(
            title: const Text('Page'),
            actions: actions,
            automaticallyImplyActions: imply,
          ),
    body: sliver
        ? CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Page'),
                actions: actions,
                automaticallyImplyActions: imply,
              ),
              const SliverFillRemaining(),
            ],
          )
        : const SizedBox.expand(),
  );

  group('the action a bar shows by itself', () {
    for (final sliver in [false, true]) {
      final bar = sliver ? 'SliverAppBar' : 'AppBar';

      testWidgets('$bar: a menu button at the end over a scaffold with an '
          'end drawer, and it opens the drawer', (tester) async {
        final handle = tester.ensureSemantics();
        await pump(
          tester,
          page(endDrawer: const Text('End drawer'), sliver: sliver),
        );
        final button = find.byIcon(PhosphorIconsRegular.list);
        expect(button, findsOneWidget);
        expect(find.bySemanticsLabel('Open menu'), findsOneWidget);
        // At the end of the bar, after the title.
        expect(
          tester.getCenter(button).dx,
          greaterThan(tester.getCenter(find.text('Page')).dx),
        );
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('End drawer'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('$bar: none when the bar has actions of its own, or is '
          'told not to', (tester) async {
        await pump(
          tester,
          page(
            endDrawer: const Text('End drawer'),
            actions: [const Text('Mine')],
            sliver: sliver,
          ),
        );
        expect(find.byIcon(PhosphorIconsRegular.list), findsNothing);
        expect(find.text('Mine'), findsOneWidget);

        await pump(tester, const SizedBox());
        await pump(
          tester,
          page(
            endDrawer: const Text('End drawer'),
            imply: false,
            sliver: sliver,
          ),
        );
        expect(find.byIcon(PhosphorIconsRegular.list), findsNothing);
      });

      testWidgets('$bar: none without an end drawer', (tester) async {
        await pump(tester, page(sliver: sliver));
        expect(find.byType(IconButton), findsNothing);
      });
    }
  });
}
