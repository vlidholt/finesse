import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
// The package's slider thumb, rebuilt (see `LiquidGlassSliderThumb`):
// `GlassEffect` is not exported, and the inner shadow is in its `src`.
// ignore: implementation_imports
import 'package:liquid_glass_widgets/src/widgets/shared/lens_inner_shadow_painter.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart' as lg;
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart' as lg;
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
    this.semanticLabel,
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

  /// The switch's name for assistive technology. Null is the package's
  /// "Switch"; an empty string names it nothing, for a switch whose label
  /// is merged into it from beside it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBridge(
      child: lg.GlassSwitch(
        semanticLabel: semanticLabel,
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

/// The thumb of a una slider on Liquid Glass, every kind of slider: one
/// value or a range, with or without its bubble and division marks.
///
/// It is the package's slider thumb: a capsule 37:24 as wide as it is
/// tall (the height 1.6 thumb radii) in [color] with a soft shadow, drawn
/// as the package's `GlassSlider` draws it. Held, it swells by half again
/// and turns into the package's refracting lens over the track; let go, it
/// settles back. Only the picture: the slider keeps its own hit
/// box, focus and semantics.
class LiquidGlassSliderThumb extends StatelessWidget {
  /// Creates the thumb for a slider whose thumb radius is [thumbRadius].
  const LiquidGlassSliderThumb({
    required this.thumbRadius,
    required this.color,
    required this.pressed,
    this.stretch = 0,
    this.focusColor,
    super.key,
  });

  /// The slider's thumb radius.
  final double thumbRadius;

  /// The thumb's colour at rest.
  final Color color;

  /// Whether the thumb is held.
  final bool pressed;

  /// How fast the held thumb is moving, 0 to 1. The lens squashes along
  /// the track by up to 30 % and stretches across it by up to 18 %, as the
  /// package's own thumb does, and settles back on a bouncy spring. Its
  /// radius is half its shorter side whatever its shape, so its ends stay
  /// round: the package's kept the resting radius, which flattened the top
  /// and bottom of a squashed lens.
  final double stretch;

  /// The colour of a focus ring around the capsule, or null for none.
  final Color? focusColor;

  @override
  Widget build(BuildContext context) {
    final height = thumbRadius * 1.6;
    final width = height * 37 / 24;
    final motion = Motion.of(context);
    return SpringBuilder(
      value: pressed ? stretch : 0,
      spring: motion.bouncy,
      builder: (context, s, _) => SpringBuilder(
        value: pressed ? 1 : 0,
        spring: motion.bouncy,
        builder: (context, t, _) => _build(width, height, t, s),
      ),
    );
  }

  Widget _build(double width, double height, double t, double s) {
    // It grows by its size, not by a transform, as the package's own
    // thumb does: the glass is laid out at the size it is drawn.
    final scale = 1 + .55 * t;
    final w = width * scale * (1 - .3 * s);
    final h = height * scale * (1 + .18 * s);
    // Half the shorter side, whatever the shape: the ends stay round.
    final radius = math.min(w, h) / 2;
    return OverflowBox(
      minWidth: 0,
      minHeight: 0,
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: SizedBox(
        width: w,
        height: h,
        child: LiquidGlassBridge(
          child: Builder(
            builder: (context) => _lens(context, w, h, radius, t),
          ),
        ),
      ),
    );
  }

  /// The package's slider thumb (`GlassSlider._buildThumbGlass`, 1.21),
  /// at the size and radius given: the material capsule over a
  /// `GlassEffect` lens that takes over as [t] rises, its shadow outside
  /// the glass and the lens's inner shadow over it.
  Widget _lens(
    BuildContext context,
    double w,
    double h,
    double radius,
    double t,
  ) {
    final transition = t.clamp(0.0, 1.0);
    final quality = lg.GlassThemeHelpers.resolveQuality(
      context,
      fallback: lg.GlassThemeHelpers.nativeStyleQuality(context),
    );
    final standard = quality == lg.GlassQuality.standard;
    final dark = lg.GlassTheme.brightnessOf(context) == Brightness.dark;
    final materialOpacity = (1 - transition * 1.35).clamp(0.0, 1.0);
    final shadowOpacity = (1 - transition) * materialOpacity;
    final theme = lg.GlassTheme.maybeOf(context)?.data;
    final style = theme?.style ?? lg.GlassStyle.ios27;
    final tint = dark
        ? const Color.from(alpha: 0.08, red: 1, green: 1, blue: 1)
        : const Color.from(alpha: 0.12, red: 0.88, green: 0.88, blue: 0.90);
    final eraBase = switch (style) {
      lg.GlassStyle.classic => lg.LiquidGlassSettings(
        glassColor: tint,
        refractiveIndex: dark ? 1.3 : 1.4,
        thickness: dark ? 13 : 17,
        lightIntensity: standard ? 0.0 : 1.8,
        blur: 0,
      ),
      lg.GlassStyle.ios26 => lg.LiquidGlassSettings.ios26Indicator.copyWith(
        refractiveIndex: 1.07,
        rimShade: 1,
        rimShadeEnds: 0.56,
        rimLight: 1,
      ),
      lg.GlassStyle.ios27 => lg.LiquidGlassSettings.ios27Indicator.copyWith(
        refractiveIndex: 1.07,
      ),
    };
    final raw =
        theme?.indicatorSettingsFor(context)?.applyTo(eraBase) ?? eraBase;
    final nativeRim = raw.rimLight > 0 || raw.rimShade > 0;
    final settings = raw.copyWith(
      blur: 0,
      frost: 0,
      glassColor: standard && raw.glassColor.a == 0 && (dark || !nativeRim)
          ? tint
          : null,
    );
    final corners = BorderRadius.circular(radius);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outside the lens's clip; the material's fade is folded into it.
        Positioned.fill(
          child: DecoratedBox(
            decoration: ShadowDecoration.box(
              borderRadius: corners,
              shadows: [
                BoxShadow(
                  color: Color.from(
                    alpha: .15 * shadowOpacity,
                    red: 0,
                    green: 0,
                    blue: 0,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                if (focusColor != null)
                  BoxShadow(color: focusColor!, spreadRadius: 3),
              ],
            ),
          ),
        ),
        lg.GlassEffect(
          shape: lg.LiquidRoundedRectangle(borderRadius: radius),
          settings: settings,
          quality: quality,
          interactionIntensity: transition,
          rimThickness: standard ? (dark ? 0.5 : 0.7) : 0.5,
          ambientRim: standard ? (dark ? 0.08 : 0.15) : 0.1,
          baseAlphaMultiplier: standard ? (dark ? 0.0 : 0.04) : 0.08,
          edgeAlphaMultiplier: standard ? (dark ? 0.15 : 0.28) : 0,
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The shell's footprint, which the shader needs.
                const Positioned.fill(
                  child: ColoredBox(color: Color(0x00000000)),
                ),
                Opacity(
                  opacity: materialOpacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 1),
                      borderRadius: corners,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (transition > .05)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: LensInnerShadowPainter(
                  borderRadius: radius,
                  opacity: transition,
                  shadowOpacity: settings.rimShade > 0
                      ? LensInnerShadowPainter.defaultShadowOpacity
                      : LensInnerShadowPainter.classicShadowOpacity,
                ),
              ),
            ),
          ),
      ],
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
