import 'package:flutter/widgets.dart';
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
    this.padding,
    this.underlineTitleOnHover,
    this.titleStyle,
    this.maintainState,
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

  /// {@macro AccordionItem.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro AccordionItem.underlineTitleOnHover}
  final bool? underlineTitleOnHover;

  /// {@macro AccordionItem.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro Accordion.maintainState}
  final bool? maintainState;

  /// Linearly interpolates between [a] and [b] by [t].
  static AccordionTheme? lerp(
    AccordionTheme? a,
    AccordionTheme? b,
    double t,
  ) => _$AccordionTheme.lerp(a, b, t);
}
