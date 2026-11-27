import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:una/src/liquid_glass/liquid_glass.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/haptics.dart';
import 'package:una/src/utils/shadow.dart';
import 'package:una/src/utils/spring.dart';

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
    // The package's slider is `thumbSize + 16` tall and places its thumb
    // for that height, while its track is centred in whatever height it is
    // given: squeezed into a shorter row, the thumb sat below the track.
    // So it always has its own height, centred in the room it is given
    // (and as tall as that where nothing bounds it).
    return OverflowBox(
      fit: OverflowBoxFit.deferToChild,
      minHeight: thumbSize + 16,
      maxHeight: thumbSize + 16,
      child: LiquidGlassBridge(
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
      ),
    );
  }
}

/// The thumb of a una slider on Liquid Glass, for the sliders the
/// package's own [LiquidGlassSlider] cannot be: a range, one with its
/// value bubble always shown or with division marks.
///
/// It is drawn as the package's slider draws its thumb: a capsule 37:24
/// as wide as it is tall (the height 1.6 thumb radii) in [color] with a
/// soft shadow. Held, it swells by half again and its material fades to
/// clear glass, a lens over the track; let go, it settles back. Only the
/// picture: the slider keeps its own hit box, focus and semantics.
class LiquidGlassSliderThumb extends StatelessWidget {
  /// Creates the thumb for a slider whose thumb radius is [thumbRadius].
  const LiquidGlassSliderThumb({
    required this.thumbRadius,
    required this.color,
    required this.pressed,
    this.focusColor,
    super.key,
  });

  /// The slider's thumb radius.
  final double thumbRadius;

  /// The thumb's colour at rest.
  final Color color;

  /// Whether the thumb is held.
  final bool pressed;

  /// The colour of a focus ring around the capsule, or null for none.
  final Color? focusColor;

  @override
  Widget build(BuildContext context) {
    final height = thumbRadius * 1.6;
    final width = height * 37 / 24;
    final motion = Motion.of(context);
    return SpringBuilder(
      value: pressed ? 1 : 0,
      spring: motion.bouncy,
      builder: (context, t, _) {
        final held = t.clamp(0.0, 1.0);
        // The material is gone a little before the lens is full size.
        final material = (1 - held * 1.35).clamp(0.0, 1.0);
        final capsule = BorderRadius.circular(height / 2);
        return OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.scale(
            scale: 1 + .55 * t,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (held > .02)
                    const LiquidGlassSurface(
                      capsule: true,
                      interactive: true,
                      child: SizedBox.expand(),
                    ),
                  Opacity(
                    opacity: material,
                    child: DecoratedBox(
                      decoration: ShadowDecoration.box(
                        color: color,
                        borderRadius: capsule,
                        shadows: [
                          const BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                          if (focusColor != null)
                            BoxShadow(color: focusColor!, spreadRadius: 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final unselectedStyle = textStyle.copyWith(
      color: theme.colorScheme.mutedForeground,
    );
    final iconSize = theme.style.buttonIconSize;
    Widget control = lg.GlassSegmentedControl(
      segments: [
        for (final (index, segment) in segments.indexed)
          switch ((segment.icon, segment.label)) {
            // The package stacks an icon above its label, which does not
            // fit a control one line high: the label spilled out of the
            // bottom. Side by side is how una's segments and the package's
            // own width maths here read it, so such a segment is handed
            // over as one icon of that row, its name kept for the screen
            // reader.
            (final icon?, final label?) => lg.GlassSegment(
              icon: _IconLabel(
                icon: icon,
                label: label,
                iconSize: iconSize,
                style: index == selectedIndex ? selectedStyle : unselectedStyle,
              ),
              enabled: onSelected != null && segment.enabled,
              tooltip: segment.tooltip,
              semanticLabel: segment.semanticLabel ?? label,
            ),
            (final icon, final label) => lg.GlassSegment(
              label: label,
              // The package draws a lone icon at 20; una's segments, and
              // the width measured below, use the button's icon size.
              icon: icon == null
                  ? null
                  : IconTheme.merge(
                      data: IconThemeData(size: iconSize),
                      child: icon,
                    ),
              enabled: onSelected != null && segment.enabled,
              tooltip: segment.tooltip,
              semanticLabel: segment.semanticLabel,
            ),
          },
      ],
      selectedIndex: selectedIndex,
      onSegmentSelected: onSelected ?? (_) {},
      height: height,
      selectedTextStyle: selectedStyle,
      unselectedTextStyle: unselectedStyle,
      iconSize: iconSize,
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
          width += iconSize + (segment.label == null ? 0 : _iconLabelGap);
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

/// The space between a segment's icon and its label.
const double _iconLabelGap = 6;

/// A segment's icon and label side by side, in the label style of its
/// state: the package gives a segment with both one above the other.
class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.style,
  });

  final Widget icon;
  final String label;
  final double iconSize;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme.merge(
            data: IconThemeData(size: iconSize),
            child: icon,
          ),
          const SizedBox(width: _iconLabelGap),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: style,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
