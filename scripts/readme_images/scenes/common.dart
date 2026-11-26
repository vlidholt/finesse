import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The people the scenes show. Fictional.
const people = [
  (name: 'Maya Lindqvist', initials: 'ML', role: 'Design lead'),
  (name: 'Jonah Reyes', initials: 'JR', role: 'iOS engineer'),
  (name: 'Aiko Tanaka', initials: 'AT', role: 'Product manager'),
  (name: 'Sam Okafor', initials: 'SO', role: 'Backend engineer'),
  (name: 'Lena Fischer', initials: 'LF', role: 'Researcher'),
  (name: 'Omar Haddad', initials: 'OH', role: 'Data scientist'),
];

/// Soft avatar colours, one per person.
const _avatarColors = [
  (Color(0xFFF7D9C4), Color(0xFF8A4B22)),
  (Color(0xFFCDE7F0), Color(0xFF1F5B70)),
  (Color(0xFFE3D7F5), Color(0xFF5A3C8C)),
  (Color(0xFFD5EDD8), Color(0xFF2E6B3A)),
  (Color(0xFFF6D6DE), Color(0xFF8C2F4A)),
  (Color(0xFFF3E8C4), Color(0xFF7A5E12)),
];

/// An avatar for person [index]: initials on a soft colour.
class PersonAvatar extends StatelessWidget {
  /// Creates the avatar of person [index].
  const PersonAvatar(this.index, {this.size, super.key});

  /// Which person.
  final int index;

  /// The avatar's diameter; the theme's when null.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _avatarColors[index % 6];
    final theme = Theme.of(context);
    final side = size ?? theme.avatarTheme.size?.width ?? 40;
    return Avatar(
      '',
      size: Size.square(side),
      backgroundColor: background,
      fallback: Text(
        people[index % 6].initials,
        style: theme.textTheme.small.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: side * .36,
        ),
      ),
    );
  }
}

/// A logo mark: a rounded square in the primary colour with a glyph.
class LogoMark extends StatelessWidget {
  /// Creates a logo mark.
  const LogoMark({this.size = 32, super.key});

  /// Its side.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: PhosphorIcon(
        PhosphorIconsFill.planet,
        size: size * .58,
        color: theme.colorScheme.primaryForeground,
      ),
    );
  }
}

/// A small bar chart: seven bars, the last highlighted.
class BarChart extends StatelessWidget {
  /// Creates a chart of [values] (0 to 1) labelled by [labels].
  const BarChart({
    required this.values,
    required this.labels,
    this.highlight,
    super.key,
  });

  /// The bars' heights, from 0 to 1.
  final List<double> values;

  /// A label under each bar.
  final List<String> labels;

  /// The index of the highlighted bar.
  final int? highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FractionallySizedBox(
                      heightFactor: values[i],
                      alignment: Alignment.bottomCenter,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: i == highlight
                              ? scheme.primary
                              : scheme.primary.withValues(alpha: .16),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                            bottom: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.caption,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
