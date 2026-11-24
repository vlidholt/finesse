import 'package:flutter/widgets.dart';

/// Named steps on a corner-radius scale, mirroring Tailwind's `rounded-*`
/// utilities as shadcn/ui uses them.
///
/// Components pick a *token* rather than a number, so a single theme radius
/// drives the whole set consistently: cards stay proportionally rounder than
/// buttons, menu items proportionally tighter, and changing the theme radius
/// moves all of them together.
enum RadiusToken {
  /// No rounding, `rounded-none`.
  none,

  /// `rounded-sm`: 0.75 × `md`, 6px by default.
  sm,

  /// The base step. `ThemeData.radius` is this one — it is what buttons,
  /// inputs and popovers use.
  md,

  /// `rounded-lg`: 1.25 × `md`, 10px by default.
  lg,

  /// `rounded-xl`: 1.75 × `md`, 14px by default.
  xl,

  /// `rounded-2xl`: 2 × `md`, 16px by default.
  xl2,

  /// `rounded-3xl`: 3 × `md`, 24px by default.
  xl3,

  /// `rounded-4xl`: 4 × `md`, 32px by default.
  xl4,

  /// Fully rounded, for pills and circles.
  full,
}

/// The factors that turn a theme's base (`md`) radius into the rest of the
/// [RadiusToken] scale.
///
/// The default is Tailwind's: 0.75, 1.25, 1.75, 2, 3 and 4 times the base. A
/// style with its own rhythm supplies its own; Finesse's default style uses
/// `RadiusScale(sm: .6, lg: 1.2, xl: 1.6, xl2: 1.8, xl3: 2, xl4: 2.4)`, which
/// at a base of 10 gives 6, 12, 16, 18, 20 and 24.
@immutable
class RadiusScale {
  /// Creates a scale from the factor of each step above and below `md`.
  const RadiusScale({
    this.sm = .75,
    this.lg = 1.25,
    this.xl = 1.75,
    this.xl2 = 2,
    this.xl3 = 3,
    this.xl4 = 4,
  });

  /// The factor of [RadiusToken.sm].
  final double sm;

  /// The factor of [RadiusToken.lg].
  final double lg;

  /// The factor of [RadiusToken.xl].
  final double xl;

  /// The factor of [RadiusToken.xl2].
  final double xl2;

  /// The factor of [RadiusToken.xl3].
  final double xl3;

  /// The factor of [RadiusToken.xl4].
  final double xl4;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RadiusScale &&
          other.sm == sm &&
          other.lg == lg &&
          other.xl == xl &&
          other.xl2 == xl2 &&
          other.xl3 == xl3 &&
          other.xl4 == xl4);

  @override
  int get hashCode => Object.hash(sm, lg, xl, xl2, xl3, xl4);

  @override
  String toString() =>
      'RadiusScale(sm: $sm, lg: $lg, xl: $xl, xl2: $xl2, xl3: $xl3, xl4: $xl4)';
}

/// A corner-radius scale derived from one base radius.
///
/// shadcn/ui defines its scale relative to a single `--radius` custom
/// property:
///
/// ```css
/// --radius-sm: calc(var(--radius) * 0.6);
/// --radius-md: calc(var(--radius) * 0.8);
/// --radius-lg: var(--radius);
/// --radius-xl: calc(var(--radius) * 1.4);
/// ```
///
/// This package's `ThemeData.radius` is the *component* radius — the
/// `rounded-md` step, since that is what button and input use — so the
/// multipliers here are expressed relative to `md`. With an 8px base and the
/// default [RadiusScale] that reproduces shadcn's scale exactly: sm 6, md 8,
/// lg 10, xl 14, 2xl 16, 3xl 24, 4xl 32. A style can supply its own [scale].
@immutable
class Radii {
  /// Creates a scale from the base (`md`) radius.
  const Radii(this.md, [this.scale = const RadiusScale()]);

  /// The `md` step, i.e. the theme's component radius.
  final BorderRadius md;

  /// The factors the other steps are derived from [md] with.
  final RadiusScale scale;

  /// Square corners, `rounded-none`.
  BorderRadius get none => BorderRadius.zero;

  /// `rounded-sm`: 0.75 × [md], 6px by default.
  BorderRadius get sm => _scale(scale.sm);

  /// `rounded-lg`: 1.25 × [md], 10px by default.
  BorderRadius get lg => _scale(scale.lg);

  /// `rounded-xl`: 1.75 × [md], 14px by default.
  BorderRadius get xl => _scale(scale.xl);

  /// `rounded-2xl`: 2 × [md], 16px by default.
  BorderRadius get xl2 => _scale(scale.xl2);

  /// `rounded-3xl`: 3 × [md], 24px by default.
  BorderRadius get xl3 => _scale(scale.xl3);

  /// `rounded-4xl`: 4 × [md], 32px by default.
  BorderRadius get xl4 => _scale(scale.xl4);

  /// Fully rounded, `rounded-full`, for pills and circles.
  BorderRadius get full => const BorderRadius.all(Radius.circular(9999));

  /// The radius for [token].
  BorderRadius resolve(RadiusToken token) => switch (token) {
    RadiusToken.none => none,
    RadiusToken.sm => sm,
    RadiusToken.md => md,
    RadiusToken.lg => lg,
    RadiusToken.xl => xl,
    RadiusToken.xl2 => xl2,
    RadiusToken.xl3 => xl3,
    RadiusToken.xl4 => xl4,
    RadiusToken.full => full,
  };

  BorderRadius _scale(double factor) => BorderRadius.only(
    topLeft: _scaleRadius(md.topLeft, factor),
    topRight: _scaleRadius(md.topRight, factor),
    bottomLeft: _scaleRadius(md.bottomLeft, factor),
    bottomRight: _scaleRadius(md.bottomRight, factor),
  );

  static Radius _scaleRadius(Radius radius, double factor) =>
      Radius.elliptical(radius.x * factor, radius.y * factor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Radii && other.md == md && other.scale == scale);

  @override
  int get hashCode => Object.hash(md, scale);

  @override
  String toString() => 'Radii(md: $md)';
}
