import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/dialog.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:flutter/material.dart' hide Dialog, ThemeData, showDialog;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('showDialog', () {
    Future<void> open(
      WidgetTester tester, {
      bool barrierDismissible = true,
    }) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) => Center(
              child: GestureDetector(
                onTap: () => showDialog<void>(
                  context: context,
                  barrierDismissible: barrierDismissible,
                  builder: (context) => const Dialog(
                    title: Text('Title'),
                    child: Text('Body'),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping the barrier dismisses it', (tester) async {
      await open(tester);
      expect(find.byType(Dialog), findsOneWidget);

      // The corner is outside the centered dialog. The default barrier blur
      // layer sits above the ModalBarrier and must not swallow this tap.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('barrierDismissible: false keeps it open', (tester) async {
      await open(tester, barrierDismissible: false);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('showDialog transition', () {
    testWidgets('the motion is set up once per direction, not on every '
        'tick, and the dialog keeps its state from entrance to exit', (
      tester,
    ) async {
      // A route's transition is rebuilt on each tick of its animation. The
      // widget that moves the dialog used to be made there, so it rebuilt
      // its animations sixty times a second.
      var created = 0;
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) => Center(
              child: GestureDetector(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => Dialog(
                    title: const Text('Title'),
                    child: _Counted(onCreate: () => created++),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      final rebuilt = <String, int>{};
      debugOnRebuildDirtyWidget = (element, builtOnce) {
        final type = element.widget.runtimeType.toString();
        rebuilt[type] = (rebuilt[type] ?? 0) + 1;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);

      await tester.tap(find.text('open'));
      await tester.pump();
      final animate = find.ancestor(
        of: find.text('Title'),
        matching: _dialogMotion,
      );
      expect(animate, findsOneWidget);
      final entering = tester.widget(animate);
      var frames = 0;
      while (animate.evaluate().isNotEmpty) {
        expect(tester.widget(animate), same(entering));
        await tester.pump(const Duration(milliseconds: 16));
        frames++;
        expect(frames, lessThan(120), reason: 'the entrance never ended');
      }
      expect(frames, greaterThan(5), reason: 'the entrance did not animate');
      // Built when it was mounted, and not again.
      expect(rebuilt['_DialogMotion'], 1);
      // At rest the dialog is under no transform.
      expect(find.text('Title'), findsOneWidget);
      expect(created, 1);

      rebuilt.clear();
      Navigator.of(tester.element(find.text('Title'))).pop();
      await tester.pump();
      expect(animate, findsOneWidget);
      final leaving = tester.widget(animate);
      frames = 0;
      while (find.text('Title').evaluate().isNotEmpty) {
        expect(tester.widget(animate), same(leaving));
        await tester.pump(const Duration(milliseconds: 16));
        frames++;
        expect(frames, lessThan(120), reason: 'the exit never ended');
      }
      expect(frames, greaterThan(3), reason: 'the exit did not animate');
      expect(rebuilt['_DialogMotion'], 1);
      expect(created, 1);
    });

    testWidgets('closed part-way in, it turns to its exit', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(
            motion: Motion.lively.copyWith(
              snappy: const MotionSpring(
                duration: Duration(milliseconds: 300),
              ),
              normal: const Duration(milliseconds: 100),
            ),
          ),
          builder: (context, child) => FinesseMaterial(child: child!),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: GestureDetector(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => const Dialog(title: Text('Title')),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final animate = find.ancestor(
        of: find.text('Title'),
        matching: _dialogMotion,
      );
      final entering = tester.widget(animate);

      Navigator.of(tester.element(find.text('Title'))).pop();
      await tester.pump();
      // Another widget for the way out, in the same place: the dialog
      // starts to leave at once, on the exit's own length.
      expect(tester.widget(animate), isNot(same(entering)));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();
      expect(find.text('Title'), findsNothing);
    });
  });

  group('Dialog', () {
    testWidgets('Dialog matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Dialog(
            title: Text('Title'),
            description: Text('Description'),
            child: Text('Child'),
          ),
        ),
      );

      await expectLater(
        find.byType(Dialog),
        matchesGoldenFile('goldens/dialog.png'),
      );
    });
  });
}

class _Counted extends StatefulWidget {
  const _Counted({required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<_Counted> createState() => _CountedState();
}

class _CountedState extends State<_Counted> {
  @override
  void initState() {
    super.initState();
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 60, height: 30);
}

/// The widget that moves a dialog in and out.
final _dialogMotion = find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString() == '_DialogMotion',
);
