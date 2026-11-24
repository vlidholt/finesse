import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The same controls under three motion vocabularies. Motion belongs to the
/// theme: `ThemeData(motion: ...)` — or a `copyWith` of the theme around a
/// subtree, as here — changes how every component below it moves, and
/// `Motion.none` switches all of it off.
class MotionTokensExample extends StatefulWidget {
  const MotionTokensExample({super.key});

  @override
  State<MotionTokensExample> createState() => _MotionTokensExampleState();
}

class _MotionTokensExampleState extends State<MotionTokensExample> {
  static const choices = {
    'Lively': Motion.lively,
    'Calm': Motion.calm,
    'None': Motion.none,
  };

  String choice = 'Lively';
  String tab = 'one';
  bool on = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        ToggleGroup<String>(
          values: {choice},
          onChanged: (values) => setState(() => choice = values.single),
          children: [
            for (final name in choices.keys)
              ToggleGroupItem(value: name, child: Text(name)),
          ],
        ),
        // Everything below reads its motion from this theme.
        Theme(
          data: theme.copyWith(motion: choices[choice]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Tabs<String>(
                value: tab,
                onChanged: (value) => setState(() => tab = value),
                tabs: const [
                  Tab(value: 'one', child: Text('Overview')),
                  Tab(value: 'two', child: Text('Activity')),
                  Tab(value: 'three', child: Text('Settings')),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Switch(
                    value: on,
                    onChanged: (value) => setState(() => on = value),
                  ),
                  Checkbox(
                    value: on,
                    onChanged: (value) => setState(() => on = value),
                  ),
                  Button.outline(
                    onPressed: () => setState(() => on = !on),
                    child: const Text('Press me'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
