import 'dart:math' as math;

import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/jobs_board.dart';
import 'package:example/strand/widgets/jobs_board_controller.dart';
import 'package:example/strand/widgets/jobs_board_view.dart';
import 'package:example/strand/widgets/jobs_detail.dart';
import 'package:example/strand/widgets/jobs_detail_page.dart';
import 'package:example/strand/widgets/jobs_header.dart';
import 'package:example/strand/widgets/jobs_results.dart';
import 'package:example/strand/widgets/jobs_search_card.dart';
import 'package:example/strand/widgets/jobs_state.dart';
import 'package:example/strand/widgets/jobs_stats.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

/// The Jobs destination of the Strand shell.
///
/// It has two sides, chosen with the switch under the title: "Find jobs",
/// which is the designed screen described below, and "My applications", a
/// board of the roles the user is tracking, dragged from stage to stage.
/// Which one shows is `jobsViewProvider`, so another screen can open the
/// board with `context.openApplications()`.
///
/// "Find jobs" on a desktop shows the page header, the search card, four summary tiles and
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
  // Both sides' state is the session's: the "Saved items" sheet counts the
  // board's saved jobs too, and the detail page is a pushed route.
  JobsState get _state => context.strand.jobs;
  ApplicationsController get _applications => context.strand.applications;

  // The side showing when the screen is built on its own, outside the
  // app's providers, as its tests do.
  final _ownView = Signal(JobsView.find);

  final _titleController = TextEditingController(text: JobsData.titleQuery);
  final _locationController = TextEditingController(
    text: JobsData.locationQuery,
  );

  Signal<JobsView> get _view => jobsViewProvider.maybeOf(context) ?? _ownView;

  @override
  void dispose() {
    _ownView.dispose();
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
    return SignalBuilder(
      builder: (context, _) {
        final signal = _view;
        final view = signal.value;
        final viewSwitch = JobsViewSwitch(
          view: view,
          onChanged: (view) => signal.value = view,
        );
        return ListenableBuilder(
          listenable: _state,
          builder: (context, _) => switch (view) {
            JobsView.find => _buildFind(context, viewSwitch),
            JobsView.applications => _buildApplications(context, viewSwitch),
          },
        );
      },
    );
  }

  /// The designed screen, with the switch between its title and its search.
  Widget _buildFind(BuildContext context, Widget viewSwitch) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final mobile = theme.formFactor == FormFactor.mobile;
    final search = JobsSearchCard(
      state: _state,
      titleController: _titleController,
      locationController: _locationController,
    );

    return PageContainer(
      scrollable: true,
      padding: _pagePadding(context),
      child: FinesseColumn(
        gap: GapSize.lg,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JobsHeader(state: _state),
          viewSwitch,
          search,
          if (mobile)
            Padding(
              // The phone design sets the list two section gaps below
              // the search panel, not one.
              padding: EdgeInsets.only(top: layout.gap(GapSize.lg)),
              child: JobsResults(state: _state, onOpen: _openDetailPage),
            )
          else ...[
            JobsStats(applications: _applications),
            Padding(
              padding: EdgeInsets.only(top: layout.gap(GapSize.xs)),
              child: _buildColumns(),
            ),
          ],
        ],
      ),
    );
  }

  EdgeInsetsGeometry _pagePadding(BuildContext context) =>
      Theme.of(context).layoutTheme.pagePadding ?? EdgeInsets.zero;

  /// The board. It does not scroll as a page: the title and the switch stay
  /// put and the board takes the rest of the window, each column scrolling
  /// its own cards.
  ///
  /// The title lines up with the other screens — the page margins, and the
  /// page's maximum width centred — but the board itself runs from one edge
  /// of the window to the other, with those margins as the padding inside
  /// its scroll view. On a window too narrow for five columns they
  /// disappear under the edge instead of stopping short of it.
  Widget _buildApplications(BuildContext context, Widget viewSwitch) {
    final layout = Theme.of(context).layoutTheme;
    final safeArea = MediaQuery.paddingOf(context);
    final page = _pagePadding(context).resolve(Directionality.of(context));

    return LayoutBuilder(
      builder: (context, constraints) {
        final spare = math.max<double>(
          0,
          (constraints.maxWidth - (layout.pageMaxWidth ?? double.infinity)) / 2,
        );
        final sides = EdgeInsets.only(
          left: spare + page.left + safeArea.left,
          right: spare + page.right + safeArea.right,
        );
        return Padding(
          padding: EdgeInsets.only(
            top: page.top + safeArea.top,
            bottom: page.bottom + safeArea.bottom,
          ),
          // The safe area has been spent; nothing below adds it again.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            removeLeft: true,
            removeRight: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: sides,
                  child: FinesseColumn(
                    gap: GapSize.lg,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      JobsHeader(state: _state),
                      viewSwitch,
                    ],
                  ),
                ),
                const Gap.lg(),
                Expanded(
                  child: JobsBoard(
                    applications: _applications,
                    padding: sides,
                    onFindJobs: () => _view.value = JobsView.find,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The results and the detail side by side, or the results alone.
  Widget _buildColumns() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final columnGap = theme.layoutTheme.gap(GapSize.xl);
        final spare =
            constraints.maxWidth - columnGap - JobsScreen._detailMinWidth;
        if (spare < JobsScreen._listMinWidth) {
          return JobsResults(state: _state, onOpen: _openDetailPage);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: columnGap,
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
                // Roomier than the theme's card inset, for a pane that is
                // read rather than scanned.
                padding: EdgeInsets.all(columnGap),
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
