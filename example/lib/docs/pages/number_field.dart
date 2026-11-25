import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/number_field/number_field_basic.dart';
import 'package:example/docs/examples/number_field/number_field_form.dart';
import 'package:example/docs/examples/number_field/number_field_format.dart';
import 'package:example/docs/examples/number_field/number_field_stepper.dart';

final numberFieldDoc = ComponentDoc(
  slug: 'number_field',
  title: 'Number Field',
  description:
      'A field for a number, typed or stepped. It is controlled: `value` '
      'and `onChanged`. What is typed is clamped to `min` and `max` and '
      'written out again when the field loses the focus.',
  examples: [
    ComponentExample(
      id: 'number_field_basic',
      title: 'Default',
      description:
          'Stacked carets on a desktop; a minus and a plus at the two ends '
          'on a phone. A held button repeats, faster the longer it is held.',
      builder: (_) => const NumberFieldBasicExample(),
    ),
    ComponentExample(
      id: 'number_field_format',
      title: 'Decimals and formats',
      description:
          '`decimalDigits` sets the precision and `format` takes any '
          '`NumberFormat` from `package:intl`.',
      builder: (_) => const NumberFieldFormatExample(),
    ),
    ComponentExample(
      id: 'number_field_stepper',
      title: 'Stepper',
      description:
          '`NumberField.stepper` for a small count that is never typed.',
      builder: (_) => const NumberFieldStepperExample(),
    ),
    ComponentExample(
      id: 'number_field_form',
      title: 'In a form',
      description:
          '`NumberFormField` adds a label, a description and '
          'validation.',
      minPreviewHeight: 280,
      builder: (_) => const NumberFieldFormExample(),
    ),
  ],
);
