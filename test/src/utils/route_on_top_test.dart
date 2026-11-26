import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// `isInTopRoute` and `isShownOnTop`: what an event handler asks before it
/// acts on an event that is not its own focus's.
void main() {
  testWidgets('a page in a nested navigator is not on top under a dialog '
      'pushed on the root navigator', (tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      UnaApp(
        home: Navigator(
          onGenerateRoute: (_) => UnaPageRoute<void>(
            builder: (context) {
              page = context;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(isInTopRoute(page), isTrue);
    expect(isShownOnTop(page), isTrue);
    // The page's own route stays current: only the root's is covered.
    expect(ModalRoute.of(page)!.isCurrent, isTrue);

    unawaited(
      showDialog<void>(
        context: page,
        builder: (_) => const Dialog(child: Text('Over it')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(ModalRoute.of(page)!.isCurrent, isTrue);
    expect(isInTopRoute(page), isFalse);
    expect(isShownOnTop(page), isFalse);
  });

  testWidgets('a hidden child of an IndexedStack is not shown', (
    tester,
  ) async {
    final contexts = <int, BuildContext>{};
    await tester.pumpWidget(
      UnaApp(
        home: IndexedStack(
          children: [
            for (final i in [0, 1])
              Builder(
                builder: (context) {
                  contexts[i] = context;
                  return const SizedBox.expand();
                },
              ),
          ],
        ),
      ),
    );
    // Both are in the top route; only one is on stage.
    expect(isInTopRoute(contexts[1]!), isTrue);
    expect(isShownOnTop(contexts[0]!), isTrue);
    expect(isShownOnTop(contexts[1]!), isFalse);
  });
}
