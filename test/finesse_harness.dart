import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The window each form factor is rendered in by [pumpFinesse].
///
/// A common phone and a common laptop, so "does not overflow" means
/// something: the desktop size is above the theme's `md` breakpoint and the
/// phone size below it.
const Map<FormFactor, Size> kSurfaceSizes = {
  FormFactor.desktop: Size(1280, 800),
  FormFactor.mobile: Size(390, 844),
};

/// One of the layouts a widget is expected to survive.
typedef FinesseLayout = ({FormFactor formFactor, TextDirection textDirection});

/// Both form factors, in both text directions.
const List<FinesseLayout> kLayouts = [
  (formFactor: FormFactor.desktop, textDirection: TextDirection.ltr),
  (formFactor: FormFactor.desktop, textDirection: TextDirection.rtl),
  (formFactor: FormFactor.mobile, textDirection: TextDirection.ltr),
  (formFactor: FormFactor.mobile, textDirection: TextDirection.rtl),
];

/// Pumps [child] as the home of a [FinesseApp].
///
/// The window is sized for [formFactor] (or to [surfaceSize]) and the form
/// factor is pinned on the app, so the theme never depends on which of the
/// two this helper happened to set first. [child] is wrapped in a
/// [Directionality] for [textDirection].
///
/// Frames are pumped at fixed intervals rather than with `pumpAndSettle`:
/// several widgets under test animate forever (`TypingIndicator`), and a
/// theme change between two calls is itself a 200 ms animation.
Future<void> pumpFinesse(
  WidgetTester tester,
  Widget child, {
  FormFactor formFactor = FormFactor.desktop,
  TextDirection textDirection = TextDirection.ltr,
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode? themeMode,
  Size? surfaceSize,
  bool pinFormFactor = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = surfaceSize ?? kSurfaceSizes[formFactor]!;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    FinesseApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      formFactor: pinFormFactor ? formFactor : null,
      home: Directionality(textDirection: textDirection, child: child),
    ),
  );
  await settle(tester);
}

/// Lets theme transitions and the short implicit animations inside the
/// widgets under test (120–200 ms) run out, without waiting for anything
/// that never ends.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}

/// Pumps [builder]'s widget in every one of [kLayouts] and fails if any of
/// them throws — a `RenderFlex` overflow above all.
///
/// [check] runs after each pump, for assertions that have to hold in every
/// layout.
Future<void> expectBuildsInEveryLayout(
  WidgetTester tester,
  Widget Function(FinesseLayout layout) builder, {
  ThemeData? theme,
  Future<void> Function(FinesseLayout layout)? check,
}) async {
  for (final layout in kLayouts) {
    await pumpFinesse(
      tester,
      builder(layout),
      formFactor: layout.formFactor,
      textDirection: layout.textDirection,
      theme: theme,
    );
    expect(
      tester.takeException(),
      isNull,
      reason: '${layout.formFactor.name} ${layout.textDirection.name}',
    );
    await check?.call(layout);
  }
}

/// Makes focus highlights show for the rest of the test.
///
/// `Pressable` reports [WidgetState.focused] through a
/// `FocusableActionDetector`, which only shows highlights while the focus
/// manager is in its traditional (pointer-and-keyboard) mode. A test runs as
/// Android, where the mode starts as touch and — since a mouse event no
/// longer flips it — stays there until a key is pressed. On a desktop the
/// mode is traditional from the start, which is what this reproduces.
///
/// Hover needs none of this: `Pressable` takes it from a `MouseRegion`,
/// which reports in every highlight mode.
void useTraditionalHighlights() {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });
}

/// Moves a mouse pointer over [position] and returns its gesture, removing
/// the pointer when the test ends.
Future<TestGesture> hoverAt(WidgetTester tester, Offset position) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await gesture.moveTo(position);
  await tester.pump();
  return gesture;
}

/// The theme the widget found by [finder] sees.
ThemeData themeOf(WidgetTester tester, Finder finder) =>
    Theme.of(tester.element(finder));

/// A 1×1 transparent PNG, for tests that need a real image.
const List<int> kTransparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];
