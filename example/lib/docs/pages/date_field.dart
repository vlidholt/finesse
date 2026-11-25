import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/date_field/date_field_basic.dart';
import 'package:example/docs/examples/date_field/date_field_compact.dart';
import 'package:example/docs/examples/date_field/date_field_form.dart';

final dateFieldDoc = ComponentDoc(
  slug: 'date_field',
  title: 'Date Field',
  description:
      'A date typed into small number fields — day, month and year, in the '
      'order the locale writes them — with a button beside them that opens '
      'a calendar. It is the keyboard-first way to enter a date someone '
      'knows by heart, the sibling of `TimeField`; `DatePicker` is the '
      'button that shows a calendar, or wheels on a phone. `DateFormField` '
      'puts it in a form.',
  examples: [
    ComponentExample(
      id: 'date_field_basic',
      title: 'Typed, or picked from a calendar',
      description:
          'Typing fills a field and moves on once it is full; the up and '
          'down arrows step the field that has the focus. `onChanged` is '
          'called once the three fields spell a date. On a phone the '
          'calendar opens in a sheet.',
      builder: (_) => const DateFieldBasicExample(),
    ),
    ComponentExample(
      id: 'date_field_compact',
      title: 'Compact',
      description:
          '`showLabels` and `showCalendarButton` choose what shows beside '
          'the digits; `leading` and `trailing` sit at the ends. A date '
          'outside `min` and `max` is moved inside when the focus leaves.',
      builder: (_) => const DateFieldCompactExample(),
    ),
    ComponentExample(
      id: 'date_field_form',
      title: 'In a form',
      description:
          "The form's value is the date once the fields spell one, and null "
          'before.',
      builder: (_) => const DateFieldFormExample(),
    ),
  ],
);
