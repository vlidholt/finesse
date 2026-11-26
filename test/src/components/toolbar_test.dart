import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../decoration_finders.dart';
import '../../una_harness.dart';

/// [Toolbar]: a bar of actions with the bottom navigation bar's surface.
Widget _toolbar({
  bool? floating,
  ValueChanged<String>? onPressed,
  Widget? leading,
  Widget? trailing,
  MainAxisAlignment alignment = MainAxisAlignment.spaceBetween,
}) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Toolbar(
      floating: floating,
      leading: leading,
      trailing: trailing,
      alignment: alignment,
      children: [
        for (final name in ['Archive', 'Flag', 'Delete'])
          IconButton.ghost(
            key: ValueKey(name),
            icon: const PhosphorIcon(PhosphorIconsRegular.archive),
            semanticLabel: name,
            onPressed: () => onPressed?.call(name),
          ),
      ],
    ),
  );
}

void main() {
  testWidgets('builds in every layout and style', (tester) async {
    for (final style in [
      StyleTokens.fluid,
      StyleTokens.crisp,
      StyleTokens.pebble,
      StyleTokens.sharp,
    ]) {
      for (final layout in kLayouts) {
        await pumpUna(
          tester,
          _toolbar(trailing: const Button(child: Text('Reply'))),
          formFactor: layout.formFactor,
          textDirection: layout.textDirection,
          theme: ThemeData(style: style),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('floating, it is a pill as wide as its actions with the '
      "bottom bar's fill, margin and shadow", (tester) async {
    await pumpUna(
      tester,
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Toolbar(
            floating: true,
            children: [
              for (final name in ['A', 'B', 'C'])
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.archive),
                  semanticLabel: name,
                  onPressed: () {},
                ),
            ],
          ),
          const BottomNavigationBar(
            floating: true,
            selectedIndex: 0,
            destinations: [
              NavigationDestination(
                icon: PhosphorIcon(PhosphorIconsRegular.house),
                label: 'Home',
              ),
              NavigationDestination(
                icon: PhosphorIcon(PhosphorIconsRegular.user),
                label: 'Me',
              ),
            ],
          ),
        ],
      ),
      formFactor: FormFactor.mobile,
    );
    final theme = Theme.of(tester.element(find.byType(Toolbar)));
    final bar = theme.bottomNavigationBarTheme;
    BoxDecoration surface(Type type) => tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(type),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .first;
    final toolbar = surface(Toolbar);
    final navigation = surface(BottomNavigationBar);
    // One surface, two bars.
    expect(toolbar.color, bar.backgroundColor);
    expect(toolbar.color, navigation.color);
    expect(toolbar.borderRadius, navigation.borderRadius);
    expect(toolbar.border, navigation.border);
    // As tall as the navigation bar, and no wider than what is in it.
    expect(
      tester.getSize(find.byType(Toolbar)).height,
      tester.getSize(find.byType(BottomNavigationBar)).height,
    );
    final pill = tester.getRect(
      find
          .descendant(
            of: find.byType(Toolbar),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(pill.width, lessThan(260));
    expect(pill.center.dx, 195);
    // Its shadow is the floating one, outside the glass.
    final shadow = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(Toolbar),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => shadowsOf(box.decoration))
        .nonNulls
        .firstWhere((shadows) => shadows.isNotEmpty);
    expect(shadow, bar.shadows ?? theme.style.floatingShadow);
  });

  testWidgets('docked, it spans the width under a hairline; leading and '
      'trailing stand at the ends, in both directions', (tester) async {
    for (final direction in TextDirection.values) {
      await pumpUna(
        tester,
        _toolbar(
          floating: false,
          leading: const Text('3', key: Key('leading')),
          trailing: const Button(key: Key('trailing'), child: Text('Go')),
          alignment: MainAxisAlignment.center,
        ),
        formFactor: FormFactor.mobile,
        textDirection: direction,
      );
      final bar = tester.getRect(find.byType(Toolbar));
      expect(bar.width, 390);
      expect(bar.bottom, 844);
      final leading = tester.getRect(find.byKey(const Key('leading')));
      final trailing = tester.getRect(find.byKey(const Key('trailing')));
      final middle = tester.getRect(find.byKey(const ValueKey('Flag')));
      final ltr = direction == TextDirection.ltr;
      expect(ltr ? leading.left : trailing.left, lessThan(40));
      expect(ltr ? trailing.right : leading.right, greaterThan(350));
      // Centred in what is left between the two.
      final between = ltr
          ? (leading.right + trailing.left) / 2
          : (trailing.right + leading.left) / 2;
      expect(middle.center.dx, moreOrLessEquals(between, epsilon: 1));
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('heightOf is what it takes, and it keeps clear of the bottom '
      'safe area', (tester) async {
    for (final floating in [true, false]) {
      late double estimate;
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(bottom: 34),
          ),
          child: Builder(
            builder: (context) {
              estimate = Toolbar.heightOf(context);
              return _toolbar();
            },
          ),
        ),
        formFactor: FormFactor.mobile,
        theme: ThemeData(
          bottomNavigationBarTheme: BottomNavigationBarTheme(
            floating: floating,
          ),
        ),
      );
      final bar = tester.getRect(find.byType(Toolbar));
      expect(bar.height, moreOrLessEquals(estimate, epsilon: .01));
      final button = tester.getRect(find.byKey(const ValueKey('Flag')));
      expect(button.bottom, lessThanOrEqualTo(844 - 34));
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('a Scaffold takes it as its bottom bar and the page clears '
      'it', (tester) async {
    await pumpUna(
      tester,
      Scaffold(
        bottomNavigationBar: Toolbar(
          children: [
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.archive),
              semanticLabel: 'Archive',
              onPressed: () {},
            ),
          ],
        ),
        body: ListView(
          children: [
            for (var i = 0; i < 30; i++)
              SizedBox(key: Key('row$i'), height: 50),
          ],
        ),
      ),
      formFactor: FormFactor.mobile,
    );
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const Key('row29'))).bottom,
      tester.getRect(find.byType(Toolbar)).top,
    );
  });

  testWidgets('its actions act, and the arrow keys move the focus along '
      'it', (tester) async {
    final pressed = <String>[];
    await pumpUna(tester, _toolbar(onPressed: pressed.add));
    await tester.tap(find.byKey(const ValueKey('Flag')));
    expect(pressed, ['Flag']);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pressed, ['Flag', 'Delete', 'Flag']);
  });

  testWidgets('plain icons and text take the colour and size of the bar, and '
      'each action is its own node for a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: Toolbar(
          leading: const Text('Draft saved'),
          children: [
            const PhosphorIcon(PhosphorIconsRegular.cloudCheck),
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.trash),
              semanticLabel: 'Discard',
              onPressed: () {},
            ),
          ],
        ),
      ),
      formFactor: FormFactor.mobile,
    );
    final theme = Theme.of(tester.element(find.byType(Toolbar)));
    final icon = IconTheme.of(
      tester.element(find.byIcon(PhosphorIconsRegular.cloudCheck)),
    );
    expect(icon.size, theme.bottomNavigationBarTheme.iconSize);
    expect(icon.color, theme.bottomNavigationBarTheme.foregroundColor);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Draft saved'))).style.color,
      theme.colorScheme.foreground,
    );
    expect(find.bySemanticsLabel('Discard'), findsOneWidget);
    expect(find.bySemanticsLabel('Draft saved'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('grows with what is in it at a text scale of two', (
    tester,
  ) async {
    await pumpUna(
      tester,
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          textScaler: TextScaler.linear(2),
        ),
        child: _toolbar(
          floating: false,
          trailing: const Button(key: Key('reply'), child: Text('Go')),
        ),
      ),
      formFactor: FormFactor.mobile,
    );
    expect(tester.takeException(), isNull);
    final bar = tester.getRect(find.byType(Toolbar));
    final button = tester.getRect(find.byKey(const Key('reply')));
    expect(button.top, greaterThanOrEqualTo(bar.top));
    expect(button.bottom, lessThanOrEqualTo(bar.bottom));
  });

  testWidgets("on a floating pill a button takes the pill's curve; docked, "
      'its own corners', (tester) async {
    BorderRadiusGeometry? radiusOf() => tester
        .widget<Decorator>(
          find
              .descendant(
                of: find.widgetWithText(Button, 'Reply'),
                matching: find.byType(Decorator),
              )
              .first,
        )
        .decoration!
        .border
        ?.borderRadius;

    await pumpUna(
      tester,
      _toolbar(
        floating: true,
        trailing: Button(onPressed: () {}, child: const Text('Reply')),
      ),
      formFactor: FormFactor.mobile,
    );
    final theme = ThemeData();
    expect(radiusOf(), theme.radii.full);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpUna(
      tester,
      _toolbar(
        floating: false,
        trailing: Button(onPressed: () {}, child: const Text('Reply')),
      ),
      formFactor: FormFactor.mobile,
    );
    expect(radiusOf(), isNot(theme.radii.full));
  });
}
