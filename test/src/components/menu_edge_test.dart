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
