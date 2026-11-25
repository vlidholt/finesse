import 'package:finesse/src/components/time_field.dart';
import 'package:finesse/src/components/time_wheel_picker.dart';
import 'package:finesse/src/components/wheel_picker.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/utils/extensions/date_time.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// The locale to format dates in at [context]: the app's, or American
/// English when the app has not loaded that locale's date symbols — a date
/// written in English is better than an exception.
String _dateLanguage(BuildContext context) {
  final tag = Intl.canonicalizedLocale(
    Localizations.localeOf(context).toLanguageTag(),
  );
  try {
    if (DateFormat.localeExists(tag)) return tag;
  } on Exception {
    // intl throws, rather than answering, while no symbols are loaded.
  }
  return 'en_US';
}

/// What a [DateWheelPicker] chooses.
enum DateWheelMode {
  /// A day, a month and a year.
  date,

  /// A month and a year; the day is kept where the month has it.
  monthYear,

  /// A day of the calendar and a time of day.
  dateAndTime,
}

/// A date chosen on wheels: day, month and year in the order the locale
/// writes them, or a day and a time.
///
/// ```dart
/// DateWheelPicker(
///   value: _birthday,
///   max: DateTime.now(),
///   onChanged: (date) => setState(() => _birthday = date),
/// )
/// ```
///
/// It is what `DatePicker` shows in wheel mode, for use on its own in a
/// page or a dialog. The wheels share one lens (see [WheelPickerGroup]);
/// a day the month does not have, and any date outside [min] and [max], is
/// dimmed and cannot be rested on.
class DateWheelPicker extends StatefulWidget {
  /// Creates wheels that show [value].
  const DateWheelPicker({
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.mode = DateWheelMode.date,
    this.minuteInterval = 1,
    this.use24HourFormat,
    this.visibleItems = 5,
    this.mainAxisSize = MainAxisSize.min,
    this.enabled = true,
    super.key,
  });

  /// The date the wheels rest on.
  final DateTime value;

  /// Called with the new date whenever a wheel brings another row under
  /// the lens.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date that can be chosen. Defaults to a hundred years
  /// before [value] (five, with a time).
  final DateTime? min;

  /// The latest date that can be chosen. Defaults to a hundred years after
  /// [value] (five, with a time).
  final DateTime? max;

  /// Which wheels show.
  final DateWheelMode mode;

  /// The step between two rows of the minutes wheel, in
  /// [DateWheelMode.dateAndTime]; it must divide 60.
  final int minuteInterval;

  /// Whether the hours run from 0 to 23. Defaults to what
  /// [uses24HourFormat] says for the platform and the locale.
  final bool? use24HourFormat;

  /// How many rows of each wheel show.
  final int visibleItems;

  /// Whether the lens is as wide as the wheels need or as wide as the
  /// parent allows.
  final MainAxisSize mainAxisSize;

  /// Whether the wheels can be turned.
  final bool enabled;

  @override
  State<DateWheelPicker> createState() => _DateWheelPickerState();
}

class _DateWheelPickerState extends State<DateWheelPicker> {
  /// The date the wheels' rows are laid out around: the years a hundred
  /// either side of it, or the days five years either side. It stays where
  /// it is while the wheels turn — rows that moved with the value would
  /// slide under the finger — and follows only a value set from far away.
  late DateTime _anchor = widget.value;

  DateTime get value => widget.value;
  DateTime? get min => widget.min;
  DateTime? get max => widget.max;
  DateWheelMode get mode => widget.mode;
  bool get enabled => widget.enabled;
  int get visibleItems => widget.visibleItems;
  MainAxisSize get mainAxisSize => widget.mainAxisSize;

  int get _firstYear => min?.year ?? _anchor.year - 100;
  int get _lastYear => max?.year ?? _anchor.year + 100;
  DateTime get _firstDay =>
      (min ?? DateTime(_anchor.year - 5, _anchor.month, _anchor.day))
          .startOfDay;
  DateTime get _lastDay =>
      (max ?? DateTime(_anchor.year + 5, _anchor.month, _anchor.day))
          .startOfDay;

  @override
  void didUpdateWidget(DateWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final outside = mode == DateWheelMode.dateAndTime
        ? value.isBefore(_firstDay) ||
              value.isAfter(_lastDay.add(const Duration(days: 1)))
        : value.year < _firstYear || value.year > _lastYear;
    if (outside) _anchor = value;
  }

  void onChanged(DateTime date) => widget.onChanged(date);

  DateTime _clamp(DateTime date) {
    final min = this.min;
    final max = this.max;
    if (min != null && date.isBefore(min)) return min;
    if (max != null && date.isAfter(max)) return max;
    return date;
  }

  void _report(DateTime date) {
    final clamped = _clamp(date);
    if (clamped != value) onChanged(clamped);
  }

  /// [value] moved to [year] and [month], its day held inside the month.
  DateTime _withMonth(int year, int month) {
    final days = DateTime(year, month).daysInMonth;
    return _copy(year: year, month: month, day: value.day.clamp(1, days));
  }

  DateTime _copy({int? year, int? month, int? day, TimeOfDay? time}) {
    return DateTime(
      year ?? value.year,
      month ?? value.month,
      day ?? value.day,
      time?.hour ?? value.hour,
      time?.minute ?? value.minute,
      time?.second ?? value.second,
    );
  }

  /// Whether any moment from [from] to [to] can be chosen.
  bool _reachable(DateTime from, DateTime to) {
    final min = this.min;
    final max = this.max;
    if (min != null && to.isBefore(min)) return false;
    if (max != null && from.isAfter(max)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = FinesseLocalizations.of(context);
    final language = _dateLanguage(context);

    if (mode == DateWheelMode.dateAndTime) {
      return _buildDateAndTime(context, language);
    }

    final firstYear = _firstYear;
    final lastYear = _lastYear;
    final monthName = DateFormat('LLLL', language);

    final years = WheelPicker<int>.builder(
      semanticLabel: l.datePicker.year,
      enabled: enabled,
      itemCount: lastYear - firstYear + 1,
      itemBuilder: (index) => WheelPickerItem(
        value: firstYear + index,
        label: '${firstYear + index}',
      ),
      indexOf: (year) => year - firstYear,
      value: value.year.clamp(firstYear, lastYear),
      onChanged: (year) => _report(_withMonth(year, value.month)),
    );

    final months = WheelPicker<int>(
      semanticLabel: l.datePicker.month,
      enabled: enabled,
      looping: true,
      alignment: AlignmentDirectional.centerStart,
      value: value.month,
      onChanged: (month) => _report(_withMonth(value.year, month)),
      items: [
        for (var month = 1; month <= 12; month++)
          WheelPickerItem(
            value: month,
            label: monthName.format(DateTime(value.year, month)),
            enabled: _reachable(
              DateTime(value.year, month),
              DateTime(value.year, month + 1).subtract(
                const Duration(microseconds: 1),
              ),
            ),
          ),
      ],
    );

    final daysInMonth = value.daysInMonth;
    final days = mode == DateWheelMode.monthYear
        ? null
        : WheelPicker<int>(
            semanticLabel: l.datePicker.day,
            enabled: enabled,
            looping: true,
            alignment: AlignmentDirectional.centerEnd,
            value: value.day,
            onChanged: (day) => _report(_copy(day: day)),
            // Always thirty-one rows, so the wheel does not jump when the
            // month changes; the ones the month lacks are dimmed.
            items: [
              for (var day = 1; day <= 31; day++)
                WheelPickerItem(
                  value: day,
                  label: '$day',
                  enabled:
                      day <= daysInMonth &&
                      _reachable(
                        DateTime(value.year, value.month, day),
                        DateTime(value.year, value.month, day, 23, 59, 59),
                      ),
                ),
            ],
          );

    // The order the locale writes a date in: "d/M/y", "M/d/y", "y-M-d".
    final pattern = DateFormat.yMd(language).pattern ?? 'd/M/y';
    final order = <(int, Widget)>[
      if (days != null) (pattern.indexOf('d'), days),
      (pattern.indexOf('M'), months),
      (pattern.indexOf('y'), years),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    return WheelPickerGroup(
      visibleItems: visibleItems,
      mainAxisSize: mainAxisSize,
      children: [for (final (_, wheel) in order) wheel],
    );
  }

  Widget _buildDateAndTime(BuildContext context, String language) {
    final l = FinesseLocalizations.of(context);
    final first = _firstDay;
    final last = _lastDay;
    final dayName = DateFormat('EEE d MMM', language);

    // Calendar days are counted from noon, so a change of the clocks never
    // moves one onto its neighbour.
    DateTime dayAt(int index) => DateTime(
      first.year,
      first.month,
      first.day + index,
    );
    int indexOf(DateTime day) => DateTime.utc(
      day.year,
      day.month,
      day.day,
    ).difference(DateTime.utc(first.year, first.month, first.day)).inDays;
    final count = indexOf(last) + 1;
    final today = indexOf(value.startOfDay).clamp(0, count - 1);

    final days = WheelPicker<int>.builder(
      semanticLabel: l.datePicker.day,
      enabled: enabled,
      alignment: AlignmentDirectional.centerEnd,
      itemCount: count,
      // Every weekday beside every month, with a two-digit day: seven days
      // in a row have them all.
      sizingLabels: [
        for (var month = 1; month <= 12; month++)
          for (var day = 22; day <= 28; day++)
            dayName.format(DateTime(2023, month, day)),
      ],
      itemBuilder: (index) =>
          WheelPickerItem(value: index, label: dayName.format(dayAt(index))),
      indexOf: (index) => index,
      value: today,
      onChanged: (index) {
        final day = dayAt(index);
        _report(_copy(year: day.year, month: day.month, day: day.day));
      },
    );

    // On the first and the last day the time has a bound of its own.
    final lower = min;
    final upper = max;
    return WheelPickerGroup(
      visibleItems: visibleItems,
      mainAxisSize: mainAxisSize,
      children: [
        days,
        TimeWheelPicker(
          value: TimeOfDay.fromDateTime(value),
          enabled: enabled,
          minuteInterval: widget.minuteInterval,
          use24HourFormat: widget.use24HourFormat,
          min: lower != null && lower.isSameDay(value)
              ? TimeOfDay.fromDateTime(lower)
              : null,
          max: upper != null && upper.isSameDay(value)
              ? TimeOfDay.fromDateTime(upper)
              : null,
          onChanged: (time) => _report(_copy(time: time)),
        ),
      ],
    );
  }
}
