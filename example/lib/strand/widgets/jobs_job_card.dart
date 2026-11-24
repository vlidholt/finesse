import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/widgets/jobs_company_logo.dart';
import 'package:example/strand/widgets/jobs_metrics.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A listing in the results list: a tappable [Card], selected while it is
/// the one the detail pane shows. The bookmark inside it is a button of its
/// own.
class JobCard extends StatelessWidget {
  const JobCard({
    required this.job,
    required this.selected,
    required this.saved,
    required this.onPressed,
    required this.onSavePressed,
    super.key,
  });

  final Job job;
  final bool selected;
  final bool saved;
  final VoidCallback onPressed;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final mobile = theme.formFactor == FormFactor.mobile;
    final caption = text.muted.copyWith(fontSize: 12, height: 16 / 12);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: jobsSnugGap,
      children: [
        JobsCompanyLogo(job.company, size: mobile ? 44 : 48),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinesseRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                gap: GapSize.sm,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: text.large,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _SaveButton(saved: saved, onPressed: onSavePressed),
                ],
              ),
              Text(
                job.company.name,
                style: text.small.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  color: colors.foregroundSubtle,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                job.location,
                style: text.muted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: jobsTightGap),
              Wrap(
                spacing: jobsInlineGap,
                runSpacing: jobsInlineGap,
                children: [
                  JobTag(job.salary),
                  if (job.easyApply) const JobTag.easyApply(),
                ],
              ),
              const SizedBox(height: jobsTightGap),
              Row(
                spacing: jobsInlineGap,
                children: [
                  // Decorative: the label beside it says what it shows.
                  ExcludeSemantics(
                    child: AvatarGroup(
                      size: 20,
                      overlap: 6,
                      children: [
                        for (final person in job.connections)
                          PersonAvatar(person, size: 20),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      job.connectionsLabel,
                      style: caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Gap.sm(),
              Text(
                job.postedLabel,
                style: caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    return Card(
      onPressed: onPressed,
      selected: selected,
      // No `semanticLabel`: it would stand in for everything inside the
      // card, the bookmark button included. The card reads its own text.
      radius: theme.radii.xl,
      // 16 on a desktop and a phone alike, unlike the theme's card inset.
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}

/// The bookmark at the top end of a job card.
///
/// The design hangs the 36px button 6px into the card's padding, so the
/// icon lines up with the title's cap height and the card's inner edge.
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saved, required this.onPressed});

  final bool saved;
  final VoidCallback onPressed;

  static const _size = 36.0;
  static const _overhang = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: _size - _overhang,
      child: OverflowBox(
        maxWidth: _size,
        maxHeight: _size,
        alignment: AlignmentDirectional.bottomStart,
        child: IconButton.ghost(
          width: _size,
          height: _size,
          iconSize: 20,
          icon: Icon(
            saved
                ? PhosphorIconsFill.bookmarkSimple
                : PhosphorIconsRegular.bookmarkSimple,
          ),
          foregroundColor: saved ? colors.tint : colors.foreground,
          semanticLabel: saved ? 'Remove from saved jobs' : 'Save job',
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// A small tag on a job card: the salary band, which is the theme's grey
/// secondary badge, or the green "Easy apply" marker.
class JobTag extends StatelessWidget {
  const JobTag(this.label, {super.key}) : _easyApply = false;

  const JobTag.easyApply({super.key}) : label = 'Easy apply', _easyApply = true;

  final String label;
  final bool _easyApply;

  @override
  Widget build(BuildContext context) {
    if (!_easyApply) return Badge.secondary(child: Text(label));

    final colors = Theme.of(context).colorScheme;
    return Badge.secondary(
      // No badge variant is green: the success pair goes on by hand.
      backgroundColor: colors.successMuted,
      hoverBackgroundColor: colors.successMuted,
      foregroundColor: colors.success,
      child: FinesseRow(
        gap: GapSize.xs,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(PhosphorIconsRegular.lightning),
          Text(label),
        ],
      ),
    );
  }
}
