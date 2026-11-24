import 'dart:io';

import 'package:disco/disco.dart';
import 'package:example/common/app_state.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/session.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// What the tests of the screens built after the designs share: Network,
// Notifications, Search and Settings.

/// A real typeface for the layout checks.
///
/// flutter_test's default font draws every glyph a full em wide — about
/// twice the width of body text — so labels that fit comfortably in any
/// real font overflow and the "nothing overflows" tests fail for the wrong
/// reason. JetBrains Mono ships with the example and, being monospaced, is
/// still wider than the fonts the app uses: a layout that fits it has room
/// to spare.
const strandTestFont = 'StrandScreenTest';

Future<void> loadStrandTestFont() async {
  final loader = FontLoader(strandTestFont);
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('fonts/JetBrainsMono-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

const strandDesktop = Size(1440, 1000);
const strandPhone = Size(390, 844);

/// The windows every screen is built in: the designs' two canvases and the
/// widths in between, where the columns drop away.
const strandSizes = [
  Size(1440, 1000),
  Size(1200, 900),
  Size(1100, 800),
  Size(1024, 800),
  Size(900, 800),
  Size(800, 800),
  Size(768, 900),
  Size(390, 844),
];

/// Pumps fixed frames: enough for a route transition or a menu's entrance,
/// during which its items ignore the pointer.
Future<void> settleFrames(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Lets every toast on screen run out, so no timer outlives the test.
Future<void> dismissToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 8));
  await settleFrames(tester, frames: 6);
}

/// Pumps [screen] on its own — below the app's providers and inside a
/// `Scaffold`, but not inside the Strand shell — in a window of [size]
/// logical pixels.
Future<void> pumpStrandScreen(
  WidgetTester tester,
  Widget screen, {
  Size size = strandDesktop,
  Brightness brightness = Brightness.light,
  double textScale = 1,
  bool appBar = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      providers: [
        ...appProviders,
        strandDestinationProvider,
        strandSessionProvider,
      ],
      child: FinesseApp(
        theme: ThemeData(
          brightness: brightness,
          textTheme: TextTheme(family: strandTestFont),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: Scaffold(appBar: appBar ? const AppBar() : null, body: screen),
      ),
    ),
  );
  await settleFrames(tester, frames: 4);
}

/// A context below the providers and the theme.
BuildContext strandContext(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first);

StrandSession strandSession(WidgetTester tester) =>
    strandSessionProvider.of(strandContext(tester));

StrandDestination strandDestination(WidgetTester tester) =>
    strandDestinationProvider.of(strandContext(tester)).value;

/// Scrolls [finder] to the middle of the viewport — clear of an app bar or
/// a bottom bar laid over the scroll view — and taps it.
Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pump();
  await tester.tap(finder);
  await settleFrames(tester);
}

/// Drags the page's scroll view to its end and back, so that everything on
/// it is laid out at least once.
Future<void> scrollThrough(WidgetTester tester) async {
  final scrollable = find.byType(SingleChildScrollView).first;
  await tester.drag(scrollable, const Offset(0, -4000));
  await settleFrames(tester, frames: 4);
  await tester.drag(scrollable, const Offset(0, 4000));
  await settleFrames(tester, frames: 4);
}
