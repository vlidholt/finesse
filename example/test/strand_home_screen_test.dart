import 'dart:io';

import 'package:disco/disco.dart';
import 'package:example/common/app_state.dart';
import 'package:example/strand/data.dart';
import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/screens/home_screen.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/home_post_card.dart';
import 'package:example/strand/widgets/home_stories.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The home feed on its own: inside a `Scaffold` with an empty `AppBar`
// rather than the Strand shell, so this file does not depend on the other
// screens and the page still starts where it does under the shell's bar.

/// A real typeface for the layout checks.
///
/// flutter_test's default font draws every glyph a full em wide — about
/// twice the width of body text — so labels that fit comfortably in any
/// real font overflow their buttons and the "nothing overflows" tests fail
/// for the wrong reason. JetBrains Mono ships with the example (for its
/// code blocks) and, being monospaced, is still a little wider than the
/// fonts the app uses: a layout that fits it has room to spare.
const _fontFamily = 'HomeScreenTest';

Future<void> _loadFont() async {
  final loader = FontLoader(_fontFamily);
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('fonts/JetBrainsMono-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

const _desktop = Size(1440, 1000);
const _mobile = Size(390, 844);

Future<void> _settle(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pumpHome(
  WidgetTester tester, {
  Size size = _desktop,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      providers: [
        ...appProviders,
        strandDestinationProvider,
        strandSessionProvider,
      ],
      child: FinesseApp(
        theme: ThemeData(
          brightness: brightness,
          textTheme: TextTheme(family: _fontFamily),
        ),
        home: const Scaffold(appBar: AppBar(), body: HomeScreen()),
      ),
    ),
  );
  await _settle(tester, frames: 4);
}

/// Scrolls the page until [finder] is in the middle of the screen — clear of
/// the app bar the page scrolls under — then taps it.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pump();
  await tester.tap(finder);
  await _settle(tester);
}

Finder _post(FeedPost post) => find.byKey(ValueKey(post.id));

Finder _inPost(FeedPost post, Finder finder) =>
    find.descendant(of: _post(post), matching: finder);

/// The posts on screen, top to bottom.
List<String> _postOrder(WidgetTester tester) => [
  for (final card in tester.widgetList<HomePostCard>(find.byType(HomePostCard)))
    card.post.id,
];

void main() {
  setUpAll(_loadFont);

  group('builds without exceptions', () {
    for (final size in const [
      Size(1440, 1000),
      Size(1100, 800),
      Size(1024, 800),
      Size(860, 800),
      Size(768, 900),
      Size(390, 844),
    ]) {
      for (final brightness in Brightness.values) {
        testWidgets('${size.width.toInt()}x${size.height.toInt()} '
            '${brightness.name}', (tester) async {
          await _pumpHome(tester, size: size, brightness: brightness);

          expect(find.byType(HomeScreen), findsOneWidget);
          expect(find.byType(HomePostCard), findsNWidgets(3));
          expect(tester.takeException(), isNull);

          // Everything below the fold lays out too.
          await tester.drag(
            find.byType(HomeStories),
            const Offset(0, -4000),
            warnIfMissed: false,
          );
          await _settle(tester, frames: 4);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('on a desktop (1440)', () {
    testWidgets('shows the three columns of the design', (tester) async {
      await _pumpHome(tester);
      expect(
        Theme.of(tester.element(find.byType(HomeScreen))).formFactor,
        FormFactor.desktop,
      );

      for (final text in [
        // Left rail.
        'Product designer at Halcyon. Building calmer tools for busy teams.',
        'Copenhagen, Denmark',
        'Profile viewers',
        '128',
        'Post impressions',
        '2,431',
        'Saved items',
        'Your groups',
        'See all',
        'Design Systems Guild',
        '12 new posts',
        'Copenhagen Product Circle',
        'Accessibility Collective',
        // Feed.
        'Add story',
        'Start a post, Noor…',
        'Photo',
        'Video',
        'Write article',
        'For you',
        'Following',
        'Trending',
        'Sort by',
        'Top',
        'Sara Lindqvist and 214 others',
        '38 comments · 12 reposts',
        'View 6 more replies',
        'Add a comment…',
        'ORBITAL.DESIGN · 8 MIN READ',
        'Designing for calm: notes from 40 interviews with screen reader '
            'users',
        'Rafael Cruz and 1,028 others',
        '96 comments · 140 reposts',
        'Copenhagen · 1,240 attending',
        'NOV',
        '28',
        'Interested',
        'Mei Tanaka and 482 others',
        '41 comments',
        // Right rail.
        'Add to your network',
        'Principal PM at Kestrel Health',
        '10 mutual',
        'Show all suggestions',
        'Trending in design',
        '#DesignSystems',
        '4,812 posts',
        'Remote design teams',
        'Help center',
        'Strand © 2026',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.text('Like'), findsNWidgets(3));
      expect(find.text('Follow'), findsNWidgets(2));
      expect(find.text('Connect'), findsNWidgets(3));
      expect(find.text('14 mutual'), findsNWidgets(2));
      // The full post text, not the phone's shorter one.
      expect(
        find.textContaining('The biggest unlock wasn’t a new flow.'),
        findsOneWidget,
      );
      expect(find.text('1 / 2'), findsNothing);
      // Four stories after "Add story", with full names.
      expect(
        find.descendant(
          of: find.byType(HomeStories),
          matching: find.text('Sara Lindqvist'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the cards sit on the designed lines', (tester) async {
      await _pumpHome(tester);
      final theme = Theme.of(tester.element(find.byType(HomeScreen)));
      Finder cardOf(String text) =>
          find.ancestor(of: find.text(text), matching: find.byType(Card));

      // The page starts a page margin below the app bar and its hairline:
      // 64 + 1 + 24.
      final top =
          AppBar.heightOf(tester.element(find.byType(Scaffold))) +
          theme.layoutTheme.pagePadding!.resolve(TextDirection.ltr).top;
      expect(top, 89);
      for (final text in [
        'Profile viewers',
        'Add story',
        'Add to your network',
      ]) {
        expect(tester.getTopLeft(cardOf(text)).dy, top, reason: text);
      }

      // A rail card's heading starts 18 inside the card's hairline, and the
      // widget that ends the row is centred on it: "See all" is shorter
      // than its heading, the close button taller than its.
      for (final (heading, trailing) in [
        ('Your groups', find.text('See all')),
        ('Add to your network', find.bySemanticsLabel('Dismiss')),
        ('Trending in design', find.byIcon(PhosphorIconsRegular.sparkle)),
      ]) {
        final card = tester.getRect(cardOf(heading));
        final title = tester.getRect(find.text(heading));
        final end = tester.getRect(trailing.first);
        expect(title.left, card.left + 19, reason: heading);
        expect(title.height, 22, reason: heading);
        expect(
          title.top,
          card.top + 19 + (end.height > 22 ? (end.height - 22) / 2 : 0),
          reason: heading,
        );
        expect(end.center.dy, title.center.dy, reason: heading);
        expect(end.right, card.right - 19, reason: heading);
      }

      // The stacked discs take the room of the discs alone, so the first
      // one starts where the text column above it does.
      const omar = HomeData.onboardingWorkshop;
      final reactions = tester.getRect(
        _inPost(omar, find.byType(AvatarGroup)),
      );
      expect(reactions.size, const Size(20 + 15 * 2, 20));
      expect(
        reactions.left,
        tester.getTopLeft(_inPost(omar, find.text(omar.body))).dx,
      );
      final mutuals = tester.getRect(
        find
            .ancestor(
              of: find.text('10 mutual'),
              matching: find.byType(Row),
            )
            .first,
      );
      expect(
        tester.getTopLeft(find.text('Rafael Cruz')).dx,
        mutuals.left,
      );
      expect(mutuals.height, 18);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the rails drop away as the window narrows', (tester) async {
      await _pumpHome(tester, size: const Size(1100, 800));
      expect(find.text('Your groups'), findsOneWidget);
      expect(find.text('Add to your network'), findsOneWidget);

      await _pumpHome(tester, size: const Size(1024, 800));
      expect(find.text('Your groups'), findsOneWidget);
      expect(find.text('Add to your network'), findsNothing);
      expect(find.text('Trending in design'), findsNothing);

      await _pumpHome(tester, size: const Size(860, 800));
      expect(find.text('Your groups'), findsOneWidget);

      await _pumpHome(tester, size: const Size(840, 800));
      expect(find.text('Your groups'), findsNothing);
      // Still the desktop feed: the composer and the full post.
      expect(find.text('Start a post, Noor…'), findsOneWidget);
      expect(find.text('Sort by'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the feed control switches between three lists', (
      tester,
    ) async {
      await _pumpHome(tester);
      const omar = HomeData.onboardingWorkshop;
      const aisha = HomeData.calmWriteUp;
      const julian = HomeData.configNordics;
      expect(_postOrder(tester), [omar.id, aisha.id, julian.id]);

      // Following: only Aisha is followed to begin with.
      await _tap(tester, find.text('Following'));
      expect(_postOrder(tester), [aisha.id]);

      // Trending: the most reacted-to first.
      await _tap(tester, find.text('Trending'));
      expect(_postOrder(tester), [aisha.id, julian.id, omar.id]);

      // "Sort by" → Recent puts the newest first again.
      await _tap(tester, find.text('Sort by'));
      await _tap(tester, find.text('Recent'));
      expect(_postOrder(tester), [omar.id, aisha.id, julian.id]);
      expect(find.text('Top'), findsNothing);

      await _tap(tester, find.text('For you'));
      expect(_postOrder(tester), [omar.id, aisha.id, julian.id]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('following an author adds them to the Following list', (
      tester,
    ) async {
      await _pumpHome(tester);
      const omar = HomeData.onboardingWorkshop;

      await _tap(tester, _inPost(omar, find.text('Follow')));
      expect(_inPost(omar, find.text('Following')), findsOneWidget);
      expect(_inPost(omar, find.text('Follow')), findsNothing);

      await _tap(tester, find.text('Following').first);
      expect(_postOrder(tester), [omar.id, HomeData.calmWriteUp.id]);

      // Unfollowing takes the post out again.
      await _tap(tester, _inPost(omar, find.text('Following')));
      expect(_postOrder(tester), [HomeData.calmWriteUp.id]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('liking a post updates its icon and its summary', (
      tester,
    ) async {
      await _pumpHome(tester);
      const omar = HomeData.onboardingWorkshop;
      const aisha = HomeData.calmWriteUp;

      // Omar's post is liked in the design.
      expect(
        _inPost(omar, find.byIcon(PhosphorIconsFill.heart)),
        findsNWidgets(2), // The action, and the "love" reaction disc.
      );
      await _tap(tester, _inPost(omar, find.text('Like')));
      expect(find.text('Sara Lindqvist and 213 others'), findsOneWidget);
      expect(
        _inPost(omar, find.byIcon(PhosphorIconsRegular.heart)),
        findsOneWidget,
      );

      expect(
        _inPost(aisha, find.byIcon(PhosphorIconsRegular.heart)),
        findsOneWidget,
      );
      await _tap(tester, _inPost(aisha, find.text('Like')));
      expect(find.text('Rafael Cruz and 1,029 others'), findsOneWidget);
      expect(
        _inPost(aisha, find.byIcon(PhosphorIconsRegular.heart)),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('"View more replies" reveals and hides the thread', (
      tester,
    ) async {
      await _pumpHome(tester);
      const hidden = 'How did you decide which two screens to keep?';
      expect(find.text(hidden), findsNothing);

      await _tap(tester, find.text('View 6 more replies'));
      expect(find.text(hidden), findsOneWidget);
      expect(find.text('View 6 more replies'), findsNothing);

      await _tap(tester, find.text('Hide replies'));
      expect(find.text(hidden), findsNothing);
      expect(find.text('View 6 more replies'), findsOneWidget);

      // A comment's own like.
      await _tap(tester, find.text('Like · 24'));
      expect(find.text('Liked · 25'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Connect, Interested and Dismiss toggle', (tester) async {
      await _pumpHome(tester);

      await _tap(tester, find.text('Connect').first);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Connect'), findsNWidgets(2));
      await _tap(tester, find.text('Pending'));
      expect(find.text('Connect'), findsNWidgets(3));

      expect(find.byIcon(PhosphorIconsFill.star), findsNothing);
      await _tap(tester, find.text('Interested'));
      expect(find.byIcon(PhosphorIconsFill.star), findsOneWidget);

      await _tap(tester, find.bySemanticsLabel('Dismiss'));
      expect(find.text('Add to your network'), findsNothing);
      expect(find.text('Trending in design'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Start a post" opens the composer', (tester) async {
      await _pumpHome(tester);
      expect(find.text('Create post'), findsNothing);

      await _tap(tester, find.text('Start a post, Noor…'));
      expect(find.text('Create post'), findsOneWidget);
      expect(find.text('Share an update with your network.'), findsOneWidget);

      await _tap(tester, find.text('Cancel'));
      expect(find.text('Create post'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the profile card goes to the profile', (tester) async {
      await _pumpHome(tester);
      final destination = strandDestinationProvider.of(
        tester.element(find.byType(HomeScreen)),
      );
      expect(destination.value, StrandDestination.home);

      await _tap(tester, find.text(People.me.name));
      expect(destination.value, StrandDestination.profile);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the post menu offers to follow the author', (tester) async {
      await _pumpHome(tester);
      const julian = HomeData.configNordics;

      await _tap(
        tester,
        _inPost(julian, find.byIcon(PhosphorIconsRegular.dotsThree)),
      );
      expect(find.text('Save post'), findsOneWidget);
      await _tap(tester, find.text('Follow Julian'));
      expect(_inPost(julian, find.text('Following')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('on a phone (390x844)', () {
    testWidgets('shows the single-column design', (tester) async {
      await _pumpHome(tester, size: _mobile);
      expect(
        Theme.of(tester.element(find.byType(HomeScreen))).formFactor,
        FormFactor.mobile,
      );

      for (final text in [
        'Add story',
        'Julian',
        'Sara',
        'Omar',
        'Freya',
        'For you',
        'Following',
        'Trending',
        'Omar Rahimi',
        '· 2h',
        'Design lead at Birchline',
        'We ran a two-day workshop to rebuild onboarding from scratch. The '
            'biggest unlock was cutting six setup screens down to two, and '
            'letting people skip setup entirely.',
        '1 / 2',
        'Sara and 214 others',
        '215',
        '38',
        '12',
        'Aisha Rahman',
        'Accessibility lead at Orbital',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      // No rails, no composer, no sort menu, no thread, no "Follow".
      for (final text in [
        'Your groups',
        'Add to your network',
        'Start a post, Noor…',
        'Sort by',
        'Add a comment…',
        'Follow',
        'Like',
      ]) {
        expect(find.text(text), findsNothing, reason: text);
      }
      // The stories row scrolls sideways.
      expect(
        find.descendant(
          of: find.byType(HomeStories),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.horizontal,
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('likes, the photo counter and the feed control work', (
      tester,
    ) async {
      await _pumpHome(tester, size: _mobile);
      const omar = HomeData.onboardingWorkshop;

      await _tap(tester, find.text('215'));
      expect(find.text('214'), findsOneWidget);
      expect(find.text('Sara and 213 others'), findsOneWidget);

      await _tap(tester, find.bySemanticsLabel(omar.images.first.alt));
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.bySemanticsLabel(omar.images.last.alt), findsOneWidget);

      await _tap(tester, find.text('Following'));
      expect(_postOrder(tester), [HomeData.calmWriteUp.id]);
      expect(tester.takeException(), isNull);
    });
  });
}
