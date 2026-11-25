import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/components/select.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/components/calendar.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/content_switch.dart';
import 'package:finesse/src/utils/extensions/date_time.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Encapsulates a start and end [DateTime] that represent the range of dates.
///
/// The range includes the [start] and [end] dates. The [start] and [end] dates
/// may be equal to indicate a date range of a single day. The [start] date must
/// not be after the [end] date.
@immutable
class DateTimeRange {
  /// Creates a date range for the given start and end [DateTime].
  const DateTimeRange({
    this.start,
    this.end,
  });

  /// The start of the range of dates.
  final DateTime? start;

  /// The end of the range of dates.
  final DateTime? end;

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [DateTime.difference] for more details.
  Duration? get duration =>
      start == null || end == null ? null : end!.difference(start!);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DateTimeRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hashAll([start, end]);

  @override
  String toString() => 'DateTimeRange(start: $start, end $end)';
}

/// Represents the data model for a single month in the calendar.
///
/// Contains the month date, a list of dates to display, and the first date
/// shown.
@immutable
class CalendarModel {
  /// Creates a calendar model for a specific month.
  const CalendarModel({
    required this.month,
    required this.dates,
    required this.firstDateShown,
  });

  /// The month this model represents.
  final DateTime month;

  /// The list of dates to display, including nulls for hidden outside days.
  final List<DateTime?> dates;

  /// The first date shown in the grid, used for weekday alignment.
  final DateTime firstDateShown;

  @override
  int get hashCode => Object.hashAll([month, dates, firstDateShown]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarModel &&
        other.month == month &&
        listEquals(other.dates, dates) &&
        other.firstDateShown == firstDateShown;
  }
}

/// Variants available for the [Calendar] widget.
enum CalendarVariant {
  /// Selects one date.
  single,

  /// Selects any number of separate dates.
  multiple,

  /// Selects a start date, an end date and the days between them.
  range,
}

/// Caption layout options for the [Calendar] widget.
enum CalendarCaptionLayout {
  /// Displays the month and year as a label. Default value.
  label,

  /// Displays a dropdown with both months and years.
  dropdown,

  /// Displays a dropdown with the months only.
  dropdownMonths,

  /// Displays a dropdown with the years only.
  dropdownYears,
}

/// A month calendar that selects a day, several days or a range of days.
///
/// ```dart
/// Calendar(
///   value: _day,
///   onChanged: (day) => setState(() => _day = day),
///   min: DateTime.now(),
/// )
/// ```
///
/// The unnamed constructor selects one day, [Calendar.multiple] any number
/// and [Calendar.range] a first and a last day. What the calendar *does* is
/// set here — its bounds, how many months show, where the week starts, how
/// the caption is laid out. How it *looks* — cell size, text styles, button
/// variants, paddings, the formats of its labels — is the theme's
/// `CalendarTheme`; pass [calendarTheme] to override part of it for one
/// calendar.
///
/// A day cell is as large as the theme says and grows with the text scale;
/// on a phone the theme's cells are touch targets.
class Calendar extends StatefulWidget {
  /// Creates a calendar that selects one day.
  const Calendar({
    super.key,
    this.value,
    this.onChanged,
    this.allowDeselection,
    this.initialMonth,
    this.numberOfMonths = 1,
    this.min,
    this.max,
    this.selectableDayPredicate,
    this.weekStartsOn,
    this.showWeekNumbers,
    this.showOutsideDays,
    this.fixedWeeks,
    this.showWeekdayNames,
    this.captionLayout,
    this.showNavigation,
    this.reverseMonths = false,
    this.onMonthChanged,
    this.calendarTheme,
  }) : variant = CalendarVariant.single,
       values = null,
       onValuesChanged = null,
       minSelected = null,
       maxSelected = null,
       range = null,
       onRangeChanged = null,
       minDays = null,
       maxDays = null;

  /// Creates a calendar that selects any number of days.
  const Calendar.multiple({
    super.key,
    this.values,
    this.onValuesChanged,
    this.minSelected,
    this.maxSelected,
    this.initialMonth,
    this.numberOfMonths = 1,
    this.min,
    this.max,
    this.selectableDayPredicate,
    this.weekStartsOn,
    this.showWeekNumbers,
    this.showOutsideDays,
    this.fixedWeeks,
    this.showWeekdayNames,
    this.captionLayout,
    this.showNavigation,
    this.reverseMonths = false,
    this.onMonthChanged,
    this.calendarTheme,
  }) : variant = CalendarVariant.multiple,
       value = null,
       onChanged = null,
       allowDeselection = null,
       range = null,
       onRangeChanged = null,
       minDays = null,
       maxDays = null;

  /// Creates a calendar that selects a range of days.
  const Calendar.range({
    super.key,
    this.range,
    this.onRangeChanged,
    this.minDays,
    this.maxDays,
    this.allowDeselection,
    this.initialMonth,
    this.numberOfMonths = 1,
    this.min,
    this.max,
    this.selectableDayPredicate,
    this.weekStartsOn,
    this.showWeekNumbers,
    this.showOutsideDays,
    this.fixedWeeks,
    this.showWeekdayNames,
    this.captionLayout,
    this.showNavigation,
    this.reverseMonths = false,
    this.onMonthChanged,
    this.calendarTheme,
  }) : variant = CalendarVariant.range,
       value = null,
       onChanged = null,
       values = null,
       onValuesChanged = null,
       minSelected = null,
       maxSelected = null;

  /// Whether the calendar selects one day, several or a range. Set by the
  /// constructor.
  final CalendarVariant variant;

  /// The selected day of a single-day calendar.
  final DateTime? value;

  /// Called with the day that was tapped, or with null when the selected
  /// day was tapped again and [allowDeselection] is true.
  final ValueChanged<DateTime?>? onChanged;

  /// The selected days of a [Calendar.multiple].
  final List<DateTime>? values;

  /// Called with all the selected days when one is added or removed.
  final ValueChanged<List<DateTime>>? onValuesChanged;

  /// The fewest days a [Calendar.multiple] keeps selected: a tap that would
  /// leave fewer is ignored.
  final int? minSelected;

  /// The most days a [Calendar.multiple] selects: once reached, the other
  /// days are disabled.
  final int? maxSelected;

  /// The selected range of a [Calendar.range]. Its end is null while only
  /// the first day has been chosen.
  final DateTimeRange? range;

  /// Called with the range whenever a tap changes it.
  final ValueChanged<DateTimeRange?>? onRangeChanged;

  /// The shortest range a [Calendar.range] accepts, in days after its
  /// first day.
  final int? minDays;

  /// The longest range a [Calendar.range] accepts, in days after its first
  /// day.
  final int? maxDays;

  /// Whether tapping the selected day, or the one day of an unfinished
  /// range, deselects it. Defaults to the theme's.
  final bool? allowDeselection;

  /// The month shown first. Defaults to the current month.
  final DateTime? initialMonth;

  /// How many months show side by side.
  final int numberOfMonths;

  /// The earliest day that can be selected. Earlier days are disabled and
  /// the calendar does not go back past this day's month.
  final DateTime? min;

  /// The latest day that can be selected. Later days are disabled and the
  /// calendar does not go on past this day's month.
  final DateTime? max;

  /// Returns whether a day can be selected; days it rejects are disabled.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The first day of the week, as a `DateTime` weekday: 1 is Monday, 7 is
  /// Sunday. Defaults to the theme's, which is Monday.
  final int? weekStartsOn;

  /// Whether a column of week numbers shows before the days.
  final bool? showWeekNumbers;

  /// Whether the days of the neighbouring months that fall in the first and
  /// last week show.
  final bool? showOutsideDays;

  /// Whether every month takes six weeks, so that the calendar keeps its
  /// height from month to month. Needs [showOutsideDays].
  final bool? fixedWeeks;

  /// Whether the row of weekday names shows. Defaults to true.
  final bool? showWeekdayNames;

  /// How the caption names the month: as a label, or with dropdowns for the
  /// month, the year or both.
  final CalendarCaptionLayout? captionLayout;

  /// Whether the previous and next buttons show. Defaults to true.
  final bool? showNavigation;

  /// Whether, with several months, the latest shows first.
  final bool reverseMonths;

  /// Called with the first month shown when the calendar moves to another.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Values that replace the theme's `CalendarTheme` for this calendar:
  /// cell size, text styles, button variants, paddings and label formats.
  final CalendarTheme? calendarTheme;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final today = DateTime.now().startOfDay;
  late DateTime currentMonth = widget.initialMonth ?? today.startOfMonth;
  List<CalendarModel> datesModels = [];
  // The first date shown in the calendar, used to render the week days
  late DateTime firstDateShown;
  bool isPreviousMonthButtonDisabled = false;
  bool isNextMonthButtonDisabled = false;
  late final selectedDays = <DateTime>{
    if (widget.value != null) widget.value!.startOfDay,
    if (widget.values != null)
      for (final date in widget.values!) date.startOfDay,
  };
  late DateTime? startRange = widget.range?.start;
  late DateTime? endRange = widget.range?.end;

  final backMonthButtonHovered = ValueNotifier<bool>(false);
  final forwardMonthButtonHovered = ValueNotifier<bool>(false);

  // The list of available years in the selector
  final availableYears = <int>[];

  /// The theme's calendar values under the widget's own.
  CalendarTheme get _calendarTheme => Theme.of(
    context,
    listen: false,
  ).calendarTheme.merge(widget.calendarTheme);

  bool get effectiveShowOutsideDays =>
      widget.showOutsideDays ?? _calendarTheme.showOutsideDays ?? true;

  bool get effectiveShowWeekdayNames =>
      widget.showWeekdayNames ?? _calendarTheme.showWeekdayNames ?? true;

  bool get effectiveShowWeekNumbers =>
      widget.showWeekNumbers ?? _calendarTheme.showWeekNumbers ?? false;

  int get effectiveWeekStartsOn =>
      widget.weekStartsOn ?? _calendarTheme.weekStartsOn ?? 1;

  bool get effectiveFixedWeeks =>
      widget.fixedWeeks ?? _calendarTheme.fixedWeeks ?? false;

  bool enabled(DateTime date) {
    final min = widget.min;
    final max = widget.max;
    if (min != null && date.isBefore(min.startOfDay)) return false;
    if (max != null && date.isAfter(max.startOfDay)) return false;

    // disable if the predicate returns false for the date
    if (widget.selectableDayPredicate != null &&
        !widget.selectableDayPredicate!(date)) {
      return false;
    }

    // disable other days when max is reached
    if (widget.maxSelected != null &&
        selectedDays.length >= widget.maxSelected!) {
      // only selected days are enabled
      return selectedDays.any((selectedDay) => selectedDay.isSameDay(date));
    }

    if (widget.variant == CalendarVariant.range) {
      bool satifiesMin() {
        if (widget.minDays != null && startRange != null) {
          // only the dates after min are enabled
          final minDate = startRange!.addDays(widget.minDays!);
          return date.isSameDayOrGreater(minDate) ||
              date.isSameDay(startRange!);
        }
        return true;
      }

      bool satifiesMax() {
        if (widget.maxDays != null && startRange != null) {
          // only the dates before max are enabled
          final maxDate = startRange!.addDays(widget.maxDays!);
          return date.isSameDayOrLower(maxDate) || date.isSameDay(startRange!);
        }
        return true;
      }

      bool isInRange() {
        return (startRange != null && date.isSameDayOrGreater(startRange!)) &&
            (endRange != null && date.isSameDayOrLower(endRange!));
      }

      return (satifiesMin() && satifiesMax()) || isInRange();
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    generateDates();
    generateAvailableYears();
  }

  @override
  void didUpdateWidget(covariant Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool initialMonthChanged;
    if ((oldWidget.initialMonth == currentMonth ||
            (currentMonth == today.startOfMonth)) &&
        widget.initialMonth != null) {
      currentMonth = widget.initialMonth!;
      initialMonthChanged = true;
    } else {
      initialMonthChanged = false;
    }

    if (widget.showOutsideDays != oldWidget.showOutsideDays ||
        widget.fixedWeeks != oldWidget.fixedWeeks ||
        widget.weekStartsOn != oldWidget.weekStartsOn ||
        widget.numberOfMonths != oldWidget.numberOfMonths ||
        widget.min != oldWidget.min ||
        widget.max != oldWidget.max ||
        widget.reverseMonths != oldWidget.reverseMonths ||
        widget.showWeekNumbers != oldWidget.showWeekNumbers ||
        initialMonthChanged) {
      generateDates();
    }
    if (widget.min != oldWidget.min || widget.max != oldWidget.max) {
      generateAvailableYears();
    }

    if (widget.value != oldWidget.value) {
      selectedDays.clear();
      if (widget.value != null) selectedDays.add(widget.value!.startOfDay);
    }

    if (widget.values != null &&
        !listEquals([...widget.values!], selectedDays.toList())) {
      selectedDays
        ..clear()
        ..addAll(widget.values!.map((day) => day.startOfDay));
    }

    if (widget.range != oldWidget.range) {
      startRange = widget.range?.start;
      endRange = widget.range?.end;
    }
  }

  @override
  void dispose() {
    backMonthButtonHovered.dispose();
    forwardMonthButtonHovered.dispose();
    super.dispose();
  }

  void generateDates() {
    datesModels = [];
    var month = currentMonth.previousMonth;
    for (var i = 0; i < widget.numberOfMonths; i++) {
      final effectiveMonth = month.nextMonth;
      generateDatesForMonth(effectiveMonth);
      month = effectiveMonth;
    }

    isPreviousMonthButtonDisabled =
        widget.min != null &&
        datesModels.first.month.startOfMonth.millisecondsSinceEpoch <=
            widget.min!.startOfMonth.millisecondsSinceEpoch;
    isNextMonthButtonDisabled =
        widget.max != null &&
        datesModels.last.month.startOfMonth.millisecondsSinceEpoch >=
            widget.max!.startOfMonth.millisecondsSinceEpoch;
  }

  void generateDatesForMonth(DateTime month) {
    var firstDate = month.startOfMonth;

    final lastDate = month.endOfMonth;
    // find the first day of the week, going back if necessary
    while (firstDate.weekday != effectiveWeekStartsOn) {
      firstDate = firstDate.previousDay;
    }
    firstDateShown = firstDate;

    final dates = <DateTime?>[];
    var coveredWholeMonth = false;
    while (!coveredWholeMonth ||
        (!effectiveFixedWeeks && dates.length % 7 != 0) ||
        (effectiveFixedWeeks && dates.length != 42)) {
      final isDayOutsideMonth = firstDate.month != month.month;
      if (isDayOutsideMonth && !effectiveShowOutsideDays) {
        dates.add(null);
      } else {
        dates.add(firstDate);
      }

      // Check if we've covered the whole month
      if (firstDate.isSameDay(lastDate) && !coveredWholeMonth) {
        coveredWholeMonth = true;
      }

      firstDate = firstDate.nextDay;
    }

    // If showWeekNumbers is enabled, duplicate the first available dates of
    // each week
    if (effectiveShowWeekNumbers) {
      for (var i = 0; i < dates.length; i += 8) {
        final sublist = dates.sublist(i);
        final firstDateOfWeek = sublist.firstWhere((d) => d != null);
        dates.insert(i, firstDateOfWeek);
      }
    }

    datesModels.add(
      CalendarModel(
        month: month,
        dates: dates,
        firstDateShown: firstDateShown,
      ),
    );
  }

  void generateAvailableYears() {
    availableYears.clear();
    final minYear = widget.min?.year ?? currentMonth.year - 100;
    final maxYear = widget.max?.year ?? currentMonth.year + 100;

    for (var i = minYear; i <= maxYear; i++) {
      availableYears.add(i);
    }
  }

  /// Memoized [DateFormat]s, keyed by pattern and language tag.
  ///
  /// Constructing a DateFormat parses the pattern and resolves locale data,
  /// which is far from free. The caption dropdowns format one label per
  /// selectable year — 201 by default — so building them without a cache cost
  /// 201 pattern parses every time the options were materialised.
  final _dateFormats = <String, DateFormat>{};

  DateFormat _dateFormat(String pattern, Locale locale) {
    final languageTag = locale.toLanguageTag();
    return _dateFormats.putIfAbsent(
      '$pattern\u0000$languageTag',
      () => DateFormat(pattern, languageTag),
    );
  }

  String defaultFormatMonthYear(DateTime date, Locale locale) {
    return _dateFormat('LLLL y', locale).format(date);
  }

  String defaultFormatYear(DateTime date, Locale locale) {
    return _dateFormat('y', locale).format(date);
  }

  String defaultFormatMonth(DateTime date, Locale locale) {
    return _dateFormat('LLLL', locale).format(date);
  }

  String defaultDropdownFormatMonth(DateTime date, Locale locale) {
    return _dateFormat('MMM', locale).format(date);
  }

  String defaultDropdownFormatYear(DateTime date, Locale locale) {
    return _dateFormat('y', locale).format(date);
  }

  String defaultFormatWeekday(DateTime date, Locale locale) {
    final s = DateFormat('EE', locale.toLanguageTag()).format(date);
    if (s.length < 2) return s;
    return s.substring(0, 2);
  }

  void goToMonth(DateTime date) {
    setState(() {
      currentMonth = date;
      generateDates();
    });
    widget.onMonthChanged?.call(currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !effectiveFixedWeeks || effectiveShowOutsideDays,
      'When fixedWeeks is true, showOutsideDays must be true',
    );

    final theme = Theme.of(context);
    final calendar = theme.calendarTheme.merge(widget.calendarTheme);
    final locale = Localizations.localeOf(context);

    final effectiveCaptionLayout =
        widget.captionLayout ??
        calendar.captionLayout ??
        CalendarCaptionLayout.label;

    final effectiveFormatMonth =
        calendar.formatMonth ?? (date) => defaultFormatMonth(date, locale);

    final effectiveFormatYear =
        calendar.formatYear ?? (date) => defaultFormatYear(date, locale);

    final effectiveDropdownFormatMonth =
        calendar.dropdownFormatMonth ??
        (date) => defaultDropdownFormatMonth(date, locale);

    final effectiveDropdownFormatYear =
        calendar.dropdownFormatYear ??
        (date) => defaultDropdownFormatYear(date, locale);

    final effectiveFormatMonthYear =
        calendar.formatMonthYear ??
        (date) => defaultFormatMonthYear(date, locale);

    final effectiveFormatWeekday =
        calendar.formatWeekday ?? (date) => defaultFormatWeekday(date, locale);

    final models = widget.reverseMonths
        ? datesModels.reversed.toList()
        : datesModels;

    final effectiveShowNavigation =
        widget.showNavigation ?? calendar.showNavigation ?? true;

    final effectiveYearSelectorMinWidth = calendar.yearSelectorMinWidth ?? 64;

    final effectiveMonthSelectorMinWidth = calendar.monthSelectorMinWidth ?? 64;

    final effectiveYearSelectorPadding =
        calendar.yearSelectorPadding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final effectiveMonthSelectorPadding =
        calendar.monthSelectorPadding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final effectiveNavigationButtonSize = calendar.navigationButtonSize ?? 28;

    final effectiveNavigationButtonIconSize =
        calendar.navigationButtonIconSize ?? 16;

    final navigationButtonIconTheme = IconThemeData(
      size: effectiveNavigationButtonIconSize,
    );

    final effectiveBackNavigationButtonIcon = IconTheme.merge(
      data: navigationButtonIconTheme,
      child:
          calendar.backNavigationButtonIcon ??
          const PhosphorIcon(PhosphorIconsRegular.caretLeft),
    );

    final effectiveForwardNavigationButtonIcon = IconTheme.merge(
      data: navigationButtonIconTheme,
      child:
          calendar.forwardNavigationButtonIcon ??
          const PhosphorIcon(PhosphorIconsRegular.caretRight),
    );

    final effectiveNavigationButtonPadding =
        calendar.navigationButtonPadding ?? EdgeInsets.zero;

    final effectiveNavigationButtonDisabledOpacity =
        calendar.navigationButtonDisabledOpacity ?? .5;

    final effectiveDecoration =
        calendar.decoration ?? const FinesseDecoration();

    final effectiveSpacingBetweenMonths = calendar.spacingBetweenMonths ?? 16;

    final effectiveRunSpacingBetweenMonths =
        calendar.runSpacingBetweenMonths ?? 16;

    // A day cell is a fixed box around one or two digits, and the caption
    // row is as tall as a cell: neither has content to grow from, so both
    // follow the text scale (never below the style's own size).
    final textScale = math
        .max(
          1,
          MediaQuery.textScalerOf(context).scale(1),
        )
        .toDouble();
    final effectiveDayButtonSize = (calendar.dayButtonSize ?? 36) * textScale;

    // `--cell-radius` and `.cn-calendar-caption-label`'s height; theme-driven
    // (the variant derives both from the style tokens), with the theme's
    // global radius and the select's own height as the standalone fallbacks.
    final effectiveDayButtonRadius =
        calendar.dayButtonBorderRadius ?? theme.radius;
    final effectiveSelectorMinHeight = calendar.selectorMinHeight;

    // Seven day columns, plus one more of the same width when week numbers
    // are shown (`w-(--cell-size)`) — a fixed width would squeeze the day
    // cells whenever the extra column appears.
    final effectiveMonthConstraints =
        calendar.monthConstraints ??
        BoxConstraints(
          maxWidth:
              (7 + (effectiveShowWeekNumbers ? 1 : 0)) * effectiveDayButtonSize,
        );

    final effectiveHeaderHeight = (calendar.headerHeight ?? 38) * textScale;

    final effectiveHeaderPadding =
        calendar.headerPadding ?? const EdgeInsets.only(bottom: 16);

    final effectiveCaptionLayoutGap = calendar.captionLayoutGap ?? 8;

    final effectiveHeaderTextStyle =
        (calendar.headerTextStyle ?? theme.textTheme.small).fallback(
          color: theme.colorScheme.foreground,
        );

    final effectiveWeekdaysPadding =
        calendar.weekdaysPadding ?? const EdgeInsets.only(bottom: 8);

    final effectiveWeekdaysTextStyle =
        (calendar.weekdaysTextStyle ??
                theme.textTheme.muted.copyWith(fontSize: 12.8))
            .fallback(
              color: theme.colorScheme.mutedForeground,
            );

    final effectiveWeekdaysTextAlign =
        calendar.weekdaysTextAlign ?? TextAlign.center;

    final effectiveWeekNumbersHeaderText =
        calendar.weekNumbersHeaderText ?? '#';

    final effectiveWeekNumbersHeaderTextStyle =
        (calendar.weekNumbersHeaderTextStyle ??
                theme.textTheme.muted.copyWith(fontSize: 12.8))
            .fallback(color: theme.colorScheme.mutedForeground);

    final effectiveGridMainAxisSpacing = calendar.gridMainAxisSpacing ?? 8;

    final effectiveGridCrossAxisSpacing = calendar.gridCrossAxisSpacing ?? 0;

    final effectiveInsideRangeDayButtonTextStyle =
        (calendar.insideRangeDayButtonTextStyle ?? theme.textTheme.small)
            .fallback(
              color: theme.colorScheme.foreground,
            );

    final effectiveSelectedDayButtonTextStyle =
        (calendar.selectedDayButtonTextStyle ??
                theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.normal,
                ))
            .fallback(color: theme.colorScheme.primaryForeground);

    final effectiveDayButtonTextStyle =
        (calendar.dayButtonTextStyle ??
                theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.normal,
                ))
            .fallback(
              color: theme.colorScheme.foreground,
            );

    final effectiveDayButtonOutsideMonthTextStyle =
        (calendar.dayButtonOutsideMonthTextStyle ?? theme.textTheme.muted)
            .fallback(
              color: theme.colorScheme.mutedForeground,
            );

    final effectiveWeekNumbersTextStyle =
        (calendar.weekNumbersTextStyle ??
                theme.textTheme.muted.copyWith(fontSize: 12.8))
            .fallback(
              color: theme.colorScheme.mutedForeground,
            );

    final effectiveWeekNumbersTextAlign =
        calendar.weekNumbersTextAlign ?? TextAlign.center;

    final effectiveDayButtonOutsideMonthOpacity =
        calendar.dayButtonOutsideMonthOpacity ?? .5;

    final effectiveDayButtonPadding =
        calendar.dayButtonPadding ?? EdgeInsets.zero;

    final effectiveDayButtonVariant =
        calendar.dayButtonVariant ?? ButtonVariant.ghost;

    final effectiveSelectedDayButtonVariant =
        calendar.selectedDayButtonVariant ?? ButtonVariant.primary;

    final effectiveInsideRangeDayButtonVariant =
        calendar.insideRangeDayButtonVariant ?? ButtonVariant.secondary;

    final effectiveDayButtonOutsideMonthVariant =
        calendar.dayButtonOutsideMonthVariant ?? ButtonVariant.ghost;

    final effectiveSelectedOutsideMonthVariant =
        calendar.selectedDayButtonOutsideMonthVariant ??
        ButtonVariant.secondary;

    final effectiveTodayButtonVariant =
        calendar.todayButtonVariant ?? ButtonVariant.secondary;

    final effectiveAllowDeselection =
        widget.allowDeselection ?? calendar.allowDeselection ?? false;

    final yearSelector = Select<int>(
      initialValue: currentMonth.year,
      padding: effectiveYearSelectorPadding,
      minHeight: effectiveSelectorMinHeight,
      decoration: FinesseDecoration(
        // The dropdown trigger rounds with the cells
        // (`rounded-(--cell-radius)`), not with the field radius.
        border: FinesseBorder(borderRadius: effectiveDayButtonRadius),
        secondaryFocusedBorder: FinesseBorder.all(
          color: theme.colorScheme.ring.withValues(alpha: .5),
        ),
      ),
      minWidth: effectiveYearSelectorMinWidth,
      selectedOptionBuilder: (context, value) {
        return Text(
          effectiveDropdownFormatYear(DateTime(value, currentMonth.month)),
        );
      },
      options: availableYears.map(
        (year) => SelectOption(
          value: year,
          child: Text(effectiveFormatYear(DateTime(year))),
        ),
      ),
      onChanged: (year) {
        if (year != null) {
          goToMonth(DateTime(year, currentMonth.month));
        }
      },
    );

    final monthSelector = Select<int>(
      initialValue: currentMonth.month,
      minHeight: effectiveSelectorMinHeight,
      decoration: FinesseDecoration(
        border: FinesseBorder(borderRadius: effectiveDayButtonRadius),
        secondaryFocusedBorder: FinesseBorder.all(
          color: theme.colorScheme.ring.withValues(alpha: .5),
        ),
      ),
      padding: effectiveMonthSelectorPadding,
      minWidth: effectiveMonthSelectorMinWidth,
      selectedOptionBuilder: (context, value) {
        return Text(
          effectiveDropdownFormatMonth(DateTime(currentMonth.year, value)),
        );
      },
      options: List.generate(
        12,
        (index) {
          final d = DateTime(currentMonth.year, index + 1);
          return SelectOption(
            value: index + 1,
            child: Text(effectiveFormatMonth(d)),
          );
        },
      ),
      onChanged: (month) {
        if (month != null) {
          goToMonth(DateTime(currentMonth.year, month));
        }
      },
    );

    final backButton = ValueListenableBuilder<bool>(
      valueListenable: backMonthButtonHovered,
      builder: (context, isHovered, _) {
        return Opacity(
          opacity: isHovered ? 1 : effectiveNavigationButtonDisabledOpacity,
          child: IconButton.outline(
            width: effectiveNavigationButtonSize,
            height: effectiveNavigationButtonSize,
            padding: effectiveNavigationButtonPadding,
            enabled: !isPreviousMonthButtonDisabled,
            onHover: (hovered) => backMonthButtonHovered.value = hovered,
            icon: effectiveBackNavigationButtonIcon,
            onPressed: () => goToMonth(currentMonth.previousMonth),
          ),
        );
      },
    );

    final forwardButton = ValueListenableBuilder<bool>(
      valueListenable: forwardMonthButtonHovered,
      builder: (context, isHovered, _) {
        return Opacity(
          opacity: isHovered ? 1 : effectiveNavigationButtonDisabledOpacity,
          child: IconButton.outline(
            width: effectiveNavigationButtonSize,
            height: effectiveNavigationButtonSize,
            padding: effectiveNavigationButtonPadding,
            enabled: !isNextMonthButtonDisabled,
            onHover: (hovered) => forwardMonthButtonHovered.value = hovered,
            onPressed: () => goToMonth(currentMonth.nextMonth),
            icon: effectiveForwardNavigationButtonIcon,
          ),
        );
      },
    );

    final columnsCount = effectiveShowWeekNumbers ? 8 : 7;

    return Decorator(
      decoration: effectiveDecoration,
      child: Wrap(
        spacing: effectiveSpacingBetweenMonths,
        runSpacing: effectiveRunSpacingBetweenMonths,
        children: models.mapIndexed((index, dateModel) {
          final isFirstMonth = index == 0;
          final isLastMonth = index == models.length - 1;

          final labelNavigation = Row(
            textDirection: TextDirection.ltr,
            children: [
              if (isFirstMonth && effectiveShowNavigation) backButton,
              Expanded(
                child: Center(
                  child: Text(
                    effectiveFormatMonthYear(dateModel.month),
                    style: effectiveHeaderTextStyle,
                  ),
                ),
              ),
              if (isLastMonth && effectiveShowNavigation) forwardButton,
            ],
          );

          final month = ConstrainedBox(
            constraints: effectiveMonthConstraints,
            child: Column(
              children: [
                // month header and back/forward buttons
                Padding(
                  padding: effectiveHeaderPadding,
                  child: SizedBox(
                    height: effectiveHeaderHeight,
                    child:
                        !isFirstMonth &&
                            effectiveCaptionLayout !=
                                CalendarCaptionLayout.label
                        ? Center(
                            child: Text(
                              effectiveFormatMonthYear(dateModel.month),
                              style: effectiveHeaderTextStyle,
                            ),
                          )
                        : switch (effectiveCaptionLayout) {
                            CalendarCaptionLayout.label => labelNavigation,
                            CalendarCaptionLayout.dropdown => Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                if (effectiveShowNavigation) backButton,
                                Expanded(
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: monthSelector),
                                        SizedBox(
                                          width: effectiveCaptionLayoutGap,
                                        ),
                                        Flexible(child: yearSelector),
                                      ],
                                    ),
                                  ),
                                ),
                                if (effectiveShowNavigation) forwardButton,
                              ],
                            ),
                            CalendarCaptionLayout.dropdownMonths => Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                if (effectiveShowNavigation) backButton,
                                Expanded(
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: monthSelector),
                                        SizedBox(
                                          width: effectiveCaptionLayoutGap,
                                        ),
                                        Text(
                                          effectiveFormatYear(
                                            dateModel.month,
                                          ),
                                          style: effectiveHeaderTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (effectiveShowNavigation) forwardButton,
                              ],
                            ),
                            CalendarCaptionLayout.dropdownYears => Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                if (effectiveShowNavigation) backButton,
                                Expanded(
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: yearSelector),
                                        SizedBox(
                                          width: effectiveCaptionLayoutGap,
                                        ),
                                        Text(
                                          effectiveFormatMonth(
                                            dateModel.month,
                                          ),
                                          style: effectiveHeaderTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (effectiveShowNavigation) forwardButton,
                              ],
                            ),
                          },
                  ),
                ),
                // week days
                Offstage(
                  offstage: !effectiveShowWeekdayNames,
                  child: Padding(
                    padding: effectiveWeekdaysPadding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        columnsCount,
                        (index) {
                          if (effectiveShowWeekNumbers && index == 0) {
                            return Expanded(
                              child: Text(
                                effectiveWeekNumbersHeaderText,
                                style: effectiveWeekNumbersHeaderTextStyle,
                                textAlign: effectiveWeekdaysTextAlign,
                              ),
                            );
                          }
                          final date = dateModel.firstDateShown.addDays(
                            index - (effectiveShowWeekNumbers ? 1 : 0),
                          );
                          return Expanded(
                            child: Text(
                              effectiveFormatWeekday(date),
                              style: effectiveWeekdaysTextStyle,
                              textAlign: effectiveWeekdaysTextAlign,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Changing month brings the new grid in from the side it
                // lies on: later months from the end, earlier from the
                // start.
                ContentSwitch(
                  value: dateModel.month.year * 12 + dateModel.month.month,
                  child: Actions(
                    actions: {
                      DirectionalFocusAction:
                          CallbackAction<DirectionalFocusIntent>(
                            onInvoke: (intent) {
                              FocusScope.of(
                                context,
                              ).focusInDirection(intent.direction);
                              return null;
                            },
                          ),
                    },
                    child: Shortcuts(
                      shortcuts: {
                        LogicalKeySet(LogicalKeyboardKey.arrowUp):
                            const DirectionalFocusIntent(TraversalDirection.up),
                        LogicalKeySet(
                          LogicalKeyboardKey.arrowDown,
                        ): const DirectionalFocusIntent(
                          TraversalDirection.down,
                        ),
                        LogicalKeySet(
                          LogicalKeyboardKey.arrowLeft,
                        ): const DirectionalFocusIntent(
                          TraversalDirection.left,
                        ),
                        LogicalKeySet(
                          LogicalKeyboardKey.arrowRight,
                        ): const DirectionalFocusIntent(
                          TraversalDirection.right,
                        ),
                      },
                      child: GridView.count(
                        mainAxisSpacing: effectiveGridMainAxisSpacing,
                        crossAxisSpacing: effectiveGridCrossAxisSpacing,
                        crossAxisCount: columnsCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: dateModel.dates.mapIndexed((index, date) {
                          if (date == null) return const SizedBox.shrink();
                          final selected = switch (widget.variant) {
                            CalendarVariant.range => false,
                            CalendarVariant.single ||
                            CalendarVariant.multiple => selectedDays.any(
                              (selectedDate) => selectedDate.isSameDay(date),
                            ),
                          };

                          final isInRange = switch (widget.variant) {
                            CalendarVariant.range =>
                              (startRange != null &&
                                      date.isSameDayOrGreater(startRange!)) &&
                                  (endRange != null &&
                                      date.isSameDayOrLower(endRange!)),
                            CalendarVariant.single ||
                            CalendarVariant.multiple => false,
                          };

                          final isFirstDateInRange =
                              startRange != null && date.isSameDay(startRange!);
                          final isLastDateInRange =
                              endRange != null && date.isSameDay(endRange!);

                          final isToday = date.isSameDay(today);
                          final isInMonth = date.month == dateModel.month.month;
                          final textStyle = switch (widget.variant) {
                            CalendarVariant.range => () {
                              if (isFirstDateInRange || isLastDateInRange) {
                                return effectiveSelectedDayButtonTextStyle;
                              }

                              if (isInRange) {
                                return effectiveInsideRangeDayButtonTextStyle;
                              }

                              return effectiveDayButtonTextStyle;
                            }(),
                            CalendarVariant.single ||
                            CalendarVariant.multiple =>
                              isInMonth
                                  ? selected
                                        ? effectiveSelectedDayButtonTextStyle
                                        : effectiveDayButtonTextStyle
                                  : effectiveDayButtonOutsideMonthTextStyle,
                          };

                          final variant = switch (widget.variant) {
                            CalendarVariant.range => () {
                              if (isFirstDateInRange || isLastDateInRange) {
                                return effectiveSelectedDayButtonVariant;
                              }
                              if (isInRange) {
                                return effectiveInsideRangeDayButtonVariant;
                              }
                              if (isToday) return effectiveTodayButtonVariant;
                              return effectiveDayButtonVariant;
                            }(),
                            CalendarVariant.single ||
                            CalendarVariant.multiple => switch (isInMonth) {
                              true =>
                                selected
                                    ? effectiveSelectedDayButtonVariant
                                    : isToday
                                    ? effectiveTodayButtonVariant
                                    : effectiveDayButtonVariant,
                              false =>
                                selected
                                    ? effectiveSelectedOutsideMonthVariant
                                    : effectiveDayButtonOutsideMonthVariant,
                            },
                          };

                          if (effectiveShowWeekNumbers && index % 8 == 0) {
                            return Center(
                              child: Text(
                                date.weekNumber.toString(),
                                style: effectiveWeekNumbersTextStyle,
                                textAlign: effectiveWeekNumbersTextAlign,
                              ),
                            );
                          }

                          final isFirstOfRow =
                              (index - (effectiveShowWeekNumbers ? 1 : 0)) %
                                  7 ==
                              0;
                          final isLastOfRow =
                              (index - (effectiveShowWeekNumbers ? 1 : 0)) %
                                  7 ==
                              6;

                          final cellRadius = effectiveDayButtonRadius;
                          final effectiveDayButtonDecoration =
                              FinesseDecoration(
                                secondaryBorder: const FinesseBorder(
                                  padding: EdgeInsets.zero,
                                ),
                                border:
                                    isInRange &&
                                        !isFirstDateInRange &&
                                        !isLastDateInRange
                                    ? isFirstOfRow
                                          ? FinesseBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: cellRadius.topLeft,
                                                bottomLeft:
                                                    cellRadius.bottomLeft,
                                              ),
                                            )
                                          : isLastOfRow
                                          ? FinesseBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: cellRadius.topRight,
                                                bottomRight:
                                                    cellRadius.bottomRight,
                                              ),
                                            )
                                          : const FinesseBorder(
                                              borderRadius: BorderRadius.zero,
                                            )
                                    : FinesseBorder(borderRadius: cellRadius),
                                secondaryFocusedBorder: FinesseBorder.all(
                                  offset: 2,
                                  color: theme.colorScheme.ring.withValues(
                                    alpha: .5,
                                  ),
                                ),
                              ).merge(calendar.dayButtonDecoration);

                          return Center(
                            child: Opacity(
                              opacity: isInMonth
                                  ? 1
                                  : effectiveDayButtonOutsideMonthOpacity,
                              child: Button(
                                variant: variant,
                                width: effectiveDayButtonSize,
                                height: effectiveDayButtonSize,
                                decoration: effectiveDayButtonDecoration,
                                enabled: enabled(date),
                                padding: effectiveDayButtonPadding,
                                child: Text(
                                  date.day.toString(),
                                  style: textStyle,
                                ),
                                onPressed: () {
                                  // ignore the operation if the min is reached
                                  if (selectedDays.contains(date) &&
                                      widget.minSelected != null &&
                                      selectedDays.length ==
                                          widget.minSelected) {
                                    return;
                                  }

                                  if (widget.variant ==
                                      CalendarVariant.single) {
                                    final selectedDate =
                                        selectedDays.firstOrNull;
                                    selectedDays.clear();
                                    if (effectiveAllowDeselection &&
                                        (selectedDate?.isSameDay(date) ??
                                            false)) {
                                      widget.onChanged?.call(null);

                                      return;
                                    }
                                  }
                                  final startRangeEquals =
                                      startRange?.isSameDay(date) ?? false;
                                  final endDateEquals =
                                      endRange?.isSameDay(date) ?? false;

                                  final singleDateSelectedInRange =
                                      (startRangeEquals && endRange == null) ||
                                      (endDateEquals && startRange == null);

                                  // Skip the operation on the range if a single
                                  // date is selected and allowDeselection is
                                  // false
                                  if (widget.variant == CalendarVariant.range) {
                                    if (singleDateSelectedInRange &&
                                        !effectiveAllowDeselection) {
                                      return;
                                    }
                                  }

                                  setState(() {
                                    if (widget.variant ==
                                        CalendarVariant.range) {
                                      // deselect the range
                                      if (singleDateSelectedInRange) {
                                        startRange = null;
                                      } else {
                                        // select the start range
                                        if (startRange == null) {
                                          startRange = date;
                                        } else {
                                          // update the start range
                                          if (isFirstDateInRange ||
                                              isLastDateInRange) {
                                            startRange = date;
                                            endRange = null;
                                          } else {
                                            // update the start/end range based on the date position
                                            if (date.isBefore(startRange!)) {
                                              startRange = date;
                                            } else {
                                              endRange = date;
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      if (selectedDays.contains(date)) {
                                        selectedDays.remove(date);
                                      } else {
                                        selectedDays.add(date);
                                      }
                                    }
                                  });

                                  switch (widget.variant) {
                                    case CalendarVariant.single:
                                      widget.onChanged?.call(date);
                                    case CalendarVariant.multiple:
                                      widget.onValuesChanged?.call(
                                        selectedDays.toList(),
                                      );
                                    case CalendarVariant.range:
                                      widget.onRangeChanged?.call(
                                        DateTimeRange(
                                          start: startRange,
                                          end: endRange,
                                        ),
                                      );
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          // A month is seven cells wide whatever room there is. Where there
          // is less — a narrow screen, a large text scale — it is shown
          // whole and smaller rather than cut off.
          final monthWidth = effectiveMonthConstraints.maxWidth;
          if (!monthWidth.isFinite) return month;
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(width: monthWidth, child: month),
          );
        }).toList(),
      ),
    );
  }
}
