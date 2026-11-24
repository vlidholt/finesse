import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a label with no label style and no fallback does not throw', (
    tester,
  ) async {
    await tester.pumpWidget(
      const FinesseApp(
        home: InputDecorator(
          label: Text('Name'),
          decoration: FinesseDecoration(fallbackToLabelStyle: false),
          child: SizedBox(height: 10),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Name'), findsOneWidget);
  });
}
