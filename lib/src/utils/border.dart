import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Converts a [FinesseBorderSide] to a Flutter [BorderSide].
extension BorderSideToBorderSide on FinesseBorderSide {
  /// Returns the Flutter [BorderSide] for this side.
  ///
  /// A side with no width becomes a zero-width side that keeps its color,
  /// instead of [BorderSide.none]. A null color becomes transparent.
  /// Otherwise the width defaults to 1, the style to [BorderStyle.solid] and
  /// the stroke alignment to [BorderSide.strokeAlignInside].
  BorderSide toBorderSide() {
    if (width == null || width == 0) {
      // Deliberately not `BorderSide.none`: that carries an opaque black, and
      // `Border` asserts that every side shares a colour before it will paint
      // a radius. A component that draws only some of its sides — the OTP
      // strip shares its vertical edges — would crash on that assertion.
      return BorderSide(
        color: color ?? const Color(0x00000000),
        width: 0,
        style: BorderStyle.none,
      );
    }
    return BorderSide(
      color: color ?? const Color(0x00000000),
      width: width ?? 1,
      style: style ?? BorderStyle.solid,
      strokeAlign: strokeAlign ?? BorderSide.strokeAlignInside,
    );
  }
}

/// Converts a [FinesseBorder] to a Flutter [Border].
extension BorderToBorder on FinesseBorder {
  /// Returns a [FinesseBoxBorder] with the four sides of this border.
  ///
  /// Missing sides become [BorderSide.none]. The radius, padding and offset are
  /// not part of the result.
  Border toBorder() {
    return FinesseBoxBorder(
      top: top?.toBorderSide() ?? BorderSide.none,
      right: right?.toBorderSide() ?? BorderSide.none,
      bottom: bottom?.toBorderSide() ?? BorderSide.none,
      left: left?.toBorderSide() ?? BorderSide.none,
    );
  }
}

/// A [Border] that tolerates differently coloured sides inside a radius.
///
/// [Border.paint] throws when given a border radius while the visible sides
/// show more than one colour. Theme animation makes that state routine:
/// lerping a boxed field towards an underlined or borderless style fades
/// three sides out while the bottom crosses to another colour, so mid-flight
/// the sides legitimately disagree. This subclass paints that case as mitred
/// straight sides clipped to the rounded outline — at field hairline widths
/// the corners are indistinguishable from the real thing, and the state only
/// lasts for the frames of the transition.
class FinesseBoxBorder extends Border {
  /// Creates a border with the given sides.
  const FinesseBoxBorder({super.top, super.right, super.bottom, super.left});

  /// Mirrors the cases [Border.paint] can draw inside a radius itself: a
  /// fully uniform border, a uniformly invisible one, or sides that show a
  /// single colour with no hairlines. Everything else asserts there.
  bool get _radiusSafeForSuper {
    if (isUniform) return true;
    final topStyle = top.style;
    final stylesUniform =
        left.style == topStyle &&
        bottom.style == topStyle &&
        right.style == topStyle;
    if (stylesUniform && topStyle == BorderStyle.none) return true;
    final visibleColors = <Color>{
      for (final side in [top, right, bottom, left])
        if (side.style != BorderStyle.none) side.color,
    };
    final hasHairline = [
      top,
      right,
      bottom,
      left,
    ].any((side) => side.style == BorderStyle.solid && side.width == 0);
    return visibleColors.length == 1 && !hasHairline;
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (shape == BoxShape.rectangle &&
        borderRadius != null &&
        borderRadius != BorderRadius.zero &&
        !_radiusSafeForSuper) {
      canvas
        ..save()
        ..clipPath(Path()..addRRect(borderRadius.toRRect(rect)));
      paintBorder(
        canvas,
        rect,
        top: top,
        right: right,
        bottom: bottom,
        left: left,
      );
      canvas.restore();
      return;
    }
    super.paint(
      canvas,
      rect,
      textDirection: textDirection,
      shape: shape,
      borderRadius: borderRadius,
    );
  }
}

/// {@template FinesseBorder}
/// A wrapper around the [Border] class with a reasonable merge.
/// {@endtemplate}
@immutable
class FinesseBorder {
  /// {@macro FinesseBorder}
  const FinesseBorder({
    this.canMerge = true,
    this.padding,
    this.radius,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.offset,
  });

  /// Creates a border whose sides are all the same.
  const FinesseBorder.fromBorderSide(
    FinesseBorderSide side, {
    this.canMerge = true,
    this.padding,
    this.radius,
    this.offset,
  }) : top = side,
       right = side,
       bottom = side,
       left = side;

  /// Creates a border with symmetrical vertical and horizontal sides.
  ///
  /// The `vertical` argument applies to the [left] and [right] sides, and the
  /// `horizontal` argument applies to the [top] and [bottom] sides.
  const FinesseBorder.symmetric({
    FinesseBorderSide? vertical,
    FinesseBorderSide? horizontal,
    this.canMerge = true,
    this.padding,
    this.radius,
    this.offset,
  }) : left = vertical,
       top = horizontal,
       right = vertical,
       bottom = horizontal;

  /// A uniform border with all sides the same color and width.
  ///
  /// The sides default to black solid borders, one logical pixel wide.
  factory FinesseBorder.all({
    bool canMerge = true,
    Color? color,
    double? width,
    BorderStyle? style,
    double? strokeAlign,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? radius,
    double? offset,
  }) {
    final side = FinesseBorderSide(
      color: color,
      width: width,
      style: style,
      strokeAlign: strokeAlign,
    );
    return FinesseBorder.fromBorderSide(
      side,
      padding: padding,
      canMerge: canMerge,
      radius: radius,
      offset: offset,
    );
  }

  /// Interpolates between two borders.
  ///
  /// The [canMerge] value comes from [b] when it is not null.
  static FinesseBorder? lerp(FinesseBorder? a, FinesseBorder? b, double t) {
    if (identical(a, b)) return a;
    return FinesseBorder(
      canMerge: b?.canMerge ?? a?.canMerge ?? true,
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      radius: BorderRadiusGeometry.lerp(a?.radius, b?.radius, t),
      top: FinesseBorderSide.lerp(
        a?.top,
        b?.top,
        t,
      ),
      right: FinesseBorderSide.lerp(
        a?.right,
        b?.right,
        t,
      ),
      bottom: FinesseBorderSide.lerp(
        a?.bottom,
        b?.bottom,
        t,
      ),
      left: FinesseBorderSide.lerp(
        a?.left,
        b?.left,
        t,
      ),
      offset: lerpDouble(a?.offset, b?.offset, t),
    );
  }

  /// Whether any side has a width other than zero.
  bool get hasBorder =>
      (top?.width ?? 0) != 0 ||
      (right?.width ?? 0) != 0 ||
      (bottom?.width ?? 0) != 0 ||
      (left?.width ?? 0) != 0;

  /// A border with no sides that replaces any border it is merged into.
  static const FinesseBorder none = FinesseBorder(canMerge: false);

  /// Creates a [FinesseBorder] that represents the addition of the two given
  /// [FinesseBorder]s.
  FinesseBorder merge(FinesseBorder? other) {
    if (other == null) return this;
    if (!other.canMerge) return other;
    if (other is FinesseRoundedSuperellipseBorder) {
      return FinesseRoundedSuperellipseBorder(
        side: switch (this) {
          final FinesseRoundedSuperellipseBorder border =>
            border.side?.merge(other.side) ?? other.side,
          _ => other.side,
        },
        radius: other.radius ?? radius,
      );
    }
    return copyWith(
      // The merged result is always mergeable again: [other] opted into the
      // merge (checked above), so the combination stays open to further
      // overrides regardless of this border's own [canMerge].
      canMerge: true,
      top: top?.merge(other.top) ?? other.top,
      right: right?.merge(other.right) ?? other.right,
      bottom: bottom?.merge(other.bottom) ?? other.bottom,
      left: left?.merge(other.left) ?? other.left,
      padding: other.padding,
      radius: other.radius,
      offset: other.offset,
    );
  }

  /// Returns a copy with the given fields replaced.
  FinesseBorder copyWith({
    bool? canMerge,
    EdgeInsetsGeometry? padding,
    FinesseBorderSide? top,
    FinesseBorderSide? right,
    FinesseBorderSide? bottom,
    FinesseBorderSide? left,
    BorderRadiusGeometry? radius,
    double? offset,
  }) {
    return FinesseBorder(
      canMerge: canMerge ?? this.canMerge,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      padding: padding ?? this.padding,
      radius: radius ?? this.radius,
      offset: offset ?? this.offset,
    );
  }

  /// Whether to merge with another border, defaults to true.
  final bool canMerge;

  /// The padding of the border, defaults to null.
  final EdgeInsetsGeometry? padding;

  /// The border radius of the border, defaults to null.
  final BorderRadiusGeometry? radius;

  /// The top side of this border.
  final FinesseBorderSide? top;

  /// The right side of this border.
  final FinesseBorderSide? right;

  /// The bottom side of this border.
  final FinesseBorderSide? bottom;

  /// The left side of this border.
  final FinesseBorderSide? left;

  /// The offset between the border and the widget.
  ///
  /// NOTE: This is supported only by the secondaryBorder, because the border is
  /// drawn outward of the widget.
  final double? offset;

  @override
  String toString() {
    return '''FinesseBorder(canMerge: $canMerge, padding: $padding, radius: $radius, top: $top, right: $right, bottom: $bottom, left: $left, offset: $offset)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // Guards against a base [FinesseBorder] comparing equal to a subclass
    // instance, keeping `==` symmetric with [FinesseRoundedSuperellipseBorder].
    if (other.runtimeType != runtimeType) return false;
    return other is FinesseBorder &&
        other.canMerge == canMerge &&
        other.padding == padding &&
        other.radius == radius &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom &&
        other.left == left &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
    canMerge,
    padding,
    radius,
    top,
    right,
    bottom,
    left,
    offset,
  );
}

/// Creates the side of a border.
@immutable
class FinesseBorderSide with Diagnosticable {
  /// Creates the side of a border.
  const FinesseBorderSide({
    this.canMerge = true,
    this.color,
    this.width,
    this.style,
    this.strokeAlign,
  }) : assert(width == null || width >= 0.0);

  /// Merges two border sides into one
  FinesseBorderSide merge(FinesseBorderSide? other) {
    if (other == null) return this;
    if (!other.canMerge) return other;
    return copyWith(
      color: other.color,
      width: other.width,
      style: other.style,
      strokeAlign: other.strokeAlign,
    );
  }

  /// Whether to merge the border side
  final bool canMerge;

  /// The color of this side of the border.
  final Color? color;

  /// The width of this side of the border, in logical pixels.
  ///
  /// Setting width to 0.0 will result in a hairline border. This means that
  /// the border will have the width of one physical pixel. Hairline
  /// rendering takes shortcuts when the path overlaps a pixel more than once.
  /// This means that it will render faster than otherwise, but it might
  /// double-hit pixels, giving it a slightly darker/lighter result.
  final double? width;

  /// The style of this side of the border.
  final BorderStyle? style;

  /// A hairline black border that is not rendered.
  static const FinesseBorderSide none = FinesseBorderSide(canMerge: false);

  /// The relative position of the stroke on a [FinesseBorderSide] in an
  /// [OutlinedBorder] or [Border].
  ///
  /// Values typically range from -1.0 ([BorderSide.strokeAlignInside], inside
  /// border, default) to 1.0 ([BorderSide.strokeAlignOutside], outside border),
  /// without any bound constraints (e.g., a value of -2.0 is not typical, but
  /// allowed).
  /// A value of 0 ([BorderSide.strokeAlignCenter]) will center the border on
  /// the edge of the widget.
  ///
  /// When set to [BorderSide.strokeAlignInside], the stroke is drawn completely
  /// inside
  /// the widget. For [BorderSide.strokeAlignCenter] and
  /// [BorderSide.strokeAlignOutside], a property
  /// such as [Container.clipBehavior] can be used in an outside widget to clip
  /// it. If [Container.decoration] has a border, the container may incorporate
  /// [width] as additional padding:
  /// - [BorderSide.strokeAlignInside] provides padding with full [width].
  /// - [BorderSide.strokeAlignCenter] provides padding with half [width].
  /// - [BorderSide.strokeAlignOutside] provides zero padding, as stroke is
  /// drawn entirely outside.
  ///
  /// This property is not honored by toPaint (because the [Paint] object
  /// cannot represent it); it is intended that classes that use
  /// [FinesseBorderSide] objects implement this property when painting borders by
  /// suitably inflating or deflating their regions.
  final double? strokeAlign;

  /// Creates a copy of this border but with the given fields replaced with the
  /// new values.
  FinesseBorderSide copyWith({
    bool? canMerge,
    Color? color,
    double? width,
    BorderStyle? style,
    double? strokeAlign,
  }) {
    return FinesseBorderSide(
      canMerge: canMerge ?? this.canMerge,
      color: color ?? this.color,
      width: width ?? this.width,
      style: style ?? this.style,
      strokeAlign: strokeAlign ?? this.strokeAlign,
    );
  }

  /// Interpolates between two border sides.
  ///
  /// The style switches from [a] to [b] at the midpoint.
  static FinesseBorderSide? lerp(
    FinesseBorderSide? a,
    FinesseBorderSide? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return FinesseBorderSide(
      canMerge: b?.canMerge ?? a?.canMerge ?? true,
      color: Color.lerp(a?.color, b?.color, t),
      width: lerpDouble(a?.width, b?.width, t),
      style: t < 0.5 ? a?.style : b?.style,
      strokeAlign: lerpDouble(a?.strokeAlign, b?.strokeAlign, t),
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
    return other is FinesseBorderSide &&
        other.canMerge == canMerge &&
        other.color == color &&
        other.width == width &&
        other.style == style &&
        other.strokeAlign == strokeAlign;
  }

  @override
  int get hashCode => Object.hash(canMerge, color, width, style, strokeAlign);

  @override
  String toStringShort() => 'FinesseBorderSide';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<Color>(
          'color',
          color,
          defaultValue: const Color(0xFF000000),
        ),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'canMerge',
          canMerge,
          defaultValue: true,
        ),
      );

    // ignore: cascade_invocations
    properties
      ..add(DoubleProperty('width', width, defaultValue: 1.0))
      ..add(
        DoubleProperty(
          'strokeAlign',
          strokeAlign,
          defaultValue: BorderSide.strokeAlignInside,
        ),
      )
      ..add(
        EnumProperty<BorderStyle>(
          'style',
          style,
          defaultValue: BorderStyle.solid,
        ),
      );
  }
}

/// Converts a [FinesseRoundedSuperellipseBorder] to a Flutter [ShapeBorder].
extension RoundedSuperellipseBorderExt on FinesseRoundedSuperellipseBorder {
  /// Returns a [RoundedSuperellipseBorder] with the side and radius of this
  /// border.
  ///
  /// [textDirection] resolves a directional radius and defaults to
  /// [TextDirection.ltr]. [defaultRadius] is used when [radius] is null.
  ShapeBorder toBorder({
    TextDirection? textDirection,
    BorderRadius defaultRadius = BorderRadius.zero,
  }) {
    final effectiveTextDirection = textDirection ?? TextDirection.ltr;
    return RoundedSuperellipseBorder(
      side: side?.toBorderSide() ?? BorderSide.none,
      borderRadius: radius?.resolve(effectiveTextDirection) ?? defaultRadius,
    );
  }
}

/// A rectangular border with rounded corners following the shape of an
/// [RSuperellipse].
@immutable
class FinesseRoundedSuperellipseBorder extends FinesseBorder {
  /// Creates a superellipse border with [side] on every edge.
  const FinesseRoundedSuperellipseBorder({
    super.canMerge,
    this.side,
    super.radius,
  });

  /// The side drawn on every edge.
  final FinesseBorderSide? side;

  @override
  String toString() {
    return '''FinesseRoundedSuperellipseBorder(canMerge: $canMerge, side: $side, radius: $radius)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FinesseRoundedSuperellipseBorder &&
        other.canMerge == canMerge &&
        other.side == side &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(canMerge, side, radius);
}
