import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

enum _Choice { save, share, mute, report }

class _Opened {
  Object? result = 'pending';
  final pressed = <_Choice>[];
}

List<ActionSheetAction<_Choice>> _actions(
  _Opened opened, {
  bool icons = false,
}) => [
  ActionSheetAction(
    value: _Choice.report,
    destructive: true,
    icon: icons ? const PhosphorIcon(PhosphorIconsRegular.flag) : null,
    label: const Text('Report'),
    onPressed: () => opened.pressed.add(_Choice.report),
  ),
  ActionSheetAction(
    value: _Choice.mute,
    enabled: false,
    label: const Text('Mute'),
    onPressed: () => opened.pressed.add(_Choice.mute),
  ),
  ActionSheetAction(
    value: _Choice.save,
    isDefault: true,
    label: const Text('Save'),
    onPressed: () => opened.pressed.add(_Choice.save),
  ),
  ActionSheetAction(
    value: _Choice.share,
    label: const Text('Share'),
    onPressed: () => opened.pressed.add(_Choice.share),
  ),
];

Future<_Opened> _open(
  WidgetTester tester, {
  FormFactor formFactor = FormFactor.mobile,
  TextDirection textDirection = TextDirection.ltr,
  Rect? anchorRect,
  bool showCancel = true,
  Widget? cancelLabel,
  bool icons = false,
  ThemeData? theme,
}) async {
  final opened = _Opened();
  await pumpFinesse(
    tester,
    Builder(
      builder: (context) => Align(
        alignment: Alignment.topLeft,
        child: Button(
          onPressed: () async {
            opened.result = await showActionSheet<_Choice>(
              context: context,
              title: const Text('Post by Maya'),
              message: const Text('Shared two hours ago'),
              anchorRect: anchorRect,
              showCancel: showCancel,
              cancelLabel: cancelLabel,
              actions: _actions(opened, icons: icons),
            );
          },
          child: const Text('Open'),
        ),
      ),
    ),
    formFactor: formFactor,
    textDirection: textDirection,
    theme: theme,
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return opened;
}

void main() {
  group('on a phone', () {
    testWidgets('is a sheet from the bottom with the actions as full-width '
        'rows and Cancel apart', (tester) async {
      await _open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      final sheet = tester.getRect(find.byType(ActionSheet<_Choice>));
      expect(sheet.width, greaterThan(380));
      expect(sheet.bottom, greaterThan(800));

      final save = tester.getRect(
        find.ancestor(
          of: find.text('Save'),
          matching: find.byType(Pressable),
        ),
      );
      final share = tester.getRect(
        find.ancestor(
          of: find.text('Share'),
          matching: find.byType(Pressable),
        ),
      );
      final cancel = tester.getRect(
        find.ancestor(
          of: find.text('Cancel'),
          matching: find.byType(Pressable),
        ),
      );
      // Touch targets, edge to edge within the sheet's padding.
      expect(save.height, greaterThanOrEqualTo(44));
      expect(save.width, greaterThan(360));
      // A hairline between two actions, a real gap before Cancel.
      expect(share.top - save.bottom, 1);
      expect(cancel.top - share.bottom, greaterThanOrEqualTo(8));
      // No close button: Cancel is the way out.
      expect(find.bySemanticsLabel('Close'), findsNothing);
    });

    testWidgets('completes with the chosen value, and runs the action once '
        'the sheet has closed', (tester) async {
      final opened = await _open(tester);
      await tester.tap(find.text('Share'));
      // Popped at once; the callback has already run, over the page.
      expect(opened.pressed, [_Choice.share]);
      await tester.pumpAndSettle();
      expect(opened.result, _Choice.share);
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('Cancel, the barrier, Escape and a drag all cancel', (
      tester,
    ) async {
      var opened = await _open(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(opened.result, isNull);
      expect(opened.pressed, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      opened = await _open(tester);
      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();
      expect(opened.result, isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      opened = await _open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(opened.result, isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      opened = await _open(tester);
      await tester.fling(
        find.text('Post by Maya'),
        const Offset(0, 120),
        1500,
      );
      await tester.pumpAndSettle();
      expect(opened.result, isNull);
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('a disabled action cannot be chosen', (tester) async {
      final opened = await _open(tester);
      await tester.tap(find.text('Mute'));
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(opened.pressed, isEmpty);
    });

    testWidgets('showCancel: false leaves the row out; cancelLabel renames '
        'it', (tester) async {
      await _open(tester, showCancel: false);
      expect(find.text('Cancel'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      final opened = await _open(tester, cancelLabel: const Text('Not now'));
      expect(find.text('Cancel'), findsNothing);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(opened.result, isNull);
    });

    testWidgets('the destructive action is in the destructive colour and '
        'the default one is heavier', (tester) async {
      await _open(tester);
      final theme = Theme.of(tester.element(find.byType(Sheet)));
      TextStyle styleOf(String label) => tester
          .widget<RichText>(
            find.descendant(
              of: find.text(label),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style!;
      expect(styleOf('Report').color, theme.colorScheme.destructive);
      expect(styleOf('Share').color, theme.colorScheme.foreground);
      expect(styleOf('Save').fontWeight, FontWeight.w600);
      expect(styleOf('Cancel').fontWeight, FontWeight.w600);
      expect(styleOf('Share').fontWeight, isNot(FontWeight.w600));
      // Disabled: the same ink, receding.
      expect(styleOf('Mute').color!.a, lessThan(.6));
    });

    testWidgets('labels are centred without icons and start beside them '
        'with icons', (tester) async {
      await _open(tester);
      final row = tester.getRect(
        find.ancestor(
          of: find.text('Share'),
          matching: find.byType(Pressable),
        ),
      );
      expect(
        tester.getCenter(find.text('Share')).dx,
        moreOrLessEquals(row.center.dx, epsilon: 1),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await _open(tester, icons: true);
      expect(tester.getTopLeft(find.text('Share')).dx, lessThan(80));
      expect(tester.getTopLeft(find.text('Report')).dx, lessThan(80));
    });

    testWidgets('twenty actions scroll instead of overflowing', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Builder(
          builder: (context) => Button(
            onPressed: () => showActionSheet<int>(
              context: context,
              title: const Text('Many'),
              actions: [
                for (var i = 0; i < 20; i++)
                  ActionSheetAction(value: i, label: Text('Action $i')),
              ],
            ),
            child: const Text('Open'),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Action 0'), findsOneWidget);
      // A strip of the page stays above it.
      expect(tester.getRect(find.byType(Sheet)).height, 844);
      final surface = tester.getRect(
        find
            .descendant(
              of: find.byType(Sheet),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(surface.top, greaterThan(30));
    });
  });

  group('keyboard', () {
    testWidgets('the first action that is neither destructive nor disabled '
        'has the focus; the arrows walk the rows and Enter chooses', (
      tester,
    ) async {
      final opened = await _open(tester);
      String? focusedLabel() {
        final context = FocusManager.instance.primaryFocus?.context;
        if (context == null) return null;
        for (final label in ['Report', 'Mute', 'Save', 'Share', 'Cancel']) {
          if (find
              .descendant(
                of: find.byWidget(context.widget),
                matching: find.text(label),
              )
              .evaluate()
              .isNotEmpty) {
            return label;
          }
        }
        return null;
      }

      expect(focusedLabel(), 'Save');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedLabel(), 'Share');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedLabel(), 'Cancel');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      // Up from Save skips the disabled row.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedLabel(), 'Report');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedLabel(), 'Save');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(opened.result, _Choice.save);
    });
  });

  group('on a desktop', () {
    testWidgets('without an anchor it is a small dialog', (tester) async {
      final opened = await _open(tester, formFactor: FormFactor.desktop);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(Sheet), findsNothing);
      final rect = tester.getRect(find.byType(ActionSheet<_Choice>));
      expect(rect.width, lessThanOrEqualTo(320));
      expect(rect.center.dx, moreOrLessEquals(640, epsilon: 1));
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(opened.result, _Choice.save);
      expect(opened.pressed, [_Choice.save]);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('with an anchor it is a menu under the rectangle', (
      tester,
    ) async {
      final opened = await _open(
        tester,
        formFactor: FormFactor.desktop,
        anchorRect: const Rect.fromLTWH(400, 200, 40, 40),
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(Sheet), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(MenuItem), findsNWidgets(4));
      // A menu has no Cancel row: a click outside it cancels.
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Post by Maya'), findsOneWidget);
      final save = tester.getRect(find.text('Save'));
      expect(save.top, greaterThan(240));
      expect(save.left, greaterThanOrEqualTo(400));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(opened.result, _Choice.save);
      expect(opened.pressed, [_Choice.save]);
    });

    testWidgets('a click outside the menu cancels', (tester) async {
      final opened = await _open(
        tester,
        formFactor: FormFactor.desktop,
        anchorRect: const Rect.fromLTWH(400, 200, 40, 40),
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.tapAt(
        const Offset(1000, 700),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(opened.result, isNull);
      expect(opened.pressed, isEmpty);
    });
  });

  group('semantics', () {
    testWidgets('the title names the route and the rows are buttons', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      expect(
        tester.getSemantics(find.text('Post by Maya')),
        isSemantics(namesRoute: true, isHeader: true, label: 'Post by Maya'),
      );
      expect(
        tester.getSemantics(
          find.ancestor(
            of: find.text('Share'),
            matching: find.byType(Pressable),
          ),
        ),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Share',
        ),
      );
      expect(
        tester.getSemantics(
          find.ancestor(
            of: find.text('Mute'),
            matching: find.byType(Pressable),
          ),
        ),
        isSemantics(isButton: true, hasEnabledState: true, label: 'Mute'),
      );
      handle.dispose();
    });
  });

  group('ActionSheet', () {
    testWidgets('inline, it reports the choice and leaves closing to its '
        'owner', (tester) async {
      final opened = _Opened();
      ActionSheetAction<_Choice>? selected;
      var cancelled = 0;
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 320,
            child: ActionSheet<_Choice>(
              actions: _actions(opened),
              onSelected: (action) => selected = action,
              onCancel: () => cancelled++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Share'));
      expect(selected?.value, _Choice.share);
      // With an onSelected the widget does not call the action itself.
      expect(opened.pressed, isEmpty);
      await tester.tap(find.text('Cancel'));
      expect(cancelled, 1);
    });

    testWidgets('without onSelected a row runs its own action', (
      tester,
    ) async {
      final opened = _Opened();
      await pumpFinesse(
        tester,
        ActionSheet<_Choice>(actions: _actions(opened), showCancel: false),
      );
      await tester.tap(find.text('Save'));
      expect(opened.pressed, [_Choice.save]);
    });

    testWidgets('builds in every layout, also at twice the text size', (
      tester,
    ) async {
      final opened = _Opened();
      await expectBuildsInEveryLayout(
        tester,
        (layout) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 2,
          maxScaleFactor: 2,
          child: SingleChildScrollView(
            child: ActionSheet<_Choice>(
              title: const Text('A title that is longer than a row is wide'),
              message: const Text('And a message that wraps on a phone.'),
              actions: _actions(opened, icons: true),
            ),
          ),
        ),
      );
    });

    testWidgets('in a right-to-left app the icon is at the right', (
      tester,
    ) async {
      final opened = _Opened();
      await pumpFinesse(
        tester,
        ActionSheet<_Choice>(actions: _actions(opened, icons: true)),
        textDirection: TextDirection.rtl,
        formFactor: FormFactor.mobile,
      );
      final icon = tester.getCenter(find.byIcon(PhosphorIconsRegular.flag));
      final label = tester.getCenter(find.text('Report'));
      expect(icon.dx, greaterThan(label.dx));
    });

    testWidgets('ActionSheetTheme restyles it', (tester) async {
      final opened = _Opened();
      const theme = ActionSheetTheme(
        rowHeight: 72,
        destructiveColor: Color(0xff123456),
      );
      await pumpFinesse(
        tester,
        ActionSheet<_Choice>(actions: _actions(opened), showCancel: false),
        theme: ThemeData(actionSheetTheme: theme),
      );
      final row = tester.getRect(
        find.ancestor(
          of: find.text('Share'),
          matching: find.byType(Pressable),
        ),
      );
      expect(row.height, 72);
      final style = tester
          .widget<RichText>(
            find.descendant(
              of: find.text('Report'),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style!;
      expect(style.color, const Color(0xff123456));
    });
  });

  group('theme', () {
    test('every style has rows a finger can hit', () {
      for (final style in StyleTokens.all) {
        for (final formFactor in FormFactor.values) {
          final theme = ThemeData(style: style).withFormFactor(formFactor);
          expect(theme.actionSheetTheme.rowHeight, greaterThanOrEqualTo(44));
          expect(theme.actionSheetTheme.labelStyle, isNotNull);
        }
      }
    });

    test('an override survives copyWith and keeps themes equal', () {
      const override = ActionSheetTheme(rowHeight: 60);
      final theme = ThemeData(actionSheetTheme: override);
      expect(theme.actionSheetTheme.rowHeight, 60);
      expect(
        theme
            .copyWith(radius: BorderRadius.circular(3))
            .actionSheetTheme
            .rowHeight,
        60,
      );
      expect(theme, ThemeData(actionSheetTheme: override));
      expect(
        theme,
        isNot(ThemeData(actionSheetTheme: const ActionSheetTheme())),
      );
    });
  });
}
