import 'package:flutter/widgets.dart';

/// Reads a [Provider] value without a dependency on it.
extension ProviderReadExt on BuildContext {
  /// Returns the value of the nearest `Provider<T>`. Throws when there is
  /// none. Does not rebuild the caller when the value changes.
  T read<T>() => Provider.of<T>(this, listen: false);

  /// Returns the value of the nearest `Provider<T>`, or null when there is
  /// none. Does not rebuild the caller when the value changes.
  T? maybeRead<T>() => Provider.maybeOf<T>(this, listen: false);
}

/// Reads a [Provider] value and depends on it.
extension ProviderWatchExt on BuildContext {
  /// Returns the value of the nearest `Provider<T>`. Throws when there is
  /// none. Rebuilds the caller when the provider notifies.
  T watch<T>() => Provider.of<T>(this);

  /// Returns the value of the nearest `Provider<T>`, or null when there is
  /// none. Rebuilds the caller when the provider notifies.
  T? maybeWatch<T>() => Provider.maybeOf<T>(this);
}

/// Provides a value of type [T] to its descendants.
///
/// Read it with `context.read<T>()` or `context.watch<T>()`. Dependents
/// rebuild only when [notifyUpdate] returns true.
class Provider<T> extends InheritedWidget {
  /// Creates a provider of [data].
  const Provider({
    super.key,
    required super.child,
    required this.data,
    this.notifyUpdate,
  });

  /// The data to be provided
  final T data;

  /// Whether to notify the update of the provider, defaults to false
  final bool Function(Provider<T> oldWidget)? notifyUpdate;

  /// Returns the value of the nearest `Provider<T>`.
  ///
  /// Throws a [FlutterError] when there is none. When [listen] is true, the
  /// default, [context] depends on the provider.
  static T of<T>(BuildContext context, {bool listen = true}) {
    final inherited = maybeOf<T>(context, listen: listen);
    if (inherited == null) {
      throw FlutterError(
        'Could not find $T InheritedWidget in the ancestor widget tree.',
      );
    }
    return inherited;
  }

  /// Returns the value of the nearest `Provider<T>`, or null when there is
  /// none.
  ///
  /// When [listen] is true, the default, [context] depends on the provider.
  static T? maybeOf<T>(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<Provider<T>>()?.data;
    }
    final provider = context
        .getElementForInheritedWidgetOfExactType<Provider<T>>()
        ?.widget;
    return (provider as Provider<T>?)?.data;
  }

  @override
  bool updateShouldNotify(covariant Provider<T> oldWidget) {
    return notifyUpdate?.call(oldWidget) ?? false;
  }
}
