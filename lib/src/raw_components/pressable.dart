import 'package:flutter/widgets.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/focus_visibility.dart';
import 'package:una/src/utils/motion_color.dart';
import 'package:una/src/utils/spring.dart';

/// Builds a widget from the interaction states of a [Pressable].
typedef PressableBuilder = Widget Function(
  BuildContext context,
  Set<WidgetState> states,
);

/// A tappable, focusable, hoverable region that reports its interaction
/// state to a builder.
///
/// It is the behaviour underneath every control that is pressed — `Button`,
/// `IconButton`, `Toggle`, `Chip`, `ListTile`, the navigation bars: pointer
/// and keyboard activation, a mouse cursor, button semantics, and a set of
/// [WidgetState]s — [WidgetState.hovered], [WidgetState.pressed],
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
/// [enabled] says otherwise in either direction.
///
/// [WidgetState.focused] is reported while the focus should *show*: when
/// the region has the focus and the keyboard is what the user is steering
/// with, as CSS's `:focus-visible`. A region focused after a click — the
/// first action of a sheet a button opened, the button once the sheet has
/// closed — or from code on a touch screen reports nothing (see
/// `FocusVisibility`); [onFocusChange] hears of every change.
///
/// For a gesture this has no callback for — a double tap, a secondary tap,
/// the start of a long press — wrap the region in a `GestureDetector` or a
/// `UnaGestureDetector`.
class Pressable extends StatefulWidget {
  /// Creates a pressable region.
  const Pressable({
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.enabled,
    this.selected,
    this.toggled,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor = SystemMouseCursors.click,
    this.semanticLabel,
    this.semanticValue,
    this.excludeSemantics,
    this.semanticContainer = false,
    this.behavior = HitTestBehavior.opaque,
    this.pressScale,
    super.key,
  });

  /// Called on a tap, or when the focused region is activated with Enter or
  /// Space.
  final VoidCallback? onPressed;

  /// Called on a long press.
  final VoidCallback? onLongPress;

  /// Whether the region responds.
  ///
  /// Null, the default, is whether it has an [onPressed] or an
  /// [onLongPress]. False disables a region that has them. True with
  /// neither keeps the region in the focus order, hovered and focused like
  /// any other, while it has nothing to do — a button that is busy — and
  /// assistive technology is still told that it cannot be pressed.
  final bool? enabled;

  /// Whether the region is the selected one of a set, for a region that can
  /// be selected at all: a tab, a destination.
  ///
  /// True adds [WidgetState.selected]. Both true and false are announced to
  /// assistive technology ("selected" / "not selected"); null, the default,
  /// says the region is a plain button.
  final bool? selected;

  /// Whether the region is switched on, for a region that stays pressed: a
  /// toggle. Announced to assistive technology as "on" or "off"; null, the
  /// default, says the region is a plain button. True adds
  /// [WidgetState.selected], as [selected] does.
  final bool? toggled;

  /// The focus node to use; one is created when null.
  final FocusNode? focusNode;

  /// Whether the region takes focus when it is first built.
  final bool autofocus;

  /// Holds the region's interaction states for whoever else wants to follow
  /// them; null keeps them to the [builder].
  ///
  /// This is Flutter's own [WidgetStatesController], which changes its
  /// [WidgetStatesController.value] set in place before notifying: a
  /// listener that needs to know which state flipped keeps its own copy of
  /// the states it last saw. [WidgetState.disabled] and
  /// [WidgetState.selected] follow the widget and reach the controller a
  /// frame later, since its listeners may not be told during a build.
  final WidgetStatesController? statesController;

  /// Called when a mouse pointer enters or leaves an enabled region.
  final ValueChanged<bool>? onHover;

  /// Called when the region gains or loses the focus, whether or not the
  /// focus shows.
  final ValueChanged<bool>? onFocusChange;

  /// The cursor shown over an enabled region.
  final MouseCursor mouseCursor;

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

  /// Whether the region is a semantics node of its own.
  ///
  /// False, the default, merges its role, label and actions into the nearest
  /// container above, which is what lets a wrapper add to them — a
  /// `Semantics` with custom actions around a row, a `MergeSemantics` around
  /// a tile and its control. True keeps the region apart from whatever is
  /// beside it under that container: a button is one node, and the text next
  /// to it is not part of its name. `Button`, `IconButton` and `Toggle` pass
  /// true.
  final bool semanticContainer;

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
  /// The states of a region nobody else follows.
  WidgetStatesController? _ownController;

  WidgetStatesController get _controller =>
      widget.statesController ?? _ownController!;

  /// Whether the last hover the caller heard of was an entry, so that a
  /// pointer that came in while the region was disabled does not report
  /// leaving it.
  bool _hoverReported = false;

  /// The taps so far. A click is usually down and up within one frame, so
  /// the content is never built pressed; the count lets it pulse anyway.
  int _taps = 0;

  bool get _hasAction => widget.onPressed != null || widget.onLongPress != null;

  bool get _enabled => widget.enabled ?? _hasAction;

  bool get _selected => widget.selected ?? widget.toggled ?? false;

  @override
  void initState() {
    super.initState();
    // A click does not make the focus show; see [FocusVisibility].
    FocusVisibility.ensureInstalled();
    if (widget.statesController == null) {
      _ownController = WidgetStatesController();
    }
    _controller.addListener(_statesChanged);
    _mirror();
  }

  @override
  void didUpdateWidget(Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statesController != oldWidget.statesController) {
      (oldWidget.statesController ?? _ownController)!.removeListener(
        _statesChanged,
      );
      if (widget.statesController != null) {
        _ownController?.dispose();
        _ownController = null;
      } else {
        _ownController = WidgetStatesController();
      }
      _controller.addListener(_statesChanged);
    }
    _mirror();
  }

  @override
  void dispose() {
    _controller.removeListener(_statesChanged);
    _ownController?.dispose();
    super.dispose();
  }

  void _statesChanged() {
    if (mounted) setState(() {});
  }

  /// Tells a controller that is not ours of the states that follow the
  /// widget. After the frame: its listeners may be anywhere in the tree — a
  /// menu row's trailing icon — and telling them now, while this is being
  /// built, is "setState() called during build". The region itself reads the
  /// widget, so it is right this frame regardless.
  void _mirror() {
    final controller = widget.statesController;
    if (controller == null) return;
    final states = controller.value;
    if (states.contains(WidgetState.disabled) == !_enabled &&
        states.contains(WidgetState.selected) == _selected) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.statesController
        ?..update(WidgetState.disabled, !_enabled)
        ..update(WidgetState.selected, _selected);
    });
  }

  void _activate() {
    if (widget.onPressed == null || !_enabled) return;
    if (mounted) setState(() => _taps++);
    widget.onPressed!();
  }

  void _setPressed(bool value) {
    if (mounted) _controller.update(WidgetState.pressed, value);
  }

  void _setHovered(bool value) {
    if (!mounted) return;
    _controller.update(WidgetState.hovered, value);
    // The caller hears of a pointer over a region that responds, and of it
    // leaving if it heard of it coming.
    if (value ? _enabled : _hoverReported) {
      _hoverReported = value;
      widget.onHover?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final hasAction = _hasAction;
    final current = _controller.value;
    final pressed = enabled && current.contains(WidgetState.pressed);
    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (enabled && current.contains(WidgetState.hovered)) WidgetState.hovered,
      if (enabled && current.contains(WidgetState.focused)) WidgetState.focused,
      if (pressed) WidgetState.pressed,
      if (_selected) WidgetState.selected,
    };
    final content = PressScale(
      // A region with nothing to do is not seen to give.
      pressed: pressed && hasAction,
      taps: _taps,
      scale: widget.pressScale,
      child: widget.builder(context, states),
    );
    return Semantics(
      container: widget.semanticContainer,
      button: true,
      enabled: enabled && hasAction,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      value: widget.semanticValue,
      // Hover comes from a MouseRegion rather than the action detector's
      // highlight callback: that one only fires in the traditional highlight
      // mode, so on a touch-first platform a connected mouse got no hover
      // feedback until a key was pressed.
      child: MouseRegion(
        cursor: enabled ? widget.mouseCursor : MouseCursor.defer,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          onShowFocusHighlight: (value) {
            if (mounted) _controller.update(WidgetState.focused, value);
          },
          onFocusChange: widget.onFocusChange,
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _activate();
                return null;
              },
            ),
            // What Enter is bound to on the web, where the app's default
            // shortcuts keep `ActivateIntent` for Space.
            ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
              onInvoke: (_) {
                _activate();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: widget.behavior,
            // A region with nothing to do still follows a press, for its
            // look, but offers assistive technology nothing to activate.
            excludeFromSemantics: !hasAction,
            onTap: enabled && widget.onPressed != null ? _activate : null,
            onLongPress: enabled ? widget.onLongPress : null,
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
///
/// The fade is the theme's: `Motion.fast` on `Motion.standard`, read through
/// `Motion.of`, so it is instant under `Motion.none` and stays the short
/// plain fade reduced motion leaves. Pass [duration] or [curve] only for a
/// fill that should differ from every other control's.
class AnimatedFill extends StatelessWidget {
  /// Creates a box that cross-fades to [color] and [borderColor].
  const AnimatedFill({
    required this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = BorderRadius.zero,
    this.child,
    this.duration,
    this.curve,
    this.onEnd,
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

  /// How long a change of colour takes. Null, the default, is the theme's
  /// `Motion.fast` — zero under `Motion.none`, which changes the colours at
  /// once.
  final Duration? duration;

  /// The curve of a change of colour. Null, the default, is the theme's
  /// `Motion.standard`.
  final Curve? curve;

  /// Called each time a change of colour has finished.
  final VoidCallback? onEnd;

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
  Widget build(BuildContext context) {
    // The theme is asked only for what was not given, so a fill with both
    // needs no theme above it.
    final motion = duration == null || curve == null
        ? Motion.of(context)
        : null;
    return _AnimatedFill(
      color: color,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      duration: duration ?? motion!.fast,
      curve: curve ?? motion!.standard,
      onEnd: onEnd,
      child: child,
    );
  }
}

// The implicit animation itself. It is a widget of its own because an
// `ImplicitlyAnimatedWidget` takes its duration in its constructor, where
// there is no context to read the theme's from.
class _AnimatedFill extends ImplicitlyAnimatedWidget {
  const _AnimatedFill({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.child,
    required super.duration,
    required super.curve,
    required super.onEnd,
  });

  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;
  final Widget? child;

  @override
  AnimatedWidgetBaseState<_AnimatedFill> createState() => _AnimatedFillState();
}

class _AnimatedFillState extends AnimatedWidgetBaseState<_AnimatedFill> {
  _FillTween? _color;
  _FillTween? _borderColor;
  final _theme = ThemeChange();

  @override
  void initState() {
    super.initState();
    _theme.changedFor(context);
  }

  @override
  void didUpdateWidget(_AnimatedFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A fill that is different because the theme is follows it at once:
    // the fade is for a change of state, and an app changing theme would
    // otherwise repaint every fill in it for the length of the fade.
    if (_theme.changedFor(context)) controller.value = 1;
  }

  // An implicit animation drops the tween of a property that becomes null
  // and jumps instead, so "no colour" is tweened as transparent.
  static const _none = Color(0x00000000);

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color = visitor(
      _color,
      widget.color ?? _none,
      (dynamic value) => _FillTween(begin: value as Color?),
    ) as _FillTween?;
    _borderColor = visitor(
      _borderColor,
      widget.borderColor ?? _none,
      (dynamic value) => _FillTween(begin: value as Color?),
    ) as _FillTween?;
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
      // The padding stays in the tree without an outline, at zero: building
      // it only while there is one moved the child under a different parent
      // each time the outline appeared or finished fading out, which threw
      // its state away. See [FocusRing].
      child: Padding(
        padding: outlined
            ? EdgeInsets.all(widget.borderWidth)
            : EdgeInsets.zero,
        child: widget.child,
      ),
    );
  }
}

class _FillTween extends Tween<Color?> {
  _FillTween({super.begin});

  @override
  Color? lerp(double t) => AnimatedFill.lerp(begin, end, t);
}
