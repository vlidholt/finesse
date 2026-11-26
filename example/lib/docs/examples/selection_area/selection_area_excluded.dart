import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SelectionAreaExcludedExample extends StatefulWidget {
  const SelectionAreaExcludedExample({super.key});

  @override
  State<SelectionAreaExcludedExample> createState() =>
      _SelectionAreaExcludedExampleState();
}

class _SelectionAreaExcludedExampleState
    extends State<SelectionAreaExcludedExample> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionArea(
            onSelectionChanged: (content) {
              setState(() => selected = content?.plainText ?? '');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite code',
                  style: theme.textTheme.small,
                ),
                const Gap.xs(),
                Text('UNA-2026-TEAL', style: theme.textTheme.large),
                const Gap.sm(),
                // Chrome that should not end up on the clipboard.
                const SelectionContainer.disabled(
                  child: Badge.secondary(child: Text('Expires in 3 days')),
                ),
              ],
            ),
          ),
          const Gap.md(),
          Text(
            selected.isEmpty
                ? 'Nothing selected'
                : '${selected.length} characters selected',
            style: theme.textTheme.caption,
          ),
        ],
      ),
    );
  }
}
