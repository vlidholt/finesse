import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'chat_bubble.g.theme.dart';

/// The theme of `ChatBubble`: every value the widget does not set itself.
@themeGen
@immutable
class ChatBubbleTheme with _$ChatBubbleTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const ChatBubbleTheme({
    bool canMerge = true,
    this.radius,
    this.tailRadius,
    this.padding,
    this.textStyle,
    this.incomingColor,
    this.incomingForegroundColor,
    this.outgoingColor,
    this.outgoingForegroundColor,
    this.maxWidthFactor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The corner radius.
  final double? radius;

  /// The radius of the corner nearest the sender.
  final double? tailRadius;

  /// Padding around the message.
  final EdgeInsetsGeometry? padding;

  /// The message's style.
  final TextStyle? textStyle;

  /// The fill of a received message.
  final Color? incomingColor;

  /// The text colour of a received message.
  final Color? incomingForegroundColor;

  /// The fill of a sent message.
  final Color? outgoingColor;

  /// The text colour of a sent message.
  final Color? outgoingForegroundColor;

  /// The widest a bubble grows, as a fraction of the available width.
  final double? maxWidthFactor;

  /// Linearly interpolates between two themes.
  static ChatBubbleTheme? lerp(
    ChatBubbleTheme? a,
    ChatBubbleTheme? b,
    double t,
  ) => _$ChatBubbleTheme.lerp(a, b, t);
}
