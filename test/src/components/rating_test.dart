import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

class _Host extends StatefulWidget {
  const _Host({this.initial = 2, this.allowHalf = false});

  final double initial;
  final bool allowHalf;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late double value = widget.initial;
  final changes = <double>[];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Rating(
        value: value,
        allowHalf: widget.allowHalf,
        semanticLabel: 'Your rating',
        onChanged: (v) {
          changes.add(v);
          setState(() => value = v);
        },
      ),
    );
  }
}

void main() {
  // Haptics are silent under `flutter test` unless a test asks.
  setUp(() => Haptics.debugEnabledInTests = true);
  tearDown(() => Haptics.debugEnabledInTests = false);

  _HostState host(WidgetTester tester) => tester.state(find.byType(_Host));

  /// A point [stars] stars along the rating, in reading order.
  Offset at(WidgetTester tester, double stars, {int count = 5}) {
    final rect = tester.getRect(find.byType(Rating));
    final rtl =
        Directionality.of(tester.element(find.byType(Rating))) ==
        TextDirection.rtl;
    final along = rect.width * stars / count;
    return Offset(rtl ? rect.right - along : rect.left + along, rect.center.dy);
  }

  int filled(WidgetTester tester) =>
      tester.widgetList(find.byIcon(PhosphorIconsFill.star)).length;

  group('Rating', () {
    testWidgets('read-only: shows the value, fractions included', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        const Center(child: Rating(value: 3.5, semanticLabel: 'Average')),
      );
      // Three full stars and the filled half of the fourth.
      expect(filled(tester), 4);
      expect(find.byIcon(PhosphorIconsRegular.star), findsNWidgets(2));
      final clip = tester.widget<Align>(
        find.descendant(
          of: find.byType(ClipRect),
          matching: find.byType(Align),
        ),
      );
      expect(clip.widthFactor, .5);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Average')),
        containsSemantics(value: '3.5 of 5', isReadOnly: true),
      );
      // No target, no focus.
      await tester.tapAt(at(tester, 4.5));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('a tap rates with the star under it', (tester) async {
      await pumpFinesse(tester, const _Host());
      await tester.tapAt(at(tester, 3.6));
      await tester.pumpAndSettle();
      expect(host(tester).changes, [4]);
      expect(filled(tester), 4);
    });

    testWidgets('allowHalf rates in halves', (tester) async {
      await pumpFinesse(tester, const _Host(allowHalf: true));
      await tester.tapAt(at(tester, 3.3));
      await tester.pumpAndSettle();
      expect(host(tester).value, 3.5);
      await tester.tapAt(at(tester, 3.8));
      await tester.pumpAndSettle();
      expect(host(tester).value, 4);
    });

    testWidgets('a drag scrubs through the stars', (tester) async {
      await pumpFinesse(tester, const _Host(initial: 1));
      final gesture = await tester.startGesture(at(tester, .5));
      await gesture.moveTo(at(tester, 1.2));
      await gesture.moveTo(at(tester, 2.5));
      await gesture.moveTo(at(tester, 4.5));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(host(tester).value, 5);
      expect(host(tester).changes.last, 5);
      expect(host(tester).changes, containsAllInOrder([3, 5]));
    });

    testWidgets('a mouse previews the rating under it', (tester) async {
      await pumpFinesse(tester, const _Host());
      final mouse = await hoverAt(tester, at(tester, 4.5));
      await tester.pump();
      expect(filled(tester), 5);
      expect(host(tester).changes, isEmpty);
      await mouse.moveTo(const Offset(5, 5));
      await tester.pump();
      expect(filled(tester), 2);
    });

    testWidgets('the arrow keys, Home and End adjust it', (tester) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, const _Host(allowHalf: true));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(tester.widget<FocusRing>(find.byType(FocusRing)).visible, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(host(tester).value, 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(host(tester).value, 2.5);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(host(tester).value, 5);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(host(tester).value, 5);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(host(tester).value, 0);
    });

    testWidgets('is a slider to assistive technology', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, const _Host());
      expect(
        tester.getSemantics(find.bySemanticsLabel('Your rating')),
        containsSemantics(
          isSlider: true,
          value: '2 of 5',
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      tester.semantics.increase(find.semantics.byLabel('Your rating'));
      await tester.pumpAndSettle();
      expect(host(tester).value, 3);
      handle.dispose();
    });

    testWidgets('reads from the right in RTL', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(),
        textDirection: TextDirection.rtl,
      );
      // Near the right edge is the first star there.
      final rect = tester.getRect(find.byType(Rating));
      await tester.tapAt(Offset(rect.right - 4, rect.center.dy));
      await tester.pumpAndSettle();
      expect(host(tester).value, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(host(tester).value, 2);
    });

    testWidgets('the chosen star pops and comes to rest', (tester) async {
      await pumpFinesse(tester, const _Host());
      await tester.tapAt(at(tester, 3.6));
      await tester.pump();
      double scaleOf() {
        final transform = tester.widget<Transform>(
          find
              .descendant(
                of: find.byType(PopOnChange).at(3),
                matching: find.byType(Transform),
              )
              .first,
        );
        return transform.transform.getMaxScaleOnAxis();
      }

      var peak = 1.0;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (scaleOf() > peak) peak = scaleOf();
      }
      expect(peak, greaterThan(1.05));
      await tester.pumpAndSettle();
      expect(scaleOf(), closeTo(1, .001));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a finger feels the stars it scrubs past', (tester) async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') calls.add(call);
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await pumpFinesse(tester, const _Host(initial: 1));
      await tester.tapAt(at(tester, 2.5));
      await tester.pumpAndSettle();
      expect(calls, hasLength(1));
      calls.clear();
      await tester.tapAt(at(tester, 4.5), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });

    testWidgets('on a phone the stars are a touch target', (tester) async {
      await pumpFinesse(tester, const _Host(), formFactor: FormFactor.mobile);
      final size = tester.getSize(find.byType(Rating));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width / 5, greaterThanOrEqualTo(36));
    });

    testWidgets('icons, size, colour and count are for the caller', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Rating(
            value: 2,
            count: 3,
            size: 30,
            color: Color(0xFFFF0000),
            icon: PhosphorIcon(PhosphorIconsRegular.heart),
            selectedIcon: PhosphorIcon(PhosphorIconsFill.heart),
          ),
        ),
      );
      expect(find.byIcon(PhosphorIconsFill.heart), findsNWidgets(2));
      expect(find.byIcon(PhosphorIconsRegular.heart), findsOneWidget);
      final icon = tester.element(find.byIcon(PhosphorIconsFill.heart).first);
      expect(IconTheme.of(icon).size, 30);
      expect(IconTheme.of(icon).color, const Color(0xFFFF0000));
    });

    testWidgets('builds in every layout', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => const _Host(allowHalf: true, initial: 2.5),
      );
    });
  });
}
