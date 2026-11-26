import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Regular at rest, fill when selected: the same name in two classes, so a
/// toggle swaps the class and nothing else.
class IconsSelectedExample extends StatefulWidget {
  const IconsSelectedExample({super.key});

  @override
  State<IconsSelectedExample> createState() => _IconsSelectedExampleState();
}

class _IconsSelectedExampleState extends State<IconsSelectedExample> {
  bool liked = true;
  bool saved = false;
  bool following = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        IconButton.ghost(
          icon: PhosphorIcon(
            liked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
            color: liked ? scheme.destructive : null,
          ),
          semanticLabel: liked ? 'Unlike' : 'Like',
          onPressed: () => setState(() => liked = !liked),
        ),
        IconButton.ghost(
          icon: PhosphorIcon(
            saved
                ? PhosphorIconsFill.bookmarkSimple
                : PhosphorIconsRegular.bookmarkSimple,
            color: saved ? scheme.tint : null,
          ),
          semanticLabel: saved ? 'Remove from saved' : 'Save',
          onPressed: () => setState(() => saved = !saved),
        ),
        IconButton.ghost(
          icon: PhosphorIcon(
            following ? PhosphorIconsFill.bell : PhosphorIconsRegular.bell,
            color: following ? scheme.tint : null,
          ),
          semanticLabel: following ? 'Mute' : 'Notify me',
          onPressed: () => setState(() => following = !following),
        ),
      ],
    );
  }
}
