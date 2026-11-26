import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SliderStepsExample extends StatelessWidget {
  const SliderStepsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          Slider(initialValue: 50, max: 100, divisions: 10),
          Slider(
            initialValue: 50,
            max: 100,
            divisions: 10,
            showDivisionMarks: false,
          ),
        ],
      ),
    );
  }
}
