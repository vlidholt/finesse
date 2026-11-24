import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/spring.dart';
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
/// It does acknowledge a press: the content shrinks a little while it is
/// held and springs back on release, and a tap too quick to have shown as a
/// press still gets a short pulse. The amount is the theme's
/// `Motion.pressScale`; [pressScale] changes it, and 1 switches it off. It
/// is a paint-time transform, so nothing is laid out again, and a disabled
/// region does not respond.
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
    this.pressScale,
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

  /// The scale of the content while the region is pressed.
  ///
  /// Null, the default, follows the theme's `Motion.pressScale`, the press
  /// of a control. Pass `Motion.of(context).surfacePressScale` for a large
  /// surface — a card, a row — where the same factor would move the edges
  /// much further, and 1 for no press response.
  final double? pressScale;

  /// Builds the region's content from its current interaction states.
  final PressableBuilder builder;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  /// The taps so far. A click is usually down and up within one frame, so
  /// the content is never built pressed; the count lets it pulse anyway.
  int _taps = 0;

  void _activate() {
    if (widget.onPressed == null) return;
    if (mounted) setState(() => _taps++);
    widget.onPressed!();
  }

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
    final content = PressScale(
      pressed: enabled && _pressed,
      taps: _taps,
      scale: widget.pressScale,
      child: widget.builder(context, states),
    );
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
                _activate();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: widget.behavior,
            onTap: widget.onPressed == null ? null : _activate,
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
    final theme = Theme.of(context);
    // The same widget whether or not the ring shows: returning [child] bare
    // while hidden moved it in the tree each time focus came or went, which
    // threw away its state — and with it any implicit animation in flight.
    return CustomPaint(
      foregroundPainter: visible
          ? _FocusRingPainter(
              color: theme.colorScheme.ring.withValues(
                alpha: theme.style.ringOpacity,
              ),
              width: theme.style.ringWidth,
              borderRadius: borderRadius,
              inset: inset,
            )
          : null,
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

/// A box whose fill and outline ease to new colours as a cross-fade.
///
/// It is what a control built on [Pressable] paints its hover, pressed and
/// selected fills with:
///
/// ```dart
/// Pressable(
///   onPressed: _open,
///   builder: (context, states) => AnimatedFill(
///     color: states.contains(WidgetState.hovered)
///         ? scheme.muted
///         : scheme.card,
///     borderColor: scheme.border,
///     borderRadius: theme.radii.lg,
///     child: const Text('Open'),
///   ),
/// )
/// ```
///
/// Use it rather than an `AnimatedContainer` whenever one of the colours may
/// be translucent. `Color.lerp` interpolates red, green, blue and alpha
/// separately, so halfway from an opaque white to a 4% wash of a dark colour
/// it passes through a half-opaque mid-grey — far darker than either end,
/// which reads as a flash on every hover. This widget blends the colours the
/// way two overlapping layers would ([AnimatedFill.lerp]), so what is on
/// screen moves straight from one to the other over any backdrop.
///
/// The outline is drawn inside the box and takes its width in layout, like a
/// `Container`'s border. Only the colours animate; a change of
/// [borderRadius] or [borderWidth] applies at once.
class AnimatedFill extends ImplicitlyAnimatedWidget {
  /// Creates a box that cross-fades to [color] and [borderColor].
  const AnimatedFill({
    required this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = BorderRadius.zero,
    this.child,
    super.duration = const Duration(milliseconds: 120),
    super.curve,
    super.onEnd,
    super.key,
  });

  /// The fill. Null paints none, and fades to and from it like a fully
  /// transparent version of the other colour.
  final Color? color;

  /// The colour of the outline. Null draws none and takes no space.
  final Color? borderColor;

  /// The width of the outline.
  final double borderWidth;

  /// The corners of the box.
  final BorderRadiusGeometry borderRadius;

  /// The content of the box.
  final Widget? child;

  /// Blends [a] into [b] the way a cross-fade between two layers does.
  ///
  /// Unlike [Color.lerp] this weighs each colour by its alpha, so a
  /// transparent or translucent end contributes transparency rather than its
  /// hidden red, green and blue. Composited over any backdrop, the result
  /// moves linearly from [a]'s appearance to [b]'s. A null colour is treated
  /// as transparent.
  static Color? lerp(Color? a, Color? b, double t) {
    if (a == null && b == null) return null;
    final from = a ?? b!.withValues(alpha: 0);
    final to = b ?? a!.withValues(alpha: 0);
    final alpha = (from.a + (to.a - from.a) * t).clamp(0.0, 1.0);
    if (alpha == 0) return (t < .5 ? from : to).withValues(alpha: 0);
    double channel(double x, double y) =>
        ((x * from.a + (y * to.a - x * from.a) * t) / alpha).clamp(0.0, 1.0);
    return Color.from(
      alpha: alpha,
      red: channel(from.r, to.r),
      green: channel(from.g, to.g),
      blue: channel(from.b, to.b),
      colorSpace: to.colorSpace,
    );
  }

  @override
  AnimatedWidgetBaseState<AnimatedFill> createState() => _AnimatedFillState();
}

class _AnimatedFillState extends AnimatedWidgetBaseState<AnimatedFill> {
  _FillTween? _color;
  _FillTween? _borderColor;

  // An implicit animation drops the tween of a property that becomes null
  // and jumps instead, so "no colour" is tweened as transparent.
  static const _none = Color(0x00000000);

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color =
        visitor(
              _color,
              widget.color ?? _none,
              (dynamic value) => _FillTween(begin: value as Color?),
            )
            as _FillTween?;
    _borderColor =
        visitor(
              _borderColor,
              widget.borderColor ?? _none,
              (dynamic value) => _FillTween(begin: value as Color?),
            )
            as _FillTween?;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color?.evaluate(animation);
    final border = _borderColor?.evaluate(animation);
    // The outline keeps its place while it fades out, so the content does
    // not shift by its width until the fade is over.
    final outlined =
        widget.borderWidth > 0 &&
        (widget.borderColor != null || (border != null && border.a > 0));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color == null || (widget.color == null && color.a == 0)
            ? null
            : color,
        borderRadius: widget.borderRadius,
        border: outlined && border != null
            ? Border.all(color: border, width: widget.borderWidth)
            : null,
      ),
      child: outlined
          ? Padding(
              padding: EdgeInsets.all(widget.borderWidth),
              child: widget.child,
            )
          : widget.child,
    );
  }
}

class _FillTween extends Tween<Color?> {
  _FillTween({super.begin});

  @override
  Color? lerp(double t) => AnimatedFill.lerp(begin, end, t);
}
