import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// The semantics of a progress indicator, `ProgressBar`, `ProgressRing` or
/// `Spinner`: one node, a progress bar from 0 to 100 while the progress is
/// known and a loading spinner while it is not.
///
/// [value] is what is read for a known progress. A progress bar's value has
/// to be a number or a percentage (Flutter checks), so a caller's own text —
/// "3 of 10" — keeps the node but not the role.
Widget progressSemantics({
  required bool determinate,
  required String? label,
  required String? value,
  required Widget child,
  bool liveRegion = false,
}) {
  final bar = determinate && value != null && _isPercentOrNumber(value);
  return Semantics(
    container: true,
    role: bar
        ? SemanticsRole.progressBar
        : determinate
        ? null
        : SemanticsRole.loadingSpinner,
    label: label,
    value: value,
    minValue: bar ? '0' : null,
    maxValue: bar ? '100' : null,
    liveRegion: liveRegion,
    child: child,
  );
}

bool _isPercentOrNumber(String value) =>
    double.tryParse(
      value.endsWith('%') ? value.substring(0, value.length - 1) : value,
    ) !=
    null;
