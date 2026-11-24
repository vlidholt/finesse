import 'package:finesse/src/utils/provider.dart';
import 'package:flutter/widgets.dart';

/// An immutable class that holds an [index].
///
/// Used by [IndexProvider] to provide the index to the child
/// widget.
@immutable
class ProviderIndex {
  /// Creates an index holder.
  const ProviderIndex(this.index);

  /// The index.
  final int index;
}

/// Provides an [index] to the [child] widget.
/// The child widget can access the index using
/// `context.watch<ProviderIndex>().index`.
class IndexProvider extends StatelessWidget {
  /// Creates a [IndexProvider].
  const IndexProvider({
    super.key,
    required this.index,
    required this.child,
  });

  /// The index to provide.
  final int index;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Provider(
      data: ProviderIndex(index),
      notifyUpdate: (oldWidget) => oldWidget.data.index != index,
      child: child,
    );
  }
}
