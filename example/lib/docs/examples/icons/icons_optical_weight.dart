import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// One icon from 12 to 24 logical pixels, as `PhosphorIcon` draws it and as
/// the font has it.
///
/// The regular weight's line is a sixteenth of the icon, so on its own it
/// thins from 1.5 pixels at 24 to 0.75 at 12. A `PhosphorIcon` makes up
/// half of that loss with a fine outline in the icon's own colour: 1.25 at
/// 16, 1.13 at 12.
class IconsOpticalWeightExample extends StatelessWidget {
  const IconsOpticalWeightExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SizeRow(title: 'PhosphorIcon'),
        const Gap.lg(),
        // Strength 0 for a subtree adds nothing: every size is the font's
        // own line, which is what a plain Icon draws.
        Theme(
          data: theme.copyWith(
            phosphorIconTheme: const PhosphorIconTheme(strength: 0),
          ),
          child: const _SizeRow(title: 'Strength 0, or a plain Icon'),
        ),
      ],
    );
  }
}

class _SizeRow extends StatelessWidget {
  const _SizeRow({required this.title});

  final String title;

  // The icon sizes are the subject of the demo, not layout.
  static const _sizes = <double>[12, 14, 16, 18, 20, 24];
  static const _icon = PhosphorIconsRegular.chatCircleDots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.muted;
    final cell = _sizes.last + theme.layoutTheme.gap(GapSize.xl);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: theme.textTheme.small),
        const Gap.sm(),
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: theme.layoutTheme.gap(GapSize.md),
          children: [
            for (final size in _sizes)
              SizedBox(
                width: cell,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: _sizes.last,
                      child: Center(child: PhosphorIcon(_icon, size: size)),
                    ),
                    const Gap.xs(),
                    Text('${size.round()}', style: caption),
                    // The line this size is drawn with under the theme.
                    Text(
                      theme.phosphorIconTheme.strokeAt(size).toStringAsFixed(2),
                      style: caption,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
