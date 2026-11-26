import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Outside a section the row is a plain tile: the parts of an order, held
/// open or closed by the parent through `open` and `onOpenChanged`.
class ExpansionTilePlainExample extends StatefulWidget {
  const ExpansionTilePlainExample({super.key});

  @override
  State<ExpansionTilePlainExample> createState() =>
      _ExpansionTilePlainExampleState();
}

class _ExpansionTilePlainExampleState extends State<ExpansionTilePlainExample> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: UnaColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        gap: GapSize.sm,
        children: [
          ExpansionTile(
            title: const Text('Order #2041'),
            subtitle: const Text('3 items · Delivered Tuesday'),
            value: const Text('€38.50'),
            open: _open,
            onOpenChanged: (open) => setState(() => _open = open),
            childrenPadding: EdgeInsetsDirectional.only(
              start: theme.layoutTheme.gap(GapSize.lg),
            ),
            children: const [
              ListTile(title: Text('Linen shirt'), value: Text('€24.00')),
              ListTile(title: Text('Canvas tote'), value: Text('€9.50')),
              ListTile(title: Text('Gift wrap'), value: Text('€5.00')),
            ],
          ),
          Button.outline(
            size: ButtonSize.sm,
            onPressed: () => setState(() => _open = !_open),
            child: Text(_open ? 'Fold it away' : 'Show the items'),
          ),
        ],
      ),
    );
  }
}
