import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/textarea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('Textarea', () {
    testWidgets('Textarea matches golden', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Textarea(
            placeholder: Text('Enter your message'),
          ),
        ),
      );

      await expectLater(
        find.byType(Textarea),
        matchesGoldenFile('goldens/textarea.png'),
      );
    });
  });
}
