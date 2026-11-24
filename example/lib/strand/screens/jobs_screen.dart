import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/widgets/jobs_detail.dart';
import 'package:example/strand/widgets/jobs_detail_page.dart';
import 'package:example/strand/widgets/jobs_header.dart';
import 'package:example/strand/widgets/jobs_metrics.dart';
import 'package:example/strand/widgets/jobs_results.dart';
import 'package:example/strand/widgets/jobs_search_card.dart';
import 'package:example/strand/widgets/jobs_state.dart';
import 'package:example/strand/widgets/jobs_stats.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The Jobs destination of the Strand shell.
///
/// A desktop shows the page header, the search card, four summary tiles and
/// then two columns: the results on the left and the selected job's detail
/// on the right. When the window is too narrow for both columns the detail
/// drops away and a job card opens it as a page instead. A phone is that
/// list-only arrangement with a shorter header: the title, a compact search
/// panel and the "Top picks for you" cards.
class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  // The two columns, from the design: the results are 440 wide and give up
  // to 80 of that before the detail, which wants at least 520, drops away.
  static const _listWidth = 440.0;
  static const _listMinWidth = 360.0;
  static const _detailMinWidth = 520.0;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _state = JobsState();
  final _titleController = TextEditingController(text: JobsData.titleQuery);
  final _locationController = TextEditingController(
    text: JobsData.locationQuery,
  );

  @override
  void dispose() {
    _state.dispose();
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _messageHiringManager() => context.goTo(StrandDestination.messages);

  void _openDetailPage(Job job) {
    context.pushFullScreen<void>(
      (pageContext) => JobDetailPage(
        job: job,
        state: _state,
        onMessage: () {
          // Back to the shell first: the conversation is one of its
          // destinations, not a page on top of this one.
          Navigator.of(pageContext).pop();
          _messageHiringManager();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final mobile = theme.formFactor == FormFactor.mobile;

    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final search = JobsSearchCard(
          state: _state,
          titleController: _titleController,
          locationController: _locationController,
        );

        return PageContainer(
          scrollable: true,
          // The designs start the page a touch lower than the page margin:
          // 28 under the app bar on a desktop, 17 on a phone.
          padding: (layout.pagePadding ?? EdgeInsets.zero).add(
            EdgeInsets.only(top: mobile ? 1 : 4),
          ),
          child: FinesseColumn(
            gap: GapSize.lg,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JobsHeader(state: _state),
              search,
              if (mobile)
                Padding(
                  // The phone design sets the list two section gaps below
                  // the search panel, not one.
                  padding: EdgeInsets.only(top: layout.gap(GapSize.lg)),
                  child: JobsResults(state: _state, onOpen: _openDetailPage),
                )
              else ...[
                JobsStats(state: _state),
                Padding(
                  padding: EdgeInsets.only(top: layout.gap(GapSize.xs)),
                  child: _buildColumns(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// The results and the detail side by side, or the results alone.
  Widget _buildColumns() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spare =
            constraints.maxWidth - jobsWideGap - JobsScreen._detailMinWidth;
        if (spare < JobsScreen._listMinWidth) {
          return JobsResults(state: _state, onOpen: _openDetailPage);
        }

        final theme = Theme.of(context);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: jobsWideGap,
          children: [
            SizedBox(
              width: spare.clamp(
                JobsScreen._listMinWidth,
                JobsScreen._listWidth,
              ),
              // Selecting a card is enough here: the detail is alongside.
              child: JobsResults(state: _state, onOpen: (_) {}),
            ),
            Expanded(
              child: Card(
                radius: theme.radii.xl3,
                // 28: roomier than the theme's card inset, for a pane that
                // is read rather than scanned.
                padding: const EdgeInsets.all(28),
                child: JobDetail(
                  job: _state.selected,
                  state: _state,
                  onMessage: _messageHiringManager,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
