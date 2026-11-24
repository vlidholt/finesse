import 'package:disco/disco.dart';
import 'package:example/strand/data/applications_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

/// The two sides of the Jobs destination.
enum JobsView {
  /// The designed screen: search, summary tiles, results and a listing.
  find(ApplicationsData.findTab),

  /// The board of the user's own applications.
  applications(ApplicationsData.boardTab);

  const JobsView(this.label);

  final String label;
}

/// Which side of Jobs is showing.
///
/// Provided above the whole app beside `strandDestinationProvider`, so any
/// screen can open the board:
///
/// ```dart
/// context.openApplications();
/// ```
final jobsViewProvider = Provider((_) => Signal(JobsView.find));

/// Shortcuts to the Jobs destination's two sides.
extension JobsNavigation on BuildContext {
  /// Switches the Strand shell to Jobs, showing the "My applications"
  /// board.
  void openApplications() {
    jobsViewProvider.of(this).value = JobsView.applications;
    goTo(StrandDestination.jobs);
  }
}

/// The switch at the top of Jobs: "Find jobs" / "My applications".
///
/// On a desktop it hugs its two labels; on a phone it fills the width.
class JobsViewSwitch extends StatelessWidget {
  const JobsViewSwitch({
    required this.view,
    required this.onChanged,
    super.key,
  });

  final JobsView view;
  final ValueChanged<JobsView> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = theme.formFactor == FormFactor.mobile;

    Widget tabs({double? labelWidth}) {
      return Semantics(
        label: 'Jobs view',
        container: true,
        child: Tabs<JobsView>(
          value: view,
          expandTabs: mobile,
          onChanged: onChanged,
          tabs: [
            for (final view in JobsView.values)
              Tab(
                value: view,
                child: labelWidth == null
                    ? Text(view.label)
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: labelWidth),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(view.label, maxLines: 1, softWrap: false),
                        ),
                      ),
              ),
          ],
        ),
      );
    }

    if (mobile) {
      // A tab lays its label out at its natural width, so in a strip that
      // halves a narrow screen a long label in a wide font would overflow
      // its half. Work out what each label has and let it shrink to that.
      return LayoutBuilder(
        builder: (context, constraints) {
          final tabsTheme = theme.tabsTheme;
          final count = JobsView.values.length;
          final strip = (tabsTheme.padding ?? EdgeInsets.zero).horizontal;
          final gaps = (tabsTheme.tabsGap ?? 0) * (count - 1);
          final inset = (tabsTheme.tabPadding ?? EdgeInsets.zero).horizontal;
          final labelWidth =
              (constraints.maxWidth - strip - gaps) / count - inset;
          return tabs(
            labelWidth: labelWidth.floorToDouble().clamp(0, double.infinity),
          );
        },
      );
    }
    // In a row the control is as wide as its tabs; stretched by a column,
    // its strip would run the width of the page behind them.
    return Row(children: [tabs()]);
  }
}
