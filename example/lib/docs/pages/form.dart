import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/form/form_fields.dart';
import 'package:example/docs/examples/form/form_more_fields.dart';
import 'package:example/docs/examples/form/form_otp.dart';
import 'package:example/docs/examples/form/form_profile.dart';

final formDoc = ComponentDoc(
  slug: 'form',
  title: 'Form',
  description:
      'Building forms with UnaForm: field values collect under their ids, '
      'and validation runs per field.',
  examples: [
    ComponentExample(
      id: 'form_profile',
      title: 'Validation and submit',
      description:
          'saveAndValidate runs every validator and returns whether the '
          'form is valid. Values collect in formKey.currentState!.value.',
      builder: (_) => const FormProfileExample(),
    ),
    ComponentExample(
      id: 'form_fields',
      title: 'Every field type',
      description:
          'Text field, select, textarea, radio group, date picker, time picker, '
          'and switch, all as form fields.',
      minPreviewHeight: 480,
      builder: (_) => const FormFieldsExample(),
    ),
    ComponentExample(
      id: 'form_more_fields',
      title: 'The richer controls',
      description:
          'Autocomplete, date field, chip group, tag field, range slider, '
          'rating and colour picker as form fields. A failed validation '
          'moves the focus to the first field that failed.',
      minPreviewHeight: 640,
      builder: (_) => const FormMoreFieldsExample(),
    ),
    ComponentExample(
      id: 'form_otp',
      title: 'OTP verification',
      builder: (_) => const FormOtpExample(),
    ),
  ],
);
