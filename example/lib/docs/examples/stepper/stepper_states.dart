import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
      controlsBuilder: (context, controls) => UnaRow(
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
