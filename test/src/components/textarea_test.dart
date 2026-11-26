import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/textarea.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
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
