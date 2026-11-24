import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/dialog.dart';
import 'package:flutter/material.dart' hide Dialog, showDialog;
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
