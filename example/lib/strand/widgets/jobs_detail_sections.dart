import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/widgets/jobs_metrics.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The fact tiles under a job's actions: two columns, or one when a tile
/// would be too narrow for its value.
class JobFactGrid extends StatelessWidget {
  const JobFactGrid({required this.facts, super.key});

  final List<JobFact> facts;

  /// Under this width a half-width tile truncates "4 designers, 12 engineers".
  static const _twoColumnMinWidth = 530.0;

  static const _gap = jobsTightGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tiles = [for (final fact in facts) _FactTile(fact)];
        if (constraints.maxWidth < _twoColumnMinWidth) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _gap,
            children: tiles,
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap,
          children: [
            for (var i = 0; i < tiles.length; i += 2)
              Row(
                spacing: _gap,
                children: [
                  Expanded(child: tiles[i]),
                  Expanded(
                    child: i + 1 < tiles.length
                        ? tiles[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile(this.fact);

  final JobFact fact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final layout = theme.layoutTheme;
    return Container(
      padding: EdgeInsets.all(layout.gap(GapSize.md)),
      decoration: BoxDecoration(
        color: colors.muted,
        border: Border.all(color: colors.border),
        // 14: between the theme's `lg` and `xl` corners.
        borderRadius: const BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        spacing: layout.gap(GapSize.md),
        children: [
          IconTile(icon: Icon(fact.icon)),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.label,
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fact.value,
                  style: theme.textTheme.small.copyWith(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Strong match for your profile" panel: the score, a progress bar and
/// the role's skills, the ones missing from the profile dashed.
class JobMatchPanel extends StatelessWidget {
  const JobMatchPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Container(
      // 18: the panel's own inset, a step inside the detail card's.
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.successMuted,
        border: Border.all(color: colors.border),
        borderRadius: theme.radii.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: theme.layoutTheme.gap(GapSize.md),
            children: [
              Expanded(
                child: Row(
                  spacing: jobsTightGap,
                  children: [
                    Icon(
                      PhosphorIconsFill.sealCheck,
                      size: 24,
                      color: colors.success,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            JobsData.matchTitle,
                            style: text.large,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            JobsData.matchSummary,
                            style: text.muted,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                JobsData.matchScoreLabel,
                style: text.h3.copyWith(
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  color: colors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: jobsSnugGap),
          const ProgressBar(
            value: JobsData.matchScore,
            // A hair slimmer than the theme's bar.
            minHeight: 6,
            semanticsLabel: 'Skills match',
            semanticsValue: JobsData.matchScoreLabel,
          ),
          const SizedBox(height: jobsSnugGap),
          Wrap(
            spacing: jobsInlineGap,
            runSpacing: jobsInlineGap,
            children: [
              for (final skill in JobsData.skills) _SkillChip(skill),
            ],
          ),
        ],
      ),
    );
  }
}

/// A skill tag, a size under the theme's filter chip.
class _SkillChip extends StatelessWidget {
  const _SkillChip(this.skill);

  final JobSkill skill;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final matched = skill.matched;
    return Chip(
      // The design's 28 plus its 1px outline, which a `Chip` counts inside
      // its height and the design's CSS box does not.
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      variant: matched ? ChipVariant.outline : ChipVariant.dashed,
      backgroundColor: matched ? colors.card : null,
      foregroundColor: matched ? null : colors.mutedForeground,
      semanticLabel: matched
          ? skill.name
          : '${skill.name}, not on your profile',
      leading: Icon(
        matched ? PhosphorIconsRegular.check : PhosphorIconsRegular.x,
        size: 14,
        color: matched ? colors.tint : colors.mutedForeground,
      ),
      label: Text(skill.name, style: const TextStyle(fontSize: 12)),
    );
  }
}

/// "Meet the hiring team": the job poster and a Message button.
class JobHiringTeam extends StatelessWidget {
  const JobHiringTeam({required this.onMessage, super.key});

  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    const person = JobsData.hiringManager;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(JobsData.hiringTeamTitle, style: text.h4),
        const Gap.md(),
        Row(
          spacing: theme.layoutTheme.gap(GapSize.md),
          children: [
            const PersonAvatar(person, size: 48),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: person.name,
                      children: [
                        TextSpan(
                          text: ' · ${JobsData.hiringManagerDegree}',
                          // A copy of the theme's style, so the lighter weight
                          // gets the font's regular face.
                          style: text.large.copyWith(
                            fontWeight: FontWeight.w400,
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    style: text.large,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    JobsData.hiringManagerRole,
                    style: text.muted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Button.outline(
              leading: const Icon(PhosphorIconsRegular.paperPlaneTilt),
              onPressed: onMessage,
              child: const Text('Message'),
            ),
          ],
        ),
      ],
    );
  }
}

/// "About the role" and the "What you'll do" checklist.
class JobDescription extends StatelessWidget {
  const JobDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    // The job description is set a size up from the app's body text, with
    // more leading: 15/24 for the paragraph, 15/23 for the list.
    final prose = text.p.copyWith(
      fontSize: 15,
      height: 24 / 15,
      color: colors.foregroundSubtle,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          JobsData.aboutRoleTitle,
          style: text.h4.copyWith(fontSize: 18, height: 24 / 18),
        ),
        const SizedBox(height: jobsTightGap),
        Text(JobsData.aboutRole, style: prose),
        const SizedBox(height: jobsWideGap),
        Text(JobsData.responsibilitiesTitle, style: text.h4),
        const SizedBox(height: jobsTightGap),
        for (final (index, item) in JobsData.responsibilities.indexed) ...[
          if (index > 0) const Gap.sm(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: jobsTightGap,
            children: [
              Padding(
                // The design's drop, which centres the icon on the first
                // line.
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  PhosphorIconsRegular.checkCircle,
                  size: 20,
                  color: colors.tint,
                ),
              ),
              Expanded(
                child: Text(item, style: prose.copyWith(height: 23 / 15)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// "About Kestrel Health": the company's size, offices and site.
class JobCompanyFacts extends StatelessWidget {
  const JobCompanyFacts({required this.companyName, super.key});

  final String companyName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('About $companyName', style: text.h4),
        const Gap.md(),
        Wrap(
          spacing: jobsWideGap,
          runSpacing: theme.layoutTheme.gap(GapSize.sm),
          children: [
            for (final (icon, label) in JobsData.companyFacts)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: jobsInlineGap,
                children: [
                  Icon(icon, size: 18, color: colors.mutedForeground),
                  Flexible(
                    child: Text(
                      label,
                      style: text.muted.copyWith(
                        fontSize: 14,
                        height: 18 / 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
