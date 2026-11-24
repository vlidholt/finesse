import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping another menubar menu switches to it', (tester) async {
    await tester.pumpWidget(
      const FinesseApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: Menubar(
            items: [
              MenubarItem(
                items: [ContextMenuItem(child: Text('New file'))],
                child: Text('File'),
              ),
              MenubarItem(
                items: [ContextMenuItem(child: Text('Undo'))],
                child: Text('Edit'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('New file'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('New file'), findsNothing);
  });
}
