import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  group('Empty', () {
    Widget wrap(Widget child) => UnaApp(home: Center(child: child));

    testWidgets('falls back to a localized title', (tester) async {
      await tester.pumpWidget(wrap(const Empty()));
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('renders icon, title, description and actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          Empty(
            icon: const Icon(PhosphorIconsRegular.tray),
            title: const Text('Nothing here'),
            description: const Text('Try again later.'),
            actions: [
              Button(onPressed: () {}, child: const Text('Refresh')),
            ],
          ),
        ),
      );
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try again later.'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.tray), findsOneWidget);
    });
  });
}
