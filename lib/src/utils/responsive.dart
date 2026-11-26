import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:una/src/theme/theme.dart';

/// The screen widths at which the layout changes, as in Tailwind CSS.
///
/// Read the current set from the `breakpoints` of [Theme], and the
/// current breakpoint with [ResponsiveBuilder].
@immutable
class Breakpoints {
  /// Creates breakpoints from minimum widths in logical pixels.
  ///
  /// The defaults are the Tailwind CSS values: [sm] 640, [md] 768, [lg] 1024,
  /// [xl] 1280 and [xxl] 1536. [tn] starts at 0.
  Breakpoints({
    double tn = 0,
    double sm = 640,
    double md = 768,
    double lg = 1024,
    double xl = 1280,
    double xxl = 1536,
  }) : tn = BreakpointTN(tn),
       sm = BreakpointSM(sm),
       md = BreakpointMD(md),
       lg = BreakpointLG(lg),
       xl = BreakpointXL(xl),
       xxl = BreakpointXXL(xxl);

  /// The tiny breakpoint, for widths below [sm]. Starts at 0 by default.
  final Breakpoint tn;

  /// The small breakpoint. Starts at 640 by default.
  final Breakpoint sm;

  /// The medium breakpoint. Starts at 768 by default.
  final Breakpoint md;

  /// The large breakpoint. Starts at 1024 by default.
  final Breakpoint lg;

  /// The extra-large breakpoint. Starts at 1280 by default.
  final Breakpoint xl;

  /// The 2xl breakpoint. Starts at 1536 by default.
  final Breakpoint xxl;

  /// Returns the largest breakpoint whose minimum width is not more than
  /// [width].
  Breakpoint fromWidth(double width) {
    if (width < sm.value) return tn;
    if (width < md.value) return sm;
    if (width < lg.value) return md;
    if (width < xl.value) return lg;
    if (width < xxl.value) return xl;
    return xxl;
  }

  /// Interpolates between two sets of breakpoints.
  ///
  /// Both [a] and [b] must be non-null.
  static Breakpoints? lerp(
    Breakpoints? a,
    Breakpoints? b,
    double t,
  ) {
    if (a == null || b == null) return t < .5 ? a : b;
    return Breakpoints(
      tn: Breakpoint.lerp(a.tn, b.tn, t),
      sm: Breakpoint.lerp(a.sm, b.sm, t),
      md: Breakpoint.lerp(a.md, b.md, t),
      lg: Breakpoint.lerp(a.lg, b.lg, t),
      xl: Breakpoint.lerp(a.xl, b.xl, t),
      xxl: Breakpoint.lerp(a.xxl, b.xxl, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Breakpoints &&
        other.tn == tn &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl;
  }

  @override
  int get hashCode => Object.hash(tn, sm, md, lg, xl, xxl);
}

/// A named minimum screen width.
///
/// Compare breakpoints with the `<`, `>`, `<=` and `>=` operators, which
/// compare their [value]s.
@immutable
sealed class Breakpoint {
  const Breakpoint(this.value);

  /// The minimum width of the breakpoint, in logical pixels.
  final double value;

  /// Whether this breakpoint starts at a smaller width than [other].
  bool operator <(Breakpoint other) {
    return value < other.value;
  }

  /// Whether this breakpoint starts at a larger width than [other].
  bool operator >(Breakpoint other) {
    return value > other.value;
  }

  /// Whether this breakpoint starts at or below the width of [other].
  bool operator <=(Breakpoint other) {
    return value <= other.value;
  }

  /// Whether this breakpoint starts at or above the width of [other].
  bool operator >=(Breakpoint other) {
    return value >= other.value;
  }

  /// Interpolates between the values of two breakpoints.
  static double lerp(Breakpoint a, Breakpoint b, double t) {
    return lerpDouble(a.value, b.value, t)!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // The subclasses add no fields, so comparing [runtimeType] and [value] is
    // enough to keep e.g. `BreakpointSM(0) != BreakpointMD(0)`.
    return other is Breakpoint &&
        other.runtimeType == runtimeType &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// The tiny breakpoint. See [Breakpoints.tn].
class BreakpointTN extends Breakpoint {
  /// Creates a tiny breakpoint that starts at [value].
  const BreakpointTN(super.value);
}

/// The small breakpoint. See [Breakpoints.sm].
class BreakpointSM extends Breakpoint {
  /// Creates a small breakpoint that starts at [value].
  const BreakpointSM(super.value);
}

/// The medium breakpoint. See [Breakpoints.md].
class BreakpointMD extends Breakpoint {
  /// Creates a medium breakpoint that starts at [value].
  const BreakpointMD(super.value);
}

/// The large breakpoint. See [Breakpoints.lg].
class BreakpointLG extends Breakpoint {
  /// Creates a large breakpoint that starts at [value].
  const BreakpointLG(super.value);
}

/// The extra-large breakpoint. See [Breakpoints.xl].
class BreakpointXL extends Breakpoint {
  /// Creates an extra-large breakpoint that starts at [value].
  const BreakpointXL(super.value);
}

/// The 2xl breakpoint. See [Breakpoints.xxl].
class BreakpointXXL extends Breakpoint {
  /// Creates a 2xl breakpoint that starts at [value].
  const BreakpointXXL(super.value);
}

/// Builds a widget for the current [Breakpoint].
typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  Breakpoint breakpoint,
);

/// Builds its child for the breakpoint that matches the screen width.
///
/// The width comes from [MediaQuery], so the builder runs again when the
/// screen size changes. The breakpoints come from the theme.
class ResponsiveBuilder extends StatelessWidget {
  /// Creates a builder that calls [builder] with the current breakpoint.
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  /// Builds the child for the current breakpoint.
  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final breakpoints = Theme.of(context).breakpoints;
    final breakpoint = breakpoints.fromWidth(width);
    return builder(context, breakpoint);
  }
}
