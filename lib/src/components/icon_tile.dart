import 'package:finesse/src/components/card.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// An icon on a soft, rounded square: the marker beside a statistic, a file
/// type, a setting.
///
/// ```dart
/// const IconTile(icon: PhosphorIcon(PhosphorIconsRegular.bookmarkSimple))
/// ```
///
/// The tile takes the theme's accent fill and tint colour, which is what
/// makes it read as part of the brand rather than as a control.
class IconTile extends StatelessWidget {
  /// Creates an icon tile.
  const IconTile({
    required this.icon,
    this.size,
    this.iconSize,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    super.key,
  });

  /// The icon, usually an [Icon].
  final Widget icon;

  /// The tile's width and height. Defaults to the theme's.
  final double? size;

  /// The icon's size. Defaults to the theme's.
  final double? iconSize;

  /// The tile's fill. Defaults to the theme's accent.
  final Color? backgroundColor;

  /// The icon's colour. Defaults to the theme's tint.
  final Color? foregroundColor;

  /// The corner radius. Defaults to the theme's.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = theme.iconTileTheme;
    final dimension = size ?? tile.size ?? 40;
    return Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? tile.backgroundColor ?? theme.colorScheme.accent,
        borderRadius: borderRadius ?? tile.borderRadius ?? theme.radii.lg,
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          size: iconSize ?? tile.iconSize ?? 22,
          color:
              foregroundColor ?? tile.foregroundColor ?? theme.colorScheme.tint,
        ),
        child: icon,
      ),
    );
  }
}

/// A headline number with a label and an icon, on a card.
///
/// ```dart
/// StatTile(
///   icon: const PhosphorIcon(PhosphorIconsRegular.bookmarkSimple),
///   value: const Text('6'),
///   label: const Text('Saved jobs'),
///   onTap: _openSaved,
/// )
/// ```
///
/// Put several in a `FinesseRow` wrapped in `Expanded`s for a summary strip.
class StatTile extends StatelessWidget {
  /// Creates a stat tile.
  const StatTile({
    required this.value,
    required this.label,
    this.icon,
    this.trailing,
    this.onTap,
    this.padding,
    super.key,
  });

  /// The icon shown in an [IconTile] before the number.
  final Widget? icon;

  /// The number, usually a [Text].
  final Widget value;

  /// What the number counts.
  final Widget label;

  /// A widget at the end of the tile, such as a trend.
  final Widget? trailing;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final card = Card(
      borderRadius: theme.radii.xl,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: layout.gapLg ?? 16,
            vertical: (layout.gapLg ?? 16) - 2,
          ),
      rowMainAxisSize: MainAxisSize.max,
      rowCrossAxisAlignment: CrossAxisAlignment.center,
      child: Row(
        spacing: layout.gapMd ?? 12,
        children: [
          if (icon != null) IconTile(icon: icon!),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle.merge(
                  style: theme.textTheme.h3.copyWith(
                    color: theme.colorScheme.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: value,
                ),
                DefaultTextStyle.merge(
                  style: theme.textTheme.muted.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: label,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) return card;
    return Pressable(
      onPressed: onTap,
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: theme.radii.xl,
        child: card,
      ),
    );
  }
}
