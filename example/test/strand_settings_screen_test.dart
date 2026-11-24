import 'package:example/common/app_state.dart';
import 'package:example/strand/screens/settings_screen.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/settings_sections.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'strand_support.dart';
import 'support.dart';

Future<void> _pump(
  WidgetTester tester, {
  Size size = strandDesktop,
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) => pumpStrandScreen(
  tester,
  const SettingsScreen(),
  size: size,
  brightness: brightness,
  textScale: textScale,
  appBar: false,
);

SettingsController _settings(WidgetTester tester) =>
    strandSession(tester).settings;

Future<void> _open(WidgetTester tester, SettingsSection section) async {
  final settings = _settings(tester);
  settings.update(() => settings.section = section);
  await settleFrames(tester, frames: 4);
}

/// The switch of the row titled [title].
Finder _switch(String title) => find.descendant(
  of: find.bySemanticsLabel(title),
  matching: find.byType(Switch),
);

void main() {
  setUpAll(() async {
    await loadStrandTestFont();
    await setUpFonts();
  });

  group('builds without overflowing', () {
    for (final size in strandSizes) {
      for (final brightness in Brightness.values) {
        testWidgets('at ${size.width.toInt()}x${size.height.toInt()}, '
            '${brightness.name}', (tester) async {
          await _pump(tester, size: size, brightness: brightness);
          for (final section in SettingsSection.values) {
            await _open(tester, section);
            expect(find.byType(SettingsSectionView), findsOneWidget);
            await scrollThrough(tester);
            expect(tester.takeException(), isNull, reason: section.label);
          }
        });
      }
    }

    testWidgets('at 1.3x text, on every form factor', (tester) async {
      for (final size in const [strandDesktop, Size(900, 800), strandPhone]) {
        await _pump(tester, size: size, textScale: 1.3);
        for (final section in SettingsSection.values) {
          await _open(tester, section);
          await scrollThrough(tester);
          expect(tester.takeException(), isNull, reason: '$size $section');
        }
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  });

  group('the page', () {
    testWidgets('lists its four pages beside the cards when wide', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
      for (final section in SettingsSection.values) {
        expect(
          find.widgetWithText(Button, section.label),
          findsOneWidget,
          reason: section.label,
        );
      }
      // Opens on Account.
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Sign-in and security'), findsOneWidget);

      await tester.tap(find.widgetWithText(Button, 'Privacy'));
      await settleFrames(tester, frames: 4);
      expect(find.text('Profile visibility'), findsOneWidget);
      expect(find.text('Sign-in and security'), findsNothing);
      expect(_settings(tester).section, SettingsSection.privacy);
    });

    testWidgets('lists them as chips on a phone', (tester) async {
      await _pump(tester, size: strandPhone);

      expect(find.byType(Chip), findsNWidgets(4));
      // The last chip is off the end of the strip until it is scrolled to.
      await scrollToAndTap(tester, find.widgetWithText(Chip, 'Appearance'));
      expect(find.text('Theme'), findsOneWidget);
      expect(
        tester.widget<Chip>(find.widgetWithText(Chip, 'Appearance')).selected,
        isTrue,
      );
    });

    testWidgets('Account: saving is offered once something changed', (
      tester,
    ) async {
      await _pump(tester);
      final save = find.widgetWithText(Button, 'Save changes');
      final discard = find.widgetWithText(Button, 'Discard');
      expect(tester.widget<Button>(save).enabled, isFalse);

      final headline = find.descendant(
        of: find.bySemanticsLabel('Headline'),
        matching: find.byType(TextField),
      );
      await tester.enterText(headline, 'Design lead at Halcyon');
      await tester.pump();
      expect(tester.widget<Button>(save).enabled, isTrue);

      // Discard puts the saved text back.
      await scrollToAndTap(tester, discard);
      expect(
        find.widgetWithText(TextField, 'Senior product designer at Halcyon'),
        findsOneWidget,
      );
      expect(tester.widget<Button>(save).enabled, isFalse);

      await tester.enterText(headline, 'Design lead at Halcyon');
      await tester.pump();
      await scrollToAndTap(tester, save);
      expect(_settings(tester).headline, 'Design lead at Halcyon');
      expect(find.text('Your changes are saved'), findsOneWidget);
      expect(tester.widget<Button>(save).enabled, isFalse);
      await dismissToasts(tester);
    });

    testWidgets('Privacy: the radio group, switches and select are live', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester, SettingsSection.privacy);
      final settings = _settings(tester);

      expect(find.byType(Radio<ProfileVisibility>), findsNWidgets(3));
      await tester.tap(find.text('Connections'));
      await settleFrames(tester, frames: 4);
      expect(settings.visibility, ProfileVisibility.connections);

      expect(settings.readReceipts, isTrue);
      await scrollToAndTap(tester, _switch('Read receipts'));
      expect(settings.readReceipts, isFalse);

      await scrollToAndTap(tester, find.byType(Select<MessagePolicy>));
      await tester.tap(find.text('Connections only').last);
      await settleFrames(tester);
      expect(settings.messages, MessagePolicy.connections);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Notifications: a checkbox per topic and channel', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester, SettingsSection.notifications);
      final settings = _settings(tester);

      expect(
        find.byType(Checkbox),
        findsNWidgets(NotificationTopic.values.length * 2),
      );
      expect(settings.emailed.contains(NotificationTopic.mentions), isFalse);
      await scrollToAndTap(tester, find.bySemanticsLabel('Mentions, email'));
      expect(settings.emailed.contains(NotificationTopic.mentions), isTrue);

      // Pausing disables every one of them.
      await scrollToAndTap(tester, _switch('Pause all notifications'));
      expect(settings.pauseAll, isTrue);
      expect(find.textContaining('Paused.'), findsOneWidget);
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .every(
              (box) => !box.enabled,
            ),
        isTrue,
      );
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('a setting is still set when the page is opened again', (
      tester,
    ) async {
      await _pump(tester);
      await _open(tester, SettingsSection.appearance);
      await scrollToAndTap(tester, _switch('Compact feed'));
      expect(_settings(tester).compactFeed, isTrue);

      // A new page, the same session.
      await _pump(tester);
      expect(find.text('Feed and motion'), findsOneWidget);
      expect(tester.widget<Switch>(_switch('Compact feed')).value, isTrue);
    });
  });

  group('in the app', () {
    Future<void> openFromMenu(WidgetTester tester) async {
      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(PhosphorIconsRegular.caretDown),
        ),
      );
      await settle(tester);
      await tester.tap(find.text('Settings'));
      await settle(tester);
    }

    testWidgets('the avatar menu opens it, over the shell', (tester) async {
      await pumpApp(tester);
      await openFromMenu(tester);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.byIcon(PhosphorIconsRegular.arrowLeft));
      await settle(tester);
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Appearance drives the real theme', (tester) async {
      await pumpApp(tester);
      await openFromMenu(tester);
      await tester.tap(find.widgetWithText(Button, 'Appearance'));
      await settle(tester);
      final page = tester.element(find.byType(SettingsScreen));
      expect(Theme.of(page).brightness, Brightness.light);

      await tester.tap(find.text('Dark'));
      await settle(tester);
      expect(themeModeProvider.of(page).value, ThemeMode.dark);
      expect(
        Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
        Brightness.dark,
      );

      // The slider is the theme editor's text scale.
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(400, 0));
      await settle(tester);
      expect(themeConfigProvider.of(page).value.textScale, 1.3);
      expect(find.text('130%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
