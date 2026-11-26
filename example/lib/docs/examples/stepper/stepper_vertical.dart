import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
