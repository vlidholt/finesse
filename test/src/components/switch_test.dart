import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/switch.dart';
import 'package:flutter/material.dart' hide Switch;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('Switch', () {
    testWidgets('Switch true matches goldens', (tester) async {
      await tester.pumpWidget(createTestWidget(const Switch(value: true)));

      await expectLater(
        find.byType(Switch),
        matchesGoldenFile('goldens/switch_on.png'),
      );
    });

    testWidgets('Switch false matches goldens', (tester) async {
      await tester.pumpWidget(createTestWidget(const Switch(value: false)));

      await expectLater(
        find.byType(Switch),
        matchesGoldenFile('goldens/switch_off.png'),
      );
    });
  });
}
