import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/date_picker/date_picker_range.dart';
import 'package:example/docs/examples/date_picker/date_picker_sheet.dart';
import 'package:example/docs/examples/date_picker/date_picker_single.dart';
import 'package:example/docs/examples/date_picker/date_picker_trigger.dart';
import 'package:example/docs/examples/date_picker/date_picker_wheels.dart';

final datePickerDoc = ComponentDoc(
  slug: 'date_picker',
  title: 'Date Picker',
  description:
      'A button that shows a date and opens a way to change it: a '
      'calendar in a popover on a desktop, a calendar or wheels in a '
      'bottom sheet on a phone. `presentation` forces either one and '
      '`mode` chooses calendar or wheels. `DateRangePicker` picks a '
      'first and a last day, `DateWheelPicker` is the wheels on their '
      'own, and `DatePickerFormField` and `DateRangePickerFormField` put '
      'the pickers in a form.',
  examples: [
    ComponentExample(
      id: 'date_picker_single',
      title: 'A date',
      description:
          'Controlled: `value` and `onChanged`. `min` and `max` bound the '
          'choice; tapping the selected day clears it unless '
          '`allowDeselection` is false.',
      builder: (_) => const DatePickerSingleExample(),
    ),
    ComponentExample(
      id: 'date_picker_range',
      title: 'A range',
      description:
          '`DateRangePicker` holds a `DateTimeRange`. `minDays` and '
          '`maxDays` bound its length.',
      builder: (_) => const DatePickerRangeExample(),
    ),
    ComponentExample(
      id: 'date_picker_sheet',
      title: 'In a sheet: calendar and wheels',
      description:
          '`PickerPresentation.sheet` shows on any screen what a phone '
          'gets. On the calendar a tap is the choice; '
          '`DatePickerMode.wheel` turns a draft that Done reports.',
      builder: (_) => const DatePickerSheetExample(),
    ),
    ComponentExample(
      id: 'date_picker_wheels',
      title: 'Wheels in the page',
      description:
          '`DateWheelPicker` orders day, month and year the way the '
          'locale writes a date. `DateWheelMode.dateAndTime` adds a time, '
          'and `monthYear` drops the day.',
      minPreviewHeight: 340,
      builder: (_) => const DatePickerWheelsExample(),
    ),
    ComponentExample(
      id: 'date_picker_trigger',
      title: 'Another trigger',
      description:
          'The calendar inside is configured on the picker too: '
          '`captionLayout`, `numberOfMonths`, `weekStartsOn`, '
          '`showWeekNumbers`, `selectableDayPredicate` and '
          '`calendarTheme`.',
      builder: (_) => const DatePickerTriggerExample(),
    ),
  ],
);
