import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/card.dart';
import 'package:una/src/components/chat_bubble.dart';
import 'package:una/src/components/skeleton.dart';
import 'package:una/src/theme/components/card.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';

/// A line of text in [style] as a skeleton draws it: the height of the line
/// and the height of the bar in it, at the ambient text scale.
({double line, double bar}) _lineMetrics(
  BuildContext context,
  TextStyle style,
) {
  final fontSize = MediaQuery.textScalerOf(context).scale(style.fontSize ?? 14);
  return (
    line: fontSize * (style.height ?? 1.4),
    // About a capital's height: what the eye takes for the line's ink.
    bar: (fontSize * .72).roundToDouble(),
  );
}

/// The corners of a bar [height] tall: the theme's small radius, never more
/// than round ends.
BorderRadius _barRadius(BuildContext context, double height) {
  final sm = Theme.of(context).radii.sm.topLeft.x;
  return BorderRadius.circular(math.min(sm, height / 2));
}

/// The widths of the lines of a paragraph, as fractions of its width: never
/// all equal, which reads as a box, and the same on every build.
const _lineWidths = [1.0, .94, .98, .9, .96, .92];

/// The width a placeholder takes when nothing bounds it.
const _unboundedWidth = 240.0;

/// {@template SkeletonText}
/// A placeholder for [lines] of text in [style]: a bar per line, each as
/// tall as the text's capitals and spaced at its line height, so the block
/// is as tall as the text it stands in for.
///
/// ```dart
/// SkeletonText(lines: 3, style: theme.textTheme.p)
/// ```
///
/// The lines vary a little in length and the last one is shorter
/// ([lastLineWidthFactor]), as a paragraph's are. It fills the width it is
/// given, or [width]; with neither it is 240 wide.
/// {@endtemplate}
class SkeletonText extends StatelessWidget {
  /// {@macro SkeletonText}
  const SkeletonText({
    super.key,
    this.lines = 3,
    this.style,
    this.width,
    this.lastLineWidthFactor,
  }) : assert(lines > 0, 'A text has at least one line');

  /// How many lines.
  final int lines;

  /// The style of the text it stands in for, merged over the ambient
  /// `DefaultTextStyle`.
  final TextStyle? style;

  /// The width of the block; null fills the width given.
  final double? width;

  /// How long the last line is, as a fraction of [width]. Defaults to .6 for
  /// a paragraph and to the full width for a single line.
  final double? lastLineWidthFactor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final metrics = _lineMetrics(
      context,
      DefaultTextStyle.of(context).style.merge(style),
    );
    final radius = _barRadius(context, metrics.bar);
    final last = lastLineWidthFactor ?? (lines > 1 ? .6 : 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final full =
            width ??
            (constraints.hasBoundedWidth
                ? constraints.maxWidth
                : _unboundedWidth);
        return SizedBox(
          width: full,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < lines; i++)
                SizedBox(
                  height: metrics.line,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Skeleton(
                      width:
                          full *
                          (i == lines - 1
                              ? last
                              : _lineWidths[i % _lineWidths.length]),
                      height: metrics.bar,
                      borderRadius: radius,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// {@template SkeletonListTile}
/// A placeholder for a `ListTile`: its padding and gap, a [leading]
/// avatar, a title line and [subtitleLines] lines of subtitle in the list
/// tile theme's text styles, and an optional [trailing] placeholder.
///
/// ```dart
/// Column(children: [for (var i = 0; i < 4; i++) const SkeletonListTile()])
/// ```
/// {@endtemplate}
class SkeletonListTile extends StatelessWidget {
  /// {@macro SkeletonListTile}
  const SkeletonListTile({
    super.key,
    this.leading = const Skeleton.avatar(),
    this.trailing,
    this.subtitleLines = 1,
  }) : assert(subtitleLines >= 0, 'subtitleLines is not negative');

  /// What stands in for the tile's leading widget: an avatar by default;
  /// null for none.
  final Widget? leading;

  /// What stands in for the tile's trailing widget, such as a
  /// `Skeleton.button`; none by default.
  final Widget? trailing;

  /// How many lines of subtitle; 0 for none.
  final int subtitleLines;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final tile = Theme.of(context).listTileTheme;
    return Padding(
      padding:
          tile.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: tile.gap ?? 12,
        children: [
          ?leading,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tile.titleGap ?? 0,
              children: [
                SkeletonText(
                  lines: 1,
                  style: tile.titleStyle,
                  lastLineWidthFactor: .5,
                ),
                if (subtitleLines > 0)
                  SkeletonText(
                    lines: subtitleLines,
                    style: tile.subtitleStyle,
                    lastLineWidthFactor: subtitleLines > 1 ? .6 : .8,
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// {@template SkeletonCard}
/// A placeholder for a `Card`: a real card, with a media block across its
/// top ([mediaAspectRatio]), a title line, [lines] lines of description and
/// [actions] button placeholders, in the card theme's padding, gap and
/// text styles.
///
/// ```dart
/// const SkeletonCard(width: 320, actions: 2)
/// ```
/// {@endtemplate}
class SkeletonCard extends StatelessWidget {
  /// {@macro SkeletonCard}
  const SkeletonCard({
    super.key,
    this.width,
    this.mediaAspectRatio = 16 / 9,
    this.lines = 2,
    this.actions = 0,
  }) : assert(lines >= 0 && actions >= 0, 'Counts are not negative');

  /// The width of the card; null fills the width given.
  final double? width;

  /// The width over the height of the media block; null for no media.
  final double? mediaAspectRatio;

  /// How many lines of description; 0 for none.
  final int lines;

  /// How many button placeholders in the card's footer.
  final int actions;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final padding = cardTheme.padding ?? const EdgeInsets.all(24);
    final gap = cardTheme.gap ?? 12;
    final radius = cardTheme.borderRadius ?? theme.radii.xl;
    // The media sits inside the card's hairline, so its corners are the
    // card's less that.
    final inner = math.max<double>(0, radius.topLeft.x - 1);
    final ratio = mediaAspectRatio;

    Widget card = Card(
      style: const CardTheme(padding: EdgeInsets.zero),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ratio != null)
            AspectRatio(
              aspectRatio: ratio,
              child: Skeleton(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(inner),
                ),
              ),
            ),
          Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: gap,
              children: [
                SkeletonText(
                  lines: 1,
                  style: cardTheme.titleStyle,
                  lastLineWidthFactor: .55,
                ),
                if (lines > 0)
                  SkeletonText(lines: lines, style: cardTheme.descriptionStyle),
                if (actions > 0)
                  Padding(
                    padding: EdgeInsets.only(top: gap / 2),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < actions; i++)
                          Skeleton.button(
                            size: ButtonSize.sm,
                            width: i == 0 ? 88 : 72,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (width != null) card = SizedBox(width: width, child: card);
    return card;
  }
}

/// {@template SkeletonChatBubble}
/// A placeholder for a `ChatBubble`: a bubble of the chat bubble theme's
/// corners and padding, as tall as [lines] lines of its text, on the side
/// its [direction] puts it, with the tail corner squared off.
///
/// ```dart
/// Column(children: [
///   const SkeletonChatBubble(),
///   const SkeletonChatBubble(
///     direction: ChatBubbleDirection.outgoing,
///     lines: 1,
///   ),
/// ])
/// ```
/// {@endtemplate}
class SkeletonChatBubble extends StatelessWidget {
  /// {@macro SkeletonChatBubble}
  const SkeletonChatBubble({
    super.key,
    this.direction = ChatBubbleDirection.incoming,
    this.lines = 2,
    this.widthFactor = .8,
  }) : assert(lines > 0, 'A bubble has at least one line');

  /// Which side the bubble is on, and so which corner is its tail.
  final ChatBubbleDirection direction;

  /// How many lines of text the bubble is as tall as.
  final int lines;

  /// How wide the bubble is, as a fraction of the widest a bubble may be.
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final bubble = theme.chatBubbleTheme;
    final padding = (bubble.padding ?? const EdgeInsets.all(12)).resolve(
      Directionality.of(context),
    );
    final metrics = _lineMetrics(
      context,
      bubble.textStyle ?? theme.textTheme.p,
    );
    final round = Radius.circular(bubble.radius ?? 18);
    final tail = Radius.circular(bubble.tailRadius ?? 6);
    final outgoing = direction == ChatBubbleDirection.outgoing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : _unboundedWidth / .78;
        return Align(
          alignment: outgoing
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Skeleton(
            width: available * (bubble.maxWidthFactor ?? .78) * widthFactor,
            height: padding.vertical + metrics.line * lines,
            borderRadius: BorderRadiusDirectional.only(
              topStart: round,
              topEnd: round,
              bottomStart: outgoing ? round : tail,
              bottomEnd: outgoing ? tail : round,
            ),
          ),
        );
      },
    );
  }
}

/// {@template SkeletonTableRow}
/// A placeholder for a row of a `UnaTable` or `DataTable`: the table
/// theme's row height and cell padding, a bar of its cell text per column,
/// of lengths that differ from column to column, and a hairline below.
///
/// ```dart
/// Column(children: [for (var i = 0; i < 5; i++) SkeletonTableRow(row: i)])
/// ```
///
/// [flex] shares the width between the columns as `Expanded` does; [row]
/// varies the bars' lengths from one row to the next.
/// {@endtemplate}
class SkeletonTableRow extends StatelessWidget {
  /// {@macro SkeletonTableRow}
  const SkeletonTableRow({
    super.key,
    this.columns = 4,
    this.flex,
    this.row = 0,
    this.divider = true,
  }) : assert(columns > 0, 'A row has at least one column');

  /// How many columns.
  final int columns;

  /// The share of the width each column takes, one entry per column;
  /// equal shares by default.
  final List<int>? flex;

  /// Which row this is, so a column of rows does not repeat one pattern.
  final int row;

  /// Whether a hairline is drawn below the row.
  final bool divider;

  // Bars of different lengths, the same on every build: a column of equal
  // ones reads as a table that has loaded and is empty.
  static const _widths = [.72, .48, .86, .6, .4, .78];

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    assert(
      flex == null || flex!.length == columns,
      'flex has one entry per column',
    );
    final theme = Theme.of(context);
    final table = theme.tableTheme;
    final metrics = _lineMetrics(
      context,
      table.cellStyle ?? theme.textTheme.small,
    );
    final radius = _barRadius(context, metrics.bar);
    final height = math.max(table.cellHeight ?? 48, metrics.line + 8);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: theme.colorScheme.border))
            : null,
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (var i = 0; i < columns; i++)
              Expanded(
                flex: flex?[i] ?? 1,
                child: Padding(
                  padding: table.cellPadding ?? EdgeInsets.zero,
                  child: FractionallySizedBox(
                    widthFactor: _widths[(row * 2 + i * 3) % _widths.length],
                    alignment: AlignmentDirectional.centerStart,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Skeleton(
                        width: double.infinity,
                        height: metrics.bar,
                        borderRadius: radius,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
