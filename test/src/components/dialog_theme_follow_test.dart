import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// An open dialog or sheet follows the app theme: switching light/dark while
/// it is open restyles it too. It used to keep the theme it was opened with.
void main() {
  testWidgets('an open dialog follows a light/dark switch', (tester) async {
    final mode = ValueNotifier(ThemeMode.light);
    addTearDown(mode.dispose);
    Brightness? seen;

    await tester.pumpWidget(
      ValueListenableBuilder(
        valueListenable: mode,
        builder: (context, themeMode, _) => UnaApp(
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: const ZincColorScheme.light(),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ZincColorScheme.dark(),
          ),
          home: Builder(
            builder: (context) => Center(
              child: Button(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => Dialog(
                    child: Builder(
                      builder: (context) {
                        seen = Theme.of(context).brightness;
                        return const Text('content');
                      },
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(seen, Brightness.light);

    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle();
    expect(find.text('content'), findsOneWidget);
    expect(seen, Brightness.dark);
  });

  testWidgets('a dialog opened from a re-themed subtree keeps that theme', (
    tester,
  ) async {
    Brightness? seen;
    await tester.pumpWidget(
      UnaApp(
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: const ZincColorScheme.light(),
        ),
        home: ThemeScope(
          data: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ZincColorScheme.dark(),
          ),
          child: Builder(
            builder: (context) => Center(
              child: Button(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => Dialog(
                    child: Builder(
                      builder: (context) {
                        seen = Theme.of(context).brightness;
                        return const Text('content');
                      },
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(seen, Brightness.dark);
  });
}
