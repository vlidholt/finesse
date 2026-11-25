import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/scaffold/scaffold_banner.dart';
import 'package:example/docs/examples/scaffold/scaffold_basic.dart';
import 'package:example/docs/examples/scaffold/scaffold_bottom_sheet.dart';
import 'package:example/docs/examples/scaffold/scaffold_drawer.dart';
import 'package:example/docs/examples/scaffold/scaffold_floating_action_button.dart';
import 'package:example/docs/examples/scaffold/scaffold_footer.dart';
import 'package:example/docs/examples/scaffold/scaffold_navigation.dart';
import 'package:flutter/widgets.dart';

final scaffoldDoc = ComponentDoc(
  slug: 'scaffold',
  title: 'Scaffold',
  description:
      'The frame of a screen. `Scaffold` lays an app bar, a banner, a '
      'bottom bar, a footer and a persistent sheet over the page and tells '
      'the page how far to inset itself; floats an action button over its '
      'corner; slides drawers in from its edges; keeps everything clear of '
      'the keyboard; and styles the status bar. `NavigationScaffold` '
      'builds both bars from one list of destinations and moves them with '
      'the form factor.',
  examples: [
    ComponentExample(
      id: 'scaffold_basic',
      title: 'Scaffold',
      description:
          'The bars sit over `body`, not above and below it, so a '
          'translucent bar shows the page scrolling beneath. The '
          '`MediaQuery` padding of the body includes their heights: a '
          '`ListView`, a '
          '`SafeArea` or a `PageContainer` clears them without being '
          'told. Every slot is measured in the frame it is laid out in, '
          'so a bar of any height works and nothing jumps on the first '
          'frame.',
      minPreviewHeight: 580,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ScaffoldBasicExample(),
    ),
    ComponentExample(
      id: 'scaffold_footer',
      title: 'Footer and keyboard',
      description:
          '`footer` rides above the bottom bar and above the software '
          'keyboard; `bottomNavigationBar` stays put and is covered. The '
          'body ends where the keyboard begins, so a focused field is '
          'scrolled into view, and it sees no `viewInsets` of its own. '
          'A footer on the bottom edge is told about the safe area and '
          'should extend under it, as a bar does: wrap one that is not a '
          'bar in a `SafeArea`. `resizeToAvoidBottomInset: false` leaves '
          'the page as it is under the keyboard.',
      minPreviewHeight: 620,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ScaffoldFooterExample(),
    ),
    ComponentExample(
      id: 'scaffold_drawer',
      title: 'Drawer',
      description:
          '`drawer` and `endDrawer` take any widget and open as modal '
          'panels from the start and end edges, at most 360 wide. An '
          '`AppBar` in the scaffold shows the menu button by itself; '
          '`Scaffold.of(context).openDrawer()` or a '
          '`GlobalKey<ScaffoldState>` opens one from anywhere else. On a '
          'touch screen a drag from the edge pulls the drawer out under '
          'the finger — only while the page cannot be popped, since that '
          'edge is otherwise the way back. The scrim, Escape, the system '
          'back gesture and a drag on the panel close it. '
          '`onDrawerChanged` reports each change.',
      minPreviewHeight: 620,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ScaffoldDrawerExample(),
    ),
    ComponentExample(
      id: 'scaffold_floating_action_button',
      title: 'Floating action button',
      description:
          '`floatingActionButton` floats one page margin from the corner '
          'and from whatever is at the bottom: the bottom bar, the footer, '
          'the sheet, the keyboard, the safe area. When those change it '
          'travels on the surface spring; when it appears, goes or is '
          'replaced by a button with another key it pops in and out. '
          '`floatingActionButtonLocation` picks `start`, `center` or '
          '`end`.',
      minPreviewHeight: 620,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ScaffoldFloatingActionButtonExample(),
    ),
    ComponentExample(
      id: 'scaffold_bottom_sheet',
      title: 'Persistent sheet',
      description:
          '`bottomSheet` stays over the end of the page without blocking '
          'it, above the footer: a mini player, a summary. The page is '
          'inset for it and scrolls beneath.',
      minPreviewHeight: 620,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ScaffoldBottomSheetExample(),
    ),
    ComponentExample(
      id: 'scaffold_banner',
      title: 'Banner',
      description:
          '`banner` is a message across the page under the app bar. The '
          'page makes room for it on the surface spring when it comes '
          'and goes, and the banner that is leaving stays drawn until it '
          'is gone.',
      minPreviewHeight: 620,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ScaffoldBannerExample(),
    ),
    ComponentExample(
      id: 'scaffold_navigation',
      title: 'NavigationScaffold',
      description:
          'On a desktop the destinations sit in the middle of the app '
          'bar. On a phone they move to a bottom bar with the `action` in '
          'its middle, and the app bar keeps `leading` and '
          '`mobileActions`. A destination can opt out of either bar: '
          'Notifications is `showInBottomBar: false` here, and is '
          'reached from the bell instead.',
      minPreviewHeight: 560,
      padding: const EdgeInsets.all(16),
      builder: (_) => const ScaffoldNavigationExample(),
    ),
  ],
);
