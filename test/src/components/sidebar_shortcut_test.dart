import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// [SidebarScaffold]'s keyboard shortcut, the form factor it lays out for
/// and the name of its trigger.
void main() {
  late SidebarController controller;

  setUp(() => controller = SidebarController());
  tearDown(() => controller.dispose());

  Widget scaffold({Widget child = const SizedBox.expand()}) => SidebarScaffold(
    controller: controller,
    sidebar: const Sidebar(
      children: [Text('Home')],
    ),
    child: child,
  );

  Future<void> pumpApp(
    WidgetTester tester,
    Widget home, {
    FormFactor? formFactor,
    Size size = const Size(1200, 800),
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UnaApp(
        navigatorKey: navigatorKey,
        formFactor: formFactor,
        home: home,
      ),
    );
    await tester.pump();
  }

  /// Presses B with [modifiers] held.
  Future<void> chord(
    WidgetTester tester,
    List<LogicalKeyboardKey> modifiers,
  ) async {
    for (final key in modifiers) {
      await tester.sendKeyDownEvent(key);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    for (final key in modifiers.reversed) {
      await tester.sendKeyUpEvent(key);
    }
    await tester.pump();
  }

  const meta = LogicalKeyboardKey.metaLeft;
  const control = LogicalKeyboardKey.controlLeft;
  const alt = LogicalKeyboardKey.altLeft;

  bool apple() => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => true,
    _ => false,
  };

  group('the shortcut', () {
    testWidgets('is one modifier per platform: Command+B on an Apple '
        'platform, Control+B elsewhere, and no other chord', (tester) async {
      await pumpApp(tester, scaffold());
      final own = apple() ? meta : control;
      final other = apple() ? control : meta;
      expect(controller.isOpen, isTrue);
      await chord(tester, [own]);
      expect(controller.isOpen, isFalse);
      await chord(tester, [own]);
      expect(controller.isOpen, isTrue);
      // Control+B moves the caret back on a Mac; AltGr is Control+Alt on
      // Windows.
      await chord(tester, [other]);
      await chord(tester, [own, alt]);
      await chord(tester, [own, other]);
      expect(controller.isOpen, isTrue);
    }, variant: TargetPlatformVariant.desktop());

    testWidgets('is not heard through a dialog', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await pumpApp(tester, scaffold(), navigatorKey: navigator);
      unawaited(
        showDialog<void>(
          context: navigator.currentContext!,
          builder: (context) => const Dialog(child: Text('Hello')),
        ),
      );
      await tester.pumpAndSettle();
      await chord(tester, [control]);
      expect(controller.isOpen, isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('is not heard in a hidden child of an IndexedStack', (
      tester,
    ) async {
      await pumpApp(
        tester,
        IndexedStack(
          index: 1,
          children: [scaffold(), const SizedBox.expand()],
        ),
      );
      await chord(tester, [control]);
      expect(controller.isOpen, isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('is left to a focused widget that takes the same chord', (
      tester,
    ) async {
      var bold = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await pumpApp(
        tester,
        scaffold(
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(
                LogicalKeyboardKey.keyB,
                control: true,
              ): () =>
                  bold++,
            },
            child: Focus(
              focusNode: focus,
              autofocus: true,
              child: const Text('Editor'),
            ),
          ),
        ),
      );
      await chord(tester, [control]);
      expect(bold, 1);
      expect(controller.isOpen, isTrue);
      // With the focus elsewhere it toggles.
      focus.unfocus();
      await tester.pump();
      await chord(tester, [control]);
      expect(controller.isOpen, isFalse);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });

  group('the form factor', () {
    testWidgets("is the theme's, not the window's", (tester) async {
      // A phone theme in a wide window: the sidebar is a sheet.
      await pumpApp(tester, scaffold(), formFactor: FormFactor.mobile);
      expect(find.text('Home'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      // A desktop theme in a narrow window: it is inline.
      await pumpApp(
        tester,
        scaffold(),
        formFactor: FormFactor.desktop,
        size: const Size(500, 800),
      );
      expect(find.text('Home'), findsOneWidget);
    });
  });

  testWidgets("the trigger is named in the app's language", (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, scaffold(child: const SidebarTrigger()));
    final strings = UnaLocalizations.of(
      tester.element(find.byType(SidebarTrigger)),
    );
    expect(
      find.bySemanticsLabel(strings.navigation.toggleSidebar),
      findsOneWidget,
    );
    handle.dispose();
  });
}
