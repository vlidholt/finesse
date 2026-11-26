// Every page of the component library, built for real.
//
// The docs browser is pumped directly — `ComponentsScreen` inside a bare
// `UnaApp` on the package's default theme — rather than through the
// example's `App`, so these tests depend on nothing but the docs themselves
// and the package: not on the theme editor or google_fonts.
import 'dart:io';

import 'package:example/docs/docs.dart';
import 'package:example/docs/registry.dart';
import 'package:example/screens/components_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/una.dart';

/// The two windows every page has to survive: a desktop one, where the
/// sidebar is docked and the theme is laid out for a pointer, and a phone,
/// where the page has the whole 390 points and the theme is laid out for
/// touch.
const _desktop = Size(1200, 900);
const _phone = Size(390, 844);

/// A real font for the pages' text.
///
/// flutter_test's default font draws every glyph an em wide, roughly twice
/// the advance of a text face, so a label that fits comfortably in the app
/// overflows in a test. JetBrains Mono ships with the example (for its code
/// blocks) and is still a little wider than a proportional face, which makes
/// it an honest, slightly pessimistic stand-in.
const _family = 'JetBrainsMono';

Future<void> _loadFont() async {
  final loader = FontLoader(_family);
  for (final file in const [
    'fonts/JetBrainsMono-Regular.ttf',
    'fonts/JetBrainsMono-Medium.ttf',
    'fonts/JetBrainsMono-Bold.ttf',
  ]) {
    loader.addFont(rootBundle.load(file));
  }
  await loader.load();
}

/// The `lib/docs/examples/<dir>/` entries of the example's pubspec.
Set<String> _bundledExampleDirs() {
  final entry = RegExp(r'^\s*-\s*(lib/docs/examples/[a-z0-9_]+)/\s*$');
  return {
    for (final line in File('pubspec.yaml').readAsLinesSync())
      if (entry.firstMatch(line) case final match?) match.group(1)!,
  };
}

List<ComponentDoc> get _allDocs => [
  for (final group in docGroups) ...group.pages,
];

/// Pumps the docs browser in a window of [size].
Future<ComponentsScreenState> _pumpDocs(
  WidgetTester tester, {
  required Size size,
  required Brightness brightness,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    UnaApp(
      debugShowCheckedModeBanner: false,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: ThemeData(textTheme: TextTheme(family: _family)),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: TextTheme(family: _family),
      ),
      // The docs pages use Material's SelectionArea, as the example app does
      // under the UnaMaterial that wraps all of it.
      builder: (context, child) => UnaMaterial(child: child!),
      home: const ComponentsScreen(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  return tester.state<ComponentsScreenState>(find.byType(ComponentsScreen));
}

/// Opens [doc] and lets it lay out. Fixed frames, never `pumpAndSettle`:
/// spinners, skeletons, progress bars and the typing indicator animate for
/// as long as they are on screen.
Future<void> _open(
  WidgetTester tester,
  ComponentsScreenState state,
  ComponentDoc doc,
) async {
  state.open(doc.slug);
  await tester.pump();
  // Source files load from the asset bundle and the sidebar scrolls the
  // page's section into view.
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

/// The first line of [error], and where the widget that raised it was
/// created when Flutter says so — which names the example at fault.
String _summary(Object error) {
  final lines = error.toString().split('\n');
  final where = lines.indexWhere((l) => l.contains('error-causing widget'));
  return [
    lines.first,
    if (where >= 0 && where + 1 < lines.length) lines[where + 1].trim(),
  ].join(' ');
}

/// Every example on the page that is showing: the ones the page registers
/// and the ones a written page embeds in its prose.
Iterable<DocExample> _examplesOnScreen(WidgetTester tester) =>
    tester.widgetList<DocExample>(
      find.byType(DocExample, skipOffstage: false),
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont();
  });

  group('registry', () {
    test('every page has a unique slug and something to show', () {
      final slugs = <String>{};
      for (final doc in _allDocs) {
        expect(slugs.add(doc.slug), isTrue, reason: 'duplicate ${doc.slug}');
        expect(
          doc.examples.isNotEmpty || doc.body != null,
          isTrue,
          reason: '${doc.slug} has neither examples nor a body',
        );
        expect(doc.title, isNotEmpty);
        expect(doc.description, isNotEmpty);
      }
    });

    test('the pages for the fork are registered', () {
      final components = {for (final doc in componentDocs) doc.slug};
      expect(
        components,
        containsAll(<String>[
          'glass',
          'app_bar',
          'navigation_bar',
          'scaffold',
          'chip',
          'list_tile',
          'tab_bar',
          'chat_bubble',
          'indicator_badge',
          'avatar_group',
          'icon_tile',
          'timeline',
          'pressable',
          'page_container',
          // Renamed with their widgets.
          'text_field',
          'otp_field',
          'divider',
          'progress_bar',
        ]),
      );
      expect(
        components.intersection({
          'input',
          'input_otp',
          'separator',
          'progress',
        }),
        isEmpty,
      );

      final guides = {
        for (final group in docGroups)
          if (group.title != 'Components')
            for (final doc in group.items) doc.slug,
      };
      expect(guides, containsAll(<String>['form_factors', 'layout', 'icons']));
    });

    test('the component list is alphabetical by title', () {
      final titles = [
        for (final doc in componentDocs) doc.title.toLowerCase(),
      ];
      expect(titles, [...titles]..sort());
    });

    test('a component page keeps its examples in a directory named after '
        'its slug, as the skills generator expects', () {
      for (final doc in componentDocs) {
        expect(
          File('lib/docs/pages/${doc.slug}.dart').existsSync(),
          isTrue,
          reason: 'lib/docs/pages/${doc.slug}.dart',
        );
        for (final example in doc.examples) {
          expect(
            File(example.assetPath(doc.slug)).existsSync(),
            isTrue,
            reason: example.assetPath(doc.slug),
          );
        }
      }
    });
  });

  group('prose', () {
    // What the package no longer has. A page that still mentions one of
    // these is describing shad, not una.
    final stale = [
      RegExp(
        r'\b(eight|vega|mira|luma|sera|rhea|slate|gray|lucide|playground)\b',
        caseSensitive: false,
      ),
      RegExp(r'\bShad[A-Z]\w*|\bshad\b|\b(Slate|Gray)ColorScheme\b'),
      // The widgets that were renamed to Flutter's vocabulary.
      RegExp(r'\b(Input|InputOTP|Separator|Progress)\('),
    ];

    test('no page or example mentions what the fork removed', () {
      final hits = <String>[];
      for (final file
          in Directory('lib/docs')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))) {
        final lines = file.readAsLinesSync();
        for (final (index, line) in lines.indexed) {
          // "Eight rows" in the context-menu page is a count of rows.
          if (line.contains('Eight rows')) continue;
          for (final pattern in stale) {
            final match = pattern.firstMatch(line);
            if (match == null) continue;
            hits.add('${file.path}:${index + 1}: ${match.group(0)}');
          }
        }
      }
      expect(hits, isEmpty);
    });
  });

  group('every page builds', () {
    for (final (name, size) in const [
      ('1200x900', _desktop),
      ('390x844', _phone),
    ]) {
      for (final brightness in Brightness.values) {
        testWidgets('at $name in ${brightness.name}', (tester) async {
          final state = await _pumpDocs(
            tester,
            size: size,
            brightness: brightness,
          );
          final theme = Theme.of(tester.element(find.byType(ComponentsScreen)));
          expect(theme.brightness, brightness);
          expect(
            theme.formFactor,
            size == _phone ? FormFactor.mobile : FormFactor.desktop,
          );

          final failures = <String>[];
          for (final doc in _allDocs) {
            await _open(tester, state, doc);
            expect(state.selectedSlug, doc.slug);
            expect(find.byType(ComponentDocPage), findsOneWidget);

            // Drain every error the page raised, not only the first.
            for (
              Object? error = tester.takeException();
              error != null;
              error = tester.takeException()
            ) {
              failures.add('${doc.slug}: ${_summary(error)}');
            }
            // A page that registers examples shows all of them.
            if (_examplesOnScreen(tester).length < doc.examples.length) {
              failures.add('${doc.slug}: an example is missing from the page');
            }
          }
          expect(failures, isEmpty, reason: failures.join('\n'));
        });
      }
    }
  });

  group('example sources', () {
    testWidgets('every example on every page is a file on disk, in a '
        'bundled directory, and loads from the asset bundle', (tester) async {
      final state = await _pumpDocs(
        tester,
        size: _desktop,
        brightness: Brightness.light,
      );
      final bundled = _bundledExampleDirs();

      // slug/id of every example, registered or embedded in a page's prose.
      final shown = <String>{};
      for (final doc in _allDocs) {
        await _open(tester, state, doc);
        tester.takeException();
        for (final example in _examplesOnScreen(tester)) {
          shown.add(example.example.assetPath(example.slug));
        }
        // And the registered ones, whether or not the page got that far.
        for (final example in doc.examples) {
          shown.add(example.assetPath(doc.slug));
        }
      }
      expect(shown.length, greaterThan(100));

      for (final path in shown) {
        expect(File(path).existsSync(), isTrue, reason: '$path is missing');
        final dir = path.substring(0, path.lastIndexOf('/'));
        expect(
          bundled,
          contains(dir),
          reason: '$dir/ has no asset entry in pubspec.yaml',
        );
      }

      // The real thing: what `CodeBlock.asset` does at run time.
      await tester.runAsync(() async {
        for (final path in shown) {
          final source = await rootBundle.loadString(path, cache: false);
          expect(source, contains('package:una/una.dart'));
        }
      });

      // Nothing left behind: an example file no page shows is dead weight
      // in the bundle, and a bundled directory with no files is a typo.
      final onDisk = {
        for (final file
            in Directory('lib/docs/examples')
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart')))
          file.path.replaceAll(r'\', '/'),
      };
      expect(onDisk.difference(shown), isEmpty, reason: 'unused examples');
      for (final dir in bundled) {
        expect(
          Directory(dir).existsSync() && Directory(dir).listSync().isNotEmpty,
          isTrue,
          reason: 'pubspec.yaml bundles $dir/, which is empty or missing',
        );
      }
    });
  });
}
