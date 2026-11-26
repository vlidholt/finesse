import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `Disabled` switches a whole group off at once: it takes no pointer, is
/// dimmed to the theme's disabled opacity and is skipped by Tab.
class BuildingBlocksDisabledExample extends StatefulWidget {
  const BuildingBlocksDisabledExample({super.key});

  @override
  State<BuildingBlocksDisabledExample> createState() =>
      _BuildingBlocksDisabledExampleState();
}

class _BuildingBlocksDisabledExampleState
    extends State<BuildingBlocksDisabledExample> {
  bool _locked = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: UnaColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        gap: GapSize.md,
        children: [
          Switch(
            value: _locked,
            onChanged: (value) => setState(() => _locked = value),
            label: const Text('Lock billing details'),
          ),
          Disabled(
            enabled: !_locked,
            // A "not allowed" cursor over the group while it is off.
            showForbiddenCursor: true,
            child: UnaColumn(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              gap: GapSize.sm,
              children: [
                const TextField(placeholder: Text('Company name')),
                const TextField(placeholder: Text('VAT number')),
                Button(onPressed: () {}, child: const Text('Save')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
