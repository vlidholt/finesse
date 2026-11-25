import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Dots for the steps of a flow. The pill glides to the new page; a tap on
/// a dot, or the arrow keys while the dots have the focus, picks a page.
class PageIndicatorBasicExample extends StatefulWidget {
  const PageIndicatorBasicExample({super.key});

  @override
  State<PageIndicatorBasicExample> createState() =>
      _PageIndicatorBasicExampleState();
}

class _PageIndicatorBasicExampleState extends State<PageIndicatorBasicExample> {
  static const _steps = ['Welcome', 'Your profile', 'Interests', 'All set'];
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseColumn(
      gap: GapSize.lg,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_steps[step], style: theme.textTheme.h4),
        PageIndicator(
          count: _steps.length,
          index: step,
          onSelected: (index) => setState(() => step = index),
        ),
        FinesseRow(
          gap: GapSize.sm,
          mainAxisSize: MainAxisSize.min,
          children: [
            Button.outline(
              enabled: step > 0,
              onPressed: () => setState(() => step--),
              child: const Text('Back'),
            ),
            Button(
              enabled: step < _steps.length - 1,
              onPressed: () => setState(() => step++),
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
