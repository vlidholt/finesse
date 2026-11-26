import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

int _inits = 0;

class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    _inits++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.square(dimension: 20);
}

double _scaleOf(WidgetTester tester, Finder child) {
  final transform = tester.widget<Transform>(
    find.ancestor(of: child, matching: find.byType(Transform)).first,
  );
  // The x scale, which unlike `getMaxScaleOnAxis` can be below 1.
  return transform.transform.storage[0];
}

void main() {
  setUp(() => _inits = 0);

  group('PopIn', () {
    late StateSetter set;
    var visible = false;

    /// A hidden PopIn, to be shown with `set(() => visible = true)`.
    Future<void> pumpHidden(WidgetTester tester, {required bool wipe}) async {
      visible = false;
      await pumpUna(
        tester,
        Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return PopIn(visible: visible, wipe: wipe, child: const _Probe());
            },
          ),
        ),
      );
      expect(_inits, 0);
    }

    ClipRect clip(WidgetTester tester) => tester.widget<ClipRect>(
      find.ancestor(of: find.byType(_Probe), matching: find.byType(ClipRect)),
    );

    testWidgets("keeps its child's state through the whole entrance: the "
        'fade ending, the wipe ending and the overshoot coming back', (
      tester,
    ) async {
      await pumpHidden(tester, wipe: true);
      set(() => visible = true);
      // The default motion's bouncy spring passes 1 and returns.
      var overshot = false;
      var returned = false;
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        if (find.byType(_Probe).evaluate().isEmpty) continue;
        final scale = _scaleOf(tester, find.byType(_Probe));
        if (scale > 1) overshot = true;
        if (overshot && scale < 1) returned = true;
      }
      expect(overshot, isTrue, reason: 'the entrance never passed its size');
      expect(returned, isTrue, reason: 'the overshoot never came back');
      expect(_inits, 1, reason: 'the child was re-created');
      await tester.pumpAndSettle();
      expect(_inits, 1);
    });

    testWidgets('wipes only while it is entering', (tester) async {
      await pumpHidden(tester, wipe: true);
      set(() => visible = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 48));
      expect(clip(tester).clipBehavior, Clip.hardEdge);
      final size = tester.getSize(find.byType(_Probe));
      final revealed = clip(tester).clipper!.getClip(size);
      expect(revealed.width, greaterThan(0));
      expect(revealed.width, lessThan(size.width));

      await tester.pumpAndSettle();
      expect(clip(tester).clipBehavior, Clip.none);
      expect(clip(tester).clipper, isNull);
    });

    testWidgets('without a wipe nothing is ever clipped', (tester) async {
      await pumpHidden(tester, wipe: false);
      set(() => visible = true);
      var frames = 0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (find.byType(_Probe).evaluate().isEmpty) continue;
        frames++;
        expect(clip(tester).clipBehavior, Clip.none);
      }
      expect(frames, greaterThan(30));
      expect(_inits, 1);
    });
  });

  group('PopOnChange', () {
    const child = ValueKey('child');
    late StateSetter set;
    var value = 0;

    Widget pop() => Center(
      child: StatefulBuilder(
        builder: (context, setState) {
          set = setState;
          return PopOnChange(
            value: value,
            scale: 1.2,
            child: const SizedBox.square(key: child, dimension: 20),
          );
        },
      ),
    );

    /// The largest scale seen over [frames] frames, changing the value on
    /// each of the first [changes].
    Future<double> peak(
      WidgetTester tester, {
      required int changes,
      required int frames,
    }) async {
      var largest = 1.0;
      for (var i = 0; i < frames; i++) {
        if (i < changes) set(() => value++);
        await tester.pump(const Duration(milliseconds: 16));
        final scale = _scaleOf(tester, find.byKey(child));
        if (scale > largest) largest = scale;
      }
      return largest;
    }

    testWidgets('one change pops to about the scale asked for', (
      tester,
    ) async {
      await pumpUna(tester, pop());
      final single = await peak(tester, changes: 1, frames: 60);
      expect(single, greaterThan(1.15));
      expect(single, lessThan(1.3));
      await tester.pumpAndSettle();
      expect(_scaleOf(tester, find.byKey(child)), 1);
    });

    testWidgets('a value that changes every frame holds the child at the '
        'peak of one pop instead of blowing it up', (tester) async {
      await pumpUna(tester, pop());
      final single = await peak(tester, changes: 1, frames: 60);
      await tester.pumpAndSettle();

      // A counter ticking every frame for half a second.
      final burst = await peak(tester, changes: 30, frames: 60);
      expect(burst, lessThanOrEqualTo(single + .01));
      expect(burst, greaterThan(1.15), reason: 'the burst did not pop');
      await tester.pumpAndSettle();
      expect(_scaleOf(tester, find.byKey(child)), 1);
    });

    testWidgets('a second change mid-pop takes it back up, never down', (
      tester,
    ) async {
      await pumpUna(tester, pop());
      set(() => value++);
      await tester.pump();
      // Past the peak and on the way down.
      await tester.pump(const Duration(milliseconds: 200));
      final falling = _scaleOf(tester, find.byKey(child));
      expect(falling, greaterThan(1));
      set(() => value++);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      expect(_scaleOf(tester, find.byKey(child)), greaterThan(falling));
      await tester.pumpAndSettle();
    });
  });
}
