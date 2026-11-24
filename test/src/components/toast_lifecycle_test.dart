import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A toast has to leave: be taken out of the tree when its exit has played,
/// whatever the motion, and never sit there invisible in front of the page.
///
/// Both ways it failed were found in review. `Toaster.hide` awaited a
/// controller future that the animate widget cancelled as soon as the exit
/// effects were a different length from the entrance's — in every shipped
/// style — so the toast stayed mounted at opacity 0 for ever, taking taps.
/// And with `Motion.none` a `Sonner` toast's zero-length entrance met a
/// controller that was already running, and asserted on every frame.
void main() {
  group('Toaster', () {
    for (final (name, motion) in <(String, Motion?)>[
      ('style default (lively)', null),
      ('calm', Motion.calm),
      ('none', Motion.none),
    ]) {
      testWidgets('Toaster.hide() completes and removes the toast — $name', (
        tester,
      ) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          FinesseApp(
            theme: ThemeData(motion: motion),
            home: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox.expand();
              },
            ),
          ),
        );
        final toaster = Toaster.of(ctx);
        toaster.show(const Toast(title: Text('Saved')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Saved'), findsOneWidget);

        var done = false;
        unawaited(toaster.hide().then((_) => done = true));
        for (var i = 0; i < 120; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(tester.takeException(), isNull);
        expect(done, isTrue, reason: 'hide() never completed');
        expect(find.text('Saved'), findsNothing);
      });

      testWidgets('a toast is gone after its display duration — $name', (
        tester,
      ) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          FinesseApp(
            theme: ThemeData(motion: motion),
            home: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox.expand();
              },
            ),
          ),
        );
        Toaster.of(ctx).show(
          const Toast(
            title: Text('Saved'),
            displayDuration: Duration(seconds: 1),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Saved'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 600));
        for (var i = 0; i < 120; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(tester.takeException(), isNull);
        expect(find.text('Saved'), findsNothing);
      });
    }

    testWidgets('after a toast has timed out, the page under where it was '
        'takes taps again', (tester) async {
      var taps = 0;
      late BuildContext ctx;
      await tester.pumpWidget(
        FinesseApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      );
      Toaster.of(ctx).show(
        Toast(
          title: const Text('Saved'),
          description: const Text('Your changes have been saved.'),
          displayDuration: const Duration(seconds: 1),
          action: Button.outline(onPressed: () {}, child: const Text('Undo')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final where = tester.getCenter(find.text('Saved'));

      // Timed out, and long gone as far as the user can see.
      await tester.pump(const Duration(milliseconds: 600));
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.tapAt(where);
      await tester.pump();
      expect(taps, 1, reason: 'an invisible toast swallowed the tap');
    });
  });

  group('Sonner', () {
    for (final (name, motion, reduce) in <(String, Motion?, bool)>[
      ('Motion.none', Motion.none, false),
      ('reduced motion', null, true),
      ('default', null, false),
    ]) {
      testWidgets('a sonner toast shows and hides without an error — $name', (
        tester,
      ) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          FinesseApp(
            theme: ThemeData(motion: motion),
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(disableAnimations: reduce),
                child: Builder(
                  builder: (context) {
                    ctx = context;
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        );
        final sonner = Sonner.of(ctx);
        final id = sonner.show(const Toast(title: Text('Saved')));
        final errors = <Object>[];
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          final e = tester.takeException();
          if (e != null) errors.add(e as Object);
        }
        expect(errors, isEmpty, reason: 'while showing');
        expect(find.text('Saved'), findsOneWidget);
        unawaited(sonner.hide(id));
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          final e = tester.takeException();
          if (e != null) errors.add(e as Object);
        }
        expect(errors, isEmpty, reason: 'while hiding');
        expect(find.text('Saved'), findsNothing);
      });
    }
  });
}
