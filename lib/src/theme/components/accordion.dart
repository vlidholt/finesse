import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'accordion.g.theme.dart';

/// {@template AccordionTheme}
/// Theme for the `Accordion` widget.
/// {@endtemplate}
@themeGen
@immutable
class AccordionTheme with _$AccordionTheme {
  /// {@macro AccordionTheme}
  const AccordionTheme({
    bool canMerge = true,
    this.icon,
    this.iconEffects,
    this.padding,
    this.underlineTitleOnHover,
    this.titleStyle,
    this.curve,
    this.duration,
    this.maintainState,
    this.effects,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro AccordionItem.icon}
  ///
  /// A theme is compared on every rebuild, so a widget given here has to be
  /// a constant. It is drawn 16 points large in the foreground colour unless
  /// it says otherwise.
  final Widget? icon;

  /// {@macro AccordionItem.iconEffects}
  final List<Effect<dynamic>>? iconEffects;

  /// {@macro AccordionItem.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro AccordionItem.underlineTitleOnHover}
  final bool? underlineTitleOnHover;

  /// {@macro AccordionItem.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro AccordionItem.curve}
  final Curve? curve;

  /// {@macro AccordionItem.duration}
  final Duration? duration;

  /// {@macro Accordion.maintainState}
  final bool? maintainState;

  /// {@macro AccordionItem.effects}
  final List<Effect<dynamic>>? effects;

  /// Linearly interpolates between [a] and [b] by [t].
  static AccordionTheme? lerp(
    AccordionTheme? a,
    AccordionTheme? b,
    double t,
  ) => _$AccordionTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is AccordionTheme &&
      listEquals(iconEffects, other.iconEffects) &&
      listEquals(effects, other.effects) &&
      super == other.copyWith(iconEffects: iconEffects, effects: effects);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(iconEffects ?? const []),
    Object.hashAll(effects ?? const []),
  );
}
