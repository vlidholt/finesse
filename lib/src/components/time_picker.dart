import 'package:flutter/widgets.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/picker.dart';
import 'package:una/src/components/popover.dart';
import 'package:una/src/components/time_field.dart';
import 'package:una/src/components/time_wheel_picker.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/icons/phosphor_icons.dart';
import 'package:una/src/theme/theme.dart';

/// A field that shows a time and opens a way to change it: a [TimeField]
/// in a popover on a desktop, wheels in a bottom sheet on a phone.
///
/// ```dart
/// TimePicker(
///   value: _start,
///   onChanged: (time) => setState(() => _start = time),
///   minuteInterval: 5,
/// )
/// ```
///
/// It is the counterpart of `DatePicker`. In the popover the time is typed
/// and taken as it is typed. In the sheet the wheels turn a draft:
/// Done reports it, Cancel — or a tap outside — leaves the time as it was,
/// and with [allowDeselection] there is a Clear that reports null.
///
/// [presentation] forces one or the other. The trigger is a field, or the
/// button [variant] names; [triggerBuilder] replaces it.
class TimePicker extends StatefulWidget {
  /// Creates a time picker.
  const TimePicker({
    required this.value,
    required this.onChanged,
    this.minuteInterval = 1,
    this.min,
    this.max,
    this.showSeconds = false,
    this.use24HourFormat,
    this.presentation = PickerPresentation.auto,
    this.placeholder,
    this.title,
    this.formatTime,
    this.allowDeselection,
    this.leading,
    this.trailing,
    this.variant,
    this.size,
    this.width,
    this.expands = false,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.controller,
    this.triggerBuilder,
    this.requestFocus = true,
    super.key,
  });

  /// The time shown; null shows the [placeholder].
  final TimeOfDay? value;

  /// Called with the chosen time, or with null when it is cleared. A null
  /// callback disables the picker.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// The step between two rows of the minutes wheel; it must divide 60.
  final int minuteInterval;

  /// The earliest time that can be chosen.
  final TimeOfDay? min;

  /// The latest time that can be chosen.
  final TimeOfDay? max;

  /// Whether seconds are shown and chosen too.
  final bool showSeconds;

  /// Whether the hours run from 0 to 23, with no day period. Defaults to
  /// what [uses24HourFormat] says for the platform and the locale.
  final bool? use24HourFormat;

  /// Whether the picker opens a popover, a sheet, or whichever suits the
  /// theme's form factor.
  final PickerPresentation presentation;

  /// Shown in the trigger while [value] is null. Defaults to the localized
  /// "Select time".
  final Widget? placeholder;

  /// The title of the sheet. Defaults to the localized "Select time".
  final Widget? title;

  /// Turns the time into the trigger's text. Defaults to `14:05` or
  /// `2:05 PM`, by [use24HourFormat].
  final String Function(TimeOfDay time)? formatTime;

  /// Whether the time can be cleared: the sheet offers a Clear that
  /// reports null. Defaults to the theme's, which is true.
  final bool? allowDeselection;

  /// The widget before the time. Defaults to a clock.
  final Widget? leading;

  /// A widget after the time.
  final Widget? trailing;

  /// The button the trigger is. Null (the default, and the theme's) makes
  /// it a field, like a text field or a select, to sit among the fields of
  /// a form; a variant makes it that button.
  final ButtonVariant? variant;

  /// The size of the button, when [variant] makes it one.
  final ButtonSize? size;

  /// The width of the trigger. Defaults to the theme's; null there makes it
  /// as wide as its content.
  final double? width;

  /// Whether the trigger fills the width it is given.
  final bool expands;

  /// Whether the picker can be opened.
  final bool enabled;

  /// The focus node of the trigger.
  final FocusNode? focusNode;

  /// Whether the trigger takes the focus when it first appears.
  final bool autofocus;

  /// Opens and closes the picker from outside.
  final PopoverController? controller;

  /// Builds the control that opens the picker, in place of the button.
  final PickerTriggerBuilder<TimeOfDay?>? triggerBuilder;

  /// Whether the popover takes the focus when it opens, on the hours.
  /// False leaves the focus where it is and makes the time's fields the
  /// next Tab stops, as `DatePicker.requestFocus` does.
  final bool requestFocus;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  final _fieldNode = FocusNode(debugLabel: 'TimePicker field');

  @override
  void dispose() {
    _fieldNode.dispose();
    super.dispose();
  }

  bool get _enabled => widget.enabled && widget.onChanged != null;

  String _format(BuildContext context, TimeOfDay time) {
    final format = widget.formatTime;
    if (format != null) return format(time);
    return formatTimeOfDay(
      context,
      time,
      showSeconds: widget.showSeconds,
      use24HourFormat: widget.use24HourFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final picker = theme.timePickerTheme;
    final l = UnaLocalizations.of(context);
    final value = widget.value;

    return PickerHost(
      presentation: widget.presentation,
      controller: widget.controller,
      requestFocus: widget.requestFocus,
      popoverPadding: picker.popoverPadding,
      anchor: picker.anchor,
      triggerBuilder: (context, toggle) {
        final builder = widget.triggerBuilder;
        if (builder != null) return builder(context, value, toggle);
        return PickerTrigger(
          onPressed: _enabled ? toggle : null,
          enabled: _enabled,
          label: value == null ? null : _format(context, value),
          placeholder: widget.placeholder ?? Text(l.timePicker.selectTime),
          leading:
              widget.leading ?? const PhosphorIcon(PhosphorIconsRegular.clock),
          trailing: widget.trailing,
          variant: widget.variant ?? picker.buttonVariant,
          size: widget.size,
          width: widget.width ?? picker.width,
          expands: widget.expands,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
        );
      },
      popoverBuilder: (context, close) {
        final field = TimeField(
          value: value,
          onChanged: widget.onChanged,
          min: widget.min,
          max: widget.max,
          showSeconds: widget.showSeconds,
          use24HourFormat: widget.use24HourFormat,
          focusNode: _fieldNode,
        );
        if (!widget.requestFocus) return field;
        // The hours take the focus, so a time can be typed straight away.
        return PickerFocusOnOpen(focusNode: _fieldNode, child: field);
      },
      sheetBuilder: (context, close) => _TimeSheet(
        initial: value,
        title: widget.title ?? Text(l.timePicker.selectTime),
        minuteInterval: widget.minuteInterval,
        min: widget.min,
        max: widget.max,
        showSeconds: widget.showSeconds,
        use24HourFormat: widget.use24HourFormat,
        allowClear:
            (widget.allowDeselection ?? picker.allowDeselection ?? true) &&
            value != null,
        onDone: (time) {
          close();
          if (time != value) widget.onChanged?.call(time);
        },
        onCancel: close,
      ),
    );
  }
}

/// How `TimePicker` writes [time] by default: `14:05` on the 24-hour clock,
/// `2:05 PM` on the 12-hour one, with the localized day period.
String formatTimeOfDay(
  BuildContext context,
  TimeOfDay time, {
  bool showSeconds = false,
  bool? use24HourFormat,
}) {
  String two(int n) => n.toString().padLeft(2, '0');
  final twentyFour = use24HourFormat ?? uses24HourFormat(context);
  final seconds = showSeconds ? ':${two(time.second)}' : '';
  if (twentyFour) return '${two(time.hour)}:${two(time.minute)}$seconds';
  final l = UnaLocalizations.of(context);
  final period = time.period == DayPeriod.am
      ? l.timePicker.am
      : l.timePicker.pm;
  return '${time.hourOfPeriod}:${two(time.minute)}$seconds $period';
}

/// The sheet of a [TimePicker]: wheels turning a draft, and the row that
/// keeps or drops it.
class _TimeSheet extends StatefulWidget {
  const _TimeSheet({
    required this.initial,
    required this.title,
    required this.minuteInterval,
    required this.min,
    required this.max,
    required this.showSeconds,
    required this.use24HourFormat,
    required this.allowClear,
    required this.onDone,
    required this.onCancel,
  });

  final TimeOfDay? initial;
  final Widget title;
  final int minuteInterval;
  final TimeOfDay? min;
  final TimeOfDay? max;
  final bool showSeconds;
  final bool? use24HourFormat;
  final bool allowClear;
  final ValueChanged<TimeOfDay?> onDone;
  final VoidCallback onCancel;

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late TimeOfDay _draft = _start();

  /// Where the wheels start: on the time held, or on now, moved onto a row
  /// of the minutes wheel and inside the bounds.
  TimeOfDay _start() {
    final from = widget.initial ?? TimeOfDay.now();
    final minute = from.minute - from.minute % widget.minuteInterval;
    return from
        .copyWith(minute: minute, second: widget.showSeconds ? null : 0)
        .clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final wheels = Theme.of(context).timePickerTheme.sheetWheelItems ?? 5;
    return PickerSheet(
      title: widget.title,
      onDone: () => widget.onDone(_draft),
      onCancel: widget.onCancel,
      onClear: widget.allowClear ? () => widget.onDone(null) : null,
      child: Center(
        child: TimeWheelPicker(
          value: _draft,
          onChanged: (time) => setState(() => _draft = time),
          minuteInterval: widget.minuteInterval,
          min: widget.min,
          max: widget.max,
          showSeconds: widget.showSeconds,
          use24HourFormat: widget.use24HourFormat,
          visibleItems: wheels,
          mainAxisSize: MainAxisSize.max,
        ),
      ),
    );
  }
}
