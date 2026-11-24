import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'avatar.g.theme.dart';

/// {@template AvatarTheme}
/// Theme for the `Avatar` widget.
/// {@endtemplate}
@themeGen
@immutable
class AvatarTheme with _$AvatarTheme {
  /// {@macro AvatarTheme}
  const AvatarTheme({
    bool canMerge = true,
    this.size,
    this.shape,
    this.backgroundColor,
    this.fit,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Avatar.size}
  final Size? size;

  /// {@macro Avatar.shape}
  final ShapeBorder? shape;

  /// {@macro Avatar.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Avatar.fit}
  final BoxFit? fit;

  /// Linearly interpolates between [a] and [b] by [t].
  static AvatarTheme? lerp(
    AvatarTheme? a,
    AvatarTheme? b,
    double t,
  ) => _$AvatarTheme.lerp(a, b, t);
}
