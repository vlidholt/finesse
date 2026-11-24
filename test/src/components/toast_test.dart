import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/toast.dart';
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

  group('Toast', () {
    testWidgets('Toast matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Toast(
            title: Text('Title'),
            description: Text('Description'),
            action: Icon(Icons.create),
            closeIconData: Icons.close,
          ),
        ),
      );

      await expectLater(
        find.byType(Toast),
        matchesGoldenFile('goldens/toast.png'),
      );
    });
  });
}
