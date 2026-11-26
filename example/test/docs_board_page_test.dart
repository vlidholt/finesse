import 'dart:io';

import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/board/board_limit.dart';
import 'package:example/docs/examples/board/board_many.dart';
import 'package:example/docs/pages/board.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart' show ByteData, FontLoader;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/una.dart';

import 'support.dart' show setUpFonts;

/// A real font: flutter_test's own draws every glyph an em wide, and rows
/// that fit any real font overflow in it.
const _font = 'DocsBoardTest';

Future<void> _loadFont() async {
  final loader = FontLoader(_font);
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('fonts/JetBrainsMono-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// Pumps the Board page as the component library shows it: inside the
/// docs' `SelectionArea`, which wants every mouse drag for itself.
Future<void> _pumpPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    UnaApp(
      theme: ThemeData(textTheme: TextTheme(family: _font)),
      builder: (context, child) => UnaMaterial(child: child!),
      home: Scaffold(body: ComponentDocPage(doc: boardDoc)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _drag(WidgetTester tester, Finder from, Offset to) async {
  final start = tester.getCenter(from);
  final gesture = await tester.startGesture(
    start,
    kind: PointerDeviceKind.mouse,
  );
  addTearDown(gesture.removePointer);
  const steps = 12;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy((to - start) / steps.toDouble());
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() async {
    await setUpFonts();
    await _loadFont();
  });

  testWidgets('a card is dragged between columns inside the docs page', (
    tester,
  ) async {
    await _pumpPage(tester);
    final card = find.text('Write the launch post');
    final done = tester.getRect(find.text('Done'));
    expect(tester.getCenter(card).dx, lessThan(done.left));

    await _drag(tester, card, tester.getCenter(find.text('Set up analytics')));
    expect(tester.takeException(), isNull);
    // It is in the last column now, and nothing was selected instead.
    expect(tester.getCenter(card).dx, greaterThan(done.left));
    expect(find.text('Write the launch post'), findsOneWidget);
  });

  testWidgets('the full column of the second example turns a card away', (
    tester,
  ) async {
    await _pumpPage(tester);
    final example = find.byType(BoardLimitExample);
    Finder inExample(String text) =>
        find.descendant(of: example, matching: find.text(text));
    expect(inExample('2/2'), findsOneWidget);

    // By its grip: the rest of the card does not drag here.
    final grip = find.descendant(
      of: find.ancestor(
        of: inExample('Export a board as CSV'),
        matching: find.byType(Card),
      ),
      matching: find.byType(BoardDragHandle),
    );
    final home = tester.getCenter(inExample('Export a board as CSV'));
    await _drag(
      tester,
      grip,
      tester.getCenter(inExample('Invite by link')),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getCenter(inExample('Export a board as CSV')), home);
    expect(inExample('2/2'), findsOneWidget);

    // The last column has room.
    await _drag(
      tester,
      grip,
      tester.getCenter(inExample('Two-factor sign-in')),
    );
    expect(
      tester.getCenter(inExample('Export a board as CSV')).dx,
      greaterThan(tester.getRect(inExample('Shipped')).left),
    );
  });

  testWidgets('the third example builds a screenful of its 900 cards', (
    tester,
  ) async {
    await _pumpPage(tester);
    final cards = find.descendant(
      of: find.byType(BoardManyExample),
      matching: find.byType(Card),
    );
    expect(cards, findsWidgets);
    expect(cards.evaluate().length, lessThan(90));
    expect(find.text('Card 1'), findsOneWidget);
    expect(find.text('Card 300'), findsNothing);
  });
}
