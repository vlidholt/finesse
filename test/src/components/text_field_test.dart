import 'package:flutter/material.dart' hide TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/text_field.dart';

void main() {
  // Helper method to create a test widget wrapped in UnaApp and Scaffold
  Widget createTestWidget(Widget child) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
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
