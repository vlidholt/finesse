import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/icons/phosphor_icons.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/spring.dart';
import 'package:una/src/utils/text_scaled_height.dart';

/// How a [Chip] is outlined.
enum ChipVariant {
  /// A translucent fill with a solid hairline. The default.
  outline,

  /// A muted fill with a hairline, for read-only tags such as a skill.
  soft,

  /// No fill and a dashed hairline, for something absent or suggested.
  dashed,
}

/// A compact pill for a filter, a choice or a tag.
///
/// ```dart
/// Chip(
///   label: const Text('Remote'),
///   leading: const PhosphorIcon(PhosphorIconsRegular.globe),
///   selected: remoteOnly,
///   onSelected: (value) => setState(() => remoteOnly = value),
/// )
/// ```
///
/// A chip with [onSelected] toggles; one with [onPressed] is a button; one
/// with neither is a static tag. A selected chip takes the theme's accent
/// fill, accent text and accent outline. A chip that can be tapped follows
/// the theme's form factor — 32 logical pixels tall on a desktop, 36 on a
/// phone — while a static tag keeps the desktop height everywhere: it is not
/// a touch target.
///
/// With [onDeleted] the chip ends in a small cross that removes it: a
/// target and a button of its own, so the chip can still be tapped for
/// something else. Backspace and Delete on the focused chip remove it too.
/// With [showCheckmark] a selected chip grows a check before its label.
class Chip extends StatelessWidget {
  /// Creates a chip.
  const Chip({
    required this.label,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.deleteIcon,
    this.deleteSemanticLabel,
    this.showCheckmark,
    this.enabled = true,
    this.variant = ChipVariant.outline,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  /// The chip's label, usually a [Text].
  final Widget label;

  /// A widget before the label, usually an [Icon].
  final Widget? leading;

  /// A widget after the label, usually an [Icon].
  final Widget? trailing;

  /// Whether the chip is selected.
  final bool selected;

  /// Called with the opposite of [selected] when the chip is tapped.
  final ValueChanged<bool>? onSelected;

  /// Called when the chip is tapped. Ignored when [onSelected] is given.
  final VoidCallback? onPressed;

  /// Called when the chip's cross is tapped, or Backspace or Delete is
  /// pressed on the focused chip. Null leaves the cross out.
  final VoidCallback? onDeleted;

  /// The icon of the delete button. Defaults to a cross.
  final Widget? deleteIcon;

  /// What assistive technology calls the delete button. Defaults to the
  /// localized "Remove [semanticLabel]", or "Remove" for a chip with no
  /// [semanticLabel].
  final String? deleteSemanticLabel;

  /// Whether a selected chip shows a check before its label. Defaults to
  /// the theme's, which is false.
  final bool? showCheckmark;

  /// Whether the chip reacts to input. A disabled chip keeps the size of
  /// one that can be tapped, dimmed; a chip with no callback at all is a
  /// tag and is not dimmed.
  final bool enabled;

  /// How the chip is outlined.
  final ChipVariant variant;

  /// The chip's height. Defaults to the theme's.
  final double? height;

  /// Padding around the content. Defaults to the theme's.
  final EdgeInsetsGeometry? padding;

  /// The fill of the unselected chip.
  final Color? backgroundColor;

  /// The colour of the unselected chip's content.
  final Color? foregroundColor;

  /// The outline of the unselected chip.
  final Color? borderColor;

  /// The focus node to use.
  final FocusNode? focusNode;

  /// A description for assistive technology.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chip = theme.chipTheme;
    final scheme = theme.colorScheme;
    final radius = chip.borderRadius ?? theme.radii.full;
    // What a tap would do, were the chip enabled.
    final action = onSelected != null
        ? () => onSelected!(!selected)
        : onPressed;
    final onTap = enabled ? action : null;
    // A tag is not a touch target, so it does not grow on a phone.
    final effectiveHeight =
        height ??
        (action == null
            ? theme.variant.baseStyle.chipHeight * theme.spacing.step / 4
            : chip.height ?? 32);

    Widget buildChip(BuildContext context, Set<WidgetState> states) {
      final hovered = states.contains(WidgetState.hovered);
      final Color fill;
      final Color foreground;
      final Color outline;
      if (selected) {
        fill = chip.selectedBackgroundColor ?? scheme.accent;
        foreground = chip.selectedForegroundColor ?? scheme.accentForeground;
        outline = chip.selectedBorderColor ?? scheme.accentBorder;
      } else {
        foreground =
            foregroundColor ?? chip.foregroundColor ?? scheme.foregroundSubtle;
        switch (variant) {
          case ChipVariant.outline:
            fill = hovered
                ? chip.hoverBackgroundColor ?? scheme.muted
                : backgroundColor ?? chip.backgroundColor ?? scheme.card;
            outline = borderColor ?? chip.borderColor ?? scheme.border;
          case ChipVariant.soft:
            fill = hovered ? scheme.secondary : backgroundColor ?? scheme.muted;
            outline = borderColor ?? scheme.border;
          case ChipVariant.dashed:
            fill = hovered
                ? chip.hoverBackgroundColor ?? scheme.muted
                : backgroundColor ?? const Color(0x00000000);
            outline = borderColor ?? scheme.borderStrong;
        }
      }
      final borderWidth = chip.borderWidth ?? 1;
      final dashed = variant == ChipVariant.dashed && !selected;
      final textStyle = (chip.textStyle ?? theme.textTheme.small).copyWith(
        color: foreground,
      );

      final gap = chip.gap ?? 6;
      final iconSize = chip.iconSize ?? 16;
      final checkmark = showCheckmark ?? chip.showCheckmark ?? false;
      var contentPadding =
          (padding ??
                  chip.padding ??
                  const EdgeInsets.symmetric(horizontal: 12))
              .resolve(Directionality.of(context));
      // The room between the cross's target and the chip's end, which the
      // target takes over: it reaches to the chip's edge.
      var deleteEnd = 0.0;
      if (onDeleted != null && enabled) {
        // The cross brings its own room: it sits closer to the end than a
        // label would.
        final ltr = Directionality.of(context) == TextDirection.ltr;
        deleteEnd = (contentPadding.horizontal / 2 - _deleteInset).clamp(
          0.0,
          double.infinity,
        );
        contentPadding = contentPadding.copyWith(
          left: ltr ? null : 0,
          right: ltr ? 0 : null,
        );
      }
      Widget content = Padding(
        padding: contentPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checkmark)
              _ChipCheck(visible: selected, size: iconSize, gap: gap),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: gap,
                children: [
                  ?leading,
                  Flexible(child: label),
                  ?trailing,
                ],
              ),
            ),
            if (onDeleted != null && enabled)
              _ChipDelete(
                onDeleted: onDeleted!,
                icon: deleteIcon,
                semanticLabel: deleteSemanticLabel,
                chipLabel: semanticLabel,
                // Inside the chip's own vertical padding, if it has any.
                height: math.max(0, effectiveHeight - contentPadding.vertical),
                end: deleteEnd,
                size: iconSize,
                color: foreground,
                // The chip is the Tab stop when it can take the focus;
                // the keyboard removes it with Backspace or Delete.
                focusable: onTap == null,
              ),
          ],
        ),
      );
      content = DefaultTextStyle.merge(
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        child: IconTheme.merge(
          data: IconThemeData(size: chip.iconSize ?? 16, color: foreground),
          child: content,
        ),
      );

      // The height sits outside the animated box: only colours ease, so a
      // change of form factor does not make every chip grow for 120 ms. The
      // colours cross-fade rather than `Color.lerp`: the glass fill and the
      // hover wash differ in alpha, and lerping them channel by channel
      // dipped through a dark grey on every hover.
      Widget box = AnimatedFill(
        color: fill,
        borderColor: dashed ? null : outline,
        borderWidth: borderWidth,
        borderRadius: radius,
        child: content,
      );
      if (dashed) {
        box = CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: outline,
            width: borderWidth,
            radius: radius,
          ),
          child: box,
        );
      }
      // A floor rather than a fixed height once text is scaled up, so the
      // label is never cut off; at a scale of 1 the two are the same.
      box = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: effectiveHeight,
          maxHeight: textScaledMaxHeight(context, effectiveHeight),
        ),
        child: box,
      );
      return FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: radius,
        child: box,
      );
    }

    // A chip with neither callback is a tag, not a control: wrapping it in a
    // `Pressable` would announce every skill or label as a disabled button.
    if (action == null) {
      final tag = buildChip(context, const <WidgetState>{});
      if (semanticLabel == null && !selected) return tag;
      return Semantics(
        label: semanticLabel,
        selected: selected ? true : null,
        child: tag,
      );
    }

    final chipButton = Pressable(
      onPressed: onTap,
      // Only a chip that toggles announces "selected" / "not selected".
      selected: onSelected != null || selected ? selected : null,
      focusNode: focusNode,
      semanticLabel: semanticLabel,
      builder: buildChip,
    );
    if (!enabled) {
      // Still a button to assistive technology, one that is disabled.
      return Opacity(opacity: theme.disabledOpacity, child: chipButton);
    }
    if (onDeleted == null) return chipButton;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key != LogicalKeyboardKey.backspace &&
            key != LogicalKeyboardKey.delete) {
          return KeyEventResult.ignored;
        }
        onDeleted!();
        return KeyEventResult.handled;
      },
      child: chipButton,
    );
  }

  /// How far inside the chip's end the delete button's target begins.
  static const _deleteInset = 8.0;
}

/// The check a selected chip shows when asked to: it pops in while the
/// chip opens up to make room for it.
class _ChipCheck extends StatelessWidget {
  const _ChipCheck({
    required this.visible,
    required this.size,
    required this.gap,
  });

  final bool visible;
  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    return SpringBuilder(
      value: visible ? 1 : 0,
      spring: motion.snappy,
      builder: (context, t, child) {
        final shown = t.clamp(0.0, 1.0);
        return ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: shown,
            heightFactor: 1,
            child: Opacity(
              opacity: shown,
              child: Transform.scale(
                // A little overshoot of the spring is the pop.
                scale: motion.reduced ? 1 : .4 + .6 * t,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: gap),
        child: PhosphorIcon(PhosphorIconsBold.check, size: size - 2),
      ),
    );
  }
}

/// The cross at the end of a chip that can be removed.
class _ChipDelete extends StatelessWidget {
  const _ChipDelete({
    required this.onDeleted,
    required this.icon,
    required this.semanticLabel,
    required this.chipLabel,
    required this.height,
    required this.end,
    required this.size,
    required this.color,
    required this.focusable,
  });

  final VoidCallback onDeleted;
  final Widget? icon;
  final String? semanticLabel;

  /// The chip's own name, which the button's says it removes.
  final String? chipLabel;

  /// The chip's height, which the target takes up whole.
  final double height;

  /// The room from the cross's padding to the chip's end edge.
  final double end;
  final double size;
  final Color color;
  final bool focusable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = UnaLocalizations.of(context).chip;
    final button = Pressable(
      onPressed: onDeleted,
      semanticLabel:
          semanticLabel ??
          (chipLabel == null
              ? strings.remove
              : strings.removeNamed(label: chipLabel!)),
      // The whole end of the chip is the target, its full height to its
      // edge; only the disc is drawn.
      builder: (context, states) {
        final active =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed);
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          // As tall as the chip and no taller, the disc in the middle.
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 4, end: 4 + end),
              child: FocusRing(
                visible: states.contains(WidgetState.focused),
                borderRadius: theme.radii.full,
                child: AnimatedFill(
                  color: active
                      ? color.withValues(alpha: color.a * .12)
                      : const Color(0x00000000),
                  borderRadius: theme.radii.full,
                  child: SizedBox.square(
                    dimension: size + 4,
                    child: Center(
                      child: IconTheme.merge(
                        data: IconThemeData(
                          size: size - 4,
                          color: color.withValues(
                            alpha: color.a * (active ? 1 : .7),
                          ),
                        ),
                        child: icon ?? const PhosphorIcon(PhosphorIconsBold.x),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    // A node of its own wherever the chip is put: "Remove" is a button
    // beside the chip's name, never part of it.
    final node = Semantics(container: true, child: button);
    return focusable ? node : ExcludeFocus(child: node);
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
  });

  final Color color;
  final double width;
  final BorderRadius radius;

  static const _dash = 3.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = radius.toRRect(Offset.zero & size).deflate(width / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      // Stretch the pattern so a whole number of dashes fits the outline and
      // the last one meets the first without a seam.
      final count = (metric.length / (_dash + _gap)).round();
      if (count == 0) continue;
      final step = metric.length / count;
      final dash = step * _dash / (_dash + _gap);
      for (var i = 0; i < count; i++) {
        final start = i * step;
        canvas.drawPath(metric.extractPath(start, start + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.radius != radius;
}
