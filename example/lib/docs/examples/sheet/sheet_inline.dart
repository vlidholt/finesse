import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A `Sheet` placed in the tree is an inline sheet: no route and no barrier,
/// so what is behind it stays in use. Its detents are measured against its
/// parent, and it cannot be dragged away — only its parent can remove it.
class SheetInlineExample extends StatefulWidget {
  const SheetInlineExample({super.key});

  @override
  State<SheetInlineExample> createState() => _SheetInlineExampleState();
}

class _SheetInlineExampleState extends State<SheetInlineExample> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: theme.radii.lg,
      child: SizedBox(
        width: 340,
        height: 420,
        child: Stack(
          children: [
            // The page behind: still tappable.
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.muted,
                child: Align(
                  alignment: const Alignment(0, -.7),
                  child: Button.outline(
                    onPressed: () => setState(() => _taps++),
                    child: Text('Tapped $_taps times'),
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Sheet(
                detents: [SheetDetent.height(96), SheetDetent.fraction(.7)],
                // Draggable by a mouse too, anywhere on it.
                draggable: true,
                showDragHandle: true,
                title: Text('Now playing'),
                description: Text('Pull up for the queue'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(title: Text('Saudade'), subtitle: Text('3:42')),
                    ListTile(
                      title: Text('Bairro Alto'),
                      subtitle: Text('4:05'),
                    ),
                    ListTile(title: Text('Tejo'), subtitle: Text('2:58')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
