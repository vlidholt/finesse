import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A term in running text explains itself. The card opens above the line,
/// so it does not cover what the reader is about to read, and falls back
/// below where there is no room. openDelay and closeDelay set how long the
/// pointer has to rest and how long the card waits for it to come back.
class HoverCardTermExample extends StatelessWidget {
  const HoverCardTermExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Text.rich(
        TextSpan(
          style: textTheme.p,
          children: [
            const TextSpan(text: 'Each release is checked against the '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: HoverCard(
                showArrow: true,
                openDelay: const Duration(milliseconds: 400),
                closeDelay: const Duration(milliseconds: 150),
                anchor: const AnchorAuto(
                  offset: Offset(0, -4),
                  followerAnchor: Alignment.topCenter,
                  targetAnchor: Alignment.topCenter,
                  fallback: AnchorAuto(offset: Offset(0, 4)),
                ),
                builder: (context) => SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text('Error budget', style: textTheme.small),
                      Text(
                        'How much unreliability a service may spend in a '
                        'month before new features wait for fixes.',
                        style: textTheme.muted,
                      ),
                    ],
                  ),
                ),
                child: Text(
                  'error budget',
                  style: textTheme.p.copyWith(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                    decorationColor: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' before it ships.'),
          ],
        ),
      ),
    );
  }
}
