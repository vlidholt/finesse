import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/stepper/stepper_basic.dart';
import 'package:example/docs/examples/stepper/stepper_states.dart';
import 'package:example/docs/examples/stepper/stepper_vertical.dart';
import 'package:flutter/widgets.dart';

final stepperDoc = ComponentDoc(
  slug: 'stepper',
  title: 'Stepper',
  description:
      'A sequence of numbered steps with the current one opened: a '
      'checkout, a sign-up, a set-up wizard. Steps before the current one '
      'show as completed, and the line between two steps fills as the '
      'first of them is completed. On a desktop the steps run across the '
      'top; on a phone they run down the page and the current step opens '
      'under its title.',
  examples: [
    ComponentExample(
      id: 'stepper_basic',
      title: 'Default',
      description:
          'The stepper is controlled: it shows `currentStep` and reports '
          'taps on a step, Continue and Cancel. Only the current step is '
          'built, so what the user typed belongs in state above it. Every '
          'step header is a Tab stop, and a change of step is announced to '
          'a screen reader.',
      minPreviewHeight: 300,
      padding: const EdgeInsets.all(24),
      builder: (_) => const StepperBasicExample(),
    ),
    ComponentExample(
      id: 'stepper_vertical',
      title: 'Vertical',
      description:
          'What a phone shows by default: the steps run down and the '
          'current step opens under its title on a spring. `axis` asks for '
          'either arrangement anywhere.',
      minPreviewHeight: 420,
      padding: const EdgeInsets.all(24),
      builder: (_) => const StepperVerticalExample(),
    ),
    ComponentExample(
      id: 'stepper_states',
      title: 'States, icons and custom controls',
      description:
          '`StepState.error` marks a step in the destructive colour, '
          '`StepState.complete` completes one whatever its place, and '
          '`StepState.disabled` dims a step and takes it out of reach. '
          '`icon` replaces the number, and `controlsBuilder` builds the '
          'controls from a `StepperControls`. With no `axis` this one is '
          'vertical on a phone.',
      minPreviewHeight: 240,
      padding: const EdgeInsets.all(24),
      builder: (_) => const StepperStatesExample(),
    ),
  ],
);
