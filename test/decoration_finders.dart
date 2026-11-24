import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Looks through the [ShadowDecoration] that carries a component's outer
/// shadows to the [BoxDecoration] underneath.
///
/// Finesse paints outer shadows on a wrapper rather than on the decoration
/// itself, so that they can be clipped to the element's own outline the way
/// CSS clips a `box-shadow`. A test reaching for a fill, border or radius
/// wants the wrapped decoration; one reaching for shadows wants
/// [shadowsOf].
BoxDecoration? boxDecorationOf(Decoration? decoration) {
  return switch (decoration) {
    ShadowDecoration(:final decoration) => decoration as BoxDecoration?,
    final BoxDecoration decoration => decoration,
    _ => null,
  };
}

/// The outer shadows a component paints, wherever they are carried.
List<BoxShadow>? shadowsOf(Decoration? decoration) {
  return switch (decoration) {
    ShadowDecoration(:final shadows) => shadows.isEmpty ? null : shadows,
    BoxDecoration(:final boxShadow) => boxShadow,
    _ => null,
  };
}
