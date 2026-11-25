import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The row kinds a menu takes beside `MenuItem`: checkbox and radio
/// rows, labels, dividers and shortcuts — and the column every row of a
/// menu keeps free once one of them is checkable.
enum _Fruit { apple, banana, cherry }

void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Pumps an open `DropdownMenu` with [items], rebuilt by [rebuild].
  Future<PopoverController> pumpMenu(
    WidgetTester tester, {
    required List<Widget> Function(StateSetter setState) items,
    ThemeData? theme,
    FormFactor formFactor = FormFactor.desktop,
    TextDirection textDirection = TextDirection.ltr,
    double textScale = 1,
    Size size = const Size(800, 700),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = PopoverController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      FinesseApp(
        theme: theme,
        formFactor: formFactor,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Directionality(textDirection: textDirection, child: child!),
        ),
        home: Align(
          alignment: AlignmentDirectional.topStart,
          child: StatefulBuilder(
            builder: (context, setState) => DropdownMenu(
              controller: controller,
              items: items(setState),
              builder: (context, controller, _) => const Text('Anchor'),
            ),
          ),
        ),
      ),
    );
    controller.open();
    await settle(tester);
    return controller;
  }

  Finder check(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Button)),
    matching: find.byIcon(PhosphorIconsRegular.check),
  );

  /// The dot of a radio row: the round box in the row's indicator column.
  Finder dot(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Button)),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle,
    ),
  );

  bool focused(WidgetTester tester, String label) =>
      Focus.of(tester.element(find.text(label))).hasFocus;

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  testWidgets('MenuItem.style overrides the menu theme for one row', (
    tester,
  ) async {
    await pumpMenu(
      tester,
      items: (_) => [
        MenuItem(onPressed: () {}, child: const Text('Plain')),
        MenuItem(
          onPressed: () {},
          style: const ContextMenuTheme(height: 48),
          child: const Text('Tall'),
        ),
      ],
    );
    double heightOf(String label) => tester
        .getSize(
          find.ancestor(of: find.text(label), matching: find.byType(Button)),
        )
        .height;
    expect(heightOf('Plain'), lessThan(48));
    expect(heightOf('Tall'), 48);
  });
  group('MenuCheckboxItem', () {
    testWidgets('a click toggles it and leaves the menu open', (tester) async {
      var checked = false;
      final menu = await pumpMenu(
        tester,
        items: (setState) => [
          MenuCheckboxItem(
            checked: checked,
            onChanged: (value) => setState(() => checked = value),
            child: const Text('Grid'),
          ),
        ],
      );
      expect(check('Grid'), findsNothing);

      await tester.tap(find.text('Grid'));
      await settle(tester);
      expect(checked, isTrue);
      expect(menu.isOpen, isTrue);
      expect(check('Grid'), findsOneWidget);

      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(checked, isFalse);
      expect(menu.isOpen, isTrue);
      expect(check('Grid'), findsNothing);
    });

    testWidgets('with closeOnTap a click and Enter close the menu, and '
        'Space still does not', (tester) async {
      var checked = false;
      final menu = await pumpMenu(
        tester,
        items: (setState) => [
          MenuCheckboxItem(
            checked: checked,
            closeOnTap: true,
            onChanged: (value) => setState(() => checked = value),
            child: const Text('Grid'),
          ),
        ],
      );
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Grid'), isTrue);

      await press(tester, LogicalKeyboardKey.space);
      await settle(tester);
      expect(checked, isTrue);
      expect(menu.isOpen, isTrue);

      await press(tester, LogicalKeyboardKey.space);
      await settle(tester);
      expect(checked, isFalse);
      expect(menu.isOpen, isTrue);

      await press(tester, LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(checked, isTrue);
      expect(menu.isOpen, isFalse);

      menu.open();
      await settle(tester);
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(checked, isFalse);
      expect(menu.isOpen, isFalse);
    });

    testWidgets('Enter toggles a row that stays open, like a click', (
      tester,
    ) async {
      var checked = false;
      final menu = await pumpMenu(
        tester,
        items: (setState) => [
          MenuCheckboxItem(
            checked: checked,
            onChanged: (value) => setState(() => checked = value),
            child: const Text('Grid'),
          ),
        ],
      );
      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.enter);
      await settle(tester);
      expect(checked, isTrue);
      expect(menu.isOpen, isTrue);
      // The row keeps the focus through the rebuild.
      expect(focused(tester, 'Grid'), isTrue);
    });

    testWidgets('without a callback, or disabled, it cannot be toggled', (
      tester,
    ) async {
      var changes = 0;
      final menu = await pumpMenu(
        tester,
        items: (setState) => [
          const MenuCheckboxItem(
            checked: true,
            onChanged: null,
            child: Text('Locked'),
          ),
          MenuCheckboxItem(
            checked: false,
            enabled: false,
            onChanged: (_) => changes++,
            child: const Text('Off'),
          ),
          MenuItem(onPressed: () {}, child: const Text('Plain')),
        ],
      );
      await tester.tap(find.text('Locked'), warnIfMissed: false);
      await tester.tap(find.text('Off'), warnIfMissed: false);
      await settle(tester);
      expect(changes, 0);
      expect(menu.isOpen, isTrue);
      // Still shown as it is.
      expect(check('Locked'), findsOneWidget);
      // The arrows pass over both.
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Plain'), isTrue);
    });

    testWidgets('is announced as checked or not, with its label, as one '
        'node that can be tapped', (tester) async {
      final handle = tester.ensureSemantics();
      var checked = true;
      await pumpMenu(
        tester,
        items: (setState) => [
          MenuCheckboxItem(
            checked: checked,
            onChanged: (value) => setState(() => checked = value),
            child: const Text('Grid'),
          ),
        ],
      );
      expect(
        tester.getSemantics(find.text('Grid')),
        isSemantics(
          label: 'Grid',
          hasCheckedState: true,
          isChecked: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.text('Grid'));
      await settle(tester);
      expect(
        tester.getSemantics(find.text('Grid')),
        isSemantics(label: 'Grid', hasCheckedState: true, isChecked: false),
      );
      handle.dispose();
    });
  });

  group('MenuRadioGroup', () {
    List<Widget> fruit(
      _Fruit? value,
      ValueChanged<_Fruit> onChanged, {
      bool closeOnTap = true,
    }) => [
      MenuRadioGroup<_Fruit>(
        value: value,
        onChanged: onChanged,
        children: [
          MenuRadioItem(
            value: _Fruit.apple,
            closeOnTap: closeOnTap,
            child: const Text('Apple'),
          ),
          MenuRadioItem(
            value: _Fruit.banana,
            closeOnTap: closeOnTap,
            child: const Text('Banana'),
          ),
          MenuRadioItem(
            value: _Fruit.cherry,
            closeOnTap: closeOnTap,
            child: const Text('Cherry'),
          ),
        ],
      ),
    ];

    testWidgets('the row with the group value shows the dot; a click picks '
        'another and closes the menu', (tester) async {
      _Fruit? value = _Fruit.apple;
      final menu = await pumpMenu(
        tester,
        items: (setState) => fruit(value, (v) => setState(() => value = v)),
      );
      expect(dot('Apple'), findsOneWidget);
      expect(dot('Banana'), findsNothing);
      expect(dot('Cherry'), findsNothing);

      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(value, _Fruit.banana);
      expect(menu.isOpen, isFalse);

      menu.open();
      await settle(tester);
      expect(dot('Apple'), findsNothing);
      expect(dot('Banana'), findsOneWidget);
    });

    testWidgets('Space picks and stays, Enter picks and closes', (
      tester,
    ) async {
      _Fruit? value;
      final menu = await pumpMenu(
        tester,
        items: (setState) => fruit(value, (v) => setState(() => value = v)),
      );
      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Banana'), isTrue);
      await press(tester, LogicalKeyboardKey.space);
      await settle(tester);
      expect(value, _Fruit.banana);
      expect(menu.isOpen, isTrue);
      expect(dot('Banana'), findsOneWidget);

      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, _Fruit.cherry);
      expect(menu.isOpen, isFalse);
    });

    testWidgets('closeOnTap: false keeps the menu open on a click', (
      tester,
    ) async {
      _Fruit? value;
      final menu = await pumpMenu(
        tester,
        items: (setState) => fruit(
          value,
          (v) => setState(() => value = v),
          closeOnTap: false,
        ),
      );
      await tester.tap(find.text('Cherry'));
      await settle(tester);
      expect(value, _Fruit.cherry);
      expect(menu.isOpen, isTrue);
    });

    testWidgets('a group without a callback disables its rows', (tester) async {
      await pumpMenu(
        tester,
        items: (setState) => const [
          MenuRadioGroup<_Fruit>(
            value: _Fruit.apple,
            onChanged: null,
            children: [
              MenuRadioItem(value: _Fruit.apple, child: Text('Apple')),
              MenuRadioItem(value: _Fruit.banana, child: Text('Banana')),
            ],
          ),
        ],
      );
      final button = tester.widget<Button>(
        find.ancestor(of: find.text('Banana'), matching: find.byType(Button)),
      );
      expect(button.enabled, isFalse);
      expect(dot('Apple'), findsOneWidget);
    });

    testWidgets('rows are announced as one of a group, checked or not', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpMenu(
        tester,
        items: (setState) => [
          MenuRadioGroup<_Fruit>(
            value: _Fruit.apple,
            onChanged: (_) {},
            children: const [
              MenuRadioItem(value: _Fruit.apple, child: Text('Apple')),
              MenuRadioItem(value: _Fruit.banana, child: Text('Banana')),
            ],
          ),
        ],
      );
      expect(
        tester.getSemantics(find.text('Apple')),
        isSemantics(
          label: 'Apple',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Banana')),
        isSemantics(
          label: 'Banana',
          hasCheckedState: true,
          isChecked: false,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      handle.dispose();
    });
  });

  group('the indicator column', () {
    List<Widget> mixed({bool checkable = true}) => [
      const MenuLabel(child: Text('Heading')),
      if (checkable)
        MenuCheckboxItem(
          checked: true,
          onChanged: (_) {},
          child: const Text('Checked'),
        ),
      MenuItem(onPressed: () {}, child: const Text('Plain')),
      MenuItem(
        leading: const PhosphorIcon(PhosphorIconsRegular.gear),
        onPressed: () {},
        child: const Text('Iconed'),
      ),
    ];

    testWidgets('with a checkable row, every label and the heading start '
        'on one line, a column in from the row', (tester) async {
      await pumpMenu(tester, items: (_) => mixed());
      final theme = Theme.of(tester.element(find.text('Plain')));
      final menuTheme = theme.contextMenuTheme;
      final column =
          menuTheme.indicatorSize! +
          menuTheme.leadingPadding!.resolve(TextDirection.ltr).horizontal;

      final checked = tester.getTopLeft(find.text('Checked')).dx;
      expect(tester.getTopLeft(find.text('Plain')).dx, checked);
      expect(tester.getTopLeft(find.text('Heading')).dx, checked);
      // A leading icon comes after the column, where the label would be.
      expect(
        tester.getTopLeft(find.byIcon(PhosphorIconsRegular.gear)).dx,
        checked,
      );
      // The mark sits in the column, before the label.
      final mark = tester.getRect(check('Checked'));
      expect(mark.width, menuTheme.indicatorSize);
      expect(mark.right, lessThanOrEqualTo(checked));
      expect(checked - mark.left, moreOrLessEquals(column));
    });

    testWidgets('without one, no row gives the column up', (tester) async {
      await pumpMenu(tester, items: (_) => mixed());
      final withColumn = tester.getTopLeft(find.text('Plain')).dx;
      await tester.pumpWidget(const SizedBox.shrink());

      await pumpMenu(tester, items: (_) => mixed(checkable: false));
      final theme = Theme.of(tester.element(find.text('Plain')));
      final menuTheme = theme.contextMenuTheme;
      final column =
          menuTheme.indicatorSize! +
          menuTheme.leadingPadding!.resolve(TextDirection.ltr).horizontal;
      final without = tester.getTopLeft(find.text('Plain')).dx;
      expect(withColumn - without, moreOrLessEquals(column));
      expect(tester.getTopLeft(find.text('Heading')).dx, without);
    });

    testWidgets('a checkable row inside a wrapper is found too', (
      tester,
    ) async {
      await pumpMenu(
        tester,
        items: (_) => [
          Builder(
            builder: (context) => MenuCheckboxItem(
              checked: true,
              onChanged: (_) {},
              child: const Text('Wrapped'),
            ),
          ),
          MenuItem(onPressed: () {}, child: const Text('Plain')),
        ],
      );
      expect(
        tester.getTopLeft(find.text('Plain')).dx,
        tester.getTopLeft(find.text('Wrapped')).dx,
      );
    });

    testWidgets('a submenu decides for itself', (tester) async {
      await pumpMenu(
        tester,
        items: (_) => [
          MenuCheckboxItem(
            checked: true,
            onChanged: (_) {},
            child: const Text('Checked'),
          ),
          MenuItem(
            items: [
              MenuItem(onPressed: () {}, child: const Text('Leaf')),
            ],
            child: const Text('More'),
          ),
        ],
      );
      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(find.text('Leaf'), findsOneWidget);
      final leafRow = tester.getRect(
        find.ancestor(of: find.text('Leaf'), matching: find.byType(Button)),
      );
      final moreRow = tester.getRect(
        find
            .ancestor(of: find.text('More'), matching: find.byType(Button))
            .first,
      );
      // The parent row is inset by the column; the submenu's is not.
      expect(
        tester.getTopLeft(find.text('More')).dx - moreRow.left,
        greaterThan(tester.getTopLeft(find.text('Leaf')).dx - leafRow.left),
      );
    });

    testWidgets('right to left the column is at the right', (tester) async {
      await pumpMenu(
        tester,
        textDirection: TextDirection.rtl,
        items: (_) => mixed(),
      );
      final checked = tester.getTopRight(find.text('Checked')).dx;
      expect(tester.getTopRight(find.text('Plain')).dx, checked);
      expect(tester.getTopRight(find.text('Heading')).dx, checked);
      expect(tester.getRect(check('Checked')).left, greaterThan(checked));
    });

    testWidgets('the mark grows with the text scale, and the labels still '
        'line up', (tester) async {
      await pumpMenu(tester, textScale: 2, items: (_) => mixed());
      final theme = Theme.of(tester.element(find.text('Plain')));
      expect(
        tester.getSize(check('Checked')).width,
        theme.contextMenuTheme.indicatorSize! * 2,
      );
      final checked = tester.getTopLeft(find.text('Checked')).dx;
      expect(tester.getTopLeft(find.text('Plain')).dx, checked);
      expect(tester.getTopLeft(find.text('Heading')).dx, checked);
      expect(tester.takeException(), isNull);
    });
  });

  group('MenuLabel and MenuDivider', () {
    List<Widget> grouped() => [
      const MenuLabel(child: Text('Fruit')),
      MenuItem(onPressed: () {}, child: const Text('Apple')),
      const MenuDivider(),
      const MenuLabel(child: Text('Vegetables')),
      MenuItem(onPressed: () {}, child: const Text('Beet')),
      MenuItem(onPressed: () {}, child: const Text('Carrot')),
    ];

    testWidgets('the arrows, Home and End pass over them', (tester) async {
      await pumpMenu(tester, items: (_) => grouped());
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Apple'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Beet'), isTrue);
      await press(tester, LogicalKeyboardKey.end);
      expect(focused(tester, 'Carrot'), isTrue);
      await press(tester, LogicalKeyboardKey.home);
      expect(focused(tester, 'Apple'), isTrue);
    });

    testWidgets('type-ahead finds rows and not headings', (tester) async {
      await pumpMenu(tester, items: (_) => grouped());
      // "V" is a heading's letter and no row's.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV, character: 'v');
      await tester.pump();
      expect(focused(tester, 'Apple'), isFalse);
      expect(focused(tester, 'Beet'), isFalse);
      expect(focused(tester, 'Carrot'), isFalse);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC, character: 'c');
      await tester.pump();
      expect(focused(tester, 'Carrot'), isTrue);
    });

    testWidgets('type-ahead reads a checkable row by its label', (
      tester,
    ) async {
      await pumpMenu(
        tester,
        items: (_) => [
          MenuItem(onPressed: () {}, child: const Text('Alpha')),
          MenuCheckboxItem(
            checked: true,
            onChanged: (_) {},
            shortcut: const MenuShortcut.text('Ctrl+Z'),
            child: const Text('Zeta'),
          ),
        ],
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ, character: 'z');
      await tester.pump();
      expect(focused(tester, 'Zeta'), isTrue);
    });

    testWidgets('a label is a header for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpMenu(tester, items: (_) => grouped());
      expect(
        tester.getSemantics(find.text('Fruit')),
        isSemantics(label: 'Fruit', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('they take their looks from the menu theme', (tester) async {
      await pumpMenu(tester, items: (_) => grouped());
      final theme = Theme.of(tester.element(find.text('Fruit')));
      final menuTheme = theme.contextMenuTheme;

      final label = DefaultTextStyle.of(tester.element(find.text('Fruit')));
      expect(label.style.color, menuTheme.labelTextStyle!.color);
      expect(label.style.fontSize, menuTheme.labelTextStyle!.fontSize);
      expect(label.style.color, theme.colorScheme.mutedForeground);

      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.color, menuTheme.dividerColor);
      expect(divider.margin, menuTheme.dividerMargin);
      // The line runs from edge to edge of the surface, inside its outline.
      final surface = tester.getRect(
        find
            .ancestor(of: find.text('Apple'), matching: find.byType(Decorator))
            .last,
      );
      final line = tester.getRect(
        find.descendant(
          of: find.byType(MenuDivider),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(line.left, moreOrLessEquals(surface.left + 1, epsilon: .01));
      expect(line.right, moreOrLessEquals(surface.right - 1, epsilon: .01));
    });

    testWidgets('on an inverted menu the divider and the label use the '
        "menu's palette, not the page's", (tester) async {
      const menuScheme = NeutralColorScheme.dark();
      await pumpMenu(
        tester,
        theme: ThemeData(
          colorScheme: const NeutralColorScheme.light(),
          style: StyleTokens.nova,
          menuColorScheme: menuScheme,
        ),
        items: (_) => grouped(),
      );
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.color, menuScheme.border);
      final label = DefaultTextStyle.of(tester.element(find.text('Fruit')));
      expect(label.style.color, menuScheme.mutedForeground);
    });

    testWidgets('a theme can restyle them', (tester) async {
      const red = Color(0xFFFF0000);
      await pumpMenu(
        tester,
        theme: ThemeData(
          contextMenuTheme: const ContextMenuTheme(
            dividerColor: red,
            dividerMargin: EdgeInsets.symmetric(vertical: 9),
            labelTextStyle: TextStyle(fontSize: 19, color: red),
            labelPadding: EdgeInsets.only(left: 40, top: 3, bottom: 3),
            indicatorSize: 22,
          ),
        ),
        items: (_) => [
          ...grouped(),
          MenuCheckboxItem(
            checked: true,
            onChanged: (_) {},
            child: const Text('Checked'),
          ),
        ],
      );
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.color, red);
      expect(divider.margin, const EdgeInsets.symmetric(vertical: 9));
      final label = DefaultTextStyle.of(tester.element(find.text('Fruit')));
      expect(label.style.fontSize, 19);
      expect(label.style.color, red);
      expect(tester.getSize(check('Checked')).width, 22);
    });
  });

  group('MenuShortcut', () {
    Future<String> describe(
      WidgetTester tester,
      SingleActivator activator,
      TargetPlatform platform,
    ) async {
      await tester.pumpWidget(const FinesseApp(home: SizedBox()));
      return MenuShortcut.describe(
        tester.element(find.byType(SizedBox).last),
        activator,
        platform: platform,
      );
    }

    testWidgets('is written in glyphs on Apple platforms, in their order', (
      tester,
    ) async {
      for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
        expect(
          await describe(
            tester,
            const SingleActivator(
              LogicalKeyboardKey.keyP,
              meta: true,
              shift: true,
            ),
            platform,
          ),
          '⇧⌘P',
        );
        expect(
          await describe(
            tester,
            const SingleActivator(
              LogicalKeyboardKey.backspace,
              meta: true,
              alt: true,
              control: true,
            ),
            platform,
          ),
          '⌃⌥⌘⌫',
        );
        expect(
          await describe(
            tester,
            const SingleActivator(LogicalKeyboardKey.enter),
            platform,
          ),
          '↩',
        );
      }
    });

    testWidgets('is spelled out and joined with + elsewhere', (tester) async {
      expect(
        await describe(
          tester,
          const SingleActivator(
            LogicalKeyboardKey.keyP,
            control: true,
            shift: true,
          ),
          TargetPlatform.windows,
        ),
        'Ctrl+Shift+P',
      );
      expect(
        await describe(
          tester,
          const SingleActivator(LogicalKeyboardKey.delete, alt: true),
          TargetPlatform.linux,
        ),
        'Alt+Del',
      );
      expect(
        await describe(
          tester,
          const SingleActivator(LogicalKeyboardKey.keyE, meta: true),
          TargetPlatform.windows,
        ),
        'Win+E',
      );
      expect(
        await describe(
          tester,
          const SingleActivator(LogicalKeyboardKey.keyE, meta: true),
          TargetPlatform.linux,
        ),
        'Meta+E',
      );
      expect(
        await describe(
          tester,
          const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true),
          TargetPlatform.android,
        ),
        'Alt+←',
      );
      expect(
        await describe(
          tester,
          const SingleActivator(LogicalKeyboardKey.f5),
          TargetPlatform.windows,
        ),
        'F5',
      );
      expect(
        await describe(
          tester,
          const SingleActivator(LogicalKeyboardKey.comma, control: true),
          TargetPlatform.windows,
        ),
        'Ctrl+,',
      );
    });

    testWidgets('follows the platform it runs on', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await pumpMenu(
        tester,
        items: (_) => [
          MenuItem(
            shortcut: const MenuShortcut(
              SingleActivator(LogicalKeyboardKey.keyS, meta: true),
            ),
            onPressed: () {},
            child: const Text('Save'),
          ),
        ],
      );
      expect(find.text('⌘S'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('sits between the label and the trailing widget, in the '
        "theme's shortcut style, and is read left to right", (tester) async {
      await pumpMenu(
        tester,
        textDirection: TextDirection.rtl,
        items: (_) => [
          MenuItem(
            shortcut: const MenuShortcut.text('Ctrl+K'),
            trailing: const PhosphorIcon(PhosphorIconsRegular.caretLeft),
            onPressed: () {},
            child: const Text('Search'),
          ),
        ],
      );
      final label = tester.getRect(find.text('Search'));
      final keys = tester.getRect(find.text('Ctrl+K'));
      final caret = tester.getRect(find.byIcon(PhosphorIconsRegular.caretLeft));
      // Right to left: label, then shortcut, then trailing.
      expect(keys.right, lessThanOrEqualTo(label.left));
      expect(caret.right, lessThanOrEqualTo(keys.left));

      final theme = Theme.of(tester.element(find.text('Search')));
      final style = DefaultTextStyle.of(
        tester.element(find.text('Ctrl+K')),
      ).style;
      final themed = theme.contextMenuTheme.shortcutTextStyle!;
      expect(style.letterSpacing, themed.letterSpacing);
      expect(style.letterSpacing, greaterThan(0));
      expect(style.fontSize, themed.fontSize);
      expect(style.color, theme.contextMenuTheme.trailingTextStyle!.color);
      expect(
        tester.widget<Text>(find.text('Ctrl+K')).textDirection,
        TextDirection.ltr,
      );
    });
  });

  group('highlight', () {
    for (final accent in MenuAccent.values) {
      testWidgets('a checkable row is highlighted at once, mark and '
          'shortcut included — ${accent.name} accent', (tester) async {
        await pumpMenu(
          tester,
          theme: ThemeData(menuAccent: accent),
          items: (_) => [
            MenuCheckboxItem(
              checked: true,
              onChanged: (_) {},
              shortcut: const MenuShortcut.text('Ctrl+G'),
              child: const Text('Grid'),
            ),
            MenuItem(onPressed: () {}, child: const Text('Plain')),
          ],
        );
        final theme = Theme.of(tester.element(find.text('Grid')));
        final menuTheme = theme.contextMenuTheme;
        final row = find.ancestor(
          of: find.text('Grid'),
          matching: find.byType(Button),
        );
        Color? fill() => tester
            .widget<Decorator>(
              find.descendant(of: row, matching: find.byType(Decorator)).first,
            )
            .decoration
            ?.color;
        Color? markColor() => IconTheme.of(
          tester.element(find.byIcon(PhosphorIconsRegular.check)),
        ).color;
        Color? keysColor() => DefaultTextStyle.of(
          tester.element(find.text('Ctrl+G')),
        ).style.color;

        expect(markColor(), menuTheme.textStyle!.color);
        expect(keysColor(), menuTheme.trailingTextStyle!.color);

        final mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: const Offset(700, 600));
        addTearDown(mouse.removePointer);
        await mouse.moveTo(tester.getCenter(find.text('Grid')));
        // One frame: no fade, no glide.
        await tester.pump();
        expect(fill(), menuTheme.selectedBackgroundColor);
        expect(markColor(), menuTheme.selectedTextStyle!.color);
        expect(keysColor(), menuTheme.selectedTrailingTextStyle!.color);

        await mouse.moveTo(tester.getCenter(find.text('Plain')));
        await tester.pump();
        expect(fill(), isNot(menuTheme.selectedBackgroundColor));
        expect(markColor(), menuTheme.textStyle!.color);
      });
    }
  });

  group('form factor and motion', () {
    testWidgets('on a phone a checkable row is a touch target', (tester) async {
      await pumpMenu(
        tester,
        formFactor: FormFactor.mobile,
        size: const Size(390, 800),
        items: (_) => [
          const MenuLabel(child: Text('Heading')),
          MenuCheckboxItem(
            checked: true,
            onChanged: (_) {},
            child: const Text('Grid'),
          ),
        ],
      );
      final row = tester.getSize(
        find.ancestor(of: find.text('Grid'), matching: find.byType(Button)),
      );
      expect(row.height, greaterThanOrEqualTo(44));
      // A heading is not one, and does not take a row's height.
      expect(
        tester.getSize(find.byType(MenuLabel)).height,
        lessThan(row.height),
      );
    });

    testWidgets('nothing overflows at twice the text size, in either '
        'direction', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpMenu(
          tester,
          textScale: 2,
          textDirection: direction,
          items: (_) => [
            const MenuLabel(child: Text('Heading')),
            MenuCheckboxItem(
              checked: true,
              onChanged: (_) {},
              shortcut: const MenuShortcut.text('Ctrl+Shift+G'),
              child: const Text('Show the grid'),
            ),
            const MenuDivider(),
            MenuRadioGroup<int>(
              value: 1,
              onChanged: (_) {},
              children: const [
                MenuRadioItem(value: 1, child: Text('One')),
                MenuRadioItem(value: 2, child: Text('Two')),
              ],
            ),
          ],
        );
        expect(tester.takeException(), isNull);
        final row = tester.getRect(
          find.ancestor(
            of: find.text('Show the grid'),
            matching: find.byType(Button),
          ),
        );
        // The row grew to hold its label.
        expect(
          row.height,
          greaterThanOrEqualTo(
            tester.getSize(find.text('Show the grid')).height,
          ),
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('the mark pops in and settles; with motion off it is there '
        'in the next frame', (tester) async {
      for (final motion in [null, Motion.none]) {
        var checked = false;
        await pumpMenu(
          tester,
          theme: ThemeData(motion: motion),
          items: (setState) => [
            MenuCheckboxItem(
              checked: checked,
              onChanged: (value) => setState(() => checked = value),
              child: const Text('Grid'),
            ),
          ],
        );
        double scale() => tester
            .widget<Transform>(
              find
                  .ancestor(of: check('Grid'), matching: find.byType(Transform))
                  .first,
            )
            .transform
            .storage[0];

        await tester.tap(find.text('Grid'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        if (motion == Motion.none) {
          expect(scale(), 1);
        } else {
          expect(scale(), lessThan(1));
          final seen = <double>[];
          for (var i = 0; i < 40; i++) {
            await tester.pump(const Duration(milliseconds: 16));
            seen.add(scale());
          }
          // It settles on its size.
          expect(seen.last, moreOrLessEquals(1, epsilon: .01));
        }
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('with reduced motion the mark simply appears', (tester) async {
      var checked = false;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpMenu(
        tester,
        items: (setState) => [
          MenuCheckboxItem(
            checked: checked,
            onChanged: (value) => setState(() => checked = value),
            child: const Text('Grid'),
          ),
        ],
      );
      await tester.tap(find.text('Grid'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(check('Grid'), findsOneWidget);
      final scale = tester
          .widget<Transform>(
            find
                .ancestor(of: check('Grid'), matching: find.byType(Transform))
                .first,
          )
          .transform
          .storage[0];
      expect(scale, 1);
    });
  });

  group('MenubarItem', () {
    testWidgets('takes a leading and a trailing widget, can be disabled, '
        'and hands its focus node to the trigger', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        FinesseApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: Menubar(
              items: [
                MenubarItem(
                  focusNode: node,
                  leading: const PhosphorIcon(PhosphorIconsRegular.file),
                  trailing: const PhosphorIcon(PhosphorIconsRegular.caretDown),
                  items: [
                    MenuCheckboxItem(
                      checked: true,
                      onChanged: (_) {},
                      child: const Text('Autosave'),
                    ),
                    const MenuDivider(),
                    const MenuItem(child: Text('Close')),
                  ],
                  child: const Text('File'),
                ),
                const MenubarItem(
                  enabled: false,
                  items: [MenuItem(child: Text('Never'))],
                  child: Text('Window'),
                ),
              ],
            ),
          ),
        ),
      );
      final file = tester.getRect(find.text('File'));
      expect(
        tester.getRect(find.byIcon(PhosphorIconsRegular.file)).right,
        lessThanOrEqualTo(file.left),
      );
      expect(
        tester.getRect(find.byIcon(PhosphorIconsRegular.caretDown)).left,
        greaterThanOrEqualTo(file.right),
      );

      // A disabled trigger opens nothing.
      await tester.tap(find.text('Window'), warnIfMissed: false);
      await settle(tester);
      expect(find.text('Never'), findsNothing);

      // Focusing the trigger through its node opens its menu, with the
      // rows a menu takes anywhere else.
      node.requestFocus();
      await settle(tester);
      expect(find.text('Autosave'), findsOneWidget);
      expect(find.byType(MenuDivider), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Close')).dx,
        tester.getTopLeft(find.text('Autosave')).dx,
      );
    });
  });
}
