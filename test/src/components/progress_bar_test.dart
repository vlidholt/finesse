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
  });
}
