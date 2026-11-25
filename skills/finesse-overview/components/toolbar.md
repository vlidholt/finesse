# Toolbar

A bar of actions along the bottom of a screen: what can be done with what is showing. It has the surface of a `BottomNavigationBar` and follows the same theme, so in a style whose bottom bar floats it is a glass pill, and otherwise it spans the bottom edge.

## In a Scaffold

Give it to a `Scaffold` as its `bottomNavigationBar`: the page scrolls beneath it and is told how far to keep clear. `children` are the actions, usually `IconButton.ghost`s, and `trailing` the one that stands apart. The arrow keys move the focus along the bar.

```dart
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
```

## Docked

`floating: false` docks the bar under a hairline. `leading` stands at the start, and `alignment` places the actions in the width that is left. Plain text and icons take the colour and size of the bar.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `floating: false` docks the bar along the bottom edge, whatever the
/// style says. `leading` stands apart at the start, and `alignment` places
/// the actions in the width that is left.
class ToolbarDockedExample extends StatefulWidget {
  const ToolbarDockedExample({super.key});

  @override
  State<ToolbarDockedExample> createState() => _ToolbarDockedExampleState();
}

class _ToolbarDockedExampleState extends State<ToolbarDockedExample> {
  final formats = <String>{'bold'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl2,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.lg)),
            child: Text(
              'Select some text to format it.',
              style: theme.textTheme.muted,
            ),
          ),
          // No screen under the bar here, so no safe area to keep clear
          // of.
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: Toolbar(
              floating: false,
              alignment: MainAxisAlignment.end,
              leading: Text('${formats.length} on'),
              children: [
                for (final (name, icon) in const [
                  ('bold', PhosphorIconsRegular.textB),
                  ('italic', PhosphorIconsRegular.textItalic),
                  ('underline', PhosphorIconsRegular.textUnderline),
                  ('link', PhosphorIconsRegular.link),
                ])
                  Toggle(
                    value: formats.contains(name),
                    onChanged: (on) => setState(
                      () => on ? formats.add(name) : formats.remove(name),
                    ),
                    child: PhosphorIcon(icon, semanticLabel: name),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```
