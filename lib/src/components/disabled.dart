import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:flutter/widgets.dart';

/// Switches a whole subtree off: a form section waiting on a switch, a
/// toolbar while a save is in flight.
///
/// While [enabled] is false the subtree takes no pointer events, cannot
/// take the keyboard focus (a control that had it gives it up, and Tab
/// skips the group), and is drawn at the theme's `disabledOpacity`.
/// Assistive technology reads the content and is told it cannot be acted
/// on. A single control is better served by its own `enabled`.
class Disabled extends StatelessWidget {
  /// Creates a widget that disables its child while [enabled] is false.
  const Disabled({
    super.key,
    required this.enabled,
    required this.child,
    this.showForbiddenCursor = false,
    this.disabledOpacity,
  });

  /// {@template Disabled.enabled}
  /// Whether the child responds. While it is false the child is
  /// non-interactive and drawn at the disabled opacity.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Disabled.child}
  /// The widget to be conditionally disabled.
  /// Receives the disabled behavior and styling applied by this widget.
  /// {@endtemplate}
  final Widget child;

  /// {@template Disabled.showForbiddenCursor}
  /// Whether to display a forbidden cursor when the widget is disabled and
  /// hovered. Defaults to false; when true, uses
  /// [SystemMouseCursors.forbidden].
  /// {@endtemplate}
  final bool showForbiddenCursor;

  /// {@template Disabled.disabledOpacity}
  /// The opacity applied to the child when disabled.
  /// Defaults to the theme’s [disabledOpacity] if not specified; ranges from
  /// 0.0 (transparent) to 1.0 (opaque).
  /// {@endtemplate}
  final double? disabledOpacity;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final disabled = !enabled;

    // No pointer and no keyboard: without the second, Tab still reached a
    // button in a disabled group and Enter pressed it. Both wrappers stay in
    // the tree either way, so the child keeps its state when the group is
    // switched on and off.
    Widget view = AbsorbPointer(
      absorbing: disabled,
      child: ExcludeFocus(excluding: disabled, child: child),
    );

    if (showForbiddenCursor && disabled) {
      view = MouseRegion(cursor: SystemMouseCursors.forbidden, child: view);
    }

    final effectiveDisabledOpacity = disabledOpacity ?? theme.disabledOpacity;

    return Opacity(
      opacity: disabled ? effectiveDisabledOpacity : 1,
      child: view,
    );
  }
}
