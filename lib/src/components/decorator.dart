import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';

/// Paints a [FinesseDecoration] around [child].
///
/// Picks the normal, focused or error form of each border from [focused] and
/// `decoration.hasError`, and merges [decoration] over
/// `ThemeData.decoration`.
class Decorator extends StatelessWidget {
  /// Creates a decorator.
  const Decorator({
    super.key,
    this.child,
    this.decoration,
    this.focused = false,
  });

  /// The child to decorate.
  final Widget? child;

  /// The decoration to apply to the child.
  final FinesseDecoration? decoration;

  /// Whether the child has focus, defaults to false.
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);

    final effectiveDecoration = theme.decoration.merge(decoration);

    final effectiveFallbackToBorder =
        effectiveDecoration.fallbackToBorder ?? true;

    final effectiveDisableSecondaryBorder =
        effectiveDecoration.disableSecondaryBorder ??
        theme.disableSecondaryBorder;

    final hasError = effectiveDecoration.hasError ?? false;

    final fallbackBorder = switch (focused) {
      true => effectiveDecoration.focusedBorder,
      false => effectiveDecoration.border,
    };

    var border = switch (hasError) {
      true => effectiveDecoration.errorBorder,
      false => fallbackBorder,
    };

    if (effectiveFallbackToBorder && border == null) {
      border = fallbackBorder ?? effectiveDecoration.border;
    }

    final fallbackSecondaryBorder = switch (focused) {
      true => effectiveDecoration.secondaryFocusedBorder,
      false => effectiveDecoration.secondaryBorder,
    };

    var secondaryBorder = switch (hasError) {
      true => effectiveDecoration.secondaryErrorBorder,
      false => fallbackSecondaryBorder,
    };

    if (effectiveFallbackToBorder && secondaryBorder == null) {
      secondaryBorder =
          fallbackSecondaryBorder ?? effectiveDecoration.secondaryBorder;
    }

    // The shadows go on the wrapper rather than the decoration itself so they
    // are clipped to the control's own outline; see [ShadowDecoration].
    final primaryDecoration = ShadowDecoration(
      shadows: effectiveDecoration.shadows ?? const [],
      decoration: switch (border) {
        final FinesseRoundedSuperellipseBorder border => ShapeDecoration(
          color: effectiveDecoration.color,
          image: effectiveDecoration.image,
          gradient: effectiveDecoration.gradient,
          shape: border.toBorder(
            textDirection: textDirection,
            defaultBorderRadius: theme.radius,
          ),
        ),
        final FinesseBorder? border => BoxDecoration(
          border: true == border?.hasBorder ? border?.toBorder() : null,
          borderRadius: effectiveDecoration.shape == BoxShape.circle
              ? null
              : border?.borderRadius,
          color: effectiveDecoration.color,
          shape: effectiveDecoration.shape ?? BoxShape.rectangle,
          backgroundBlendMode: effectiveDecoration.backgroundBlendMode,
          gradient: effectiveDecoration.gradient,
          image: effectiveDecoration.image,
        ),
      },
    );

    Widget decorated = Container(
      decoration: primaryDecoration,
      padding: border?.padding,
      child: child,
    );

    if (secondaryBorder != null && !effectiveDisableSecondaryBorder) {
      decorated = Padding(
        padding: secondaryBorder.padding ?? EdgeInsets.zero,
        child: CustomPaint(
          foregroundPainter: OutwardBorderPainter(
            border: secondaryBorder.toBorder(),
            offset: secondaryBorder.offset ?? 0,
            radius:
                secondaryBorder.borderRadius?.resolve(textDirection) ??
                BorderRadius.zero,
            textDirection: textDirection,
          ),
          child: decorated,
        ),
      );
    }

    return decorated;
  }
}

/// {@template outwardBorderPainter}
/// A [CustomPainter] that paints a border outward from the given rectangle.
/// {@endtemplate}
class OutwardBorderPainter extends CustomPainter {
  /// {@macro outwardBorderPainter}
  const OutwardBorderPainter({
    required this.border,
    required this.offset,
    required this.radius,
    required this.textDirection,
  });

  /// The border to paint.
  final Border border;

  /// The offset to inflate the border by.
  final double offset;

  /// The radius of the border.
  final BorderRadius? radius;

  /// The text direction to use when painting the border.
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(
      canvas,
      (Offset.zero & size).inflate(offset),
      borderRadius: radius,
      textDirection: textDirection,
    );
  }

  @override
  bool shouldRepaint(covariant OutwardBorderPainter oldDelegate) {
    return border != oldDelegate.border ||
        offset != oldDelegate.offset ||
        radius != oldDelegate.radius ||
        textDirection != oldDelegate.textDirection;
  }
}
