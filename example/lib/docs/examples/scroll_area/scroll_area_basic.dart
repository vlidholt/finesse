import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ScrollAreaBasicExample extends StatelessWidget {
  const ScrollAreaBasicExample({super.key});

  static final tags = [for (var i = 50; i > 0; i--) 'v1.2.0-beta.$i'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 192,
      height: 288,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radius,
      ),
      child: ScrollArea(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tags', style: theme.textTheme.small),
            const SizedBox(height: 16),
            for (final tag in tags) ...[
              Text(tag, style: theme.textTheme.muted),
              const Divider.horizontal(),
            ],
          ],
        ),
      ),
    );
  }
}
