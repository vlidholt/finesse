import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A row of text tabs with a line under the selected one, for switching
/// between the sections of a page.
///
/// ```dart
/// TabBar(
///   selectedIndex: section,
///   onSelected: (i) => setState(() => section = i),
///   tabs: const [Text('Posts'), Text('About'), Text('Experience')],
/// )
/// ```
///
/// `Tabs` is the segmented control: a filled strip with a raised selection,
/// for a few mutually exclusive views. `TabBar` is the quieter underline
/// form, and it only reports which tab is selected — the caller shows the
/// matching content.
///
/// With [expand] the tabs share the width equally; without it each is as
/// wide as its label plus [tabPadding] and the row scrolls when it does not
/// fit.
class TabBar extends StatelessWidget {
  /// Creates a tab bar.
  const TabBar({
    required this.tabs,
    required this.selectedIndex,
    this.onSelected,
    this.expand = true,
    this.height,
    this.tabPadding,
    this.showBorder = true,
    this.indicatorColor,
    this.labelStyle,
    super.key,
  });

  /// The tabs' labels, usually [Text]s.
  final List<Widget> tabs;

  /// The index of the selected tab.
  final int selectedIndex;

  /// Called with the index of the tab that was tapped.
  final ValueChanged<int>? onSelected;

  /// Whether the tabs share the available width equally.
  final bool expand;

  /// The bar's height. Defaults to the style's underline tab height.
  final double? height;

  /// Horizontal padding around each label when the tabs do not [expand].
  final EdgeInsetsGeometry? tabPadding;

  /// Whether a hairline runs under the whole bar.
  final bool showBorder;

  /// The colour of the line under the selected tab. Defaults to the
  /// foreground colour.
  final Color? indicatorColor;

  /// The labels' style. Weight and colour are set per tab on top of it.
  /// Defaults to the theme's `large` text style.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final barHeight = height ?? theme.style.underlineTabHeight;
    final baseStyle = (labelStyle ?? theme.textTheme.large).copyWith(
      height: 1,
    );

    Widget tab(int index) {
      final selected = index == selectedIndex;
      final child = Pressable(
        selected: selected,
        onPressed: onSelected == null ? null : () => onSelected!(index),
        builder: (context, states) {
          final active = selected || states.contains(WidgetState.hovered);
          return FocusRing(
            visible: states.contains(WidgetState.focused),
            borderRadius: theme.radius,
            child: SizedBox(
              height: barHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Padding(
                    // Tabs that share the width need little padding of
                    // their own; tabs that hug their label need room.
                    padding:
                        tabPadding ??
                        EdgeInsets.symmetric(horizontal: expand ? 4 : 16),
                    child: DefaultTextStyle.merge(
                      style: baseStyle.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: active
                            ? scheme.foreground
                            : scheme.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: tabs[index],
                    ),
                  ),
                  if (selected)
                    Positioned(
                      left: 0,
                      right: 0,
                      // Over the bar's own hairline, which a `DecoratedBox`
                      // paints inside the bar's height rather than adding
                      // to it — so the bottom edge is already the hairline.
                      bottom: 0,
                      height: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: indicatorColor ?? scheme.foreground,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
      return expand ? Expanded(child: child) : child;
    }

    Widget row = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [for (var i = 0; i < tabs.length; i++) tab(i)],
    );
    if (!expand) {
      row = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: row,
      );
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showBorder
              ? Border(bottom: BorderSide(color: scheme.border))
              : null,
        ),
        child: row,
      ),
    );
  }
}
