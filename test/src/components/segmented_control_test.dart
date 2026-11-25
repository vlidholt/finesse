import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// [SegmentedControl] picks one value of a few: the tab list's strip and
/// travelling thumb, announced as radio buttons.
const _frame = Duration(milliseconds: 16);

enum _Size { small, medium, large }

Widget _control({
  _Size? value = _Size.small,
  ValueChanged<_Size>? onChanged,
  bool expand = false,
  bool enabled = true,
  bool mediumEnabled = true,
}) {
  return Align(
    alignment: Alignment.topLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: SegmentedControl<_Size>(
        value: value,
        onChanged: onChanged,
        expand: expand,
        enabled: enabled,
        segments: [
          const Segment(value: _Size.small, label: Text('S')),
          Segment(
            value: _Size.medium,
            label: const Text('M'),
            enabled: mediumEnabled,
          ),
          const Segment(value: _Size.large, label: Text('L')),
        ],
      ),
    ),
  );
}

/// A control that holds its own value, as an app would.
class _Held extends StatefulWidget {
  const _Held({this.changes});

  final List<_Size>? changes;

  @override
  State<_Held> createState() => _HeldState();
}

class _HeldState extends State<_Held> {
  _Size value = _Size.small;

  @override
  Widget build(BuildContext context) => _control(
    value: value,
    onChanged: (next) {
      widget.changes?.add(next);
      setState(() => value = next);
    },
  );
}

Finder _segments() => find.byType(MovingIndicatorTarget);

RenderMovingIndicator _indicator(WidgetTester tester) => tester.renderObject(
  find.descendant(
    of: find.byType(SegmentedControl<_Size>),
    matching: find.byWidgetPredicate(
      (w) => '${w.runtimeType}' == '_MovingIndicatorRenderWidget',
    ),
  ),
);

void main() {
  testWidgets('builds in every layout and style without overflowing', (
    tester,
  ) async {
    for (final style in [
      StyleTokens.finesse,
      StyleTokens.nova,
      StyleTokens.maia,
      StyleTokens.lyra,
    ]) {
      for (final layout in kLayouts) {
        await pumpFinesse(
          tester,
          _control(onChanged: (_) {}),
          formFactor: layout.formFactor,
          textDirection: layout.textDirection,
          theme: ThemeData(style: style),
        );
        expect(tester.takeException(), isNull);
        expect(_segments(), findsNWidgets(3));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('is as wide as its segments, or fills the width with expand', (
    tester,
  ) async {
    await pumpFinesse(tester, _control(onChanged: (_) {}));
    final hugging = tester.getSize(find.byType(SegmentedControl<_Size>));
    expect(hugging.width, lessThan(200));
    final widths = [
      for (var i = 0; i < 3; i++) tester.getSize(_segments().at(i)).width,
    ];
    await tester.pumpWidget(const SizedBox.shrink());

    await pumpFinesse(tester, _control(onChanged: (_) {}, expand: true));
    expect(tester.getSize(find.byType(SegmentedControl<_Size>)).width, 400);
    final shared = [
      for (var i = 0; i < 3; i++) tester.getSize(_segments().at(i)).width,
    ];
    expect(shared.toSet(), hasLength(1));
    expect(shared.first, greaterThan(widths.first));
  });

  testWidgets("a segment is the style's tab height, on both form factors, "
      'and grows with the text scale', (tester) async {
    for (final formFactor in FormFactor.values) {
      await pumpFinesse(
        tester,
        _control(onChanged: (_) {}),
        formFactor: formFactor,
      );
      final theme = Theme.of(tester.element(_segments().first));
      final height = theme.tabsTheme.tabHeight ?? 32;
      expect(tester.getSize(_segments().first).height, height);
      if (formFactor == FormFactor.mobile) {
        // A touch target.
        expect(
          tester.getSize(find.byType(SegmentedControl<_Size>)).height,
          greaterThanOrEqualTo(44),
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }

    await pumpFinesse(
      tester,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _control(onChanged: (_) {}),
      ),
    );
    expect(tester.takeException(), isNull);
    final label = tester.getRect(find.text('S'));
    final segment = tester.getRect(_segments().first);
    expect(segment.top, lessThanOrEqualTo(label.top));
    expect(segment.bottom, greaterThanOrEqualTo(label.bottom));
  });

  testWidgets('a tap reports the value; the chosen segment reports nothing', (
    tester,
  ) async {
    final changes = <_Size>[];
    await pumpFinesse(tester, _control(onChanged: changes.add));
    await tester.tap(find.text('L'));
    await tester.tap(find.text('S'));
    await tester.tap(find.text('M'));
    expect(changes, [_Size.large, _Size.medium]);
  });

  testWidgets('one thumb travels to the chosen segment without turning '
      'back, and settles', (tester) async {
    await pumpFinesse(
      tester,
      const _Held(),
      // Without the spring's little bounce, which is an overshoot.
      theme: ThemeData(
        motion: Motion.lively.copyWith(snappy: const MotionSpring()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final indicator = _indicator(tester);
    final start = indicator.indicatorRect!;
    expect(
      start,
      tester
          .getRect(_segments().first)
          .shift(
            -tester.getTopLeft(
              find.byWidgetPredicate(
                (w) => '${w.runtimeType}' == '_MovingIndicatorRenderWidget',
              ),
            ),
          ),
    );
    await tester.tap(find.text('L'));
    await tester.pump();
    final left = <double>[];
    for (var i = 0; i < 40; i++) {
      await tester.pump(_frame);
      left.add(indicator.indicatorRect!.left);
    }
    for (var i = 1; i < left.length; i++) {
      expect(left[i], greaterThanOrEqualTo(left[i - 1] - 1e-6));
    }
    expect(left.toSet().length, greaterThan(5));
    await tester.pumpAndSettle();
    expect(
      indicator.indicatorRect!.width,
      tester.getSize(_segments().at(2)).width,
    );
    expect(indicator.indicatorRect!.left, greaterThan(start.left));
  });

  testWidgets('with reduced motion, and with none, the thumb is simply '
      'there', (tester) async {
    for (final reduce in [true, false]) {
      await pumpFinesse(
        tester,
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduce),
          child: const _Held(),
        ),
        theme: reduce ? null : ThemeData(motion: Motion.none),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final indicator = _indicator(tester);
      await tester.tap(find.text('L'));
      await tester.pump();
      await tester.pump(_frame);
      final box = tester.getRect(_segments().at(2));
      expect(indicator.indicatorRect!.width, box.width);
      final first = indicator.indicatorRect!.left;
      await tester.pump(const Duration(milliseconds: 200));
      expect(indicator.indicatorRect!.left, first);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('is one Tab stop; the arrow keys change the value, mirrored '
      'in a right-to-left layout and past a disabled segment', (tester) async {
    for (final direction in TextDirection.values) {
      var value = _Size.small;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              _control(
                value: value,
                mediumEnabled: false,
                onChanged: (next) => setState(() => value = next),
              ),
              const Focus(child: SizedBox(width: 10, height: 10)),
            ],
          ),
        ),
        textDirection: direction,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final forward = direction == TextDirection.ltr
          ? LogicalKeyboardKey.arrowRight
          : LogicalKeyboardKey.arrowLeft;
      final back = direction == TextDirection.ltr
          ? LogicalKeyboardKey.arrowLeft
          : LogicalKeyboardKey.arrowRight;
      // Over the disabled one in the middle.
      await tester.sendKeyEvent(forward);
      await tester.pump();
      expect(value, _Size.large);
      await tester.sendKeyEvent(back);
      await tester.pump();
      expect(value, _Size.small);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, _Size.large);
      // One stop: Tab leaves.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(SegmentedControl<_Size>),
          matching: find.byWidgetPredicate(
            (w) => w is Focus && (w.focusNode?.hasPrimaryFocus ?? false),
          ),
        ),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('keyboard focus shows a ring on the focused segment', (
    tester,
  ) async {
    await pumpFinesse(tester, const _Held());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final node = FocusManager.instance.primaryFocus!;
    expect(
      find.descendant(
        of: _segments().first,
        matching: find.byElementPredicate((e) => e == node.context),
        matchRoot: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('on a touch screen a finger dragged along the strip takes the '
      'thumb with it; a mouse does not', (tester) async {
    final changes = <_Size>[];
    await pumpFinesse(tester, _Held(changes: changes));
    final first = tester.getCenter(_segments().first);
    final last = tester.getCenter(_segments().at(2));
    final step = (last - first) / 8;

    final finger = await tester.startGesture(first);
    for (var i = 0; i < 8; i++) {
      await finger.moveBy(step);
      await tester.pump(_frame);
    }
    // Drifting off the strip keeps hold of it.
    await finger.moveBy(const Offset(0, 80));
    await tester.pump();
    await finger.up();
    await tester.pumpAndSettle();
    expect(changes, [_Size.medium, _Size.large]);

    changes.clear();
    final mouse = await tester.startGesture(
      last,
      kind: PointerDeviceKind.mouse,
    );
    for (var i = 0; i < 8; i++) {
      await mouse.moveBy(-step);
      await tester.pump(_frame);
    }
    await mouse.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  testWidgets('disabled, or without onChanged, it is inert', (tester) async {
    final changes = <_Size>[];
    await pumpFinesse(
      tester,
      _control(onChanged: changes.add, enabled: false),
    );
    await tester.tap(find.text('L'), warnIfMissed: false);
    expect(changes, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());

    await pumpFinesse(tester, _control());
    await tester.tap(find.text('L'), warnIfMissed: false);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a disabled segment cannot be chosen', (tester) async {
    final changes = <_Size>[];
    await pumpFinesse(
      tester,
      _control(onChanged: changes.add, mediumEnabled: false),
    );
    await tester.tap(find.text('M'), warnIfMissed: false);
    expect(changes, isEmpty);
  });

  testWidgets('a value no segment has shows no thumb', (tester) async {
    await pumpFinesse(tester, _control(value: null, onChanged: (_) {}));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_indicator(tester).indicatorRect, isNull);
  });

  testWidgets('is a radio group to a screen reader: one node per segment, '
      'checked or not, each with a tap', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpFinesse(
      tester,
      Semantics(
        label: 'Size',
        container: true,
        child: _control(value: _Size.medium, onChanged: (_) {}),
      ),
    );
    expect(tester.takeException(), isNull);
    final group = tester.getSemantics(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics && w.properties.role == ui.SemanticsRole.radioGroup,
      ),
    );
    expect(group.getSemanticsData().role, ui.SemanticsRole.radioGroup);
    for (final (index, label) in ['S', 'M', 'L'].indexed) {
      final data = tester
          .getSemantics(find.bySemanticsLabel(label))
          .getSemanticsData();
      expect(data.label, label);
      expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(
        data.flagsCollection.isChecked,
        index == 1 ? ui.CheckedState.isTrue : ui.CheckedState.isFalse,
      );
      expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
    }
    handle.dispose();
  });

  testWidgets('an icon-only segment is read by its semantic label, and a '
      'tooltip names it for a pointer', (tester) async {
    final handle = tester.ensureSemantics();
    var value = 'list';
    await pumpFinesse(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Align(
          child: SegmentedControl<String>(
            value: value,
            onChanged: (next) => setState(() => value = next),
            segments: const [
              Segment(
                value: 'list',
                icon: PhosphorIcon(PhosphorIconsRegular.list),
                semanticLabel: 'List',
                tooltip: 'List',
              ),
              Segment(
                value: 'grid',
                icon: PhosphorIcon(PhosphorIconsRegular.squaresFour),
                semanticLabel: 'Grid',
                tooltip: 'Grid',
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final grid = tester.getSemantics(find.bySemanticsLabel('Grid'));
    expect(grid.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
    tester.semantics.tap(find.semantics.byLabel('Grid'));
    await tester.pumpAndSettle();
    expect(value, 'grid');
    handle.dispose();
  });

  testWidgets('the theme restyles it: the tabs theme is the one place', (
    tester,
  ) async {
    const fill = Color(0xFF112233);
    await pumpFinesse(
      tester,
      _control(onChanged: (_) {}),
      theme: ThemeData(
        tabsTheme: const TabsTheme(
          tabHeight: 50,
          tabSelectedBackgroundColor: fill,
        ),
      ),
    );
    expect(tester.getSize(_segments().first).height, 50);
    final target = tester.widget<MovingIndicatorTarget>(_segments().first);
    final decoration = target.decoration as ShadowDecoration;
    expect((decoration.decoration as BoxDecoration).color, fill);
  });
}
