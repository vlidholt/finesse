import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An inline `Sheet` as the scaffold's `bottomSheet`: a summary resting at
/// the foot of the page that pulls up into the whole order. It has no route
/// and no barrier, so the list behind it stays in use.
class ScaffoldSheetExample extends StatefulWidget {
  const ScaffoldSheetExample({super.key});

  @override
  State<ScaffoldSheetExample> createState() => _ScaffoldSheetExampleState();
}

class _ScaffoldSheetExampleState extends State<ScaffoldSheetExample> {
  static const _menu = {
    'Flat white': 3.6,
    'Cardamom bun': 4.2,
    'Sourdough toast': 5.5,
    'Oat porridge': 6.8,
    'Iced tea': 3.2,
    'Pastel de nata': 2.4,
    'Granola bowl': 7.1,
  };

  final _order = <String, int>{'Flat white': 1, 'Cardamom bun': 2};

  double get _total => _order.entries.fold(
    0,
    (sum, entry) => sum + _menu[entry.key]! * entry.value,
  );

  int get _count => _order.values.fold(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Order')),
        bottomSheet: Sheet(
          detents: const [SheetDetent.height(112), SheetDetent.fraction(.6)],
          draggable: true,
          showDragHandle: true,
          title: Text('$_count items · €${_total.toStringAsFixed(2)}'),
          description: const Text('Pull up to review the order'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final MapEntry(key: item, value: count) in _order.entries)
                ListTile(
                  title: Text(item),
                  subtitle: Text(
                    '$count × €${_menu[item]!.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton.ghost(
                    icon: const PhosphorIcon(PhosphorIconsRegular.minus),
                    semanticLabel: 'Remove one $item',
                    onPressed: () => setState(() {
                      if (count == 1) {
                        _order.remove(item);
                      } else {
                        _order[item] = count - 1;
                      }
                    }),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
                child: Button(
                  expands: true,
                  onPressed: _order.isEmpty ? null : () {},
                  child: const Text('Place order'),
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            for (final MapEntry(key: item, value: price) in _menu.entries)
              ListTile(
                title: Text(item),
                subtitle: Text('€${price.toStringAsFixed(2)}'),
                trailing: const PhosphorIcon(PhosphorIconsRegular.plus),
                onTap: () =>
                    setState(() => _order[item] = (_order[item] ?? 0) + 1),
              ),
          ],
        ),
      ),
    );
  }
}
