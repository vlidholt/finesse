import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'streaming_text.g.theme.dart';

/// The theme of `StreamingText`: every value the widget does not set itself.
///
/// The motion knobs are null by default and are resolved from the theme's
/// motion when the text builds, so they follow `ThemeData(motion: ...)` and
/// the platform's reduced-motion setting.
@themeGen
@immutable
class StreamingTextTheme with _$StreamingTextTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const StreamingTextTheme({
    bool canMerge = true,
    this.revealRate,
    this.catchUpDuration,
    this.fadeDuration,
    this.rise,
    this.showCaret,
    this.caretColor,
    this.caretWidth,
    this.caretGap,
    this.caretPulse,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The slowest text is revealed, in characters a second: the pace of a
  /// trickle, and of the last few characters of a burst.
  final double? revealRate;

  /// How long the reveal takes to work through what has arrived but is not
  /// showing yet. The further behind it is, the faster it goes, so a large
  /// burst is not typed out at [revealRate]; a steady stream is shown about
  /// this long after it arrives.
  final Duration? catchUpDuration;

  /// How long newly revealed text takes to fade in. Null uses the theme
  /// motion's normal duration.
  final Duration? fadeDuration;

  /// How far, in logical pixels, newly revealed text rises into place as it
  /// fades in. Null derives it from the theme motion's overlay travel.
  final double? rise;

  /// Whether a soft caret marks the end of the text while more is expected.
  final bool? showCaret;

  /// The colour of the caret. Null uses the text's own colour, softened.
  final Color? caretColor;

  /// The width of the caret.
  final double? caretWidth;

  /// The gap between the last character and the caret.
  final double? caretGap;

  /// How long one breath of the caret takes. Zero keeps it steady.
  final Duration? caretPulse;

  /// Linearly interpolates between two themes.
  static StreamingTextTheme? lerp(
    StreamingTextTheme? a,
    StreamingTextTheme? b,
    double t,
  ) => _$StreamingTextTheme.lerp(a, b, t);
}
