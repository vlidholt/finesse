import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A control of your own: `Pressable` supplies the behaviour and hands the
/// builder its states; `AnimatedFill` and `FocusRing` draw them.
class BuildingBlocksPressableExample extends StatefulWidget {
  const BuildingBlocksPressableExample({super.key});

  @override
  State<BuildingBlocksPressableExample> createState() =>
      _BuildingBlocksPressableExampleState();
}

class _BuildingBlocksPressableExampleState
    extends State<BuildingBlocksPressableExample> {
  int _likes = 12;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = theme.radii.full;

    return Pressable(
      // Tap, Enter and Space all end up here.
      onPressed: () => setState(() {
        _liked = !_liked;
        _likes += _liked ? 1 : -1;
      }),
      // Announced as a toggle: "selected" or "not selected".
      selected: _liked,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        final pressed = states.contains(WidgetState.pressed);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: radius,
          // Cross-fades between fills without the flash a colour lerp
          // gives when the two differ in alpha.
          child: AnimatedFill(
            color: _liked
                ? scheme.accent
                : pressed || hovered
                ? scheme.muted
                : null,
            borderColor: _liked ? scheme.accentBorder : scheme.border,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.layoutTheme.gap(GapSize.md),
                vertical: theme.layoutTheme.gap(GapSize.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.layoutTheme.gap(GapSize.sm),
                children: [
                  PhosphorIcon(
                    _liked
                        ? PhosphorIconsFill.heart
                        : PhosphorIconsRegular.heart,
                    size: 16,
                    color: _liked ? scheme.tint : scheme.foreground,
                  ),
                  Text('$_likes', style: theme.textTheme.small),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
