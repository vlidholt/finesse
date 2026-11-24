import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/scroll_area.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/browser_context_menu/browser_context_menu.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/mouse_area.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:finesse/src/utils/states_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The tap-region group every context menu shared before 1.0.
///
/// Menus now get a group of their own (shared with their submenus), so a tap
/// on another menu's trigger counts as outside and closes the open one.
@Deprecated(
  'Each menu now has its own tap-region group; this one is no longer used. '
  'Will be removed in the next major version.',
)
const kContextMenuGroupId = ValueKey('context-menu');

/// {@template ContextMenuRegion}
/// A widget that shows the context menu when the user right clicks the [child]
/// or long presses it (only on android and ios), unless a value to
/// [longPressEnabled] is provided.
///
/// On Android and iOS, tapping the [child] also shows the context menu by
/// default. This can be overridden using [tapEnabled].
/// {@endtemplate}
class ContextMenuRegion extends StatefulWidget {
  /// {@macro ContextMenuRegion}
  const ContextMenuRegion({
    super.key,
    required this.child,
    this.items = const [],
    this.itemsBuilder,
    this.visible,
    this.constraints,
    this.onHoverArea,
    this.padding,
    this.groupId,
    this.effects,
    this.shadows,
    this.decoration,
    this.filter,
    this.controller,
    this.supportedDevices,
    this.longPressEnabled,
    this.tapEnabled,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.popoverReverseDuration,
  });

  /// {@macro Popover.reverseDuration}
  final Duration? popoverReverseDuration;

  /// {@template ContextMenuRegion.child}
  /// The child that triggers the visibility of the context menu.
  /// {@endtemplate}
  final Widget child;

  /// {@macro ContextMenu.items}
  final List<Widget> items;

  /// {@macro ContextMenu.itemsBuilder}
  final List<Widget> Function(BuildContext context)? itemsBuilder;

  /// {@macro ContextMenu.visible}
  final bool? visible;

  /// {@macro ContextMenu.constraints}
  final BoxConstraints? constraints;

  /// {@macro ContextMenu.onHoverArea}
  final ValueChanged<bool>? onHoverArea;

  /// {@macro ContextMenu.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro MouseArea.groupId}
  final Object? groupId;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// {@macro ContextMenu.controller}
  final PopoverController? controller;

  /// {@template ContextMenuRegion.hitTestBehavior}
  /// How this gesture detector should behave during hit testing.
  ///
  /// This defaults to [HitTestBehavior.opaque].
  /// {@endtemplate}
  final HitTestBehavior hitTestBehavior;

  /// The kind of devices that are allowed to be recognized.
  ///
  /// If set to null, events from all device types will be recognized. Defaults
  /// to null.
  final Set<PointerDeviceKind>? supportedDevices;

  /// {@template ContextMenuRegion.longPressEnabled}
  /// Whether the context menu should be shown when the user long presses the
  /// child, defaults to true only on Android and iOS.
  /// {@endtemplate}
  final bool? longPressEnabled;

  /// {@template ContextMenuRegion.tapEnabled}
  /// Whether the context menu should be shown when the user taps/left-clicks
  /// the child.
  ///
  /// Defaults to true on Android and iOS, false on other platforms.
  /// {@endtemplate}
  final bool? tapEnabled;

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  FinesseContextMenuController? _controller;
  PopoverController get controller =>
      widget.controller ??
      (_controller ??= FinesseContextMenuController(
        isOpen: widget.visible ?? false,
      ));
  Offset? offset;

  @override
  void didUpdateWidget(covariant ContextMenuRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != null) {
      controller.setOpen(widget.visible!);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void showAtOffset(Offset offset) {
    if (!mounted) return;
    setState(() => this.offset = offset);
    controller.show();
  }

  void hide() {
    controller.hide();
  }

  void show(Offset offset) {
    showAtOffset(offset);
  }

  void onLongPress() {
    assert(offset != null, 'offset must not be null');
    showAtOffset(offset!);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLongPressEnabled =
        widget.longPressEnabled ??
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    final effectiveTapEnabled =
        widget.tapEnabled ??
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    final isWindows = defaultTargetPlatform == TargetPlatform.windows;

    return ContextMenu(
      // Radix opens a context menu with its corner at the pointer, not
      // centred on it.
      anchor: offset == null
          ? null
          : GlobalAnchor(
              offset!,
              followerAnchor: AlignmentDirectional.topStart,
            ),
      controller: controller,
      items: widget.items,
      itemsBuilder: widget.itemsBuilder,
      constraints: widget.constraints,
      onHoverArea: widget.onHoverArea,
      padding: widget.padding,
      groupId: widget.groupId,
      effects: widget.effects,
      shadows: widget.shadows,
      decoration: widget.decoration,
      filter: widget.filter,
      popoverReverseDuration: widget.popoverReverseDuration,
      child: FinesseGestureDetector(
        behavior: widget.hitTestBehavior,
        supportedDevices: widget.supportedDevices,
        onTapDown: (d) {
          if (effectiveTapEnabled) {
            if (controller.isOpen) {
              hide();
            } else {
              show(d.globalPosition);
            }
          } else {
            hide();
          }
        },
        // The browser's native menu is cancelled per event, never by
        // flipping `BrowserContextMenu`'s global flag: `SelectionArea`
        // changes its tree shape on that flag, and remounting its selection
        // container mid-flight trips `SelectableRegion`'s
        // `assert(_selectable == null)`. See suppressBrowserContextMenu.
        onSecondaryTapDown: (d) {
          if (kIsWeb) suppressBrowserContextMenu();
          if (!isWindows) show(d.globalPosition);
        },
        onSecondaryTapUp: (d) {
          // On Windows the browser fires `contextmenu` on button up, which
          // can be arbitrarily long after the down — re-arm so a slow click
          // stays covered, and only then open the menu.
          if (kIsWeb) suppressBrowserContextMenu();
          if (isWindows) show(d.globalPosition);
        },
        onLongPressStart: effectiveLongPressEnabled
            ? (d) {
                offset = d.globalPosition;
              }
            : null,
        onLongPress: effectiveLongPressEnabled ? onLongPress : null,
        child: widget.child,
      ),
    );
  }
}

/// Controls a [ContextMenu]: whether it is open and, optionally, the
/// point it opens at.
///
/// Any [PopoverController] works as a context menu controller; this one
/// adds [showAt].
class FinesseContextMenuController extends PopoverController {
  /// Creates a controller. [isOpen] sets whether the menu starts open.
  FinesseContextMenuController({super.isOpen});

  Offset? _position;

  /// The global point the menu opens at, set by [showAt]. Null means the
  /// menu's own anchor.
  Offset? get position => _position;

  /// Opens the menu with its corner at [globalPosition], as a context menu
  /// opens at the pointer. The menu is mirrored or shifted to stay on screen.
  void showAt(Offset globalPosition) {
    final moved = _position != globalPosition;
    _position = globalPosition;
    if (isOpen) {
      if (moved) notifyListeners();
    } else {
      super.show();
    }
  }

  /// Opens the menu at its own anchor, forgetting any [showAt] position.
  @override
  void show() {
    _position = null;
    super.show();
  }
}

/// A menu of [ContextMenuItem]s shown in a popover next to [child].
///
/// This is the menu surface behind shadcn's `DropdownMenuContent` and
/// `ContextMenuContent`. It opens when [visible] or [controller] says so; use
/// [ContextMenuRegion] to open it on a right click or long press. With no
/// [items] and no [itemsBuilder], it builds only [child].
class ContextMenu extends StatefulWidget {
  /// Creates a context menu anchored to [child].
  const ContextMenu({
    super.key,
    required this.child,
    this.items = const [],
    this.itemsBuilder,
    this.anchor,
    this.visible,
    this.constraints,
    this.onHoverArea,
    this.padding,
    this.groupId,
    this.effects,
    this.shadows,
    this.decoration,
    this.filter,
    this.controller,
    this.onTapOutside,
    this.onTapInside,
    this.onTapUpInside,
    this.onTapUpOutside,
    this.popoverReverseDuration,
  });

  /// {@macro Popover.reverseDuration}
  final Duration? popoverReverseDuration;

  /// {@template ContextMenu.child}
  /// The child of the context menu.
  /// {@endtemplate}
  final Widget child;

  /// {@template ContextMenu.items}
  /// The items of the context menu.
  /// {@endtemplate}
  final List<Widget> items;

  /// {@template ContextMenu.itemsBuilder}
  /// Builds the items each time the menu opens, instead of [items].
  ///
  /// The items are not built while the menu is closed, which matters for a
  /// menu whose items are expensive or depend on state that changes while it
  /// is closed.
  /// {@endtemplate}
  final List<Widget> Function(BuildContext context)? itemsBuilder;

  /// {@template ContextMenu.anchor}
  /// The anchor of the context menu.
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@template ContextMenu.visible}
  /// Whether the context menu is visible, defaults to null.
  /// {@endtemplate}
  final bool? visible;

  /// {@template ContextMenu.constraints}
  /// The constraints of the context menu, defaults to
  /// `BoxConstraints(minWidth: 128)`.
  /// {@endtemplate}
  final BoxConstraints? constraints;

  /// {@template ContextMenu.onHoverArea}
  /// The callback called when the hover area changes.
  /// {@endtemplate}
  final ValueChanged<bool>? onHoverArea;

  /// {@template ContextMenu.padding}
  /// The padding of the context menu, defaults to
  /// `EdgeInsets.symmetric(vertical: 4)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@macro MouseArea.groupId}
  final Object? groupId;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// {@template ContextMenu.controller}
  /// The controller of the context menu, starts from isOpen set to false.
  /// {@endtemplate}
  final PopoverController? controller;

  /// {@template ContextMenu.onTapOutside}
  /// A callback to be invoked when a tap down is detected outside of this
  /// [TapRegion] and any other region with the same [groupId], if any.
  ///
  /// The [PointerDownEvent] passed to the function is the event that caused the
  /// notification. If this region is part of a group (i.e. [groupId] is set),
  /// then it's possible that the event may be outside of this immediate region,
  /// although it will be within the region of one of the group members.
  ///
  /// See also:
  /// * [onTapUpOutside], which is called when a tap up is detected outside
  ///   of this region.
  /// {@endtemplate}
  final TapRegionCallback? onTapOutside;

  /// {@template ContextMenu.onTapInside}
  /// A callback to be invoked when a tap down is detected inside of this
  /// [TapRegion], or any other tap region with the same [groupId], if any.
  ///
  /// The [PointerDownEvent] passed to the function is the event that caused the
  /// notification. If this region is part of a group (i.e. [groupId] is set),
  /// then it's possible that the event may be outside of this immediate region,
  /// although it will be within the region of one of the group members.
  ///
  /// See also:
  /// * [onTapUpInside], which is called when a tap up is detected inside
  ///   of this region.
  /// {@endtemplate}
  final TapRegionCallback? onTapInside;

  /// {@template ContextMenu.onTapUpInside}
  /// A callback to be invoked when a tap up is detected inside of this
  /// [TapRegion], or any other tap region with the same [groupId], if any.
  ///
  /// The [PointerUpEvent] passed to the function is the event that caused the
  /// notification. If this region is part of a group (i.e. [groupId] is set),
  /// then it's possible that the event may be outside of this immediate region,
  /// although it will be within the region of one of the group members.
  ///
  /// See also:
  /// * [onTapInside], which is called when a tap down is detected inside
  ///   of this region.
  /// {@endtemplate}
  final TapRegionUpCallback? onTapUpInside;

  /// {@template ContextMenu.onTapUpOutside}
  /// A callback to be invoked when a tap up is detected outside of this
  /// [TapRegion] and any other region with the same [groupId], if any.
  ///
  /// The [PointerUpEvent] passed to the function is the event that caused the
  /// notification. If this region is part of a group (i.e. [groupId] is set),
  /// then it's possible that the event may be outside of this immediate region,
  /// although it will be within the region of one of the group members.
  ///
  /// See also:
  /// * [onTapOutside], which is called when a tap down is detected outside
  ///   of this region.
  /// {@endtemplate}
  final TapRegionUpCallback? onTapUpOutside;

  @override
  State<ContextMenu> createState() => ContextMenuState();
}

/// The state of a [ContextMenu].
///
/// Its items and submenus find it in the widget tree.
class ContextMenuState extends State<ContextMenu> {
  FinesseContextMenuController? _controller;

  /// This menu's tap-region group when it is a root menu.
  final Object _ownTapRegionGroupId = Object();

  /// The root menu above this one, if this is a submenu.
  ContextMenuState? _root;

  /// The menu's content, which takes focus when a root menu opens so that
  /// arrow keys, Home/End and type-ahead work straight away, as in Radix.
  final _contentFocusNode = FocusNode(debugLabel: 'ContextMenu content');

  /// The row of this menu level the pointer was last over.
  _ContextMenuItemState? _hoveredItem;

  /// Called when the pointer reaches [item], a row of this menu level. The
  /// row it left gives up its highlight and closes its submenu at once,
  /// without waiting for its grace period, so only one submenu is ever open.
  void _itemHovered(_ContextMenuItemState item) {
    final previous = _hoveredItem;
    _hoveredItem = item;
    if (previous == null || identical(previous, item) || !previous.mounted) {
      return;
    }
    previous._unhoverNow();
  }

  /// The characters typed in quick succession, for type-ahead.
  String _typeAhead = '';
  Timer? _typeAheadReset;

  PopoverController? _listened;

  void _listenTo(PopoverController controller) {
    if (identical(controller, _listened)) return;
    _listened?.removeListener(_onOpenChanged);
    _listened = controller..addListener(_onOpenChanged);
  }

  /// The [FinesseContextMenuController.position] this menu was last built for.
  Offset? _builtPosition;

  void _onOpenChanged() {
    final controller = this.controller;
    // The anchor is resolved in build, so a new showAt point needs one.
    if (controller is FinesseContextMenuController &&
        controller.position != _builtPosition &&
        mounted) {
      setState(() {});
    }
    // A hover-opened submenu leaves focus where it is.
    if (!controller.isOpen || _root != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && controller.isOpen && !_hasFocusedItem) {
        _contentFocusNode.requestFocus();
      }
    });
  }

  /// The focusable items of this menu level, in order. Submenu items are
  /// focus descendants too (their overlay is built below this one), so they
  /// are told apart by the level they were built in.
  List<FocusNode> get _itemNodes => [
    for (final node in _contentFocusNode.traversalDescendants)
      if (node.context?.getInheritedWidgetOfExactType<_MenuLevel>()?.menu ==
          this)
        node,
  ];

  bool get _hasFocusedItem => _itemNodes.any((n) => n.hasPrimaryFocus);

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final items = _itemNodes;
    if (items.isEmpty) return KeyEventResult.ignored;
    final current = items.indexWhere((n) => n.hasPrimaryFocus);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.home) {
      items.first.requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      items.last.requestFocus();
      return KeyEventResult.handled;
    }
    // From the content itself (after a pointer open), the arrows enter the
    // list at either end.
    if (current == -1 && key == LogicalKeyboardKey.arrowDown) {
      items.first.requestFocus();
      return KeyEventResult.handled;
    }
    if (current == -1 && key == LogicalKeyboardKey.arrowUp) {
      items.last.requestFocus();
      return KeyEventResult.handled;
    }

    final character = event.character;
    final keyboard = HardwareKeyboard.instance;
    if (character == null ||
        character.trim().isEmpty ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed) {
      return KeyEventResult.ignored;
    }
    _typeAheadReset?.cancel();
    _typeAheadReset = Timer(
      const Duration(milliseconds: 500),
      () => _typeAhead = '',
    );
    _typeAhead += character.toLowerCase();
    // Repeating one letter cycles through the items starting with it.
    final query = _typeAhead.split('').toSet().length == 1
        ? _typeAhead[0]
        : _typeAhead;
    final start = query.length == 1 ? current + 1 : math.max(current, 0);
    for (var i = 0; i < items.length; i++) {
      final candidate = items[(start + i) % items.length];
      final label = _labelOf(candidate.context);
      if (label != null && label.toLowerCase().startsWith(query)) {
        candidate.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.handled;
  }

  /// The first text below [context] outside an icon: an item's label.
  static String? _labelOf(BuildContext? context) {
    String? label;
    void visit(Element element) {
      if (label != null) return;
      final widget = element.widget;
      // An Icon renders its glyph as RichText; a leading icon would otherwise
      // be taken for the label.
      if (widget is Icon) return;
      if (widget is Text) {
        label = widget.data ?? widget.textSpan?.toPlainText();
      } else if (widget is RichText) {
        label = widget.text.toPlainText();
      }
      if (label == null) element.visitChildren(visit);
    }

    if (context is Element) context.visitChildren(visit);
    return label;
  }

  /// The tap-region group of this menu tree: a root menu's own, shared with
  /// every submenu below it, so taps inside any of them count as inside.
  /// Distinct per root menu, so a tap on another menu's trigger counts as
  /// outside and closes this one.
  Object get tapRegionGroupId =>
      _root?.tapRegionGroupId ?? _ownTapRegionGroupId;

  /// The controller in use: [ContextMenu.controller] when given, otherwise
  /// an internal [FinesseContextMenuController] that starts open when
  /// [ContextMenu.visible] is true.
  PopoverController get controller =>
      widget.controller ??
      (_controller ??= FinesseContextMenuController(
        isOpen: widget.visible ?? false,
      ));

  @override
  void initState() {
    super.initState();
    _listenTo(controller);
  }

  @override
  void didUpdateWidget(covariant ContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _listenTo(controller);
    if (widget.visible != null) {
      controller.setOpen(widget.visible!);
    }
  }

  @override
  void dispose() {
    _listened?.removeListener(_onOpenChanged);
    _typeAheadReset?.cancel();
    _contentFocusNode.dispose();
    _controller?.dispose();
    super.dispose();
  }

  /// Opens the menu when [visible] is true, and closes it otherwise.
  void setVisible(bool visible) {
    controller.setOpen(visible);
  }

  @override
  Widget build(BuildContext context) {
    // A submenu is built below its root menu's provider; a root menu finds
    // none, since it puts its own provider below itself.
    _root = context.maybeRead<ContextMenuState>();

    // if the context menu has no items, just return the child
    if (widget.items.isEmpty && widget.itemsBuilder == null) {
      return widget.child;
    }

    final theme = Theme.of(context);

    final effectiveConstraints =
        widget.constraints ??
        theme.contextMenuTheme.constraints ??
        const BoxConstraints(minWidth: 128);

    final effectivePadding =
        widget.padding ??
        theme.contextMenuTheme.padding ??
        const EdgeInsets.symmetric(vertical: 4);

    final effectiveDecoration =
        (theme.contextMenuTheme.decoration ?? const FinesseDecoration()).merge(
          widget.decoration,
        );

    final effectiveFilter = widget.filter ?? theme.contextMenuTheme.filter;

    final effectiveEffects = widget.effects ?? theme.contextMenuTheme.effects;

    final effectiveShadows = widget.shadows ?? theme.contextMenuTheme.shadows;

    // A point set through FinesseContextMenuController.showAt wins over the
    // menu's own anchor; the menu opens with its corner there.
    final controller = this.controller;
    final position = controller is FinesseContextMenuController
        ? controller.position
        : null;
    _builtPosition = position;
    final effectiveAnchor = position != null
        ? GlobalAnchor(
            position,
            followerAnchor: AlignmentDirectional.topStart,
          )
        : widget.anchor;

    // Long menus scroll instead of running off screen; Radix caps them at
    // the available height the same way.
    final resolvedPadding = effectivePadding.resolve(
      Directionality.of(context),
    );
    final maxHeight = math
        .max(
          0,
          MediaQuery.sizeOf(context).height - resolvedPadding.vertical - 16,
        )
        .toDouble();

    Widget child = Popover(
      controller: controller,
      padding: effectivePadding,
      areaGroupId: widget.groupId,
      groupId: tapRegionGroupId,
      anchor: effectiveAnchor,
      decoration: effectiveDecoration,
      effects: effectiveEffects,
      shadows: effectiveShadows,
      filter: effectiveFilter,
      // A submenu that closes is being replaced by a sibling's, or the
      // pointer has left the menu: it goes at once rather than fading out
      // over the one that replaces it.
      reverseDuration:
          widget.popoverReverseDuration ??
          theme.contextMenuTheme.popoverReverseDuration ??
          (_root != null ? Duration.zero : null),
      useSameGroupIdForChild: false,
      popover: (context) {
        return MouseArea(
          groupId: widget.groupId,
          key: ValueKey(widget.groupId),
          child: ConstrainedBox(
            constraints: effectiveConstraints,
            child: IntrinsicWidth(
              child: TapRegion(
                onTapInside: widget.onTapInside,
                onTapOutside: widget.onTapOutside,
                onTapUpInside: widget.onTapUpInside,
                onTapUpOutside: widget.onTapUpOutside,
                groupId: tapRegionGroupId,
                child: Focus(
                  focusNode: _contentFocusNode,
                  skipTraversal: true,
                  onKeyEvent: _handleKey,
                  child: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight),
                      child: ScrollArea(
                        child: _MenuLevel(
                          menu: this,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children:
                                widget.itemsBuilder?.call(context) ??
                                widget.items,
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
      },
      child: MouseArea(
        groupId: widget.groupId,
        onEnter: (_) => widget.onHoverArea?.call(true),
        onExit: (_) => widget.onHoverArea?.call(false),
        child: TapRegion(groupId: tapRegionGroupId, child: widget.child),
      ),
    );

    // just put one context menu inherited widget.
    if (_root == null) {
      child = Provider(data: this, child: child);
    }

    return child;
  }
}

/// Tracks whether a [ContextMenuItem] is hovered or focused, and the same
/// for the items in its submenu.
///
/// Used internally. It is not exported from `package:finesse/finesse.dart`.
class ContextMenuItemController extends ChangeNotifier {
  /// Creates a controller for the item identified by [itemKey].
  ContextMenuItemController({
    required this.itemKey,
    bool hovered = false,
    bool focused = false,
  }) : _hovered = hovered,
       _focused = focused;

  bool _hovered = false;

  /// Whether the pointer is over the item.
  bool get hovered => _hovered;

  /// Sets [hovered], and notifies listeners when it changes.
  void setHovered(bool hovered) {
    if (hovered == _hovered) return;
    _hovered = hovered;
    notifyListeners();
  }

  bool _focused = false;

  /// Whether the item has keyboard focus.
  bool get focused => _focused;

  /// Sets [focused], and notifies listeners when it changes.
  void setFocused(bool focused) {
    if (focused == _focused) return;
    _focused = focused;
    notifyListeners();
  }

  /// Identifies the item in its parent's [items] map.
  final Key itemKey;

  /// Maps the item key to the item controller
  final Map<Key, ContextMenuItemController> items = {};

  /// Whether the item is highlighted: it is hovered or focused, or an item in
  /// its submenu is.
  bool get selected =>
      _hovered || _focused || items.values.any((e) => e.selected);

  /// Clears [hovered] on this item and on every item in its submenu.
  void clearHovered() {
    for (final item in items.values) {
      item.clearHovered();
    }
    setHovered(false);
  }

  /// Adds [controller] to the items of this item's submenu.
  void registerSubItem(ContextMenuItemController controller) {
    items[controller.itemKey] = controller;
  }

  /// Removes [controller] from the items of this item's submenu.
  void unregisterSubItem(ContextMenuItemController controller) {
    items.remove(controller.itemKey);
  }
}

/// The variant of the context menu item.
enum ContextMenuItemVariant {
  /// A regular row.
  primary,

  /// A row with extra start padding, so that its label lines up with rows that
  /// have a leading icon. shadcn's `inset` prop.
  inset,
}

/// A row in a [ContextMenu], shadcn's `DropdownMenuItem`.
///
/// When [items] is not empty, the row opens a submenu with them on hover.
class ContextMenuItem extends StatefulWidget {
  /// Creates a regular menu item.
  const ContextMenuItem({
    super.key,
    required this.child,
    this.items = const [],
    this.enabled = true,
    this.leading,
    this.trailing,
    this.leadingPadding,
    this.trailingPadding,
    this.padding,
    this.onPressed,
    this.onTapDown,
    this.anchor,
    this.showDelay,
    this.height,
    this.buttonVariant,
    this.decoration,
    this.textStyle,
    this.selectedTextStyle,
    this.trailingTextStyle,
    this.constraints,
    this.subMenuPadding,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.closeOnTap,
    this.destructive = false,
  }) : variant = ContextMenuItemVariant.primary,
       insetPadding = null;

  /// Creates a menu item with an explicit [variant].
  const ContextMenuItem.raw({
    super.key,
    required this.variant,
    required this.child,
    this.items = const [],
    this.enabled = true,
    this.leading,
    this.trailing,
    this.leadingPadding,
    this.trailingPadding,
    this.padding,
    this.insetPadding,
    this.onPressed,
    this.onTapDown,
    this.anchor,
    this.showDelay,
    this.height,
    this.buttonVariant,
    this.decoration,
    this.textStyle,
    this.selectedTextStyle,
    this.trailingTextStyle,
    this.constraints,
    this.subMenuPadding,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.closeOnTap,
    this.destructive = false,
  });

  /// Creates an inset menu item, whose label lines up with items that have a
  /// leading icon.
  const ContextMenuItem.inset({
    super.key,
    required this.child,
    this.items = const [],
    this.enabled = true,
    this.leading,
    this.trailing,
    this.leadingPadding,
    this.trailingPadding,
    this.padding,
    this.insetPadding,
    this.onPressed,
    this.onTapDown,
    this.anchor,
    this.showDelay,
    this.height,
    this.buttonVariant,
    this.decoration,
    this.textStyle,
    this.selectedTextStyle,
    this.trailingTextStyle,
    this.constraints,
    this.subMenuPadding,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.closeOnTap,
    this.destructive = false,
  }) : variant = ContextMenuItemVariant.inset;

  /// {@template ContextMenuItem.variant}
  /// The variant of the context menu item, defaults to
  /// [ContextMenuItemVariant.primary].
  /// {@endtemplate}
  final ContextMenuItemVariant variant;

  /// {@template ContextMenuItem.child}
  /// The child of the context menu item.
  /// {@endtemplate}
  final Widget child;

  /// {@template ContextMenuItem.enabled}
  /// Whether the context menu item is enabled, defaults to true.
  /// {@endtemplate}
  final bool enabled;

  /// {@template ContextMenuItem.leading}
  /// The leading widget of the context menu item.
  /// {@endtemplate}
  final Widget? leading;

  /// {@template ContextMenuItem.trailing}
  /// The trailing widget of the context menu item.
  /// {@endtemplate}
  final Widget? trailing;

  /// {@template ContextMenuItem.leadingPadding}
  /// The padding of the leading widget, defaults to
  /// `EdgeInsets.only(right: 8)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? leadingPadding;

  /// {@template ContextMenuItem.trailingPadding}
  /// The padding of the trailing widget, defaults to
  /// `EdgeInsets.only(left: 8)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? trailingPadding;

  /// {@template ContextMenuItem.padding}
  /// The padding of the context menu item, defaults to
  /// `EdgeInsets.symmetric(horizontal: 4)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template ContextMenuItem.insetPadding}
  /// The row's own padding. Defaults to the style's item padding
  /// (`StyleTokens.itemPaddingX`, shadcn's `px-2`) on both sides, plus a
  /// 24px icon column at the start when the variant is inset.
  /// {@endtemplate}
  final EdgeInsetsGeometry? insetPadding;

  /// {@template ContextMenuItem.onPressed}
  /// The callback called when the context menu item is pressed.
  /// {@endtemplate}
  final VoidCallback? onPressed;

  /// {@template ContextMenuItem.onTapDown}
  /// The callback called when a pointer down event is detected on the context
  /// menu item. Useful when the action must fire immediately before the
  /// overlay is dismissed (e.g. text selection context menus).
  /// {@endtemplate}
  final ValueChanged<TapDownDetails>? onTapDown;

  /// {@template ContextMenuItem.anchor}
  /// The anchor of the context menu item, defaults to
  /// ```dart
  /// AnchorAuto(
  ///   offset: Offset(-8, parentItemController != null ? -5 : -3),
  ///   targetAnchor: Alignment.topRight,
  ///   followerAnchor: Alignment.bottomRight,
  /// )
  /// ```
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@template ContextMenuItem.showDelay}
  /// How long an item with a submenu stays highlighted, with its submenu
  /// open, after the pointer leaves it. Defaults to 100ms.
  ///
  /// The grace period lets the pointer cross the gap to the submenu without
  /// the submenu closing under it. Reaching another row of the same menu
  /// ends it at once.
  /// {@endtemplate}
  final Duration? showDelay;

  /// {@template ContextMenuItem.height}
  /// The height of the context menu item, defaults to 32.
  /// {@endtemplate}
  final double? height;

  /// {@template ContextMenuItem.buttonVariant}
  /// The variant of the button of the context menu item, defaults to
  /// [ButtonVariant.ghost].
  /// {@endtemplate}
  final ButtonVariant? buttonVariant;

  /// {@template ContextMenuItem.decoration}
  /// The decoration of the context menu item, defaults to
  /// `FinesseDecoration(secondaryBorder: FinesseBorder.none)`.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template ContextMenuItem.textStyle}
  /// The text style of the context menu item, defaults to
  /// `small.copyWith(fontWeight: FontWeight.normal)`.
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// {@template ContextMenuItem.selectedTextStyle}
  /// The text style of the item while it is selected or hovered.
  ///
  /// Defaults to [textStyle]. It exists because a menu whose selection is a
  /// strong fill needs its label to change with it.
  /// {@endtemplate}
  final TextStyle? selectedTextStyle;

  /// {@template ContextMenuItem.trailingTextStyle}
  /// The text style of the trailing widget, defaults to
  /// `muted.copyWith(fontSize: 12, height: 1)`.
  /// {@endtemplate}
  final TextStyle? trailingTextStyle;

  /// {@macro ContextMenu.constraints}
  final BoxConstraints? constraints;

  /// {@macro ContextMenu.padding}
  final EdgeInsetsGeometry? subMenuPadding;

  /// {@template ContextMenuItem.backgroundColor}
  /// The background color of the context menu item, defaults to
  /// `null`.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template ContextMenuItem.selectedBackgroundColor}
  /// The background color of the context menu item when it is selected,
  /// defaults to `theme.colorScheme.accent`.
  /// {@endtemplate}
  final Color? selectedBackgroundColor;

  /// {@template ContextMenuItem.closeOnTap}
  /// Whether the context menu should be closed when the item is tapped,
  /// defaults to `true` when [items] is empty, otherwise `false`.
  /// {@endtemplate}
  final bool? closeOnTap;

  /// {@template ContextMenuItem.items}
  /// The submenu items of the context menu item.
  /// {@endtemplate}
  final List<Widget> items;

  /// {@template ContextMenuItem.destructive}
  /// Whether this is a destructive action, shadcn's
  /// `data-[variant=destructive]`: the label and icons take the destructive
  /// colour and the hover highlight becomes a destructive wash.
  /// {@endtemplate}
  final bool destructive;

  @override
  State<ContextMenuItem> createState() => _ContextMenuItemState();
}

class _ContextMenuItemState extends State<ContextMenuItem> {
  final itemKey = UniqueKey();
  late final controller = ContextMenuItemController(itemKey: itemKey);

  /// Shared with the item's button so the trailing widget and text colours
  /// can follow the button's own hover state — a leaf item is only ever
  /// hovered, never "selected", so selection alone cannot drive them.
  final statesController = StatesController();
  // get the parent item controller, if any, meaning this item is a submenu
  late final parentItemController = context
      .maybeRead<ContextMenuItemController>();

  bool get hasTrailingIcon => widget.items.isNotEmpty;

  /// Pending un-hover of an item with a submenu, so the pointer can cross the
  /// gap to the submenu without closing it.
  Timer? _unhoverTimer;

  /// Ends the grace period now: drops the highlight and closes the submenu,
  /// including any nested submenu still in its own grace period.
  void _unhoverNow() {
    _unhoverTimer?.cancel();
    _unhoverTimer = null;
    controller.clearHovered();
  }

  bool _buttonHovered = false;

  /// Tells the menu level when the pointer reaches this row, so the row it
  /// came from lets go at once. The button's own hover is used because leaf
  /// rows have no hover area of their own.
  void _onStatesChanged() {
    final hovered = statesController.value.contains(FinesseState.hovered);
    if (hovered == _buttonHovered) return;
    _buttonHovered = hovered;
    if (hovered) {
      context.getInheritedWidgetOfExactType<_MenuLevel>()?.menu._itemHovered(
        this,
      );
    }
  }

  void _onHoverArea(bool hovered, Duration grace) {
    if (hovered || grace == Duration.zero) {
      _unhoverTimer?.cancel();
      _unhoverTimer = null;
      controller.setHovered(hovered);
      return;
    }
    // The mouse area reports an exit on every pointer event outside it, not
    // once. Restarting the timer on each would keep the item highlighted,
    // and its submenu open, for as long as the pointer moves.
    if (!controller.hovered || (_unhoverTimer?.isActive ?? false)) return;
    _unhoverTimer = Timer(grace, () {
      if (mounted) controller.setHovered(false);
    });
  }

  @override
  void initState() {
    super.initState();
    statesController.addListener(_onStatesChanged);
    // register the subitem controller if this item is a submenu
    parentItemController?.registerSubItem(controller);
  }

  @override
  void dispose() {
    _unhoverTimer?.cancel();
    parentItemController?.unregisterSubItem(controller);
    controller.dispose();
    statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final contextMenu = context.read<ContextMenuState>();

    final effectivePadding =
        widget.padding ??
        theme.contextMenuTheme.itemPadding ??
        const EdgeInsets.symmetric(horizontal: 4);

    // The row's own horizontal padding (`px-2`), from the style tokens so a
    // denser or roomier style moves it. An inset row reserves shadcn's
    // `pl-8`-style gutter: the base padding plus a 24px icon column.
    final itemPaddingX = theme.style.itemPaddingX * theme.spacing.step / 4;
    final defaultInsetPadding = switch (widget.variant) {
      ContextMenuItemVariant.primary => EdgeInsets.symmetric(
        horizontal: itemPaddingX,
      ),
      ContextMenuItemVariant.inset => EdgeInsetsDirectional.only(
        start: itemPaddingX + 24,
        end: itemPaddingX,
      ),
    };

    final effectiveInsetPadding =
        widget.insetPadding ??
        theme.contextMenuTheme.insetPadding ??
        defaultInsetPadding;

    final effectiveLeadingPadding =
        widget.leadingPadding ??
        theme.contextMenuTheme.leadingPadding ??
        const EdgeInsetsDirectional.only(end: 8);

    final effectiveTrailingPadding =
        widget.trailingPadding ??
        theme.contextMenuTheme.trailingPadding ??
        const EdgeInsetsDirectional.only(start: 8);

    // A submenu opens beside its item and flips to the other side when it
    // would cross the screen edge, instead of sliding over its parent.
    final submenuOffsetY = parentItemController != null ? -5.0 : -3.0;
    final effectiveAnchor =
        widget.anchor ??
        theme.contextMenuTheme.anchor ??
        AnchorAuto(
          offset: Offset(-8, submenuOffsetY),
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
          fallback: AnchorAuto(
            offset: Offset(8, submenuOffsetY),
            targetAnchor: Alignment.topLeft,
            followerAnchor: Alignment.bottomLeft,
          ),
        );

    final effectiveHeight =
        widget.height ?? theme.contextMenuTheme.height ?? 32;

    final effectiveShowDelay =
        widget.showDelay ??
        theme.contextMenuTheme.showDelay ??
        const Duration(milliseconds: 100);

    final effectiveButtonVariant =
        widget.buttonVariant ??
        theme.contextMenuTheme.buttonVariant ??
        ButtonVariant.ghost;

    final effectiveDecoration = const FinesseDecoration(
      secondaryBorder: FinesseBorder.none,
      secondaryFocusedBorder: FinesseBorder.none,
    ).merge(theme.contextMenuTheme.itemDecoration).merge(widget.decoration);

    // Menu rows draw their colours from the menu palette slots. shadcn's
    // states, per `cn-dropdown-menu-item`: rest is the popover foreground,
    // hover/open is `bg-accent text-accent-foreground` with every descendant
    // (icons included) following, and a destructive row keeps its destructive
    // text over a `destructive/10` wash (`/20` in dark).
    final effectiveTextStyle =
        (widget.textStyle ??
                theme.contextMenuTheme.textStyle ??
                theme.textTheme.small.copyWith(fontWeight: FontWeight.normal))
            .fallback(color: theme.colorScheme.popoverForeground);

    final effectiveSelectedTextStyle =
        (widget.selectedTextStyle ??
                theme.contextMenuTheme.selectedTextStyle ??
                effectiveTextStyle)
            .fallback(color: theme.colorScheme.accentForeground);

    final effectiveTrailingTextStyle =
        (widget.trailingTextStyle ??
                theme.contextMenuTheme.trailingTextStyle ??
                theme.textTheme.muted.copyWith(
                  fontSize: 12,
                  height: 1,
                ))
            .fallback(color: theme.colorScheme.mutedForeground);

    final effectiveSelectedTrailingTextStyle =
        theme.contextMenuTheme.selectedTrailingTextStyle ??
        effectiveTrailingTextStyle.copyWith(
          color: effectiveSelectedTextStyle.color,
        );

    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.contextMenuTheme.backgroundColor;

    var effectiveSelectedBackgroundColor =
        widget.selectedBackgroundColor ??
        theme.contextMenuTheme.selectedBackgroundColor ??
        theme.colorScheme.accent;

    var foregroundColor = effectiveTextStyle.color!;
    var selectedForegroundColor = effectiveSelectedTextStyle.color!;

    if (widget.destructive) {
      final destructive =
          theme.contextMenuTheme.destructiveForegroundColor ??
          theme.colorScheme.destructive;
      foregroundColor = destructive;
      selectedForegroundColor = destructive;
      effectiveSelectedBackgroundColor =
          theme.contextMenuTheme.destructiveSelectedBackgroundColor ??
          destructive.withValues(
            alpha:
                destructive.a * (theme.brightness == Brightness.dark ? .2 : .1),
          );
    }

    final effectiveCloseOnTap =
        widget.closeOnTap ??
        theme.contextMenuTheme.closeOnTap ??
        widget.items.isEmpty;

    /// if the item has submenu items, use the current item key,
    /// otherwise use the parent item controller's item key
    /// or the current item key if there is no parent item
    final effectiveGroupId = widget.items.isNotEmpty
        ? itemKey
        : parentItemController?.itemKey ?? itemKey;

    Widget child = ListenableBuilder(
      listenable: Listenable.merge([controller, statesController]),
      builder: (context, _) {
        final hovered = statesController.value.contains(FinesseState.hovered);
        final selected = controller.selected;
        // Rest vs highlight, resolved here because a leaf item's hover lives
        // in the button's own states — selection alone cannot see it.
        final highlighted = selected || hovered;

        return ContextMenu(
          visible: selected,
          anchor: effectiveAnchor,
          constraints: widget.constraints,
          padding: widget.subMenuPadding,
          groupId: effectiveGroupId,
          onHoverArea: (hovered) => _onHoverArea(hovered, effectiveShowDelay),
          items: widget.items,
          child: Padding(
            padding: effectivePadding,
            child: Button.raw(
              height: effectiveHeight,
              enabled: widget.enabled,
              variant: effectiveButtonVariant,
              decoration: effectiveDecoration,
              width: double.infinity,
              padding: effectiveInsetPadding,
              statesController: statesController,
              backgroundColor: selected
                  ? effectiveSelectedBackgroundColor
                  : effectiveBackgroundColor,
              hoverBackgroundColor: effectiveSelectedBackgroundColor,
              // Through the button rather than a wrapping DefaultTextStyle,
              // so its IconTheme recolours leading and trailing icons with
              // the text — shadcn's `focus:**:text-accent-foreground`.
              foregroundColor: selected
                  ? selectedForegroundColor
                  : foregroundColor,
              hoverForegroundColor: selectedForegroundColor,
              textStyle: highlighted
                  ? effectiveSelectedTextStyle
                  : effectiveTextStyle,
              onFocusChange: controller.setFocused,
              onTapDown: widget.onTapDown != null
                  ? (details) {
                      widget.onTapDown!(details);
                      if (effectiveCloseOnTap) contextMenu.setVisible(false);
                    }
                  : null,
              onPressed: () {
                widget.onPressed?.call();
                if (effectiveCloseOnTap) contextMenu.setVisible(false);
              },
              child: Expanded(
                child: Row(
                  children: [
                    if (widget.leading != null)
                      Padding(
                        padding: effectiveLeadingPadding,
                        child: widget.leading,
                      ),
                    // The button centres its text (`TextAlign.center` in its
                    // DefaultTextStyle); a menu row is start-aligned.
                    Expanded(
                      child: DefaultTextStyle.merge(
                        textAlign: TextAlign.start,
                        child: widget.child,
                      ),
                    ),
                    if (widget.trailing != null)
                      Padding(
                        padding: effectiveTrailingPadding,
                        child: DefaultTextStyle(
                          style: highlighted
                              ? effectiveSelectedTrailingTextStyle
                              : effectiveTrailingTextStyle,
                          child: widget.trailing!,
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

    final itemConstraints = theme.contextMenuTheme.itemConstraints;
    if (itemConstraints != null) {
      child = ConstrainedBox(constraints: itemConstraints, child: child);
    }

    // if the item has at least one submenu item, wrap it in a provider to
    //provide the controller to the submenu items
    if (widget.items.isNotEmpty) {
      child = Provider(
        data: controller,
        child: child,
      );
    }

    return child;
  }
}

/// Marks the items built by one menu level, so a menu can tell its own items
/// from those of a submenu below it.
class _MenuLevel extends InheritedWidget {
  const _MenuLevel({required this.menu, required super.child});

  final ContextMenuState menu;

  @override
  bool updateShouldNotify(_MenuLevel oldWidget) => menu != oldWidget.menu;
}
