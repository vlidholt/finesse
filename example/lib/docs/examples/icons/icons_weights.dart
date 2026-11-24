import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// One icon in each of the six weights. Five are `IconData` for a plain
/// `Icon`; duotone is two glyphs and has its own widget.
class IconsWeightsExample extends StatelessWidget {
  const IconsWeightsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget weight(String name, Widget icon) {
      return SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            icon,
            Text(name, style: theme.textTheme.muted),
          ],
        ),
      );
    }

    return IconTheme.merge(
      data: const IconThemeData(size: 32),
      child: Wrap(
        spacing: 8,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          weight('Thin', const Icon(PhosphorIconsThin.bellRinging)),
          weight('Light', const Icon(PhosphorIconsLight.bellRinging)),
          weight('Regular', const Icon(PhosphorIconsRegular.bellRinging)),
          weight('Bold', const Icon(PhosphorIconsBold.bellRinging)),
          weight('Fill', const Icon(PhosphorIconsFill.bellRinging)),
          weight(
            'Duotone',
            const PhosphorDuotoneIcon(PhosphorIconsDuotone.bellRinging),
          ),
        ],
      ),
    );
  }
}
