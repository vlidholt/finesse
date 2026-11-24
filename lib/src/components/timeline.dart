import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// One entry of a [Timeline].
@immutable
class TimelineEntry {
  /// Creates an entry with a [marker] in the gutter and [child] beside it.
  const TimelineEntry({required this.marker, required this.child});

  /// The widget in the gutter: a logo, an avatar, an icon tile.
  final Widget marker;

  /// The entry's content.
  final Widget child;
}

/// A vertical sequence of entries joined by a line: work experience, an
/// activity log, the steps of an order.
///
/// ```dart
/// Timeline(
///   entries: [
///     TimelineEntry(
///       marker: Image.asset('assets/halcyon.png', width: 42),
///       child: const Text('Senior product designer'),
///     ),
///     TimelineEntry(
///       marker: Image.asset('assets/birchline.png', width: 42),
///       child: const Text('Product designer'),
///     ),
///   ],
/// )
/// ```
///
/// The line runs from under each marker to the top of the next and stops at
/// the last entry.
class Timeline extends StatelessWidget {
  /// Creates a timeline.
  const Timeline({
    required this.entries,
    this.gap,
    this.spacing,
    this.lineColor,
    super.key,
  });

  /// The entries, top to bottom.
  final List<TimelineEntry> entries;

  /// The gap between a marker and its content.
  final double? gap;

  /// The space between one entry and the next.
  final double? spacing;

  /// The colour of the joining line.
  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeline = theme.timelineTheme;
    final effectiveSpacing = spacing ?? timeline.spacing ?? 20;
    final lineGap = timeline.lineGap ?? 6;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, entry) in entries.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap ?? timeline.gap ?? 14,
              children: [
                Column(
                  children: [
                    entry.marker,
                    if (index < entries.length - 1)
                      Expanded(
                        child: Container(
                          width: timeline.lineWidth ?? 2,
                          margin: EdgeInsets.only(
                            top: lineGap,
                            bottom: lineGap,
                          ),
                          decoration: BoxDecoration(
                            color:
                                lineColor ??
                                timeline.lineColor ??
                                theme.colorScheme.borderStrong,
                            borderRadius: BorderRadius.circular(
                              timeline.lineWidth ?? 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: index < entries.length - 1 ? effectiveSpacing : 0,
                    ),
                    child: entry.child,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
