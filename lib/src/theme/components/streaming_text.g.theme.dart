// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'streaming_text.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamingTextTheme {
  bool get canMerge => true;

  static StreamingTextTheme? lerp(
    StreamingTextTheme? a,
    StreamingTextTheme? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return StreamingTextTheme(
      revealRate: lerpDouble$(a.revealRate, b.revealRate, t),
      catchUpDuration: lerpDuration$(a.catchUpDuration, b.catchUpDuration, t),
      fadeDuration: lerpDuration$(a.fadeDuration, b.fadeDuration, t),
      rise: lerpDouble$(a.rise, b.rise, t),
      showCaret: t < 0.5 ? a.showCaret : b.showCaret,
      caretColor: Color.lerp(a.caretColor, b.caretColor, t),
      caretWidth: lerpDouble$(a.caretWidth, b.caretWidth, t),
      caretGap: lerpDouble$(a.caretGap, b.caretGap, t),
      caretPulse: lerpDuration$(a.caretPulse, b.caretPulse, t),
    );
  }

  StreamingTextTheme copyWith({
    double? revealRate,
    Duration? catchUpDuration,
    Duration? fadeDuration,
    double? rise,
    bool? showCaret,
    Color? caretColor,
    double? caretWidth,
    double? caretGap,
    Duration? caretPulse,
  }) {
    final _this = (this as StreamingTextTheme);

    return StreamingTextTheme(
      revealRate: revealRate ?? _this.revealRate,
      catchUpDuration: catchUpDuration ?? _this.catchUpDuration,
      fadeDuration: fadeDuration ?? _this.fadeDuration,
      rise: rise ?? _this.rise,
      showCaret: showCaret ?? _this.showCaret,
      caretColor: caretColor ?? _this.caretColor,
      caretWidth: caretWidth ?? _this.caretWidth,
      caretGap: caretGap ?? _this.caretGap,
      caretPulse: caretPulse ?? _this.caretPulse,
    );
  }

  StreamingTextTheme merge(StreamingTextTheme? other) {
    final _this = (this as StreamingTextTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      revealRate: other.revealRate,
      catchUpDuration: other.catchUpDuration,
      fadeDuration: other.fadeDuration,
      rise: other.rise,
      showCaret: other.showCaret,
      caretColor: other.caretColor,
      caretWidth: other.caretWidth,
      caretGap: other.caretGap,
      caretPulse: other.caretPulse,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamingTextTheme);
    final _other = (other as StreamingTextTheme);

    return _other.revealRate == _this.revealRate &&
        _other.catchUpDuration == _this.catchUpDuration &&
        _other.fadeDuration == _this.fadeDuration &&
        _other.rise == _this.rise &&
        _other.showCaret == _this.showCaret &&
        _other.caretColor == _this.caretColor &&
        _other.caretWidth == _this.caretWidth &&
        _other.caretGap == _this.caretGap &&
        _other.caretPulse == _this.caretPulse;
  }

  @override
  int get hashCode {
    final _this = (this as StreamingTextTheme);

    return Object.hash(
      runtimeType,
      _this.revealRate,
      _this.catchUpDuration,
      _this.fadeDuration,
      _this.rise,
      _this.showCaret,
      _this.caretColor,
      _this.caretWidth,
      _this.caretGap,
      _this.caretPulse,
    );
  }
}
