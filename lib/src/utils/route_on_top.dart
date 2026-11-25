import 'package:flutter/widgets.dart';

/// Whether [context] is in the route on top of the whole app: the current
/// route of its navigator, in a navigator that is itself in the current
/// route of the navigator around it, all the way up.
///
/// `ModalRoute.isCurrent` answers for one navigator only. A page in a
/// nested navigator stays current under a dialog pushed on the root one,
/// and something listening for a key or a system gesture from that page
/// would act through the dialog's barrier.
///
/// Nothing here is a dependency of [context]: it is meant to be asked when
/// an event arrives. Looking the routes up with `ModalRoute.of` would make
/// each nested navigator depend on the route that hosts it, and a change in
/// that route would rebuild every page in it.
///
/// [context] has to be inside the page of its route: a route's transitions
/// and barrier are built outside it, and from there the route is not
/// found. A context that is not in a route at all counts as on top.
bool isInTopRoute(BuildContext context) {
  if (!context.mounted) return false;
  BuildContext at = context;
  while (true) {
    final navigator = at.findAncestorStateOfType<NavigatorState>();
    if (navigator == null) return true;
    final top = _topRoute(navigator);
    final subtree = top is ModalRoute ? top.subtreeContext : null;
    if (subtree == null || !_isWithin(at, subtree)) return false;
    at = navigator.context;
  }
}

/// The topmost route of [navigator] that is not on its way out.
Route<dynamic>? _topRoute(NavigatorState navigator) {
  Route<dynamic>? top;
  // Stops at the first route it is shown, so nothing is popped.
  navigator.popUntil((route) {
    top = route;
    return true;
  });
  return top;
}

/// Whether [context] is [ancestor] or inside it.
bool _isWithin(BuildContext context, BuildContext ancestor) {
  if (identical(context, ancestor)) return true;
  var found = false;
  context.visitAncestorElements((element) {
    found = identical(element, ancestor);
    return !found;
  });
  return found;
}
