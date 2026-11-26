import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The five named gaps, measured under each form factor. The bars are sized
/// by `Gap`s, so what you see is what a layout gets.
class LayoutGapScaleExample extends StatelessWidget {
  const LayoutGapScaleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 48,
      runSpacing: 24,
      children: [
        for (final formFactor in FormFactor.values)
          Theme(
            data: theme.withFormFactor(formFactor),
            child: _Scale(
              title: switch (formFactor) {
                FormFactor.desktop => 'Desktop',
                FormFactor.mobile => 'Mobile',
              },
            ),
          ),
      ],
    );
  }
}

class _Scale extends StatelessWidget {
  const _Scale({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(title, style: theme.textTheme.small),
        for (final size in GapSize.values.skip(1))
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  '${size.name}  ${layout.gap(size).round()}',
                  style: theme.textTheme.muted,
                ),
              ),
              // The gap itself, made visible: a row is as wide as its Gap.
              ColoredBox(
                color: theme.colorScheme.tint,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Gap.size(size), const SizedBox(height: 12)],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
