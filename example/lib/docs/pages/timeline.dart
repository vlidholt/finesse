import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/timeline/timeline_activity.dart';
import 'package:example/docs/examples/timeline/timeline_experience.dart';

final timelineDoc = ComponentDoc(
  slug: 'timeline',
  title: 'Timeline',
  description:
      'A vertical sequence of entries joined by a line: work experience, '
      'an activity log, the steps of an order.',
  examples: [
    ComponentExample(
      id: 'timeline_experience',
      title: 'Default',
      description:
          'Each `TimelineEntry` pairs a `marker` in the gutter with a '
          '`child` beside it. The line stops at the last entry.',
      minPreviewHeight: 320,
      builder: (_) => const TimelineExperienceExample(),
    ),
    ComponentExample(
      id: 'timeline_activity',
      title: 'Compact, with icon markers',
      description:
          '`gap` is the space between a marker and its content, '
          '`spacing` the space between entries, and `lineColor` the '
          'colour of the line.',
      minPreviewHeight: 320,
      builder: (_) => const TimelineActivityExample(),
    ),
  ],
);
