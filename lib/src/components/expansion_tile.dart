import 'dart:math' as math;

import 'package:finesse/src/components/list_section.dart';
import 'package:finesse/src/components/list_tile.dart';
import 'package:finesse/src/icons/phosphor_icon.dart';
import 'package:finesse/src/icons/phosphor_icons_regular.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/utils/expand_reveal.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';

/// A list row that opens to show rows of its own: a group of settings
/// folded under one heading, the parts of an order, the replies to a
/// message.
///
/// ```dart
/// ListSection(
///   children: [
///     ExpansionTile(
///       leading: const PhosphorIcon(PhosphorIconsRegular.bell),
///       title: const Text('Notifications'),
///       value: const Text('3 on'),
///       children: [
///         SwitchListTile(
///           title: const Text('Mentions'),
///           value: mentions,
///           onChanged: (value) => setState(() => mentions = value),
///         ),
///         // …
///       ],
///     ),
///   ],
/// )
/// ```
///
/// The heading is a `ListTile` that ends in a caret; tapping it, or Enter
/// or Space while it has the focus, opens or closes the row. The rows under
/// it unfold on the theme's `smooth` spring while the caret turns, and fold
/// away the same way; a change halfway carries on from where it was.
///
/// Inside a `ListSection` the heading and the rows under it read the
/// section's `ListSectionScope`, so they take its padding and fill to the
/// card's corners where they meet them; outside one they are plain tiles.
///
/// Give [open] to hold the state yourself, or [initiallyOpen] to let the
/// row keep it; [onOpenChanged] is called either way.
class ExpansionTile extends StatefulWidget {
  /// Creates a row that opens to show [children].
  const ExpansionTile({
    required this.title,
    required this.children,
    this.leading,
    this.subtitle,
    this.value,
    this.open,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.enabled = true,
    this.maintainState = false,
    this.childrenPadding,
    this.focusNode,
    super.key,
  }) : assert(
         open == null || !initiallyOpen,
         'Give open to control the row or initiallyOpen to seed it, not '
         'both.',
       );

  /// The heading, as a `ListTile`'s title.
  final Widget title;

  /// The rows shown while the row is open, usually `ListTile`s.
  final List<Widget> children;

  /// A widget before the heading: an icon, an avatar.
  final Widget? leading;

  /// A line under the heading.
  final Widget? subtitle;

  /// A short value before the caret, as a `ListTile`'s value: a count, the
  /// current choice.
  final Widget? value;

  /// Whether the row is open. Null lets the row keep its own state.
  final bool? open;

  /// Whether the row starts open when it keeps its own state.
  final bool initiallyOpen;

  /// Called with true when the heading is tapped to open the row, and with
  /// false when it is tapped to close it.
  final ValueChanged<bool>? onOpenChanged;

  /// Whether the heading can be tapped.
  final bool enabled;

  /// Whether the rows keep their state while the row is closed. They are
  /// built anyway, hidden, and out of the focus and semantics trees.
  final bool maintainState;

  /// The space around the rows. Defaults to none: rows are tiles with
  /// padding of their own.
  final EdgeInsetsGeometry? childrenPadding;

  /// The focus node of the heading.
  final FocusNode? focusNode;

  @override
  State<ExpansionTile> createState() => _ExpansionTileState();
}

class _ExpansionTileState extends State<ExpansionTile> {
  late bool _open = widget.open ?? widget.initiallyOpen;

  bool get _isOpen => widget.open ?? _open;

  void _toggle() {
    final next = !_isOpen;
    if (widget.open == null) setState(() => _open = next);
    widget.onOpenChanged?.call(next);
  }

  /// [scope] for a row at [position] of the section the tile is in.
  static Widget _scoped(
    ListSectionScope? scope,
    ListSectionPosition position,
    Widget child,
  ) {
    if (scope == null) return child;
    return ListSectionScope(
      position: position,
      variant: scope.variant,
      borderRadius: scope.borderRadius,
      minTileHeight: scope.minTileHeight,
      pressedColor: scope.pressedColor,
      tilePadding: scope.tilePadding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final scope = ListSectionScope.maybeOf(context);
    final open = _isOpen;
    final hasRows = widget.children.isNotEmpty;

    // While it is open the heading is not the bottom of the row, and the
    // last of the rows under it is.
    final position = scope?.position ?? ListSectionPosition.only;
    final headingPosition = open && hasRows
        ? (position.isFirst
              ? ListSectionPosition.first
              : ListSectionPosition.middle)
        : position;

    final heading = Semantics(
      expanded: open,
      child: ListTile(
        leading: widget.leading,
        title: widget.title,
        subtitle: widget.subtitle,
        value: widget.value,
        trailing: SpringBuilder(
          value: open ? 1 : 0,
          spring: motion.smooth,
          builder: (context, t, child) =>
              Transform.rotate(angle: t * math.pi, child: child),
          child: const PhosphorIcon(PhosphorIconsRegular.caretDown),
        ),
        enabled: widget.enabled,
        focusNode: widget.focusNode,
        onTap: widget.enabled ? _toggle : null,
      ),
    );

    final count = widget.children.length;
    final rows = Padding(
      padding: widget.childrenPadding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < count; i++)
            _scoped(
              scope,
              i == count - 1 && position.isLast
                  ? ListSectionPosition.last
                  : ListSectionPosition.middle,
              widget.children[i],
            ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _scoped(scope, headingPosition, heading),
        if (hasRows)
          SpringBuilder(
            value: open ? 1 : 0,
            spring: motion.smooth,
            builder: (context, t, child) {
              final shown = open || t > 0;
              if (!shown && !widget.maintainState) {
                return const SizedBox.shrink();
              }
              // The same widgets at every stage, so the rows keep their
              // state through the whole fold.
              return Visibility(
                visible: shown,
                maintainState: true,
                child: ExpandReveal(
                  factor: t,
                  travel: motion.overlayTravel,
                  child: child!,
                ),
              );
            },
            child: rows,
          ),
      ],
    );
  }
}
