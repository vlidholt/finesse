import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('ProgressBar', () {
    testWidgets('ProgressBar indeterminate matches goldens', (tester) async {
      await tester.pumpWidget(createTestWidget(const ProgressBar()));

      await expectLater(
        find.byType(ProgressBar),
        matchesGoldenFile('goldens/progress_indeterminate.png'),
      );
    });

    testWidgets('ProgressBar determinate matches goldens', (tester) async {
      await tester.pumpWidget(createTestWidget(const ProgressBar(value: 0.5)));

      await expectLater(
        find.byType(ProgressBar),
        matchesGoldenFile('goldens/progress_determinate.png'),
      );
    });

    testWidgets('goes indeterminate, determinate and indeterminate again, '
        'and rests while determinate', (tester) async {
      final value = ValueNotifier<double?>(null);
      addTearDown(value.dispose);
      await tester.pumpWidget(
        createTestWidget(
          ValueListenableBuilder<double?>(
            valueListenable: value,
            builder: (context, v, _) => ProgressBar(value: v),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      value.value = .5;
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      value.value = null;
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);
      value.value = .2;
      await tester.pumpAndSettle();
    });
  });
}
