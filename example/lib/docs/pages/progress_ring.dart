import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/progress_ring/progress_ring_basic.dart';
import 'package:example/docs/examples/progress_ring/progress_ring_gauge.dart';

final progressRingDoc = ComponentDoc(
  slug: 'progress_ring',
  title: 'Progress Ring',
  description:
      'A ring that fills as something progresses — an upload, a quota, a '
      'goal — or spins while the length is unknown. The circular counterpart '
      'of the progress bar.',
  examples: [
    ComponentExample(
      id: 'progress_ring_basic',
      title: 'A value, with something in the middle',
      description:
          '`value` runs from 0 to 1 and the arc eases to each new value on '
          'the theme\'s smooth spring. `child` is centred in the ring: a '
          'percentage, an icon. Colours come from the progress bar\'s theme.',
      minPreviewHeight: 260,
      builder: (_) => const ProgressRingBasicExample(),
    ),
    ComponentExample(
      id: 'progress_ring_gauge',
      title: 'Gauges and unknown length',
      description:
          'A `sweepAngle` of less than a full turn opens the ring at the '
          'bottom. With `value: null` the ring spins: the arc turns while '
          'it grows and shrinks, as Material\'s indeterminate indicator '
          'does, and under reduced motion it holds still and breathes. '
          '`Spinner` is the small inline indicator for a button or a line '
          'of text, this same ring by default.',
      minPreviewHeight: 220,
      builder: (_) => const ProgressRingGaugeExample(),
    ),
  ],
);
