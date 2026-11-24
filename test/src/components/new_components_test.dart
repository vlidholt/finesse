import 'dart:ui' show Tristate;

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => FinesseApp(home: Center(child: child));

  group('Skeleton', () {
    testWidgets('renders at the requested size', (tester) async {
      await tester.pumpWidget(
        wrap(const Skeleton(width: 200, height: 16, animate: false)),
      );
      final size = tester.getSize(find.byType(Skeleton));
      expect(size, const Size(200, 16));
    });

    testWidgets('reads its color from the theme', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(
            colorScheme: const SlateColorScheme.light(),
            brightness: Brightness.light,
            skeletonTheme: const SkeletonTheme(
              color: Color(0xFF123456),
              animate: false,
            ),
          ),
          home: const Center(child: Skeleton(width: 10, height: 10)),
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(Skeleton),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (box.decoration as BoxDecoration).color,
        const Color(0xFF123456),
      );
    });

    testWidgets('is hidden from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const Skeleton(width: 10, height: 10, animate: false)),
      );
      expect(find.byType(ExcludeSemantics), findsWidgets);
      handle.dispose();
    });
  });

  group('Spinner', () {
    testWidgets('renders at the requested size and keeps animating', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const Spinner(size: 24)));
      expect(tester.getSize(find.byType(Spinner)), const Size(24, 24));

      // A repeating animation never settles, so pump fixed frames instead of
      // pumpAndSettle (which would time out).
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('Kbd', () {
    testWidgets('renders a single cap', (tester) async {
      await tester.pumpWidget(wrap(const Kbd('K')));
      expect(find.text('K'), findsOneWidget);
    });

    testWidgets('renders a group of caps', (tester) async {
      await tester.pumpWidget(wrap(const Kbd.group(['⌘', 'K'])));
      expect(find.text('⌘'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
    });
  });

  group('Toggle', () {
    testWidgets('calls onChanged with the flipped value', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        wrap(
          Toggle(
            value: false,
            onChanged: changes.add,
            child: const Text('Bold'),
          ),
        ),
      );

      await tester.tap(find.byType(Toggle));
      await tester.pumpAndSettle();
      expect(changes, [true]);
    });

    testWidgets('does not fire when disabled', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        wrap(
          Toggle(
            value: false,
            enabled: false,
            onChanged: changes.add,
            child: const Text('Bold'),
          ),
        ),
      );

      await tester.tap(find.byType(Toggle), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('outline uses the outline toggle theme', (tester) async {
      await tester.pumpWidget(
        wrap(
          Toggle.outline(
            value: false,
            onChanged: (_) {},
            child: const Text('Bold'),
          ),
        ),
      );

      final theme = Theme.of(
        tester.element(find.byType(Toggle)),
      );
      expect(theme.outlineToggleTheme.decoration?.border?.top?.width, 1);
      expect(theme.toggleTheme.decoration?.border?.top?.width, 0);
    });

    testWidgets('exposes its toggled state to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          Toggle(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Bold',
            child: const Text('B'),
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(Toggle));
      // The explicit label replaces the child's text rather than merging.
      expect(node.label, 'Bold');
      expect(node.flagsCollection.isButton, isTrue);
      // isToggled/isEnabled are tri-state: unset, true or false.
      expect(node.flagsCollection.isToggled, Tristate.isTrue);
      expect(node.flagsCollection.isEnabled, Tristate.isTrue);
      handle.dispose();
    });
  });

  group('ToggleGroup', () {
    testWidgets('single variant replaces the selection', (tester) async {
      Set<String>? latest;
      await tester.pumpWidget(
        wrap(
          ToggleGroup<String>(
            values: const {'a'},
            onChanged: (v) => latest = v,
            children: const [
              ToggleGroupItem(value: 'a', child: Text('A')),
              ToggleGroupItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(latest, {'b'});
    });

    testWidgets('single variant deselects on re-tap', (tester) async {
      Set<String>? latest;
      await tester.pumpWidget(
        wrap(
          ToggleGroup<String>(
            values: const {'a'},
            onChanged: (v) => latest = v,
            children: const [
              ToggleGroupItem(value: 'a', child: Text('A')),
              ToggleGroupItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(latest, isEmpty);
    });

    testWidgets('multiple variant accumulates', (tester) async {
      Set<String>? latest;
      await tester.pumpWidget(
        wrap(
          ToggleGroup<String>.multiple(
            values: const {'a'},
            onChanged: (v) => latest = v,
            children: const [
              ToggleGroupItem(value: 'a', child: Text('A')),
              ToggleGroupItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(latest, {'a', 'b'});
    });
  });

  group('Collapsible', () {
    testWidgets('hides content until opened', (tester) async {
      final controller = CollapsibleController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          Collapsible(
            controller: controller,
            child: const Text('Hidden'),
          ),
        ),
      );
      expect(find.text('Hidden'), findsNothing);

      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Hidden'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('keeps content mounted with maintainState', (tester) async {
      final controller = CollapsibleController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          Collapsible(
            controller: controller,
            maintainState: true,
            child: const Text('Hidden'),
          ),
        ),
      );
      expect(find.text('Hidden'), findsOneWidget);
    });
  });

  group('Empty', () {
    testWidgets('falls back to a localized title', (tester) async {
      await tester.pumpWidget(wrap(const Empty()));
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('renders icon, title, description and actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          Empty(
            icon: const Icon(PhosphorIconsRegular.tray),
            title: const Text('Nothing here'),
            description: const Text('Try again later.'),
            actions: [
              Button(onPressed: () {}, child: const Text('Refresh')),
            ],
          ),
        ),
      );
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try again later.'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.tray), findsOneWidget);
    });
  });

  group('Pagination.buildPageWindow', () {
    test('returns every page when they all fit', () {
      expect(
        Pagination.buildPageWindow(page: 1, pageCount: 5),
        [1, 2, 3, 4, 5],
      );
    });

    test('inserts an ellipsis for a skipped run', () {
      expect(
        Pagination.buildPageWindow(page: 1, pageCount: 20),
        [1, 2, null, 20],
      );
    });

    test('windows around the current page', () {
      expect(
        Pagination.buildPageWindow(page: 10, pageCount: 20),
        [1, null, 9, 10, 11, null, 20],
      );
    });

    test('renders the page itself rather than hiding a single one', () {
      // A gap of exactly one page would make the ellipsis longer than the
      // number it replaces.
      expect(
        Pagination.buildPageWindow(page: 4, pageCount: 7),
        [1, 2, 3, 4, 5, 6, 7],
      );
    });

    test('handles the degenerate cases', () {
      expect(Pagination.buildPageWindow(page: 1, pageCount: 0), isEmpty);
      expect(Pagination.buildPageWindow(page: 1, pageCount: 1), [1]);
      // An out-of-range page is clamped rather than throwing.
      expect(
        Pagination.buildPageWindow(page: 99, pageCount: 3),
        [1, 2, 3],
      );
    });
  });

  group('Pagination', () {
    testWidgets('navigates with the previous/next buttons', (tester) async {
      final visited = <int>[];
      await tester.pumpWidget(
        wrap(
          Pagination(
            page: 5,
            pageCount: 20,
            onPageChanged: visited.add,
          ),
        ),
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(visited, [6]);

      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();
      expect(visited, [6, 4]);
    });

    testWidgets('does not go before the first page', (tester) async {
      final visited = <int>[];
      await tester.pumpWidget(
        wrap(
          Pagination(page: 1, pageCount: 5, onPageChanged: visited.add),
        ),
      );

      await tester.tap(find.text('Previous'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(visited, isEmpty);
    });

    testWidgets('jumps to a tapped page number', (tester) async {
      final visited = <int>[];
      await tester.pumpWidget(
        wrap(
          Pagination(page: 1, pageCount: 5, onPageChanged: visited.add),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(visited, [3]);
    });
  });
}
