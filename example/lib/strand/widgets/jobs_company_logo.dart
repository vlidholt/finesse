import 'package:example/strand/data.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A company's mark on a rounded square, with the hairline the designs draw
/// just inside its edge so a white logo keeps its shape on a white card.
class JobsCompanyLogo extends StatelessWidget {
  const JobsCompanyLogo(this.company, {this.size = 48, this.radius, super.key});

  final Company company;

  /// The width and height: 48 in a job card (44 on a phone), 56 in the
  /// detail pane's header.
  final double size;

  /// The corner radius. Defaults to the theme's `lg` step.
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corners = radius ?? theme.radii.lg;
    return ClipRRect(
      borderRadius: corners,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: corners,
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: Image.asset(
          company.logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          semanticLabel: '${company.name} logo',
        ),
      ),
    );
  }
}
