import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The look a bar gives the buttons in it: the [variant] a `Button` or
/// `IconButton` that names none takes, and a [style] merged under every
/// button's own (a capsule of glass rounds the buttons on it, so nothing
/// on it has to be clipped).
///
/// A bar knows what it is drawn on — its own surface, a photograph, a
/// capsule of Liquid Glass — and its buttons do not, so the bar decides
/// and an app writes `IconButton(icon: …, onPressed: …)` in a bar's slots.
/// An overlay opened from a button in a bar is built under the button, so
/// the portal puts [BarButtonScope.none] around it: a menu's buttons are
/// not the bar's.
@internal
class BarButtonScope extends InheritedWidget {
  /// Gives the buttons under [child] the bar's [variant] and [style].
  const BarButtonScope({
    required super.child,
    this.variant,
    this.style,
    super.key,
  });

  /// Gives the buttons under [child] no look of a bar's.
  const BarButtonScope.none({required super.child, super.key})
    : variant = null,
      style = null;

  /// The variant of a button that names none. Null leaves it primary.
  final ButtonVariant? variant;

  /// Merged under every button's own style.
  final ButtonTheme? style;

  /// The scope around [context], if any.
  static BarButtonScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BarButtonScope>();

  /// The variant a button under [context] takes when it is given [variant].
  static ButtonVariant variantOf(
    BuildContext context,
    ButtonVariant? variant, {
    ButtonVariant fallback = ButtonVariant.primary,
  }) => variant ?? maybeOf(context)?.variant ?? fallback;

  /// [style] with the scope's merged under it.
  static ButtonTheme? styleOf(BuildContext context, ButtonTheme? style) {
    final scope = maybeOf(context)?.style;
    if (scope == null) return style;
    return scope.merge(style);
  }

  @override
  bool updateShouldNotify(BarButtonScope oldWidget) =>
      variant != oldWidget.variant || style != oldWidget.style;
}
