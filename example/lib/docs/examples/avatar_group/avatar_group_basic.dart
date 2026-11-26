import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Mutual connections: the first avatar is painted on top and each one is
/// ringed in the colour of the surface behind it.
class AvatarGroupBasicExample extends StatelessWidget {
  const AvatarGroupBasicExample({super.key});

  static const _photos = [
    'assets/images/avatar_mei_tanaka.jpg',
    'assets/images/avatar_omar_rahimi.jpg',
    'assets/images/avatar_claire_dubois.jpg',
    'assets/images/avatar_julian_reyes.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          AvatarGroup(
            size: 28,
            children: [for (final photo in _photos) Avatar(photo)],
          ),
          Flexible(
            child: Text(
              'Mei, Omar and 12 other mutual connections',
              style: theme.textTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
