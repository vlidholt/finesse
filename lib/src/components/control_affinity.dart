import 'package:flutter/widgets.dart';

/// Which side of its label a `Checkbox`, a `Radio` or a `Switch` sits on,
/// and which side of its row the control of a `SwitchListTile`, a
/// `CheckboxListTile` or a `RadioListTile`.
enum ControlAffinity {
  /// The control comes first and the label follows it: on the left where
  /// text runs left to right.
  leading,

  /// The label comes first and the control follows it.
  trailing,
}

/// Lays out a control beside its label and description, on the side
/// [affinity] names.
///
/// Internal to the package: the row `Checkbox`, `Radio` and `Switch` share.
class ControlLabelRow extends StatelessWidget {
  /// Creates the row of a labelled control.
  const ControlLabelRow({
    required this.control,
    required this.affinity,
    required this.labelPadding,
    required this.crossAxisAlignment,
    this.label,
    super.key,
  });

  /// The checkbox, radio or switch.
  final Widget control;

  /// The label and description, already styled; null for a bare control.
  final Widget? label;

  /// The side the control is on.
  final ControlAffinity affinity;

  /// The padding around [label], written for a leading control: its start
  /// is the gap to the control. It is mirrored for a trailing one.
  final EdgeInsetsGeometry labelPadding;

  /// How the control and the label line up across the row.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label == null) return control;
    final direction = Directionality.of(context);
    final leading = affinity == ControlAffinity.leading;
    final padding = labelPadding.resolve(direction);
    final text = Flexible(
      child: Padding(
        // The gap stays between the label and the control.
        padding: leading
            ? padding
            : padding.copyWith(left: padding.right, right: padding.left),
        child: label,
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: leading ? [control, text] : [text, control],
    );
  }
}
