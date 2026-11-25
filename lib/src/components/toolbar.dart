import 'package:finesse/src/components/bottom_bar_surface.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/arrow_key_focus.dart';
import 'package:flutter/widgets.dart';

/// A bar of actions along the bottom of a screen: what can be done with
/// what is showing — reply, archive, delete; bold, italic, link.
///
/// ```dart
/// Scaffold(
///   body: message,
///   bottomNavigationBar: Toolbar(
///     children: [
///       IconButton.ghost(
///         icon: const PhosphorIcon(PhosphorIconsRegular.archive),
///         semanticLabel: 'Archive',
///         onPressed: archive,
///       ),
///       IconButton.ghost(
///         icon: const PhosphorIcon(PhosphorIconsRegular.trash),
///         semanticLabel: 'Delete',
///         onPressed: delete,
///       ),
///     ],
///     trailing: Button(onPressed: reply, child: const Text('Reply')),
///   ),
/// )
/// ```
///
/// It has the surface of a `BottomNavigationBar` and follows the same
/// theme: in a style whose bottom bar floats it is a glass pill as wide as
/// its content, otherwise it spans the bottom edge under a hairline. It
/// keeps clear of the bottom safe area. A `Scaffold` takes it as its
/// `bottomNavigationBar`, where the page scrolls beneath it.
///
/// [children] are usually `IconButton.ghost`s; [leading] and [trailing]
/// hold the things that stand apart at either end — a count, the one
/// labelled button. Plain icons and text take the bar's colour and size.
/// The arrow keys move the focus along the bar.
class Toolbar extends StatelessWidget {
  /// Creates a toolbar.
  const Toolbar({
    required this.children,
    this.leading,
    this.trailing,
    this.floating,
    this.alignment = MainAxisAlignment.spaceBetween,
    this.padding,
    super.key,
  });

  /// The actions, in reading order.
  final List<Widget> children;

  /// Shown at the start of the bar, apart from [children].
  final Widget? leading;

  /// Shown at the end of the bar, apart from [children].
  final Widget? trailing;

  /// Whether the bar floats as a pill. Defaults to the theme's, as a
  /// `BottomNavigationBar` does.
  final bool? floating;

  /// How [children] share the width of a bar that spans the screen. A
  /// floating bar is as wide as its content, so there is nothing to share.
  final MainAxisAlignment alignment;

  /// The space around the bar's content, on top of the bar's own padding.
  /// Defaults to none in a floating bar and the page's margin at the sides
  /// of a docked one.
  final EdgeInsetsGeometry? padding;

  /// The height a [Toolbar] takes in [context], including its margin and
  /// the bottom safe area. A `Scaffold` uses it to inset its body before
  /// the bar has been measured.
  static double heightOf(BuildContext context) {
    final bar = Theme.of(context).bottomNavigationBarTheme;
    return (bar.itemHeight ?? 48) +
        BottomBarSurface.extentAround(
          context,
          floating: BottomBarSurface.floatsIn(context),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.bottomNavigationBarTheme;
    final isFloating = floating ?? BottomBarSurface.floatsIn(context);
    final gap = bar.gap ?? 4;
    final apart = theme.layoutTheme.gap(GapSize.sm);
    final effectivePadding =
        padding ??
        (isFloating
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(
                horizontal: theme.layoutTheme.gap(GapSize.sm),
              ));

    Widget row = Row(
      mainAxisSize: isFloating ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: isFloating ? MainAxisAlignment.start : alignment,
      spacing: gap,
      children: children,
    );
    if (leading != null || trailing != null) {
      row = Row(
        mainAxisSize: isFloating ? MainAxisSize.min : MainAxisSize.max,
        spacing: apart,
        children: [
          ?leading,
          if (isFloating) row else Expanded(child: row),
          ?trailing,
        ],
      );
    }

    return BottomBarSurface(
      floating: isFloating,
      child: Padding(
        padding: effectivePadding,
        // A floor: the bar is as tall as a bottom bar, and taller if what
        // is in it — scaled text, a tall button — needs the room.
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: bar.itemHeight ?? 48),
          child: IconTheme.merge(
            data: IconThemeData(
              color: bar.foregroundColor ?? theme.colorScheme.foregroundSubtle,
              size: bar.iconSize,
            ),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.foreground,
              ),
              child: ArrowKeyFocus(
                child: FocusTraversalGroup(child: row),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
