import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/page_route/page_route_pages.dart';
import 'package:example/docs/examples/page_route/page_route_push.dart';
import 'package:flutter/widgets.dart';

final pageRouteDoc = ComponentDoc(
  slug: 'page_route',
  title: 'Page Route',
  description:
      'How one page replaces another. `FinessePageRoute` is the route '
      '`FinesseApp` pushes by default: a short slide and a fade on the '
      "theme's motion, from the end side on a phone and a few pixels' "
      'rise on a desktop. A page can be taken back with a gesture: a '
      'drag from its start edge on iOS, and a preview of the predictive '
      'back gesture on Android. `FinessePage` is the same route for a '
      'declared page list.',
  examples: [
    ComponentExample(
      id: 'page_route_push',
      title: 'Pushing pages',
      description:
          '`Navigator.push(FinessePageRoute(builder: ...))`. The page '
          'follows the finger for as long as it is held; past the '
          'middle, or flicked, it leaves, and otherwise it springs back '
          'with the speed it was let go at. `backGesture` is null by '
          'default, which follows the platform; `true`, as here, offers '
          'the swipe everywhere and `false` switches it off. A '
          '`fullscreenDialog` rises from below and never has one, and '
          'neither has a page under a `PopScope` that refuses to pop.',
      minPreviewHeight: 520,
      padding: const EdgeInsets.all(24),
      builder: (_) => const PageRoutePushExample(),
    ),
    ComponentExample(
      id: 'page_route_pages',
      title: 'Declared pages',
      description:
          'With `Navigator.pages`, or a router package, pages are '
          'values. `FinessePage(child: ...)` shows one through the same '
          'route, with `fullscreenDialog`, `maintainState` and '
          '`backGesture`. In `go_router`, return it from a '
          "route's `pageBuilder` with `key: state.pageKey`.",
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(24),
      builder: (_) => const PageRoutePagesExample(),
    ),
  ],
);
