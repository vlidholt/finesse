import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/progress_bar/progress_bar_basic.dart';

final progressBarDoc = ComponentDoc(
  slug: 'progress_bar',
  title: 'Progress Bar',
  description:
      'A `ProgressBar` shows how much of a task is complete, or that work '
      'is under way when the amount is unknown.',
  examples: [
    ComponentExample(
      id: 'progress_bar_basic',
      title: 'Determinate and indeterminate',
      builder: (_) => const ProgressBarBasicExample(),
    ),
  ],
);
