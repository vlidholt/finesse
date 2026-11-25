import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'collapsible.g.theme.dart';

/// {@template CollapsibleTheme}
/// Theme for the `Collapsible` widget.
/// {@endtemplate}
@themeGen
@immutable
class CollapsibleTheme with _$CollapsibleTheme {
  /// {@macro CollapsibleTheme}
  const CollapsibleTheme({
    bool canMerge = true,
    this.crossAxisAlignment,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Collapsible.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// Linearly interpolates between [a] and [b] by [t].
  static CollapsibleTheme? lerp(
    CollapsibleTheme? a,
    CollapsibleTheme? b,
    double t,
  ) => _$CollapsibleTheme.lerp(a, b, t);
}
