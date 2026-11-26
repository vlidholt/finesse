import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../fixture_styles.dart';

void main() {
  group('ScrollAreaTheme', () {
    test('matches .cn-scroll-area-* per style', () {
      final vega = ThemeData(style: FixtureStyles.vega).scrollAreaTheme;
      // `w-2.5 p-px border-l`: a 7px thumb inset 1px.
      expect(vega.thickness, 7);
      expect(vega.crossAxisMargin, 1);
      expect(vega.radius, const Radius.circular(999));
      // lyra and sera square the thumb (`rounded-none`).
      expect(
        ThemeData(style: StyleTokens.lyra).scrollAreaTheme.radius,
        Radius.zero,
      );
      expect(
        ThemeData(style: FixtureStyles.sera).scrollAreaTheme.radius,
        Radius.zero,
      );
    });

    test('the thumb is the border colour', () {
      final theme = ThemeData();
      expect(theme.scrollAreaTheme.thumbColor, theme.colorScheme.border);
    });
  });

  testWidgets('ScrollArea scrolls its content with one scrollbar', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      UnaApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 100,
            width: 100,
            child: ScrollArea(
              controller: controller,
              child: Column(
                children: [
                  for (var i = 0; i < 30; i++)
                    SizedBox(height: 20, child: Text('row $i')),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RawScrollbar), findsOneWidget);
    await tester.drag(find.text('row 0'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
  });

  testWidgets('edge shadows show only where content continues', (
    tester,
  ) async {
    await tester.pumpWidget(
      UnaApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 100,
            width: 100,
            child: ScrollArea(
              edgeShadows: true,
              child: Column(
                children: [
                  for (var i = 0; i < 30; i++)
                    SizedBox(height: 20, child: Text('row $i')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final opacities = tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .map((o) => o.opacity)
        .toList();
    // At the top: nothing before, more after.
    expect(opacities, [0, 1]);
  });
}
