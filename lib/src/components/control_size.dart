import 'package:flutter/widgets.dart';
import 'package:una/src/theme/data.dart';

/// How large a field-like control is drawn: a `NumberField`, a `Select`, a
/// `SegmentedControl`.
///
/// [regular] is the theme's own size, the height of a text field. [sm] is
/// a step smaller — a small button's height and padding, its text a size
/// down — for dense surfaces: an inspector, a settings panel, a toolbar,
/// a cell edited in place. Both follow the form factor, so a small control
/// on a phone is still a comfortable target.
enum ControlSize {
  /// A step smaller than a text field: a small button's height.
  sm,

  /// The theme's own size.
  regular,
}

/// The metrics a [ControlSize] stands for in a theme.
@immutable
class ControlMetrics {
  const ControlMetrics._({
    required this.height,
    required this.paddingX,
    required this.iconSize,
    required this.textStyle,
  });

  /// The metrics of [size] in [theme]; null for [ControlSize.regular],
  /// where a control keeps its own.
  static ControlMetrics? of(ThemeData theme, ControlSize size) {
    if (size == ControlSize.regular) return null;
    final sm = theme.buttonSizesTheme.sm;
    final padding = sm?.padding.horizontal ?? 24;
    return ControlMetrics._(
      height: sm?.height ?? 32,
      paddingX: padding / 2,
      iconSize: sm?.iconSize ?? 14,
      textStyle: theme.textTheme.small.copyWith(
        fontWeight: theme.textTheme.p.fontWeight,
      ),
    );
  }

  /// The control's height, border included.
  final double height;

  /// The inset of its content from its start and end.
  final double paddingX;

  /// The size of its icons.
  final double iconSize;

  /// The style of its text.
  final TextStyle textStyle;
}
