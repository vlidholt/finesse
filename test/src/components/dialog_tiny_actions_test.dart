import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  testWidgets('long action labels ellipsize on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UnaApp(
        home: Dialog(
          title: const Text('Delete'),
          actions: [
            Button(
              onPressed: () {},
              child: const Text(
                'Delete this file and every one of its earlier versions now',
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a phone a button fills the dialog, and an action that is '
      'not a button lays out its own', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      UnaApp(
        formFactor: FormFactor.mobile,
        home: Dialog(
          title: const Text('Share'),
          actions: [
            Button.outline(onPressed: () {}, child: const Text('Cancel')),
            // The theme that widens a button used to reach these two as
            // well: a button as wide as a row has no width to take.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button.ghost(onPressed: () {}, child: const Text('Copy')),
                Button(onPressed: () {}, child: const Text('Send')),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final dialog = tester.getRect(find.byType(BackdropSurface));
    final cancel = tester.getRect(find.widgetWithText(Button, 'Cancel'));
    expect(cancel.width, greaterThan(dialog.width - 60));
    // The two in the row keep their own widths, side by side.
    final copy = tester.getRect(find.widgetWithText(Button, 'Copy'));
    final send = tester.getRect(find.widgetWithText(Button, 'Send'));
    expect(copy.width, lessThan(120));
    expect(send.width, lessThan(120));
    expect(copy.center.dy, closeTo(send.center.dy, 1));
    // Stacked from the bottom up: the last action is on top.
    expect(send.center.dy, lessThan(cancel.center.dy));
  });

  testWidgets('on a phone the buttons of a wrap each fill a run', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      UnaApp(
        formFactor: FormFactor.mobile,
        home: Dialog(
          title: const Text('Share'),
          actions: [
            Flexible(
              child: Wrap(
                verticalDirection: VerticalDirection.up,
                children: [
                  Button.outline(onPressed: () {}, child: const Text('Later')),
                  Button(onPressed: () {}, child: const Text('Follow')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final later = tester.getRect(find.widgetWithText(Button, 'Later'));
    final follow = tester.getRect(find.widgetWithText(Button, 'Follow'));
    expect(follow.width, later.width);
    expect(follow.center.dy, lessThan(later.center.dy));
  });

  testWidgets('the phone layout follows the form factor, not the window', (
    tester,
  ) async {
    Widget app(FormFactor formFactor) => UnaApp(
      formFactor: formFactor,
      home: Dialog(
        title: const Text('Delete'),
        actions: [
          Button.outline(onPressed: () {}, child: const Text('Cancel')),
          Button(onPressed: () {}, child: const Text('Delete')),
        ],
      ),
    );
    bool stacked() {
      final cancel = tester.getCenter(find.widgetWithText(Button, 'Cancel'));
      final delete = tester.getCenter(find.widgetWithText(Button, 'Delete'));
      return (cancel.dy - delete.dy).abs() > 10;
    }

    // A phone: a band across the screen, with nothing to round.
    _phone(tester);
    await tester.pumpWidget(app(FormFactor.mobile));
    await tester.pumpAndSettle();
    expect(stacked(), isTrue);
    expect(tester.getSize(find.byType(BackdropSurface)).width, 390);
    expect(_radius(tester), BorderRadius.zero);

    // The desktop layout in the same narrow window.
    await tester.pumpWidget(app(FormFactor.desktop));
    await tester.pumpAndSettle();
    expect(stacked(), isFalse);
    expect(_radius(tester), isNot(BorderRadius.zero));

    // The phone layout in a wide one: the dialog floats, and keeps its
    // corners.
    _phone(tester, width: 900);
    await tester.pumpWidget(app(FormFactor.mobile));
    await tester.pumpAndSettle();
    expect(stacked(), isTrue);
    expect(
      tester.getSize(find.byType(BackdropSurface)).width,
      lessThanOrEqualTo(512),
    );
    expect(_radius(tester), isNot(BorderRadius.zero));
  });

  testWidgets('a dialog inside margins keeps its corners on a phone', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      const UnaApp(
        formFactor: FormFactor.mobile,
        home: Padding(
          padding: EdgeInsets.all(16),
          child: Dialog(title: Text('Floating')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // As wide as its content, not as the room it was given.
    expect(
      tester.getSize(find.byType(BackdropSurface)).width,
      lessThan(358),
    );
    expect(_radius(tester), isNot(BorderRadius.zero));
  });
}

BorderRadiusGeometry _radius(WidgetTester tester) => tester
    .widget<BackdropSurface>(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(BackdropSurface),
      ),
    )
    .borderRadius;

void _phone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
