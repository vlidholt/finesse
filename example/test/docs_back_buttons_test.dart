import 'dart:io';

import 'package:example/docs/examples/list_detail_layout/list_detail_layout_basic.dart';
import 'package:example/docs/examples/page_route/page_route_pages.dart';
import 'package:example/docs/examples/page_route/page_route_push.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart' show ByteData, FontLoader;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart' show setUpFonts;

/// A real font: flutter_test's own draws every glyph an em wide, and rows
/// that fit any real font overflow in it.
const _font = 'DocsBackButtonsTest';

Future<void> _loadFont() async {
  final loader = FontLoader(_font);
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('fonts/JetBrainsMono-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> _pump(WidgetTester tester, Widget example) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    FinesseApp(
      theme: ThemeData(textTheme: TextTheme(family: _font)),
      home: Scaffold(body: Center(child: example)),
    ),
  );
  await tester.pumpAndSettle();
}

/// The docs examples with pages in them leave the way back to the app bar:
/// none of them makes a back button of its own.
void main() {
  setUpAll(() async {
    await setUpFonts();
    await _loadFont();
  });

  testWidgets('page_route_push: a pushed page has the bar\'s back button, a '
      'full-screen dialog its close button, and both go back', (tester) async {
    await _pump(tester, const PageRoutePushExample());
    // The first page has nowhere to go back to.
    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(CloseButton), findsNothing);

    await tester.tap(find.text('Push a page'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsWidgets);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsNothing);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Open a full-screen dialog'));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsOneWidget);
    expect(find.byType(CloseButton), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsNothing);
  });

  testWidgets('page_route_pages: the bar\'s back button pops the page and '
      'the state follows', (tester) async {
    await _pump(tester, const PageRoutePagesExample());
    expect(find.byType(BackButton), findsNothing);
    final person = find.byType(ListTile).first;
    await tester.tap(person);
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.textContaining('Shown because the state'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsNothing);
    expect(find.textContaining('Shown because the state'), findsNothing);
    // The state was cleared: the same person opens again.
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('list_detail_layout: over the list the detail has the bar\'s '
      'back button; beside it, none', (tester) async {
    await _pump(tester, const ListDetailLayoutBasicExample());
    // Side by side.
    await tester.tap(find.text('Ada Okafor'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Phone'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    // Back at the list, with the choice forgotten.
    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Jonas Lind'), findsOneWidget);

    await tester.tap(find.text('Jonas Lind'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
  });
}
