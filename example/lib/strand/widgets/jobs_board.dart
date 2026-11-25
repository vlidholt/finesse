import 'package:example/strand/data/applications_data.dart';
import 'package:example/strand/widgets/jobs_board_card.dart';
import 'package:example/strand/widgets/jobs_board_controller.dart';
import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The "My applications" board: one column per [ApplicationStage], a card
/// per application, dragged from stage to stage.
///
/// The board fills the height it is given and each column scrolls its own
/// cards. [padding] is inside the board's horizontal scroll view, so on a
/// window too narrow for five columns they run to its edges.
class JobsBoard extends StatelessWidget {
  const JobsBoard({
    required this.applications,
    required this.onFindJobs,
    this.padding,
    super.key,
  });

  final ApplicationsController applications;

  /// Called by "Find more jobs", once there is nothing left to add.
  final VoidCallback onFindJobs;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: applications,
      builder: (context, _) => Board<JobApplication>(
        padding: padding,
        itemId: (application) => application.id,
        itemSemanticLabel: (application) =>
            '${application.title}, ${application.company.name}',
        columns: [
          for (final stage in ApplicationStage.values)
            BoardColumn(
              id: stage,
              label: stage.label,
              items: applications.at(stage),
              leading: PhosphorIcon(
                stage.icon,
                size: Theme.of(context).glyph,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
              trailing: _StageMenu(stage: stage, applications: applications),
              footer: stage == ApplicationStage.saved
                  ? Button.ghost(
                      style: ButtonTheme(
                        width: double.infinity,
                      ),
                      // The label takes the width that is left and gives
                      // way when a wide font or a large text size needs
                      // more than the column has.
                      expands: true,
                      leading: PhosphorIcon(
                        applications.hasSuggestions
                            ? PhosphorIconsRegular.plus
                            : PhosphorIconsRegular.magnifyingGlass,
                      ),
                      onPressed: applications.hasSuggestions
                          ? applications.addSuggestion
                          : onFindJobs,
                      child: Text(
                        applications.hasSuggestions
                            ? ApplicationsData.addLabel
                            : ApplicationsData.findMoreLabel,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : null,
            ),
        ],
        itemBuilder: (context, application, details) =>
            ApplicationCard(application),
        onMove: applications.move,
      ),
    );
  }
}

/// The "…" at the end of a column's header: sorting, and clearing the
/// column out.
class _StageMenu extends StatelessWidget {
  const _StageMenu({required this.stage, required this.applications});

  final ApplicationStage stage;
  final ApplicationsController applications;

  @override
  Widget build(BuildContext context) {
    final empty = applications.at(stage).isEmpty;
    return DropdownMenu(
      constraints: const BoxConstraints(minWidth: 208),
      items: [
        MenuItem(
          leading: const PhosphorIcon(
            PhosphorIconsRegular.clockCounterClockwise,
          ),
          enabled: !empty,
          onPressed: () => applications.sort(stage, ApplicationSort.updated),
          child: const Text('Sort by last updated'),
        ),
        MenuItem(
          leading: const PhosphorIcon(PhosphorIconsRegular.sortAscending),
          enabled: !empty,
          onPressed: () => applications.sort(stage, ApplicationSort.company),
          child: const Text('Sort by company'),
        ),
        const Divider(margin: EdgeInsets.symmetric(vertical: 4)),
        if (stage == ApplicationStage.archived)
          MenuItem(
            leading: const PhosphorIcon(PhosphorIconsRegular.trash),
            enabled: !empty,
            destructive: true,
            onPressed: applications.clearArchive,
            child: const Text('Clear the archive'),
          )
        else
          MenuItem(
            leading: const PhosphorIcon(PhosphorIconsRegular.archive),
            enabled: !empty,
            onPressed: () => applications.archiveAll(stage),
            child: const Text('Archive all'),
          ),
      ],
      builder: (context, controller, _) => IconButton.ghost(
        size: ButtonSize.sm,
        icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
        semanticLabel: '${stage.label} options',
        onPressed: controller.toggle,
      ),
    );
  }
}
