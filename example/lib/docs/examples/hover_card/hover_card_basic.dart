import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Rest the pointer on the name, move the focus to it, or press and hold it
/// on a touch screen: the card says who it is. Nothing in it is needed to
/// use the page, which is what makes it a hover card and not a popover.
class HoverCardBasicExample extends StatelessWidget {
  const HoverCardBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Reviewed by ', style: textTheme.p),
        HoverCard(
          builder: (context) => SizedBox(
            width: 260,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                const Avatar(null, fallback: Text('ML')),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text('Maya Lindqvist', style: textTheme.small),
                      Text(
                        'Type designer. Draws letters, mostly lowercase.',
                        style: textTheme.muted,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        spacing: 6,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsRegular.calendarBlank,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          Text('Joined March 2024', style: textTheme.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Something the keyboard can reach: focus opens the card too.
          child: Pressable(
            onPressed: () {},
            builder: (context, states) => FocusRing(
              visible: states.contains(WidgetState.focused),
              borderRadius: theme.radii.sm,
              child: Text(
                '@maya',
                style: textTheme.p.copyWith(
                  color: theme.colorScheme.tint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
