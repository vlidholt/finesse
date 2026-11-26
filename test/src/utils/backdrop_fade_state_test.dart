import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// A glass surface claims its entrance's fade while it comes in and goes
/// out, and gives it back at rest. Neither may change the shape of the tree
/// around its content: when it did, everything inside a dialog or popover
/// was built again from scratch as the exit began — a search view's query
/// went back to empty and every result showed while the view left.
void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    final glass = platform == TargetPlatform.iOS ? 'Liquid Glass' : 'frosted';

    for (final formFactor in FormFactor.values) {
      testWidgets('$glass dialog, $formFactor: the content keeps its state in '
          'and out', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          _Probe.created = 0;
          await tester.pumpWidget(
            UnaApp(
              formFactor: formFactor,
              home: Builder(
                builder: (context) => Center(
                  child: Button(
                    onPressed: () => showDialog<void>(
                      context: context,
                      // Glass either way: a frosted dialog is glass when
                      // its style has a filter, as the search palette's does.
                      builder: (context) => Dialog(
                        style: DialogTheme(
                          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        ),
                        child: const _Probe(),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          for (var i = 0; i < 30; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(_Probe.created, 1, reason: 'the entrance ended');
          Navigator.of(tester.element(find.byType(_Probe))).pop();
          for (var i = 0; i < 30; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(find.byType(_Probe), findsNothing);
          expect(_Probe.created, 1, reason: 'the exit began');
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('$glass popover: the content keeps its state in and out', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        _Probe.created = 0;
        final controller = PopoverController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          UnaApp(
            formFactor: FormFactor.desktop,
            home: Center(
              child: Popover(
                controller: controller,
                builder: (context) => const _Probe(),
                child: const SizedBox(width: 40, height: 20),
              ),
            ),
          ),
        );
        controller.open();
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(_Probe.created, 1, reason: 'the entrance ended');
        controller.close();
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(find.byType(_Probe), findsNothing);
        expect(_Probe.created, 1, reason: 'the exit began');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}

/// Counts how many times its state was created.
class _Probe extends StatefulWidget {
  const _Probe();

  static int created = 0;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    _Probe.created++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 160, height: 80);
}
