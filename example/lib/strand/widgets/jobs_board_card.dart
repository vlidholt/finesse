import 'package:example/strand/data/applications_data.dart';
import 'package:example/strand/widgets/jobs_company_logo.dart';
import 'package:example/strand/widgets/jobs_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An application on the board: the company's mark, the role, where it is,
/// and one status line with when it last changed.
///
/// It is a plain [Card]; inside a `Board` a card takes the board's tighter
/// padding and radius by itself.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard(this.application, {super.key});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final caption = text.muted.copyWith(fontSize: 12, height: 16 / 12);
    final toneColor = switch (application.tone) {
      ApplicationTone.quiet => colors.mutedForeground,
      ApplicationTone.active => colors.tint,
      ApplicationTone.good => colors.success,
      ApplicationTone.urgent => colors.warning,
    };

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: jobsTightGap,
            children: [
              JobsCompanyLogo(
                application.company,
                size: 36,
                radius: theme.radii.md,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.title,
                      style: text.small.copyWith(
                        fontSize: 14,
                        height: 18 / 14,
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${application.company.name} · '
                      '${application.location}',
                      style: caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: jobsTightGap),
          Row(
            spacing: jobsInlineGap,
            children: [
              // Decorative: the text beside it says what it marks.
              ExcludeSemantics(
                child: Icon(application.statusIcon, size: 14, color: toneColor),
              ),
              Expanded(
                child: Text(
                  application.status,
                  style: caption.copyWith(
                    color: toneColor,
                    fontWeight: application.tone == ApplicationTone.quiet
                        ? null
                        : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                application.updated,
                style: caption,
                semanticsLabel: 'Updated ${application.updated}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
