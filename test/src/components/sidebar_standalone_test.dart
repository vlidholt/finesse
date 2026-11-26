import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

void main() {
  final taps = <String>[];
  setUp(taps.clear);

  Sidebar sidebar({bool trigger = false}) => Sidebar(
    header: Row(
      children: [
        const Expanded(child: Text('Acme')),
        if (trigger) const SidebarTrigger(),
      ],
    ),
    footer: const Text('Signed in'),
    children: [
      SidebarGroup(
        label: const Text('Workspace'),
        children: [
          SidebarMenu(
            children: [
              SidebarMenuButton(
                selected: true,
                leading: const PhosphorIcon(PhosphorIconsRegular.house),
                onPressed: () => taps.add('home'),
                child: const Text('Home'),
              ),
              SidebarMenuButton(
                leading: const PhosphorIcon(PhosphorIconsRegular.gear),
                onPressed: () => taps.add('settings'),
                child: const Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  group('a Sidebar without a SidebarScaffold', () {
    for (final direction in TextDirection.values) {
      testWidgets('is a Scaffold drawer, ${direction.name}', (tester) async {
        final scaffold = GlobalKey<ScaffoldState>();
        await pumpUna(
          tester,
          Scaffold(
            key: scaffold,
            drawer: sidebar(trigger: true),
            body: const Center(child: Text('Page')),
          ),
          formFactor: FormFactor.mobile,
          textDirection: direction,
        );
        expect(find.text('Home'), findsNothing);

        scaffold.currentState!.openDrawer();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(scaffold.currentState!.isDrawerOpen, isTrue);

        // Expanded, with its header, items and footer, top to bottom.
        final panel = tester.getRect(find.byType(Sidebar));
        expect(panel.height, 844);
        expect(panel.width, greaterThan(200));
        expect(panel.width, lessThan(390));
        expect(
          tester.getCenter(find.text('Acme')).dy,
          lessThan(tester.getCenter(find.text('Home')).dy),
        );
        expect(
          tester.getCenter(find.text('Settings')).dy,
          lessThan(tester.getCenter(find.text('Signed in')).dy),
        );
        // A menu button is a full row, not the icon rail's square.
        expect(
          tester.getSize(find.byType(SidebarMenuButton).first).width,
          greaterThan(150),
        );

        await tester.tap(find.text('Settings'));
        await tester.pump();
        expect(taps, ['settings']);
        // A press does not close the drawer by itself.
        expect(scaffold.currentState!.isDrawerOpen, isTrue);

        // The sidebar's own trigger closes the panel it is in.
        await tester.tap(find.byType(SidebarTrigger));
        await tester.pumpAndSettle();
        expect(scaffold.currentState!.isDrawerOpen, isFalse);
        expect(find.text('Home'), findsNothing);
        expect(find.text('Page'), findsOneWidget);

        // And it opens again as it was.
        scaffold.currentState!.openDrawer();
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('is a panel in a page, where its trigger leaves the page be', (
      tester,
    ) async {
      await pumpUna(
        tester,
        Row(
          children: [
            SizedBox(width: 260, child: sidebar(trigger: true)),
            const Expanded(child: Center(child: Text('Page'))),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Sidebar)), const Size(260, 800));
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(taps, ['home']);

      await tester.tap(find.byType(SidebarTrigger));
      await tester.pumpAndSettle();
      expect(find.text('Page'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('is the content of a sheet', (tester) async {
      await pumpUna(
        tester,
        Builder(
          builder: (context) => Center(
            child: Button(
              onPressed: () => showSheet<void>(
                context: context,
                side: SheetSide.start,
                builder: (context) => Sheet(
                  style: const SheetTheme(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: 280),
                  ),
                  showCloseButton: false,
                  scrollable: false,
                  child: sidebar(trigger: true),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.byType(SidebarTrigger));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('inside a SidebarScaffold nothing changes', (tester) async {
      await pumpUna(
        tester,
        SidebarScaffold(sidebar: sidebar(), child: const Text('Page')),
      );
      final scope = SidebarScope.of(tester.element(find.text('Home')));
      expect(scope.inSheet, isFalse);
      expect(scope.isMobile, isFalse);
    });
  });
}
