import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'swipe_actions.g.theme.dart';

/// The theme of `SwipeActions`.
///
/// ```dart
/// ThemeData(
///   swipeActionsTheme: const SwipeActionsTheme(edgeShadowWidth: 0),
/// )
/// ```
@themeGen
@immutable
class SwipeActionsTheme with _$SwipeActionsTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const SwipeActionsTheme({
    bool canMerge = true,
    this.edgeShadowColor,
    this.edgeShadowWidth,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The colour of the shadow the row casts onto the uncovered actions, at
  /// the row's edge. It fades out over [edgeShadowWidth]. Defaults to a
  /// light black wash, darker in a dark theme.
  final Color? edgeShadowColor;

  /// How far the edge shadow reaches into the actions. Zero draws none.
  final double? edgeShadowWidth;

  /// Linearly interpolates between [a] and [b] by [t].
  static SwipeActionsTheme? lerp(
    SwipeActionsTheme? a,
    SwipeActionsTheme? b,
    double t,
  ) => _$SwipeActionsTheme.lerp(a, b, t);
}
