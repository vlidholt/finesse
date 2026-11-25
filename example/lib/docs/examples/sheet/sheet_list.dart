import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A sheet with a list of its own takes a `builder` and gives the list the
/// scroll controller it is handed. A pull up then raises the sheet to its
/// largest detent before the list scrolls, and a pull down from the top of
/// the list lowers it — and, from the smallest detent, closes it.
class SheetListExample extends StatelessWidget {
  const SheetListExample({super.key});

  static const _names = [
    'Maya Lindqvist',
    'Omar Rahimi',
    'Ines Carvalho',
    'Jonas Berg',
    'Aiko Tanaka',
    'Leila Haddad',
    'Tomás Rivera',
    'Freja Holm',
    'Noah Okafor',
    'Sofia Marin',
    'Elias Novak',
    'Priya Raman',
  ];

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      onPressed: () => showSheet<void>(
        context: context,
        builder: (context) => Sheet(
          title: const Text('Liked by'),
          detents: const [SheetDetent.medium, SheetDetent.large],
          builder: (context, controller) => ListView.builder(
            controller: controller,
            itemCount: _names.length,
            itemBuilder: (context, index) {
              final name = _names[index];
              return ListTile(
                leading: Avatar(null, fallback: Text(name[0])),
                title: Text(name),
                onTap: () => Navigator.of(context).pop(),
              );
            },
          ),
        ),
      ),
      child: const Text('Show who liked this'),
    );
  }
}
