import 'package:flutter/widgets.dart';
import 'package:una/src/components/context_menu.dart';
import 'package:una/src/components/popover.dart';
import 'package:una/src/raw_components/portal.dart';

/// Builds a [DropdownMenu]'s trigger. Call `controller.toggle` from the
/// trigger's `onPressed`.
typedef DropdownMenuTriggerBuilder = Widget Function(
  BuildContext context,
  PopoverController controller,
  Widget? child,
);

/// {@template DropdownMenu}
/// shadcn/ui's DropdownMenu: a menu that opens from a trigger, below it and
/// aligned to its start edge.
///
/// The menu is a [ContextMenu], so it takes the same items
/// ([MenuItem], separators, labels, submenus), scrolls when long,
/// supports keyboard navigation and type-ahead, and flips to stay on screen:
/// to the trigger's end edge near the side of the screen, above it near the
/// bottom.
///
/// ```dart
/// DropdownMenu(
///   items: [
///     MenuItem(child: Text('Profile'), onPressed: () {}),
///     MenuItem(child: Text('Log out'), onPressed: () {}),
///   ],
///   builder: (context, controller, _) => Button.outline(
///     onPressed: controller.toggle,
///     child: const Text('Open'),
///   ),
/// )
/// ```
/// {@endtemplate}
class DropdownMenu extends StatefulWidget {
  /// {@macro DropdownMenu}
  const DropdownMenu({
    super.key,
    required this.builder,
    this.items = const [],
    this.itemsBuilder,
    this.child,
    this.controller,
    this.anchor,
    this.constraints,
    this.padding,
    this.onOpenChanged,
    this.requestFocus = true,
  });

  /// Builds the trigger. See [DropdownMenuTriggerBuilder].
  final DropdownMenuTriggerBuilder builder;

  /// {@macro ContextMenu.items}
  final List<Widget> items;

  /// {@macro ContextMenu.itemsBuilder}
  final List<Widget> Function(BuildContext context)? itemsBuilder;

  /// Passed to [builder] unchanged, for a part of the trigger that does not
  /// depend on the controller.
  final Widget? child;

  /// Controls whether the menu is open. One is created when not given.
  final PopoverController? controller;

  /// Where the menu opens. Defaults to below the trigger at its start edge,
  /// falling back to its end edge and then to above it.
  final AnchorBase? anchor;

  /// {@macro ContextMenu.constraints}
  final BoxConstraints? constraints;

  /// {@macro ContextMenu.padding}
  final EdgeInsetsGeometry? padding;

  /// Called when the menu opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// {@macro ContextMenu.requestFocus}
  final bool requestFocus;

  /// The default anchor: Radix's `side="bottom" align="start"` with
  /// `sideOffset={4}`, trying the other alignment and then the other side
  /// when the menu would leave the screen.
  static const defaultAnchor = AnchorAuto(
    offset: Offset(0, 4),
    targetAnchor: AlignmentDirectional.bottomStart,
    followerAnchor: AlignmentDirectional.bottomEnd,
    fallback: AnchorAuto(
      offset: Offset(0, 4),
      targetAnchor: AlignmentDirectional.bottomEnd,
      followerAnchor: AlignmentDirectional.bottomStart,
      fallback: AnchorAuto(
        offset: Offset(0, -4),
        targetAnchor: AlignmentDirectional.topStart,
        followerAnchor: AlignmentDirectional.topEnd,
        fallback: AnchorAuto(
          offset: Offset(0, -4),
          targetAnchor: AlignmentDirectional.topEnd,
          followerAnchor: AlignmentDirectional.topStart,
        ),
      ),
    ),
  );

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  PopoverController? _ownController;
  PopoverController get _controller =>
      widget.controller ?? (_ownController ??= PopoverController());

  PopoverController? _listened;
  bool _wasOpen = false;

  void _listen() {
    final controller = _controller;
    if (identical(controller, _listened)) return;
    _listened?.removeListener(_onChanged);
    _listened = controller..addListener(_onChanged);
    _wasOpen = controller.isOpen;
  }

  void _onChanged() {
    final open = _controller.isOpen;
    if (open == _wasOpen) return;
    _wasOpen = open;
    widget.onOpenChanged?.call(open);
  }

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(DropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _listen();
  }

  @override
  void dispose() {
    _listened?.removeListener(_onChanged);
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenu(
      controller: _controller,
      anchor: widget.anchor ?? DropdownMenu.defaultAnchor,
      items: widget.items,
      itemsBuilder: widget.itemsBuilder,
      constraints: widget.constraints,
      padding: widget.padding,
      requestFocus: widget.requestFocus,
      child: widget.builder(context, _controller, widget.child),
    );
  }
}
