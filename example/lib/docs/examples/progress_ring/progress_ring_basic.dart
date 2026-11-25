import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A ring that follows a value: drag the slider and the arc eases to it.
/// The middle of a ring holds a number or an icon.
class ProgressRingBasicExample extends StatefulWidget {
  const ProgressRingBasicExample({super.key});

  @override
  State<ProgressRingBasicExample> createState() =>
      _ProgressRingBasicExampleState();
}

class _ProgressRingBasicExampleState extends State<ProgressRingBasicExample> {
  double value = .64;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: FinesseColumn(
        gap: GapSize.xl,
        mainAxisSize: MainAxisSize.min,
        children: [
          FinesseRow(
            gap: GapSize.xl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressRing(value: value, semanticLabel: 'Upload'),
              ProgressRing(
                value: value,
                size: 72,
                semanticLabel: 'Upload',
                child: Text('$percent%'),
              ),
              ProgressRing(
                value: value,
                size: 72,
                semanticLabel: 'Upload',
                child: PhosphorIcon(
                  value >= 1
                      ? PhosphorIconsRegular.check
                      : PhosphorIconsRegular.arrowUp,
                ),
              ),
            ],
          ),
          Slider(
            initialValue: value,
            label: 'Progress',
            onChanged: (next) => setState(() => value = next),
          ),
        ],
      ),
    );
  }
}
