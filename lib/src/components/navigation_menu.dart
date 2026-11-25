import 'dart:async';
import 'dart:math' as math;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/sheet.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/components/navigation_menu.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/content_switch.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:finesse/src/utils/route_on_top.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:finesse/src/utils/spring_size.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One entry of a [NavigationMenu]: a link, or a trigger that opens a
/// panel.
///
/// ```dart
/// // A link: it goes somewhere.
/// NavigationMenuItem(
///   label: const Text('Pricing'),
///   onPressed: () => go('/pricing'),
/// )
///
/// // A trigger: it opens a panel of links.
/// NavigationMenuItem(
///   label: const Text('Products'),
///   builder: (context) => const ProductLinks(),
/// )
/// ```
@immutable
class NavigationMenuItem {
  /// Creates an entry. With a [builder] it is a trigger and opens the panel
  /// the builder returns; without, it is a link and calls [onPressed].
  const NavigationMenuItem({
    required this.label,
    this.leading,
    this.builder,
    this.onPressed,
    this.selected = false,
    this.enabled = true,
  }) : assert(
         builder == null || onPressed == null,
         'An entry with a panel opens the panel when it is pressed: give it '
         'a builder or onPressed, not both.',
       );

  /// The entry's name in the row, and the heading of its content in the
  /// sheet a collapsed menu opens.
  final Widget label;

  /// A widget before the label: an icon.
  final Widget? leading;

  /// Builds the panel this entry opens: usually a few [NavigationMenuLink]s
  /// in a column or a grid. The same content is shown as a section of the
  /// sheet when the menu is collapsed, at the sheet's width, so lay it out
  /// to fit what it is given rather than to a fixed width.
  final WidgetBuilder? builder;

  /// Called when a link is pressed.
  final VoidCallback? onPressed;

  /// Whether this entry is where the user is now: the current page, or the
  /// section the current page belongs to.
  final bool selected;

  /// Whether the entry can be pressed, hovered and focused.
  final bool enabled;
}

/// The links of a site or an app's top level, in a row: some go somewhere,
/// some open a panel of further links under the row.
///
/// ```dart
/// NavigationMenu(
///   items: [
///     NavigationMenuItem(
///       label: const Text('Products'),
///       builder: (context) => SizedBox(
///         width: 320,
///         child: Column(
///           children: [
///             NavigationMenuLink(
///               title: const Text('Analytics'),
///               description: const Text('Traffic and conversion, live.'),
///               onPressed: () => go('/analytics'),
///             ),
///             NavigationMenuLink(
///               title: const Text('Automation'),
///               description: const Text('Rules that run while you sleep.'),
///               onPressed: () => go('/automation'),
///             ),
///           ],
///         ),
///       ),
///     ),
///     NavigationMenuItem(
///       label: const Text('Pricing'),
///       onPressed: () => go('/pricing'),
///     ),
///   ],
/// )
/// ```
///
/// A trigger opens its panel when the pointer rests on it, when it is
/// pressed, and with Enter, Space or the down arrow. There is one panel:
/// moving to another trigger slides it under that trigger and resizes it
/// for the new content, rather than closing one and opening another. It
/// closes when the pointer has left both the row and the panel, on a press
/// outside, on Escape, and when a [NavigationMenuLink] in it is pressed.
///
/// From the keyboard each entry is a Tab stop, and the left and right
/// arrows, Home and End move along the row. With a panel open, Tab goes
/// from its trigger into the panel and on to the next entry.
///
/// **On a phone** — or wherever [collapsed] is true — a row of links has no
/// room and a pointer does not hover, so the menu is one button that opens
/// a sheet: the links as rows, and each trigger's content under its label
/// as a section.
///
/// The panel is a popover (`PopoverTheme` gives its surface) and the
/// triggers are ghost buttons; what is the menu's own is in
/// `NavigationMenuTheme`.
class NavigationMenu extends StatefulWidget {
  /// Creates a navigation menu.
  const NavigationMenu({
    required this.items,
    this.collapsed,
    this.openOnHover = true,
    this.onOpenChanged,
    this.semanticLabel,
    super.key,
  });

  /// The entries, in reading order.
  final List<NavigationMenuItem> items;

  /// Whether the menu is one button that opens a sheet holding every
  /// entry, instead of a row. Defaults to whether the theme's form factor
  /// is a phone's.
  final bool? collapsed;

  /// Whether a panel opens when the pointer rests on its trigger. Without,
  /// it opens on a press only.
  final bool openOnHover;

  /// Called when a panel opens or closes, with the index of the entry whose
  /// panel is now open, or null when none is. A collapsed menu reports its
  /// sheet as index 0 and its closing as null.
  final ValueChanged<int?>? onOpenChanged;

  /// What assistive technology calls the menu. Defaults to a localized
  /// "Navigation menu".
  final String? semanticLabel;

  /// Closes the panel of the menu around [context], or the sheet of a
  /// collapsed one. A [NavigationMenuLink] does it when it is pressed; call
  /// it from any other control in a panel that navigates.
  static void close(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MenuScope>()?.close();

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu>
    with SingleTickerProviderStateMixin {
  final _popover = PopoverController();
  final _tapGroup = Object();
  final _rowKey = GlobalKey();
  final _contentKey = GlobalKey();

  /// One focus node and one key per entry of the row.
  final _nodes = <FocusNode>[];
  final _keys = <GlobalKey>[];

  /// Around the panel's content, to send the focus into it.
  final _panelNode = FocusNode(
    debugLabel: 'NavigationMenu panel',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The panel's place along the row: how far its leading corner is from
  /// the row's, in physical pixels to the right.
  late final SpringController _slide = SpringController(vsync: this);

  /// The entry whose panel is open, and the one whose content the panel
  /// shows — the same while open, and the last one while it leaves.
  int? _open;
  int? _shown;

  /// Which way the content last changed: 1 towards the end of the row.
  int _direction = 1;

  /// Whether the panel has been placed since it last opened. The first
  /// placement is a jump; later ones slide.
  bool _placed = false;
  bool _placementScheduled = false;

  Timer? _openTimer;
  Timer? _closeTimer;
  int? _hovered;
  bool _overPanel = false;
  bool _listeningForEscape = false;

  @override
  void initState() {
    super.initState();
    _syncNodes();
    _popover.addListener(_onPopoverChanged);
  }

  @override
  void didUpdateWidget(NavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
    final open = _open;
    if (open != null &&
        (open >= widget.items.length ||
            widget.items[open].builder == null ||
            !widget.items[open].enabled)) {
      // The entry whose panel was open is gone. Not during build: closing
      // reports to the parent.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _close();
      });
    }
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _listenForEscape(false);
    _popover
      ..removeListener(_onPopoverChanged)
      ..dispose();
    for (final node in _nodes) {
      node.dispose();
    }
    _panelNode.dispose();
    _slide.dispose();
    super.dispose();
  }

  void _syncNodes() {
    while (_nodes.length < widget.items.length) {
      _nodes.add(FocusNode(debugLabel: 'NavigationMenu entry'));
      _keys.add(GlobalKey());
    }
    while (_nodes.length > widget.items.length) {
      _nodes.removeLast().dispose();
      _keys.removeLast();
    }
  }

  NavigationMenuTheme get _theme => Theme.of(context).navigationMenuTheme;

  bool _isTrigger(int index) =>
      index < widget.items.length &&
      widget.items[index].builder != null &&
      widget.items[index].enabled;

  // --- Opening and closing -------------------------------------------------

  void _show(int index) {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _openTimer = _closeTimer = null;
    if (!_isTrigger(index) || _open == index) return;
    final previous = _open;
    setState(() {
      if (previous != null) _direction = index > previous ? 1 : -1;
      _open = _shown = index;
    });
    if (previous == null) _placed = false;
    _popover.open();
    _schedulePlacement();
    widget.onOpenChanged?.call(index);
  }

  void _close() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _openTimer = _closeTimer = null;
    if (_open == null) return;
    setState(() => _open = null);
    _overPanel = false;
    _popover.close();
    widget.onOpenChanged?.call(null);
  }

  /// The popover closed by itself: Escape with the focus in the panel.
  void _onPopoverChanged() {
    _listenForEscape(_popover.isOpen);
    if (!_popover.isOpen && _open != null) {
      final trigger = _nodes[_open!];
      _close();
      if (_panelNode.hasFocus) trigger.requestFocus();
    }
  }

  // --- The pointer ---------------------------------------------------------

  void _onTriggerHover(int index, {required bool hovered}) {
    if (!widget.openOnHover) return;
    if (hovered) {
      _hovered = index;
      _closeTimer?.cancel();
      _closeTimer = null;
      if (!_isTrigger(index)) {
        // A link: nothing to open, and the open panel is not its.
        _openTimer?.cancel();
        _openTimer = null;
        if (_open != null) _scheduleClose();
        return;
      }
      if (_open == index) return;
      // With a panel open the next one takes over at once; the first waits
      // for the pointer to rest.
      final delay = _open != null
          ? Duration.zero
          : _theme.openDelay ?? const Duration(milliseconds: 120);
      _openTimer?.cancel();
      if (delay <= Duration.zero) return _show(index);
      _openTimer = Timer(delay, () {
        _openTimer = null;
        if (mounted && _hovered == index) _show(index);
      });
    } else if (_hovered == index) {
      _hovered = null;
      _openTimer?.cancel();
      _openTimer = null;
      _scheduleClose();
    }
  }

  void _scheduleClose() {
    if (_open == null || _closeTimer != null) return;
    final delay = _theme.closeDelay ?? const Duration(milliseconds: 180);
    if (delay <= Duration.zero) {
      if (!_stays) _close();
      return;
    }
    _closeTimer = Timer(delay, () {
      _closeTimer = null;
      if (mounted && !_stays) _close();
    });
  }

  /// Whether the open panel has a reason to stay: the pointer is on it or
  /// on its trigger, or the keyboard's focus is in it.
  bool get _stays {
    final open = _open;
    if (open == null) return false;
    return _overPanel ||
        _hovered == open ||
        _panelNode.hasFocus ||
        (_nodes[open].hasFocus && _showsFocus);
  }

  bool get _showsFocus =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  void _onPressed(int index) {
    final item = widget.items[index];
    if (item.builder == null) {
      _close();
      item.onPressed?.call();
    } else if (_open == index) {
      _close();
    } else {
      _show(index);
    }
  }

  // --- The keyboard --------------------------------------------------------

  void _onTriggerFocus(int index, {required bool focused}) {
    // The focus moving along the row takes an open panel with it, as the
    // pointer does. A click focuses a button too; only the keyboard counts.
    if (!focused || !_showsFocus || _open == null || _open == index) return;
    _isTrigger(index) ? _show(index) : _close();
  }

  KeyEventResult _onRowKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final index = _nodes.indexWhere((node) => node.hasPrimaryFocus);
    if (index < 0) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final forward = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    if (key == LogicalKeyboardKey.arrowRight) {
      _focusEntry(index, forward);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _focusEntry(index, -forward);
    } else if (key == LogicalKeyboardKey.home) {
      _focusEntry(-1, 1);
    } else if (key == LogicalKeyboardKey.end) {
      _focusEntry(widget.items.length, -1);
    } else if (key == LogicalKeyboardKey.arrowDown && _isTrigger(index)) {
      if (event is KeyDownEvent) {
        _show(index);
        _focusPanel();
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// Focuses the next enabled entry from [from] in the direction of [step].
  void _focusEntry(int from, int step) {
    for (var i = from + step; i >= 0 && i < widget.items.length; i += step) {
      if (widget.items[i].enabled) {
        _nodes[i].requestFocus();
        return;
      }
    }
  }

  /// Sends the focus to the first control of the panel, once it is built.
  void _focusPanel([int attempt = 0]) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _open == null) return;
      final first = _panelNode.traversalDescendants.firstOrNull;
      if (first != null) {
        first.requestFocus();
      } else if (attempt < 3) {
        // The overlay is built a frame after it is asked for.
        _focusPanel(attempt + 1);
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// Escape, while a panel is open and the focus is where the popover's
  /// own binding cannot hear it: on the row, or nowhere near the menu when
  /// the pointer opened the panel.
  void _listenForEscape(bool listen) {
    if (listen == _listeningForEscape) return;
    _listeningForEscape = listen;
    if (listen) {
      FocusManager.instance.addEarlyKeyEventHandler(_onEarlyKey);
    } else {
      FocusManager.instance.removeEarlyKeyEventHandler(_onEarlyKey);
    }
  }

  KeyEventResult _onEarlyKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        _open == null ||
        _panelNode.hasFocus ||
        !mounted ||
        // An early handler hears the key wherever the focus is: under a
        // dialog, or in a part of the tree that is not shown, the key is
        // someone else's.
        !TickerMode.valuesOf(context).enabled ||
        !Visibility.of(context) ||
        !isInTopRoute(context)) {
      return KeyEventResult.ignored;
    }
    _close();
    return KeyEventResult.handled;
  }

  // --- Where the panel is --------------------------------------------------

  void _schedulePlacement() {
    if (_placementScheduled) return;
    _placementScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _placementScheduled = false;
      if (mounted) _place();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// Puts the panel under the open trigger, as far as the screen lets it.
  ///
  /// It runs after a frame, when the trigger and the new content have been
  /// laid out. The content is measured at its own size, which the panel is
  /// still springing to.
  void _place() {
    final open = _open;
    if (open == null || open >= _keys.length) return;
    final row = _rowKey.currentContext?.findRenderObject();
    final trigger = _keys[open].currentContext?.findRenderObject();
    if (row is! RenderBox || trigger is! RenderBox || !row.hasSize) return;
    final content = _contentKey.currentContext?.findRenderObject();
    if (content is! RenderBox || !content.hasSize) {
      // The overlay is built a frame after it is shown.
      _schedulePlacement();
      return;
    }

    final rtl = Directionality.of(context) == TextDirection.rtl;
    // The panel is in the overlay, which need not be the whole window: a
    // page beside a docked panel has one of its own.
    final overlay = Overlay.maybeOf(context)?.context.findRenderObject();
    final bounds = overlay is RenderBox && overlay.hasSize
        ? overlay.localToGlobal(Offset.zero) & overlay.size
        : Offset.zero & MediaQuery.sizeOf(context);
    final margin = _theme.panelMargin ?? 8;
    final width = content.size.width + 2;
    final rowRect = row.localToGlobal(Offset.zero) & row.size;
    final triggerRect = trigger.localToGlobal(Offset.zero) & trigger.size;

    double target;
    if (rtl) {
      // The panel's trailing edge is the anchor; keep its leading edge on
      // screen first.
      final right = math.min(
        math.max(triggerRect.right, bounds.left + margin + width),
        bounds.right - margin,
      );
      target = right - rowRect.right;
    } else {
      final left = math.max(
        math.min(triggerRect.left, bounds.right - margin - width),
        bounds.left + margin,
      );
      target = left - rowRect.left;
    }

    final motion = Motion.of(context);
    if (!_placed || motion.reduced) {
      _placed = true;
      _slide.jumpTo(target);
    } else if ((target - _slide.target).abs() > .5) {
      // A surface: no bounce.
      _slide.animateTo(target, spring: motion.smooth);
    }
  }

  // --- Build ---------------------------------------------------------------

  bool get _collapsed =>
      widget.collapsed ?? Theme.of(context).formFactor == FormFactor.mobile;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    if (_collapsed) {
      // The row and its panel are gone; a panel left open would go on
      // answering Escape for a popover nobody sees. Not during build:
      // closing reports to the parent.
      if (_open != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && _collapsed) _close();
        });
      }
      return _CollapsedMenu(
        items: widget.items,
        semanticLabel: widget.semanticLabel,
        onOpenChanged: widget.onOpenChanged,
      );
    }

    final theme = Theme.of(context);
    final menu = theme.navigationMenuTheme;
    final strings = FinesseLocalizations.of(context).navigation;
    final items = widget.items;
    final open = _open;
    final gap = menu.gap ?? 4;

    final row = Row(
      key: _rowKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, item) in items.indexed)
          Padding(
            padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : gap),
            child: FocusTraversalOrder(
              order: NumericFocusOrder(index.toDouble()),
              child: _Entry(
                key: _keys[index],
                item: item,
                open: open == index,
                // One fill marks where the user is; while a panel is open
                // it is on that panel's trigger instead.
                marked: open == null ? item.selected : open == index,
                selectedColor: menu.selectedColor ?? theme.colorScheme.muted,
                focusNode: _nodes[index],
                onPressed: () => _onPressed(index),
                onHover: (hovered) => _onTriggerHover(index, hovered: hovered),
                onFocusChange: (focused) =>
                    _onTriggerFocus(index, focused: focused),
              ),
            ),
          ),
      ],
    );

    // The panel hangs from a point of no size at the row's leading bottom
    // corner, and that point is what slides: the popover follows it in the
    // compositor, so a slide rebuilds and lays out nothing.
    final panel = PositionedDirectional(
      start: 0,
      bottom: 0,
      child: FocusTraversalOrder(
        // After its trigger, before the next entry.
        order: NumericFocusOrder((open ?? _shown ?? 0) + .5),
        child: _SlidingPoint(
          position: _slide,
          child: Popover(
            controller: _popover,
            // The focus stays on the row until it is sent into the panel.
            requestFocus: false,
            // A press on the row is the row's business.
            closeOnTapOutside: false,
            padding: EdgeInsets.zero,
            anchor: Anchor(
              childAlignment: AlignmentDirectional.bottomStart,
              overlayAlignment: AlignmentDirectional.topStart,
              offset: Offset(0, menu.panelOffset ?? 6),
            ),
            builder: _buildPanel,
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel ?? strings.menu,
      child: TapRegion(
        groupId: _tapGroup,
        onTapOutside: (_) => _close(),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: _onRowKey,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The open trigger is marked by one fill that slides along
                // the row as the panels are switched.
                MovingIndicator(child: row),
                panel,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final theme = Theme.of(context);
    final menu = theme.navigationMenuTheme;
    final shown = _shown;
    final item = shown != null && shown < widget.items.length
        ? widget.items[shown]
        : null;
    final margin = menu.panelMargin ?? 8;
    final radius =
        theme.popoverTheme.decoration?.border?.borderRadius ?? theme.radius;

    return _MenuScope(
      close: _close,
      inSheet: false,
      child: TapRegion(
        groupId: _tapGroup,
        child: MouseRegion(
          onEnter: (_) {
            // Not a panel that is already leaving.
            if (_open == null) return;
            _overPanel = true;
            _closeTimer?.cancel();
            _closeTimer = null;
          },
          onExit: (_) {
            _overPanel = false;
            _scheduleClose();
          },
          child: Focus(
            focusNode: _panelNode,
            onFocusChange: (focused) {
              if (!focused) _scheduleClose();
            },
            child: Semantics(
              container: true,
              onDismiss: _close,
              child: _MaxWidthLess(
                by: margin * 2,
                // One panel for every trigger: it takes the size of the
                // content it now shows on a spring, and the content comes
                // in from the side the pointer went to.
                child: SpringSize(
                  spring: Motion.of(context).smooth,
                  borderRadius: radius,
                  child: KeyedSubtree(
                    key: _contentKey,
                    child: ContentSwitch(
                      value: shown ?? -1,
                      direction: _direction,
                      child: KeyedSubtree(
                        key: ValueKey(shown),
                        child: Padding(
                          padding: menu.panelPadding ?? const EdgeInsets.all(8),
                          child: item?.builder == null
                              ? const SizedBox.shrink()
                              : Builder(builder: item!.builder!),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tells what is in a panel, or in a collapsed menu's sheet, how to close
/// it and which of the two it is in.
class _MenuScope extends InheritedWidget {
  const _MenuScope({
    required this.close,
    required this.inSheet,
    required super.child,
  });

  final VoidCallback close;
  final bool inSheet;

  @override
  bool updateShouldNotify(_MenuScope oldWidget) => inSheet != oldWidget.inSheet;
}

/// One entry of the row: a ghost button, with a caret when it opens a
/// panel.
class _Entry extends StatelessWidget {
  const _Entry({
    required this.item,
    required this.open,
    required this.marked,
    required this.selectedColor,
    required this.focusNode,
    required this.onPressed,
    required this.onHover,
    required this.onFocusChange,
    super.key,
  });

  final NavigationMenuItem item;
  final bool open;
  final bool marked;
  final Color selectedColor;
  final FocusNode focusNode;
  final VoidCallback onPressed;
  final ValueChanged<bool> onHover;
  final ValueChanged<bool> onFocusChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trigger = item.builder != null;
    final radius =
        theme.ghostButtonTheme.decoration?.border?.borderRadius ?? theme.radius;
    return MovingIndicatorTarget(
      selected: marked,
      decoration: BoxDecoration(color: selectedColor, borderRadius: radius),
      // One node: the button, and whether its panel is open.
      child: MergeSemantics(
        child: Semantics(
          expanded: trigger ? open : null,
          selected: item.selected ? true : null,
          child: Button.ghost(
            focusNode: focusNode,
            enabled: item.enabled,
            onPressed: onPressed,
            onHover: onHover,
            onFocusChange: onFocusChange,
            leading: item.leading,
            trailing: trigger ? _Caret(open: open) : null,
            child: item.label,
          ),
        ),
      ),
    );
  }
}

/// Lets its child be at most as wide as it is itself allowed to be, less
/// [by]: the panel keeps a margin to both edges of the overlay.
class _MaxWidthLess extends SingleChildRenderObjectWidget {
  const _MaxWidthLess({required this.by, required super.child});

  final double by;

  @override
  _RenderMaxWidthLess createRenderObject(BuildContext context) =>
      _RenderMaxWidthLess(by);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMaxWidthLess renderObject,
  ) {
    renderObject.by = by;
  }
}

class _RenderMaxWidthLess extends RenderProxyBox {
  _RenderMaxWidthLess(this._by);

  double get by => _by;
  double _by;
  set by(double value) {
    if (value == _by) return;
    _by = value;
    markNeedsLayout();
  }

  BoxConstraints _narrowed(BoxConstraints constraints) =>
      constraints.hasBoundedWidth
      ? constraints.copyWith(
          minWidth: math.min(
            constraints.minWidth,
            math.max(0, constraints.maxWidth - _by),
          ),
          maxWidth: math.max(0, constraints.maxWidth - _by),
        )
      : constraints;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      super.computeDryLayout(_narrowed(constraints));

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_narrowed(constraints), parentUsesSize: true);
    size = constraints.constrain(child.size);
  }
}

/// The caret of a trigger: it turns over while its panel is open.
class _Caret extends StatelessWidget {
  const _Caret({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    return SpringBuilder(
      value: open ? 1 : 0,
      spring: motion.snappy,
      builder: (context, t, child) => Transform.rotate(
        angle: motion.reduced ? (open ? math.pi : 0) : t * math.pi,
        child: child,
      ),
      child: const PhosphorIcon(PhosphorIconsRegular.caretDown, size: 12),
    );
  }
}

/// Paints its child [position] pixels to the right of where it is laid
/// out. The popover that hangs from the child follows in the compositor.
class _SlidingPoint extends SingleChildRenderObjectWidget {
  const _SlidingPoint({required this.position, required super.child});

  final SpringController position;

  @override
  _RenderSlidingPoint createRenderObject(BuildContext context) =>
      _RenderSlidingPoint(position);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSlidingPoint renderObject,
  ) {
    renderObject.position = position;
  }
}

class _RenderSlidingPoint extends RenderProxyBox {
  _RenderSlidingPoint(this._position);

  SpringController get position => _position;
  SpringController _position;
  set position(SpringController value) {
    if (identical(value, _position)) return;
    if (attached) _position.animation.removeListener(markNeedsPaint);
    _position = value;
    if (attached) _position.animation.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _position.animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _position.animation.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset.translate(_position.value, 0));
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(_position.value, 0, 0, 1);
  }
}

/// A link in the panel of a [NavigationMenu]: a title, a line about where
/// it leads, and an icon.
///
/// ```dart
/// NavigationMenuLink(
///   leading: const PhosphorIcon(PhosphorIconsRegular.chartLine),
///   title: const Text('Analytics'),
///   description: const Text('Traffic and conversion, live.'),
///   onPressed: () => go('/analytics'),
/// )
/// ```
///
/// It fills the width it is given, highlights under the pointer and the
/// focus as a menu row does, and closes the menu when it is pressed. In
/// the sheet of a collapsed menu it is a row at least a touch target tall.
/// Outside a navigation menu it is the same link, with nothing to close.
class NavigationMenuLink extends StatelessWidget {
  /// Creates a link.
  const NavigationMenuLink({
    required this.title,
    this.description,
    this.leading,
    this.onPressed,
    this.selected = false,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  /// Where the link leads, in a word or two.
  final Widget title;

  /// A line about it, in the muted colour. It wraps to two lines.
  final Widget? description;

  /// A widget before the text: an icon, in the muted colour unless it has
  /// one of its own.
  final Widget? leading;

  /// Called when the link is pressed, after the menu has been told to
  /// close.
  final VoidCallback? onPressed;

  /// Whether this is the page the user is on.
  final bool selected;

  /// Whether the link can be pressed.
  final bool enabled;

  /// What assistive technology reads for the link, in place of its title
  /// and description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menu = theme.navigationMenuTheme;
    final scope = context.dependOnInheritedWidgetOfExactType<_MenuScope>();
    final inSheet = scope?.inSheet ?? false;
    final radius = menu.linkBorderRadius ?? theme.radii.sm;
    final hover = menu.linkHoverColor ?? theme.colorScheme.muted;
    final resting = selected
        ? menu.linkSelectedColor ?? hover.withValues(alpha: hover.a * .5)
        : hover.withValues(alpha: 0);
    final titleStyle = menu.linkTitleStyle ?? theme.textTheme.small;
    final descriptionStyle = menu.linkDescriptionStyle ?? theme.textTheme.muted;
    final ink = enabled ? null : theme.colorScheme.mutedForeground;

    return Pressable(
      onPressed: enabled && onPressed != null
          ? () {
              scope?.close();
              onPressed!();
            }
          : null,
      selected: selected ? true : null,
      semanticLabel: semanticLabel,
      // A row of a menu: it does not give under a press.
      pressScale: 1,
      builder: (context, states) {
        final lit =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: radius,
          child: AnimatedFill(
            color: lit ? hover : resting,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // A touch target in the sheet; in the panel, its content.
                minHeight: inSheet
                    ? theme.listSectionTheme.minTileHeight ?? 44
                    : 0,
              ),
              child: Padding(
                padding: menu.linkPadding ?? const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: description == null
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      IconTheme.merge(
                        data: IconThemeData(
                          size: 16,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        child: Padding(
                          // On the title's line.
                          padding: EdgeInsets.only(
                            top: description == null ? 0 : 2,
                          ),
                          child: leading,
                        ),
                      ),
                      SizedBox(width: theme.layoutTheme.gap(GapSize.sm)),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle.merge(
                            style: titleStyle.copyWith(color: ink),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: title,
                          ),
                          if (description != null) ...[
                            SizedBox(height: menu.linkGap ?? 4),
                            DefaultTextStyle.merge(
                              style: descriptionStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              child: description!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A navigation menu on a phone: one button, and a sheet with every entry.
class _CollapsedMenu extends StatefulWidget {
  const _CollapsedMenu({
    required this.items,
    required this.semanticLabel,
    required this.onOpenChanged,
  });

  final List<NavigationMenuItem> items;
  final String? semanticLabel;
  final ValueChanged<int?>? onOpenChanged;

  @override
  State<_CollapsedMenu> createState() => _CollapsedMenuState();
}

class _CollapsedMenuState extends State<_CollapsedMenu> {
  bool _open = false;

  Future<void> _show() async {
    if (_open) return;
    _open = true;
    widget.onOpenChanged?.call(0);
    final label =
        widget.semanticLabel ??
        FinesseLocalizations.of(context).navigation.menu;
    await showSheet<void>(
      context: context,
      builder: (context) => _MenuSheet(items: widget.items, label: label),
    );
    _open = false;
    if (mounted) widget.onOpenChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final strings = FinesseLocalizations.of(context).navigation;
    return IconButton.ghost(
      icon: const PhosphorIcon(PhosphorIconsRegular.list),
      semanticLabel: strings.openMenu,
      onPressed: _show,
    );
  }
}

/// The sheet of a collapsed menu: the links as rows, and under each
/// trigger's label the content of its panel.
class _MenuSheet extends StatelessWidget {
  const _MenuSheet({required this.items, required this.label});

  final List<NavigationMenuItem> items;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menu = theme.navigationMenuTheme;
    final gap = theme.layoutTheme.gap(GapSize.md);
    final inset = (menu.linkPadding ?? const EdgeInsets.all(8)).resolve(
      Directionality.of(context),
    );
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);

    void close() {
      // This sheet and nothing else: a link may already have pushed a page
      // over it.
      if (route != null && route.isActive) {
        route.isCurrent ? navigator.pop() : navigator.removeRoute(route);
      }
    }

    return Sheet(
      semanticLabel: label,
      scrollable: true,
      child: _MenuScope(
        close: close,
        inSheet: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, item) in items.indexed)
              if (item.builder == null)
                NavigationMenuLink(
                  title: item.label,
                  leading: item.leading,
                  selected: item.selected,
                  enabled: item.enabled,
                  onPressed: item.onPressed ?? () {},
                )
              else ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    inset.left,
                    index == 0 ? 0 : gap,
                    inset.right,
                    theme.layoutTheme.gap(GapSize.xs),
                  ),
                  child: Semantics(
                    header: true,
                    child: DefaultTextStyle.merge(
                      style: menu.sheetLabelStyle ?? theme.textTheme.caption,
                      child: item.label,
                    ),
                  ),
                ),
                Builder(builder: item.builder!),
              ],
          ],
        ),
      ),
    );
  }
}
