import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Duotone icons draw a fill layer under the outline. By default it is the
/// outline's colour at 20%; both the colour and the opacity can be set.
class IconsDuotoneExample extends StatelessWidget {
  const IconsDuotoneExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconTheme.merge(
      data: const IconThemeData(size: 40),
      child: Wrap(
        spacing: 28,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          // Size and colour come from the IconTheme, as an Icon's do.
          const PhosphorDuotoneIcon(PhosphorIconsDuotone.folderOpen),
          PhosphorDuotoneIcon(
            PhosphorIconsDuotone.chatCircleDots,
            color: scheme.tint,
          ),
          PhosphorDuotoneIcon(
            PhosphorIconsDuotone.sun,
            color: scheme.foreground,
            secondaryColor: scheme.warning,
            secondaryOpacity: .6,
          ),
          PhosphorDuotoneIcon(
            PhosphorIconsDuotone.heart,
            color: scheme.destructive,
            secondaryOpacity: .35,
          ),
        ],
      ),
    );
  }
}
