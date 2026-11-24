import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/widgets/jobs_state.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Opens "All filters": every filter of the Jobs search as a switch. They
/// are the chips' own state, so a switch flipped here selects its chip.
Future<void> showJobFiltersDialog(BuildContext context, JobsState state) {
  return showDialog<void>(
    context: context,
    builder: (context) => ListenableBuilder(
      listenable: state,
      builder: (context, _) => Dialog(
        title: const Text('All filters'),
        description: const Text('Narrow the results to roles that fit.'),
        constraints: const BoxConstraints(maxWidth: 440),
        scrollable: true,
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Show results'),
          ),
        ],
        child: FinesseColumn(
          gap: GapSize.md,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final filter in JobsData.filters)
              Row(
                children: [
                  if (filter.icon case final icon?) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                    const Gap.sm(),
                  ],
                  Expanded(child: Text(filter.label)),
                  Semantics(
                    label: filter.label,
                    child: Switch(
                      value: state.isFilterOn(filter),
                      onChanged: (_) => state.toggleFilter(filter),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
