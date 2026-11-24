import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/date_picker.dart';
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

  group('DatePicker', () {
    testWidgets('DatePicker matches goldens', (tester) async {
      await tester.pumpWidget(createTestWidget(const DatePicker()));

      await expectLater(
        find.byType(DatePicker),
        matchesGoldenFile('goldens/date_picker.png'),
      );
    });
  });
}
