import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/calendar/calendar_multiple.dart';
import 'package:example/docs/examples/calendar/calendar_range.dart';
import 'package:example/docs/examples/calendar/calendar_single.dart';
import 'package:example/docs/examples/calendar/calendar_theme.dart';

final calendarDoc = ComponentDoc(
  slug: 'calendar',
  title: 'Calendar',
  description:
      'A month calendar that selects a day, several days or a range. Its '
      'parameters say what it does: bounds, how many months show, where '
      'the week starts, how the caption is laid out. How it looks is the '
      "theme's `CalendarTheme`, which `calendarTheme` overrides for one "
      'calendar. Cells grow with the text scale and a month that does '
      'not fit its room is shown whole, smaller. `DatePicker` puts a '
      'calendar behind a button.',
  examples: [
    ComponentExample(
      id: 'calendar_single',
      title: 'One day',
      description: '`value` and `onChanged`.',
      builder: (_) => const CalendarSingleExample(),
    ),
    ComponentExample(
      id: 'calendar_range',
      title: 'A range',
      description:
          '`Calendar.range` takes `range` and `onRangeChanged`. `min` and '
          '`max` are the earliest and latest day; `minDays` and `maxDays` '
          'bound the length of the range.',
      builder: (_) => const CalendarRangeExample(),
    ),
    ComponentExample(
      id: 'calendar_multiple',
      title: 'Several days',
      description:
          '`Calendar.multiple` takes `values` and `onValuesChanged`. '
          '`selectableDayPredicate` disables days one by one, '
          '`captionLayout` puts the month and year in dropdowns, and '
          '`showWeekNumbers` adds a column.',
      builder: (_) => const CalendarMultipleExample(),
    ),
    ComponentExample(
      id: 'calendar_theme',
      title: 'Restyled',
      description:
          'Cell size and radius, button variants, text styles and the '
          'formats of the labels are all fields of `CalendarTheme`.',
      builder: (_) => const CalendarThemeExample(),
    ),
  ],
);
