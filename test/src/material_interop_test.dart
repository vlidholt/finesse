import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide Scrollbar, Slider, TextField, Theme, ThemeData, ThemeMode;
import 'package:flutter/material.dart' as m;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/una.dart';

/// una's core does not depend on Material or Cupertino, which Flutter is
/// moving out of the SDK into the `material_ui` and `cupertino_ui` packages.
/// Interop is opt-in through `package:una/material.dart`.
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
      final source = file.readAsStringSync();
      final material = RegExp(
        r'''^\s*(import|export)\s+'package:flutter/material\.dart''',
        multiLine: true,
      );
      if (material.hasMatch(source)) offenders.add(file.path);
      // The Liquid Glass adapter bridges the theme into the SDK's
      // CupertinoTheme, which liquid_glass_widgets reads; nothing else may.
      if (file.path.startsWith('lib/src/liquid_glass/')) continue;
      final cupertino = RegExp(
        r'''^\s*(import|export)\s+'package:flutter/cupertino\.dart''',
        multiLine: true,
      );
      if (cupertino.hasMatch(source)) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });

  test('only lib/src/liquid_glass/ imports liquid_glass_widgets', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.startsWith('lib/src/liquid_glass/')) continue;
      final imports = RegExp(
        r'''^\s*(import|export)\s+'package:liquid_glass_widgets/''',
        multiLine: true,
      );
      if (imports.hasMatch(file.readAsStringSync())) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });

  group('UnaApp without UnaMaterial', () {
    testWidgets('sets the icon and selection styles from the una theme', (
      tester,
    ) async {
      late IconThemeData icons;
      late DefaultSelectionStyle selection;
      await tester.pumpWidget(
        UnaApp(
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

    testWidgets('pushes pages with a UnaPageRoute', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        UnaApp(
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
        isA<UnaPageRoute<Object?>>(),
      );
    });

    testWidgets('gives vertical scrollables a Scrollbar on desktop', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.pumpWidget(
        UnaApp(
          home: ListView(
            children: [for (var i = 0; i < 50; i++) Text('$i')],
          ),
        ),
      );
      expect(find.byType(Scrollbar), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('UnaMaterial', () {
    testWidgets('derives the Material theme from the una theme', (
      tester,
    ) async {
      late m.ThemeData material;
      await tester.pumpWidget(
        UnaApp(
          themeMode: ThemeMode.dark,
          darkTheme: dark,
          builder: (context, child) => UnaMaterial(child: child!),
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
        UnaApp(
          builder: (context, child) => UnaMaterial(
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
        UnaApp(
          builder: (context, child) => UnaMaterial(child: child!),
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
        UnaApp(
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: UnaMaterial(child: child!),
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
        UnaApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => UnaMaterial(child: child!),
          home: const SizedBox.shrink(),
        ),
      );
      // Only the app's own Localizations: the bridge added no override.
      expect(find.byType(Localizations), findsOneWidget);
    });
  });
}
