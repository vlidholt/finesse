import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/time_picker/time_picker_basic.dart';
import 'package:example/docs/examples/time_picker/time_picker_sheet.dart';
import 'package:example/docs/examples/time_picker/time_picker_trigger.dart';
import 'package:example/docs/examples/time_picker/time_picker_wheels.dart';

final timePickerDoc = ComponentDoc(
  slug: 'time_picker',
  title: 'Time Picker',
  description:
      'A field that shows a time and opens a way to change it: a '
      '`TimeField` in a popover on a desktop, wheels in a bottom sheet on '
      'a phone. It is the counterpart of `DatePicker`. `presentation` '
      'forces either one, `TimeWheelPicker` is the wheels on their own, '
      'and `TimePickerFormField` puts the picker in a form.',
  examples: [
    ComponentExample(
      id: 'time_picker_basic',
      title: 'Basic',
      description:
          'Controlled: `value` and `onChanged`. The clock, 12- or '
          '24-hour, follows the platform and the locale unless '
          '`use24HourFormat` says otherwise.',
      builder: (_) => const TimePickerBasicExample(),
    ),
    ComponentExample(
      id: 'time_picker_sheet',
      title: 'Wheels in a sheet',
      description:
          '`PickerPresentation.sheet` shows on any screen what a phone '
          'gets. The wheels turn a draft: Done reports it, Cancel or a '
          'tap outside drops it. `minuteInterval`, `min` and `max` shape '
          'the wheels, and Clear empties the time unless '
          '`allowDeselection` is false.',
      builder: (_) => const TimePickerSheetExample(),
    ),
    ComponentExample(
      id: 'time_picker_wheels',
      title: 'Wheels in the page',
      description:
          '`TimeWheelPicker` is controlled like any wheel and reports as '
          'it turns.',
      minPreviewHeight: 340,
      builder: (_) => const TimePickerWheelsExample(),
    ),
    ComponentExample(
      id: 'time_picker_trigger',
      title: 'Another trigger',
      description:
          '`triggerBuilder` replaces the button; `leading`, `trailing`, '
          '`variant`, `size` and `formatTime` restyle it.',
      builder: (_) => const TimePickerTriggerExample(),
    ),
  ],
);
