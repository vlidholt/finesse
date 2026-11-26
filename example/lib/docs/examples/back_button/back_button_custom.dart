import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Another icon, another name. The name is what a screen reader says and,
/// on a desktop, the tooltip.
class BackButtonCustomExample extends StatelessWidget {
  const BackButtonCustomExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        BackButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
          semanticLabel: 'Back to inbox',
          onPressed: () {},
        ),
        CloseButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.caretDown),
          semanticLabel: 'Minimise',
          onPressed: () {},
        ),
        const BackButton(enabled: false),
      ],
    );
  }
}
