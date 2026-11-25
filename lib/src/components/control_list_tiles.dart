import 'package:finesse/src/components/checkbox.dart';
import 'package:finesse/src/components/control_affinity.dart';
import 'package:finesse/src/components/list_tile.dart';
import 'package:finesse/src/components/switch.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:flutter/widgets.dart';

/// A row with a title and a switch: the whole row is the target.
///
/// ```dart
/// SwitchListTile(
///   title: const Text('Read receipts'),
///   subtitle: const Text('Let people see when you have read a message'),
///   value: receipts,
///   onChanged: (value) => setState(() => receipts = value),
/// )
/// ```
///
/// A tap anywhere on the row, or Enter or Space while it has the focus,
/// calls [onChanged] with the other value; the row itself holds no state.
/// The switch inside takes no focus of its own, and assistive technology
/// meets one control that carries the title as its label and the value as
/// its state.
///
/// Use it in a `ListSection`. A switch with an inline label, for a form, is
/// `Switch(label:)`.
class SwitchListTile extends StatelessWidget {
  /// Creates a row with a switch.
  const SwitchListTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.secondary,
    this.enabled = true,
    this.controlAffinity = ControlAffinity.trailing,
    this.subtitleMaxLines = 2,
    this.focusNode,
    super.key,
  });

  /// The row's first line, and the switch's name.
  final Widget title;

  /// The quieter line under the title.
  final Widget? subtitle;

  /// A widget on the side of the row the switch is not on, usually an icon.
  final Widget? secondary;

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value when the row is activated. Null switches the
  /// row off, like [enabled].
  final ValueChanged<bool>? onChanged;

  /// Whether the row responds.
  final bool enabled;

  /// Which side the switch is on.
  final ControlAffinity controlAffinity;

  /// The most lines the subtitle wraps to; null for no limit.
  final int? subtitleMaxLines;

  /// The focus node of the row.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null;
    return _ControlTile(
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      enabled: active,
      controlAffinity: controlAffinity,
      subtitleMaxLines: subtitleMaxLines,
      focusNode: focusNode,
      toggled: value,
      onTap: () => onChanged?.call(!value),
      control: Switch(
        value: value,
        enabled: active,
        // The row is the target; this only keeps the switch looking live.
        onChanged: active ? _ignore : null,
      ),
    );
  }

  static void _ignore(bool _) {}
}

/// A row with a title and a checkbox: the whole row is the target.
///
/// ```dart
/// CheckboxListTile(
///   title: const Text('Product updates'),
///   value: updates,
///   onChanged: (value) => setState(() => updates = value ?? false),
/// )
/// ```
///
/// With [tristate] the value may also be null, drawn as a dash and
/// announced as mixed — a "select all" row over a partly selected list. A
/// tap then goes from unchecked to checked to mixed and round again.
///
/// A tap anywhere on the row, or Enter or Space while it has the focus,
/// calls [onChanged]; the row itself holds no state. The checkbox inside
/// takes no focus of its own, and assistive technology meets one control
/// that carries the title as its label.
class CheckboxListTile extends StatelessWidget {
  /// Creates a row with a checkbox.
  const CheckboxListTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.secondary,
    this.enabled = true,
    this.tristate = false,
    this.controlAffinity = ControlAffinity.trailing,
    this.subtitleMaxLines = 2,
    this.focusNode,
    super.key,
  }) : assert(
         tristate || value != null,
         'A null value is the mixed state and needs tristate: true.',
       );

  /// The row's first line, and the checkbox's name.
  final Widget title;

  /// The quieter line under the title.
  final Widget? subtitle;

  /// A widget on the side of the row the checkbox is not on, usually an
  /// icon.
  final Widget? secondary;

  /// Whether the box is checked. Null, with [tristate], is the mixed state.
  final bool? value;

  /// Called with the new value when the row is activated. Null switches the
  /// row off, like [enabled]. The value is only ever null with [tristate].
  final ValueChanged<bool?>? onChanged;

  /// Whether the row responds.
  final bool enabled;

  /// Whether the box has a third, mixed state.
  final bool tristate;

  /// Which side the checkbox is on.
  final ControlAffinity controlAffinity;

  /// The most lines the subtitle wraps to; null for no limit.
  final int? subtitleMaxLines;

  /// The focus node of the row.
  final FocusNode? focusNode;

  bool? get _next => switch (value) {
    false => true,
    true => tristate ? null : false,
    null => false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = enabled && onChanged != null;
    final size = theme.checkboxTheme.size ?? 16;
    return _ControlTile(
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      enabled: active,
      controlAffinity: controlAffinity,
      subtitleMaxLines: subtitleMaxLines,
      focusNode: focusNode,
      checked: value ?? false,
      mixed: value == null,
      onTap: () => onChanged?.call(_next),
      control: Checkbox(
        // The mixed state is the checked box with a dash for its mark.
        value: value ?? true,
        enabled: active,
        onChanged: active ? _ignore : null,
        checkboxPadding: EdgeInsets.zero,
        icon: value == null
            ? PhosphorIcon(
                PhosphorIconsBold.minus,
                color: theme.colorScheme.primaryForeground,
                size: size - 4,
              )
            : null,
      ),
    );
  }

  static void _ignore(bool _) {}
}

/// A row with a title and a radio button: one choice of several, with the
/// whole row as the target.
///
/// ```dart
/// ListSection(
///   header: const Text('Who can message you'),
///   children: [
///     for (final audience in Audience.values)
///       RadioListTile<Audience>(
///         title: Text(audience.label),
///         value: audience,
///         groupValue: selected,
///         onChanged: (value) => setState(() => selected = value!),
///       ),
///   ],
/// )
/// ```
///
/// The row is selected when its [value] equals [groupValue]; activating it
/// calls [onChanged] with [value] (or with null, for a selected row that is
/// [toggleable]). The rows of one choice share a [groupValue] and hold no
/// state themselves, so they can be the rows of a `ListSection`, with its
/// hairlines between them.
///
/// The radio inside takes no focus of its own, and assistive technology
/// meets one control: the title, "radio button", and whether it is
/// selected. A radio with an inline label, for a form, is a `Radio` in a
/// `FinesseRadioGroup`.
class RadioListTile<T> extends StatelessWidget {
  /// Creates a row with a radio button.
  const RadioListTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
    this.secondary,
    this.enabled = true,
    this.toggleable = false,
    this.controlAffinity = ControlAffinity.trailing,
    this.subtitleMaxLines = 2,
    this.focusNode,
    super.key,
  });

  /// The row's first line, and the radio's name.
  final Widget title;

  /// The quieter line under the title.
  final Widget? subtitle;

  /// A widget on the side of the row the radio is not on, usually an icon.
  final Widget? secondary;

  /// The choice this row stands for.
  final T value;

  /// The choice that is selected now. The row is selected when it equals
  /// [value].
  final T? groupValue;

  /// Called with [value] when the row is activated — or with null, when a
  /// selected, [toggleable] row is. Null switches the row off, like
  /// [enabled].
  final ValueChanged<T?>? onChanged;

  /// Whether the row responds.
  final bool enabled;

  /// Whether activating the selected row clears the choice.
  final bool toggleable;

  /// Which side the radio is on.
  final ControlAffinity controlAffinity;

  /// The most lines the subtitle wraps to; null for no limit.
  final int? subtitleMaxLines;

  /// The focus node of the row.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final active = enabled && onChanged != null;
    return _ControlTile(
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      enabled: active,
      controlAffinity: controlAffinity,
      subtitleMaxLines: subtitleMaxLines,
      focusNode: focusNode,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      onTap: () {
        if (!selected) {
          onChanged?.call(value);
        } else if (toggleable) {
          onChanged?.call(null);
        }
      },
      control: _RadioMark(selected: selected, enabled: active),
    );
  }
}

/// The row the three control tiles share: a `ListTile` whose tap is the
/// control's, read as one node carrying the control's state.
class _ControlTile extends StatelessWidget {
  const _ControlTile({
    required this.title,
    required this.subtitle,
    required this.secondary,
    required this.enabled,
    required this.controlAffinity,
    required this.subtitleMaxLines,
    required this.focusNode,
    required this.onTap,
    required this.control,
    this.toggled,
    this.checked,
    this.mixed,
    this.inMutuallyExclusiveGroup,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool enabled;
  final ControlAffinity controlAffinity;
  final int? subtitleMaxLines;
  final FocusNode? focusNode;
  final VoidCallback onTap;
  final Widget control;
  final bool? toggled;
  final bool? checked;
  final bool? mixed;
  final bool? inMutuallyExclusiveGroup;

  @override
  Widget build(BuildContext context) {
    // The picture of the control, and nothing else: the row has the tap,
    // the focus and the name.
    final picture = ExcludeSemantics(
      child: ExcludeFocus(child: IgnorePointer(child: control)),
    );
    final leading = controlAffinity == ControlAffinity.leading;
    return MergeSemantics(
      child: Semantics(
        toggled: toggled,
        // A mixed box is neither checked nor unchecked.
        checked: (mixed ?? false) ? null : checked,
        mixed: (mixed ?? false) ? true : null,
        inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
        child: ListTile(
          title: title,
          subtitle: subtitle,
          subtitleMaxLines: subtitleMaxLines,
          leading: leading ? picture : secondary,
          trailing: leading ? secondary : picture,
          enabled: enabled,
          focusNode: focusNode,
          onTap: onTap,
        ),
      ),
    );
  }
}

/// A radio button's circle and dot, drawn from the radio theme: the same
/// picture `Radio` draws, without its gestures, focus or group.
class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radio = theme.radioTheme;
    final motion = Motion.of(context);
    final decoration =
        (selected ? radio.checkedDecoration ?? radio.decoration : null) ??
        radio.decoration ??
        const FinesseDecoration();
    final size = radio.size ?? 16;
    final dot = radio.circleSize ?? 8;
    final spring = radio.duration == null || motion.bouncy.isInstant
        ? motion.bouncy
        : motion.bouncy.copyWith(duration: radio.duration);
    final mark = AnimatedColorBuilder(
      color: decoration.color,
      duration: motion.fast,
      curve: motion.standard,
      builder: (context, color, child) => Decorator(
        decoration: color == null
            ? decoration
            : decoration.copyWith(color: color),
        child: child,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: PopIn(
            visible: selected,
            scale: .2,
            spring: spring,
            child: SizedBox.square(
              dimension: dot,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: radio.color ?? theme.colorScheme.primaryForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (enabled) return mark;
    return Opacity(opacity: theme.disabledOpacity, child: mark);
  }
}
