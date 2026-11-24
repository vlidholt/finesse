import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The same widgets under both form factors. Nothing in `_Controls` knows
/// which one it is in; every size comes from the theme above it.
class FormFactorsSideBySideExample extends StatelessWidget {
  const FormFactorsSideBySideExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget column(FormFactor formFactor) {
      return SizedBox(
        width: 260,
        child: Theme(
          data: theme.withFormFactor(formFactor),
          child: _Controls(
            title: switch (formFactor) {
              FormFactor.desktop => 'Desktop',
              FormFactor.mobile => 'Mobile',
            },
          ),
        ),
      );
    }

    return Wrap(
      spacing: 40,
      runSpacing: 32,
      children: [
        column(FormFactor.desktop),
        column(FormFactor.mobile),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.style;
    return FinesseColumn(
      gap: GapSize.lg,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.h4),
        Text(
          'Buttons ${style.buttonHeight.round()}, fields '
          '${style.inputHeight.round()}, chips ${style.chipHeight.round()}, '
          'body text ${style.body.fontSize.round()}.',
          style: theme.textTheme.p,
        ),
        const TextField(placeholder: Text('Email')),
        Button(onPressed: () {}, child: const Text('Continue')),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Remote'), selected: true),
            Chip(label: Text('Hybrid')),
          ],
        ),
        const Checkbox(value: true, label: Text('Remember me')),
      ],
    );
  }
}
