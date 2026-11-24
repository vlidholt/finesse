import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A row with a leading widget, a title, a subtitle and a trailing widget:
/// a conversation, a person to follow, a shared file, a settings entry.
///
/// ```dart
/// ListTile(
///   leading: const Avatar('assets/omar.jpg'),
///   title: const Text('Omar Rahimi'),
///   subtitle: const Text('Design lead at Birchline'),
///   trailing: Button.outline(onPressed: _follow, child: const Text('Follow')),
///   onTap: _openProfile,
/// )
/// ```
///
/// The title and subtitle each truncate to [titleMaxLines] and
/// [subtitleMaxLines]. With an [onTap] the row highlights under the pointer
/// and takes keyboard focus; [selected] gives it the theme's accent fill.
class ListTile extends StatelessWidget {
  /// Creates a list tile.
  const ListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.padding,
    this.gap,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.focusNode,
    super.key,
  });

  /// The widget before the text, usually an avatar or an [Icon].
  final Widget? leading;

  /// The first line.
  final Widget title;

  /// The quieter line under the title.
  final Widget? subtitle;

  /// The widget after the text: a button, a timestamp, a badge.
  final Widget? trailing;

  /// Called when the row is tapped. Null makes the row inert.
  final VoidCallback? onTap;

  /// Whether the row is the selected one of its list.
  final bool selected;

  /// Padding around the row's content. Defaults to the theme's.
  final EdgeInsetsGeometry? padding;

  /// The gap between [leading], the text and [trailing].
  final double? gap;

  /// How [leading] and [trailing] align against the text.
  final CrossAxisAlignment crossAxisAlignment;

  /// The most lines the title wraps to; null for no limit.
  final int? titleMaxLines;

  /// The most lines the subtitle wraps to; null for no limit.
  final int? subtitleMaxLines;

  /// The title's style. Defaults to the theme's.
  final TextStyle? titleStyle;

  /// The subtitle's style. Defaults to the theme's.
  final TextStyle? subtitleStyle;

  /// The corner radius of the highlight.
  final BorderRadius? borderRadius;

  /// The focus node to use.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = theme.listTileTheme;
    final radius = borderRadius ?? tile.radius ?? theme.radius;
    final effectiveGap = gap ?? tile.gap ?? 12;

    Widget line(Widget child, TextStyle style, int? maxLines) =>
        DefaultTextStyle.merge(
          style: style,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          child: child,
        );

    // The scheme's colour is a default: a style that states its own colour —
    // the caller's or the theme's — keeps it.
    TextStyle coloured(TextStyle style, Color fallback) =>
        style.color == null ? style.copyWith(color: fallback) : style;

    final row = Padding(
      padding:
          padding ??
          tile.padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        spacing: effectiveGap,
        children: [
          ?leading,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tile.titleGap ?? 0,
              children: [
                line(
                  title,
                  coloured(
                    titleStyle ?? tile.titleStyle ?? theme.textTheme.large,
                    theme.colorScheme.foreground,
                  ),
                  titleMaxLines,
                ),
                if (subtitle != null)
                  line(
                    subtitle!,
                    coloured(
                      subtitleStyle ??
                          tile.subtitleStyle ??
                          theme.textTheme.muted,
                      theme.colorScheme.mutedForeground,
                    ),
                    subtitleMaxLines,
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (onTap == null) {
      if (!selected) return row;
      // Selected but inert: highlighted, and not announced as a button.
      return Semantics(
        selected: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tile.selectedColor ?? theme.colorScheme.accent,
            borderRadius: radius,
          ),
          child: row,
        ),
      );
    }

    return Pressable(
      onPressed: onTap,
      selected: selected ? true : null,
      focusNode: focusNode,
      // The press gives a little, as a surface does; see `Card`.
      pressScale: tile.pressScale ?? Motion.of(context).surfacePressScale,
      builder: (context, states) {
        final color = selected
            ? tile.selectedColor ?? theme.colorScheme.accent
            : states.contains(WidgetState.hovered)
            ? tile.hoverColor ?? theme.colorScheme.muted
            : const Color(0x00000000);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: radius,
          child: AnimatedFill(
            color: color,
            borderRadius: radius,
            child: row,
          ),
        );
      },
    );
  }
}
