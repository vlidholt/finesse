import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

// On a device with no hover, a press stands in for it: a finger that comes
// down on the detector hovers it until it lifts, gives up or taps elsewhere.
// While a mouse pointer is inside, the hover is the pointer's.
enum _Gesture {
  tapDown,
  tapUp,
  tapCancel,
  tapOutside,
  longPressDown,
  longPressStart,
  longPressUp,
  longPressEnd,
  longPressCancel,
  doubleTapDown,
  doubleTapCancel,
}

const _hoverOn = {
  _Gesture.tapDown,
  _Gesture.longPressDown,
  _Gesture.longPressStart,
};

const _hoverOff = {
  _Gesture.tapUp,
  _Gesture.tapOutside,
  _Gesture.tapCancel,
  _Gesture.longPressUp,
  _Gesture.longPressEnd,
  _Gesture.longPressCancel,
};

/// A [GestureDetector] for the gestures a control has no callback for, which
/// can also stand in for hover where there is no pointer.
///
/// The controls of this package are built on `Pressable`, which answers a
/// tap, a long press and the keyboard and nothing else. For anything rarer —
/// a double tap, a secondary tap, the moment a press starts or is given up,
/// a pan — wrap the control in one of these:
///
/// ```dart
/// FinesseGestureDetector(
///   onDoubleTap: _zoom,
///   onSecondaryTapDown: (details) => _showMenuAt(details.globalPosition),
///   child: Button.outline(onPressed: _open, child: const Text('Photo')),
/// )
/// ```
///
/// The control inside keeps its own tap. This detector always has a tap
/// recogniser of its own, whatever callbacks it is given — it follows a
/// press for [onHover] — so there are always two beside each other: the
/// control wins a tap, and this one's [onTapDown] is only heard once a
/// press has lasted a tenth of a second. Use a `Listener` to hear every
/// pointer that comes down.
///
/// [onHover] reports the mouse's hover and, on a device that has none, a
/// press: a finger that comes down hovers the detector until it lifts.
class FinesseGestureDetector extends StatefulWidget {
  /// Creates a gesture detector that also tracks the hover state.
  const FinesseGestureDetector({
    super.key,
    required this.child,
    this.mouseCursor = MouseCursor.defer,
    this.behavior,
    this.onHover,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.supportedDevices,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.forceStartPressure = 0.4,
    this.forcePeakPressure = 0.85,
    this.excludeFromSemantics = false,
    this.groupId,
    this.onTapOutside,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  /// Called with the new hover state each time it changes.
  ///
  /// The hover state comes from the mouse when there is one; without one a
  /// press stands in for it, from the moment a pointer comes down until it
  /// lifts, gives up or taps elsewhere.
  final ValueChanged<bool>? onHover;

  /// The mouse cursor shown over the widget. Defaults to [MouseCursor.defer].
  final MouseCursor mouseCursor;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Called when a tap with the primary button completes.
  final VoidCallback? onTap;

  /// Called when the user taps outside the widget.
  final VoidCallback? onTapOutside;

  /// Called when a pointer touches down for a primary tap.
  final ValueChanged<TapDownDetails>? onTapDown;

  /// Called when a pointer lifts up after a primary tap.
  final ValueChanged<TapUpDetails>? onTapUp;

  /// Called when a primary tap does not complete.
  final VoidCallback? onTapCancel;

  /// Called when a tap with the secondary button completes.
  final VoidCallback? onSecondaryTap;

  /// Called when a pointer touches down for a secondary tap.
  final ValueChanged<TapDownDetails>? onSecondaryTapDown;

  /// Called when a pointer lifts up after a secondary tap.
  final ValueChanged<TapUpDetails>? onSecondaryTapUp;

  /// Called when a secondary tap does not complete.
  final VoidCallback? onSecondaryTapCancel;

  /// Called when a long press is recognized.
  final VoidCallback? onLongPress;

  /// Called when a long press starts, with the pointer position.
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  /// Called when a long press does not complete.
  final VoidCallback? onLongPressCancel;

  /// Called when the pointer lifts up after a long press.
  final VoidCallback? onLongPressUp;

  /// Called when the pointer moves during a long press.
  final ValueChanged<LongPressMoveUpdateDetails>? onLongPressMoveUpdate;

  /// Called when a pointer touches down that can become a long press.
  final ValueChanged<LongPressDownDetails>? onLongPressDown;

  /// Called when a long press ends, with the pointer position and velocity.
  final ValueChanged<LongPressEndDetails>? onLongPressEnd;

  /// Called when a double tap completes.
  final VoidCallback? onDoubleTap;

  /// Called when a pointer touches down for the second tap of a double tap.
  final ValueChanged<TapDownDetails>? onDoubleTapDown;

  /// Called when a double tap does not complete.
  final VoidCallback? onDoubleTapCancel;

  /// How long a press must last to count as a long press. Defaults to
  /// [kLongPressTimeout].
  final Duration? longPressDuration;

  /// The kind of devices that are allowed to be recognized.
  ///
  /// If set to null, events from all device types will be recognized. Defaults
  /// to null.
  final Set<PointerDeviceKind>? supportedDevices;

  /// The pointer is in contact with the screen and has pressed with sufficient
  /// force to initiate a force press. The amount of force is at least
  /// [ForcePressGestureRecognizer.startPressure].
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressStartCallback? onForcePressStart;

  /// The pointer is in contact with the screen and has pressed with the maximum
  /// force. The amount of force is at least
  /// [ForcePressGestureRecognizer.peakPressure].
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressPeakCallback? onForcePressPeak;

  /// A pointer is in contact with the screen, has previously passed the
  /// [ForcePressGestureRecognizer.startPressure] and is either moving on the
  /// plane of the screen, pressing the screen with varying forces or both
  /// simultaneously.
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressUpdateCallback? onForcePressUpdate;

  /// The pointer tracked by [onForcePressStart] is no longer in contact with
  /// the screen.
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressEndCallback? onForcePressEnd;

  /// The pressure at which a force press starts. Defaults to 0.4.
  ///
  /// See [ForcePressGestureRecognizer.startPressure].
  final double forceStartPressure;

  /// The pressure at which a force press reaches its peak. Defaults to 0.85.
  ///
  /// See [ForcePressGestureRecognizer.peakPressure].
  final double forcePeakPressure;

  /// How the detector behaves during hit testing.
  ///
  /// When null, uses the default of [RawGestureDetector].
  final HitTestBehavior? behavior;

  /// Whether to exclude these gestures from the semantics tree. For
  /// example, the long-press gesture for showing a tooltip is
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  /// A pointer has contacted the screen with a primary button and might begin
  /// to move.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragDownCallback? onPanDown;

  /// A pointer has contacted the screen with a primary button and has begun to
  /// move.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragStartCallback? onPanStart;

  /// A pointer that is in contact with the screen with a primary button and
  /// moving has moved again.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragUpdateCallback? onPanUpdate;

  /// A pointer that was previously in contact with the screen with a primary
  /// button and moving is no longer in contact with the screen and was moving
  /// at a specific velocity when it stopped contacting the screen.
  final GestureDragEndCallback? onPanEnd;

  /// The pointer that previously triggered [onPanDown] did not complete.
  final GestureDragCancelCallback? onPanCancel;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], gesture drag behavior will
  /// begin at the position where the drag gesture won the arena. If set to
  /// [DragStartBehavior.down] it will begin at the position where a down event
  /// is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// Only the [DragGestureRecognizer.onStart] callbacks for the
  /// [VerticalDragGestureRecognizer], [HorizontalDragGestureRecognizer] and
  /// [PanGestureRecognizer] are affected by this setting.
  final DragStartBehavior dragStartBehavior;

  /// {@macro MouseArea.groupId}
  final Object? groupId;

  @override
  State<FinesseGestureDetector> createState() => _GestureDetectorState();
}

class _GestureDetectorState extends State<FinesseGestureDetector> {
  bool hovered = false;

  /// Whether a mouse pointer is currently inside this detector.
  ///
  /// A press stands in for hover only on a device that has none. With a
  /// mouse inside, the press would fight the `MouseRegion`: a click's tap-up
  /// would clear the highlight although the cursor has not moved.
  bool mouseInside = false;

  @override
  Widget build(BuildContext context) {
    final configuration = ScrollConfiguration.of(context);

    final gestures = <Type, GestureRecognizerFactory>{};
    final gestureSettings = MediaQuery.maybeGestureSettingsOf(context);

    void setHover(_Gesture gesture) {
      // A real hover is already being tracked by the MouseRegion below.
      if (mouseInside) return;
      final on = _hoverOn.contains(gesture);
      if (!on && !_hoverOff.contains(gesture)) return;
      if (on == hovered) return;
      hovered = on;
      widget.onHover?.call(on);
    }

    void effectiveOnTapDown(TapDownDetails d) {
      setHover(_Gesture.tapDown);
      widget.onTapDown?.call(d);
    }

    void effectiveOnTap() {
      widget.onTap?.call();
    }

    void effectiveOnTapOutside(PointerDownEvent event) {
      setHover(_Gesture.tapOutside);
      widget.onTapOutside?.call();
    }

    void effectiveOnSecondaryTapDown(TapDownDetails d) {
      widget.onSecondaryTapDown?.call(d);
    }

    void effectiveOnSecondaryTapUp(TapUpDetails d) {
      widget.onSecondaryTapUp?.call(d);
    }

    void effectiveOnSecondaryTapCancel() {
      widget.onSecondaryTapCancel?.call();
    }

    void effectiveOnSecondaryTap() {
      widget.onSecondaryTap?.call();
    }

    void effectiveOnTapUp(TapUpDetails d) {
      setHover(_Gesture.tapUp);
      widget.onTapUp?.call(d);
    }

    void effectiveOnTapCancel() {
      setHover(_Gesture.tapCancel);
      widget.onTapCancel?.call();
    }

    void effectiveOnDoubleTapDown(TapDownDetails d) {
      setHover(_Gesture.doubleTapDown);
      widget.onDoubleTapDown?.call(d);
    }

    void effectiveOnDoubleTapCancel() {
      setHover(_Gesture.doubleTapCancel);
      widget.onDoubleTapCancel?.call();
    }

    void effectiveOnLongPressStart(LongPressStartDetails d) {
      setHover(_Gesture.longPressStart);
      widget.onLongPressStart?.call(d);
    }

    void effectiveOnLongPressCancel() {
      setHover(_Gesture.longPressCancel);
      widget.onLongPressCancel?.call();
    }

    void effectiveOnLongPressUp() {
      setHover(_Gesture.longPressUp);
      widget.onLongPressUp?.call();
    }

    void effectiveOnLongPressDown(LongPressDownDetails d) {
      setHover(_Gesture.longPressDown);
      widget.onLongPressDown?.call(d);
    }

    void effectiveOnLongPressEnd(LongPressEndDetails d) {
      setHover(_Gesture.longPressEnd);
      widget.onLongPressEnd?.call(d);
    }

    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(
            debugOwner: this,
            supportedDevices: widget.supportedDevices,
          ),
          (TapGestureRecognizer instance) {
            instance
              ..onTapDown = effectiveOnTapDown
              ..onTapUp = effectiveOnTapUp
              ..onTap = effectiveOnTap
              ..onTapCancel = effectiveOnTapCancel
              ..onSecondaryTapDown = effectiveOnSecondaryTapDown
              ..onSecondaryTapUp = effectiveOnSecondaryTapUp
              ..onSecondaryTap = effectiveOnSecondaryTap
              ..onSecondaryTapCancel = effectiveOnSecondaryTapCancel
              ..gestureSettings = gestureSettings
              ..supportedDevices = widget.supportedDevices;
          },
        );

    if (widget.onDoubleTap != null ||
        widget.onDoubleTapDown != null ||
        widget.onDoubleTapCancel != null) {
      gestures[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
            () => DoubleTapGestureRecognizer(
              debugOwner: this,
              supportedDevices: widget.supportedDevices,
            ),
            (DoubleTapGestureRecognizer instance) {
              instance
                ..onDoubleTapDown = effectiveOnDoubleTapDown
                ..onDoubleTap = widget.onDoubleTap
                ..onDoubleTapCancel = effectiveOnDoubleTapCancel
                ..gestureSettings = gestureSettings
                ..supportedDevices = widget.supportedDevices;
            },
          );
    }

    if (widget.onLongPressDown != null ||
        widget.onLongPressCancel != null ||
        widget.onLongPress != null ||
        widget.onLongPressStart != null ||
        widget.onLongPressMoveUpdate != null ||
        widget.onLongPressUp != null ||
        widget.onLongPressEnd != null) {
      gestures[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(
              duration: widget.longPressDuration ?? kLongPressTimeout,
              debugOwner: this,
              supportedDevices: widget.supportedDevices,
            ),
            (LongPressGestureRecognizer instance) {
              instance
                ..onLongPressDown = effectiveOnLongPressDown
                ..onLongPressCancel = effectiveOnLongPressCancel
                ..onLongPress = widget.onLongPress
                ..onLongPressStart = effectiveOnLongPressStart
                ..onLongPressMoveUpdate = widget.onLongPressMoveUpdate
                ..onLongPressUp = effectiveOnLongPressUp
                ..onLongPressEnd = effectiveOnLongPressEnd
                ..gestureSettings = gestureSettings
                ..supportedDevices = widget.supportedDevices;
            },
          );
    }

    if (widget.onForcePressStart != null ||
        widget.onForcePressPeak != null ||
        widget.onForcePressUpdate != null ||
        widget.onForcePressEnd != null) {
      gestures[ForcePressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ForcePressGestureRecognizer>(
            () => ForcePressGestureRecognizer(
              debugOwner: this,
              supportedDevices: widget.supportedDevices,
              startPressure: widget.forceStartPressure,
              peakPressure: widget.forcePeakPressure,
            ),
            (ForcePressGestureRecognizer instance) {
              instance
                ..onStart = widget.onForcePressStart
                ..onPeak = widget.onForcePressPeak
                ..onUpdate = widget.onForcePressUpdate
                ..onEnd = widget.onForcePressEnd
                ..gestureSettings = gestureSettings
                ..supportedDevices = widget.supportedDevices;
            },
          );
    }

    if (widget.onPanDown != null ||
        widget.onPanStart != null ||
        widget.onPanUpdate != null ||
        widget.onPanEnd != null ||
        widget.onPanCancel != null) {
      gestures[PanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
            () => PanGestureRecognizer(
              debugOwner: this,
              supportedDevices: widget.supportedDevices,
            ),
            (PanGestureRecognizer instance) {
              instance
                ..onDown = widget.onPanDown
                ..onStart = widget.onPanStart
                ..onUpdate = widget.onPanUpdate
                ..onEnd = widget.onPanEnd
                ..onCancel = widget.onPanCancel
                ..dragStartBehavior = widget.dragStartBehavior
                ..multitouchDragStrategy = configuration
                    .getMultitouchDragStrategy(context)
                ..gestureSettings = gestureSettings
                ..supportedDevices = widget.supportedDevices;
            },
          );
    }

    return TapRegion(
      onTapOutside: effectiveOnTapOutside,
      groupId: widget.groupId,
      child: MouseRegion(
        cursor: widget.mouseCursor,
        onEnter: (_) {
          mouseInside = true;
          hovered = true;
          widget.onHover?.call(true);
        },
        onExit: (_) {
          mouseInside = false;
          hovered = false;
          widget.onHover?.call(false);
        },
        child: RawGestureDetector(
          gestures: gestures,
          behavior: widget.behavior,
          excludeFromSemantics: widget.excludeFromSemantics,
          child: widget.child,
        ),
      ),
    );
  }
}
