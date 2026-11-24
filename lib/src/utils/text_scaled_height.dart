import 'package:flutter/widgets.dart';

/// The tallest a control whose style gives it the fixed [height] may be at
/// the text scale of [context].
///
/// A style height (`h-9`) is the height at the platform's own text size.
/// The label inside is scaled by the user's setting and the box is not, so a
/// control held to its style height lays the label out in the room that is
/// left and cuts it off — a tab at 1.3×, a small button at 1.6×. A
/// fixed-height control therefore treats its height as a floor:
///
/// ```dart
/// ConstrainedBox(
///   constraints: BoxConstraints(
///     minHeight: height,
///     maxHeight: textScaledMaxHeight(context, height),
///   ),
///   child: …,
/// )
/// ```
///
/// At a scale of 1 or less the two are equal and the control is exactly as
/// tall as its style says, so the heights that line controls up on a row
/// are untouched. Above 1 the control may grow in proportion to its text,
/// which is always enough for a label that fitted unscaled, and it does so
/// only once its content needs the room — the same way a field, whose
/// height was always a minimum, behaves. A box that is a fixed size in
/// *both* directions around a glyph (an OTP slot) has no content to grow
/// from and multiplies its side by the scale instead.
double textScaledMaxHeight(BuildContext context, double height) {
  // Asked for a size of 1 rather than of the label: under a scaler that is
  // not linear the small sizes take the largest factor, and this is a
  // ceiling.
  final scale = MediaQuery.maybeTextScalerOf(context)?.scale(1) ?? 1;
  return scale > 1 ? height * scale : height;
}
