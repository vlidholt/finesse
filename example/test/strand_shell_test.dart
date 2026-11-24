import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/main.dart';
import 'package:example/screens/components_screen.dart';
import 'package:example/strand/screens/home_screen.dart';
import 'package:example/strand/screens/jobs_screen.dart';
import 'package:example/strand/screens/messages_screen.dart';
import 'package:example/strand/screens/network_screen.dart';
import 'package:example/strand/screens/notifications_screen.dart';
import 'package:example/strand/screens/profile_screen.dart';
import 'package:example/strand/screens/search_screen.dart';
import 'package:example/strand/strand_shell.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/search_field.dart';
import 'package:example/strand/widgets/strand_logo.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  setUpAll(setUpFonts);

  Finder inTopBar(Finder finder) =>
      find.descendant(of: find.byType(NavigationBar), matching: finder);
  Finder inBottomBar(Finder finder) =>
      find.descendant(of: find.byType(BottomNavigationBar), matching: finder);
  Finder inAppBar(Finder finder) =>
      find.descendant(of: find.byType(AppBar), matching: finder);

  StrandDestination destination(WidgetTester tester) =>
      strandDestinationProvider.of(appContext(tester)).value;

  /// Opens the menu behind [trigger] and waits out its entrance animation,
  /// during which the items ignore the pointer.
  Future<void> openMenu(WidgetTester tester, Finder trigger) async {
    await tester.tap(trigger);
    await settle(tester);
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await settle(tester);
  }

  group('on a desktop (1440x900)', () {
    testWidgets('the app opens on Strand with the top navigation', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(StrandShell), findsOneWidget);
      expect(Theme.of(appContext(tester)).formFactor, FormFactor.desktop);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);

      // Logo, search, the five destinations with their unread counts.
      expect(inAppBar(find.byType(StrandLogo)), findsOneWidget);
      expect(find.text('strand'), findsOneWidget);
      expect(inAppBar(find.byType(SearchField)), findsOneWidget);
      expect(find.text('Search people, posts, jobs'), findsOneWidget);
      // The key cap names the platform's chord: Ctrl K off Apple's.
      expect(find.text(SearchField.shortcutLabel), findsOneWidget);
      for (final label in [
        'Home',
        'Network',
        'Jobs',
        'Messages',
        'Notifications',
      ]) {
        expect(inTopBar(find.text(label)), findsOneWidget, reason: label);
      }
      expect(inTopBar(find.text('Me')), findsNothing);
      // Two conversations have something unread; twelve notifications do.
      expect(inTopBar(find.text('2')), findsOneWidget);
      expect(inTopBar(find.text('12')), findsOneWidget);
      // Home is selected: its filled icon, the others regular.
      expect(inTopBar(find.byIcon(PhosphorIconsFill.house)), findsOneWidget);
      expect(
        inTopBar(find.byIcon(PhosphorIconsRegular.briefcase)),
        findsOneWidget,
      );
      // The dark-mode button and the avatar pill.
      expect(inAppBar(find.byIcon(PhosphorIconsRegular.moon)), findsOneWidget);
      expect(inAppBar(find.byType(PersonAvatar)), findsOneWidget);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(ThemeCustomizerPanel), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a destination switches screens', (tester) async {
      await pumpApp(tester);

      await tapAndSettle(tester, inTopBar(find.text('Jobs')));
      expect(destination(tester), StrandDestination.jobs);
      expect(find.byType(JobsScreen), findsOneWidget);
      // Still alive, but offstage.
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
      expect(
        inTopBar(find.byIcon(PhosphorIconsFill.briefcase)),
        findsOneWidget,
      );

      await tapAndSettle(tester, inTopBar(find.text('Messages')));
      expect(find.byType(MessagesScreen), findsOneWidget);

      await tapAndSettle(tester, inTopBar(find.text('Network')));
      expect(find.byType(NetworkScreen), findsOneWidget);
      expect(find.text('People you may know'), findsOneWidget);

      await tapAndSettle(tester, inTopBar(find.text('Notifications')));
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('12 unread notifications.'), findsOneWidget);
      // No destination is a placeholder any more.
      expect(
        find.textContaining('not part of the Strand designs'),
        findsNothing,
      );

      // The logo goes home.
      await tapAndSettle(tester, find.byType(StrandLogo));
      expect(destination(tester), StrandDestination.home);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the bell counts the unread notifications', (tester) async {
      await pumpApp(tester);
      final notifications = strandSessionProvider
          .of(appContext(tester))
          .notifications;
      expect(inTopBar(find.text('12')), findsOneWidget);

      await tapAndSettle(tester, inTopBar(find.text('Notifications')));
      // Opening a row reads it.
      await tapAndSettle(tester, find.textContaining('mentioned you').first);
      expect(notifications.unreadCount, 11);
      expect(destination(tester), StrandDestination.home);
      expect(inTopBar(find.text('11')), findsOneWidget);
      expect(inTopBar(find.text('12')), findsNothing);

      await tapAndSettle(tester, inTopBar(find.text('Notifications')));
      await tapAndSettle(
        tester,
        find.widgetWithText(Button, 'Mark all as read'),
      );
      // No count, no badge; the messages' "2" is untouched.
      expect(inTopBar(find.text('11')), findsNothing);
      expect(inTopBar(find.text('2')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the avatar menu leads to the profile, the component library '
        'and the theme editor', (tester) async {
      await pumpApp(tester);
      final pill = inAppBar(find.byIcon(PhosphorIconsRegular.caretDown));

      await openMenu(tester, pill);
      // Once in the menu's header and once on the Home feed's profile card.
      expect(find.text('Noor Haddad'), findsNWidgets(2));
      expect(find.text('Browse components'), findsOneWidget);
      expect(find.text('Open theme editor'), findsOneWidget);

      await tapAndSettle(tester, find.text('View profile'));
      expect(destination(tester), StrandDestination.profile);
      expect(find.byType(ProfileScreen), findsOneWidget);
      // Profile is not a top-bar destination, so nothing reads as selected.
      expect(inTopBar(find.byIcon(PhosphorIconsFill.house)), findsNothing);

      // The theme editor docks beside Strand.
      await openMenu(tester, pill);
      await tapAndSettle(tester, find.text('Open theme editor'));
      final panel = find.byType(ThemeCustomizerPanel);
      expect(panel, findsOneWidget);
      expect(tester.getSize(panel).width, ThemeCustomizerPanel.width);
      expect(
        tester.getSize(find.byType(StrandShell)).width,
        desktopSize.width - ThemeCustomizerPanel.width,
      );
      expect(find.byType(ProfileScreen), findsOneWidget);

      await openMenu(tester, pill);
      await tapAndSettle(tester, find.text('Close theme editor'));
      expect(panel, findsNothing);

      // The component library replaces Strand, and its bar leads back.
      await openMenu(tester, pill);
      await tapAndSettle(tester, find.text('Browse components'));
      expect(sectionSignal(tester).value, AppSection.components);
      expect(find.byType(ComponentsScreen), findsOneWidget);
      expect(find.byType(Sidebar), findsOneWidget);
      expect(find.byType(StrandShell), findsNothing);

      await tapAndSettle(tester, find.byIcon(PhosphorIconsRegular.arrowLeft));
      expect(sectionSignal(tester).value, AppSection.strand);
      expect(find.byType(StrandShell), findsOneWidget);
      // Strand is where it was left.
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the dark-mode button flips the whole app', (tester) async {
      await pumpApp(tester);
      expect(Theme.of(appContext(tester)).brightness, Brightness.light);

      await tapAndSettle(
        tester,
        inAppBar(find.byIcon(PhosphorIconsRegular.moon)),
      );
      expect(Theme.of(appContext(tester)).brightness, Brightness.dark);
      expect(inAppBar(find.byIcon(PhosphorIconsRegular.sun)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a full-screen route covers the shell but not the editor, and '
        'keeps the theme and the providers', (tester) async {
      await pumpApp(tester);
      await openThemeEditor(tester);

      // What a screen does: push from its own context.
      final screen = tester.element(find.byType(HomeScreen));
      screen.pushFullScreen<void>((context) => const SearchScreen());
      await settle(tester);

      expect(find.byType(SearchScreen), findsOneWidget);
      // The shell's chrome is underneath; the editor is still docked.
      expect(find.byType(NavigationBar), findsNothing);
      final panel = find.byType(ThemeCustomizerPanel);
      expect(panel, findsOneWidget);
      expect(
        tester.getSize(find.byType(SearchScreen)).width,
        desktopSize.width - ThemeCustomizerPanel.width,
      );

      // The route follows the editor live…
      final route = tester.element(find.byType(SearchScreen));
      final config = themeConfigProvider.of(route);
      config.value = config.value.copyWith(
        baseColor: BaseColor.zinc,
      );
      await settle(tester);
      expect(
        Theme.of(route).colorScheme.background,
        const ZincColorScheme.light().background,
      );
      // …and can navigate the shell beneath it.
      route.goTo(StrandDestination.jobs);
      await tapAndSettle(tester, find.byIcon(PhosphorIconsRegular.arrowLeft));
      expect(find.byType(SearchScreen), findsNothing);
      expect(find.byType(JobsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('docking the editor beside a medium window lays Strand out '
        'for the space it is left with', (tester) async {
      await pumpApp(tester, size: const Size(900, 800));
      expect(find.byType(NavigationBar), findsOneWidget);

      await openThemeEditor(tester);
      // 900 - 272 is below the phone breakpoint.
      expect(Theme.of(appContext(tester)).formFactor, FormFactor.mobile);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the app bar gives way without overflowing at every width '
        'down to the phone breakpoint', (tester) async {
      for (final width in [1280.0, 1100.0, 960.0, 840.0, 768.0]) {
        await pumpApp(tester, size: Size(width, 800));
        expect(find.byType(NavigationBar), findsOneWidget, reason: '$width');
        expect(tester.takeException(), isNull, reason: 'at $width');
      }
    });

    testWidgets('search is reachable at every width: the field, then a '
        'magnifier in the bar', (tester) async {
      for (final width in [1280.0, 1100.0, 960.0, 900.0, 840.0, 768.0]) {
        await pumpApp(tester, size: Size(width, 800));
        // Either the field itself or the magnifier that opens the page, and
        // never both.
        final field = inAppBar(find.byType(SearchField)).hitTestable();
        final magnifier = inAppBar(
          find.widgetWithIcon(
            IconButton,
            PhosphorIconsRegular.magnifyingGlass,
          ),
        ).hitTestable();
        expect(
          field.evaluate().length + magnifier.evaluate().length,
          1,
          reason: 'at $width',
        );
        expect(tester.takeException(), isNull, reason: 'at $width');
      }

      // In the narrow range the magnifier opens the search page.
      await pumpApp(tester, size: const Size(800, 800));
      await tapAndSettle(
        tester,
        inAppBar(
          find.widgetWithIcon(
            IconButton,
            PhosphorIconsRegular.magnifyingGlass,
          ),
        ).hitTestable(),
      );
      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });

  group('on a phone (390x844)', () {
    testWidgets('the app opens on Strand with the bottom navigation', (
      tester,
    ) async {
      await pumpApp(tester, size: mobileSize);

      expect(find.byType(StrandShell), findsOneWidget);
      expect(Theme.of(appContext(tester)).formFactor, FormFactor.mobile);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // The app bar: logo, then search, notifications (12), messages (2).
      expect(inAppBar(find.byType(StrandLogo)), findsOneWidget);
      expect(find.byType(SearchField), findsNothing);
      expect(
        inAppBar(find.byIcon(PhosphorIconsRegular.magnifyingGlass)),
        findsOneWidget,
      );
      expect(inAppBar(find.byIcon(PhosphorIconsRegular.bell)), findsOneWidget);
      expect(
        inAppBar(find.byIcon(PhosphorIconsRegular.chatCircleDots)),
        findsOneWidget,
      );
      expect(inAppBar(find.text('12')), findsOneWidget);
      expect(inAppBar(find.text('2')), findsOneWidget);
      expect(
        tester.getSize(
          find.ancestor(
            of: find.byIcon(PhosphorIconsRegular.bell),
            matching: find.byType(IconButton),
          ),
        ),
        const Size.square(44),
      );

      // The bottom bar: Home, Network, Create post, Jobs, Me.
      expect(inBottomBar(find.byIcon(PhosphorIconsFill.house)), findsOneWidget);
      expect(
        inBottomBar(find.byIcon(PhosphorIconsRegular.usersThree)),
        findsOneWidget,
      );
      expect(
        inBottomBar(find.byIcon(PhosphorIconsRegular.plus)),
        findsOneWidget,
      );
      expect(
        inBottomBar(find.byIcon(PhosphorIconsRegular.briefcase)),
        findsOneWidget,
      );
      expect(inBottomBar(find.byType(PersonAvatar)), findsOneWidget);
      expect(
        inBottomBar(find.byIcon(PhosphorIconsRegular.chatCircleDots)),
        findsNothing,
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the bars switch screens', (tester) async {
      await pumpApp(tester, size: mobileSize);

      await tapAndSettle(
        tester,
        inBottomBar(find.byIcon(PhosphorIconsRegular.briefcase)),
      );
      expect(find.byType(JobsScreen), findsOneWidget);

      await tapAndSettle(
        tester,
        inBottomBar(find.byIcon(PhosphorIconsRegular.usersThree)),
      );
      expect(find.byType(NetworkScreen), findsOneWidget);

      // Messages and notifications live in the app bar on a phone.
      await tapAndSettle(
        tester,
        inAppBar(find.byIcon(PhosphorIconsRegular.chatCircleDots)),
      );
      expect(destination(tester), StrandDestination.messages);
      expect(find.byType(MessagesScreen), findsOneWidget);

      await tapAndSettle(
        tester,
        inAppBar(find.byIcon(PhosphorIconsRegular.bell)),
      );
      expect(destination(tester), StrandDestination.notifications);
      expect(find.byType(NotificationsScreen), findsOneWidget);

      // "Me" opens the profile, which has no app bar over its cover.
      await tapAndSettle(tester, inBottomBar(find.byType(PersonAvatar)));
      expect(destination(tester), StrandDestination.profile);
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      await tapAndSettle(
        tester,
        inBottomBar(find.byIcon(PhosphorIconsRegular.house)),
      );
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search opens as a full-screen route', (tester) async {
      await pumpApp(tester, size: mobileSize);

      await tapAndSettle(
        tester,
        inAppBar(find.byIcon(PhosphorIconsRegular.magnifyingGlass)),
      );
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.byType(SearchField), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);

      await tapAndSettle(tester, find.byIcon(PhosphorIconsRegular.arrowLeft));
      expect(find.byType(SearchScreen), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the create-post action opens the composer', (tester) async {
      await pumpApp(tester, size: mobileSize);

      await tapAndSettle(
        tester,
        inBottomBar(find.byIcon(PhosphorIconsRegular.plus)),
      );
      expect(find.text('Create post'), findsOneWidget);
      expect(find.text('Start a post, Noor…'), findsOneWidget);

      await tapAndSettle(tester, find.text('Cancel'));
      expect(find.text('Create post'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the theme editor covers a phone-sized window, and closes '
        'itself', (tester) async {
      await pumpApp(tester, size: mobileSize);
      await tapAndSettle(
        tester,
        inBottomBar(find.byIcon(PhosphorIconsRegular.usersThree)),
      );

      await openThemeEditor(tester);
      final panel = find.byType(ThemeCustomizerPanel);
      expect(tester.getSize(panel), mobileSize);
      expect(find.text('Style'), findsOneWidget);
      await tapAndSettle(
        tester,
        find.descendant(
          of: panel,
          matching: find.byIcon(PhosphorIconsRegular.x),
        ),
      );
      expect(panel, findsNothing);
      expect(find.byType(NetworkScreen), findsOneWidget);

      await openComponentLibrary(tester);
      expect(find.byType(ComponentsScreen), findsOneWidget);
      expect(find.byType(StrandShell), findsNothing);

      await tapAndSettle(tester, find.byIcon(PhosphorIconsRegular.arrowLeft));
      expect(find.byType(StrandShell), findsOneWidget);
      expect(find.byType(NetworkScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("the profile's menu is the phone's way out of Strand", (
      tester,
    ) async {
      await pumpApp(tester, size: mobileSize);
      await tapAndSettle(tester, inBottomBar(find.byType(PersonAvatar)));

      await openMenu(tester, find.byIcon(PhosphorIconsRegular.dotsThree));
      expect(find.text('View profile'), findsNothing);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Open theme editor'), findsOneWidget);

      await tapAndSettle(tester, find.text('Browse components'));
      expect(find.byType(ComponentsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
