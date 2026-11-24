import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

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
///   leading: const Icon(PhosphorIconsRegular.globe),
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
class Chip extends StatelessWidget {
  /// Creates a chip.
  const Chip({
    required this.label,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onSelected,
    this.onPressed,
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
    final radius = chip.radius ?? theme.radii.full;
    final onTap = onSelected != null ? () => onSelected!(!selected) : onPressed;
    // A tag is not a touch target, so it does not grow on a phone.
    final effectiveHeight =
        height ??
        (onTap == null
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

      Widget content = Padding(
        padding:
            padding ??
            chip.padding ??
            const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: chip.gap ?? 6,
          children: [
            ?leading,
            Flexible(child: label),
            ?trailing,
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
      // change of form factor does not make every chip grow for 120 ms.
      Widget box = AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: radius,
          border: dashed
              ? null
              : Border.all(color: outline, width: borderWidth),
        ),
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
      box = SizedBox(height: effectiveHeight, child: box);
      return FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: radius,
        child: box,
      );
    }

    // A chip with neither callback is a tag, not a control: wrapping it in a
    // `Pressable` would announce every skill or label as a disabled button.
    if (onTap == null) {
      final tag = buildChip(context, const <WidgetState>{});
      if (semanticLabel == null && !selected) return tag;
      return Semantics(
        label: semanticLabel,
        selected: selected ? true : null,
        child: tag,
      );
    }

    return Pressable(
      onPressed: onTap,
      // Only a chip that toggles announces "selected" / "not selected".
      selected: onSelected != null || selected ? selected : null,
      focusNode: focusNode,
      semanticLabel: semanticLabel,
      builder: buildChip,
    );
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
