import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/time_field/time_field_basic.dart';
import 'package:example/docs/examples/time_field/time_field_period.dart';
import 'package:example/docs/examples/time_field/time_field_seconds.dart';

final timeFieldDoc = ComponentDoc(
  slug: 'time_field',
  title: 'Time Field',
  description:
      'A time typed into small number fields: hours, minutes and, '
      'optionally, seconds, with a day period on the 12-hour clock. It is '
      'the inline, keyboard-first way to enter a time; `TimePicker` is '
      'the button that opens one in a popover, or wheels on a phone. '
      '`TimeFormField` puts it in a form.',
  examples: [
    ComponentExample(
      id: 'time_field_basic',
      title: '24-hour',
      description:
          '`value` and `onChanged` hold the time in the parent; '
          '`initialValue` lets the field keep it. `onChanged` is called '
          'once every field that shows is filled.',
      builder: (_) => const TimeFieldBasicExample(),
    ),
    ComponentExample(
      id: 'time_field_period',
      title: '12-hour, with a day period',
      description:
          'The time reported is always on the 24-hour clock: 4:45 PM is '
          '`TimeOfDay(hour: 16, minute: 45)`.',
      builder: (_) => const TimeFieldPeriodExample(),
    ),
    ComponentExample(
      id: 'time_field_seconds',
      title: 'Which fields show',
      description:
          '`showHours`, `showMinutes`, `showSeconds` and `showLabels` '
          'choose the fields; `leading` and `trailing` sit beside them.',
      builder: (_) => const TimeFieldSecondsExample(),
    ),
  ],
);
