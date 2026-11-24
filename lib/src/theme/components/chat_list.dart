import 'package:finesse/src/theme/motion.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'chat_list.g.theme.dart';

/// The theme of `ChatList`: every value the widget does not set itself.
///
/// The motion knobs are null by default and are resolved from the theme's
/// motion when the list builds, so they follow `ThemeData(motion: ...)` and
/// the platform's reduced-motion setting.
@themeGen
@immutable
class ChatListTheme with _$ChatListTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const ChatListTheme({
    bool canMerge = true,
    this.padding,
    this.spacing,
    this.groupSpacing,
    this.followDistance,
    this.enterSpring,
    this.exitSpring,
    this.enterScale,
    this.enterTravel,
    this.stagger,
    this.maxStaggerSteps,
    this.jumpToLatestMargin,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The padding around the messages, inside the scroll view.
  final EdgeInsetsGeometry? padding;

  /// The gap between two messages that are not part of one run.
  final double? spacing;

  /// The gap between two consecutive messages of one run: the same sender,
  /// moments apart.
  final double? groupSpacing;

  /// How far from the newest message, in logical pixels, the list still
  /// counts as resting on it — and so follows new content down.
  final double? followDistance;

  /// The spring a new message arrives on: its height opening up, and the
  /// bubble growing out of its tail corner. Null uses the theme motion's
  /// snappy spring without its bounce, so the messages above never
  /// overshoot.
  final MotionSpring? enterSpring;

  /// The spring a removed message leaves on. Null uses the enter spring, a
  /// third faster.
  final MotionSpring? exitSpring;

  /// The scale a new message grows from; 1 is no growth. Null derives it
  /// from the theme motion's overlay scale.
  final double? enterScale;

  /// How far, in logical pixels, an incoming message travels in from its
  /// side. Null derives it from the theme motion's overlay travel.
  final double? enterTravel;

  /// The delay between two messages that arrive together. Null uses a
  /// third of the theme motion's fast duration.
  final Duration? stagger;

  /// The most [stagger]s any message waits, so a burst never queues for
  /// long.
  final int? maxStaggerSteps;

  /// The gap between the "jump to latest" button and the bottom [padding].
  final double? jumpToLatestMargin;

  /// Linearly interpolates between two themes.
  static ChatListTheme? lerp(ChatListTheme? a, ChatListTheme? b, double t) =>
      _$ChatListTheme.lerp(a, b, t);
}
