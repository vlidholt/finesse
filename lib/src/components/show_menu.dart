part of 'context_menu.dart';

/// Shows a menu at a point or next to a rectangle, for something that has
/// no widget to hang a [ContextMenu] on: a hit on a canvas, a table cell, a
/// row of a virtualised list, an action that picks from a few choices.
///
/// Give either [position], a point in global coordinates — the menu opens
/// with its corner there, as a context menu does at the pointer — or
/// [anchorRect], a rectangle in global coordinates — the menu opens below
/// it, aligned to its start edge, as a [DropdownMenu] does under its
/// trigger. Either way it is mirrored or shifted to stay on screen.
///
/// The [items] are a [ContextMenu]'s: [MenuItem], [MenuCheckboxItem],
/// [MenuRadioGroup], [MenuLabel], [MenuDivider], submenus. The menu takes
/// the keyboard focus, and closes on a tap outside, on Escape and on the
/// system's back gesture.
///
/// The returned future completes when the menu has closed: with the
/// [MenuItem.value] of the row that closed it, or with null when it
/// was dismissed or the row has no value. A row's `onPressed` still runs.
///
/// ```dart
/// final action = await showMenu<CellAction>(
///   context: context,
///   position: details.globalPosition,
///   items: const [
///     MenuItem(value: CellAction.copy, child: Text('Copy')),
///     MenuItem(value: CellAction.clear, child: Text('Clear')),
///   ],
/// );
/// ```
Future<T?> showMenu<T>({
  required BuildContext context,
  required List<Widget> items,
  Offset? position,
  Rect? anchorRect,
  BoxConstraints? constraints,
  String? barrierLabel,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  assert(
    (position == null) != (anchorRect == null),
    'Give showMenu either a position or an anchorRect.',
  );
  // A menu without rows shows nothing, and nothing could close it.
  if (items.isEmpty) return Future<T?>.value();
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);

  // The menu is laid out in the navigator's overlay, which is not the whole
  // screen when the navigator is nested.
  final overlay = navigator.overlay?.context.findRenderObject();
  Offset local(Offset global) => overlay is RenderBox && overlay.hasSize
      ? overlay.globalToLocal(global)
      : global;
  final anchor = anchorRect != null
      ? Rect.fromPoints(
          local(anchorRect.topLeft),
          local(anchorRect.bottomRight),
        )
      : local(position!) & Size.zero;

  // As `showDialog` does: a theme applied to the subtree the menu was
  // opened from is republished in the route, and the app's own is followed
  // live.
  final ambientTheme = Theme.of(context, listen: false);
  final themedLocally =
      ambientTheme != Theme.maybeOf(navigator.context, listen: false);
  final opener = context;

  return navigator.push(
    _MenuRoute<T>(
      anchor: anchor,
      point: position,
      items: items,
      constraints: constraints,
      barrierLabel:
          barrierLabel ?? FinesseLocalizations.of(context).dialog.dismiss,
      // The menu plays its own exit; the route stays for as long.
      reverseTransitionDuration: Motion.of(context).fast,
      themeOf: (routeContext) {
        final appTheme = Theme.maybeOf(routeContext);
        return !themedLocally && appTheme != null
            ? appTheme
            : opener.mounted
            ? Theme.of(opener, listen: false)
            : ambientTheme;
      },
      settings: routeSettings,
    ),
  );
}

/// Holds the value the row that closes a [showMenu] menu hands back.
class _MenuResultHolder {
  Object? value;
}

/// Lets a row reach the [_MenuResultHolder] of the route it is shown in.
class _MenuResult extends InheritedWidget {
  const _MenuResult({required this.holder, required super.child});

  final _MenuResultHolder holder;

  @override
  bool updateShouldNotify(_MenuResult oldWidget) => holder != oldWidget.holder;
}

/// The route of [showMenu]: a [ContextMenu] that is open from the start,
/// anchored to an invisible box at the point or rectangle it was given.
///
/// The menu is the same widget a `DropdownMenu` shows, so it arrives,
/// leaves, takes the focus and paints as one. The route adds what a menu
/// without a trigger needs: something to hold it, a barrier that keeps the
/// page from reacting to the tap that closes it, and a future.
class _MenuRoute<T> extends PopupRoute<T> {
  _MenuRoute({
    required this.anchor,
    required this.point,
    required this.items,
    required this.constraints,
    required this.barrierLabel,
    required this.reverseTransitionDuration,
    required this.themeOf,
    super.settings,
  });

  /// The point (an empty rectangle) or rectangle, in the overlay's
  /// coordinates.
  final Rect anchor;

  /// The point, in global coordinates, the menu opens with its corner on.
  /// Null opens it below [anchor].
  final Offset? point;

  final List<Widget> items;
  final BoxConstraints? constraints;
  final ThemeData Function(BuildContext context) themeOf;

  final _controller = PopoverController(isOpen: true);
  final _result = _MenuResultHolder();

  /// Whether the route has been popped or removed, by the menu or by
  /// anything else.
  bool _leaving = false;

  @override
  void install() {
    super.install();
    _controller.addListener(_menuToggled);
  }

  /// The menu closed itself — a row was chosen, a tap landed outside,
  /// Escape — and takes its route with it.
  void _menuToggled() {
    if (_controller.isOpen || _leaving || !isActive) return;
    final value = _result.value;
    final result = value is T ? value : null;
    if (isCurrent) {
      navigator?.pop(result);
    } else {
      // A row opened something over the menu before closing it.
      _leaving = true;
      navigator?.removeRoute(this, result);
    }
  }

  /// The route was popped — by the menu, or from outside by the back
  /// gesture or `Navigator.pop`. The menu plays its exit while the route
  /// plays its own, which is nothing but the time it takes.
  @override
  bool didPop(T? result) {
    _leaving = true;
    _controller.close();
    return super.didPop(result);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_menuToggled)
      ..dispose();
    super.dispose();
  }

  // The menu animates itself, from the frame it is first on screen.
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  final Duration reverseTransitionDuration;

  // The menu closes itself on a tap outside, at the pointer's down; a
  // barrier that also popped the route on the tap's up would pop the one
  // under it.
  @override
  bool get barrierDismissible => false;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  /// Swallows what lands outside the menu, so the tap that closes it does
  /// not also press what is under it, and gives a screen reader the way
  /// out. Not a `ModalBarrier`: one that does not dismiss plays the
  /// platform's alert sound on every tap.
  @override
  Widget buildModalBarrier() {
    return BlockSemantics(
      child: Semantics(
        label: barrierLabel,
        onTap: _controller.close,
        onDismiss: _controller.close,
        child: const MouseRegion(
          cursor: SystemMouseCursors.basic,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _MenuResult(
      holder: _result,
      child: ThemeScope(
        data: themeOf(context),
        child: Stack(
          children: [
            Positioned.fromRect(
              rect: anchor,
              child: ContextMenu(
                controller: _controller,
                anchor: point != null
                    ? GlobalAnchor(
                        point!,
                        followerAnchor: AlignmentDirectional.topStart,
                      )
                    : DropdownMenu.defaultAnchor,
                constraints: constraints,
                items: items,
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
