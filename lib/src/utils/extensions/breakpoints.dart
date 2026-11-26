import 'package:flutter/widgets.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/responsive.dart';

/// Reads the current [Breakpoint] from a [BuildContext].
extension BreakpointsExt on BuildContext {
  /// The breakpoint that matches the screen width, from the breakpoints of the
  /// current [Theme].
  ///
  /// Rebuilds the caller when the screen size or the theme changes.
  Breakpoint get breakpoint {
    final width = MediaQuery.sizeOf(this).width;
    final breakpoints = Theme.of(this).breakpoints;
    return breakpoints.fromWidth(width);
  }
}
