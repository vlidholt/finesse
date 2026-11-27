import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/src/components/control_affinity.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/disabled.dart';
import 'package:una/src/liquid_glass/controls.dart';
import 'package:una/src/liquid_glass/liquid_glass.dart';
import 'package:una/src/raw_components/focusable.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/activation_keys.dart';
import 'package:una/src/utils/border.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/extensions/text_style.dart';
import 'package:una/src/utils/haptics.dart';
import 'package:una/src/utils/motion_color.dart';
import 'package:una/src/utils/spring.dart';

/// {@template Switch}
/// A customizable switch widget, styled according to the Shadcn UI design
/// system.
///
/// Allows users to toggle between two states: on or off.
/// {@endtemplate}
class Switch extends StatefulWidget {
  /// {@macro Switch}
  const Switch({
    super.key,
    required this.value,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.thumbColor,
    this.uncheckedTrackColor,
    this.checkedTrackColor,
    this.width,
    this.height,
    this.margin,
    this.decoration,
    this.controlAffinity = ControlAffinity.leading,
    this.label,
    this.description,
    this.padding,
  });

  /// {@template Switch.value}
  /// Whether the switch is currently on or off.
  ///
  /// Represents the current state of the switch.
  /// {@endtemplate}
  final bool value;

  /// {@template Switch.enabled}
  /// Whether the switch is enabled and can be interacted with.
  ///
  /// Defaults to true. When disabled, it visually indicates it's inactive and
  /// ignores user interactions.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Switch.onChanged}
  /// Callback function invoked when the switch is toggled.
  ///
  /// Provides a boolean value indicating the new state of the switch (true for
  /// on, false for off).
  /// {@endtemplate}
  final ValueChanged<bool>? onChanged;

  /// {@template Switch.focusNode}
  /// Focus node to control the focus state of the switch.
  ///
  /// If not provided, an internal [FocusNode] is created.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Widget.autofocus}
  /// Whether this widget should be focused when first shown.
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template Widget.onFocusChange}
  /// Called when the focus state of this widget changes.
  /// {@endtemplate}
  final ValueChanged<bool>? onFocusChange;

  /// {@template Switch.thumbColor}
  /// Color of the switch's thumb (the draggable part).
  ///
  /// Defaults to the theme's background color.
  /// {@endtemplate}
  final Color? thumbColor;

  /// {@template Switch.uncheckedTrackColor}
  /// Color of the track when the switch is in the unchecked (off) state.
  ///
  /// Defaults to the theme's input color.
  /// {@endtemplate}
  final Color? uncheckedTrackColor;

  /// {@template Switch.checkedTrackColor}
  /// Color of the track when the switch is in the checked (on) state.
  ///
  /// Defaults to the theme's primary color.
  /// {@endtemplate}
  final Color? checkedTrackColor;

  /// {@template Switch.width}
  /// Width of the switch widget.
  ///
  /// Defaults to 44.
  /// {@endtemplate}
  final double? width;

  /// {@template Switch.height}
  /// Height of the switch widget.
  ///
  /// Defaults to 24.
  /// {@endtemplate}
  final double? height;

  /// {@template Switch.margin}
  /// Margin around the thumb within the track.
  ///
  /// Affects the visual spacing and thumb's draggable area. Defaults to 2.
  /// {@endtemplate}
  final double? margin;

  /// {@template Switch.decoration}
  /// Custom decoration for the switch track.
  ///
  /// Allows styling the appearance of the track, such as border or background.
  /// Uses [UnaDecoration].
  /// {@endtemplate}
  final UnaDecoration? decoration;

  /// {@template Switch.controlAffinity}
  /// Whether the switch comes before the label or after it.
  /// {@endtemplate}
  final ControlAffinity controlAffinity;

  /// {@template Switch.label}
  /// Widget to display as a label for the switch.
  ///
  /// Typically a [Text] widget describing the switch's function, on the side
  /// [controlAffinity] leaves free.
  /// {@endtemplate}
  final Widget? label;

  /// {@template Switch.description}
  /// An optional line under the label, in the muted colour.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Switch.padding}
  /// Padding between the switch itself and its label.
  ///
  /// Defaults to `EdgeInsetsDirectional.only(start: 8)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  @override
  State<Switch> createState() => _SwitchState();
}

class _SwitchState extends State<Switch> with SingleTickerProviderStateMixin {
  FocusNode? _focusNode;
  // 0 with the thumb at the unchecked end, 1 at the checked end. A spring,
  // so toggling back mid-travel turns the thumb around where it is.
  late final _position = SpringController(
    vsync: this,
    value: widget.value ? 1 : 0,
  );

  /// The thumb travels on the small-delight spring.
  MotionSpring get _spring => Motion.of(context).bouncy;

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant Switch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _position.animateTo(widget.value ? 1 : 0, spring: _spring);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      if (widget.focusNode == null) {
        _focusNode = FocusNode();
      } else {
        _focusNode?.dispose();
        _focusNode = null;
      }
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _position.dispose();
    super.dispose();
  }

  void onTap() {
    Haptics.impact(context);
    widget.onChanged!(!widget.value);
    if (!focusNode.hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);

    final direction = Directionality.of(context);
    final effectiveThumbColor =
        widget.thumbColor ??
        theme.switchTheme.thumbColor ??
        theme.colorScheme.background;
    final effectiveUncheckedTrackColor =
        widget.uncheckedTrackColor ??
        theme.switchTheme.uncheckedTrackColor ??
        theme.colorScheme.input;
    final effectiveCheckedTrackColor =
        widget.checkedTrackColor ??
        theme.switchTheme.checkedTrackColor ??
        theme.colorScheme.primary;
    final effectiveWidth = widget.width ?? theme.switchTheme.width ?? 44;
    final effectiveMargin = widget.margin ?? theme.switchTheme.margin ?? 2;
    final effectiveHeight = widget.height ?? theme.switchTheme.height ?? 24;
    final effectiveThumbSize = effectiveHeight - effectiveMargin * 2;
    final transitionStep =
        effectiveWidth - effectiveMargin * 2 - effectiveThumbSize;
    final effectiveStretch =
        theme.switchTheme.thumbStretch ??
        (Motion.of(context).reduced ? 0 : .25);

    final baseDecoration =
        (theme.switchTheme.decoration ?? const UnaDecoration()).merge(
          widget.decoration,
        );

    final effectivePadding =
        widget.padding ??
        theme.switchTheme.padding ??
        const EdgeInsetsDirectional.only(start: 8);

    final liquid = LiquidGlass.isActive(context, theme.switchTheme.liquidGlass);
    final switchWidget = liquid
        ? LiquidGlassSwitch(
            value: widget.value,
            onChanged: widget.enabled ? widget.onChanged : null,
            width: effectiveWidth,
            height: effectiveHeight,
            activeColor: effectiveCheckedTrackColor,
            inactiveColor: effectiveUncheckedTrackColor,
            thumbColor: effectiveThumbColor,
            focusNode: focusNode,
            autofocus: widget.autofocus,
          )
        : _buildSwitch(
            context,
            direction: direction,
            thumbColor: effectiveThumbColor,
            uncheckedTrackColor: effectiveUncheckedTrackColor,
            checkedTrackColor: effectiveCheckedTrackColor,
            width: effectiveWidth,
            height: effectiveHeight,
            margin: effectiveMargin,
            thumbSize: effectiveThumbSize,
            transitionStep: transitionStep,
            stretch: effectiveStretch,
            baseDecoration: baseDecoration,
          );

    return Disabled(
      showForbiddenCursor: true,
      enabled: widget.enabled,
      disabledOpacity: 1,
      child: GestureDetector(
        // The glass switch takes its own taps and drags.
        onTap: widget.onChanged == null || liquid ? null : onTap,
        child: ControlLabelRow(
          affinity: widget.controlAffinity,
          crossAxisAlignment: CrossAxisAlignment.center,
          labelPadding: effectivePadding,
          control: switchWidget,
          label: widget.label == null
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onChanged == null || !liquid
                            ? null
                            : onTap,
                        child: DefaultTextStyle(
                          style: theme.textTheme.muted.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.foreground,
                          ),
                          child: widget.label!,
                        ),
                      ),
                    ),
                    if (widget.description != null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: DefaultTextStyle(
                          style: theme.textTheme.muted.fallback(
                            color: theme.colorScheme.mutedForeground,
                          ),
                          child: widget.description!,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context, {
    required TextDirection direction,
    required Color thumbColor,
    required Color uncheckedTrackColor,
    required Color checkedTrackColor,
    required double width,
    required double height,
    required double margin,
    required double thumbSize,
    required double transitionStep,
    required double stretch,
    required UnaDecoration baseDecoration,
  }) {
    final effectiveThumbColor = thumbColor;
    final effectiveUncheckedTrackColor = uncheckedTrackColor;
    final effectiveCheckedTrackColor = checkedTrackColor;
    final effectiveWidth = width;
    final effectiveHeight = height;
    final effectiveMargin = margin;
    final effectiveThumbSize = thumbSize;
    final effectiveStretch = stretch;
    return Semantics(
      toggled: widget.value,
      child: Disabled(
        showForbiddenCursor: true,
        enabled: widget.enabled,
        child: CallbackShortcuts(
          bindings: {
            for (final trigger in activationKeys)
              trigger: () {
                if (!widget.enabled) return;
                onTap();
              },
          },
          child: Focusable(
            visibleOnly: true,
            autofocus: widget.autofocus,
            onFocusChange: widget.onFocusChange,
            focusNode: focusNode,
            builder: (context, focused, child) {
              // The track's colour follows the thumb: it blends from one
              // state's to the other's as the thumb crosses.
              return AnimatedBuilder(
                animation: _position.animation,
                builder: (context, child) => Decorator(
                  focused: focused,
                  decoration: baseDecoration.copyWith(
                    color: lerpColorThroughAlpha(
                      effectiveUncheckedTrackColor,
                      effectiveCheckedTrackColor,
                      _position.value.clamp(0.0, 1.0),
                    ),
                  ),
                  child: child,
                ),
                child: child,
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: effectiveWidth,
                height: effectiveHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(effectiveMargin),
                    child: Row(
                      textDirection: direction,
                      children: [
                        AnimatedBuilder(
                          animation: _position.animation,
                          builder: (context, child) {
                            final t = _position.value;
                            // Widest mid-travel, round again at either end:
                            // the thumb stretches as it crosses.
                            final extra =
                                effectiveThumbSize *
                                effectiveStretch *
                                math.sin(math.pi * t.clamp(0.0, 1.0));
                            // The stretch stays inside the track: the thumb
                            // grows towards where it is going.
                            final dx = (transitionStep - extra) * t;
                            return Transform.translate(
                              offset: Offset(
                                direction == TextDirection.ltr ? dx : -dx,
                                0,
                              ),
                              child: SizedBox(
                                width: effectiveThumbSize + extra,
                                height: effectiveThumbSize,
                                child: child,
                              ),
                            );
                          },
                          child: Decorator(
                            decoration: UnaDecoration(
                              color: effectiveThumbColor,
                              border: UnaBorder.all(
                                borderRadius: BorderRadius.circular(
                                  effectiveThumbSize / 2,
                                ),
                                width: 0,
                              ),
                              canMerge: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
