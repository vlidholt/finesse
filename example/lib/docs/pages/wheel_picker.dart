import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/wheel_picker/wheel_picker_basic.dart';
import 'package:example/docs/examples/wheel_picker/wheel_picker_builder.dart';
import 'package:example/docs/examples/wheel_picker/wheel_picker_disabled.dart';
import 'package:example/docs/examples/wheel_picker/wheel_picker_group.dart';

final wheelPickerDoc = ComponentDoc(
  slug: 'wheel_picker',
  title: 'Wheel Picker',
  description:
      'A wheel of rows, one of which rests under a lens: the way a phone '
      'chooses from a short, ordered list. It scrolls with momentum and '
      'settles on a row, ticks under a finger, moves a row per notch of a '
      'mouse wheel and follows the arrow keys. `TimePicker` and '
      '`DatePicker` open wheels in a sheet on a phone.',
  examples: [
    ComponentExample(
      id: 'wheel_picker_basic',
      title: 'One wheel',
      description:
          'Controlled: `onChanged` reports the row under the lens as the '
          'wheel turns, and the wheel rests on `value`. Drag it, click a '
          'row, or focus it and type.',
      minPreviewHeight: 320,
      builder: (_) => const WheelPickerBasicExample(),
    ),
    ComponentExample(
      id: 'wheel_picker_group',
      title: 'A group under one lens',
      description:
          '`WheelPickerGroup` draws the lens once across its children and '
          'gives its wheels one row height. A child that is not a wheel, '
          'such as a unit, is centred on the lens. `looping` makes a '
          'wheel go round.',
      minPreviewHeight: 320,
      builder: (_) => const WheelPickerGroupExample(),
    ),
    ComponentExample(
      id: 'wheel_picker_builder',
      title: 'A long list',
      description:
          '`WheelPicker.builder` makes rows on demand; `indexOf` is the '
          'inverse of `itemBuilder`. A value set from outside is rolled '
          'to.',
      minPreviewHeight: 320,
      builder: (_) => const WheelPickerBuilderExample(),
    ),
    ComponentExample(
      id: 'wheel_picker_disabled',
      title: 'Rows that cannot be chosen',
      description:
          'A row with `enabled: false` is dimmed, skipped by the '
          'keyboard, and never rested on.',
      minPreviewHeight: 320,
      builder: (_) => const WheelPickerDisabledExample(),
    ),
  ],
);
