import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/skeleton/skeleton_card.dart';
import 'package:example/docs/examples/skeleton/skeleton_cards.dart';
import 'package:example/docs/examples/skeleton/skeleton_chat.dart';
import 'package:example/docs/examples/skeleton/skeleton_controls.dart';
import 'package:example/docs/examples/skeleton/skeleton_list.dart';
import 'package:example/docs/examples/skeleton/skeleton_swap.dart';
import 'package:example/docs/examples/skeleton/skeleton_table.dart';
import 'package:example/docs/examples/skeleton/skeleton_text.dart';

final skeletonDoc = ComponentDoc(
  slug: 'skeleton',
  title: 'Skeleton',
  description:
      'A placeholder to show while content is loading, in the shape of the '
      'content it stands in for.',
  examples: [
    ComponentExample(
      id: 'skeleton_card',
      title: 'Default',
      description:
          'A block of any size: `width` and `height`, or the size its parent '
          'gives it; `Skeleton.circle` for a round one. In the una style '
          'a soft band of light sweeps across it; the shadcn styles pulse. '
          'Every skeleton moves to one clock, and the band is laid across '
          'the whole screen, so neighbours shimmer as one surface. Under '
          'reduced motion it holds still.',
      builder: (_) => const SkeletonCardExample(),
    ),
    ComponentExample(
      id: 'skeleton_text',
      title: 'Text',
      description:
          '`SkeletonText` is `lines` bars in a text `style`: each as tall as '
          'the text\'s capitals and spaced at its line height, so the block '
          'is as tall as the text that replaces it. The lines vary a little '
          'and the last is shorter (`lastLineWidthFactor`).',
      builder: (_) => const SkeletonTextExample(),
    ),
    ComponentExample(
      id: 'skeleton_list',
      title: 'List tiles',
      description:
          '`SkeletonListTile` has a list tile\'s padding, gap and text '
          'styles: an avatar by default as `leading` (null for none), a '
          'title, `subtitleLines` of subtitle and an optional `trailing` '
          'placeholder.',
      minPreviewHeight: 300,
      builder: (_) => const SkeletonListExample(),
    ),
    ComponentExample(
      id: 'skeleton_cards',
      title: 'Cards',
      description:
          '`SkeletonCard` is a real card with a media block across its top '
          '(`mediaAspectRatio`, null for none), a title, `lines` of '
          'description and `actions` button placeholders.',
      minPreviewHeight: 380,
      builder: (_) => const SkeletonCardsExample(),
    ),
    ComponentExample(
      id: 'skeleton_chat',
      title: 'Chat',
      description:
          '`SkeletonChatBubble` is a bubble of the chat bubble theme\'s '
          'corners and padding, `lines` tall, on the side its `direction` '
          'puts it, with the tail corner squared off.',
      minPreviewHeight: 300,
      builder: (_) => const SkeletonChatExample(),
    ),
    ComponentExample(
      id: 'skeleton_table',
      title: 'Table rows',
      description:
          '`SkeletonTableRow` has the table theme\'s row height and cell '
          'padding; `flex` shares the width between the columns and `row` '
          'varies the bars from one row to the next.',
      minPreviewHeight: 300,
      builder: (_) => const SkeletonTableExample(),
    ),
    ComponentExample(
      id: 'skeleton_controls',
      title: 'Avatars, chips and buttons',
      description:
          '`Skeleton.avatar`, `Skeleton.chip` and `Skeleton.button` take '
          'their size and corners from the component they stand in for.',
      builder: (_) => const SkeletonControlsExample(),
    ),
    ComponentExample(
      id: 'skeleton_swap',
      title: 'Swapping in the content',
      description:
          'Put the content in the skeleton\'s place once it has loaded. A '
          'placeholder in the real component\'s metrics keeps the page '
          'from jumping when it does.',
      builder: (_) => const SkeletonSwapExample(),
    ),
  ],
);
