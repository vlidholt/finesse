import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

void main() {
  testWidgets('a popover opened under a bar does not pad its content by the '
      'bar', (tester) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    final list = GlobalKey();
    await pumpUna(
      tester,
      Scaffold(
        appBar: const AppBar(title: Text('Page')),
        // The overlay a popover opens in is the navigator's, and the
        // navigator is in the scaffold's body, which the bar pads.
        body: Navigator(
          onGenerateRoute: (settings) => UnaPageRoute<void>(
            settings: settings,
            builder: (context) => Center(
              child: Popover(
                controller: controller,
                builder: (context) => SizedBox(
                  width: 120,
                  height: 160,
                  // A list with no padding of its own takes the vertical
                  // `MediaQuery` padding.
                  child: ListView(
                    key: list,
                    children: const [SizedBox(height: 20, child: Text('a'))],
                  ),
                ),
                child: const SizedBox(width: 40, height: 20),
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      MediaQuery.paddingOf(tester.element(find.byType(Popover))).top,
      greaterThan(0),
      reason: 'the page under the bar is padded by it',
    );

    controller.open();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(MediaQuery.paddingOf(list.currentContext!), EdgeInsets.zero);
    expect(
      tester.getRect(find.text('a')).top,
      tester.getRect(find.byKey(list)).top,
    );
  });
}
