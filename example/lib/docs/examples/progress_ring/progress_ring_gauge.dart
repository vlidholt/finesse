import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A gauge is a ring that stops short of a full turn, and a ring with no
/// value spins: progress of unknown length at any size.
class ProgressRingGaugeExample extends StatelessWidget {
  const ProgressRingGaugeExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnaRow(
      gap: GapSize.xl,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressRing(
          value: .72,
          size: 104,
          strokeWidth: 8,
          sweepAngle: math.pi * 1.5,
          semanticLabel: 'Profile strength',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '72',
                style: theme.textTheme.h3.copyWith(
                  color: theme.colorScheme.foreground,
                ),
              ),
              Text('of 100', style: theme.textTheme.caption),
            ],
          ),
        ),
        ProgressRing(
          value: .9,
          size: 104,
          strokeWidth: 8,
          sweepAngle: math.pi,
          color: theme.colorScheme.warning,
          semanticLabel: 'Storage',
          semanticValue: '45 of 50 GB',
          child: const Text('45 GB'),
        ),
        const ProgressRing(value: null, size: 56, semanticLabel: 'Syncing'),
      ],
    );
  }
}
