import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/widgets/jobs_state.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The four summary tiles: one row while each tile has room for its label,
/// two rows of two below that.
class JobsStats extends StatelessWidget {
  const JobsStats({required this.state, super.key});

  final JobsState state;

  /// Under this width four tiles in a row truncate their labels.
  static const _singleRowMinWidth = 960.0;

  @override
  Widget build(BuildContext context) {
    Widget tile(JobStat stat, [int? value]) => Expanded(
      child: StatTile(
        icon: Icon(stat.icon),
        value: Text('${value ?? stat.value}'),
        label: Text(stat.label),
      ),
    );

    final tiles = [
      tile(JobsData.savedJobs, state.savedCount),
      tile(JobsData.applicationsSent, state.appliedCount),
      tile(JobsData.interviews),
      tile(JobsData.profileViews),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _singleRowMinWidth) {
          return FinesseRow(gap: GapSize.md, children: tiles);
        }
        return FinesseColumn(
          gap: GapSize.md,
          mainAxisSize: MainAxisSize.min,
          children: [
            FinesseRow(gap: GapSize.md, children: tiles.sublist(0, 2)),
            FinesseRow(gap: GapSize.md, children: tiles.sublist(2)),
          ],
        );
      },
    );
  }
}
