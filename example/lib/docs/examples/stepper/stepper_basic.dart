import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
