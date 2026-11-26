import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A `Scaffold` lays its bars over its body and hands the body the room
/// they cover as padding. A sidebar under them starts its column below the
/// top bar and ends it above the bottom one, while its surface runs on
/// beneath them as the page does.
void main() {
  for (final variant in SidebarVariant.values) {
    testWidgets('a $variant sidebar keeps its column clear of the bars', (
      tester,
    ) async {
      await pumpUna(
        tester,
        Scaffold(
          appBar: const AppBar(title: Text('Title')),
          bottomNavigationBar: const SizedBox(height: 60),
          body: SidebarScaffold(
            sidebar: Sidebar(
              variant: variant,
              header: const Text('Header'),
              footer: const Text('Footer'),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );
      final bar = tester.getRect(find.byType(AppBar));
      expect(tester.getRect(find.text('Header')).top, greaterThan(bar.bottom));
      final window = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(
        tester.getRect(find.text('Footer')).bottom,
        lessThanOrEqualTo(window.height - 60),
      );
    });
  }
}
