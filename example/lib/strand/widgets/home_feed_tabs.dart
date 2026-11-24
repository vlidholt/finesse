import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/home_feed_scope.dart';
import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The feed's segmented control — For you, Following, Trending.
///
/// On a desktop it hugs its labels and shares the row with the "Sort by"
/// menu; on a phone it fills the width and the menu is left out.
class HomeFeedTabs extends StatelessWidget {
  const HomeFeedTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = HomeFeedScope.of(context);
    final mobile = theme.formFactor == FormFactor.mobile;

    // On a phone the three tabs share the width, and a label that does
    // not fit its third shrinks to it.
    final tabs = Semantics(
      label: 'Feed',
      container: true,
      child: Tabs<HomeFeed>(
        value: model.feed,
        expandTabs: mobile,
        onChanged: (feed) => model.feed = feed,
        tabs: [
          for (final feed in HomeFeed.values)
            Tab(value: feed, child: StrandTabLabel(feed.label)),
        ],
      ),
    );
    if (mobile) return tabs;

    // The control keeps the width of its labels; the menu is what gives
    // way.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        tabs,
        const Flexible(child: _SortMenu()),
      ],
    );
  }
}

/// "Sort by Top ⌄": a text button that opens the two orders.
class _SortMenu extends StatelessWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final model = HomeFeedScope.of(context);
    final style = theme.textTheme.small.copyWith(
      color: scheme.mutedForeground,
    );

    return DropdownMenu(
      items: [
        for (final sort in FeedSort.values)
          ContextMenuItem(
            trailing: model.sort == sort
                ? const PhosphorIcon(PhosphorIconsRegular.check)
                : null,
            onPressed: () => model.sort = sort,
            child: Text(sort.label),
          ),
      ],
      builder: (context, controller, _) => Pressable(
        onPressed: controller.toggle,
        builder: (context, states) => FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: theme.radii.sm,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Sort by',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: style,
                ),
              ),
              const Gap.xs(),
              Flexible(
                child: Text(
                  model.sort.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: style.copyWith(color: scheme.foreground),
                ),
              ),
              const Gap.xs(),
              PhosphorIcon(
                PhosphorIconsRegular.caretDown,
                size: theme.iconBeside(style),
                color: scheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
