import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/context_menu.dart' show MenuEdge;
import 'package:una/una.dart';

import '../../una_harness.dart';

/// The first and the last row of a menu round their outer corners to the
/// menu's own, less the padding between them, so the highlight follows the
/// menu's curve on a phone, where its corners are large.
void main() {
  testWidgets('only the end rows of a menu follow its corners', (
    tester,
  ) async {
    await pumpUna(
      tester,
      Column(
        children: MenuEdge.mark([
          for (final label in ['First', 'Middle', 'Last'])
            Builder(
              key: ValueKey(label),
              builder: (context) {
                final rounded = MenuEdge.roundRadius(
                  context,
                  BorderRadius.circular(8),
                  menu: BorderRadius.circular(24),
                  inset: 4,
                );
                return Text(
                  '$label ${rounded.topLeft.x} ${rounded.bottomLeft.x}',
                );
              },
            ),
        ]),
      ),
      formFactor: FormFactor.mobile,
    );
    // The top row's top corners, and the bottom row's bottom ones: 24 less
    // the 4 between them. The middle row keeps the row's own 8.
    expect(find.text('First 20.0 8.0'), findsOneWidget);
    expect(find.text('Middle 8.0 8.0'), findsOneWidget);
    expect(find.text('Last 8.0 20.0'), findsOneWidget);
  });

  test('a single row is at both edges', () {
    final marked = MenuEdge.mark([const SizedBox()]);
    final edge = marked.single as MenuEdge;
    expect(edge.top, isTrue);
    expect(edge.bottom, isTrue);
  });

  test('every row is marked, so a group cannot pass its edge to all of '
      'its rows', () {
    final marked = MenuEdge.mark([
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ]).cast<MenuEdge>();
    expect(
      [for (final e in marked) (e.top, e.bottom)],
      [
        (true, false),
        (false, false),
        (false, true),
      ],
    );
  });

  testWidgets('a radio group at the end of a menu rounds only its last row', (
    tester,
  ) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    await pumpUna(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: DropdownMenu(
          controller: controller,
          items: [
            const MenuItem(child: Text('Top')),
            MenuRadioGroup<int>(
              value: 1,
              onChanged: (_) {},
              children: const [
                MenuRadioItem(value: 1, child: Text('One')),
                MenuRadioItem(value: 2, child: Text('Two')),
                MenuRadioItem(value: 3, child: Text('Three')),
              ],
            ),
          ],
          builder: (context, controller, _) => const Text('Anchor'),
        ),
      ),
      formFactor: FormFactor.mobile,
    );
    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    ({bool top, bool bottom})? edgeOf(String label) =>
        MenuEdge.of(tester.element(find.text(label)));
    expect(edgeOf('Top'), (top: true, bottom: false));
    expect(edgeOf('One'), (top: false, bottom: false));
    expect(edgeOf('Two'), (top: false, bottom: false));
    expect(edgeOf('Three'), (top: false, bottom: true));
  });

  testWidgets('a row never gets smaller corners than its own', (tester) async {
    await pumpUna(
      tester,
      MenuEdge(
        top: true,
        bottom: true,
        child: Builder(
          builder: (context) {
            final rounded = MenuEdge.roundRadius(
              context,
              BorderRadius.circular(10),
              menu: BorderRadius.circular(8),
              inset: 4,
            );
            return Text('${rounded.topLeft.x}');
          },
        ),
      ),
    );
    expect(find.text('10.0'), findsOneWidget);
  });
}
