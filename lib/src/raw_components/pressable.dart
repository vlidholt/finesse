import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// Builds a widget from the interaction states of a [Pressable].
typedef PressableBuilder =
    Widget Function(BuildContext context, Set<WidgetState> states);

/// A tappable, focusable, hoverable region that reports its interaction
/// state to a builder.
///
/// It is the behaviour underneath `Chip`, `ListTile` and the navigation bars:
/// pointer and keyboard activation, a mouse cursor, button semantics, and a
/// set of [WidgetState]s — [WidgetState.hovered], [WidgetState.pressed],
/// [WidgetState.focused], [WidgetState.selected] and [WidgetState.disabled] —
/// handed to [builder] so the caller decides what each looks like. It paints
/// nothing itself.
///
/// ```dart
/// Pressable(
///   onPressed: _open,
///   builder: (context, states) => ColoredBox(
///     color: states.contains(WidgetState.hovered) ? hover : idle,
///     child: const Text('Open'),
///   ),
/// )
/// ```
///
/// With no [onPressed] and no [onLongPress] the region is disabled: it takes
/// no focus, shows the basic cursor and reports [WidgetState.disabled].
class Pressable extends StatefulWidget {
  /// Creates a pressable region.
  const Pressable({
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.selected = false,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.cursor = SystemMouseCursors.click,
    this.semanticLabel,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  /// Called on a tap, or when the focused region is activated with Enter or
  /// Space.
  final VoidCallback? onPressed;

  /// Called on a long press.
  final VoidCallback? onLongPress;

  /// Whether the region represents the selected one of a set. Adds
  /// [WidgetState.selected] and is announced to assistive technology.
  final bool selected;

  /// The focus node to use; one is created when null.
  final FocusNode? focusNode;

  /// Whether the region takes focus when it is first built.
  final bool autofocus;

  /// Whether the region can take keyboard focus at all.
  final bool canRequestFocus;

  /// The cursor shown over an enabled region.
  final MouseCursor cursor;

  /// A description for assistive technology, for a region whose content is
  /// only an icon.
  final String? semanticLabel;

  /// How the region behaves in hit testing.
  final HitTestBehavior behavior;

  /// Builds the region's content from its current interaction states.
  final PressableBuilder builder;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (enabled && _hovered) WidgetState.hovered,
      if (enabled && _focused) WidgetState.focused,
      if (enabled && _pressed) WidgetState.pressed,
      if (widget.selected) WidgetState.selected,
    };
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected ? true : null,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        descendantsAreFocusable: true,
        mouseCursor: enabled ? widget.cursor : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) {
          if (_hovered != value) setState(() => _hovered = value);
        },
        onShowFocusHighlight: (value) {
          if (_focused != value) setState(() => _focused = value);
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: widget.behavior,
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: widget.builder(context, states),
        ),
      ),
    );
  }
}

/// Paints the theme's focus ring around [child] while [visible].
///
/// The ring is drawn outside [child]'s bounds, flush against it, in the
/// theme's ring colour, width and opacity, and takes no space in layout.
class FocusRing extends StatelessWidget {
  /// Creates a focus ring around [child].
  const FocusRing({
    required this.visible,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  /// Whether the ring is painted.
  final bool visible;

  /// The corners of the widget the ring surrounds.
  final BorderRadius borderRadius;

  /// The widget the ring surrounds.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;
    final theme = Theme.of(context);
    return CustomPaint(
      foregroundPainter: _FocusRingPainter(
        color: theme.colorScheme.ring.withValues(
          alpha: theme.style.ringOpacity,
        ),
        width: theme.style.ringWidth,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({
    required this.color,
    required this.width,
    required this.borderRadius,
  });

  final Color color;
  final double width;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final inner = borderRadius.toRRect(Offset.zero & size);
    final outer = inner.inflate(width);
    canvas.drawDRRect(outer, inner, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.borderRadius != borderRadius;
}
