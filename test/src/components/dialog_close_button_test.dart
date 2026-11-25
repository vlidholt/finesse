import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// A dialog has no close button unless it asks for one; a sheet keeps its
/// own. Either way the barrier and Escape still dismiss.
void main() {
  final closeIcon = find.byIcon(PhosphorIconsRegular.x);

  Future<void> open(WidgetTester tester, WidgetBuilder builder) async {
    await pumpFinesse(
      tester,
      Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () =>
                showDialog<void>(context: context, builder: builder),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await settle(tester);
  }

  test('no built-in dialog theme shows a close button; the sheet shows '
      'its own', () {
    for (final style in StyleTokens.all) {
      final theme = ThemeData(style: style);
      expect(theme.primaryDialogTheme.showCloseButton, isNull);
      expect(theme.alertDialogTheme.showCloseButton, isNull);
      expect(theme.sheetTheme.showCloseButton, isTrue);
    }
  });

  testWidgets('a dialog shows no close button by default', (tester) async {
    await open(
      tester,
      (context) => const Dialog(title: Text('Edit profile')),
    );
    expect(find.text('Edit profile'), findsOneWidget);
    expect(closeIcon, findsNothing);
  });

  testWidgets('an alert dialog shows none either', (tester) async {
    await open(
      tester,
      (context) => const Dialog.alert(title: Text('Are you sure?')),
    );
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(closeIcon, findsNothing);
  });

  testWidgets('Escape and a tap on the barrier still dismiss it', (
    tester,
  ) async {
    Widget dialog(BuildContext context) =>
        const Dialog(title: Text('Edit profile'));

    await open(tester, dialog);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.text('Edit profile'), findsNothing);

    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(find.text('Edit profile'), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await settle(tester);
    expect(find.text('Edit profile'), findsNothing);
  });

  testWidgets('showCloseButton opts the button back in, and it closes', (
    tester,
  ) async {
    await open(
      tester,
      (context) => const Dialog(
        title: Text('Edit profile'),
        showCloseButton: true,
      ),
    );
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    await settle(tester);
    expect(find.text('Edit profile'), findsNothing);
  });

  testWidgets('closeIcon is the glyph of the button, and only that', (
    tester,
  ) async {
    await open(
      tester,
      (context) => const Dialog(
        title: Text('Edit profile'),
        closeIcon: PhosphorIcon(PhosphorIconsRegular.arrowLeft),
      ),
    );
    // An icon alone does not ask for the button.
    expect(find.byIcon(PhosphorIconsRegular.arrowLeft), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);

    await open(
      tester,
      (context) => const Dialog(
        title: Text('Edit profile'),
        showCloseButton: true,
        closeIcon: PhosphorIcon(PhosphorIconsRegular.arrowLeft),
      ),
    );
    expect(closeIcon, findsNothing);
    final glyph = find.byIcon(PhosphorIconsRegular.arrowLeft);
    expect(
      find.ancestor(of: glyph, matching: find.byType(IconButton)),
      findsOneWidget,
    );
    await tester.tap(glyph);
    await settle(tester);
    expect(find.text('Edit profile'), findsNothing);
  });

  testWidgets('closeButton stands in for the whole button', (tester) async {
    var pressed = 0;
    await open(
      tester,
      (context) => Dialog(
        title: const Text('Edit profile'),
        closeButton: Button.ghost(
          onPressed: () => pressed++,
          child: const Text('Done'),
        ),
      ),
    );
    expect(closeIcon, findsNothing);
    await tester.tap(find.text('Done'));
    await settle(tester);
    // It is the caller's button: the dialog does not close on its behalf.
    expect(pressed, 1);
    expect(find.text('Edit profile'), findsOneWidget);
  });

  testWidgets('a theme can opt every dialog back in', (tester) async {
    final base = ThemeData();
    final theme = base.copyWith(
      primaryDialogTheme: base.primaryDialogTheme.copyWith(
        showCloseButton: true,
      ),
    );
    await pumpFinesse(
      tester,
      theme: theme,
      darkTheme: theme,
      Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => const Dialog(title: Text('Edit profile')),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(closeIcon, findsOneWidget);
  });

  testWidgets('a sheet keeps its close button', (tester) async {
    await pumpFinesse(
      tester,
      Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () => showSheet<void>(
              context: context,
              side: SheetSide.right,
              builder: (context) => const Sheet(title: Text('Filters')),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(find.text('Filters'), findsOneWidget);
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    await settle(tester);
    expect(find.text('Filters'), findsNothing);
  });

  testWidgets('the closeButton of a sheet stands in for the whole button', (
    tester,
  ) async {
    var pressed = 0;
    await pumpFinesse(
      tester,
      Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () => showSheet<void>(
              context: context,
              side: SheetSide.right,
              builder: (context) => Sheet(
                title: const Text('Filters'),
                // Shown even with the built-in button switched off.
                showCloseButton: false,
                closeButton: Button.ghost(
                  onPressed: () => pressed++,
                  child: const Text('Done'),
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(closeIcon, findsNothing);
    await tester.tap(find.text('Done'));
    await settle(tester);
    // It is the caller's button: the sheet does not close on its behalf.
    expect(pressed, 1);
    expect(find.text('Filters'), findsOneWidget);
  });

  testWidgets('the command palette has no close button', (tester) async {
    await pumpFinesse(
      tester,
      Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () => showCommandDialog<String>(
              context: context,
              groups: const [
                CommandGroup(items: [CommandItem(label: 'Calendar')]),
              ],
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(find.text('Calendar'), findsOneWidget);
    expect(closeIcon, findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.text('Calendar'), findsNothing);
  });
}
