import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/resizable.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/components/resizable.dart';
import 'package:finesse/src/theme/data.dart' as f;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('ResizableController.resize', () {
    ResizableController buildController({
      required List<double> sizes,
      double totalWidth = 100,
      double minSize = 0,
    }) {
      final controller = ResizableController();
      for (var i = 0; i < sizes.length; i++) {
        controller.registerPanel(
          PanelInfo(
            id: i,
            defaultSize: sizes[i],
            minSize: minSize,
            maxSize: 1,
          ),
        );
      }
      controller.totalAvailableWidth = totalWidth;
      return controller;
    }

    test(
      'forward drag: trailing panel collapses, leading pivot grows into next '
      'trailing panel',
      () {
        // 3 panels: 0.40, 0.30, 0.30 (totalWidth=200)
        // Drag divider 0|1 by 90px right → delta = 90/200 = 0.45
        // Leading pivot (0) grows, trailing panels shrink.
        final controller = buildController(
          sizes: [0.40, 0.30, 0.30],
          totalWidth: 200,
        );
        final initialLayout = [0.40, 0.30, 0.30];

        final result = controller.resize(
          delta: 0.45, // 90px / 200px
          initialLayout: initialLayout,
          pivotIndices: [0, 1],
        );

        expect(result, ResizeResult.success);
        expect(controller.getPanelInfo(0).size, closeTo(0.85, 1e-5));
        expect(controller.getPanelInfo(1).size, closeTo(0.00, 1e-5));
        expect(controller.getPanelInfo(2).size, closeTo(0.15, 1e-5));
      },
    );

    test('backward drag: leading panel collapses, trailing pivot grows, '
        'no further cascade when no more leading panels', () {
      // 3 panels: 0.25, 0.50, 0.25, totalWidth=100
      // Drag divider 0|1 left 30px → delta = -0.30
      // Trailing pivot (1) grows, leading panels shrink.
      final controller = buildController(sizes: [0.25, 0.50, 0.25]);
      final initialLayout = [0.25, 0.50, 0.25];

      final result = controller.resize(
        delta: -0.30,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );

      expect(result, ResizeResult.failedLeading);
      expect(controller.getPanelInfo(0).size, closeTo(0.00, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.75, 1e-5));
      expect(controller.getPanelInfo(2).size, closeTo(0.25, 1e-5));
    });

    test('forward drag: trailing collapses, no further cascade when no more '
        'trailing panels', () {
      // 3 panels: 0.25, 0.50, 0.25, totalWidth=100
      // Drag divider 1|2 right 30px → delta = 0.30
      final controller = buildController(sizes: [0.25, 0.50, 0.25]);
      final initialLayout = [0.25, 0.50, 0.25];

      final result = controller.resize(
        delta: 0.30,
        initialLayout: initialLayout,
        pivotIndices: [1, 2],
      );

      expect(result, ResizeResult.failedTrailing);
      expect(controller.getPanelInfo(0).size, closeTo(0.25, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.75, 1e-5));
      expect(controller.getPanelInfo(2).size, closeTo(0.00, 1e-5));
    });

    test('cascade stops when all panels in direction are fully collapsed', () {
      // 2 panels: 0.25, 0.75, totalWidth=100
      // Drag divider 0|1 left 50px → delta = -0.50
      final controller = buildController(sizes: [0.25, 0.75]);
      final initialLayout = [0.25, 0.75];

      final result = controller.resize(
        delta: -0.50,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );

      expect(result, ResizeResult.failedLeading);
      expect(controller.getPanelInfo(0).size, closeTo(0.0, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(1.0, 1e-5));
    });

    test('no-op delta returns initial layout unchanged', () {
      final controller = buildController(sizes: [0.50, 0.50]);
      final initialLayout = [0.50, 0.50];

      final result = controller.resize(
        delta: 0,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );

      expect(result, ResizeResult.success);
      expect(controller.getPanelInfo(0).size, closeTo(0.50, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.50, 1e-5));
    });

    test('drag reversal returns to original layout', () {
      final controller = buildController(sizes: [0.50, 0.50]);
      final initialLayout = [0.50, 0.50];

      // Drag forward
      controller.resize(
        delta: 0.20,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );
      expect(controller.getPanelInfo(0).size, closeTo(0.70, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.30, 1e-5));

      // Drag back to origin (using same initialLayout, delta=0)
      controller.resize(
        delta: 0,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );
      expect(controller.getPanelInfo(0).size, closeTo(0.50, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.50, 1e-5));
    });

    test('max delta capping: delta exceeding available space is capped', () {
      // 2 panels: 0.50, 0.50, totalWidth=100
      // Delta of 0.80 exceeds what trailing panel can give (0.50).
      final controller = buildController(sizes: [0.50, 0.50]);
      final initialLayout = [0.50, 0.50];

      final result = controller.resize(
        delta: 0.80,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );

      expect(result, ResizeResult.failedTrailing);
      expect(controller.getPanelInfo(0).size, closeTo(1.0, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.0, 1e-5));
    });

    test('respects minSize constraints on trailing panels', () {
      final controller = ResizableController();
      controller.registerPanel(
        PanelInfo(id: 0, defaultSize: 0.50, maxSize: 1),
      );
      controller.registerPanel(
        PanelInfo(id: 1, defaultSize: 0.50, minSize: 0.20, maxSize: 1),
      );
      controller.totalAvailableWidth = 100;
      final initialLayout = [0.50, 0.50];

      final result = controller.resize(
        delta: 0.40,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );

      expect(result, ResizeResult.failedTrailing);
      expect(controller.getPanelInfo(0).size, closeTo(0.80, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.20, 1e-5));
    });

    test('respects maxSize constraints on leading pivot', () {
      final controller = ResizableController();
      controller.registerPanel(
        PanelInfo(id: 0, defaultSize: 0.50, maxSize: 0.60),
      );
      controller.registerPanel(
        PanelInfo(id: 1, defaultSize: 0.50, maxSize: 1),
      );
      controller.totalAvailableWidth = 100;
      final initialLayout = [0.50, 0.50];

      final result = controller.resize(
        delta: 0.30,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );

      // Leading pivot can only grow to 0.60, so only 0.10 consumed.
      expect(result, ResizeResult.failedTrailing);
      expect(controller.getPanelInfo(0).size, closeTo(0.60, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.40, 1e-5));
    });

    test('Phase 3 overflow: pivot at max cascades to adjacent panels', () {
      // 3 panels, leading pivot maxSize=0.40
      final controller = ResizableController();
      controller.registerPanel(
        PanelInfo(id: 0, defaultSize: 0.20, maxSize: 1),
      );
      controller.registerPanel(
        PanelInfo(id: 1, defaultSize: 0.40, maxSize: 0.40),
      );
      controller.registerPanel(
        PanelInfo(id: 2, defaultSize: 0.40, maxSize: 1),
      );
      controller.totalAvailableWidth = 100;
      final initialLayout = [0.20, 0.40, 0.40];

      // Drag divider 1|2 right by 0.30 → pivot(1) already at max 0.40.
      // Phase 2 grows pivot by 0.0, overflow 0.30 cascades to panel 0.
      final result = controller.resize(
        delta: 0.30,
        initialLayout: initialLayout,
        pivotIndices: [1, 2],
      );

      expect(result, ResizeResult.success);
      expect(controller.getPanelInfo(0).size, closeTo(0.50, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.40, 1e-5));
      expect(controller.getPanelInfo(2).size, closeTo(0.10, 1e-5));
    });

    test('all panels at minSize: backward drag is a no-op', () {
      final controller = ResizableController();
      controller.registerPanel(
        PanelInfo(id: 0, defaultSize: 0.20, minSize: 0.20, maxSize: 1),
      );
      controller.registerPanel(
        PanelInfo(id: 1, defaultSize: 0.80, maxSize: 1),
      );
      controller.totalAvailableWidth = 100;
      final initialLayout = [0.20, 0.80];

      final result = controller.resize(
        delta: -0.10,
        initialLayout: initialLayout,
        pivotIndices: [0, 1],
      );

      // Panel 0 can't shrink below 0.20, so nothing happens.
      expect(result, ResizeResult.failedLeading);
      expect(controller.getPanelInfo(0).size, closeTo(0.20, 1e-5));
      expect(controller.getPanelInfo(1).size, closeTo(0.80, 1e-5));
    });
  });

  group('Resizable', () {
    testWidgets('Resizable matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ResizablePanelGroup(
            children: [
              ResizablePanel(
                id: 1,
                defaultSize: 0.5,
                child: Container(
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: const Text('One'),
                ),
              ),
              ResizablePanel(
                id: 2,
                defaultSize: 0.5,
                child: Container(
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: const Text('Two'),
                ),
              ),
            ],
          ),
        ),
      );

      await expectLater(
        find.byType(ResizablePanelGroup),
        matchesGoldenFile('goldens/resizable.png'),
      );
    });

    testWidgets('drag start → update → verify layout changes', (tester) async {
      final controller = ResizableController();

      await tester.pumpWidget(
        createTestWidget(
          ResizablePanelGroup(
            controller: controller,
            children: const [
              ResizablePanel(
                id: 1,
                defaultSize: 0.5,
                child: Text('One'),
              ),
              ResizablePanel(
                id: 2,
                defaultSize: 0.5,
                child: Text('Two'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the GestureDetector for the divider
      final gesture = find.byType(GestureDetector);
      expect(gesture, findsWidgets);

      // Simulate a horizontal drag on the divider
      final dividerFinder = gesture.last;
      final dividerCenter = tester.getCenter(dividerFinder);

      await tester.timedDragFrom(
        dividerCenter,
        const Offset(50, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      // After dragging right, panel 0 should be larger and panel 1 smaller
      expect(
        controller.getPanelInfo(0).size,
        greaterThan(controller.getPanelInfo(1).size),
      );
    });

    testWidgets('the controller reads, sets and resets the sizes', (
      tester,
    ) async {
      final controller = ResizableController();
      addTearDown(controller.dispose);
      expect(controller.sizes, isEmpty);
      var notified = 0;
      controller.addListener(() => notified++);

      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            width: 400,
            height: 100,
            child: ResizablePanelGroup(
              controller: controller,
              children: const [
                ResizablePanel(
                  id: 1,
                  defaultSize: 0.5,
                  child: SizedBox.expand(key: ValueKey('one')),
                ),
                ResizablePanel(
                  id: 2,
                  defaultSize: 0.5,
                  minSize: .2,
                  child: SizedBox.expand(key: ValueKey('two')),
                ),
              ],
            ),
          ),
        ),
      );
      expect(controller.sizes, [0.5, 0.5]);
      final one = find.byKey(const ValueKey('one'));
      final two = find.byKey(const ValueKey('two'));
      expect(tester.getSize(one).width, tester.getSize(two).width);

      notified = 0;
      controller.setSizes([0.75, 0.25]);
      await tester.pump();
      expect(notified, 1);
      expect(controller.sizes, [0.75, 0.25]);
      expect(
        tester.getSize(one).width,
        closeTo(tester.getSize(two).width * 3, 1),
      );

      // A size outside the panel's own limits is refused.
      expect(() => controller.setSizes([0.9, 0.1]), throwsException);

      controller.reset();
      await tester.pump();
      expect(controller.sizes, [0.5, 0.5]);
      expect(tester.getSize(one).width, tester.getSize(two).width);
    });

    testWidgets("the theme's handleIcon replaces the grip", (tester) async {
      const icon = SizedBox(key: ValueKey('grip'), width: 6, height: 20);
      Widget group({Widget? handleIcon}) => SizedBox(
        width: 400,
        height: 100,
        child: ResizablePanelGroup(
          showHandle: true,
          handleIcon: handleIcon,
          children: const [
            ResizablePanel(id: 1, defaultSize: 0.5, child: SizedBox.expand()),
            ResizablePanel(id: 2, defaultSize: 0.5, child: SizedBox.expand()),
          ],
        ),
      );

      await tester.pumpWidget(createTestWidget(group()));
      expect(find.byIcon(PhosphorIconsRegular.dotsSixVertical), findsOneWidget);

      await tester.pumpWidget(
        FinesseApp(
          theme: f.ThemeData(
            resizableTheme: const ResizableTheme(handleIcon: icon),
          ),
          home: group(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('grip')), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.dotsSixVertical), findsNothing);

      // The widget's own handle wins over the theme's.
      await tester.pumpWidget(
        FinesseApp(
          theme: f.ThemeData(
            resizableTheme: const ResizableTheme(handleIcon: icon),
          ),
          home: group(
            handleIcon: const SizedBox(key: ValueKey('own'), width: 4),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('own')), findsOneWidget);
      expect(find.byKey(const ValueKey('grip')), findsNothing);
    });
  });
}
