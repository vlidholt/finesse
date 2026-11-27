import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/navigation_rail.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// What assistive technology is told about the navigation components and
/// the small widgets around them: landmarks and their names, the current
/// breadcrumb, an avatar's name, a progress indicator's role, a tab's
/// panel.
void main() {
  const destinations = [
    NavigationDestination(
      icon: SizedBox.square(dimension: 20),
      label: 'Home',
    ),
    NavigationDestination(
      icon: SizedBox.square(dimension: 20),
      label: 'Jobs',
    ),
  ];

  /// The navigation landmarks on screen, by name.
  List<String> landmarks() => [
    for (final node
        in find.semantics
            .byPredicate(
              (node) =>
                  node.getSemanticsData().role == SemanticsRole.navigation,
            )
            .evaluate())
      node.label,
  ];

  group('navigation landmarks', () {
    testWidgets('the bars and the rail are named landmarks', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Column(
          children: [
            const NavigationBar(
              destinations: destinations,
              selectedIndex: 0,
              semanticLabel: 'Sections',
            ),
            const Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    destinations: destinations,
                    selectedIndex: 0,
                  ),
                ],
              ),
            ),
            BottomNavigationBar(
              destinations: destinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ],
        ),
      );
      // Several at once, each named — Flutter asserts that they are.
      expect(tester.takeException(), isNull);
      expect(
        landmarks(),
        unorderedEquals(['Sections', 'Main navigation', 'Main navigation']),
      );
      handle.dispose();
    });

    testWidgets('the bottom bar is a landmark on Liquid Glass too', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      LiquidGlass.debugHasShaderFilters = true;
      try {
        await pumpUna(
          tester,
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              destinations: destinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
          formFactor: FormFactor.mobile,
        );
        expect(landmarks(), ['Main navigation']);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        debugDefaultTargetPlatformOverride = null;
        LiquidGlass.debugHasShaderFilters = null;
      }
      handle.dispose();
    });
  });

  group('breadcrumb', () {
    testWidgets('is a landmark whose last item is the current page', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Breadcrumb(
          children: [
            BreadcrumbLink(onPressed: () {}, child: const Text('Home')),
            const BreadcrumbEllipsis(),
            const Text('Settings'),
          ],
        ),
      );
      expect(landmarks(), ['Breadcrumb']);
      expect(
        find.semantics.byLabel('Settings').evaluate().single,
        containsSemantics(isSelected: true),
      );
      expect(
        find.semantics.byLabel('Home').evaluate().single,
        containsSemantics(isButton: true, isSelected: false),
      );
      expect(find.semantics.byLabel('More pages'), findsOne);
      handle.dispose();
    });

    testWidgets('the dropdown says whether its menu is open', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Breadcrumb(
          children: [
            BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(
                  onPressed: () {},
                  child: const Text('Docs'),
                ),
              ],
              child: const BreadcrumbEllipsis(),
            ),
            const Text('Settings'),
          ],
        ),
      );
      SemanticsNode trigger() =>
          tester.getSemantics(find.byType(BreadcrumbLink));
      expect(
        trigger(),
        containsSemantics(
          label: 'More pages',
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );
      await tester.tap(find.byType(BreadcrumbEllipsis));
      await settle(tester);
      expect(trigger(), containsSemantics(isExpanded: true));
      handle.dispose();
    });

    testWidgets('the caret turns at once under reduced motion', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpUna(
        tester,
        BreadcrumbDropdown(
          items: [
            BreadcrumbDropMenuItem(onPressed: () {}, child: const Text('Docs')),
          ],
          child: const Text('More'),
        ),
      );
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).duration,
        Duration.zero,
      );
    });
  });

  group('avatar', () {
    testWidgets('a named avatar is one image; an unnamed one is decorative', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Row(
          children: [
            Avatar(null, semanticLabel: 'Ann Lee', fallback: Text('AL')),
            Avatar(null, fallback: Text('BO')),
          ],
        ),
      );
      expect(
        find.semantics.byLabel('Ann Lee').evaluate().single,
        containsSemantics(isImage: true),
      );
      expect(find.semantics.byLabel('AL'), findsNothing);
      expect(find.semantics.byLabel('BO'), findsNothing);
      handle.dispose();
    });
  });

  group('progress', () {
    SemanticsData data(WidgetTester tester, Finder finder) =>
        tester.getSemantics(finder).getSemanticsData();

    testWidgets('a known progress is a progress bar from 0 to 100', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Column(
          children: [
            ProgressBar(value: .42, semanticLabel: 'Upload'),
            ProgressRing(value: .5, semanticLabel: 'Storage'),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      for (final (type, value) in [
        (ProgressBar, '42%'),
        (ProgressRing, '50%'),
      ]) {
        final node = data(tester, find.byType(type));
        expect(node.role, SemanticsRole.progressBar, reason: '$type');
        expect(node.minValue, '0', reason: '$type');
        expect(node.maxValue, '100', reason: '$type');
        expect(node.value, value, reason: '$type');
      }
      handle.dispose();
    });

    testWidgets('an unknown progress is a loading spinner', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Column(
          children: [
            ProgressBar(semanticLabel: 'Syncing'),
            ProgressRing(value: null, semanticLabel: 'Loading'),
            Spinner(semanticLabel: 'Saving'),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      for (final label in ['Syncing', 'Loading', 'Saving']) {
        final node = find.semantics.byLabel(label).evaluate().single;
        expect(
          node.getSemanticsData().role,
          SemanticsRole.loadingSpinner,
          reason: label,
        );
      }
      handle.dispose();
    });

    testWidgets("a caller's own wording keeps the node but not the role", (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const ProgressRing(
          value: .24,
          semanticLabel: 'Storage',
          semanticValue: '12 of 50 GB',
        ),
      );
      expect(tester.takeException(), isNull);
      final node = data(tester, find.byType(ProgressRing));
      expect(node.value, '12 of 50 GB');
      expect(node.role, SemanticsRole.none);
      handle.dispose();
    });
  });

  testWidgets("the selected tab's page is its panel", (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: TabBarView<String>(
          value: 'a',
          pages: {
            'a': (context) => const Text('page a'),
            'b': (context) => const Text('page b'),
          },
        ),
      ),
    );
    final panel = find.semantics.byPredicate(
      (node) => node.getSemanticsData().role == SemanticsRole.tabPanel,
    );
    expect(panel, findsOne);
    // The page's content is read as part of its panel.
    expect(panel.evaluate().single.label, 'page a');
    handle.dispose();
  });
}
