import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/home_feed_scope.dart';
import 'package:example/strand/widgets/home_pieces.dart';
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

    Widget tabs({double? labelWidth}) {
      return Semantics(
        label: 'Feed',
        container: true,
        child: Tabs<HomeFeed>(
          value: model.feed,
          expandTabs: mobile,
          onChanged: (feed) => model.feed = feed,
          tabs: [
            for (final feed in HomeFeed.values)
              Tab(
                value: feed,
                child: labelWidth == null
                    ? Text(feed.label)
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: labelWidth),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(feed.label, maxLines: 1, softWrap: false),
                        ),
                      ),
              ),
          ],
        ),
      );
    }

    if (mobile) {
      // A tab lays its label out at its natural width, so in a strip that
      // divides a narrow screen a long label in a wide font would overflow
      // its third. Work out what each label has and let it shrink to that.
      return LayoutBuilder(
        builder: (context, constraints) {
          final tabsTheme = theme.tabsTheme;
          final count = HomeFeed.values.length;
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

    // The control is not flexible — given spare width its strip would
    // stretch past the last tab — so the menu is what gives way.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        tabs(),
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
                ? const Icon(PhosphorIconsRegular.check)
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
              const Gap.raw(homeTightGap),
              Flexible(
                child: Text(
                  model.sort.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: style.copyWith(color: scheme.foreground),
                ),
              ),
              const Gap.raw(homeTightGap),
              Icon(
                PhosphorIconsRegular.caretDown,
                size: 14,
                color: scheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
