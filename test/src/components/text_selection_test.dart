import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _text = 'The quick brown fox jumps';

Widget _app(
  Widget child, {
  ThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  bool disableAnimations = false,
}) {
  return FinesseApp(
    theme: theme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: Directionality(
          textDirection: textDirection,
          child: Center(child: SizedBox(width: 320, child: child)),
        ),
      ),
    ),
  );
}

/// The painters of the selection handles on screen.
Finder _handles() => find.byWidgetPredicate(
  (w) => w is CustomPaint && '${w.painter.runtimeType}' == '_HandlePainter',
);

Future<void> _longPress(WidgetTester tester, Offset at) async {
  final gesture = await tester.startGesture(at);
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  await gesture.up();
  // The toolbar's entrance.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Where the [index]th character of the field's text is drawn.
Offset _charAt(WidgetTester tester, int index) {
  final editable = tester
      .state<EditableTextState>(find.byType(EditableText))
      .renderEditable;
  final rect = editable.getLocalRectForCaret(TextPosition(offset: index));
  return editable.localToGlobal(rect.center + const Offset(3, 0));
}

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('controls', () {
    test('adaptive follows the platform', () {
      for (final platform in TargetPlatform.values) {
        debugDefaultTargetPlatformOverride = platform;
        final touch =
            platform == TargetPlatform.iOS ||
            platform == TargetPlatform.android ||
            platform == TargetPlatform.fuchsia;
        expect(
          FinesseTextSelectionControls.adaptive,
          touch ? same(finesseTextSelectionControls) : isNull,
          reason: '$platform',
        );
        expect(FinesseTextSelectionControls.usesTouchSelection, touch);
      }
      debugDefaultTargetPlatformOverride = null;
    });

    test('handle geometry: the anchor is on the stem', () {
      final controls = FinesseTextSelectionControls();
      const line = 20.0;
      final size = controls.getHandleSize(line);
      expect(size.height, greaterThan(line));
      for (final type in TextSelectionHandleType.values) {
        // Horizontally the anchor is the middle of the handle, whatever
        // its type: the stem is centred under (or over) its dot.
        expect(controls.getHandleAnchor(type, line).dx, size.width / 2);
      }
      // The start handle carries its dot above the line: its box ends at
      // the bottom of the selection.
      expect(
        controls.getHandleAnchor(TextSelectionHandleType.left, line).dy,
        size.height,
      );
      // The end handle's dot hangs below: its stem is the line's height.
      expect(
        controls.getHandleAnchor(TextSelectionHandleType.right, line).dy,
        line,
      );
      // The collapsed handle starts under the caret.
      expect(
        controls.getHandleAnchor(TextSelectionHandleType.collapsed, line).dy,
        lessThan(0),
      );
    });
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    group('$platform', () {
      testWidgets('a long press selects a word and shows handles and the '
          'horizontal toolbar above the selection', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        final controller = TextEditingController(text: _text);
        addTearDown(controller.dispose);
        await tester.pumpWidget(_app(TextField(controller: controller)));

        await _longPress(tester, _charAt(tester, 5));

        expect(controller.selection.isCollapsed, isFalse);
        expect(
          controller.selection.textInside(_text),
          'quick',
        );
        // A start and an end handle, in the theme's tint.
        expect(_handles(), findsNWidgets(2));
        final theme = Theme.of(tester.element(find.byType(TextField)));
        for (final paint in tester.widgetList<CustomPaint>(_handles())) {
          expect(
            (paint.painter! as dynamic).color,
            theme.textSelectionTheme.handleColor,
          );
        }
        expect(theme.textSelectionTheme.handleColor, theme.colorScheme.tint);

        // The toolbar, not the desktop's vertical menu.
        expect(find.byType(TextSelectionToolbar), findsOneWidget);
        expect(find.byType(ContextMenu), findsNothing);
        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('Cut'), findsOneWidget);

        // It is a row, and it sits above the field's text.
        final copy = tester.getRect(find.text('Copy'));
        final cut = tester.getRect(find.text('Cut'));
        expect(copy.center.dy, moreOrLessEquals(cut.center.dy, epsilon: 1));
        final field = tester.getRect(find.byType(EditableText));
        final toolbar = tester.getRect(
          find.descendant(
            of: find.byType(TextSelectionToolbar),
            matching: find.byType(Surface),
          ),
        );
        expect(toolbar.bottom, lessThanOrEqualTo(field.top));
        expect(
          toolbar.height,
          theme.textSelectionTheme.toolbarHeight,
        );

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('Copy copies, hides the toolbar and keeps the focus', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String?;
            }
            if (call.method == 'Clipboard.getData') {
              return {'text': copied ?? ''};
            }
            if (call.method == 'Clipboard.hasStrings') {
              return {'value': copied != null};
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final controller = TextEditingController(text: _text);
        final focusNode = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focusNode.dispose);
        await tester.pumpWidget(
          _app(TextField(controller: controller, focusNode: focusNode)),
        );
        await _longPress(tester, _charAt(tester, 5));
        expect(focusNode.hasFocus, isTrue);

        await tester.tap(find.text('Copy'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(copied, 'quick');
        expect(find.byType(TextSelectionToolbar), findsNothing);
        expect(focusNode.hasFocus, isTrue);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('the magnifier shows while a handle is dragged', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        final controller = TextEditingController(text: _text);
        addTearDown(controller.dispose);
        await tester.pumpWidget(_app(TextField(controller: controller)));
        await _longPress(tester, _charAt(tester, 5));
        expect(find.byType(TextMagnifier), findsNothing);

        // The end handle: the later of the two on the line.
        final rects = [
          for (final e in _handles().evaluate())
            tester.getRect(find.byWidget(e.widget)),
        ]..sort((a, b) => a.center.dx.compareTo(b.center.dx));
        final end = rects.last;
        final gesture = await tester.startGesture(
          Offset(end.center.dx, end.bottom - 4),
        );
        await tester.pump();
        await gesture.moveBy(const Offset(20, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(20, 0));
        await tester.pump();

        expect(find.byType(TextMagnifier), findsOneWidget);
        expect(find.byType(RawMagnifier), findsOneWidget);
        final lens = tester.getRect(find.byType(RawMagnifier));
        final theme = Theme.of(tester.element(find.byType(TextField)));
        expect(lens.size, theme.textSelectionTheme.magnifierSize);
        // Above the line being edited, and on screen.
        final field = tester.getRect(find.byType(EditableText));
        expect(lens.bottom, lessThanOrEqualTo(field.top + 2));
        expect(lens.top, greaterThanOrEqualTo(0));
        // The selection grew with the drag.
        expect(controller.selection.end, greaterThan(9));

        await gesture.up();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(TextMagnifier), findsNothing);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('a tap in a field with text shows the caret handle', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        final controller = TextEditingController(text: _text);
        addTearDown(controller.dispose);
        await tester.pumpWidget(_app(TextField(controller: controller)));
        await tester.tapAt(_charAt(tester, 5));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(controller.selection.isCollapsed, isTrue);
        expect(_handles(), findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('Textarea gets the same controls', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        final controller = TextEditingController(text: _text);
        addTearDown(controller.dispose);
        await tester.pumpWidget(_app(Textarea(controller: controller)));
        await _longPress(tester, _charAt(tester, 5));
        expect(_handles(), findsNWidgets(2));
        expect(find.byType(TextSelectionToolbar), findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
      });
    });
  }

  testWidgets('on a desktop there are no handles and the menu is vertical', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final controller = TextEditingController(text: _text);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(TextField(controller: controller)));

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.selectionControls, isNull);

    await tester.tapAt(
      _charAt(tester, 5),
      buttons: kSecondaryButton,
      kind: PointerDeviceKind.mouse,
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(TextSelectionToolbar), findsNothing);
    expect(find.byType(ContextMenu), findsWidgets);
    expect(_handles(), findsNothing);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('explicit controls, magnifier and menu win over the defaults', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    await tester.pumpWidget(
      _app(
        TextField(
          initialValue: _text,
          selectionControls: finesseTextSelectionControls,
          magnifierConfiguration: TextMagnifierConfiguration.disabled,
        ),
      ),
    );
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.selectionControls, same(finesseTextSelectionControls));
    expect(
      editable.magnifierConfiguration,
      same(TextMagnifierConfiguration.disabled),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  group('toolbar', () {
    Widget toolbar({
      required Offset above,
      Offset? below,
      int actions = 3,
      VoidCallback? onFirst,
    }) {
      return TextSelectionToolbar(
        anchorAbove: above,
        anchorBelow: below ?? above + const Offset(0, 24),
        children: [
          for (var i = 0; i < actions; i++)
            TextSelectionToolbarButton(
              onPressed: i == 0 ? onFirst ?? () {} : () {},
              child: Text('Action $i'),
            ),
        ],
      );
    }

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('goes below the selection when there is no room above', (
      tester,
    ) async {
      await tester.pumpWidget(
        FinesseApp(home: toolbar(above: const Offset(400, 20))),
      );
      await settle(tester);
      final rect = tester.getRect(find.byType(Surface));
      expect(rect.top, greaterThan(20 + 24));
      expect(rect.center.dx, moreOrLessEquals(400, epsilon: 1));
    });

    testWidgets('stays on screen near an edge', (tester) async {
      await tester.pumpWidget(
        FinesseApp(home: toolbar(above: const Offset(4, 300))),
      );
      await settle(tester);
      final rect = tester.getRect(find.byType(Surface));
      expect(rect.left, greaterThanOrEqualTo(8));
      expect(rect.bottom, lessThanOrEqualTo(300));
    });

    testWidgets('pages when the actions do not fit, and pages back', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        FinesseApp(home: toolbar(above: const Offset(180, 300), actions: 8)),
      );
      await settle(tester);

      Finder shown(String text) => find.text(text).hitTestable();
      expect(shown('Action 0'), findsOneWidget);
      expect(shown('Action 7'), findsNothing);
      final surface = tester.getRect(find.byType(Surface));
      expect(surface.width, lessThanOrEqualTo(360 - 16));

      // Walk to the last page.
      final more = find.bySemanticsLabel('More');
      var pages = 0;
      while (more.hitTestable().evaluate().isNotEmpty && pages < 8) {
        await tester.tap(more.hitTestable());
        await tester.pump();
        pages++;
      }
      expect(pages, greaterThan(0));
      expect(shown('Action 7'), findsOneWidget);
      expect(shown('Action 0'), findsNothing);

      // And back to the first.
      final back = find.bySemanticsLabel('Back');
      for (var i = 0; i < pages; i++) {
        await tester.tap(back.hitTestable());
        await tester.pump();
      }
      expect(shown('Action 0'), findsOneWidget);
      expect(back.hitTestable(), findsNothing);
    });

    testWidgets('every action is reachable across the pages', (tester) async {
      tester.view.physicalSize = const Size(300, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        FinesseApp(home: toolbar(above: const Offset(150, 300), actions: 7)),
      );
      await settle(tester);
      final seen = <String>{};
      final more = find.bySemanticsLabel('More');
      for (var page = 0; page < 8; page++) {
        for (var i = 0; i < 7; i++) {
          if (find.text('Action $i').hitTestable().evaluate().isNotEmpty) {
            seen.add('Action $i');
          }
        }
        if (more.hitTestable().evaluate().isEmpty) break;
        await tester.tap(more.hitTestable());
        await tester.pump();
      }
      expect(seen, hasLength(7));
    });

    testWidgets('is mirrored in a right-to-left locale', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: toolbar(above: const Offset(400, 300)),
          ),
        ),
      );
      await settle(tester);
      expect(
        tester.getCenter(find.text('Action 0')).dx,
        greaterThan(tester.getCenter(find.text('Action 2')).dx),
      );
    });

    testWidgets('grows with the text scale instead of clipping', (
      tester,
    ) async {
      await tester.pumpWidget(
        FinesseApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: toolbar(above: const Offset(400, 300)),
            ),
          ),
        ),
      );
      await settle(tester);
      final surface = tester.getRect(find.byType(Surface));
      final label = tester.getRect(find.text('Action 0'));
      expect(surface.top, lessThanOrEqualTo(label.top));
      expect(surface.bottom, greaterThanOrEqualTo(label.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a press runs the action and does not take the focus', (
      tester,
    ) async {
      var pressed = 0;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        FinesseApp(
          home: Stack(
            children: [
              Focus(
                focusNode: focusNode,
                autofocus: true,
                child: const SizedBox(width: 10, height: 10),
              ),
              toolbar(above: const Offset(400, 300), onFirst: () => pressed++),
            ],
          ),
        ),
      );
      await settle(tester);
      expect(focusNode.hasPrimaryFocus, isTrue);
      await tester.tap(find.text('Action 0'));
      await tester.pump();
      expect(pressed, 1);
      expect(focusNode.hasPrimaryFocus, isTrue);
    });

    testWidgets('settles, and appears at once without motion', (tester) async {
      await tester.pumpWidget(
        FinesseApp(home: toolbar(above: const Offset(400, 300))),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(motion: Motion.none),
          home: toolbar(above: const Offset(400, 300)),
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('Action 0').hitTestable(), findsOneWidget);
    });

    testWidgets('the standard actions are localized, custom ones named', (
      tester,
    ) async {
      await tester.pumpWidget(
        FinesseApp(
          home: TextSelectionToolbar.buttonItems(
            anchors: const TextSelectionToolbarAnchors(
              primaryAnchor: Offset(400, 300),
            ),
            buttonItems: [
              ContextMenuButtonItem(
                onPressed: () {},
                type: ContextMenuButtonType.lookUp,
              ),
              ContextMenuButtonItem(onPressed: () {}, label: 'Translate'),
              // No label and no standard type: left out.
              ContextMenuButtonItem(onPressed: () {}),
            ],
          ),
        ),
      );
      await settle(tester);
      expect(find.text('Look Up'), findsOneWidget);
      expect(find.text('Translate'), findsOneWidget);
      expect(find.byType(TextSelectionToolbarButton), findsNWidgets(4));
    });

    testWidgets('the theme restyles it', (tester) async {
      const dividerColor = Color(0xFFFF0000);
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(
            textSelectionTheme: const TextSelectionTheme(
              toolbarHeight: 56,
              toolbarDividerColor: dividerColor,
              handleColor: Color(0xFF00FF00),
            ),
          ),
          home: toolbar(above: const Offset(400, 300)),
        ),
      );
      await settle(tester);
      expect(tester.getSize(find.byType(Surface)).height, 56);
      final theme = Theme.of(tester.element(find.byType(Surface)));
      expect(theme.textSelectionTheme.handleColor, const Color(0xFF00FF00));
      // Untouched fields keep the variant's values.
      expect(theme.textSelectionTheme.magnifierScale, 1.25);
    });
  });

  group('theme', () {
    test('is a value: built twice it is equal, shadows by value', () {
      final a = ThemeData();
      final b = ThemeData();
      expect(a.textSelectionTheme, b.textSelectionTheme);
      expect(a.textSelectionTheme.hashCode, b.textSelectionTheme.hashCode);
      expect(a, b);

      const shadow = BoxShadow(blurRadius: 4);
      // Two lists, equal by value.
      final one = TextSelectionTheme(magnifierShadows: [shadow]);
      final two = TextSelectionTheme(magnifierShadows: [shadow]);
      expect(one, two);
      expect(one.hashCode, two.hashCode);
      expect(one, isNot(const TextSelectionTheme(magnifierShadows: [])));
    });

    test('copyWith re-derives it and keeps an override', () {
      final theme = ThemeData(
        textSelectionTheme: const TextSelectionTheme(handleSize: 16),
      );
      expect(theme.textSelectionTheme.handleSize, 16);
      final dark = theme.copyWith(
        colorScheme: const TealColorScheme.dark(),
        brightness: Brightness.dark,
      );
      expect(dark.textSelectionTheme.handleSize, 16);
      expect(dark.textSelectionTheme.handleColor, dark.colorScheme.tint);
      expect(
        dark.textSelectionTheme.handleColor,
        isNot(theme.textSelectionTheme.handleColor),
      );
    });

    test('every style gives the toolbar a touch-sized height', () {
      for (final style in [
        StyleTokens.finesse,
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        for (final formFactor in FormFactor.values) {
          final theme = ThemeData(
            style: style,
          ).withFormFactor(formFactor);
          expect(
            theme.textSelectionTheme.toolbarHeight,
            greaterThanOrEqualTo(40),
          );
          expect(theme.textSelectionTheme.handleColor, isNotNull);
        }
      }
    });

    test('lerps', () {
      final a = ThemeData().textSelectionTheme;
      final b = a.copyWith(handleSize: 20, toolbarHeight: 60);
      final mid = TextSelectionTheme.lerp(a, b, .5)!;
      expect(mid.handleSize, 16);
      expect(mid.toolbarHeight, (a.toolbarHeight! + 60) / 2);
    });
  });

  group('SelectionArea', () {
    testWidgets('touch: a long press selects a word, with handles and the '
        'toolbar; Copy reports the selection', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      SelectedContent? selected;
      await tester.pumpWidget(
        _app(
          SelectionArea(
            onSelectionChanged: (content) => selected = content,
            child: const Text(_text),
          ),
        ),
      );
      final text = tester.getRect(find.text(_text));
      await _longPress(tester, text.centerLeft + const Offset(40, 0));

      expect(selected?.plainText, isNotEmpty);
      expect(find.byType(TextSelectionToolbar), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(_handles(), findsNWidgets(2));

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('desktop: no handles, and a right-click opens the menu', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await tester.pumpWidget(
        _app(const SelectionArea(child: Text(_text))),
      );
      final text = tester.getRect(find.text(_text));
      // Select a word with a double click, then right-click it.
      final at = text.centerLeft + const Offset(40, 0);
      await tester.tapAt(at, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(at, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tapAt(
        at,
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(_handles(), findsNothing);
      expect(find.byType(TextSelectionToolbar), findsNothing);
      expect(find.byType(ContextMenu), findsWidgets);
      expect(find.text('Copy'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('the state exposes the region', (tester) async {
      final key = GlobalKey<SelectionAreaState>();
      SelectedContent? selected;
      await tester.pumpWidget(
        _app(
          SelectionArea(
            key: key,
            onSelectionChanged: (content) => selected = content,
            child: const Text(_text),
          ),
        ),
      );
      key.currentState!.selectableRegion.selectAll();
      await tester.pump();
      expect(selected?.plainText, _text);
    });
  });
}
