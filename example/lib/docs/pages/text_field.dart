import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/text_field/text_field_basic.dart';
import 'package:example/docs/examples/text_field/text_field_clearable.dart';
import 'package:example/docs/examples/text_field/text_field_counter.dart';
import 'package:example/docs/examples/text_field/text_field_disabled.dart';
import 'package:example/docs/examples/text_field/text_field_password.dart';
import 'package:example/docs/examples/text_field/text_field_touch_selection.dart';

final textFieldDoc = ComponentDoc(
  slug: 'text_field',
  title: 'Text Field',
  description:
      'A single-line text field. `TextField` is the control; '
      '`TextFormField` is the same field inside a `UnaForm`.',
  examples: [
    ComponentExample(
      id: 'text_field_basic',
      title: 'Default',
      builder: (_) => const TextFieldBasicExample(),
    ),
    ComponentExample(
      id: 'text_field_password',
      title: 'Password',
      description:
          '`TextField.password` obscures the text and adds a button that '
          'reveals it. `leading` and `trailing` hold icons and actions.',
      builder: (_) => const TextFieldPasswordExample(),
    ),
    ComponentExample(
      id: 'text_field_clearable',
      title: 'Clearable',
      builder: (_) => const TextFieldClearableExample(),
    ),
    ComponentExample(
      id: 'text_field_counter',
      title: 'Character count',
      description:
          '`showCounter` counts against `maxLength`. `Textarea` takes it '
          'too.',
      builder: (_) => const TextFieldCounterExample(),
    ),
    ComponentExample(
      id: 'text_field_disabled',
      title: 'Disabled',
      builder: (_) => const TextFieldDisabledExample(),
    ),
    ComponentExample(
      id: 'text_field_touch_selection',
      title: 'Selection on touch',
      description:
          'On iOS and Android every field has selection handles, a '
          'horizontal `TextSelectionToolbar` and a `TextMagnifier`, styled '
          'by `ThemeData.textSelectionTheme`; a desktop keeps its pointer '
          'selection and menu. This field asks for the touch controls by '
          'name so they show here too.',
      builder: (_) => const TextFieldTouchSelectionExample(),
    ),
  ],
);
