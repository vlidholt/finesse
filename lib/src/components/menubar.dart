import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/context_menu.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:finesse/src/utils/provider_index.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    this.radius,
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

  /// {@template Menubar.radius}
  /// The radius of the menubar, default to `theme.radius`
  /// {@endtemplate}
  final BorderRadiusGeometry? radius;

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
  /// `FinesseBorder.all(color: theme.colorScheme.border, width: 1)`
  /// {@endtemplate}
  final FinesseBorder? border;

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
        widget.radius ?? theme.menubarTheme.radius ?? theme.radius;
    final effectivePadding =
        widget.padding ?? theme.menubarTheme.padding ?? const EdgeInsets.all(4);
    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.menubarTheme.backgroundColor;
    final effectiveBorder = FinesseBorder.all(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.items
              .mapIndexed(
                (i, item) => IndexProvider(index: i, child: item),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// A menubar item that contains a list of items, typically a list of
/// [ContextMenuItem].
class MenubarItem extends StatefulWidget {
  /// Creates the menubar item with the given [items].
  const MenubarItem({
    super.key,
    required this.child,
    required this.items,
    this.constraints,
    this.onHoverArea,
    this.padding,
    this.groupId,
    this.effects,
    this.shadows,
    this.decoration,
    this.filter,
    this.controller,
    this.anchor,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.variant,
    this.size,
    this.cursor,
    this.width,
    this.height,
    this.buttonPadding,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.focusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.buttonShadows,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.buttonDecoration,
    this.enabled = true,
    this.statesController,
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.textDirection,
    this.onFocusChange,
    this.expands,
  });

  /// The child of the menubar item
  final Widget child;

  /// {@macro ContextMenu.items}
  final List<Widget> items;

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

  /// {@macro Popover.controller}
  final PopoverController? controller;

  /// {@template MenubarItem.anchor}
  /// The anchor of the context menu shown by the item, defaults to
  /// ```dart
  /// const AnchorAuto(
  ///   offset: Offset(-4, 8),
  ///   followerAnchor: Alignment.bottomRight,
  ///   targetAnchor: Alignment.bottomLeft,
  /// );
  /// ```
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@macro Button.onLongPress}
  final VoidCallback? onLongPress;

  /// {@macro Button.leading}
  final Widget? leading;

  /// {@macro Button.trailing}
  final Widget? trailing;

  /// {@macro Button.variant}
  ///
  /// Defaults to `ButtonVariant.ghost`.
  final ButtonVariant? variant;

  /// {@macro Button.size}
  final ButtonSize? size;

  /// {@macro Button.cursor}
  final MouseCursor? cursor;

  /// {@macro Button.width}
  final double? width;

  /// {@template MenubarItem.height}
  /// {@macro Button.height}
  ///
  /// Defaults to `32`.
  /// {@endtemplate}
  final double? height;

  /// {@macro Button.padding}
  final EdgeInsetsGeometry? buttonPadding;

  /// {@macro Button.backgroundColor}
  final Color? backgroundColor;

  /// {@template MenubarItem.selectedBackgroundColor}
  /// The background color of the button when the item is selected, defaults to
  /// `theme.colorScheme.accent`.
  /// {@endtemplate}
  final Color? selectedBackgroundColor;

  /// {@macro Button.hoverBackgroundColor}
  final Color? hoverBackgroundColor;

  /// {@macro Button.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Button.hoverForegroundColor}
  final Color? hoverForegroundColor;

  /// {@macro Button.autofocus}
  final bool autofocus;

  /// {@macro Button.focusNode}
  final FocusNode? focusNode;

  /// {@macro Button.pressedBackgroundColor}
  final Color? pressedBackgroundColor;

  /// {@macro Button.pressedForegroundColor}
  final Color? pressedForegroundColor;

  /// {@macro Button.shadows}
  final List<BoxShadow>? buttonShadows;

  /// {@macro Button.gradient}
  final Gradient? gradient;

  /// {@macro Button.textDecoration}
  final TextDecoration? textDecoration;

  /// {@macro Button.hoverTextDecoration}
  final TextDecoration? hoverTextDecoration;

  /// {@macro Button.decoration}
  final FinesseDecoration? buttonDecoration;

  /// {@macro Button.enabled}
  final bool enabled;

  /// {@macro Button.statesController}
  final WidgetStatesController? statesController;

  /// {@macro Button.gap}
  final double? gap;

  /// {@macro Button.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Button.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? hoverStrategies;

  /// {@macro Button.onHoverChange}
  final ValueChanged<bool>? onHoverChange;

  /// {@macro Button.onTapDown}
  final ValueChanged<TapDownDetails>? onTapDown;

  /// {@macro Button.onTapUp}
  final ValueChanged<TapUpDetails>? onTapUp;

  /// {@macro Button.onTapCancel}
  final VoidCallback? onTapCancel;

  /// {@macro Button.onSecondaryTapDown}
  final ValueChanged<TapDownDetails>? onSecondaryTapDown;

  /// {@macro Button.onSecondaryTapUp}
  final ValueChanged<TapUpDetails>? onSecondaryTapUp;

  /// {@macro Button.onSecondaryTapCancel}
  final VoidCallback? onSecondaryTapCancel;

  /// {@macro Button.onLongPressStart}
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  /// {@macro Button.onLongPressCancel}
  final VoidCallback? onLongPressCancel;

  /// {@macro Button.onLongPressUp}
  final VoidCallback? onLongPressUp;

  /// {@macro Button.onLongPressDown}
  final ValueChanged<LongPressDownDetails>? onLongPressDown;

  /// {@macro Button.onLongPressEnd}
  final ValueChanged<LongPressEndDetails>? onLongPressEnd;

  /// {@macro Button.onDoubleTap}
  final VoidCallback? onDoubleTap;

  /// {@macro Button.onDoubleTapDown}
  final ValueChanged<TapDownDetails>? onDoubleTapDown;

  /// {@macro Button.onDoubleTapCancel}
  final VoidCallback? onDoubleTapCancel;

  /// {@macro Button.longPressDuration}
  final Duration? longPressDuration;

  /// {@macro Button.textDirection}
  final TextDirection? textDirection;

  /// {@macro Button.onFocusChange}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro Button.expands}
  final bool? expands;

  @override
  State<MenubarItem> createState() => _MenubarItemState();
}

class _MenubarItemState extends State<MenubarItem> {
  PopoverController? _popoverController;

  PopoverController get popoverController =>
      widget.controller ?? _popoverController!;

  MenubarController? _menubarController;

  MenubarController get menubarController => _menubarController!;

  late int index;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _popoverController = PopoverController();
    }
  }

  void onSelectedIndexChange() {
    final selected = menubarController.selectedIndex == index;
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
    _popoverController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inherited = context.watch<_MenubarState>();
    final theme = Theme.of(context);
    final effectiveAnchor =
        widget.anchor ??
        theme.menubarTheme.anchor ??
        const Anchor(
          offset: Offset(-4, 8),
          childAlignment: AlignmentDirectional.bottomStart,
          overlayAlignment: AlignmentDirectional.topStart,
        );

    final effectiveHeight =
        widget.height ?? theme.menubarTheme.buttonHeight ?? 32;
    final effectiveVariant =
        widget.variant ??
        theme.menubarTheme.buttonVariant ??
        ButtonVariant.ghost;
    final effectiveSelectedBackgroundColor =
        widget.selectedBackgroundColor ??
        theme.menubarTheme.buttonSelectedBackgroundColor ??
        theme.colorScheme.accent;
    final effectiveButtonDecoration = const FinesseDecoration(
      disableSecondaryBorder: true,
    ).merge(theme.menubarTheme.buttonDecoration).merge(widget.buttonDecoration);
    final effectiveSelectOnHover =
        inherited.widget.selectOnHover ??
        theme.menubarTheme.selectOnHover ??
        true;

    return ListenableBuilder(
      listenable: menubarController,
      builder: (context, child) {
        final selected = menubarController.selectedIndex == index;
        return ContextMenu(
          anchor: effectiveAnchor,
          controller: popoverController,
          items: widget.items,
          constraints: widget.constraints ?? theme.menubarTheme.constraints,
          onHoverArea: widget.onHoverArea,
          padding: widget.padding ?? theme.menubarTheme.contextMenuPadding,
          groupId: widget.groupId,
          effects: widget.effects ?? theme.menubarTheme.effects,
          shadows: widget.shadows ?? theme.menubarTheme.shadows,
          decoration: widget.decoration ?? theme.menubarTheme.decoration,
          filter: widget.filter ?? theme.menubarTheme.filter,
          onTapUpInside: (_) {
            menubarController.selectedIndex = index;
          },
          onTapOutside: (_) {
            menubarController.selectedIndex = null;
          },
          child: Button.raw(
            variant: effectiveVariant,
            height: effectiveHeight,
            backgroundColor: selected
                ? effectiveSelectedBackgroundColor
                : widget.backgroundColor ??
                      theme.menubarTheme.buttonBackgroundColor,
            focusNode: widget.focusNode,
            onFocusChange: (focused) {
              widget.onFocusChange?.call(focused);
              // Set the selected index
              if (focused) {
                menubarController.selectedIndex = index;
              }
            },
            onHoverChange: (hovered) {
              widget.onHoverChange?.call(hovered);
              if (!hovered) return;
              if (!effectiveSelectOnHover) return;
              // Hover only *switches* menus: a closed menubar opens on tap,
              // like the reference (`radix`'s menubar), not on pointer-over.
              if (menubarController.selectedIndex == null) return;
              menubarController.selectedIndex = index;
            },
            onPressed: () {
              menubarController.selectedIndex = index;
              // If selected and popover is not open, open it
              if (selected && !popoverController.isOpen) {
                popoverController.show();
              }
            },
            onLongPress: widget.onLongPress,
            leading: widget.leading,
            trailing: widget.trailing,
            size: widget.size ?? theme.menubarTheme.buttonSize,
            cursor: widget.cursor ?? theme.menubarTheme.buttonCursor,
            width: widget.width ?? theme.menubarTheme.buttonWidth,
            padding: widget.buttonPadding ?? theme.menubarTheme.buttonPadding,
            hoverBackgroundColor:
                widget.hoverBackgroundColor ??
                theme.menubarTheme.buttonHoverBackgroundColor,
            foregroundColor:
                widget.foregroundColor ??
                theme.menubarTheme.buttonForegroundColor,
            hoverForegroundColor:
                widget.hoverForegroundColor ??
                theme.menubarTheme.buttonHoverForegroundColor,
            autofocus: widget.autofocus,
            pressedBackgroundColor:
                widget.pressedBackgroundColor ??
                theme.menubarTheme.buttonPressedBackgroundColor,
            pressedForegroundColor:
                widget.pressedForegroundColor ??
                theme.menubarTheme.buttonPressedForegroundColor,
            shadows: widget.buttonShadows ?? theme.menubarTheme.buttonShadows,
            gradient: widget.gradient ?? theme.menubarTheme.buttonGradient,
            textDecoration:
                widget.textDecoration ??
                theme.menubarTheme.buttonTextDecoration,
            hoverTextDecoration:
                widget.hoverTextDecoration ??
                theme.menubarTheme.buttonHoverTextDecoration,
            decoration: effectiveButtonDecoration,
            enabled: widget.enabled,
            statesController: widget.statesController,
            gap: widget.gap ?? theme.menubarTheme.buttonGap,
            mainAxisAlignment:
                widget.mainAxisAlignment ??
                theme.menubarTheme.buttonMainAxisAlignment,
            crossAxisAlignment:
                widget.crossAxisAlignment ??
                theme.menubarTheme.buttonCrossAxisAlignment,
            hoverStrategies:
                widget.hoverStrategies ??
                theme.menubarTheme.buttonHoverStrategies,
            onTapDown: widget.onTapDown,
            onTapUp: widget.onTapUp,
            onTapCancel: widget.onTapCancel,
            onSecondaryTapDown: widget.onSecondaryTapDown,
            onSecondaryTapUp: widget.onSecondaryTapUp,
            onSecondaryTapCancel: widget.onSecondaryTapCancel,
            onLongPressStart: widget.onLongPressStart,
            onLongPressCancel: widget.onLongPressCancel,
            onLongPressUp: widget.onLongPressUp,
            onLongPressDown: widget.onLongPressDown,
            onLongPressEnd: widget.onLongPressEnd,
            onDoubleTap: widget.onDoubleTap,
            onDoubleTapDown: widget.onDoubleTapDown,
            onDoubleTapCancel: widget.onDoubleTapCancel,
            longPressDuration: widget.longPressDuration,
            textDirection:
                widget.textDirection ?? theme.menubarTheme.buttonTextDirection,
            expands: widget.expands ?? theme.menubarTheme.buttonExpands,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
