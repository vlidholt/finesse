import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/widgets/jobs_company_logo.dart';
import 'package:example/strand/widgets/jobs_detail_sections.dart';
import 'package:example/strand/widgets/jobs_metrics.dart';
import 'package:example/strand/widgets/jobs_state.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Everything the designs say about one job, top to bottom: the company
/// header, the title, the actions, the fact tiles, the match panel, the
/// hiring team, the description and the company.
///
/// It is only the content. The desktop screen puts it in a card beside the
/// results; a phone pushes it as a page (`JobDetailPage`), which moves the
/// share action into its app bar and "Easy Apply" into a bar at the bottom —
/// hence [showHeaderActions] and [showActions].
class JobDetail extends StatelessWidget {
  const JobDetail({
    required this.job,
    required this.state,
    required this.onMessage,
    this.showHeaderActions = true,
    this.showActions = true,
    super.key,
  });

  final Job job;
  final JobsState state;

  /// Called by the hiring manager's Message button.
  final VoidCallback onMessage;

  /// Whether the company header carries the share and overflow buttons.
  final bool showHeaderActions;

  /// Whether "Easy Apply" and "Save" sit under the title.
  final bool showActions;

  // The designs space this pane on its own rhythm — 22 between sections,
  // 20/6/18 around the title — rather than on the page's gap scale.
  static const _sectionGap = 22.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = theme.formFactor == FormFactor.mobile;
    const section = SizedBox(height: _sectionGap);
    const rule = Divider.horizontal(
      margin: EdgeInsets.symmetric(vertical: _sectionGap),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CompanyHeader(
          job: job,
          following: state.isFollowing(job),
          onFollowPressed: () => state.toggleFollowing(job),
          showActions: showHeaderActions,
        ),
        const SizedBox(height: jobsWideGap),
        Text(
          job.title,
          // No phone design exists for this pane; the title drops two steps
          // there so it wraps to two lines rather than three.
          style: theme.textTheme.h1.copyWith(
            fontSize: mobile ? 22 : 26,
            height: mobile ? 28 / 22 : 32 / 26,
            letterSpacing: mobile ? -.44 : -.52,
          ),
        ),
        const SizedBox(height: jobsInlineGap),
        Text(
          job.detailMeta,
          style: theme.textTheme.muted.copyWith(fontSize: 14, height: 18 / 14),
        ),
        if (showActions) ...[
          const SizedBox(height: 18),
          JobActions(job: job, state: state),
        ],
        section,
        JobFactGrid(facts: JobsData.factsFor(job)),
        const SizedBox(height: jobsSnugGap),
        const JobMatchPanel(),
        section,
        JobHiringTeam(onMessage: onMessage),
        rule,
        const JobDescription(),
        rule,
        JobCompanyFacts(companyName: job.company.name),
      ],
    );
  }
}

/// The logo, the company's name and tagline, and Follow / share / more.
class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader({
    required this.job,
    required this.following,
    required this.onFollowPressed,
    required this.showActions,
  });

  final Job job;
  final bool following;
  final VoidCallback onFollowPressed;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Row(
      // Between every part of the row, as between a job card's logo and its
      // text.
      spacing: jobsSnugGap,
      children: [
        JobsCompanyLogo(job.company, size: 56, radius: theme.radii.xl),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.company.name,
                style: text.large,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                JobsData.companyTagline,
                style: text.muted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Button.outline(
          leading: Icon(
            following ? PhosphorIconsRegular.check : PhosphorIconsRegular.plus,
          ),
          onPressed: onFollowPressed,
          child: Text(following ? 'Following' : 'Follow'),
        ),
        if (showActions) ...[
          IconButton.secondary(
            icon: const Icon(PhosphorIconsRegular.export),
            semanticLabel: 'Share job',
            onPressed: () {},
          ),
          IconButton.secondary(
            icon: const Icon(PhosphorIconsRegular.dotsThree),
            semanticLabel: 'More options',
            onPressed: () {},
          ),
        ],
      ],
    );
  }
}

/// "Easy Apply" and "Save".
///
/// Under the title on a desktop; in the bottom bar of the phone's detail
/// page, where [expand] lets "Easy Apply" take the spare width.
class JobActions extends StatelessWidget {
  const JobActions({
    required this.job,
    required this.state,
    this.expand = false,
    super.key,
  });

  final Job job;
  final JobsState state;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final applied = state.hasApplied(job);
    final saved = state.isSaved(job);

    final apply = Button(
      size: ButtonSize.lg,
      // The one call to action in the tint rather than the primary colour.
      backgroundColor: colors.tint,
      hoverBackgroundColor: colors.tint.withValues(alpha: .8),
      foregroundColor: colors.tintForeground,
      hoverForegroundColor: colors.tintForeground,
      enabled: !applied,
      leading: Icon(
        applied ? PhosphorIconsRegular.check : PhosphorIconsRegular.lightning,
      ),
      onPressed: () => state.apply(job),
      child: Text(applied ? 'Applied' : 'Easy Apply'),
    );

    return FinesseRow(
      gap: GapSize.sm,
      children: [
        if (expand) Expanded(child: apply) else apply,
        Button.outline(
          size: ButtonSize.lg,
          // The large height with the regular button's side padding.
          padding: theme.buttonSizesTheme.regular?.padding,
          leading: Icon(
            saved
                ? PhosphorIconsFill.bookmarkSimple
                : PhosphorIconsRegular.bookmarkSimple,
            color: saved ? colors.tint : null,
          ),
          onPressed: () => state.toggleSaved(job),
          child: Text(saved ? 'Saved' : 'Save'),
        ),
      ],
    );
  }
}
