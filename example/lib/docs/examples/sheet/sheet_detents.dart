import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Detents are the sizes a sheet rests at. Drag it, fling it, press the
/// arrow keys with the handle focused, or send it somewhere with a
/// `SheetController`.
class SheetDetentsExample extends StatelessWidget {
  const SheetDetentsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      onPressed: () => showSheet<void>(
        context: context,
        builder: (context) => const _TripSheet(),
      ),
      child: const Text('Plan a trip'),
    );
  }
}

class _TripSheet extends StatefulWidget {
  const _TripSheet();

  @override
  State<_TripSheet> createState() => _TripSheetState();
}

class _TripSheetState extends State<_TripSheet> {
  final _sheet = SheetController();
  var _detent = SheetDetent.medium;

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expanded = _detent == SheetDetent.large;
    return Sheet(
      controller: _sheet,
      detents: const [SheetDetent.medium, SheetDetent.large],
      onDetentChanged: (detent) => setState(() => _detent = detent),
      title: const Text('Lisbon, three days'),
      description: Text(expanded ? 'The whole plan' : 'Day one'),
      actions: [
        Button.outline(
          onPressed: () => _sheet.animateTo(
            expanded ? SheetDetent.medium : SheetDetent.large,
          ),
          child: Text(expanded ? 'Show less' : 'Show all three days'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (day, plan) in const [
            ('Friday', 'Alfama on foot, then fado after dinner.'),
            ('Saturday', 'The tram to Belém and back along the river.'),
            ('Sunday', 'Sintra by train, home on the late one.'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: theme.textTheme.small),
                  Text(plan, style: theme.textTheme.muted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
