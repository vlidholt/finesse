import 'package:flutter/widgets.dart';
import 'package:una/src/theme/theme.dart';

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
    this.ringInLayout = false,
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

  /// Whether the ring takes up layout space.
  ///
  /// By default it does not: the group is exactly as tall as [size] and as
  /// wide as the avatars, and the ring is painted around them, the way a CSS
  /// `box-shadow` ring is. That keeps the first avatar aligned with text
  /// beside or above it. Set this when the group sits against a clipping
  /// edge.
  final bool ringInLayout;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final ring = ringColor ?? theme.colorScheme.card;
    final step = size - (overlap ?? size / 4);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final count = children.length;
    final inset = ringInLayout ? 0.0 : -ringWidth;
    return SizedBox(
      width: size + step * (count - 1) + (ringInLayout ? ringWidth * 2 : 0),
      height: size + (ringInLayout ? ringWidth * 2 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Painted last-to-first so the first avatar ends up on top.
          for (var i = count - 1; i >= 0; i--)
            Positioned(
              left: rtl ? null : i * step + inset,
              right: rtl ? i * step + inset : null,
              top: inset,
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
