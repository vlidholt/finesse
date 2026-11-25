import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/scaffold/scaffold_basic.dart';
import 'package:example/docs/examples/scaffold/scaffold_navigation.dart';
import 'package:flutter/widgets.dart';

final scaffoldDoc = ComponentDoc(
  slug: 'scaffold',
  title: 'Scaffold',
  description:
      'The frame of a screen. `Scaffold` lays an app bar and a bottom bar '
      'over the page and tells the page how far to inset itself; '
      '`NavigationScaffold` builds the navigation from one list of '
      'destinations and moves it with the form factor; '
      '`DestinationStack` keeps each destination\'s page alive.',
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
          'told.',
      minPreviewHeight: 580,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ScaffoldBasicExample(),
    ),
    ComponentExample(
      id: 'scaffold_navigation',
      title: 'NavigationScaffold',
      description:
          'On a desktop the destinations sit in the middle of the app '
          'bar. On a phone they move to a bottom bar with the `action` in '
          'its middle, and the app bar keeps `leading` and '
          '`mobileActions`. `layout` overrides the choice, or asks for '
          'the third: `NavigationLayout.rail` puts a `NavigationRail` '
          'down the start edge under the app bar, for a tablet. A '
          'destination can opt out of a bar: Notifications is '
          '`showInBottomBar: false` here, and is reached from the bell '
          'instead. The body is a `DestinationStack`: scroll a page, '
          'visit another, and come back to where you were.',
      minPreviewHeight: 560,
      padding: const EdgeInsets.all(16),
      builder: (_) => const ScaffoldNavigationExample(),
    ),
  ],
);
