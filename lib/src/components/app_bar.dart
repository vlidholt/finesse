import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:flutter/widgets.dart';

/// The bar across the top of a screen: a logo or back button, a title, and
/// actions.
///
/// ```dart
/// AppBar(
///   leading: const Logo(),
///   middle: NavigationBar(destinations: destinations, selectedIndex: 0),
///   actions: [
///     IconButton.ghost(icon: const Icon(PhosphorIconsRegular.bell)),
///   ],
/// )
/// ```
///
/// With a [middle], the bar has three zones: [leading] and [title] start
/// aligned, [middle] centred in the bar, [actions] end aligned. Without one,
/// [title] takes the space between [leading] and [actions].
///
/// The bar's height follows the theme's form factor and its fill follows the
/// style's bar opacity: a translucent bar blurs whatever scrolls beneath it,
/// which is the reason to put it in a [Scaffold] rather than a `Column`. The
/// content is centred and capped at the width of a `PageContainer`'s padding
/// box, so on a wide screen the bar's ends sit one page margin outside the
/// page content below it.
class AppBar extends StatelessWidget {
  /// Creates an app bar.
  const AppBar({
    this.leading,
    this.title,
    this.middle,
    this.actions = const [],
    this.height,
    this.padding,
    this.backgroundColor,
    this.showBorder = true,
    this.maxWidth,
    this.gap,
    this.actionsGap,
    this.primary = true,
    super.key,
  });

  /// The widget at the start: a logo, a back button.
  final Widget? leading;

  /// The widget after [leading]: a title, a search field, a person's name.
  final Widget? title;

  /// A widget centred in the bar, usually a `NavigationBar`.
  final Widget? middle;

  /// The widgets at the end, usually icon buttons.
  final List<Widget> actions;

  /// The bar's height, not counting the safe area or the hairline under
  /// it. Defaults to the theme's.
  final double? height;

  /// Padding around the content. Defaults to the theme's page margin.
  final EdgeInsetsGeometry? padding;

  /// The bar's fill. Defaults to the theme's.
  final Color? backgroundColor;

  /// Whether a hairline is drawn under the bar.
  final bool showBorder;

  /// The widest the content grows. Defaults to the theme's page width.
  final double? maxWidth;

  /// The gap between [leading], [title], [middle] and [actions].
  final double? gap;

  /// The gap between two [actions].
  final double? actionsGap;

  /// Whether the bar sits at the top of the screen and should extend under
  /// the status bar.
  final bool primary;

  /// The height an [AppBar] takes in [context], including the status bar
  /// when [primary]. A [Scaffold] uses it to inset its body.
  static double heightOf(BuildContext context, {bool primary = true}) {
    final theme = Theme.of(context);
    return (theme.appBarTheme.height ?? 64) +
        // The hairline under the bar.
        1 +
        (primary ? MediaQuery.paddingOf(context).top : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.appBarTheme;
    final topInset = primary ? MediaQuery.paddingOf(context).top : 0.0;
    final effectiveGap = gap ?? bar.gap ?? 24;
    final foreground = bar.foregroundColor ?? theme.colorScheme.foreground;

    final actionsRow = actions.isEmpty
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: actionsGap ?? theme.layoutTheme.gapSm ?? 8,
            children: actions,
          );

    final Widget content;
    if (middle != null) {
      content = Row(
        spacing: effectiveGap,
        children: [
          Expanded(
            child: Row(
              spacing: effectiveGap - 4,
              children: [
                ?leading,
                if (title != null) Flexible(child: title!),
              ],
            ),
          ),
          middle!,
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: actionsRow,
            ),
          ),
        ],
      );
    } else {
      content = Row(
        spacing: effectiveGap / 2,
        children: [
          ?leading,
          Expanded(child: title ?? const SizedBox.shrink()),
          ?actionsRow,
        ],
      );
    }

    return Semantics(
      container: true,
      child: Backdrop(
        blur: bar.blur ?? 0,
        saturation: bar.saturation ?? 1,
        child: Container(
          // The hairline is added to the height rather than taken from it,
          // so a 64-point bar has 64 points for its content.
          height:
              (height ?? bar.height ?? 64) + topInset + (showBorder ? 1 : 0),
          padding: EdgeInsets.only(top: topInset),
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                bar.backgroundColor ??
                theme.colorScheme.card,
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: bar.borderColor ?? theme.colorScheme.border,
                    ),
                  )
                : null,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? bar.maxWidth ?? double.infinity,
              ),
              child: Padding(
                padding:
                    padding ??
                    bar.padding ??
                    const EdgeInsets.symmetric(horizontal: 24),
                child: DefaultTextStyle.merge(
                  style: (bar.titleStyle ?? theme.textTheme.large).copyWith(
                    color: foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: IconTheme.merge(
                    data: IconThemeData(color: foreground),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
