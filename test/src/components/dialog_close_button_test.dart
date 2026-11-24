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

  test('no built-in dialog theme carries a close icon; the sheet does', () {
    for (final style in StyleTokens.all) {
      final theme = ThemeData(style: style);
      expect(theme.primaryDialogTheme.closeIconData, isNull);
      expect(theme.alertDialogTheme.closeIconData, isNull);
      expect(theme.sheetTheme.closeIconData, PhosphorIconsRegular.x);
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

  testWidgets('closeIconData opts the button back in, and it closes', (
    tester,
  ) async {
    await open(
      tester,
      (context) => const Dialog(
        title: Text('Edit profile'),
        closeIconData: PhosphorIconsRegular.x,
      ),
    );
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    await settle(tester);
    expect(find.text('Edit profile'), findsNothing);
  });

  testWidgets('a theme can opt every dialog back in', (tester) async {
    final base = ThemeData();
    final theme = base.copyWith(
      primaryDialogTheme: base.primaryDialogTheme.copyWith(
        closeIconData: PhosphorIconsRegular.x,
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
