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
      '`NavigationScaffold` builds both bars from one list of '
      'destinations and moves them with the form factor.',
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
          '`mobileActions`. A destination can opt out of either bar: '
          'Notifications is `showInBottomBar: false` here, and is '
          'reached from the bell instead.',
      minPreviewHeight: 560,
      padding: const EdgeInsets.all(16),
      builder: (_) => const ScaffoldNavigationExample(),
    ),
  ],
);
