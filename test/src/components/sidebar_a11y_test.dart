import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// The sidebar from the keyboard and for assistive technology: every row,
/// the trigger and the row actions are Tab stops that Enter and Space
/// activate; a closed panel and the icon rail's hidden parts are not; the
/// sidebar is a named navigation landmark; its rows grow with scaled text;
/// and reduced motion moves it at once.
/// Whether [context] is in the subtree of a widget that [finder] finds.
bool within(BuildContext context, Finder finder) {
  final elements = finder.evaluate().toSet();
  if (elements.contains(context)) return true;
  var inside = false;
  context.visitAncestorElements((element) {
    inside = elements.contains(element);
    return !inside;
  });
  return inside;
}

/// Whether anything inside a widget that [finder] finds can be reached with
/// Tab.
bool reachable(WidgetTester tester, Finder finder) {
  for (final node in FocusManager.instance.rootScope.descendants) {
    final context = node.context;
    if (context == null || !node.canRequestFocus || node.skipTraversal) {
      continue;
    }
    if (within(context, finder)) return true;
  }
  return false;
}

void main() {
  Widget scaffold({
    required SidebarController controller,
    SidebarCollapsible collapsible = SidebarCollapsible.offcanvas,
    VoidCallback? onHome,
    VoidCallback? onAdd,
    VoidCallback? onSub,
    VoidCallback? onRowAction,
  }) {
    return SidebarScaffold(
      controller: controller,
      sidebar: Sidebar(
        collapsible: collapsible,
        children: [
          SidebarGroup(
            label: const Text('Projects'),
            action: SidebarMenuAction(
              icon: const PhosphorIcon(PhosphorIconsRegular.plus),
              semanticLabel: 'Add project',
              onPressed: onAdd,
            ),
            children: [
              SidebarMenu(
                children: [
                  SidebarMenuButton(
                    leading: const PhosphorIcon(PhosphorIconsRegular.house),
                    onPressed: onHome,
                    trailing: SidebarMenuAction(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.dotsThree,
                      ),
                      semanticLabel: 'More',
                      onPressed: onRowAction,
                    ),
                    child: const Text('Home'),
                  ),
                  SidebarMenuSub(
                    children: [
                      SidebarMenuSubButton(
                        onPressed: onSub,
                        child: const Text('Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      child: const Align(
        alignment: Alignment.topLeft,
        child: SidebarTrigger(),
      ),
    );
  }

  /// Presses Tab until the focus is in a widget that [finder] finds, and
  /// fails if it never gets there.
  Future<void> tabTo(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 12; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focus = FocusManager.instance.primaryFocus?.context;
      if (focus != null && within(focus, finder)) return;
    }
    fail('Tab never reached $finder');
  }

  testWidgets('rows, the trigger and the actions are Tab stops that Enter '
      'and Space activate', (tester) async {
    final controller = SidebarController();
    addTearDown(controller.dispose);
    var home = 0;
    var add = 0;
    var sub = 0;
    var rowAction = 0;
    await pumpUna(
      tester,
      scaffold(
        controller: controller,
        onHome: () => home++,
        onAdd: () => add++,
        onSub: () => sub++,
        onRowAction: () => rowAction++,
      ),
    );

    await tabTo(tester, find.byType(SidebarMenuButton));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(home, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(home, 2);

    await tabTo(
      tester,
      find.descendant(
        of: find.byType(SidebarMenuButton),
        matching: find.byType(SidebarMenuAction),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(rowAction, 1);
    expect(home, 2, reason: 'the action is not the row');

    await tabTo(tester, find.byType(SidebarMenuSubButton));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(sub, 1);

    await tabTo(tester, find.byType(SidebarTrigger));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(controller.isOpen, isFalse);

    // The group's action, from the start again.
    controller.open();
    await settle(tester);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tabTo(
      tester,
      find.descendant(
        of: find.byType(SidebarGroup),
        matching: find.byWidgetPredicate(
          (w) => w is SidebarMenuAction && w.semanticLabel == 'Add project',
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(add, 1);
  });

  testWidgets('a row shows the sidebar ring while it has the focus', (
    tester,
  ) async {
    useTraditionalHighlights();
    final controller = SidebarController();
    addTearDown(controller.dispose);
    await pumpUna(tester, scaffold(controller: controller, onHome: () {}));

    Decorator decorator() => tester.widget<Decorator>(
      find
          .descendant(
            of: find.byType(SidebarMenuButton),
            matching: find.byType(Decorator),
          )
          .first,
    );

    expect(decorator().focused, isFalse);
    await tabTo(tester, find.byType(SidebarMenuButton));
    await tester.pump();
    expect(decorator().focused, isTrue);
  });

  testWidgets('the trigger says whether the sidebar is open', (tester) async {
    final handle = tester.ensureSemantics();
    final controller = SidebarController();
    addTearDown(controller.dispose);
    await pumpUna(tester, scaffold(controller: controller));

    final trigger = find.byType(SidebarTrigger);
    expect(
      tester.getSemantics(trigger),
      containsSemantics(
        label: 'Toggle sidebar',
        isButton: true,
        isExpanded: true,
        hasExpandedState: true,
        hasTapAction: true,
      ),
    );
    controller.close();
    await settle(tester);
    expect(
      tester.getSemantics(trigger),
      containsSemantics(isExpanded: false, hasExpandedState: true),
    );
    handle.dispose();
  });

  testWidgets('a closed off-canvas sidebar is neither a Tab stop nor read', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = SidebarController();
    addTearDown(controller.dispose);
    await pumpUna(tester, scaffold(controller: controller, onHome: () {}));
    expect(reachable(tester, find.byType(Sidebar)), isTrue);
    expect(find.semantics.byLabel('Home'), findsOne);

    controller.close();
    await settle(tester);
    expect(reachable(tester, find.byType(Sidebar)), isFalse);
    expect(find.semantics.byLabel('Home'), findsNothing);

    // Tab goes round the page without entering it.
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focus = FocusManager.instance.primaryFocus?.context;
      if (focus == null) continue;
      expect(within(focus, find.byType(Sidebar)), isFalse);
    }
    handle.dispose();
  });

  testWidgets("the icon rail leaves out the group label's action", (
    tester,
  ) async {
    final controller = SidebarController();
    addTearDown(controller.dispose);
    await pumpUna(
      tester,
      scaffold(
        controller: controller,
        collapsible: SidebarCollapsible.icon,
        onAdd: () {},
        onHome: () {},
        onRowAction: () {},
      ),
    );
    final groupAction = find.byWidgetPredicate(
      (w) => w is SidebarMenuAction && w.semanticLabel == 'Add project',
    );
    final rowAction = find.byWidgetPredicate(
      (w) => w is SidebarMenuAction && w.semanticLabel == 'More',
    );
    expect(reachable(tester, groupAction), isTrue);
    expect(reachable(tester, rowAction), isTrue);

    controller.close();
    await settle(tester);
    expect(reachable(tester, groupAction), isFalse);
    expect(reachable(tester, rowAction), isFalse);
    // The rail's rows stay.
    expect(reachable(tester, find.byType(SidebarMenuButton)), isTrue);
  });

  testWidgets('a row action takes a tap over at least 24 points', (
    tester,
  ) async {
    final controller = SidebarController();
    addTearDown(controller.dispose);
    var taps = 0;
    await pumpUna(
      tester,
      scaffold(controller: controller, onAdd: () => taps++),
    );
    final action = find.byWidgetPredicate(
      (w) => w is SidebarMenuAction && w.semanticLabel == 'Add project',
    );
    final size = tester.getSize(action);
    expect(size.width, greaterThanOrEqualTo(24));
    expect(size.height, greaterThanOrEqualTo(24));
    // A corner of the target, outside the 20-point square drawn in it.
    await tester.tapAt(tester.getTopLeft(action) + const Offset(1, 1));
    expect(taps, 1);
  });

  testWidgets('the sidebar is a named navigation landmark', (tester) async {
    final handle = tester.ensureSemantics();
    final controller = SidebarController();
    addTearDown(controller.dispose);
    await pumpUna(tester, scaffold(controller: controller));
    final node = tester.getSemantics(
      find.descendant(
        of: find.byType(Sidebar),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.role == SemanticsRole.navigation,
        ),
      ),
    );
    expect(node.getSemanticsData().role, SemanticsRole.navigation);
    expect(node.label, 'Sidebar');
    handle.dispose();
  });

  testWidgets('rows grow with scaled text instead of cutting it off', (
    tester,
  ) async {
    final controller = SidebarController();
    addTearDown(controller.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      UnaApp(
        formFactor: FormFactor.desktop,
        home: scaffold(controller: controller, onHome: () {}, onSub: () {}),
      ),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);

    for (final (row, label) in [
      (find.byType(SidebarMenuButton), 'Home'),
      (find.byType(SidebarMenuSubButton), 'Settings'),
    ]) {
      final rowBox = tester.getRect(
        find.descendant(of: row, matching: find.byType(Decorator)).first,
      );
      final text = tester.getRect(
        find.descendant(of: row, matching: find.text(label)),
      );
      expect(rowBox.height, greaterThanOrEqualTo(text.height), reason: label);
      expect(rowBox.top, lessThanOrEqualTo(text.top), reason: label);
      expect(rowBox.bottom, greaterThanOrEqualTo(text.bottom), reason: label);
    }
  });

  testWidgets('under reduced motion the sidebar closes at once', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    final controller = SidebarController();
    addTearDown(controller.dispose);
    await pumpUna(tester, scaffold(controller: controller));
    expect(tester.getSize(find.byType(Sidebar)).width, greaterThan(0));

    controller.close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.getSize(find.byType(Sidebar)).width, 0);
  });
}
