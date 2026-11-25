import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A toolbar under a message, as a `Scaffold`'s bottom bar: icon actions,
/// and the one labelled button at the end.
class ToolbarBasicExample extends StatefulWidget {
  const ToolbarBasicExample({super.key});

  @override
  State<ToolbarBasicExample> createState() => _ToolbarBasicExampleState();
}

class _ToolbarBasicExampleState extends State<ToolbarBasicExample> {
  String last = 'Nothing yet';
  bool flagged = false;

  void _did(String what) => setState(() => last = what);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: 340,
        height: 420,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: theme.radii.xl2),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl2,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Scaffold(
            appBar: const AppBar(title: Text('Release notes')),
            bottomNavigationBar: Toolbar(
              trailing: Button(
                onPressed: () => _did('Replied'),
                child: const Text('Reply'),
              ),
              children: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.archive),
                  semanticLabel: 'Archive',
                  onPressed: () => _did('Archived'),
                ),
                IconButton.ghost(
                  icon: PhosphorIcon(
                    flagged
                        ? PhosphorIconsFill.flag
                        : PhosphorIconsRegular.flag,
                  ),
                  semanticLabel: flagged ? 'Remove the flag' : 'Flag',
                  onPressed: () => setState(() {
                    flagged = !flagged;
                    last = flagged ? 'Flagged' : 'Flag removed';
                  }),
                ),
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.trash),
                  semanticLabel: 'Delete',
                  onPressed: () => _did('Deleted'),
                ),
              ],
            ),
            body: PageContainer(
              scrollable: true,
              child: FinesseColumn(
                gap: GapSize.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(last, style: theme.textTheme.muted),
                  for (var i = 1; i <= 5; i++)
                    Card(
                      title: Text('Note $i'),
                      description: const Text(
                        'The page scrolls beneath the toolbar.',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
