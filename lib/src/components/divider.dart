import 'package:finesse/src/theme/components/divider.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// Variants available for the [Divider] widget.
enum DividerVariant {
  /// A vertical line, used between items in a row.
  vertical,

  /// A horizontal line, used between items in a column.
  horizontal,
}

/// A customizable widget that supports horizontal and vertical separators.
///
/// Typically used to separate content or sections of row, columns, or lists.
class Divider extends StatelessWidget {
  /// Creates a separator: a horizontal line unless [variant] says
  /// otherwise.
  const Divider({
    this.variant = DividerVariant.horizontal,
    this.margin,
    this.thickness,
    this.color,
    this.borderRadius,
    super.key,
  });

  /// Creates a vertical separator, a shortcut for
  /// `Divider(variant: DividerVariant.vertical)`.
  const Divider.vertical({
    this.margin,
    this.thickness,
    this.color,
    this.borderRadius,
    super.key,
  }) : variant = DividerVariant.vertical;

  /// {@template Divider.margin}
  /// The margin (or space) around the separator.
  ///{@endtemplate}
  ///
  /// This will override [DividerTheme.verticalMargin] and
  /// [DividerTheme.horizontalMargin].
  final EdgeInsetsGeometry? margin;

  /// {@template Divider.thickness}
  /// The thickness of the separator.
  /// This controls the height of the horizontal separator and the
  /// width of the vertical separator.
  /// {@endtemplate}
  ///
  /// This will override [DividerTheme.thickness].
  final double? thickness;

  /// {@template Divider.color}
  /// The color of the separator.
  /// {@endtemplate}
  ///
  /// This will override [DividerTheme.color].
  final Color? color;

  /// Whether the line is horizontal, the default, or vertical.
  final DividerVariant variant;

  /// {@template Divider.borderRadius}
  /// The amount of radius for the border of the separator.
  ///
  /// If this is null, then the default radius of [BoxDecoration] will be used.
  /// {@endtemplate}
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerTheme = theme.dividerTheme;

    final effectiveThickness = thickness ?? dividerTheme.thickness ?? 1;
    final effectiveColor =
        color ?? dividerTheme.color ?? theme.colorScheme.border;

    final borderSide = BorderSide(
      color: effectiveColor,
      width: effectiveThickness,
    );

    final defaultMargin = switch (variant) {
      DividerVariant.vertical => dividerTheme.verticalMargin,
      DividerVariant.horizontal => dividerTheme.horizontalMargin,
    };

    final effectiveMargin = margin ?? defaultMargin ?? EdgeInsets.zero;

    return Padding(
      padding: effectiveMargin,
      child: switch (variant) {
        DividerVariant.vertical => DecoratedBox(
          decoration: BoxDecoration(
            border: Border(left: borderSide),
            borderRadius: borderRadius,
          ),
          child: SizedBox(width: effectiveThickness, height: double.infinity),
        ),
        DividerVariant.horizontal => DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: borderSide),
            borderRadius: borderRadius,
          ),
          child: SizedBox(height: effectiveThickness, width: double.infinity),
        ),
      },
    );
  }
}
