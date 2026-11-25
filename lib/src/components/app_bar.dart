import 'package:finesse/src/components/app_bar_layout.dart';
import 'package:finesse/src/theme/components/app_bar.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/system_overlay_style.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The bar across the top of a screen: a logo or back button, a title, and
/// actions.
///
/// ```dart
/// AppBar(
///   title: const Text('Settings'),
///   actions: [
///     IconButton.ghost(
///       tooltip: 'Notifications',
///       onPressed: _openNotifications,
///       icon: const PhosphorIcon(PhosphorIconsRegular.bell),
///     ),
///   ],
/// )
/// ```
///
/// **Zones.** With a [middle], the bar has three zones: [leading] and
/// [title] start aligned, [middle] centred in the bar, [actions] end
/// aligned. Without one, [title] takes the space between [leading] and
/// [actions] — or, with [centerTitle], sits in the centre of the bar the
/// way a pushed page's title does on iOS.
///
/// **The leading button.** A bar that is given no [leading] shows the one
/// its place calls for: a `CloseButton` on a full-screen dialog, a
/// `BackButton` on a page that can be popped, a menu button over a
/// `Scaffold` with a drawer. [automaticallyImplyLeading] turns that off.
/// Likewise a bar with no [actions] over a `Scaffold` with an end drawer
/// shows the button that opens it, unless [automaticallyImplyActions] is
/// false.
///
/// **Under the toolbar.** [bottom] is a second row inside the same surface
/// and above the hairline: a `TabBar`, a search field, a row of filter
/// chips. It adds its own height.
///
/// **The surface.** The bar's height follows the theme's form factor and
/// its fill follows the style's bar opacity: a translucent bar blurs
/// whatever scrolls beneath it, which is the reason to put it in a
/// `Scaffold` rather than a `Column`. With
/// [AppBarSurfaceBehavior.whenScrolled] the bar is bare while the page is
/// at its top and takes its fill, hairline and blur once content scrolls
/// under it. A primary bar also styles the system's status bar so that its
/// icons read on the bar.
///
/// The content is centred and capped at the width of a `PageContainer`'s
/// padding box, so on a wide screen the bar's ends sit one page margin
/// outside the page content below it.
class AppBar extends StatelessWidget {
  /// Creates an app bar.
  const AppBar({
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.centerTitle,
    this.middle,
    this.actions = const [],
    this.automaticallyImplyActions = true,
    this.bottom,
    this.height,
    this.padding,
    this.backgroundColor,
    this.showBorder = true,
    this.surfaceBehavior,
    this.systemOverlayStyle,
    this.maxWidth,
    this.gap,
    this.actionsGap,
    this.primary = true,
    super.key,
  });

  /// The widget at the start: a logo, a back button.
  final Widget? leading;

  /// Whether a bar without a [leading] shows the button its place calls
  /// for: close, back, or the scaffold's menu.
  final bool automaticallyImplyLeading;

  /// The widget after [leading]: a title, a search field, a person's name.
  ///
  /// It is announced as the page's heading — unless the bar has a [middle]:
  /// a bar that carries the app's navigation is not headed by what sits
  /// beside its logo.
  final Widget? title;

  /// Whether [title] is centred in the bar instead of following [leading].
  /// Defaults to the theme's, which is false. A [middle] has the centre
  /// first.
  final bool? centerTitle;

  /// A widget centred in the bar, usually a `NavigationBar`.
  final Widget? middle;

  /// The widgets at the end, usually icon buttons.
  final List<Widget> actions;

  /// Whether a bar without [actions] over a scaffold with an end drawer
  /// shows the button that opens it.
  final bool automaticallyImplyActions;

  /// A row under the toolbar, inside the bar's surface: a `TabBar`, a
  /// search field, filter chips. It takes the bar's width; give it its own
  /// margins.
  final Widget? bottom;

  /// The toolbar's height, not counting the safe area, [bottom] or the
  /// hairline under the bar. Defaults to the theme's.
  ///
  /// It is the height at the platform's own text size. With the text
  /// scaled up far enough that a line of the title no longer fits, the
  /// toolbar is as tall as that line; [heightOf] reports the result.
  final double? height;

  /// Padding around the toolbar's content. Defaults to the theme's page
  /// margin.
  final EdgeInsetsGeometry? padding;

  /// The bar's fill. Defaults to the theme's.
  final Color? backgroundColor;

  /// Whether a hairline is drawn under the bar.
  final bool showBorder;

  /// When the bar shows its fill, hairline and blur. Defaults to the
  /// theme's, which is always.
  ///
  /// [AppBarSurfaceBehavior.whenScrolled] needs a `Scaffold` above the bar:
  /// that is what tells it the page has scrolled.
  final AppBarSurfaceBehavior? surfaceBehavior;

  /// The style of the system's status bar over this bar. Defaults to
  /// transparent, with icons that read on the bar's fill. Only a [primary]
  /// bar sets one.
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// The widest the content grows. Defaults to the theme's page width.
  final double? maxWidth;

  /// The gap between [leading], [title], [middle] and [actions].
  final double? gap;

  /// The gap between two [actions].
  final double? actionsGap;

  /// Whether the bar sits at the top of the screen and should extend under
  /// the status bar.
  final bool primary;

  /// The height an [AppBar] without a `bottom` takes in [context],
  /// including the status bar when [primary], at the text scale of
  /// [context].
  static double heightOf(BuildContext context, {bool primary = true}) {
    final theme = Theme.of(context);
    return appBarToolbarHeight(context, theme.appBarTheme.height ?? 64) +
        // The hairline under the bar.
        1 +
        (primary ? MediaQuery.paddingOf(context).top : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.appBarTheme;
    final topInset = primary ? MediaQuery.paddingOf(context).top : 0.0;
    final toolbarHeight = appBarToolbarHeight(
      context,
      height ?? bar.height ?? 64,
    );
    final fill =
        backgroundColor ?? bar.backgroundColor ?? theme.colorScheme.card;
    final liquid = appBarUsesLiquidGlass(context, bar.liquidGlass);
    // On Liquid Glass the scroll edge shows once content is under the bar,
    // as on iOS: at the top it would only blur the page's own first lines.
    final behavior = liquid
        ? AppBarSurfaceBehavior.whenScrolled
        : surfaceBehavior ??
              bar.surfaceBehavior ??
              AppBarSurfaceBehavior.always;

    final implied = leading == null && automaticallyImplyLeading
        ? impliedLeading(context)
        : null;
    var effectiveLeading = leading ?? implied;
    var effectiveActions = automaticallyImplyActions
        ? impliedActions(context, actions)
        : actions;
    if (liquid) {
      (effectiveLeading, effectiveActions) = liquidGlassBarSlots(
        context,
        leading: effectiveLeading,
        actions: effectiveActions,
        actionsGap: actionsGap,
        leadingIsButton: implied != null,
      );
    }
    final toolbar = AppBarToolbar(
      height: toolbarHeight,
      leading: effectiveLeading,
      // The bar's own button lines its glyph up with the page margin, as
      // the title of a bar without one does. On glass the capsule does.
      alignLeadingGlyph: implied != null && !liquid,
      title: title,
      middle: middle,
      actions: effectiveActions,
      centerTitle: centerTitle ?? bar.centerTitle ?? false,
      padding: padding,
      maxWidth: maxWidth,
      gap: gap,
      actionsGap: actionsGap,
    );
    final content = bottom == null
        ? toolbar
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [toolbar, bottom!],
          );

    Widget surface(Animation<double>? visibility) => AppBarSurface(
      color: fill,
      borderColor: showBorder
          ? bar.borderColor ?? theme.colorScheme.border
          : null,
      blur: bar.blur ?? 0,
      saturation: bar.saturation ?? 1,
      // The hairline is added to the height rather than taken from it, so
      // a 64-point bar has 64 points for its content.
      padding: EdgeInsets.only(top: topInset),
      visibility: visibility,
      liquid: liquid,
      child: content,
    );

    Widget result = Semantics(
      container: true,
      child: behavior == AppBarSurfaceBehavior.always
          ? surface(null)
          : _ScrolledUnder(builder: surface),
    );
    if (primary) {
      result = AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            systemOverlayStyle ??
            systemOverlayStyleFor(
              surfaceBrightness(fill, theme.colorScheme.background),
            ),
        child: result,
      );
    }
    return result;
  }
}

/// Runs an animation up to 1 while the page under the nearest `Scaffold`
/// has scrolled away from its top, and back to 0 when it returns.
///
/// The builder runs once: what it builds follows the animation at paint
/// time.
class _ScrolledUnder extends StatefulWidget {
  const _ScrolledUnder({required this.builder});

  final Widget Function(Animation<double> scrolledUnder) builder;

  @override
  State<_ScrolledUnder> createState() => _ScrolledUnderState();
}

class _ScrolledUnderState extends State<_ScrolledUnder>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);
  ScrollNotificationObserverState? _observer;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ScrollNotificationObserver.maybeOf(context);
    if (identical(observer, _observer)) return;
    _observer?.removeListener(_onScroll);
    _observer = observer?..addListener(_onScroll);
  }

  void _onScroll(ScrollNotification notification) {
    // The page's own scroll view, not one nested inside it.
    if (notification is! ScrollUpdateNotification || notification.depth != 0) {
      return;
    }
    final metrics = notification.metrics;
    final under = switch (metrics.axisDirection) {
      AxisDirection.down => metrics.extentBefore > 0,
      // A reversed list, a conversation: its start is at the bottom.
      AxisDirection.up => metrics.extentAfter > 0,
      // A carousel in the page says nothing about what is under the bar.
      AxisDirection.left || AxisDirection.right => _scrolledUnder,
    };
    if (under == _scrolledUnder) return;
    _scrolledUnder = under;
    final motion = Motion.of(context);
    _controller.animateTo(
      under ? 1 : 0,
      duration: motion.fast,
      curve: motion.standard,
    );
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}
