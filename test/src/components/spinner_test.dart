import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spinner', () {
    Widget wrap(Widget child) => FinesseApp(home: Center(child: child));

    testWidgets('renders at the requested size and keeps animating', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const Spinner(size: 24)));
      expect(tester.getSize(find.byType(Spinner)), const Size(24, 24));

      // A repeating animation never settles, so pump fixed frames instead of
      // pumpAndSettle (which would time out).
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}
