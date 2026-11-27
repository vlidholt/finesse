import 'package:flutter/widgets.dart';

/// What a control built around a `TextField` adds to the field's own
/// semantics node: whether the list it opens is showing.
///
/// A text field's node does not merge with a `Semantics` around it, and a
/// `MergeSemantics` around the field would swallow its clear button, so a
/// combobox (`Autocomplete`, `TagField`) says it this way and the field
/// puts it in its node.
///
/// Internal: not exported.
class FieldSemantics extends InheritedWidget {
  /// Adds [expanded] to the node of the `TextField` in [child].
  const FieldSemantics({
    required this.expanded,
    required super.child,
    super.key,
  });

  /// Whether the list the field opens is showing; null when it has none.
  final bool? expanded;

  /// The nearest [FieldSemantics] around [context], or null.
  static FieldSemantics? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FieldSemantics>();

  @override
  bool updateShouldNotify(FieldSemantics oldWidget) =>
      expanded != oldWidget.expanded;
}
