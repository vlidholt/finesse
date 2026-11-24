import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The default tile takes the theme's accent fill and tint colour. Size,
/// colours and radius can each be overridden.
class IconTileBasicExample extends StatelessWidget {
  const IconTileBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const IconTile(icon: Icon(PhosphorIconsRegular.bookmarkSimple)),
        const IconTile(
          size: 32,
          iconSize: 18,
          icon: Icon(PhosphorIconsRegular.fileText),
        ),
        const IconTile(
          size: 56,
          iconSize: 28,
          icon: Icon(PhosphorIconsRegular.chartLineUp),
        ),
        IconTile(
          backgroundColor: scheme.successMuted,
          foregroundColor: scheme.success,
          icon: const Icon(PhosphorIconsRegular.checkCircle),
        ),
        IconTile(
          backgroundColor: scheme.muted,
          foregroundColor: scheme.mutedForeground,
          borderRadius: theme.radii.full,
          icon: const Icon(PhosphorIconsRegular.gear),
        ),
      ],
    );
  }
}
