import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Another icon, another name. The name is what a screen reader says and,
/// on a desktop, the tooltip.
class BackButtonCustomExample extends StatelessWidget {
  const BackButtonCustomExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
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
