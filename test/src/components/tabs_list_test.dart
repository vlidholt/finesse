import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tabs without content render only the list', (tester) async {
    String? changed;
    await tester.pumpWidget(
      FinesseApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: Tabs<String>(
            value: 'day',
            onChanged: (v) => changed = v,
            tabs: const [
              Tab(value: 'day', child: Text('Day')),
              Tab(value: 'week', child: Text('Week')),
            ],
          ),
        ),
      ),
    );

    final tabs = tester.getRect(find.byType(Tabs<String>));
    final list = tester.getRect(
      find
          .descendant(
            of: find.byType(Tabs<String>),
            matching: find.byType(Decorator),
          )
          .first,
    );
    // No gap and no panel area below the list.
    expect(tabs.height, list.height);

    await tester.tap(find.text('Week'));
    await tester.pump();
    expect(changed, 'week');
  });
}
