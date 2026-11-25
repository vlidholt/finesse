import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'resizable.g.theme.dart';

/// {@template ResizableTheme}
/// Theme for the `ResizablePanelGroup` widget.
/// {@endtemplate}
@themeGen
@immutable
class ResizableTheme with _$ResizableTheme {
  /// {@macro ResizableTheme}
  const ResizableTheme({
    bool canMerge = true,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,
    this.textDirection,
    this.verticalDirection,
    this.showHandle,
    this.handleIconData,
    this.dividerSize,
    this.resetOnDoubleTap,
    this.handleDecoration,
    this.handlePadding,
    this.handleSize,
    this.dividerThickness,
    this.dividerColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro ResizablePanelGroup.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro ResizablePanelGroup.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro ResizablePanelGroup.mainAxisSize}
  final MainAxisSize? mainAxisSize;

  /// {@macro ResizablePanelGroup.textDirection}
  final TextDirection? textDirection;

  /// {@macro ResizablePanelGroup.verticalDirection}
  final VerticalDirection? verticalDirection;

  /// {@macro ResizablePanelGroup.showHandle}
  final bool? showHandle;

  /// An icon for the resize handle.
  final IconData? handleIconData;

  /// {@macro ResizablePanelGroup.dividerSize}
  final double? dividerSize;

  /// {@macro ResizablePanelGroup.resetOnDoubleTap}
  final bool? resetOnDoubleTap;

  /// {@macro ResizablePanelGroup.handleDecoration}
  final FinesseDecoration? handleDecoration;

  /// {@macro ResizablePanelGroup.handlePadding}
  final EdgeInsetsGeometry? handlePadding;

  /// {@macro ResizablePanelGroup.handleSize}
  final double? handleSize;

  /// {@macro ResizablePanelGroup.dividerThickness}
  final double? dividerThickness;

  /// {@macro ResizablePanelGroup.dividerColor}
  final Color? dividerColor;

  /// Linearly interpolates between [a] and [b] by [t].
  static ResizableTheme? lerp(
    ResizableTheme? a,
    ResizableTheme? b,
    double t,
  ) => _$ResizableTheme.lerp(a, b, t);
}
