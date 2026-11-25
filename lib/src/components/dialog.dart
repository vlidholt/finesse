import 'dart:ui';

import 'package:boxy/flex.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/expanded_actions_theme.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:finesse/src/utils/responsive.dart';
import 'package:finesse/src/utils/route_theme.dart';
import 'package:finesse/src/utils/separated_iterable.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    return Stack(children: [_barrierBlur(animation), content]);
  }

  Widget? _blurLayer;
  Animation<double>? _blurAnimation;

  /// The blur behind the dialog, growing with [animation].
  ///
  /// The framework calls [buildTransitions] on every tick; the layer is made
  /// once per animation and handed back as the same widget, so a tick
  /// rebuilds it through its own listener only, not a second time from
  /// above.
  ///
  /// The filter sits above the barrier and below the dialog, and grows with
  /// the route so the page does not snap out of focus. It is not faded in:
  /// under an opacity layer a backdrop filter samples that layer, which is
  /// empty, so on some renderers the blur was missing for the whole
  /// transition and appeared at its end. It must not hit-test either: the
  /// ColoredBox that gives the filter its extent is opaque to taps even
  /// when fully transparent, and without the IgnorePointer it eats the
  /// outside tap that should reach the ModalBarrier and dismiss the route.
  Widget _barrierBlur(Animation<double> animation) {
    final cached = _blurLayer;
    if (cached != null && identical(animation, _blurAnimation)) return cached;
    _blurAnimation = animation;
    return _blurLayer = Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          child: const ColoredBox(color: Color(0x00000000)),
          builder: (context, child) {
            final sigma = barrierBlurSigma * animation.value;
            return BackdropFilter(
              enabled: sigma > 0,
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// Plays a dialog's entrance and exit effects around the route's content.
///
/// A route's transition is rebuilt on every tick of its animation, each
/// time around a new [child]. Building the animate widget there re-added
/// every effect and rebuilt every effect's animation sixty times a second.
/// Here it is made once per direction and kept, with a [_RouteChildSlot]
/// where the content goes: a tick reaches the slot through [_RouteChild] and
/// leaves the effects alone.
class _DialogTransition extends StatefulWidget {
  const _DialogTransition({
    required this.animation,
    required this.animateIn,
    required this.animateOut,
    required this.child,
  });

  /// The route's animation. Only its status is read: the effects play on
  /// their own controller, for the lengths the route was given.
  final Animation<double> animation;

  final List<Effect<dynamic>> animateIn;
  final List<Effect<dynamic>> animateOut;
  final Widget child;

  @override
  State<_DialogTransition> createState() => _DialogTransitionState();
}

class _DialogTransitionState extends State<_DialogTransition> {
  Widget? _animated;
  bool _entering = false;

  @override
  void didUpdateWidget(_DialogTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Effects have no `==`; a list is the same when it is the same list.
    if (!identical(widget.animateIn, oldWidget.animateIn) ||
        !identical(widget.animateOut, oldWidget.animateOut)) {
      _animated = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // The status changes on a tick, so the rebuild that tick causes is
    // enough to see it; no listener of its own.
    final status = widget.animation.status;
    var content = _animated;
    if (status == AnimationStatus.completed) {
      // At rest the dialog is under no effect at all.
      content = const _RouteChildSlot();
    } else {
      final entering = status == AnimationStatus.forward;
      if (content == null || entering != _entering) {
        _entering = entering;
        content = _animated = FinesseAnimate(
          effects: entering ? widget.animateIn : widget.animateOut,
          // A glass dialog takes the fade over; see [BackdropFade].
          fadeThroughBackdrop: true,
          child: const _RouteChildSlot(),
        );
      }
    }
    return _RouteChild(routeChild: widget.child, child: content);
  }
}

/// Carries a route's content past widgets that must not be rebuilt for it.
class _RouteChild extends InheritedWidget {
  const _RouteChild({required this.routeChild, required super.child});

  final Widget routeChild;

  @override
  bool updateShouldNotify(_RouteChild oldWidget) =>
      routeChild != oldWidget.routeChild;
}

/// Where the content carried by the nearest [_RouteChild] is built.
class _RouteChildSlot extends StatelessWidget {
  const _RouteChildSlot();

  @override
  Widget build(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RouteChild>()!.routeChild;
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
  /// Defaults to the theme's, and then to `EntranceEffect.forMotion`: a fade
  /// with a little growth, on the theme's motion tokens.
  List<Effect<dynamic>>? animateIn,

  /// The animation effects when the dialog disappears.
  /// Defaults to the theme's, and then to a quicker fade and shrink on the
  /// theme's motion tokens.
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

  // The dialog scales up out of the middle of the screen while the route
  // ramps the barrier's tint and blur behind it, and leaves faster than it
  // came. With reduced motion both are a short fade; with none, nothing.
  final motion = Motion.of(context);
  final effectiveAnimateIn =
      animateIn ??
      effectiveDialogTheme.animateIn ??
      EntranceEffect.forMotion(motion);

  final exitScale = motion.reduced ? 1.0 : (1 + motion.overlayScale) / 2;
  final effectiveAnimateOut =
      animateOut ??
      effectiveDialogTheme.animateOut ??
      <Effect<dynamic>>[
        if (motion.normal > Duration.zero) ...[
          FadeEffect(
            begin: 1,
            end: 0,
            duration: motion.reduced ? motion.fast : motion.normal,
            curve: motion.exit,
          ),
          if (exitScale != 1)
            ScaleEffect(
              begin: const Offset(1, 1),
              end: Offset(exitScale, exitScale),
              duration: motion.normal,
              curve: motion.exit,
            ),
        ],
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

  final ambientTheme = Theme.of(context, listen: false);
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);

  return navigator.push(
    DialogRoute(
      // Themed like the place it was opened from, or following the app's
      // theme live; see [routeThemedBuilder].
      pageBuilder: routeThemedBuilder(
        opener: context,
        navigator: navigator,
        builder: builder,
      ),
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
        return _DialogTransition(
          animation: animation,
          animateIn: effectiveAnimateIn,
          animateOut: effectiveAnimateOut,
          child: child,
        );
      },
    ),
  );
}

/// Variants available for the [Dialog] widget.
enum DialogVariant {
  /// A standard dialog. Like an alert it has no close button unless it is
  /// given one (`closeIconData` or `closeIcon`): it is dismissed by a tap on
  /// the barrier, by Escape, or by one of its actions.
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
/// Pass `variant:` or use [Dialog.alert], the shortcut for the alert variant.
class Dialog extends StatelessWidget {
  /// Creates a dialog: the primary variant unless [variant] says otherwise.
  const Dialog({
    super.key,
    this.variant = DialogVariant.primary,
    this.title,
    this.description,
    this.child,
    this.actions = const [],
    this.closeIcon,
    this.closeIconData,
    this.onClose,
    this.semanticLabel,
    this.closeIconPosition,
    this.borderRadius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.constraints,
    this.border,
    this.shadows,
    this.filter,
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
    this.borderRadius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.constraints,
    this.border,
    this.shadows,
    this.filter,
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
  /// A custom widget for the close button, shown in the dialog's top end
  /// corner. Overrides [closeIconData].
  ///
  /// A dialog has no close button by default: give it an action that
  /// closes it — a Cancel or Close button — or pass [closeIconData] to get
  /// the ghost button with that icon.
  /// {@endtemplate}
  final Widget? closeIcon;

  /// {@template Dialog.closeIconData}
  /// The icon of the close button, such as [PhosphorIconsRegular.x].
  ///
  /// Null, the default, falls back to the theme's `closeIconData`, and when
  /// that is null too — as it is in the built-in themes — the dialog has no
  /// close button. Not used when [closeIcon] is given.
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

  /// {@template Dialog.borderRadius}
  /// The border radius of the dialog’s corners.
  /// Defaults to the theme’s radius if not specified.
  /// {@endtemplate}
  final BorderRadius? borderRadius;

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

  /// {@template Dialog.filter}
  /// A filter applied to what is behind the dialog, for a translucent
  /// [backgroundColor]: the blur of a glass surface. Null, the default,
  /// applies none.
  /// {@endtemplate}
  final ImageFilter? filter;

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
                icon: PhosphorIcon(
                  size: 16,
                  closeIconData ??
                      effectiveDialogTheme.closeIconData ??
                      PhosphorIconsRegular.x,
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
        borderRadius ?? effectiveDialogTheme.borderRadius ?? theme.radius;

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
              data: expandedActionsThemeOf(theme),
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

          final surfaceRadius = (!sm && effectiveRemoveBorderRadiusWhenTiny)
              ? null
              : effectiveRadius;
          // Through a `BackdropSurface` even without a filter, so the
          // route's entrance fade has one place to go either way.
          return BackdropSurface(
            filter: filter,
            tintOpacity: effectiveBackgroundColor.a,
            borderRadius: surfaceRadius ?? BorderRadius.zero,
            // A filter is clipped, which would cut the shadow off; it is
            // painted outside the clip instead.
            shadow: filter == null
                ? null
                : ShadowDecoration.box(
                    borderRadius: surfaceRadius,
                    shadows: effectiveShadows,
                  ),
            child: DecoratedBox(
              decoration: ShadowDecoration.box(
                color: effectiveBackgroundColor,
                borderRadius: surfaceRadius,
                border: effectiveBorder,
                shadows: filter == null ? effectiveShadows : const [],
              ),
              child: widget,
            ),
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
