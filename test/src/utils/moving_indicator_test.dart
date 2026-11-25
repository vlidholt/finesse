import 'package:finesse/finesse.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);
const _pill = BoxDecoration(color: Color(0xff000000));

class _Segments extends StatelessWidget {
  const _Segments({
    required this.selected,
    this.widths = const [100, 100, 100],
    this.reduceMotion = false,
    this.motion,
    this.padding = 0,
  });

  final int? selected;
  final List<double> widths;
  final bool reduceMotion;
  final Motion? motion;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return FinesseApp(
      theme: ThemeData(
        motion: motion ?? Motion.lively.copyWith(snappy: const MotionSpring()),
      ),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduceMotion,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: padding),
              child: MovingIndicator(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (i, width) in widths.indexed)
                      MovingIndicatorTarget(
                        selected: i == selected,
                        decoration: _pill,
                        child: SizedBox(width: width, height: 30),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

RenderMovingIndicator _render(WidgetTester tester) =>
    tester.renderObject<RenderMovingIndicator>(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_MovingIndicatorRenderWidget',
      ),
    );

void main() {
  testWidgets('is on the selected target from the first frame', (
    tester,
  ) async {
    await tester.pumpWidget(const _Segments(selected: 1));
    expect(
      _render(tester).indicatorRect,
      const Rect.fromLTWH(100, 0, 100, 30),
    );
    expect(_render(tester).indicatorOpacity, 1);
    await tester.pumpAndSettle();
    expect(
      _render(tester).indicatorRect,
      const Rect.fromLTWH(100, 0, 100, 30),
    );
  });

  testWidgets('travels to the new target: every edge monotone, the leading '
      'edge first, and it stretches on the way', (tester) async {
    await tester.pumpWidget(const _Segments(selected: 0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const _Segments(selected: 2));

    var previous = _render(tester).indicatorRect!;
    expect(previous, const Rect.fromLTWH(0, 0, 100, 30));
    var widest = previous.width;
    for (var i = 0; i < 80; i++) {
      await tester.pump(_frame);
      final rect = _render(tester).indicatorRect!;
      expect(rect.left, greaterThanOrEqualTo(previous.left - 1e-6));
      expect(rect.right, greaterThanOrEqualTo(previous.right - 1e-6));
      // Travelling right, the right edge leads: it is never narrower
      // than at rest.
      expect(rect.width, greaterThanOrEqualTo(100 - 1e-6));
      // Never outside the span between the two targets.
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(300 + 1e-6));
      expect(rect.top, 0);
      expect(rect.bottom, 30);
      if (rect.width > widest) widest = rect.width;
      previous = rect;
    }
    expect(previous, const Rect.fromLTWH(200, 0, 100, 30));
    expect(widest, greaterThan(110), reason: 'it stretches while it moves');
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('with no stretch it moves rigidly', (tester) async {
    final motion = Motion.calm.copyWith(indicatorStretch: 0);
    await tester.pumpWidget(_Segments(selected: 0, motion: motion));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_Segments(selected: 2, motion: motion));
    for (var i = 0; i < 40; i++) {
      await tester.pump(_frame);
      expect(_render(tester).indicatorRect!.width, closeTo(100, 1e-6));
    }
  });

  testWidgets('an interruption turns around without a jump', (tester) async {
    await tester.pumpWidget(const _Segments(selected: 0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const _Segments(selected: 2));
    for (var i = 0; i < 5; i++) {
      await tester.pump(_frame);
    }
    var previous = _render(tester).indicatorRect!;
    expect(previous.left, inExclusiveRange(0, 200));
    await tester.pumpWidget(const _Segments(selected: 0));
    for (var i = 0; i < 80; i++) {
      await tester.pump(_frame);
      final rect = _render(tester).indicatorRect!;
      // At most the distance the fastest frame of a clean run covers.
      expect((rect.left - previous.left).abs(), lessThan(40));
      expect((rect.right - previous.right).abs(), lessThan(40));
      previous = rect;
    }
    expect(previous, const Rect.fromLTWH(0, 0, 100, 30));
  });

  testWidgets('follows the same target rigidly when layout moves it', (
    tester,
  ) async {
    await tester.pumpWidget(const _Segments(selected: 1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const _Segments(selected: 1, padding: 40));
    // The same frame: no animation.
    expect(
      _render(tester).indicatorRect,
      const Rect.fromLTWH(100, 0, 100, 30),
    );
    await tester.pumpWidget(
      const _Segments(selected: 1, widths: [60, 140, 100]),
    );
    expect(
      _render(tester).indicatorRect,
      const Rect.fromLTWH(60, 0, 140, 30),
    );
    await tester.pump(_frame);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('fades out with no selection and in on the next', (
    tester,
  ) async {
    await tester.pumpWidget(const _Segments(selected: 0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const _Segments(selected: null));
    var previous = 1.0;
    for (var i = 0; i < 20; i++) {
      await tester.pump(_frame);
      final opacity = _render(tester).indicatorOpacity;
      expect(opacity, lessThanOrEqualTo(previous));
      previous = opacity;
    }
    expect(previous, 0);
    expect(_render(tester).indicatorRect, isNull);

    await tester.pumpWidget(const _Segments(selected: 2));
    // It appears on the new target; it does not fly in from the old one.
    for (var i = 0; i < 20; i++) {
      await tester.pump(_frame);
      final opacity = _render(tester).indicatorOpacity;
      expect(opacity, greaterThanOrEqualTo(previous));
      previous = opacity;
      if (opacity > 0) {
        expect(
          _render(tester).indicatorRect,
          const Rect.fromLTWH(200, 0, 100, 30),
        );
      }
    }
    expect(previous, 1);
  });

  testWidgets('jumps with reduced motion', (tester) async {
    await tester.pumpWidget(
      const _Segments(selected: 0, reduceMotion: true),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      const _Segments(selected: 2, reduceMotion: true),
    );
    await tester.pump(_frame);
    expect(
      _render(tester).indicatorRect,
      const Rect.fromLTWH(200, 0, 100, 30),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a target outside a MovingIndicator paints its own '
      'decoration', (tester) async {
    await tester.pumpWidget(
      const FinesseApp(
        home: Center(
          child: MovingIndicatorTarget(
            selected: true,
            decoration: _pill,
            child: SizedBox(width: 40, height: 20),
          ),
        ),
      ),
    );
    expect(
      find.byType(MovingIndicatorTarget),
      paints..rect(color: const Color(0xff000000)),
    );
  });

  testWidgets('paints the decoration on the animated rectangle', (
    tester,
  ) async {
    await tester.pumpWidget(const _Segments(selected: 1));
    expect(
      find.byType(MovingIndicator),
      paints..rect(
        rect: const Rect.fromLTWH(100, 0, 100, 30),
        color: const Color(0xff000000),
      ),
    );
  });
  group('while it fades, the layer it fades through', () {
    /// The bounds of the `saveLayer` the indicator paints through.
    List<Rect?> layers(WidgetTester tester) {
      final bounds = <Rect?>[];
      expect(
        find.byType(MovingIndicator),
        paints..everything((method, arguments) {
          if (method == #saveLayer) bounds.add(arguments.first as Rect?);
          return true;
        }),
      );
      return bounds;
    }

    Widget segments({required int? selected, required Decoration pill}) =>
        FinesseApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: MovingIndicator(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    MovingIndicatorTarget(
                      selected: i == selected,
                      decoration: pill,
                      child: const SizedBox(width: 100, height: 30),
                    ),
                ],
              ),
            ),
          ),
        );

    Future<void> fadeOut(WidgetTester tester, Decoration pill) async {
      await tester.pumpWidget(segments(selected: 1, pill: pill));
      await tester.pumpAndSettle();
      expect(layers(tester), isEmpty, reason: 'no layer at full opacity');
      await tester.pumpWidget(segments(selected: null, pill: pill));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 48));
      final opacity = _render(tester).indicatorOpacity;
      expect(opacity, greaterThan(0));
      expect(opacity, lessThan(1));
    }

    const box = Rect.fromLTWH(100, 0, 100, 30);

    testWidgets('is the size of a plain pill, not of the window', (
      tester,
    ) async {
      await fadeOut(tester, _pill);
      final bounds = layers(tester).single!;
      expect(bounds.contains(box.topLeft), isTrue);
      expect(bounds.contains(box.bottomRight), isTrue);
      expect(box.inflate(2).contains(bounds.topLeft), isTrue);
      expect(box.inflate(2).contains(bounds.bottomRight), isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('reaches as far as its shadows and its border do', (
      tester,
    ) async {
      const shadow = BoxShadow(
        color: Color(0x40000000),
        blurRadius: 12,
        spreadRadius: 2,
        offset: Offset(0, 4),
      );
      // The far edge of the shadow: its offset, its spread and three
      // sigmas of blur.
      final reach = 4 + 2 + shadow.blurSigma * 3;
      for (final pill in <Decoration>[
        const BoxDecoration(color: Color(0xff000000), boxShadow: [shadow]),
        ShadowDecoration.box(
          color: const Color(0xff000000),
          shadows: const [shadow],
        ),
        const ShapeDecoration(
          color: Color(0xff000000),
          shape: StadiumBorder(),
          shadows: [shadow],
        ),
      ]) {
        await fadeOut(tester, pill);
        final bounds = layers(tester).single!;
        expect(bounds.bottom, greaterThanOrEqualTo(box.bottom + reach));
        expect(bounds.left, lessThanOrEqualTo(box.left - (reach - 4)));
        expect(bounds.width, lessThan(200), reason: '$pill');
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
      }

      await fadeOut(
        tester,
        BoxDecoration(
          border: Border.all(
            width: 6,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      );
      final bounds = layers(tester).single!;
      expect(bounds.left, lessThanOrEqualTo(box.left - 6));
      expect(bounds.bottom, greaterThanOrEqualTo(box.bottom + 6));
      await tester.pumpAndSettle();
    });

    testWidgets('is left unbounded for a decoration it knows nothing '
        'about', (tester) async {
      await fadeOut(tester, const FlutterLogoDecoration());
      expect(layers(tester).single, isNull);
      await tester.pumpAndSettle();
    });
  });
}
