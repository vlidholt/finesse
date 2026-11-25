import 'dart:math' as math;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/calendar.dart';
import 'package:finesse/src/components/date_wheel_picker.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/components/calendar.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/extensions/date_time.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

/// How a [DatePicker] lets a date be chosen.
enum DatePickerMode {
  /// A month calendar.
  calendar,

  /// Wheels for the day, the month and the year, as on a phone's own date
  /// picker. Suited to dates far from today, such as a date of birth.
  wheel,
}

/// How `DatePicker` writes [date] by default: `October 1st, 2024`.
String formatPickedDate(BuildContext context, DateTime date) {
  final language = Localizations.localeOf(context).toLanguageTag();
  final month = intl.DateFormat('MMMM', language).format(date);
  final year = intl.DateFormat('y', language).format(date);
  return '$month ${date.getOrdinalDay()}, $year';
}

/// How `DateRangePicker` writes [range] by default: `Oct 1, 2024 - Oct 8,
/// 2024`, or the first day alone while the range has no end.
String formatPickedDateRange(BuildContext context, DateTimeRange range) {
  final start = range.start;
  if (start == null) return '';
  final format = intl.DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  );
  final end = range.end;
  return end == null
      ? format.format(start)
      : '${format.format(start)} - ${format.format(end)}';
}

/// A field that shows a date and opens a way to change it: a calendar in
/// a popover on a desktop, a calendar or wheels in a bottom sheet on a
/// phone.
///
/// ```dart
/// DatePicker(
///   value: _due,
///   onChanged: (date) => setState(() => _due = date),
///   min: DateTime.now(),
/// )
/// ```
///
/// [presentation] forces the popover or the sheet and [mode] chooses the
/// calendar or the wheels. With a calendar a tap on a day reports it and,
/// with [closeOnSelection], closes the picker; the wheels in a sheet turn a
/// draft that Done reports and Cancel drops.
///
/// The trigger is a field by default, set by [placeholder], [formatDate],
/// [leading] and [trailing]; [variant] and [size] make it a button, and
/// [triggerBuilder] replaces it. How the calendar looks is the theme's
/// `CalendarTheme`; [calendarTheme] overrides it for this picker.
/// `DateRangePicker` picks a first and a last day.
class DatePicker extends StatefulWidget {
  /// Creates a date picker.
  const DatePicker({
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.presentation = PickerPresentation.auto,
    this.mode = DatePickerMode.calendar,
    this.closeOnSelection,
    this.allowDeselection,
    this.placeholder,
    this.title,
    this.formatDate,
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
    this.numberOfMonths = 1,
    this.selectableDayPredicate,
    this.weekStartsOn,
    this.showWeekNumbers,
    this.captionLayout,
    this.calendarTheme,
    super.key,
  });

  /// The date shown; null shows the [placeholder].
  final DateTime? value;

  /// Called with the chosen day, or with null when the date is cleared. A
  /// null callback disables the picker.
  final ValueChanged<DateTime?>? onChanged;

  /// The earliest day that can be chosen.
  final DateTime? min;

  /// The latest day that can be chosen.
  final DateTime? max;

  /// Whether the picker opens a popover, a sheet, or whichever suits the
  /// theme's form factor.
  final PickerPresentation presentation;

  /// Whether the date is chosen on a calendar or on wheels.
  final DatePickerMode mode;

  /// Whether choosing a day on the calendar closes the picker. Defaults to
  /// the theme's, which is true.
  final bool? closeOnSelection;

  /// Whether the date can be cleared: by tapping the selected day again,
  /// and with Clear in the sheet. Defaults to the theme's, which is true.
  final bool? allowDeselection;

  /// Shown in the button while [value] is null. Defaults to the localized
  /// "Select date".
  final Widget? placeholder;

  /// The title of the sheet. Defaults to the [placeholder].
  final Widget? title;

  /// Turns the date into the button's text. Defaults to
  /// [formatPickedDate].
  final String Function(DateTime date)? formatDate;

  /// The widget before the date. Defaults to a calendar icon.
  final Widget? leading;

  /// A widget after the date.
  final Widget? trailing;

  /// The button the trigger is. Null (the default, and the theme's) makes
  /// it a field, like a text field or a select, to sit among the fields of
  /// a form; a variant makes it that button.
  final ButtonVariant? variant;

  /// The size of the button, when [variant] makes it one.
  final ButtonSize? size;

  /// The width of the trigger. Defaults to the theme's.
  final double? width;

  /// Whether the trigger fills the width it is given.
  final bool expands;

  /// Whether the picker can be opened.
  final bool enabled;

  /// The focus node of the button.
  final FocusNode? focusNode;

  /// Whether the button takes the focus when it first appears.
  final bool autofocus;

  /// Opens and closes the picker from outside.
  final PopoverController? controller;

  /// Builds the control that opens the picker, in place of the button.
  final PickerTriggerBuilder<DateTime?>? triggerBuilder;

  /// Whether the popover takes the focus when it opens. False leaves the
  /// focus where it is and makes the calendar the next Tab stops.
  final bool requestFocus;

  /// How many months the calendar shows side by side, in a popover. The
  /// sheet shows one.
  final int numberOfMonths;

  /// Returns whether a day can be chosen; days it rejects are disabled.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The first day of the week: 1 is Monday, 7 is Sunday.
  final int? weekStartsOn;

  /// Whether the calendar shows week numbers.
  final bool? showWeekNumbers;

  /// How the calendar's caption names the month.
  final CalendarCaptionLayout? captionLayout;

  /// Values that replace the theme's `CalendarTheme` for this picker.
  final CalendarTheme? calendarTheme;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool get _enabled => widget.enabled && widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final picker = theme.datePickerTheme;
    final l = FinesseLocalizations.of(context);
    final value = widget.value;
    final placeholder = widget.placeholder ?? Text(l.datePicker.selectDate);
    final closeOnSelection =
        widget.closeOnSelection ?? picker.closeOnSelection ?? true;
    final allowDeselection =
        widget.allowDeselection ?? picker.allowDeselection ?? true;

    Calendar calendar({
      required DateTime? value,
      required ValueChanged<DateTime?> onChanged,
      required int numberOfMonths,
      CalendarTheme? override,
    }) {
      return Calendar(
        value: value,
        onChanged: onChanged,
        allowDeselection: allowDeselection,
        initialMonth: value ?? _initialDay(widget.min, widget.max),
        numberOfMonths: numberOfMonths,
        min: widget.min,
        max: widget.max,
        selectableDayPredicate: widget.selectableDayPredicate,
        weekStartsOn: widget.weekStartsOn,
        showWeekNumbers: widget.showWeekNumbers,
        captionLayout: widget.captionLayout,
        // The popover or the sheet is the surface: no frame of its own.
        calendarTheme: const CalendarTheme(
          decoration: FinesseDecoration.none,
        ).merge(widget.calendarTheme).merge(override),
      );
    }

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
          label: value == null
              ? null
              : widget.formatDate?.call(value) ??
                    formatPickedDate(context, value),
          placeholder: placeholder,
          leading:
              widget.leading ??
              const PhosphorIcon(PhosphorIconsRegular.calendarBlank),
          trailing: widget.trailing,
          variant: widget.variant ?? picker.buttonVariant,
          size: widget.size,
          width: widget.width ?? picker.width,
          expands: widget.expands,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
        );
      },
      popoverBuilder: (context, close) => switch (widget.mode) {
        DatePickerMode.calendar => calendar(
          value: value,
          numberOfMonths: widget.numberOfMonths,
          onChanged: (day) {
            widget.onChanged?.call(day);
            if (closeOnSelection && day != null) close();
          },
        ),
        // In a popover the wheels are taken as they turn, like the calendar.
        DatePickerMode.wheel => DateWheelPicker(
          value: value ?? _initialDay(widget.min, widget.max),
          min: widget.min,
          max: widget.max,
          onChanged: (day) => widget.onChanged?.call(day),
        ),
      },
      sheetBuilder: (context, close) => _DateSheet(
        initial: value,
        title: widget.title ?? placeholder,
        showWeekNumbers: widget.showWeekNumbers ?? false,
        mode: widget.mode,
        min: widget.min,
        max: widget.max,
        // On a calendar a tap is the choice; wheels have no such moment,
        // so they always wait for Done.
        commitOnTap: closeOnSelection && widget.mode == DatePickerMode.calendar,
        allowClear: allowDeselection && value != null,
        calendarBuilder: (draft, onChanged, override) => calendar(
          value: draft,
          numberOfMonths: 1,
          onChanged: onChanged,
          override: override,
        ),
        onDone: (day) {
          close();
          if (day != value) widget.onChanged?.call(day);
        },
        onCancel: close,
      ),
    );
  }
}

/// The day a picker with no value opens on: today, moved inside the bounds.
DateTime _initialDay(DateTime? min, DateTime? max) {
  final today = DateTime.now().startOfDay;
  if (min != null && today.isBefore(min)) return min.startOfDay;
  if (max != null && today.isAfter(max)) return max.startOfDay;
  return today;
}

/// Builds the calendar of a sheet around a draft, with the theme values
/// that make it as wide as the sheet.
typedef _SheetCalendarBuilder<T> =
    Widget Function(T draft, ValueChanged<T> onChanged, CalendarTheme override);

/// A calendar laid out as wide as the room it is given, with square cells.
///
/// The cells are never smaller than the theme's, and the room is capped by
/// the sheet's content width, so on a phone they are generous touch
/// targets.
class _WideCalendar extends StatelessWidget {
  const _WideCalendar({required this.showWeekNumbers, required this.builder});

  final bool showWeekNumbers;
  final Widget Function(CalendarTheme override) builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The calendar scales its cells with the text; the override is the size
    // before that.
    final textScale = math.max(1, MediaQuery.textScalerOf(context).scale(1));
    final columns = showWeekNumbers ? 8 : 7;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = constraints.hasBoundedWidth
            ? (constraints.maxWidth / columns).floorToDouble() / textScale
            : theme.calendarTheme.dayButtonSize;
        return Center(
          child: builder(
            CalendarTheme(
              dayButtonSize: cell,
              // The row gap of a grid of large cells would spread the
              // weeks too far apart.
              gridMainAxisSpacing: 0,
            ),
          ),
        );
      },
    );
  }
}

/// The sheet of a [DatePicker].
class _DateSheet extends StatefulWidget {
  const _DateSheet({
    required this.initial,
    required this.title,
    required this.showWeekNumbers,
    required this.mode,
    required this.min,
    required this.max,
    required this.commitOnTap,
    required this.allowClear,
    required this.calendarBuilder,
    required this.onDone,
    required this.onCancel,
  });

  final DateTime? initial;
  final Widget title;
  final bool showWeekNumbers;
  final DatePickerMode mode;
  final DateTime? min;
  final DateTime? max;
  final bool commitOnTap;
  final bool allowClear;
  final _SheetCalendarBuilder<DateTime?> calendarBuilder;
  final ValueChanged<DateTime?> onDone;
  final VoidCallback onCancel;

  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late DateTime? _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final picker = theme.datePickerTheme;
    final Widget content;
    switch (widget.mode) {
      case DatePickerMode.calendar:
        content = _WideCalendar(
          showWeekNumbers: widget.showWeekNumbers,
          builder: (override) => widget.calendarBuilder(_draft, (day) {
            if (widget.commitOnTap && day != null) {
              widget.onDone(day);
            } else {
              setState(() => _draft = day);
            }
          }, override),
        );
      case DatePickerMode.wheel:
        content = Center(
          child: DateWheelPicker(
            value: _draft ?? _initialDay(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            visibleItems: picker.sheetWheelItems ?? 5,
            mainAxisSize: MainAxisSize.max,
            onChanged: (day) => setState(() => _draft = day),
          ),
        );
    }
    return PickerSheet(
      title: widget.title,
      maxWidth: picker.sheetMaxWidth,
      // Wheels always rest on a date, so Done has one to report even
      // when nothing was turned.
      onDone: widget.commitOnTap
          ? null
          : () => widget.onDone(
              _draft ??
                  (widget.mode == DatePickerMode.wheel
                      ? _initialDay(widget.min, widget.max)
                      : null),
            ),
      onCancel: widget.onCancel,
      onClear: widget.allowClear ? () => widget.onDone(null) : null,
      child: content,
    );
  }
}

/// A field that shows a range of dates and opens a calendar to change it:
/// in a popover on a desktop, in a bottom sheet on a phone.
///
/// ```dart
/// DateRangePicker(
///   value: _stay,
///   onChanged: (range) => setState(() => _stay = range),
///   numberOfMonths: 2,
/// )
/// ```
///
/// The first tap sets the first day and the second the last. In a popover
/// each tap is reported, and the picker closes on the second when
/// [closeOnSelection] is true; in a sheet the range is a draft that Done
/// reports. See [DatePicker] for the trigger and the calendar.
class DateRangePicker extends StatefulWidget {
  /// Creates a date range picker.
  const DateRangePicker({
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.minDays,
    this.maxDays,
    this.presentation = PickerPresentation.auto,
    this.closeOnSelection,
    this.allowDeselection,
    this.placeholder,
    this.title,
    this.formatDateRange,
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
    this.numberOfMonths = 1,
    this.selectableDayPredicate,
    this.weekStartsOn,
    this.showWeekNumbers,
    this.captionLayout,
    this.calendarTheme,
    super.key,
  });

  /// The range shown; null, or a range with no first day, shows the
  /// [placeholder].
  final DateTimeRange? value;

  /// Called with the chosen range, or with null when it is cleared. A null
  /// callback disables the picker.
  final ValueChanged<DateTimeRange?>? onChanged;

  /// The earliest day that can be chosen.
  final DateTime? min;

  /// The latest day that can be chosen.
  final DateTime? max;

  /// The shortest range accepted, in days after its first day.
  final int? minDays;

  /// The longest range accepted, in days after its first day.
  final int? maxDays;

  /// Whether the picker opens a popover, a sheet, or whichever suits the
  /// theme's form factor.
  final PickerPresentation presentation;

  /// Whether the popover closes once the range has both its days. Defaults
  /// to the theme's, which is true.
  final bool? closeOnSelection;

  /// Whether the range can be cleared. Defaults to the theme's, which is
  /// true.
  final bool? allowDeselection;

  /// Shown in the button while there is no range. Defaults to the
  /// localized "Select dates".
  final Widget? placeholder;

  /// The title of the sheet. Defaults to the [placeholder].
  final Widget? title;

  /// Turns the range into the button's text. Defaults to
  /// [formatPickedDateRange].
  final String Function(DateTimeRange range)? formatDateRange;

  /// The widget before the range. Defaults to a calendar icon.
  final Widget? leading;

  /// A widget after the range.
  final Widget? trailing;

  /// The button the trigger is. Null (the default, and the theme's) makes
  /// it a field, like a text field or a select, to sit among the fields of
  /// a form; a variant makes it that button.
  final ButtonVariant? variant;

  /// The size of the button, when [variant] makes it one.
  final ButtonSize? size;

  /// The width of the trigger. Defaults to the theme's.
  final double? width;

  /// Whether the trigger fills the width it is given.
  final bool expands;

  /// Whether the picker can be opened.
  final bool enabled;

  /// The focus node of the button.
  final FocusNode? focusNode;

  /// Whether the button takes the focus when it first appears.
  final bool autofocus;

  /// Opens and closes the picker from outside.
  final PopoverController? controller;

  /// Builds the control that opens the picker, in place of the button.
  final PickerTriggerBuilder<DateTimeRange?>? triggerBuilder;

  /// Whether the popover takes the focus when it opens.
  final bool requestFocus;

  /// How many months the calendar shows side by side, in a popover. The
  /// sheet shows one.
  final int numberOfMonths;

  /// Returns whether a day can be chosen; days it rejects are disabled.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The first day of the week: 1 is Monday, 7 is Sunday.
  final int? weekStartsOn;

  /// Whether the calendar shows week numbers.
  final bool? showWeekNumbers;

  /// How the calendar's caption names the month.
  final CalendarCaptionLayout? captionLayout;

  /// Values that replace the theme's `CalendarTheme` for this picker.
  final CalendarTheme? calendarTheme;

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  bool get _enabled => widget.enabled && widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final picker = theme.datePickerTheme;
    final l = FinesseLocalizations.of(context);
    final value = widget.value;
    final hasValue = value?.start != null;
    final placeholder =
        widget.placeholder ?? Text(l.datePicker.selectDateRange);
    final closeOnSelection =
        widget.closeOnSelection ?? picker.closeOnSelection ?? true;
    final allowDeselection =
        widget.allowDeselection ?? picker.allowDeselection ?? true;

    Calendar calendar({
      required DateTimeRange? range,
      required ValueChanged<DateTimeRange?> onChanged,
      required int numberOfMonths,
      CalendarTheme? override,
    }) {
      return Calendar.range(
        range: range,
        onRangeChanged: onChanged,
        allowDeselection: allowDeselection,
        initialMonth: range?.start ?? _initialDay(widget.min, widget.max),
        numberOfMonths: numberOfMonths,
        min: widget.min,
        max: widget.max,
        minDays: widget.minDays,
        maxDays: widget.maxDays,
        selectableDayPredicate: widget.selectableDayPredicate,
        weekStartsOn: widget.weekStartsOn,
        showWeekNumbers: widget.showWeekNumbers,
        captionLayout: widget.captionLayout,
        calendarTheme: const CalendarTheme(
          decoration: FinesseDecoration.none,
        ).merge(widget.calendarTheme).merge(override),
      );
    }

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
          label: !hasValue
              ? null
              : widget.formatDateRange?.call(value!) ??
                    formatPickedDateRange(context, value!),
          placeholder: placeholder,
          leading:
              widget.leading ??
              const PhosphorIcon(PhosphorIconsRegular.calendarBlank),
          trailing: widget.trailing,
          variant: widget.variant ?? picker.buttonVariant,
          size: widget.size,
          width: widget.width ?? picker.width,
          expands: widget.expands,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
        );
      },
      popoverBuilder: (context, close) => calendar(
        range: value,
        numberOfMonths: widget.numberOfMonths,
        onChanged: (range) {
          widget.onChanged?.call(range?.start == null ? null : range);
          if (closeOnSelection && range?.start != null && range?.end != null) {
            close();
          }
        },
      ),
      sheetBuilder: (context, close) => _DateRangeSheet(
        initial: value,
        title: widget.title ?? placeholder,
        showWeekNumbers: widget.showWeekNumbers ?? false,
        allowClear: allowDeselection && hasValue,
        calendarBuilder: (draft, onChanged, override) => calendar(
          range: draft,
          numberOfMonths: 1,
          onChanged: onChanged,
          override: override,
        ),
        onDone: (range) {
          close();
          final next = range?.start == null ? null : range;
          if (next != value) widget.onChanged?.call(next);
        },
        onCancel: close,
      ),
    );
  }
}

/// The sheet of a [DateRangePicker]: the calendar turns a draft, since a
/// range is not chosen until its second day is.
class _DateRangeSheet extends StatefulWidget {
  const _DateRangeSheet({
    required this.initial,
    required this.title,
    required this.showWeekNumbers,
    required this.allowClear,
    required this.calendarBuilder,
    required this.onDone,
    required this.onCancel,
  });

  final DateTimeRange? initial;
  final Widget title;
  final bool showWeekNumbers;
  final bool allowClear;
  final _SheetCalendarBuilder<DateTimeRange?> calendarBuilder;
  final ValueChanged<DateTimeRange?> onDone;
  final VoidCallback onCancel;

  @override
  State<_DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<_DateRangeSheet> {
  late DateTimeRange? _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final picker = Theme.of(context).datePickerTheme;
    return PickerSheet(
      title: widget.title,
      maxWidth: picker.sheetMaxWidth,
      onDone: () => widget.onDone(_draft),
      onCancel: widget.onCancel,
      onClear: widget.allowClear ? () => widget.onDone(null) : null,
      child: _WideCalendar(
        showWeekNumbers: widget.showWeekNumbers,
        builder: (override) => widget.calendarBuilder(
          _draft,
          (range) => setState(() => _draft = range),
          override,
        ),
      ),
    );
  }
}
