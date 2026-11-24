import 'package:finesse/src/theme/motion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'board.g.theme.dart';

/// The theme of `Board`: every value the widget does not set itself.
///
/// The metrics follow the form factor: on a phone a column takes
/// [columnViewportFraction] of the board's width, so the next one peeks in,
/// and the board snaps from column to column.
@themeGen
@immutable
class BoardTheme with _$BoardTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const BoardTheme({
    bool canMerge = true,
    this.columnWidth,
    this.columnMinWidth,
    this.columnMaxWidth,
    this.columnViewportFraction,
    this.columnGap,
    this.itemGap,
    this.padding,
    this.columnPadding,
    this.headerPadding,
    this.footerPadding,
    this.columnRadius,
    this.columnColor,
    this.columnBorderColor,
    this.targetColumnColor,
    this.targetColumnBorderColor,
    this.refusedColumnColor,
    this.refusedColumnBorderColor,
    this.headerTextStyle,
    this.countTextStyle,
    this.countColor,
    this.countForegroundColor,
    this.fullCountColor,
    this.fullCountForegroundColor,
    this.itemColor,
    this.itemPadding,
    this.itemRadius,
    this.itemShadows,
    this.placeholderColor,
    this.placeholderBorderColor,
    this.emptyHeight,
    this.dragScale,
    this.dragTilt,
    this.landScale,
    this.dragShadows,
    this.highlightColor,
    this.highlightDuration,
    this.liftSpring,
    this.shiftSpring,
    this.dropSpring,
    this.landSpring,
    this.autoScrollExtent,
    this.autoScrollSpeed,
    this.snap,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The width of a column in a board that scrolls sideways.
  ///
  /// A board whose columns all fit — at [columnMinWidth] or more each —
  /// shares its width between them instead, up to [columnMaxWidth].
  final double? columnWidth;

  /// The narrowest a column is squeezed to make every column fit. Narrower
  /// than that, the columns keep [columnWidth] and the board scrolls.
  final double? columnMinWidth;

  /// The widest a column grows when the board has room to spare.
  final double? columnMaxWidth;

  /// The share of the board's width one column takes, in place of
  /// [columnWidth], which then only caps it. Set on a phone, so the next
  /// column peeks in from the edge; null on a desktop.
  final double? columnViewportFraction;

  /// The gap between two columns.
  final double? columnGap;

  /// The gap between two items of a column.
  final double? itemGap;

  /// The padding around the columns, inside the board's own scroll view, so
  /// a column scrolls under it to the board's edge.
  final EdgeInsetsGeometry? padding;

  /// The padding around a column's list of items.
  final EdgeInsetsGeometry? columnPadding;

  /// The padding around a column's header.
  final EdgeInsetsGeometry? headerPadding;

  /// The padding around a column's footer.
  final EdgeInsetsGeometry? footerPadding;

  /// The corner radius of a column.
  final BorderRadius? columnRadius;

  /// The fill of a column.
  final Color? columnColor;

  /// The hairline outline of a column.
  final Color? columnBorderColor;

  /// The fill of the column a dragged item is over.
  final Color? targetColumnColor;

  /// The outline of the column a dragged item is over.
  final Color? targetColumnBorderColor;

  /// The fill of a column that refuses the dragged item.
  final Color? refusedColumnColor;

  /// The outline of a column that refuses the dragged item.
  final Color? refusedColumnBorderColor;

  /// The style of a column's title.
  final TextStyle? headerTextStyle;

  /// The style of the number beside a column's title.
  final TextStyle? countTextStyle;

  /// The fill of the count.
  final Color? countColor;

  /// The colour of the count's digits.
  final Color? countForegroundColor;

  /// The fill of the count of a column that has reached its limit.
  final Color? fullCountColor;

  /// The colour of the digits of a column that has reached its limit.
  final Color? fullCountForegroundColor;

  /// The fill a `Card` takes inside a board. Opaque, so the lifted card
  /// hides what it is dragged over.
  final Color? itemColor;

  /// The padding a `Card` takes inside a board.
  final EdgeInsetsGeometry? itemPadding;

  /// The corner radius of an item: of a `Card` inside a board, of the slot
  /// that opens for a dragged item and of the lifted item's shadow.
  final BorderRadius? itemRadius;

  /// The shadows a `Card` takes inside a board.
  final List<BoxShadow>? itemShadows;

  /// The fill of the slot that opens where a dragged item will land.
  final Color? placeholderColor;

  /// The outline of that slot, and of an empty column's drop target.
  final Color? placeholderBorderColor;

  /// The height of an empty column's drop target.
  final double? emptyHeight;

  /// How much a picked-up item grows; 1 is not at all.
  final double? dragScale;

  /// The furthest a dragged item leans into its movement, in radians.
  final double? dragTilt;

  /// How far a landing item is pressed into its slot before it springs
  /// back to its size: the pop of a drop. 1 is no pop.
  final double? landScale;

  /// The shadow under a picked-up item, in addition to its own.
  final List<BoxShadow>? dragShadows;

  /// The colour of the outline that glows around an item as it lands.
  final Color? highlightColor;

  /// How long that glow takes to fade.
  final Duration? highlightDuration;

  /// The spring an item is picked up with. Null uses the theme motion's
  /// snappy spring.
  final MotionSpring? liftSpring;

  /// The spring the other items make way with. Null uses the theme motion's
  /// snappy spring without its bounce, so nothing overshoots its slot.
  final MotionSpring? shiftSpring;

  /// The spring a released item flies to its slot with. Null uses the theme
  /// motion's snappy spring without its bounce: it arrives, and the landing
  /// does the rest.
  final MotionSpring? dropSpring;

  /// The spring a landing item settles with, from [dragScale] through
  /// [landScale] to its own size. Null uses the theme motion's bouncy
  /// spring.
  final MotionSpring? landSpring;

  /// How close to an edge, in logical pixels, a dragged item starts to
  /// scroll the board or a column.
  final double? autoScrollExtent;

  /// The fastest that scrolling gets, in logical pixels per second, reached
  /// at the edge itself.
  final double? autoScrollSpeed;

  /// Whether the board comes to rest with a column at its leading edge.
  final bool? snap;

  /// Linearly interpolates between two themes.
  static BoardTheme? lerp(BoardTheme? a, BoardTheme? b, double t) =>
      _$BoardTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is BoardTheme &&
      listEquals(itemShadows, other.itemShadows) &&
      listEquals(dragShadows, other.dragShadows) &&
      super ==
          other.copyWith(itemShadows: itemShadows, dragShadows: dragShadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(itemShadows ?? const []),
    Object.hashAll(dragShadows ?? const []),
  );
}
