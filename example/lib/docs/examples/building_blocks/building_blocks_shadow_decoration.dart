import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The same translucent box and the same shadow, twice. A `BoxDecoration`
/// paints the shadow behind the whole box, where it shows through the fill
/// as a grey wash; `ShadowDecoration` paints it outside the box only, as
/// CSS does.
class BuildingBlocksShadowDecorationExample extends StatelessWidget {
  const BuildingBlocksShadowDecorationExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = theme.radii.xl;
    final fill = scheme.card.withValues(alpha: .4);
    final border = Border.all(color: scheme.foreground.withValues(alpha: .1));
    const shadows = [
      BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
    ];

    Widget sample(String label, Decoration decoration) {
      return FinesseColumn(
        mainAxisSize: MainAxisSize.min,
        gap: GapSize.md,
        children: [
          Container(width: 150, height: 96, decoration: decoration),
          Text(label, style: theme.textTheme.muted),
        ],
      );
    }

    return Wrap(
      spacing: theme.layoutTheme.gap(GapSize.xl),
      runSpacing: theme.layoutTheme.gap(GapSize.xl),
      alignment: WrapAlignment.center,
      children: [
        sample(
          'BoxDecoration',
          BoxDecoration(
            color: fill,
            border: border,
            borderRadius: radius,
            boxShadow: shadows,
          ),
        ),
        sample(
          'ShadowDecoration',
          // The same arguments, with `shadows` for `boxShadow`.
          ShadowDecoration.box(
            color: fill,
            border: border,
            borderRadius: radius,
            shadows: shadows,
          ),
        ),
      ],
    );
  }
}
