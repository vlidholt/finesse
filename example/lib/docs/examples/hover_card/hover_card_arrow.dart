import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// An arrow ties the card to one of several triggers in a row. The pointer
/// can travel into the card, and Tab reaches its button after the avatar:
/// the card stays for as long as either is in it.
class HoverCardArrowExample extends StatelessWidget {
  const HoverCardArrowExample({super.key});

  static const _people = [
    (initials: 'ML', name: 'Maya Lindqvist', role: 'Type designer'),
    (initials: 'OR', name: 'Omar Rahimi', role: 'Staff engineer'),
    (initials: 'EP', name: 'Elena Petrova', role: 'Product lead'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        for (final person in _people)
          HoverCard(
            showArrow: true,
            // Quick to open: these are small targets in a row, and the
            // next card should not keep the reader waiting.
            openDelay: const Duration(milliseconds: 250),
            builder: (context) => SizedBox(
              width: 220,
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(person.name, style: textTheme.small),
                        Text(person.role, style: textTheme.muted),
                      ],
                    ),
                  ),
                  Button.outline(
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Follow'),
                  ),
                ],
              ),
            ),
            child: Pressable(
              onPressed: () {},
              semanticLabel: person.name,
              builder: (context, states) => FocusRing(
                visible: states.contains(WidgetState.focused),
                borderRadius: BorderRadius.circular(999),
                child: Avatar(null, fallback: Text(person.initials)),
              ),
            ),
          ),
      ],
    );
  }
}
