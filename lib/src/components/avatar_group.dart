import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A row of overlapping avatars, each ringed in the colour of the surface
/// behind it: the people who reacted, the mutual connections.
///
/// ```dart
/// AvatarGroup(
///   size: 20,
///   children: [
///     for (final person in mutuals) Avatar(person.photo),
///   ],
/// )
/// ```
///
/// The first child is painted on top. Every child is forced to [size] and
/// clipped to a circle, so anything works as a child — an avatar, an image, a
/// coloured reaction icon.
class AvatarGroup extends StatelessWidget {
  /// Creates a group of overlapping avatars.
  const AvatarGroup({
    required this.children,
    this.size = 24,
    this.overlap,
    this.ringWidth = 2,
    this.ringColor,
    super.key,
  });

  /// The avatars, first on top.
  final List<Widget> children;

  /// The diameter each child is forced to.
  final double size;

  /// How far each avatar slides under the one before it. Defaults to a
  /// quarter of [size].
  final double? overlap;

  /// The width of the ring around each avatar.
  final double ringWidth;

  /// The ring's colour. Defaults to the theme's card colour.
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final ring = ringColor ?? theme.colorScheme.card;
    final step = size - (overlap ?? size / 4);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final count = children.length;
    return SizedBox(
      width: size + step * (count - 1) + ringWidth * 2,
      height: size + ringWidth * 2,
      child: Stack(
        children: [
          // Painted last-to-first so the first avatar ends up on top.
          for (var i = count - 1; i >= 0; i--)
            Positioned(
              left: rtl ? null : i * step,
              right: rtl ? i * step : null,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(ringWidth),
                decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
                child: ClipOval(
                  child: SizedBox.square(
                    dimension: size,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: children[i],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
