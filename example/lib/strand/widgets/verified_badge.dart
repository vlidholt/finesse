import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The seal shown after a verified person's name, in the theme's tint.
///
/// ```dart
/// Row(children: [Text(person.name), const Gap.xs(), const VerifiedBadge()])
/// ```
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({this.size = 16, super.key});

  /// The icon's size: 16 beside a name in a list, 20 beside a profile's
  /// title.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      PhosphorIconsFill.sealCheck,
      size: size,
      color: Theme.of(context).colorScheme.tint,
      semanticLabel: 'Verified',
    );
  }
}
