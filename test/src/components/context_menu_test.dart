import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/context_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('ContextMenuRegion tapEnabled', () {
    Widget buildRegion({
      FinesseContextMenuController? controller,
      bool? tapEnabled,
    }) {
      return FinesseApp(
        builder: (context, child) => FinesseMaterial(child: child!),
        home: Scaffold(
          body: ContextMenuRegion(
            controller: controller,
            tapEnabled: tapEnabled,
            items: const [ContextMenuItem(child: Text('Item'))],
            child: const SizedBox(width: 200, height: 200, key: Key('target')),
          ),
        ),
      );
    }

    testWidgets(
      'tap opens menu by default on mobile platforms',
      (tester) async {
        final controller = FinesseContextMenuController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(buildRegion(controller: controller));
        await tester.pumpAndSettle();

        expect(controller.isOpen, false);
        await tester.tap(
          find.byKey(const Key('target')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(controller.isOpen, true);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );

    testWidgets(
      'tap does not open menu by default on desktop platforms',
      (tester) async {
        final controller = FinesseContextMenuController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(buildRegion(controller: controller));
        await tester.pumpAndSettle();

        expect(controller.isOpen, false);
        await tester.tap(
          find.byKey(const Key('target')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(controller.isOpen, false);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      }),
    );

    testWidgets(
      'tapEnabled: true opens menu on desktop',
      (tester) async {
        final controller = FinesseContextMenuController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          buildRegion(controller: controller, tapEnabled: true),
        );
        await tester.pumpAndSettle();

        expect(controller.isOpen, false);
        await tester.tap(
          find.byKey(const Key('target')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(controller.isOpen, true);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      }),
    );

    testWidgets(
      'tapEnabled: false prevents tap from opening menu on mobile',
      (tester) async {
        final controller = FinesseContextMenuController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          buildRegion(controller: controller, tapEnabled: false),
        );
        await tester.pumpAndSettle();

        expect(controller.isOpen, false);
        await tester.tap(
          find.byKey(const Key('target')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(controller.isOpen, false);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );

    testWidgets(
      'opening a menu with a disabled item does not assert during build',
      (tester) async {
        final controller = FinesseContextMenuController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          createTestWidget(
            ContextMenuRegion(
              controller: controller,
              items: const [
                ContextMenuItem(child: Text('Enabled')),
                ContextMenuItem(
                  enabled: false,
                  child: Text('Disabled'),
                ),
              ],
              child: const SizedBox(
                width: 200,
                height: 200,
                key: Key('target'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final exceptionBefore = tester.takeException();
        expect(exceptionBefore, isNull);

        await tester.tap(
          find.byKey(const Key('target')),
          buttons: kSecondaryButton,
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Disabled'), findsOneWidget);
      },
    );

    group('ContextMenu', () {
      testWidgets('ContextMenu matches goldens', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            ContextMenuRegion(
              constraints: const BoxConstraints(minWidth: 300),
              items: [
                const ContextMenuItem.inset(
                  child: Text('Back'),
                ),
                const ContextMenuItem.inset(
                  enabled: false,
                  child: Text('Forward'),
                ),
                const ContextMenuItem.inset(
                  child: Text('Reload'),
                ),
                const ContextMenuItem.inset(
                  trailing: Icon(LucideIcons.chevronRight),
                  items: [
                    ContextMenuItem(
                      child: Text('Save Page As...'),
                    ),
                    ContextMenuItem(
                      child: Text('Create Shortcut...'),
                    ),
                    ContextMenuItem(
                      child: Text('Name Window...'),
                    ),
                    ContextMenuItem(
                      child: Text('Developer Tools'),
                    ),
                  ],
                  child: Text('More Tools'),
                ),
                const ContextMenuItem(
                  leading: Icon(LucideIcons.check),
                  child: Text('Show Bookmarks Bar'),
                ),
                const ContextMenuItem.inset(child: Text('Show Full URLs')),
                const Padding(
                  padding: EdgeInsets.fromLTRB(36, 8, 8, 8),
                  child: Text('People'),
                ),
                ContextMenuItem(
                  leading: SizedBox.square(
                    dimension: 16,
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Pedro Duarte'),
                ),
                const ContextMenuItem.inset(child: Text('Colm Tuite')),
              ],
              child: Container(
                width: 300,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Right click here'),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(ContextMenuRegion),
          matchesGoldenFile('goldens/context_menu_region.png'),
        );
      });
    });
  });
}
