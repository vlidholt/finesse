import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:finesse/src/utils/text_scaled_height.dart';
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
/// The line is one shape: selecting another tab slides it there, stretching
/// a little on the way, and the labels' colours fade — the theme's `Motion`
/// sets the pace, and reduced motion moves it at once.
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

  /// The tabs' height, not counting the hairline under them. Defaults to
  /// the style's underline tab height.
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
    final motion = Motion.of(context);
    final indicator = BoxDecoration(
      color: indicatorColor ?? scheme.foreground,
      borderRadius: BorderRadius.circular(2),
    );

    Widget tab(int index) {
      final selected = index == selectedIndex;
      final child = Pressable(
        selected: selected,
        onPressed: onSelected == null ? null : () => onSelected!(index),
        // The travelling line is the response; a tab that shrank would
        // take its end of the line with it.
        pressScale: 1,
        builder: (context, states) {
          final active = selected || states.contains(WidgetState.hovered);
          return FocusRing(
            visible: states.contains(WidgetState.focused),
            borderRadius: theme.radius,
            // A floor once text is scaled up, so a label is never taller
            // than its tab; at a scale of 1 the two are the same.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: barHeight,
                maxHeight: textScaledMaxHeight(context, barHeight),
              ),
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
                    // The colour fades; the weight cannot (a face is one
                    // weight, and a label that changed width every frame
                    // would shake its neighbours), so it switches at once.
                    child: AnimatedColorBuilder(
                      color: active
                          ? scheme.foreground
                          : scheme.mutedForeground,
                      duration: motion.fast,
                      curve: motion.standard,
                      builder: (context, color, child) =>
                          DefaultTextStyle.merge(
                            style: baseStyle.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: child!,
                          ),
                      child: tabs[index],
                    ),
                  ),
                  // Where the line goes when this tab is selected. The line
                  // itself is painted once, by the bar, and travels.
                  Positioned(
                    left: 0,
                    right: 0,
                    // Over the bar's own hairline, which sits just below
                    // the tabs.
                    bottom: showBorder ? -1 : 0,
                    height: 2,
                    child: MovingIndicatorTarget(
                      selected: selected,
                      decoration: indicator,
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

    // Around the row, inside the scroll view: the line scrolls with the
    // tabs. In front of them, so it also covers the hairline.
    Widget row = MovingIndicator(
      position: DecorationPosition.foreground,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [for (var i = 0; i < tabs.length; i++) tab(i)],
      ),
    );
    if (!expand) {
      // Clipped at the sides, but one pixel taller than the tabs so the
      // indicator can reach over the hairline.
      row = ClipRect(
        clipper: const _BelowByOneClipper(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: row,
        ),
      );
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      // A `Container`, not a `DecoratedBox`: its border is laid out under
      // the tabs, so the hairline adds to the bar's height as it does in CSS
      // rather than eating into it.
      child: Container(
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

class _BelowByOneClipper extends CustomClipper<Rect> {
  const _BelowByOneClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width, size.height + 1);

  @override
  bool shouldReclip(_BelowByOneClipper oldClipper) => false;
}
