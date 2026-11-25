import 'dart:ui' show Tristate;

import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `Button(loading:)`, `IconButton(loading:)` and `IconButton(tooltip:)`.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    ThemeData? theme,
    double textScale = 1,
    Size size = const Size(800, 400),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinesseApp(
        theme: theme,
        darkTheme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Center(child: child),
      ),
    );
  }

  /// Pumps fixed frames: a spinner never settles.
  Future<List<Size>> frames(
    WidgetTester tester,
    Finder of, {
    int count = 30,
  }) async {
    final sizes = <Size>[];
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      sizes.add(tester.getSize(of));
    }
    return sizes;
  }

  double opacityOf(WidgetTester tester, Finder finder) {
    var opacity = 1.0;
    RenderObject? node = tester.renderObject(finder);
    while (node != null) {
      if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
      if (node is RenderOpacity) opacity *= node.opacity;
      node = node.parent;
    }
    return opacity;
  }

  group('Button(loading:)', () {
    for (final (name, leading) in <(String, Widget?)>[
      ('a label alone', null),
      ('a leading icon', const PhosphorIcon(PhosphorIconsRegular.floppyDisk)),
    ]) {
      testWidgets('$name: the button is the same size on every frame of the '
          'way in and out, and the spinner is gone afterwards', (tester) async {
        var loading = false;
        late StateSetter rebuild;
        await pump(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return Button(
                loading: loading,
                leading: leading,
                onPressed: () {},
                child: const Text('Save changes'),
              );
            },
          ),
        );
        final button = find.byType(Button);
        final rest = tester.getSize(button);
        final label = tester.getRect(find.text('Save changes'));
        expect(find.byType(Spinner), findsNothing);

        rebuild(() => loading = true);
        expect(await frames(tester, button), everyElement(rest));
        expect(find.byType(Spinner), findsOneWidget);
        // The label has not moved, whether or not it still shows.
        expect(tester.getRect(find.text('Save changes')), label);
        final spinner = tester.getRect(find.byType(Spinner));
        if (leading == null) {
          // Over the label, which is out of sight.
          expect(spinner.center.dx, moreOrLessEquals(label.center.dx));
          expect(opacityOf(tester, find.text('Save changes')), 0);
        } else {
          // In the icon's place, beside a label that still reads.
          final icon = tester.getRect(find.bySubtype<Icon>());
          expect(spinner.center, icon.center);
          expect(opacityOf(tester, find.bySubtype<Icon>()), 0);
          expect(opacityOf(tester, find.text('Save changes')), 1);
        }

        rebuild(() => loading = false);
        expect(await frames(tester, button), everyElement(rest));
        expect(find.byType(Spinner), findsNothing);
        expect(opacityOf(tester, find.text('Save changes')), 1);
        // Nothing is left running.
        await tester.pumpAndSettle();
        expect(tester.binding.hasScheduledFrame, isFalse);
      });
    }

    testWidgets('the swap fades and pops rather than snapping, also the '
        'first time', (tester) async {
      var loading = false;
      late StateSetter rebuild;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Button(
              loading: loading,
              onPressed: () {},
              child: const Text('Save'),
            );
          },
        ),
      );
      rebuild(() => loading = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 40));
      expect(opacityOf(tester, find.text('Save')), inExclusiveRange(0, 1));
      await frames(tester, find.byType(Button));
      expect(opacityOf(tester, find.text('Save')), 0);
    });

    testWidgets('a loading button ignores presses, by pointer and by '
        'keyboard, keeps the focus and does not dim', (tester) async {
      var presses = 0;
      var loading = false;
      late StateSetter rebuild;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Button(
              focusNode: focusNode,
              loading: loading,
              onPressed: () => presses++,
              onLongPress: () => presses += 10,
              child: const Text('Save'),
            );
          },
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(presses, 1);

      rebuild(() => loading = true);
      await frames(tester, find.byType(Button));
      expect(focusNode.hasFocus, isTrue);
      await tester.tap(find.byType(Button));
      await tester.longPress(find.byType(Button));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(presses, 1);
      // Busy, not disabled.
      expect(
        tester
            .widget<Opacity>(
              find
                  .descendant(
                    of: find.byType(Button),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        1,
      );

      rebuild(() => loading = false);
      await frames(tester, find.byType(Button));
      await tester.tap(find.byType(Button));
      expect(presses, 2);
    });

    testWidgets('a loading button shows no hover and the plain cursor', (
      tester,
    ) async {
      await pump(
        tester,
        Button.outline(
          loading: true,
          onPressed: () {},
          child: const Text('Save'),
        ),
      );
      await frames(tester, find.byType(Button));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(Button)));
      await frames(tester, find.byType(Button));
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.basic,
      );
      final theme = Theme.of(tester.element(find.byType(Button)));
      final decorator = tester.widget<Decorator>(
        find.descendant(
          of: find.byType(Button),
          matching: find.byType(Decorator),
        ),
      );
      expect(
        decorator.decoration!.color,
        theme.outlineButtonTheme.backgroundColor,
      );
    });

    testWidgets('assistive technology is told it is busy', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        Button(loading: true, onPressed: () {}, child: const Text('Save')),
      );
      await frames(tester, find.byType(Button));
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      // The button's own node says it cannot be pressed now.
      SemanticsNode? node = tester.getSemantics(find.text('Save'));
      while (node != null && !node.flagsCollection.isButton) {
        node = node.parent;
      }
      expect(node, isNotNull);
      expect(node!.flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('the height is still a floor under a larger text size', (
      tester,
    ) async {
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await pump(
          tester,
          Button(
            loading: true,
            leading: const PhosphorIcon(PhosphorIconsRegular.floppyDisk),
            onPressed: () {},
            child: const Text('Save'),
          ),
          textScale: scale,
        );
        await frames(tester, find.byType(Button));
        expect(tester.takeException(), isNull);
        final theme = Theme.of(tester.element(find.byType(Button)));
        final height = tester.getSize(find.byType(Button)).height;
        final floor = theme.buttonSizesTheme.regular!.height;
        if (scale == 1) {
          expect(height, floor);
        } else {
          expect(height, greaterThanOrEqualTo(floor));
          expect(
            tester.getSize(find.text('Save')).height,
            lessThanOrEqualTo(height),
          );
        }
      }
    });

    testWidgets('with no motion the swap is immediate and nothing asserts', (
      tester,
    ) async {
      var loading = false;
      late StateSetter rebuild;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Button(
              loading: loading,
              onPressed: () {},
              child: const Text('Save'),
            );
          },
        ),
        theme: ThemeData(motion: Motion.none),
      );
      rebuild(() => loading = true);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(Spinner), findsOneWidget);
      expect(opacityOf(tester, find.text('Save')), 0);
      rebuild(() => loading = false);
      await tester.pump();
      await tester.pump();
      expect(find.byType(Spinner), findsNothing);
    });
  });

  group('IconButton', () {
    testWidgets('loading: the spinner takes the place of the icon in a '
        'button that stays square', (tester) async {
      var loading = false;
      late StateSetter rebuild;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return IconButton.outline(
              loading: loading,
              tooltip: 'Refresh',
              onPressed: () {},
              icon: const PhosphorIcon(PhosphorIconsRegular.arrowsClockwise),
            );
          },
        ),
      );
      final rest = tester.getSize(find.byType(IconButton));
      expect(rest.width, rest.height);
      rebuild(() => loading = true);
      expect(await frames(tester, find.byType(IconButton)), everyElement(rest));
      expect(
        tester.getCenter(find.byType(Spinner)),
        tester.getCenter(find.byType(IconButton)),
      );
      expect(opacityOf(tester, find.bySubtype<Icon>()), 0);
    });

    testWidgets('tooltip: shown on hover and on focus, and it names the '
        'button for assistive technology — which can still press it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pump(
        tester,
        IconButton.ghost(
          focusNode: focusNode,
          tooltip: 'Archive',
          onPressed: () => presses++,
          icon: const PhosphorIcon(PhosphorIconsRegular.archive),
        ),
      );
      expect(find.text('Archive'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Archive')),
        matchesSemantics(
          label: 'Archive',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('Archive'));
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      expect(presses, 1);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(IconButton)));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Archive'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Archive'), findsNothing);

      focusNode.requestFocus();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Archive'), findsOneWidget);
      // The tap still goes to the button.
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(presses, 2);
      handle.dispose();
    });

    testWidgets('a semantic label of its own wins over the tooltip, and a '
        'loading button says so', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        IconButton(
          tooltip: 'Sync',
          semanticLabel: 'Synchronise the library',
          loading: true,
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowsClockwise),
        ),
      );
      await frames(tester, find.byType(IconButton));
      expect(find.bySemanticsLabel('Sync'), findsNothing);
      final data = tester
          .getSemantics(find.bySemanticsLabel(RegExp('Synchronise')))
          .getSemanticsData();
      expect(data.label, contains('Synchronise the library'));
      expect(data.value, 'Loading');
      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('without a tooltip nothing is added around the button', (
      tester,
    ) async {
      await pump(
        tester,
        IconButton(
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.archive),
        ),
      );
      expect(find.byType(Tooltip), findsNothing);
      expect(find.byType(MergeSemantics), findsNothing);
    });
  });
}
