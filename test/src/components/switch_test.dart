import 'package:flutter/material.dart' hide Switch;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/switch.dart';

void main() {
  // Helper method to create a test widget wrapped in UnaApp and Scaffold
  Widget createTestWidget(Widget child) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('Switch', () {
    testWidgets('Switch true matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(Switch(value: true, onChanged: (_) {})),
      );

      await expectLater(
        find.byType(Switch),
        matchesGoldenFile('goldens/switch_on.png'),
      );
    });

    testWidgets('Switch false matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(Switch(value: false, onChanged: (_) {})),
      );

      await expectLater(
        find.byType(Switch),
        matchesGoldenFile('goldens/switch_off.png'),
      );
    });
  });
}
