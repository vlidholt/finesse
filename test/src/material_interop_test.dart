import 'dart:io';

import 'package:finesse/finesse.dart';
import 'package:finesse/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide Scrollbar, Slider, TextField, Theme, ThemeData, ThemeMode;
import 'package:flutter/material.dart' as m;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// finesse's core does not depend on Material or Cupertino, which Flutter is
/// moving out of the SDK into the `material_ui` and `cupertino_ui` packages.
/// Interop is opt-in through `package:finesse/material.dart`.
void main() {
  final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ZincColorScheme.dark(),
  );

  test('only lib/material.dart imports Material or Cupertino', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path == 'lib/material.dart') continue;
      final imports = RegExp(
        r'''^\s*(import|export)\s+'package:flutter/(material|cupertino)\.dart''',
        multiLine: true,
      );
      if (imports.hasMatch(file.readAsStringSync())) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });

  group('FinesseApp without FinesseMaterial', () {
    testWidgets('sets the icon and selection styles from the finesse theme', (
      tester,
    ) async {
      late IconThemeData icons;
      late DefaultSelectionStyle selection;
      await tester.pumpWidget(
        FinesseApp(
          themeMode: ThemeMode.dark,
          darkTheme: dark,
          home: Builder(
            builder: (context) {
              icons = IconTheme.of(context);
              selection = DefaultSelectionStyle.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(icons.size, 16);
      expect(icons.color, dark.colorScheme.foreground);
      expect(selection.cursorColor, dark.colorScheme.primary);
      expect(selection.selectionColor, dark.colorScheme.selection);
    });

    testWidgets('pushes pages with a FinessePageRoute', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        FinesseApp(
          navigatorKey: navigator,
          routes: {
            '/': (_) => const Text('home'),
            '/next': (_) => const Text('next'),
          },
        ),
      );
      navigator.currentState!.pushNamed('/next');
      await tester.pumpAndSettle();
      expect(find.text('next'), findsOneWidget);
      expect(
        ModalRoute.of(tester.element(find.text('next'))),
        isA<FinessePageRoute<Object?>>(),
      );
    });

    testWidgets('gives vertical scrollables a Scrollbar on desktop', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.pumpWidget(
        FinesseApp(
          home: ListView(
            children: [for (var i = 0; i < 50; i++) Text('$i')],
          ),
        ),
      );
      expect(find.byType(Scrollbar), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('FinesseMaterial', () {
    testWidgets('derives the Material theme from the finesse theme', (
      tester,
    ) async {
      late m.ThemeData material;
      await tester.pumpWidget(
        FinesseApp(
          themeMode: ThemeMode.dark,
          darkTheme: dark,
          builder: (context, child) => FinesseMaterial(child: child!),
          home: Builder(
            builder: (context) {
              material = m.Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(material.brightness, Brightness.dark);
      expect(material.colorScheme.primary, dark.colorScheme.primary);
      expect(material.colorScheme.surface, dark.colorScheme.background);
    });

    testWidgets('themeBuilder changes the derived theme', (tester) async {
      late m.ThemeData material;
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(
            themeBuilder: (context, theme) =>
                theme.copyWith(splashFactory: NoSplash.splashFactory),
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              material = m.Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(material.splashFactory, NoSplash.splashFactory);
    });

    testWidgets('provides what TextField and Slider need', (
      tester,
    ) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Column(
            children: [m.TextField(), m.Slider(value: .5, onChanged: null)],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(m.TextField));
      expect(MaterialLocalizations.of(context), isNotNull);
      expect(CupertinoLocalizations.of(context), isNotNull);
    });

    testWidgets('keeps the text direction set above it', (tester) async {
      late TextDirection direction;
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: FinesseMaterial(child: child!),
          ),
          home: Builder(
            builder: (context) {
              direction = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(direction, TextDirection.rtl);
    });

    testWidgets('keeps localizations an ancestor already provides', (
      tester,
    ) async {
      await tester.pumpWidget(
        FinesseApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const SizedBox.shrink(),
        ),
      );
      // Only the app's own Localizations: the bridge added no override.
      expect(find.byType(Localizations), findsOneWidget);
    });
  });
}
