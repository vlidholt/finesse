import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A back button, a title and two actions. Without a `middle`, the title
/// takes the space between the leading widget and the actions. The buttons
/// name no variant: the bar gives them the look for what it is drawn on.
class AppBarBasicExample extends StatelessWidget {
  const AppBarBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 520,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl,
      ),
      // Painted over the content, so nothing covers the frame's corners.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radii.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            // Not at the top of the screen here, so no status bar inset.
            primary: false,
            leading: IconButton(
              icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
              semanticLabel: 'Back',
              onPressed: () {},
            ),
            title: const Text('Messages'),
            actions: [
              IconButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
                semanticLabel: 'Search',
                onPressed: () {},
              ),
              IconButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.notePencil),
                semanticLabel: 'New message',
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(
            height: 120,
            child: Center(
              child: Text('Page content', style: theme.textTheme.muted),
            ),
          ),
        ],
      ),
    );
  }
}
