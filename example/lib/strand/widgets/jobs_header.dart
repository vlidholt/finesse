import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/widgets/jobs_state.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The page title. A desktop adds the subtitle and the two page actions;
/// a phone shows the title alone.
class JobsHeader extends StatelessWidget {
  const JobsHeader({required this.state, super.key});

  final JobsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final layout = theme.layoutTheme;
    final title = Text(JobsData.title, style: theme.textTheme.h1);
    if (theme.formFactor == FormFactor.mobile) return title;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: layout.gap(GapSize.xl),
      runSpacing: layout.gap(GapSize.md),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const Gap.xs(),
            Text(
              JobsData.subtitle,
              // A step up from the 14px body: the design's page lead.
              style: theme.textTheme.p.copyWith(
                fontSize: 15,
                height: 22 / 15,
                color: colors.mutedForeground,
              ),
            ),
          ],
        ),
        FinesseRow(
          gap: GapSize.sm,
          mainAxisSize: MainAxisSize.min,
          children: [
            Button.outline(
              leading: Icon(
                state.alerts
                    ? PhosphorIconsFill.bellRinging
                    : PhosphorIconsRegular.bell,
                color: state.alerts ? colors.tint : null,
              ),
              onPressed: state.toggleAlerts,
              child: const Text('Job alerts'),
            ),
            Button(
              leading: const Icon(PhosphorIconsRegular.plus),
              onPressed: () {},
              child: const Text('Post a job'),
            ),
          ],
        ),
      ],
    );
  }
}
