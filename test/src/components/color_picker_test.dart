import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.initial = const Color(0xFF0F766E),
    this.showAlpha = false,
    this.swatches,
    this.mode,
    this.enabled = true,
  });

  final Color initial;
  final bool showAlpha;
  final List<Color>? swatches;
  final ColorPickerMode? mode;
  final bool enabled;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Color value = widget.initial;
  final changes = <Color>[];

  /// Changes the colour from outside the picker.
  void set(Color next) => setState(() => value = next);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 260,
        child: ColorPicker(
          value: value,
          showAlpha: widget.showAlpha,
          swatches: widget.swatches,
          initialMode: widget.mode,
          onChanged: widget.enabled
              ? (v) {
                  changes.add(v);
                  setState(() => value = v);
                }
              : null,
        ),
      ),
    );
  }
}

void main() {
  _HostState host(WidgetTester tester) => tester.state(find.byType(_Host));

  Finder sliderNamed(String label) => find.bySemanticsLabel(label);

  HSVColor hsvOf(WidgetTester tester) => HSVColor.fromColor(host(tester).value);

  group('hex', () {
    test('writes and reads colours', () {
      expect(colorToHex(const Color(0xFF0F766E)), '#0F766E');
      expect(colorToHex(const Color(0x800F766E), alpha: true), '#0F766E80');
      expect(colorFromHex('#0f766e'), const Color(0xFF0F766E));
      expect(colorFromHex('0F766E80'), const Color(0x800F766E));
      expect(colorFromHex('#fa0'), const Color(0xFFFFAA00));
      expect(colorFromHex('#12'), isNull);
      expect(colorFromHex('teal'), isNull);
    });
  });

  group('ColorPicker', () {
    testWidgets('a tap in the area sets saturation and brightness', (
      tester,
    ) async {
      await pumpUna(tester, const _Host());
      final area = tester.getRect(sliderNamed('Saturation and brightness'));
      // The thumb's centre stays a radius in from each edge, so the area's
      // values span its size less a thumb at each end.
      final r = Theme.of(
        tester.element(find.byType(ColorPicker)),
      ).sliderTheme.thumbRadius!;
      final span = area.deflate(r);
      await tester.tapAt(
        Offset(span.left + span.width * .25, span.top + span.height * .25),
      );
      await tester.pump();
      expect(hsvOf(tester).saturation, closeTo(.25, .02));
      expect(hsvOf(tester).value, closeTo(.75, .02));
      // The hue is kept.
      expect(hsvOf(tester).hue, closeTo(175, 2));
    });

    testWidgets('a drag along the hue track turns the hue', (tester) async {
      await pumpUna(tester, const _Host());
      final track = tester.getRect(sliderNamed('Hue'));
      final gesture = await tester.startGesture(
        Offset(track.left + track.width * .5, track.center.dy),
      );
      await gesture.moveBy(const Offset(-30, 0));
      await gesture.moveBy(const Offset(-60, 0));
      await tester.pump();
      await gesture.up();
      expect(hsvOf(tester).hue, lessThan(120));
      expect(host(tester).changes, isNotEmpty);
    });

    testWidgets('grey keeps its hue thumb where it was', (tester) async {
      await pumpUna(tester, const _Host());
      final area = tester.getRect(sliderNamed('Saturation and brightness'));
      // All the way to no saturation: a grey, which has no hue of its own.
      await tester.tapAt(Offset(area.left + 1, area.center.dy));
      await tester.pump();
      expect(hsvOf(tester).saturation, lessThan(.02));
      expect(
        tester.getSemantics(sliderNamed('Hue')),
        containsSemantics(value: '175°'),
      );
    });

    testWidgets('the opacity track is there with showAlpha', (tester) async {
      await pumpUna(tester, const _Host());
      expect(sliderNamed('Opacity'), findsNothing);
      await pumpUna(
        tester,
        const KeyedSubtree(key: ValueKey(2), child: _Host(showAlpha: true)),
      );
      final track = tester.getRect(sliderNamed('Opacity'));
      await tester.tapAt(
        Offset(track.left + track.width * .5, track.center.dy),
      );
      await tester.pump();
      expect(host(tester).value.a, closeTo(.5, .05));
      expect(find.text(colorToHex(host(tester).value, alpha: true)), findsOne);
    });

    testWidgets('the arrow keys move a thumb, Shift in larger steps', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpUna(tester, const _Host());
      // The mode's segmented control is the first Tab stop, the area the
      // second.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final before = hsvOf(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(hsvOf(tester).saturation, closeTo(before.saturation - .01, .006));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(hsvOf(tester).value, closeTo(before.value - .1, .01));
      // Then the hue.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final hue = hsvOf(tester).hue;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(hsvOf(tester).hue, greaterThan(hue));
    });

    testWidgets('a hex typed in full sets the colour', (tester) async {
      await pumpUna(tester, const _Host());
      expect(find.text('#0F766E'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '#B4');
      await tester.pump();
      expect(host(tester).changes, isEmpty);
      await tester.enterText(find.byType(TextField), '#B45309');
      await tester.pump();
      expect(host(tester).value, const Color(0xFFB45309));
    });

    testWidgets('a swatch sets the colour and wears the ring', (tester) async {
      const swatches = [Color(0xFFB45309), Color(0xFF4338CA)];
      await pumpUna(tester, const _Host(swatches: swatches));
      await tester.tap(find.bySemanticsLabel('#4338CA'));
      await tester.pump();
      expect(host(tester).value, const Color(0xFF4338CA));
      expect(
        tester.getSemantics(find.bySemanticsLabel('#4338CA')),
        containsSemantics(isButton: true, isSelected: true),
      );
      expect(find.text('#4338CA'), findsOneWidget);
    });

    testWidgets('a colour from outside moves the thumbs', (tester) async {
      await pumpUna(tester, const _Host());
      host(tester).set(const Color(0xFFFF0000));
      await tester.pump();
      expect(
        tester.getSemantics(sliderNamed('Hue')),
        containsSemantics(value: '0°'),
      );
      expect(find.text('#FF0000'), findsOneWidget);
      expect(host(tester).changes, isEmpty);
    });

    testWidgets('the hue runs from the right in RTL', (tester) async {
      await pumpUna(
        tester,
        const _Host(initial: Color(0xFFFF0000)),
        textDirection: TextDirection.rtl,
      );
      final track = tester.getRect(sliderNamed('Hue'));
      await tester.tapAt(
        Offset(track.left + track.width * .25, track.center.dy),
      );
      await tester.pump();
      expect(hsvOf(tester).hue, closeTo(270, 12));
    });

    testWidgets('builds in every layout', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => const _Host(
          showAlpha: true,
          swatches: [Color(0xFFB45309), Color(0x804338CA)],
        ),
      );
    });
  });

  group('ColorPickerButton', () {
    Future<void> rest(WidgetTester tester) async {
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    Widget button(
      List<Color> reported, {
      PickerPresentation presentation = PickerPresentation.auto,
    }) {
      var color = const Color(0xFF0F766E);
      return StatefulBuilder(
        builder: (context, setState) => Center(
          child: ColorPickerButton(
            value: color,
            presentation: presentation,
            semanticLabel: 'Accent',
            onChanged: (v) {
              reported.add(v);
              setState(() => color = v);
            },
          ),
        ),
      );
    }

    testWidgets('is a swatch as tall as a control, named and valued', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, button([]));
      final theme = themeOf(tester, find.byType(ColorPickerButton));
      expect(
        tester.getSize(find.byType(ColorPickerButton)),
        Size.square(theme.style.inputHeight),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Accent')),
        containsSemantics(isButton: true, value: '#0F766E'),
      );
      handle.dispose();
    });

    testWidgets('on a desktop it opens the picker in a popover, live', (
      tester,
    ) async {
      final reported = <Color>[];
      await pumpUna(tester, button(reported));
      await tester.tap(find.byType(ColorPickerButton));
      await rest(tester);
      expect(find.byType(ColorPicker), findsOneWidget);
      expect(find.byType(Sheet), findsNothing);
      await tester.enterText(find.byType(TextField), '#B45309');
      await tester.pump();
      expect(reported, [const Color(0xFFB45309)]);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await rest(tester);
      expect(find.byType(ColorPicker), findsNothing);
    });

    testWidgets('on a phone it opens a sheet whose Done reports the draft', (
      tester,
    ) async {
      final reported = <Color>[];
      await pumpUna(
        tester,
        button(reported),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.byType(ColorPickerButton));
      await rest(tester);
      expect(find.byType(Sheet), findsOneWidget);
      expect(find.text('Select colour'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '#B45309');
      await tester.pump();
      expect(reported, isEmpty);
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(reported, [const Color(0xFFB45309)]);
      expect(find.byType(Sheet), findsNothing);
      // Cancel drops a draft.
      await tester.tap(find.byType(ColorPickerButton));
      await rest(tester);
      await tester.enterText(find.byType(TextField), '#000000');
      await tester.pump();
      await tester.tap(find.widgetWithText(Button, 'Cancel'));
      await rest(tester);
      expect(reported, hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a null onChanged disables it', (tester) async {
      await pumpUna(
        tester,
        const Center(
          child: ColorPickerButton(value: Color(0xFF0F766E), onChanged: null),
        ),
      );
      await tester.tap(find.byType(ColorPickerButton), warnIfMissed: false);
      await rest(tester);
      expect(find.byType(ColorPicker), findsNothing);
    });
  });

  group('ColorPicker modes', () {
    _HostState host(WidgetTester tester) =>
        tester.state<_HostState>(find.byType(_Host));

    testWidgets('a segmented control switches between the three', (
      tester,
    ) async {
      await pumpUna(tester, const _Host());
      expect(find.byType(SegmentedControl<ColorPickerMode>), findsOneWidget);
      for (final label in ['Spectrum', 'Grid', 'Sliders']) {
        expect(find.text(label), findsOneWidget);
      }
      // The third segment, from the keyboard: the arrows move a segmented
      // control's selection. (The test font's em-wide glyphs overflow the
      // labels at this width, so a tap is not a fair test of the layout.)
      useTraditionalHighlights();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('R'), findsOneWidget);
      // Teal's red, green and blue, as numbers.
      expect(find.text('15'), findsOneWidget);
      expect(find.text('118'), findsOneWidget);
      expect(find.text('110'), findsOneWidget);
    });

    testWidgets('one mode shows no control', (tester) async {
      await pumpUna(
        tester,
        const Center(
          child: SizedBox(
            width: 260,
            child: ColorPicker(
              value: Color(0xFF0F766E),
              onChanged: null,
              modes: [ColorPickerMode.spectrum],
            ),
          ),
        ),
      );
      expect(find.byType(SegmentedControl<ColorPickerMode>), findsNothing);
    });

    testWidgets('a tap in the grid picks the cell under it', (tester) async {
      await pumpUna(tester, const _Host(mode: ColorPickerMode.grid));
      final grid = find.byWidgetPredicate(
        (w) => w is CustomPaint && '${w.painter.runtimeType}' == '_GridPainter',
      );
      final rect = tester.getRect(grid);
      // The first cell of the grey row: white.
      await tester.tapAt(rect.topLeft + const Offset(4, 4));
      await tester.pump();
      expect(colorToHex(host(tester).value), '#FFFFFF');
      // The last: black.
      await tester.tapAt(rect.topRight + const Offset(-4, 4));
      await tester.pump();
      expect(colorToHex(host(tester).value), '#000000');
      // A hue lower down: not grey.
      await tester.tapAt(rect.center);
      await tester.pump();
      final hsv = HSVColor.fromColor(host(tester).value);
      expect(hsv.saturation, greaterThan(.5));
    });

    testWidgets('a slider changes only its channel', (tester) async {
      await pumpUna(tester, const _Host(mode: ColorPickerMode.sliders));
      final before = host(tester).value;
      final red = find.bySemanticsLabel('Red');
      final rect = tester.getRect(red);
      await tester.tapAt(rect.centerRight - const Offset(2, 0));
      await tester.pump();
      final after = host(tester).value;
      expect(after.r, greaterThan(.9));
      expect(after.g, closeTo(before.g, .01));
      expect(after.b, closeTo(before.b, .01));
    });

    testWidgets('with no onChanged it is disabled', (tester) async {
      await pumpUna(tester, const _Host(enabled: false));
      expect(find.byType(Disabled), findsWidgets);
      final disabled = tester.widget<Disabled>(
        find
            .ancestor(
              of: find.byType(SegmentedControl<ColorPickerMode>),
              matching: find.byType(Disabled),
            )
            .first,
      );
      expect(disabled.enabled, isFalse);
    });
  });
}
