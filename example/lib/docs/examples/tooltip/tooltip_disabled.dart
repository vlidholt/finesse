import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TooltipDisabledExample extends StatelessWidget {
  const TooltipDisabledExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A disabled button absorbs pointer events, so a wrapper reports the
    // hover on its behalf — the reference wraps its trigger in a span for
    // the same reason.
    return Tooltip(
      builder: (context) => const Text('This feature is currently unavailable'),
      child: FinesseGestureDetector(
        child: Button.outline(
          enabled: false,
          onPressed: () {},
          child: const Text('Disabled'),
        ),
      ),
    );
  }
}
