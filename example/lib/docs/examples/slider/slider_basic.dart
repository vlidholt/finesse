import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SliderBasicExample extends StatelessWidget {
  const SliderBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: Slider(
        initialValue: 33,
        max: 100,
      ),
    );
  }
}
