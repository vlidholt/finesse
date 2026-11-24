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
    this.selected,
    this.focusNode,
    this.autofocus = false,
    this.cursor = SystemMouseCursors.click,
    this.semanticLabel,
    this.semanticValue,
    this.excludeSemantics,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  /// Called on a tap, or when the focused region is activated with Enter or
  /// Space.
  final VoidCallback? onPressed;

  /// Called on a long press.
  final VoidCallback? onLongPress;

  /// Whether the region is the selected one of a set, for a region that can
  /// be selected at all: a tab, a destination, a toggle.
  ///
  /// True adds [WidgetState.selected]. Both true and false are announced to
  /// assistive technology ("selected" / "not selected"); null, the default,
  /// says the region is a plain button.
  final bool? selected;

  /// The focus node to use; one is created when null.
  final FocusNode? focusNode;

  /// Whether the region takes focus when it is first built.
  final bool autofocus;

  /// The cursor shown over an enabled region.
  final MouseCursor cursor;

  /// What assistive technology reads for the region, in place of its
  /// content. Needed when the content is only an icon.
  final String? semanticLabel;

  /// A value read after the label, such as an unread count.
  final String? semanticValue;

  /// Whether the content's own semantics are dropped in favour of
  /// [semanticLabel]. Defaults to true when there is a label — an icon and
  /// its label would otherwise both be read — and false without one. Set it
  /// to false for a labelled region that contains controls of its own.
  final bool? excludeSemantics;

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
    final selected = widget.selected ?? false;
    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (enabled && _hovered) WidgetState.hovered,
      if (enabled && _focused) WidgetState.focused,
      if (enabled && _pressed) WidgetState.pressed,
      if (selected) WidgetState.selected,
    };
    final content = widget.builder(context, states);
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      value: widget.semanticValue,
      // Hover comes from a MouseRegion rather than the action detector's
      // highlight callback: that one only fires in the traditional highlight
      // mode, so on a touch-first platform a connected mouse got no hover
      // feedback until a key was pressed.
      child: MouseRegion(
        cursor: enabled ? widget.cursor : MouseCursor.defer,
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered && mounted) setState(() => _hovered = false);
        },
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
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
            // A label stands in for the content; reading both says it
            // twice. Only the content is excluded: the tap and focus
            // actions of the detectors above have to stay on the node, or
            // assistive technology could read the region but not activate
            // it.
            child: (widget.excludeSemantics ?? widget.semanticLabel != null)
                ? ExcludeSemantics(child: content)
                : content,
          ),
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
    this.inset = false,
    super.key,
  });

  /// Whether the ring is painted.
  final bool visible;

  /// The corners of the widget the ring surrounds.
  final BorderRadius borderRadius;

  /// Whether the ring is painted just inside [child]'s bounds instead of
  /// outside them. For a child whose surroundings are clipped — a destination
  /// in a bar that clips for its backdrop blur — where an outside ring would
  /// be cut off.
  final bool inset;

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
        inset: inset,
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
    required this.inset,
  });

  final Color color;
  final double width;
  final BorderRadius borderRadius;
  final bool inset;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = borderRadius.toRRect(Offset.zero & size);
    final outer = inset ? bounds : bounds.inflate(width);
    final inner = inset ? bounds.deflate(width) : bounds;
    canvas.drawDRRect(outer, inner, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.inset != inset ||
      oldDelegate.borderRadius != borderRadius;
}
