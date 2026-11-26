import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:una/src/liquid_glass/liquid_glass.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/haptics.dart';

/// The package's `GlassSwitch` with una's colours and size: flat at
/// rest, a lens of glass while it is pressed or dragged.
///
/// Built by `Switch` when Liquid Glass is active; not public.
class LiquidGlassSwitch extends StatelessWidget {
  /// Creates a Liquid Glass switch.
  const LiquidGlassSwitch({
    required this.value,
    required this.onChanged,
    required this.width,
    required this.height,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value; null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// The track's width.
  final double width;

  /// The track's height.
  final double height;

  /// The track's colour when on.
  final Color activeColor;

  /// The track's colour when off.
  final Color inactiveColor;

  /// The thumb's colour.
  final Color thumbColor;

  /// The focus node of the switch.
  final FocusNode? focusNode;

  /// Whether the switch takes the focus when it is first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBridge(
      child: lg.GlassSwitch(
        value: value,
        onChanged: onChanged,
        width: width,
        height: height,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        thumbColor: thumbColor,
        useOwnLayer: true,
        // Through una's rule: a phone only, the theme's switch, and
        // silent in tests.
        enableHaptics: Haptics.enabledOf(context),
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}

/// The package's `GlassSlider` with una's colours and size: its thumb
/// turns into a lens of glass while it is dragged.
///
/// Built by `Slider` when Liquid Glass is active; not public.
class LiquidGlassSlider extends StatelessWidget {
  /// Creates a Liquid Glass slider.
  const LiquidGlassSlider({
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.trackHeight,
    required this.thumbSize,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    this.divisions,
    this.onChangeStart,
    this.onChangeEnd,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The value.
  final double value;

  /// Called while the value changes; null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called when a drag starts.
  final ValueChanged<double>? onChangeStart;

  /// Called when a drag ends.
  final ValueChanged<double>? onChangeEnd;

  /// The smallest value.
  final double min;

  /// The largest value.
  final double max;

  /// The number of discrete steps, or null for a continuous slider.
  final int? divisions;

  /// The height of the track.
  final double trackHeight;

  /// The diameter of the thumb at rest.
  final double thumbSize;

  /// The colour of the track up to the thumb.
  final Color activeColor;

  /// The colour of the rest of the track.
  final Color inactiveColor;

  /// The thumb's colour.
  final Color thumbColor;

  /// The focus node of the slider.
  final FocusNode? focusNode;

  /// Whether the slider takes the focus when it is first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBridge(
      child: lg.GlassSlider(
        value: value,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        divisions: divisions,
        trackHeight: trackHeight,
        thumbRadius: thumbSize / 2,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        thumbColor: thumbColor,
        useOwnLayer: true,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}

/// One segment of a [LiquidGlassSegmentedControl].
@immutable
class LiquidGlassSegment {
  /// Creates a segment with a [label], an [icon] or both.
  const LiquidGlassSegment({
    this.label,
    this.icon,
    this.enabled = true,
    this.tooltip,
    this.semanticLabel,
  });

  /// The text of the segment.
  final String? label;

  /// The icon of the segment.
  final Widget? icon;

  /// Whether the segment can be chosen.
  final bool enabled;

  /// A tooltip for the segment.
  final String? tooltip;

  /// What a screen reader says for the segment.
  final String? semanticLabel;
}

/// The package's `GlassSegmentedControl` in una's type and size: the
/// selection is a lens of glass that slides and stretches between
/// segments.
///
/// Built by `SegmentedControl` when Liquid Glass is active; not public.
class LiquidGlassSegmentedControl extends StatelessWidget {
  /// Creates a Liquid Glass segmented control.
  const LiquidGlassSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
    required this.height,
    this.expand = false,
    super.key,
  });

  /// The segments.
  final List<LiquidGlassSegment> segments;

  /// The index of the selected segment.
  final int selectedIndex;

  /// Called with the index of the segment chosen; null disables the
  /// control.
  final ValueChanged<int>? onSelected;

  /// The height of the control.
  final double height;

  /// Whether the control fills the width it is given rather than fitting
  /// its segments.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSelected = this.onSelected;
    final textStyle = theme.textTheme.small.copyWith(
      color: theme.colorScheme.foreground,
    );
    final selectedStyle = textStyle.copyWith(fontWeight: FontWeight.w600);
    Widget control = lg.GlassSegmentedControl(
      segments: [
        for (final segment in segments)
          lg.GlassSegment(
            label: segment.label,
            icon: segment.icon,
            enabled: onSelected != null && segment.enabled,
            tooltip: segment.tooltip,
            semanticLabel: segment.semanticLabel,
          ),
      ],
      selectedIndex: selectedIndex,
      onSegmentSelected: onSelected ?? (_) {},
      height: height,
      selectedTextStyle: selectedStyle,
      unselectedTextStyle: textStyle.copyWith(
        color: theme.colorScheme.mutedForeground,
      ),
      iconSize: theme.style.buttonIconSize,
      useOwnLayer: true,
    );
    if (!expand) {
      // The package's control fills the width it is given and has no
      // intrinsic width of its own that counts its label padding, so a
      // control that fits its segments is measured here: the widest label
      // (segments are equal), in the selected weight, padded as the package
      // pads it.
      final scaler = MediaQuery.textScalerOf(context);
      var widest = 0.0;
      for (final segment in segments) {
        var width = 0.0;
        if (segment.label case final label?) {
          final painter = TextPainter(
            text: TextSpan(text: label, style: selectedStyle),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          width += painter.width;
          painter.dispose();
        }
        if (segment.icon != null) {
          width += theme.style.buttonIconSize + (segment.label == null ? 0 : 6);
        }
        if (width > widest) widest = width;
      }
      // 16 a side of each label, and the track's 2 a side.
      control = SizedBox(
        width: segments.length * (widest + 32) + 4,
        child: control,
      );
    }
    return LiquidGlassBridge(child: control);
  }
}
