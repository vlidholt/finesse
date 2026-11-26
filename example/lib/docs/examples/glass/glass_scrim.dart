import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Labels over a photo. `color` replaces the theme's tint with a dark scrim,
/// used at its own alpha, so white text stays readable in light and dark.
class GlassScrimExample extends StatelessWidget {
  const GlassScrimExample({super.key});

  static const _scrim = Color(0x52090909);
  static const _onScrim = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget label({required IconData icon, required String text}) {
      return Glass(
        color: _scrim,
        borderRadius: theme.radii.full,
        // No hairline: the scrim is the whole surface.
        border: const Border.fromBorderSide(BorderSide.none),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            PhosphorIcon(icon, size: 16, color: _onScrim),
            Text(
              text,
              style: theme.textTheme.small.copyWith(color: _onScrim),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: theme.radii.xl2,
      child: SizedBox(
        width: 440,
        height: 260,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/photo_alpine_lake.jpg',
              fit: BoxFit.cover,
            ),
            PositionedDirectional(
              top: 12,
              end: 12,
              child: label(icon: PhosphorIconsFill.images, text: '1 / 4'),
            ),
            PositionedDirectional(
              start: 12,
              bottom: 12,
              child: label(
                icon: PhosphorIconsFill.mapPin,
                text: 'Alpine lake',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
