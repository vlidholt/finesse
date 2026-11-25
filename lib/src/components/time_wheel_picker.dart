import 'package:finesse/src/components/time_field.dart';
import 'package:finesse/src/components/wheel_picker.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:flutter/widgets.dart';

/// A time chosen on wheels: hours, minutes and, optionally, seconds, with a
/// day period beside them on the 12-hour clock.
///
/// ```dart
/// TimeWheelPicker(
///   value: _alarm,
///   onChanged: (time) => setState(() => _alarm = time),
///   minuteInterval: 5,
/// )
/// ```
///
/// It is what `TimePicker` shows in its sheet on a phone, for use on its
/// own in a page or a dialog. The wheels share one lens (see
/// [WheelPickerGroup]), the hours and minutes go round, and a time outside
/// [min] and [max] is dimmed and cannot be rested on.
class TimeWheelPicker extends StatelessWidget {
  /// Creates wheels that show [value].
  const TimeWheelPicker({
    required this.value,
    required this.onChanged,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.min,
    this.max,
    this.showSeconds = false,
    this.use24HourFormat,
    this.visibleItems = 5,
    this.mainAxisSize = MainAxisSize.min,
    this.enabled = true,
    super.key,
  }) : assert(
         minuteInterval > 0 && 60 % minuteInterval == 0,
         'minuteInterval must divide 60.',
       ),
       assert(
         secondInterval > 0 && 60 % secondInterval == 0,
         'secondInterval must divide 60.',
       );

  /// The time the wheels rest on.
  final TimeOfDay value;

  /// Called with the new time whenever a wheel brings another row under
  /// the lens.
  final ValueChanged<TimeOfDay> onChanged;

  /// The step between two rows of the minutes wheel; it must divide 60.
  final int minuteInterval;

  /// The step between two rows of the seconds wheel; it must divide 60.
  final int secondInterval;

  /// The earliest time that can be chosen.
  final TimeOfDay? min;

  /// The latest time that can be chosen.
  final TimeOfDay? max;

  /// Whether there is a wheel for the seconds.
  final bool showSeconds;

  /// Whether the hours run from 0 to 23, with no day period. Defaults to
  /// what [uses24HourFormat] says for the platform and the locale.
  final bool? use24HourFormat;

  /// How many rows of each wheel show.
  final int visibleItems;

  /// Whether the lens is as wide as the wheels need or as wide as the
  /// parent allows.
  final MainAxisSize mainAxisSize;

  /// Whether the wheels can be turned.
  final bool enabled;

  /// Whether any time from [from] to [to] can be chosen.
  bool _reachable(TimeOfDay from, TimeOfDay to) {
    final min = this.min;
    final max = this.max;
    if (min != null && to.isBefore(min)) return false;
    if (max != null && from.isAfter(max)) return false;
    return true;
  }

  void _report(TimeOfDay time) {
    final clamped = time.clamp(min, max);
    if (clamped != value) onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final l = FinesseLocalizations.of(context);
    final twentyFour = use24HourFormat ?? uses24HourFormat(context);
    String two(int n) => n.toString().padLeft(2, '0');

    final period = value.period;
    // The hour of the day a row of the hours wheel stands for.
    int hourOf(int row) => twentyFour
        ? row
        : row % TimeOfDay.hoursPerPeriod +
              (period == DayPeriod.pm ? TimeOfDay.hoursPerPeriod : 0);
    final minute = value.minute - value.minute % minuteInterval;
    final second = value.second - value.second % secondInterval;

    final hours = WheelPicker<int>(
      semanticLabel: l.timePicker.hours,
      looping: true,
      enabled: enabled,
      alignment: AlignmentDirectional.centerEnd,
      value: twentyFour ? value.hour : value.hourOfPeriod,
      onChanged: (row) => _report(value.copyWith(hour: hourOf(row))),
      items: [
        for (final row
            in twentyFour
                ? [for (var h = 0; h < 24; h++) h]
                : [12, for (var h = 1; h < 12; h++) h])
          WheelPickerItem(
            value: row,
            label: twentyFour ? two(row) : '$row',
            enabled: _reachable(
              TimeOfDay(hour: hourOf(row), minute: 0),
              TimeOfDay(hour: hourOf(row), minute: 59, second: 59),
            ),
          ),
      ],
    );

    final minutes = WheelPicker<int>(
      semanticLabel: l.timePicker.minutes,
      looping: true,
      enabled: enabled,
      alignment: showSeconds
          ? AlignmentDirectional.center
          : AlignmentDirectional.centerStart,
      value: minute,
      onChanged: (m) => _report(value.copyWith(minute: m)),
      items: [
        for (var m = 0; m < 60; m += minuteInterval)
          WheelPickerItem(
            value: m,
            label: two(m),
            enabled: _reachable(
              TimeOfDay(hour: value.hour, minute: m),
              TimeOfDay(hour: value.hour, minute: m, second: 59),
            ),
          ),
      ],
    );

    final seconds = !showSeconds
        ? null
        : WheelPicker<int>(
            semanticLabel: l.timePicker.seconds,
            looping: true,
            enabled: enabled,
            alignment: AlignmentDirectional.centerStart,
            value: second,
            onChanged: (s) => _report(value.copyWith(second: s)),
            items: [
              for (var s = 0; s < 60; s += secondInterval)
                WheelPickerItem(
                  value: s,
                  label: two(s),
                  enabled: _reachable(
                    value.copyWith(second: s),
                    value.copyWith(second: s),
                  ),
                ),
            ],
          );

    final periods = twentyFour
        ? null
        : WheelPicker<DayPeriod>(
            semanticLabel: l.timePicker.period,
            enabled: enabled,
            value: period,
            onChanged: (p) => _report(value.withPeriod(p)),
            items: [
              WheelPickerItem(
                value: DayPeriod.am,
                label: l.timePicker.am,
                enabled: _reachable(
                  const TimeOfDay(hour: 0, minute: 0),
                  const TimeOfDay(hour: 11, minute: 59, second: 59),
                ),
              ),
              WheelPickerItem(
                value: DayPeriod.pm,
                label: l.timePicker.pm,
                enabled: _reachable(
                  const TimeOfDay(hour: 12, minute: 0),
                  const TimeOfDay(hour: 23, minute: 59, second: 59),
                ),
              ),
            ],
          );

    // Hours, minutes and seconds read left to right in every script; the
    // day period follows them, on the side the text ends.
    final clock = Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          hours,
          const Text(':'),
          minutes,
          if (seconds != null) ...[const Text(':'), seconds],
        ],
      ),
    );
    return WheelPickerGroup(
      visibleItems: visibleItems,
      mainAxisSize: mainAxisSize,
      children: [clock, ?periods],
    );
  }
}
