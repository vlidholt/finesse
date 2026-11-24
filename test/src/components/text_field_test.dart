import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:flutter/material.dart' hide TextField;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('TextField', () {
    testWidgets('TextField matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const TextField(placeholder: Text('Email')),
        ),
      );

      await expectLater(
        find.byType(TextField),
        matchesGoldenFile('goldens/input.png'),
      );
    });
  });
}
