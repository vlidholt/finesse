import 'package:finesse/src/theme/data.dart';
import 'package:flutter/widgets.dart';

/// Provides a [ThemeData] to its descendants.
///
/// `FinesseApp` inserts one. Use [Theme.merge] to override part of the theme
/// for a subtree.
class Theme extends StatelessWidget {
  /// Creates a widget that applies [data] to [child].
  const Theme({
    super.key,
    required this.data,
    required this.child,
  });

  /// The theme for descendant widgets.
  final ThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Returns the nearest [ThemeData].
  ///
  /// Throws a [FlutterError] when there is no [Theme] ancestor. When
  /// [listen] is true, [context] rebuilds when the theme changes.
  static ThemeData of(BuildContext context, {bool listen = true}) {
    final provider = maybeOf(context, listen: listen);
    if (provider == null) {
      throw FlutterError(
        '''
        Theme.of() called with a context that does not contain a Theme.\n
        No Theme ancestor could be found starting from the context that was passed to Theme.of(). 
        This can happen because you do not have a FinesseApp widget (which introduces a Theme), 
        or it can happen if the context you use comes from a widget above this widget.\n
        The context used was: $context''',
      );
    }
    return provider;
  }

  /// Creates a [ThemeData] that overrides the [ThemeData] in
  /// scope at this point in the widget tree.
  ///
  /// The given [data] is merged with the [data] from the default [Theme]
  /// for the [BuildContext] where the widget is inserted.
  static Widget merge({
    Key? key,
    ThemeData? data,
    required Widget child,
  }) {
    return Builder(
      key: key,
      builder: (BuildContext context) {
        final parent = Theme.of(context);
        return Theme(data: parent.merge(data), child: child);
      },
    );
  }

  /// Returns the nearest [ThemeData], or null when there is no [Theme]
  /// ancestor.
  ///
  /// When [listen] is true, [context] rebuilds when the theme changes.
  static ThemeData? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<FinesseInheritedTheme>()
          ?.theme
          .data;
    }
    final provider = context
        .getElementForInheritedWidgetOfExactType<FinesseInheritedTheme>()
        ?.widget;

    return (provider as FinesseInheritedTheme?)?.theme.data;
  }

  @override
  Widget build(BuildContext context) {
    return FinesseInheritedTheme(
      theme: this,
      child: child,
    );
  }
}

/// The inherited widget that [Theme] inserts.
///
/// It lets [InheritedTheme.capture] carry the theme into routes and overlays.
class FinesseInheritedTheme extends InheritedTheme {
  /// Creates an inherited theme for [theme].
  const FinesseInheritedTheme({
    super.key,
    required this.theme,
    required super.child,
  });

  /// The [Theme] that inserted this widget.
  final Theme theme;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return Theme(data: theme.data, child: child);
  }

  @override
  bool updateShouldNotify(FinesseInheritedTheme oldWidget) =>
      theme.data != oldWidget.theme.data;
}

/// An interpolation between two [ThemeData]s.
///
/// This class specializes the interpolation of [Tween<ThemeData>] to call
/// the [ThemeData.lerp] method.
///
/// See [Tween] for a discussion on how to use interpolation objects.
class ThemeDataTween extends Tween<ThemeData> {
  /// Creates a [ThemeData] tween.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  ThemeDataTween({super.begin, super.end});

  /// Whether [begin] and [end] are laid out for different form factors.
  bool get _changesFormFactor {
    final from = begin;
    final to = end;
    return from != null && to != null && from.formFactor != to.formFactor;
  }

  // Overridden as well as [lerp]: a [Tween] never calls `lerp` at either end
  // — at t == 0 it hands back [begin] — and an implicit animation's first
  // frame is t == 0. Checking in `lerp` alone therefore still built one
  // frame of the old form factor's layout in a window that was already the
  // new size, which is exactly the frame a desktop app bar overflows a
  // phone-width window on.
  @override
  ThemeData transform(double t) {
    if (_changesFormFactor) return end!;
    return super.transform(t);
  }

  @override
  ThemeData lerp(double t) {
    // Two form factors are two layouts, not the ends of a range: 40-point
    // buttons on the way from 36 to 44 belong to neither. Interpolating would
    // also keep the old layout's metrics on screen for half the transition
    // while the window is already the new size, which is when things
    // overflow. So a change of form factor takes effect at once.
    if (_changesFormFactor) return end!;
    return ThemeData.lerp(begin, end, t)!;
  }
}

/// Animated version of [Theme] which automatically transitions the colors
/// etc, over a given duration whenever the given theme changes.
class AnimatedTheme extends ImplicitlyAnimatedWidget {
  /// Creates an animated theme.
  ///
  /// By default, the theme transition uses a linear curve.
  const AnimatedTheme({
    super.key,
    required this.data,
    required this.child,
    super.curve,
    super.duration = const Duration(milliseconds: 200),
    super.onEnd,
  });

  /// Specifies the color and typography values for descendant widgets.
  final ThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedTheme> createState() => _AnimatedThemeState();
}

class _AnimatedThemeState extends AnimatedWidgetBaseState<AnimatedTheme> {
  ThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data =
        visitor(
              _data,
              widget.data,
              (dynamic value) => ThemeDataTween(begin: value as ThemeData),
            )!
            as ThemeDataTween;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }
}
