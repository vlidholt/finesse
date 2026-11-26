import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
        const IconTile(icon: PhosphorIcon(PhosphorIconsRegular.bookmarkSimple)),
        const IconTile(
          size: 32,
          iconSize: 18,
          icon: PhosphorIcon(PhosphorIconsRegular.fileText),
        ),
        const IconTile(
          size: 56,
          iconSize: 28,
          icon: PhosphorIcon(PhosphorIconsRegular.chartLineUp),
        ),
        IconTile(
          backgroundColor: scheme.successMuted,
          foregroundColor: scheme.success,
          icon: const PhosphorIcon(PhosphorIconsRegular.checkCircle),
        ),
        IconTile(
          backgroundColor: scheme.muted,
          foregroundColor: scheme.mutedForeground,
          borderRadius: theme.radii.full,
          icon: const PhosphorIcon(PhosphorIconsRegular.gear),
        ),
      ],
    );
  }
}
