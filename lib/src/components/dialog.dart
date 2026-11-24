import 'dart:ui';

import 'package:boxy/flex.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/theme_scope.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:finesse/src/utils/responsive.dart';
import 'package:finesse/src/utils/separated_iterable.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// {@template DialogRoute}
/// A custom dialog route that allows specifying a `reverseTransitionDuration`.
/// Tapping the barrier pops the route when [barrierDismissible] is true.
///
/// Used internally by [showDialog].
/// {@endtemplate}
class DialogRoute<T> extends PopupRoute<T> {
  /// {@macro DialogRoute}
  DialogRoute({
    required this.pageBuilder,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.barrierColor = const Color(0x1a000000),
    this.barrierBlurSigma = 2,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.reverseTransitionDuration = const Duration(milliseconds: 200),
    this.transitionBuilder,
    this.anchorPoint,
    this.opaque = false,
    super.settings,
  });

  /// Builds the content of the route, usually a [Dialog].
  final WidgetBuilder pageBuilder;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  @override
  final Color? barrierColor;

  /// {@template Dialog.barrierBlurSigma}
  /// The gaussian blur applied to whatever is behind the barrier, shadcn/ui's
  /// `backdrop-blur-xs`.
  ///
  /// Zero disables it. A blurred barrier is what lets the colour stay as light
  /// as `black/10` and still separate the dialog from the page.
  /// {@endtemplate}
  final double barrierBlurSigma;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  /// Builds the enter and exit transition. Defaults to a fade.
  final RouteTransitionsBuilder? transitionBuilder;

  /// Not used by this route. It is kept to match the arguments of
  /// [showDialog].
  final Offset? anchorPoint;

  @override
  final bool opaque;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Builder(builder: pageBuilder);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final content = transitionBuilder != null
        ? transitionBuilder!(context, animation, secondaryAnimation, child)
        : FadeTransition(opacity: animation, child: child);

    if (barrierBlurSigma <= 0) return content;

    // The filter sits above the barrier and below the dialog, and fades with
    // the route so the page does not snap out of focus. It must not hit-test:
    // the ColoredBox that gives the filter its extent is opaque to taps even
    // when fully transparent, and without the IgnorePointer it eats the
    // outside tap that should reach the ModalBarrier and dismiss the route.
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: animation,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: barrierBlurSigma,
                  sigmaY: barrierBlurSigma,
                ),
                child: const ColoredBox(color: Color(0x00000000)),
              ),
            ),
          ),
        ),
        content,
      ],
    );
  }
}

/// Displays a [Dialog] as a modal dialog with animation.
///
/// Shows a dialog with customizable barrier and animation properties, returning
/// a [Future] with the result when the dialog is dismissed.
Future<T?> showDialog<T>({
  /// The build context in which to show the dialog.
  required BuildContext context,

  /// The builder function to create the dialog content.
  required WidgetBuilder builder,

  /// Whether the dialog can be dismissed by tapping outside the barrier.
  /// Defaults to true.
  bool barrierDismissible = true,

  /// The color of the barrier behind the dialog.
  ///
  /// Defaults to `DialogTheme.barrierColor` — shadcn's `bg-black/10`,
  /// which works because the barrier is also blurred.
  Color? barrierColor,

  /// The gaussian blur applied behind the barrier.
  ///
  /// Defaults to `DialogTheme.barrierBlurSigma`.
  double? barrierBlurSigma,

  /// The accessibility label for the barrier, which dismisses the dialog.
  /// Defaults to the localized "Dismiss".
  String? barrierLabel,

  /// Whether to use the root navigator for routing.
  /// Defaults to true.
  bool useRootNavigator = true,

  /// Optional route settings for navigation.
  RouteSettings? routeSettings,

  /// The anchor point for positioning the dialog.
  Offset? anchorPoint,

  /// The animation effects when the dialog appears.
  /// Defaults to fade and scale-in if not specified.
  List<Effect<dynamic>>? animateIn,

  /// The animation effects when the dialog disappears.
  /// Defaults to fade and scale-out if not specified.
  List<Effect<dynamic>>? animateOut,

  /// The variant of the dialog to display.
  /// Defaults to [DialogVariant.primary].
  DialogVariant variant = DialogVariant.primary,

  /// Whether the route occludes the routes behind it.
  /// When false, [MediaQuery.viewInsetsOf] from the host scaffold will be
  /// available in the dialog context, allowing keyboard-aware content.
  /// Defaults to true (standard dialog behavior).
  bool opaque = false,
}) {
  final theme = Theme.of(context);
  final effectiveDialogTheme = switch (variant) {
    DialogVariant.primary => theme.primaryDialogTheme,
    DialogVariant.alert => theme.alertDialogTheme,
  };

  final effectiveAnimateIn =
      animateIn ??
      effectiveDialogTheme.animateIn ??
      const [
        FadeEffect(),
        ScaleEffect(begin: Offset(.95, .95), end: Offset(1, 1)),
      ];

  final effectiveAnimateOut =
      animateOut ??
      effectiveDialogTheme.animateOut ??
      const [
        FadeEffect(begin: 1, end: 0),
        ScaleEffect(begin: Offset(1, 1), end: Offset(.95, .95)),
      ];

  /// Returns the maximum duration(including delay) from
  /// the list of [Effect]s.
  Duration maxCompletionDuration(List<Effect<dynamic>> effects) {
    if (effects.isEmpty) return Duration.zero;

    return effects.fold<Duration>(
      Duration.zero, // start with zero
      (max, effect) {
        final effectTotal =
            (effect.delay ?? Duration.zero) +
            (effect.duration ?? Animate.defaultDuration);
        return effectTotal > max ? effectTotal : max;
      },
    );
  }

  // A route is built under the Navigator, so it does not see a Theme that
  // was applied to a subtree — only the app-level one. When the call site is
  // re-themed (see ThemeScope), republish its theme inside the route so
  // the dialog matches its surroundings. Otherwise follow the app-level theme
  // live: capturing it here froze an open dialog or sheet in the theme it was
  // opened with, so a light/dark switch left it behind.
  final ambientTheme = Theme.of(context, listen: false);
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themedLocally =
      ambientTheme != Theme.maybeOf(navigator.context, listen: false);
  final opener = context;

  return navigator.push(
    DialogRoute(
      pageBuilder: (routeContext) {
        // Depend on the app-level theme in both cases, so the route rebuilds
        // when it changes; a re-themed opener is re-read at that point.
        final appTheme = Theme.maybeOf(routeContext);
        return ThemeScope(
          data: !themedLocally && appTheme != null
              ? appTheme
              : opener.mounted
              ? Theme.of(opener, listen: false)
              : ambientTheme,
          child: Builder(builder: builder),
        );
      },
      barrierColor:
          barrierColor ??
          ambientTheme.primaryDialogTheme.barrierColor ??
          const Color(0x1a000000),
      barrierBlurSigma:
          barrierBlurSigma ??
          ambientTheme.primaryDialogTheme.barrierBlurSigma ??
          2,
      barrierDismissible: barrierDismissible,
      barrierLabel:
          barrierLabel ?? FinesseLocalizations.of(context).dialog.dismiss,
      anchorPoint: anchorPoint,
      settings: routeSettings,
      opaque: opaque,
      transitionDuration: maxCompletionDuration(effectiveAnimateIn),
      reverseTransitionDuration: maxCompletionDuration(effectiveAnimateOut),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (animation.status == AnimationStatus.completed) {
          return child;
        }
        final animateIn = animation.status == AnimationStatus.forward;
        return FinesseAnimate(
          effects: animateIn ? effectiveAnimateIn : effectiveAnimateOut,
          child: child,
        );
      },
    ),
  );
}

/// Variants available for the [Dialog] widget.
enum DialogVariant {
  /// A standard dialog with a close button.
  primary,

  /// A dialog that needs a response. It has no close button by default, so the
  /// user picks one of the actions. Styled by `alertDialogTheme`.
  alert,
}

/// A customizable dialog widget for displaying content and actions.
///
/// The [Dialog] widget provides a styled container for presenting a title,
/// description, custom content, and actions in a modal format. It supports
/// variants (primary and alert) and integrates with [Theme] for styling.
/// Use named constructors like [Dialog.alert] for alert-specific styling or
/// [Dialog.raw] for full control.
class Dialog extends StatelessWidget {
  /// Creates a primary variant dialog widget.
  const Dialog({
    super.key,
    this.title,
    this.description,
    this.child,
    this.actions = const [],
    this.closeIcon,
    this.closeIconData,
    this.onClose,
    this.semanticLabel,
    this.closeIconPosition,
    this.radius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.constraints,
    this.border,
    this.shadows,
    this.removeBorderRadiusWhenTiny,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.alignment,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.actionsGap,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
  }) : variant = DialogVariant.primary;

  /// Creates an alert variant dialog widget, typically for warnings or
  /// critical messages.
  const Dialog.alert({
    super.key,
    this.title,
    this.description,
    this.child,
    this.actions = const [],
    this.closeIcon,
    this.closeIconData,
    this.onClose,
    this.semanticLabel,
    this.closeIconPosition,
    this.radius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.constraints,
    this.border,
    this.shadows,
    this.removeBorderRadiusWhenTiny,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.alignment,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.actionsGap,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
  }) : variant = DialogVariant.alert;

  /// Creates a dialog widget with a specified [variant], offering full
  /// customization.
  const Dialog.raw({
    super.key,
    required this.variant,
    this.title,
    this.description,
    this.child,
    this.actions = const [],
    this.closeIcon,
    this.closeIconData,
    this.onClose,
    this.semanticLabel,
    this.closeIconPosition,
    this.radius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.constraints,
    this.border,
    this.shadows,
    this.removeBorderRadiusWhenTiny,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.alignment,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.actionsGap,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
  });

  /// {@template Dialog.title}
  /// The title widget displayed at the top of the dialog.
  /// Typically a [Text] widget, styled with the theme’s large text style.
  /// {@endtemplate}
  final Widget? title;

  /// {@template Dialog.description}
  /// The description widget displayed below the title.
  /// Typically a [Text] widget, styled with the theme’s muted style.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Dialog.child}
  /// The main content widget of the dialog, displayed below the description.
  /// Expands to fill available space if scrollable.
  /// {@endtemplate}
  final Widget? child;

  /// {@template Dialog.variant}
  /// The variant of the dialog, either [DialogVariant.primary] or
  /// [DialogVariant.alert]. Determines the visual style applied through the
  /// [Theme].
  /// {@endtemplate}
  final DialogVariant variant;

  /// {@template Dialog.actions}
  /// The list of action widgets displayed at the bottom of the dialog.
  /// Typically buttons, arranged based on [actionsAxis].
  /// Defaults to an empty list if not specified.
  /// {@endtemplate}
  final List<Widget> actions;

  /// {@template Dialog.closeIcon}
  /// The custom widget for the close button.
  /// Overrides [closeIconData] if provided; defaults to a ghost button with an
  /// 'X' icon.
  /// {@endtemplate}
  final Widget? closeIcon;

  /// {@template Dialog.closeIconData}
  /// The icon data for the close button.
  /// Used if [closeIcon] is null; defaults to [LucideIcons.x] if not specified.
  /// {@endtemplate}
  final IconData? closeIconData;

  /// {@template Dialog.onClose}
  /// Called when the default close button is pressed. Defaults to
  /// `Navigator.maybePop`, which respects a `PopScope` around the dialog.
  /// Not used when [closeIcon] replaces the button.
  /// {@endtemplate}
  final VoidCallback? onClose;

  /// {@template Dialog.semanticLabel}
  /// The accessible name of the dialog, announced when it opens.
  ///
  /// Defaults to null, in which case screen readers fall back to reading the
  /// dialog's contents.
  /// {@endtemplate}
  final String? semanticLabel;

  /// {@template Dialog.closeIconPosition}
  /// The position of the close icon within the dialog.
  /// Defaults to top-end (8, 8) if not specified.
  /// {@endtemplate}
  final Position? closeIconPosition;

  /// {@template Dialog.radius}
  /// The border radius of the dialog’s corners.
  /// Defaults to the theme’s radius if not specified.
  /// {@endtemplate}
  final BorderRadius? radius;

  /// {@template Dialog.backgroundColor}
  /// The background color of the dialog.
  /// Defaults to the theme’s background color if not specified.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Dialog.expandActionsWhenTiny}
  /// Whether actions expand to full width on small screens.
  /// Defaults to true if not specified.
  /// {@endtemplate}
  final bool? expandActionsWhenTiny;

  /// {@template Dialog.padding}
  /// The padding inside the dialog, surrounding all content.
  /// Defaults to EdgeInsets.all(24) if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Dialog.gap}
  /// The gap between content elements (title, description, child, actions).
  /// Defaults to 8 if not specified.
  /// {@endtemplate}
  final double? gap;

  /// {@template Dialog.constraints}
  /// Constraints applied to the dialog’s layout.
  /// Defaults to a max width of 512 if not specified.
  /// {@endtemplate}
  final BoxConstraints? constraints;

  /// {@template Dialog.border}
  /// The border surrounding the dialog.
  /// Defaults to a border with the theme’s border color if not specified.
  /// {@endtemplate}
  final BoxBorder? border;

  /// {@template Dialog.shadows}
  /// The list of box shadows applied to the dialog for elevation.
  /// Defaults to large shadows if not specified.
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Dialog.removeBorderRadiusWhenTiny}
  /// Whether to remove the border radius on small screens.
  /// Defaults to true if not specified.
  /// {@endtemplate}
  final bool? removeBorderRadiusWhenTiny;

  /// {@template Dialog.actionsAxis}
  /// The axis along which actions are arranged (horizontal or vertical).
  /// Responsive to screen size if not specified.
  /// {@endtemplate}
  final Axis? actionsAxis;

  /// {@template Dialog.actionsMainAxisSize}
  /// The main axis size of the actions layout.
  /// Defaults to [MainAxisSize.max] if not specified.
  /// {@endtemplate}
  final MainAxisSize? actionsMainAxisSize;

  /// {@template Dialog.actionsMainAxisAlignment}
  /// The main axis alignment of the actions.
  /// Defaults to [MainAxisAlignment.end] if not specified.
  /// {@endtemplate}
  final MainAxisAlignment? actionsMainAxisAlignment;

  /// {@template Dialog.actionsVerticalDirection}
  /// The vertical direction of the actions layout when vertical.
  /// Responsive to screen size if not specified.
  /// {@endtemplate}
  final VerticalDirection? actionsVerticalDirection;

  /// {@template Dialog.titleStyle}
  /// The text style for the title.
  /// Defaults to the theme’s large text style if not specified.
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template Dialog.descriptionStyle}
  /// The text style for the description.
  /// Defaults to the theme’s muted text style if not specified.
  /// {@endtemplate}
  final TextStyle? descriptionStyle;

  /// {@template Dialog.titleTextAlign}
  /// The text alignment for the title.
  /// Responsive to screen size if not specified.
  /// {@endtemplate}
  final TextAlign? titleTextAlign;

  /// {@template Dialog.descriptionTextAlign}
  /// The text alignment for the description.
  /// Responsive to screen size if not specified.
  /// {@endtemplate}
  final TextAlign? descriptionTextAlign;

  /// {@template Dialog.alignment}
  /// The alignment of the dialog within its parent container.
  /// Defaults to [Alignment.center] if not specified.
  /// {@endtemplate}
  final Alignment? alignment;

  /// {@template Dialog.mainAxisAlignment}
  /// The main axis alignment of the dialog’s column content.
  /// Defaults to [MainAxisAlignment.start] if not specified.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template Dialog.crossAxisAlignment}
  /// The cross axis alignment of the dialog’s column content.
  /// Defaults to [CrossAxisAlignment.start] if not specified.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template Dialog.scrollable}
  /// Whether the dialog content is scrollable.
  ///
  /// Defaults to true if not specified.
  /// {@endtemplate}
  final bool? scrollable;

  /// {@template Dialog.scrollPadding}
  /// The padding applied when the dialog content is scrollable.
  ///
  /// If not specified, no additional padding is applied to the scrollable
  /// content.
  /// {@endtemplate}
  final EdgeInsetsGeometry? scrollPadding;

  /// {@template Dialog.actionsGap}
  /// The gap between action buttons.

  /// Defaults to 8 if not specified.
  /// {@endtemplate}
  final double? actionsGap;

  /// {@template Dialog.useSafeArea}
  /// Whether to wrap the dialog in a SafeArea widget to avoid system UI
  /// intrusions.
  ///
  /// Defaults to true if not specified.
  /// {@endtemplate}
  final bool? useSafeArea;

  /// {@template Dialog.titlePinned}
  /// Whether the title is pinned when scrolling and [scrollable] is true.
  ///
  /// Defaults to false if not specified.
  /// {@endtemplate}
  final bool? titlePinned;

  /// {@template Dialog.descriptionPinned}
  /// Whether the description is pinned when scrolling and [scrollable] is true.
  ///
  /// Defaults to false if not specified.
  /// {@endtemplate}
  final bool? descriptionPinned;

  /// {@template Dialog.actionsPinned}
  /// Whether the actions are pinned when scrolling and [scrollable] is true.
  ///
  /// Defaults to true if not specified.
  /// {@endtemplate}
  final bool? actionsPinned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDialogTheme = switch (variant) {
      DialogVariant.primary => theme.primaryDialogTheme,
      DialogVariant.alert => theme.alertDialogTheme,
    };

    final effectiveBackgroundColor =
        backgroundColor ??
        effectiveDialogTheme.backgroundColor ??
        theme.colorScheme.background;

    final effectiveCloseIcon =
        closeIcon ??
        (closeIconData == null && effectiveDialogTheme.closeIconData == null
            ? null
            : IconButton.ghost(
                icon: Icon(
                  size: 16,
                  closeIconData ??
                      effectiveDialogTheme.closeIconData ??
                      LucideIcons.x,
                ),
                width: 20,
                height: 20,
                padding: EdgeInsets.zero,
                foregroundColor: theme.colorScheme.foreground.withValues(
                  alpha: .5,
                ),
                hoverBackgroundColor: const Color(0x00000000),
                hoverForegroundColor: theme.colorScheme.foreground,
                pressedForegroundColor: theme.colorScheme.foreground,
                semanticLabel: FinesseLocalizations.of(context).dialog.close,
                onPressed: onClose ?? () => Navigator.of(context).maybePop(),
              ));

    final effectiveCloseIconPosition =
        closeIconPosition ??
        effectiveDialogTheme.closeIconPosition ??
        Position.directional(
          top: 8,
          end: 8,
          textDirection: Directionality.of(context),
        );

    final effectiveRadius =
        radius ?? effectiveDialogTheme.radius ?? theme.radius;

    final effectiveExpandActionsWhenTiny =
        expandActionsWhenTiny ??
        effectiveDialogTheme.expandActionsWhenTiny ??
        true;

    final effectiveConstraints =
        constraints ??
        effectiveDialogTheme.constraints ??
        const BoxConstraints(maxWidth: 512);

    final effectiveBorder =
        border ??
        effectiveDialogTheme.border ??
        Border.all(color: theme.colorScheme.border);

    final effectiveShadows =
        shadows ?? effectiveDialogTheme.shadows ?? Shadows.lg;

    final effectiveRemoveBorderRadiusWhenTiny =
        removeBorderRadiusWhenTiny ??
        effectiveDialogTheme.removeBorderRadiusWhenTiny ??
        true;
    final effectivePadding =
        padding ?? effectiveDialogTheme.padding ?? const EdgeInsets.all(24);

    final effectiveGap = gap ?? effectiveDialogTheme.gap ?? 8;

    final effectiveTitleStyle =
        (titleStyle ?? effectiveDialogTheme.titleStyle ?? theme.textTheme.large)
            .fallback(color: theme.colorScheme.foreground);

    final effectiveDescriptionStyle =
        (descriptionStyle ??
                effectiveDialogTheme.descriptionStyle ??
                theme.textTheme.muted)
            .fallback(
              color: theme.colorScheme.mutedForeground,
            );

    final effectiveAlignment =
        alignment ?? effectiveDialogTheme.alignment ?? Alignment.center;

    final effectiveMainAxisAlignment =
        mainAxisAlignment ??
        effectiveDialogTheme.mainAxisAlignment ??
        MainAxisAlignment.start;

    final effectiveCrossAxisAlignment =
        crossAxisAlignment ??
        effectiveDialogTheme.crossAxisAlignment ??
        CrossAxisAlignment.start;

    final effectiveScrollable =
        scrollable ?? effectiveDialogTheme.scrollable ?? true;

    final effectiveScrollPadding =
        scrollPadding ?? effectiveDialogTheme.scrollPadding;

    final effectiveActionsGap =
        actionsGap ?? effectiveDialogTheme.actionsGap ?? 8;

    final effectiveUseSafeArea =
        useSafeArea ?? effectiveDialogTheme.useSafeArea ?? true;

    final effectiveTitlePinned =
        titlePinned ?? effectiveDialogTheme.titlePinned ?? false;

    final effectiveDescriptionPinned =
        descriptionPinned ?? effectiveDialogTheme.descriptionPinned ?? false;

    final effectiveActionsPinned =
        actionsPinned ?? effectiveDialogTheme.actionsPinned ?? true;

    final dialog = ConstrainedBox(
      constraints: effectiveConstraints,
      child: ResponsiveBuilder(
        builder: (context, breakpoint) {
          final sm = breakpoint >= theme.breakpoints.sm;

          final effectiveActionsAxis =
              actionsAxis ??
              effectiveDialogTheme.actionsAxis ??
              (sm ? Axis.horizontal : Axis.vertical);

          final effectiveActionsMainAxisSize =
              actionsMainAxisSize ??
              effectiveDialogTheme.actionsMainAxisSize ??
              MainAxisSize.min;

          final effectiveActionsMainAxisAlignment =
              actionsMainAxisAlignment ??
              effectiveDialogTheme.actionsMainAxisAlignment ??
              MainAxisAlignment.end;

          final effectiveActionsVerticalDirection =
              actionsVerticalDirection ??
              effectiveDialogTheme.actionsVerticalDirection ??
              (sm ? VerticalDirection.down : VerticalDirection.up);

          final effectiveTitleTextAlign =
              titleTextAlign ??
              effectiveDialogTheme.titleTextAlign ??
              (sm ? TextAlign.start : TextAlign.center);

          final effectiveDescriptionTextAlign =
              descriptionTextAlign ??
              effectiveDialogTheme.descriptionTextAlign ??
              (sm ? TextAlign.start : TextAlign.center);

          Widget? effectiveActions = actions.isEmpty
              ? null
              : BoxyFlexible.align(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  child: Flex(
                    direction: effectiveActionsAxis,
                    mainAxisSize: effectiveActionsMainAxisSize,
                    mainAxisAlignment: effectiveActionsMainAxisAlignment,
                    verticalDirection: effectiveActionsVerticalDirection,
                    spacing: effectiveActionsGap,
                    children: actions,
                  ),
                );

          if (!sm &&
              effectiveExpandActionsWhenTiny &&
              effectiveActions != null) {
            effectiveActions = Theme(
              data: theme.copyWith(
                primaryButtonTheme: theme.primaryButtonTheme.copyWith(
                  width: double.infinity,
                  expands: true,
                ),
                secondaryButtonTheme: theme.secondaryButtonTheme.copyWith(
                  width: double.infinity,
                  expands: true,
                ),
                outlineButtonTheme: theme.outlineButtonTheme.copyWith(
                  width: double.infinity,
                  expands: true,
                ),
                ghostButtonTheme: theme.ghostButtonTheme.copyWith(
                  width: double.infinity,
                  expands: true,
                ),
                destructiveButtonTheme: theme.destructiveButtonTheme.copyWith(
                  width: double.infinity,
                  expands: true,
                ),
              ),
              // Full-width buttons give their labels the button's width, so
              // a long label ellipsizes instead of overflowing the button.
              child: DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                child: effectiveActions,
              ),
            );
          }

          final effectiveTitle = title != null
              ? DefaultTextStyle(
                  style: effectiveTitleStyle,
                  textAlign: effectiveTitleTextAlign,
                  child: title!,
                )
              : null;

          final effectiveDescription = description != null
              ? DefaultTextStyle(
                  style: effectiveDescriptionStyle,
                  textAlign: effectiveDescriptionTextAlign,
                  child: description!,
                )
              : null;

          final effectiveChild = child != null
              ? DefaultTextStyle(
                  style: effectiveDescriptionStyle,
                  child: child!,
                )
              : null;

          Widget widget = BoxyColumn(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: effectiveMainAxisAlignment,
            crossAxisAlignment: effectiveCrossAxisAlignment,
            children: [
              // Only show title if not scrollable or scrollable but not pinned
              if (effectiveTitle != null &&
                  (!effectiveScrollable || !effectiveTitlePinned))
                effectiveTitle,
              // Only show description if not scrollable or scrollable but not
              // pinned
              if (effectiveDescription != null &&
                  (!effectiveScrollable || !effectiveDescriptionPinned))
                effectiveDescription,
              if (effectiveChild != null) Flexible(child: effectiveChild),
              // Only show actions if not scrollable or scrollable but not
              // pinned
              if (effectiveActions != null &&
                  (!effectiveScrollable || !effectiveActionsPinned))
                effectiveActions,
            ].separatedBy(SizedBox(height: effectiveGap)),
          );

          if (effectiveScrollable) {
            widget = BoxyColumn(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: effectiveMainAxisAlignment,
              crossAxisAlignment: effectiveCrossAxisAlignment,
              children: [
                // Pinned title
                if (effectiveTitle != null && effectiveTitlePinned)
                  effectiveTitle,
                // Pinned description
                if (effectiveDescription != null && effectiveDescriptionPinned)
                  effectiveDescription,
                Flexible(
                  child: SingleChildScrollView(
                    padding: effectiveScrollPadding,
                    child: widget,
                  ),
                ),
                // Pinned actions
                if (effectiveActions != null && effectiveActionsPinned)
                  effectiveActions,
              ].separatedBy(SizedBox(height: effectiveGap)),
            );
          }

          widget = Stack(
            children: [
              Padding(
                padding: effectivePadding,
                child: widget,
              ),
              if (effectiveCloseIcon != null)
                effectiveCloseIcon.positionedWith(effectiveCloseIconPosition),
            ],
          );

          if (effectiveUseSafeArea) {
            widget = SafeArea(child: widget);
          }

          return DecoratedBox(
            decoration: ShadowDecoration.box(
              color: effectiveBackgroundColor,
              borderRadius: (!sm && effectiveRemoveBorderRadiusWhenTiny)
                  ? null
                  : effectiveRadius,
              border: effectiveBorder,
              shadows: effectiveShadows,
            ),
            child: widget,
          );
        },
      ),
    );

    // Get the current view padding
    final viewPadding = MediaQuery.viewInsetsOf(context);

    return Semantics(
      // Matches what Flutter's own AlertDialog publishes: the dialog names the
      // route it scopes, and its children are described explicitly rather than
      // being flattened into one label. DialogRoute extends PopupRoute, so
      // the focus trap and focus restoration already come from ModalRoute.
      scopesRoute: true,
      explicitChildNodes: true,
      namesRoute: semanticLabel != null,
      label: semanticLabel,
      child: Align(
        alignment: effectiveAlignment,
        child: Padding(
          padding: viewPadding,
          child: dialog,
        ),
      ),
    );
  }
}
