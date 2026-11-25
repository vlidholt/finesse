# Stepper

A sequence of numbered steps with the current one opened: a checkout, a sign-up, a set-up wizard. Steps before the current one show as completed, and the line between two steps fills as the first of them is completed. On a desktop the steps run across the top; on a phone they run down the page and the current step opens under its title.

## Default

The stepper is controlled: it shows `currentStep` and reports taps on a step, Continue and Cancel. Only the current step is built, so what the user typed belongs in state above it. Every step header is a Tab stop, and a change of step is announced to a screen reader.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class StepperBasicExample extends StatefulWidget {
  const StepperBasicExample({super.key});

  @override
  State<StepperBasicExample> createState() => _StepperBasicExampleState();
}

class _StepperBasicExampleState extends State<StepperBasicExample> {
  var _step = 1;

  // What the user typed lives here, above the stepper: only the current
  // step's content is built.
  final _name = TextEditingController(text: 'Elena Rossi');
  final _street = TextEditingController();
  final _card = TextEditingController();

  static const _last = 2;

  @override
  void dispose() {
    _name.dispose();
    _street.dispose();
    _card.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _step,
      // The stepper is controlled: it reports, the parent decides.
      onStepTapped: (step) => setState(() => _step = step),
      onContinue: () => setState(() => _step = _step == _last ? 0 : _step + 1),
      onCancel: _step == 0 ? null : () => setState(() => _step--),
      steps: [
        Step(
          title: const Text('Account'),
          subtitle: const Text('Who is ordering'),
          content: TextField(
            controller: _name,
            placeholder: const Text('Full name'),
          ),
        ),
        Step(
          title: const Text('Address'),
          subtitle: const Text('Where it goes'),
          content: TextField(
            controller: _street,
            placeholder: const Text('Street and number'),
          ),
        ),
        Step(
          title: const Text('Payment'),
          content: TextField(
            controller: _card,
            placeholder: const Text('Card number'),
          ),
        ),
      ],
    );
  }
}
```

## Vertical

What a phone shows by default: the steps run down and the current step opens under its title on a spring. `axis` asks for either arrangement anywhere.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class StepperVerticalExample extends StatefulWidget {
  const StepperVerticalExample({super.key});

  @override
  State<StepperVerticalExample> createState() => _StepperVerticalExampleState();
}

class _StepperVerticalExampleState extends State<StepperVerticalExample> {
  var _step = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget note(String text) => Text(text, style: theme.textTheme.muted);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      // A phone gets this arrangement by itself; `axis` asks for it
      // anywhere.
      child: Stepper(
        axis: Axis.vertical,
        currentStep: _step,
        onStepTapped: (step) => setState(() => _step = step),
        onContinue: () => setState(() => _step = (_step + 1) % 4),
        onCancel: _step == 0 ? null : () => setState(() => _step--),
        steps: [
          Step(
            title: const Text('Create the workspace'),
            subtitle: const Text('Demo Labs'),
            content: note('Pick a name your team will recognise.'),
          ),
          Step(
            title: const Text('Invite your team'),
            content: note('Send invitations now, or skip and do it later.'),
          ),
          Step(
            title: const Text('Connect a repository'),
            subtitle: const Text('Optional'),
            content: note('Link GitHub to see pull requests in threads.'),
          ),
          Step(
            title: const Text('Review'),
            content: note('Everything is ready. Have a last look.'),
          ),
        ],
      ),
    );
  }
}
```

## States, icons and custom controls

`StepState.error` marks a step in the destructive colour, `StepState.complete` completes one whatever its place, and `StepState.disabled` dims a step and takes it out of reach. `icon` replaces the number, and `controlsBuilder` builds the controls from a `StepperControls`. With no `axis` this one is vertical on a phone.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class StepperStatesExample extends StatefulWidget {
  const StepperStatesExample({super.key});

  @override
  State<StepperStatesExample> createState() => _StepperStatesExampleState();
}

class _StepperStatesExampleState extends State<StepperStatesExample> {
  var _step = 2;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _step,
      onStepTapped: (step) => setState(() => _step = step),
      // Your own controls in place of Continue and Cancel.
      controlsBuilder: (context, controls) => FinesseRow(
        gap: GapSize.sm,
        children: [
          Button.outline(
            enabled: !controls.isFirst,
            leading: const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
            onPressed: () => setState(() => _step--),
            child: const Text('Previous'),
          ),
          Button(
            enabled: !controls.isLast,
            trailing: const PhosphorIcon(PhosphorIconsRegular.arrowRight),
            onPressed: () => setState(() => _step++),
            child: Text(
              'Step ${controls.currentStep + 2} of ${controls.stepCount}',
            ),
          ),
        ],
      ),
      steps: const [
        Step(
          title: Text('Cart'),
          icon: PhosphorIcon(PhosphorIconsRegular.shoppingCart),
        ),
        Step(
          title: Text('Shipping'),
          subtitle: Text('Address not found'),
          // Whatever its place, this step says something is wrong.
          state: StepState.error,
          icon: PhosphorIcon(PhosphorIconsRegular.truck),
        ),
        Step(
          title: Text('Payment'),
          icon: PhosphorIcon(PhosphorIconsRegular.creditCard),
        ),
        Step(
          title: Text('Gift wrap'),
          subtitle: Text('Sold out'),
          state: StepState.disabled,
          icon: PhosphorIcon(PhosphorIconsRegular.gift),
        ),
        Step(
          title: Text('Done'),
          icon: PhosphorIcon(PhosphorIconsRegular.flagCheckered),
        ),
      ],
    );
  }
}
```
