import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/context_menu.dart';
import 'package:una/src/components/popover.dart';
import 'package:una/src/raw_components/portal.dart';
import 'package:una/src/theme/components/button.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/border.dart';
import 'package:una/src/utils/entrance.dart';
import 'package:una/src/utils/moving_indicator.dart';
import 'package:una/src/utils/provider.dart';
import 'package:una/src/utils/provider_index.dart';
import 'package:una/src/utils/shadow.dart';

/// {@template MenubarController}
/// The controller for managing the selected item of the menubar
/// {@endtemplate}
class MenubarController extends ChangeNotifier {
  int? _selectedIndex;

  /// Returns the selected index of the menubar
  int? get selectedIndex => _selectedIndex;

  /// Sets the selected index of the menubar
  set selectedIndex(int? value) {
    if (_selectedIndex == value) return;
    _selectedIndex = value;
    notifyListeners();
  }
}

/// A menubar that contains a list of items, typically a list of
/// [MenubarItem].
class Menubar extends StatefulWidget {
  /// Creates the menubar with the given [items].
  const Menubar({
    super.key,
    required this.items,
    this.borderRadius,
    this.controller,
    this.padding,
    this.backgroundColor,
    this.border,
    this.selectOnHover,
    this.stripShadows,
  });

  /// {@template Menubar.stripShadows}
  /// The shadow of the menubar strip itself. Defaults to the style's control
  /// shadow (`shadow-xs` in the styles that shadow their controls); pass an
  /// empty list for a flat strip.
  ///
  /// `MenubarTheme.shadows` is the shadow of the menus that open from it.
  /// {@endtemplate}
  final List<BoxShadow>? stripShadows;

  /// {@template Menubar.items}
  /// The items of the menubar
  /// {@endtemplate}
  final Iterable<Widget> items;

  /// {@template Menubar.borderRadius}
  /// The radius of the menubar, default to `theme.radius`
  /// {@endtemplate}
  final BorderRadiusGeometry? borderRadius;

  /// {@macro MenubarController}
  final MenubarController? controller;

  /// {@template Menubar.padding}
  /// The padding of the menubar, default to `EdgeInsets.all(4)`
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Menubar.backgroundColor}
  /// The background color of the menubar, default to `null`
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Menubar.border}
  /// The border of the menubar, default to
  /// `UnaBorder.all(color: theme.colorScheme.border, width: 1)`
  /// {@endtemplate}
  final UnaBorder? border;

  /// {@template Menubar.selectOnHover}
  /// Whether hovering a trigger moves the selection *while a menu is already
  /// open*, defaults to `true`.
  ///
  /// Matching the reference menubar: a closed menubar only opens on tap (or
  /// keyboard), but once one menu is open, pointing at another trigger
  /// switches to its menu.
  /// {@endtemplate}
  final bool? selectOnHover;

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  int? focusedIndex;

  /// The pointer that last went down on one of this menubar's triggers.
  ///
  /// The same press reaches the open menu as a tap outside it. The menu
  /// leaves that press alone: the trigger it landed on switches to its own
  /// menu on the way up, so the selection goes from one menu straight to
  /// the next instead of through "none" — which is what lets the second
  /// menu take over from the first rather than open afresh.
  int? _triggerPointer;
  MenubarController? _controller;
  MenubarController get controller => widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = MenubarController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius =
        widget.borderRadius ?? theme.menubarTheme.borderRadius ?? theme.radius;
    final effectivePadding =
        widget.padding ?? theme.menubarTheme.padding ?? const EdgeInsets.all(4);
    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.menubarTheme.backgroundColor;
    final effectiveBorder = UnaBorder.all(
      color: theme.colorScheme.border,
      width: 1,
    ).merge(theme.menubarTheme.border).merge(widget.border);

    return Provider(
      // No notifyUpdate: `data` is this State, whose identity never changes,
      // so any predicate over it is constant. Items rebuild through the normal
      // parent-to-child path instead. The previous
      // `(oldState) => oldState.data != this` was always false, i.e. exactly
      // Provider's default.
      data: this,
      // A Container rather than DecoratedBox + Padding: Container counts its
      // decoration's border into the padding, which is what makes the strip
      // border-box — `h-9` in the reference includes the hairline, and the
      // theme's trigger height is derived assuming it does.
      child: Container(
        decoration: ShadowDecoration.box(
          color: effectiveBackgroundColor,
          border: effectiveBorder.toBorder(),
          borderRadius: effectiveRadius,
          // The strip's `shadow-xs`; only styles that shadow their controls
          // keep it. `MenubarTheme.shadows` belongs to the item popovers.
          shadows:
              widget.stripShadows ??
              theme.menubarTheme.stripShadows ??
              theme.style.controlShadow,
        ),
        padding: effectivePadding,
        // The open menu's trigger is marked by one fill that slides along
        // the strip as the menus are switched.
        child: MovingIndicator(
          // A menu bar to a screen reader, and its triggers menu items.
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            role: widget.items.isEmpty ? null : SemanticsRole.menuBar,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.items
                  .mapIndexed(
                    (i, item) => IndexProvider(index: i, child: item),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template MenubarItem}
/// One menu of a [Menubar]: a trigger in the strip and the menu that opens
/// under it.
///
/// The [items] are a menu's rows — [MenuItem], [MenuCheckboxItem],
/// [MenuRadioGroup], [MenuLabel], [MenuDivider], submenus. How the trigger
/// and its menu look is the theme's (`MenubarTheme`); re-theme the subtree
/// for a menubar that looks different.
///
/// ```dart
/// Menubar(
///   items: [
///     MenubarItem(
///       items: [
///         MenuItem(child: const Text('New tab'), onPressed: () {}),
///         const MenuDivider(),
///         MenuItem(child: const Text('Print…'), onPressed: () {}),
///       ],
///       child: const Text('File'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class MenubarItem extends StatefulWidget {
  /// {@macro MenubarItem}
  const MenubarItem({
    super.key,
    required this.child,
    required this.items,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.focusNode,
  });

  /// The trigger's label.
  final Widget child;

  /// {@macro ContextMenu.items}
  final List<Widget> items;

  /// {@macro Button.leading}
  final Widget? leading;

  /// {@macro Button.trailing}
  final Widget? trailing;

  /// Whether the trigger can be pressed and focused. Defaults to true.
  final bool enabled;

  /// {@macro Button.focusNode}
  final FocusNode? focusNode;

  @override
  State<MenubarItem> createState() => _MenubarItemState();
}

class _MenubarItemState extends State<MenubarItem> {
  final PopoverController popoverController = PopoverController();

  MenubarController? _menubarController;

  MenubarController get menubarController => _menubarController!;

  late int index;

  /// The menubar's selection when this item last heard of a change.
  int? _lastSelectedIndex;

  /// Whether this item's menu took over from another one that was open. It
  /// then only fades in: the menus stand in for one surface that changes
  /// its content, and a second full entrance beside the first would read as
  /// a flicker.
  bool _tookOver = false;

  @override
  void initState() {
    super.initState();
    popoverController.addListener(_onPopoverChanged);
  }

  bool _wasOpen = false;

  /// The menu closed by itself — a row was chosen, Escape, a press outside
  /// it: the menubar has no open menu any more. Left selected, hovering
  /// the next trigger would open its menu.
  void _onPopoverChanged() {
    final open = popoverController.isOpen;
    if (open == _wasOpen) return;
    _wasOpen = open;
    if (open) return;
    // After the frame: a menu that closed because the next one opened in
    // its place leaves the selection to that one.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || popoverController.isOpen) return;
      if (menubarController.selectedIndex == index) {
        menubarController.selectedIndex = null;
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// Right or Left out of the open menu: the next or the previous menu of
  /// the bar opens in its place, wrapping round at either end and passing
  /// over the triggers that are disabled.
  void _moveAcross(int step) {
    final items = context.read<_MenubarState>().widget.items.toList();
    final count = items.length;
    for (var i = 1; i < count; i++) {
      final next = (index + step * i) % count;
      final item = items[next];
      if (item is MenubarItem && !item.enabled) continue;
      menubarController.selectedIndex = next;
      return;
    }
  }

  /// Down on a trigger opens its menu, as Enter and Space do.
  KeyEventResult _onTriggerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.arrowDown ||
        !widget.enabled) {
      return KeyEventResult.ignored;
    }
    menubarController.selectedIndex = index;
    if (!popoverController.isOpen) popoverController.open();
    return KeyEventResult.handled;
  }

  void onSelectedIndexChange() {
    final previous = _lastSelectedIndex;
    final current = menubarController.selectedIndex;
    _lastSelectedIndex = current;
    final selected = current == index;
    if (selected && !popoverController.isOpen) {
      _tookOver = previous != null && previous != index;
    }
    popoverController.setOpen(selected);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = context.watch<_MenubarState>().controller;
    index = context.watch<ProviderIndex>().index;

    // Detach from the previous controller before adopting the new one. The
    // old code reassigned the field first and then removed the listener from
    // the *new* controller, so swapping Menubar.controller left the
    // listener attached to the old one forever — and it would later call
    // setOpen on a disposed popover controller.
    if (!identical(newController, _menubarController)) {
      _menubarController?.removeListener(onSelectedIndexChange);
      _menubarController = newController;
      newController.addListener(onSelectedIndexChange);
    }
  }

  @override
  void dispose() {
    _menubarController?.removeListener(onSelectedIndexChange);
    popoverController
      ..removeListener(_onPopoverChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inherited = context.watch<_MenubarState>();
    final theme = Theme.of(context);
    final menubarTheme = theme.menubarTheme;
    final effectiveAnchor =
        menubarTheme.anchor ??
        const Anchor(
          offset: Offset(-4, 8),
          childAlignment: AlignmentDirectional.bottomStart,
          overlayAlignment: AlignmentDirectional.topStart,
        );

    final effectiveHeight = menubarTheme.buttonHeight ?? 32;
    final effectiveVariant = menubarTheme.buttonVariant ?? ButtonVariant.ghost;
    final effectiveSelectedBackgroundColor =
        menubarTheme.buttonSelectedBackgroundColor ?? theme.colorScheme.accent;
    final effectiveButtonDecoration = const UnaDecoration(
      disableSecondaryBorder: true,
    ).merge(menubarTheme.buttonDecoration);
    // The shape of the trigger, for the fill that marks the open menu.
    final variantDecoration = switch (effectiveVariant) {
      ButtonVariant.primary => theme.primaryButtonTheme,
      ButtonVariant.destructive => theme.destructiveButtonTheme,
      ButtonVariant.secondary => theme.secondaryButtonTheme,
      ButtonVariant.ghost => theme.ghostButtonTheme,
      ButtonVariant.outline => theme.outlineButtonTheme,
      ButtonVariant.link => theme.linkButtonTheme,
    }.decoration;
    final effectiveSelectOnHover =
        inherited.widget.selectOnHover ?? menubarTheme.selectOnHover ?? true;

    final Widget item = ListenableBuilder(
      listenable: menubarController,
      builder: (context, child) {
        final selected = menubarController.selectedIndex == index;
        return ContextMenu.internal(
          anchor: effectiveAnchor,
          controller: popoverController,
          items: widget.items,
          constraints: menubarTheme.constraints,
          padding: menubarTheme.contextMenuPadding,
          // The menu that replaces its neighbour only fades in: a second
          // pop right beside the first reads as a flicker.
          entrance: _tookOver ? EntranceSpec.fade(Motion.of(context)) : null,
          shadows: menubarTheme.shadows,
          decoration: menubarTheme.decoration,
          filter: menubarTheme.filter,
          onTapUpInside: (_) {
            menubarController.selectedIndex = index;
          },
          onTapOutside: (event) {
            // A press on another trigger of this menubar: that trigger
            // decides.
            if (event.pointer == inherited._triggerPointer) return;
            menubarController.selectedIndex = null;
          },
          onMoveAcross: _moveAcross,
          child: MovingIndicatorTarget(
            selected: selected,
            decoration: BoxDecoration(
              color: effectiveSelectedBackgroundColor,
              borderRadius:
                  effectiveButtonDecoration.border?.borderRadius ??
                  variantDecoration?.border?.borderRadius,
            ),
            child: Listener(
              onPointerDown: widget.enabled
                  ? (event) => inherited._triggerPointer = event.pointer
                  : null,
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                includeSemantics: false,
                onKeyEvent: _onTriggerKey,
                child: Button(
                  variant: effectiveVariant,
                  style: ButtonTheme(
                    pressScale: 1,
                    height: effectiveHeight,
                    backgroundColor: menubarTheme.buttonBackgroundColor,
                    width: menubarTheme.buttonWidth,
                    padding: menubarTheme.buttonPadding,
                    hoverBackgroundColor:
                        menubarTheme.buttonHoverBackgroundColor,
                    foregroundColor: menubarTheme.buttonForegroundColor,
                    hoverForegroundColor:
                        menubarTheme.buttonHoverForegroundColor,
                    pressedBackgroundColor:
                        menubarTheme.buttonPressedBackgroundColor,
                    pressedForegroundColor:
                        menubarTheme.buttonPressedForegroundColor,
                    shadows: menubarTheme.buttonShadows,
                    gradient: menubarTheme.buttonGradient,
                    textDecoration: menubarTheme.buttonTextDecoration,
                    hoverTextDecoration: menubarTheme.buttonHoverTextDecoration,
                    decoration: effectiveButtonDecoration,
                    gap: menubarTheme.buttonGap,
                    mainAxisAlignment: menubarTheme.buttonMainAxisAlignment,
                    crossAxisAlignment: menubarTheme.buttonCrossAxisAlignment,
                  ),
                  // The focus only marks a trigger: Tab walks along the bar
                  // without opening a menu. Enter, Space and Down open it.
                  focusNode: widget.focusNode,
                  onHover: (hovered) {
                    if (!hovered) return;
                    if (!effectiveSelectOnHover) return;
                    // Hover only *switches* menus: a closed menubar opens on
                    // tap, like the reference (`radix`'s menubar), not on
                    // pointer-over.
                    if (menubarController.selectedIndex == null) return;
                    menubarController.selectedIndex = index;
                  },
                  onPressed: () {
                    menubarController.selectedIndex = index;
                    // If selected and popover is not open, open it
                    if (selected && !popoverController.isOpen) {
                      popoverController.open();
                    }
                  },
                  leading: widget.leading,
                  trailing: widget.trailing,
                  size: menubarTheme.buttonSize,
                  mouseCursor: menubarTheme.buttonMouseCursor,
                  enabled: widget.enabled,
                  expands: menubarTheme.buttonExpands,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
    // One node per trigger: a menu item of the bar, with the trigger's own
    // label and tap, that says whether its menu is open. The menu it opens
    // is drawn in the overlay, outside it.
    return MergeSemantics(
      child: ListenableBuilder(
        listenable: popoverController,
        builder: (context, child) => Semantics(
          role: SemanticsRole.menuItem,
          expanded: popoverController.isOpen,
          child: child,
        ),
        child: item,
      ),
    );
  }
}
