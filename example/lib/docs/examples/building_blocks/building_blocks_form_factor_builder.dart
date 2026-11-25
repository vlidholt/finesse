import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// One screen, arranged twice. `FormFactorBuilder` follows the theme, so
/// re-theming a subtree for a phone is enough to see the other layout.
class BuildingBlocksFormFactorBuilderExample extends StatefulWidget {
  const BuildingBlocksFormFactorBuilderExample({super.key});

  @override
  State<BuildingBlocksFormFactorBuilderExample> createState() =>
      _BuildingBlocksFormFactorBuilderExampleState();
}

class _BuildingBlocksFormFactorBuilderExampleState
    extends State<BuildingBlocksFormFactorBuilderExample> {
  FormFactor _formFactor = FormFactor.desktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const list = _Panel(
      icon: PhosphorIconsRegular.tray,
      label: 'Conversations',
    );
    const detail = _Panel(
      icon: PhosphorIconsRegular.chatCircle,
      label: 'Conversation',
    );

    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        SegmentedControl<FormFactor>(
          value: _formFactor,
          onChanged: (value) => setState(() => _formFactor = value),
          segments: const [
            Segment(value: FormFactor.desktop, label: Text('Desktop')),
            Segment(value: FormFactor.mobile, label: Text('Mobile')),
          ],
        ),
        SizedBox(
          width: _formFactor == FormFactor.mobile ? 220 : 440,
          height: 180,
          // Cached per theme and form factor: fine to call in `build`.
          child: Theme(
            data: theme.withFormFactor(_formFactor),
            child: FormFactorBuilder(
              // A phone shows the list alone…
              mobile: (context) => list,
              // …a desktop the list beside what is open.
              desktop: (context) => Row(
                spacing: theme.layoutTheme.gap(GapSize.md),
                children: const [
                  Expanded(child: list),
                  Expanded(flex: 2, child: detail),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Center(
        child: FinesseColumn(
          mainAxisSize: MainAxisSize.min,
          gap: GapSize.sm,
          children: [
            PhosphorIcon(icon, color: theme.colorScheme.tint),
            Text(label, style: theme.textTheme.small),
          ],
        ),
      ),
    );
  }
}
