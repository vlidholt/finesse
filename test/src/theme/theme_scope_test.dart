import 'package:finesse/finesse.dart';
import 'package:finesse/material.dart';
import 'package:flutter/material.dart'
    hide Dialog, Theme, ThemeData, showDialog;
import 'package:flutter/material.dart' as m;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const NeutralColorScheme.dark(),
  );

  group('ThemeScope', () {
    testWidgets('publishes the Finesse theme to its subtree', (tester) async {
      late ThemeData seen;
      await tester.pumpWidget(
        FinesseApp(
          home: ThemeScope(
            data: darkTheme,
            child: Builder(
              builder: (context) {
                seen = Theme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(seen.brightness, Brightness.dark);
    });

    testWidgets('text follows the scoped theme, not the app', (tester) async {
      // The regression this exists for: a dark panel inside a light app used
      // to inherit the app's DefaultTextStyle and render black-on-black.
      late TextStyle style;
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: const NeutralColorScheme.light(),
          ),
          home: ThemeScope(
            data: darkTheme,
            child: Builder(
              builder: (context) {
                style = DefaultTextStyle.of(context).style;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(style.color, darkTheme.colorScheme.foreground);
    });

    testWidgets('icons follow the scoped theme', (tester) async {
      late IconThemeData icons;
      await tester.pumpWidget(
        FinesseApp(
          home: ThemeScope(
            data: darkTheme,
            child: Builder(
              builder: (context) {
                icons = IconTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(icons.color, darkTheme.colorScheme.foreground);
    });

    testWidgets('sets the selection colours', (tester) async {
      late DefaultSelectionStyle selection;
      await tester.pumpWidget(
        FinesseApp(
          home: ThemeScope(
            data: darkTheme,
            child: Builder(
              builder: (context) {
                selection = DefaultSelectionStyle.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(selection.cursorColor, darkTheme.colorScheme.primary);
      expect(selection.selectionColor, darkTheme.colorScheme.selection);
    });

    testWidgets('a FinesseMaterial inside follows the scoped theme', (
      tester,
    ) async {
      late m.ThemeData material;
      await tester.pumpWidget(
        FinesseApp(
          home: ThemeScope(
            data: darkTheme,
            child: FinesseMaterial(
              child: Builder(
                builder: (context) {
                  material = m.Theme.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      expect(material.brightness, Brightness.dark);
      expect(material.colorScheme.surface, darkTheme.colorScheme.background);
    });
  });

  group('showDialog theme inheritance', () {
    testWidgets("a dialog opened from a scope keeps that scope's theme", (
      tester,
    ) async {
      // A route is built under the Navigator, so without the fix the dialog
      // would pick up the app theme and clash with the panel it came from.
      late ThemeData insideDialog;

      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: const NeutralColorScheme.light(),
          ),
          home: ThemeScope(
            data: darkTheme,
            child: Builder(
              builder: (context) => Button(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) {
                    insideDialog = Theme.of(context);
                    return const Dialog(child: Text('hi'));
                  },
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(insideDialog.brightness, Brightness.dark);
      expect(
        insideDialog.colorScheme.background,
        darkTheme.colorScheme.background,
      );
    });
  });
}
