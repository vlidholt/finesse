import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/avatar_group/avatar_group_basic.dart';
import 'package:example/docs/examples/avatar_group/avatar_group_mixed.dart';

final avatarGroupDoc = ComponentDoc(
  slug: 'avatar_group',
  title: 'Avatar Group',
  description:
      'A row of overlapping avatars, each ringed in the colour of the '
      'surface behind it: the people who reacted, the mutual connections.',
  examples: [
    ComponentExample(
      id: 'avatar_group_basic',
      title: 'Default',
      description:
          'The first child is painted on top. The ring defaults to the '
          'card colour.',
      builder: (_) => const AvatarGroupBasicExample(),
    ),
    ComponentExample(
      id: 'avatar_group_mixed',
      title: 'Sizes, overlap and other children',
      description:
          'Every child is forced to `size` and clipped to a circle. Pass '
          '`ringColor` when the group does not sit on a card.',
      builder: (_) => const AvatarGroupMixedExample(),
    ),
  ],
);
