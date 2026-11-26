import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The same controls under three motion vocabularies. Motion belongs to the
/// theme: `ThemeData(motion: ...)` — or a `copyWith` of the theme around a
/// subtree, as here — changes how every component below it moves, and
/// `Motion.none` switches all of it off.
///
/// `ThemeData.copyWith` derives every component theme again, so the scoped
/// theme is made when the theme above or the choice changes and kept in the
/// state — not made again on every build.
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

  /// The theme above with the chosen motion.
  late ThemeData scoped;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scoped = Theme.of(context).copyWith(motion: choices[choice]);
  }

  void choose(String name) {
    setState(() {
      choice = name;
      scoped = Theme.of(context).copyWith(motion: choices[name]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        ToggleGroup<String>(
          value: choice,
          // One vocabulary is always chosen: without this, tapping the
          // selected item would clear the selection.
          allowDeselection: false,
          onChanged: (value) => choose(value!),
          items: [
            for (final name in choices.keys)
              ToggleGroupItem(value: name, child: Text(name)),
          ],
        ),
        // Everything below reads its motion from this theme.
        Theme(
          data: scoped,
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
