import 'dart:async';

import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:finesse/src/utils/responsive.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A widget that manages and displays toasts within the widget tree.
///
/// The [Toaster] widget acts as a provider for toast notifications,
/// displaying them as overlays on top of its child widget. It uses an
/// [InheritedWidget] to allow descendants to access its state and show toasts
/// via [Toaster.of].
class Toaster extends StatefulWidget {
  /// Creates a toaster widget that wraps the provided child.
  const Toaster({
    super.key,
    required this.child,
  });

  /// The widget below the toaster in the tree, over which toasts are displayed.
  /// Typically the main app content.
  final Widget child;

  @override
  State<Toaster> createState() => ToasterState();

  /// Retrieves the [ToasterState] from the nearest [Toaster] ancestor.
  ///
  /// Throws a [FlutterError] if no [Toaster] is found in the widget tree.
  static ToasterState of(BuildContext context) {
    final provider = maybeOf(context);
    if (provider == null) {
      throw FlutterError(
        '''Could not find Toaster InheritedWidget in the ancestor widget tree.''',
      );
    }
    return provider;
  }

  /// Attempts to retrieve the [ToasterState] from the nearest [Toaster]
  /// ancestor.
  ///
  /// Returns null if no [Toaster] is found, allowing optional access.
  static ToasterState? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ToasterScope>();
    return scope?.messengerState;
  }
}

/// The state class for [Toaster], managing toast visibility and animations.
///
/// Controls the display, hiding, and timing of toasts using an animation
/// controller and timer, providing methods to show and hide toasts
/// programmatically.
class ToasterState extends State<Toaster> with TickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);
  final _visibleToast = ValueNotifier<Toast?>(null);
  final _shown = ValueNotifier(false);
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _shown.dispose();
    _visibleToast.dispose();
    super.dispose();
  }

  /// Shows [toast], replacing the one on screen, and hides it after its display
  /// duration.
  void show(Toast toast) {
    _timer?.cancel();
    _shown.value = true;
    _visibleToast.value = toast;
    _controller.forward(from: 0);
    _timer = Timer(toast.resolveDisplayDuration(context), hide);
  }

  /// Hides the toast on screen.
  ///
  /// When [animate] is true, the default, the future completes after the exit
  /// animation.
  Future<void> hide({bool animate = true}) async {
    _timer?.cancel();
    _shown.value = false;
    if (animate) await _controller.forward(from: 0);
    _visibleToast.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ToasterScope(
      messengerState: this,
      child: Stack(
        children: [
          widget.child,
          ValueListenableBuilder(
            valueListenable: _shown,
            builder: (context, visible, child) {
              return ValueListenableBuilder(
                valueListenable: _visibleToast,
                builder: (context, toast, child) {
                  final effectiveToastTheme = switch (toast?.variant) {
                    ToastVariant.primary || null => theme.primaryToastTheme,
                    ToastVariant.destructive => theme.destructiveToastTheme,
                  };
                  final effectiveAlignment =
                      toast?.alignment ??
                      effectiveToastTheme.alignment ??
                      Alignment.bottomRight;
                  final motion = Motion.of(context);
                  final defaultAnimateIn = Toast.enterEffects(
                    effectiveAlignment,
                    motion,
                  );
                  final defaultAnimateOut = Toast.exitEffects(
                    effectiveAlignment,
                    motion,
                  );

                  final effectiveAnimateIn =
                      toast?.animateIn ??
                      effectiveToastTheme.animateIn ??
                      defaultAnimateIn;
                  final effectiveAnimateOut =
                      toast?.animateOut ??
                      effectiveToastTheme.animateOut ??
                      defaultAnimateOut;

                  final defaultOffset = switch (effectiveAlignment) {
                    Alignment.topCenter ||
                    Alignment.topLeft ||
                    Alignment.topRight => Offset(
                      16,
                      MediaQuery.paddingOf(context).top + 16,
                    ),
                    Alignment.bottomCenter ||
                    Alignment.bottomLeft ||
                    Alignment.bottomRight => Offset(
                      16,
                      MediaQuery.paddingOf(context).bottom + 16,
                    ),
                    _ => const Offset(16, 16),
                  };

                  final effectiveOffset =
                      toast?.offset ??
                      effectiveToastTheme.offset ??
                      defaultOffset;

                  // Around the toast itself, not the full-screen box that
                  // aligns it: a slide or a scale is then relative to the
                  // toast, which is what makes a short travel possible.
                  return Align(
                    alignment: effectiveAlignment,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: effectiveOffset.dx,
                        vertical: effectiveOffset.dy,
                      ),
                      child: FinesseAnimate(
                        controller: _controller,
                        effects: visible
                            ? effectiveAnimateIn
                            : effectiveAnimateOut,
                        child: toast ?? const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// An inherited widget that provides access to the [ToasterState].
///
/// Allows descendants to access the toaster state via [Toaster.of] or
/// [Toaster.maybeOf] for showing and hiding toasts.
class ToasterScope extends InheritedWidget {
  /// Creates a scope widget that holds the [ToasterState] and child.
  const ToasterScope({
    super.key,
    required super.child,
    required this.messengerState,
  });

  /// The [ToasterState] instance managing toast display.
  final ToasterState messengerState;

  @override
  bool updateShouldNotify(ToasterScope oldWidget) =>
      messengerState != oldWidget.messengerState;
}

/// Variants available for the [Toast] widget.
enum ToastVariant {
  /// The default toast. Styled by `ThemeData.primaryToastTheme`.
  primary,

  /// A toast for errors. Styled by `ThemeData.destructiveToastTheme`.
  destructive,
}

/// A customizable toast notification widget.
///
/// The [Toast] widget displays a notification with a title, description,
/// optional action, and close button, styled according to its variant (primary
/// or destructive). It supports animations and integrates with [Theme] for
/// consistent appearance.
class Toast extends StatefulWidget {
  /// Creates a primary variant toast widget.
  const Toast({
    super.key,
    this.id,
    this.title,
    this.description,
    this.action,
    this.closeIcon,
    this.closeIconData,
    this.alignment,
    this.offset,
    this.displayDuration,
    this.textDirection,
    this.animateIn,
    this.animateOut,
    this.crossAxisAlignment,
    this.showCloseIconOnlyWhenHovered,
    this.titleStyle,
    this.descriptionStyle,
    this.actionPadding,
    this.border,
    this.radius,
    this.shadows,
    this.backgroundColor,
    this.padding,
    this.closeIconPosition,
    this.constraints,
    this.mainAxisAlignment,
    this.mainAxisSize,
  }) : variant = ToastVariant.primary;

  /// Creates a destructive variant toast widget, typically for error or warning
  /// messages.
  const Toast.destructive({
    super.key,
    this.id,
    this.title,
    this.description,
    this.action,
    this.closeIcon,
    this.closeIconData,
    this.alignment,
    this.offset,
    this.displayDuration,
    this.textDirection,
    this.animateIn,
    this.animateOut,
    this.crossAxisAlignment,
    this.showCloseIconOnlyWhenHovered,
    this.titleStyle,
    this.descriptionStyle,
    this.actionPadding,
    this.border,
    this.radius,
    this.shadows,
    this.backgroundColor,
    this.padding,
    this.closeIconPosition,
    this.constraints,
    this.mainAxisAlignment,
    this.mainAxisSize,
  }) : variant = ToastVariant.destructive;

  /// Creates a toast widget with a specified [variant], offering full
  /// customization.
  const Toast.raw({
    super.key,
    this.id,
    required this.variant,
    this.title,
    this.description,
    this.action,
    this.closeIcon,
    this.closeIconData,
    this.alignment,
    this.offset,
    this.displayDuration,
    this.textDirection,
    this.animateIn,
    this.animateOut,
    this.crossAxisAlignment,
    this.showCloseIconOnlyWhenHovered,
    this.titleStyle,
    this.descriptionStyle,
    this.actionPadding,
    this.border,
    this.radius,
    this.shadows,
    this.backgroundColor,
    this.padding,
    this.closeIconPosition,
    this.constraints,
    this.mainAxisAlignment,
    this.mainAxisSize,
  });

  /// {@template Toast.id}
  /// The unique identifier for the toast, used for tracking and managing
  /// toasts. Defaults to `UniqueKey()` if not specified.
  /// {@endtemplate}
  final Object? id;

  /// {@template Toast.title}
  /// The title widget displayed at the top of the toast.
  /// Typically a [Text] widget, styled with the theme’s muted bold style.
  /// {@endtemplate}
  final Widget? title;

  /// {@template Toast.description}
  /// The description widget displayed below the title.
  /// Typically a [Text] widget, styled with the theme’s muted style.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Toast.action}
  /// An optional action widget displayed alongside the content.
  /// Typically a button, padded according to [actionPadding].
  /// {@endtemplate}
  final Widget? action;

  /// {@template Toast.closeIcon}
  /// The custom widget for the close button.
  /// Overrides [closeIconData] if provided; defaults to a ghost button with an
  /// 'X' icon.
  /// {@endtemplate}
  final Widget? closeIcon;

  /// {@template Toast.closeIconData}
  /// The icon data for the close button.
  /// Used if [closeIcon] is null; defaults to [PhosphorIconsRegular.x] if not
  /// specified.
  /// {@endtemplate}
  final IconData? closeIconData;

  /// {@template Toast.alignment}
  /// The alignment of the toast within the screen.
  /// Defaults to [Alignment.bottomRight] if not specified.
  /// {@endtemplate}
  final Alignment? alignment;

  /// {@template Toast.offset}
  /// The offset from the [alignment] position as padding.
  /// Defaults to 16 pixels from edges or safe areas if not specified.
  /// {@endtemplate}
  final Offset? offset;

  /// {@template Toast.displayDuration}
  /// How long the toast stays visible before it hides itself. Defaults to
  /// the theme's value, then to [Toast.defaultDuration] (5 seconds).
  /// {@endtemplate}
  final Duration? displayDuration;

  /// {@template Toast.textDirection}
  /// The directionality of the toast’s content (e.g., LTR or RTL).
  /// Defaults to null, inheriting from the context.
  /// {@endtemplate}
  final TextDirection? textDirection;

  /// {@template Toast.animateIn}
  /// The animation effects when the toast appears.
  /// Defaults to alignment-specific slide or fade effects if not specified.
  /// {@endtemplate}
  final List<Effect<dynamic>>? animateIn;

  /// {@template Toast.animateOut}
  /// The animation effects when the toast disappears.
  /// Defaults to alignment-specific slide or fade effects if not specified.
  /// {@endtemplate}
  final List<Effect<dynamic>>? animateOut;

  /// {@template Toast.crossAxisAlignment}
  /// The cross-axis alignment of the toast’s content (vertical).
  /// Defaults to [CrossAxisAlignment.center] if not specified.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template Toast.mainAxisAlignment}
  /// The main-axis alignment of the toast’s content (horizontally).
  /// Defaults to [MainAxisAlignment.spaceBetween] if not specified.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template Toast.showCloseIconOnlyWhenHovered}
  /// Whether the close icon is visible only when the toast is hovered.
  /// Defaults to true if not specified.
  /// {@endtemplate}
  final bool? showCloseIconOnlyWhenHovered;

  /// {@template Toast.titleStyle}
  /// The text style for the title.
  /// Defaults to a bold muted style with variant-specific foreground color.
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template Toast.descriptionStyle}
  /// The text style for the description.
  /// Defaults to a muted style with variant-specific foreground color.
  /// {@endtemplate}
  final TextStyle? descriptionStyle;

  /// {@template Toast.actionPadding}
  /// The padding around the action widget.
  /// Defaults to start padding of 16 if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? actionPadding;

  /// {@template Toast.border}
  /// The border surrounding the toast.
  /// Defaults to a border with the theme’s border color if not specified.
  /// {@endtemplate}
  final FinesseBorder? border;

  /// {@template Toast.radius}
  /// The border radius of the toast’s corners.
  /// Defaults to the theme’s radius if not specified.
  /// {@endtemplate}
  final BorderRadius? radius;

  /// {@template Toast.shadows}
  /// The list of box shadows applied to the toast for elevation.
  /// Defaults to large shadows if not specified.
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Toast.backgroundColor}
  /// The background color of the toast.
  /// Defaults to the theme’s background color if not specified.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Toast.padding}
  /// The padding inside the toast, surrounding all content.
  ///
  /// Defaults to EdgeInsetsDirectional.fromSTEB(24, 24, 32, 24) if not
  /// specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Toast.closeIconPosition}
  /// The position of the close icon within the toast.
  /// Defaults to top-end (8, 8) if not specified.
  /// {@endtemplate}
  final Position? closeIconPosition;

  /// {@template Toast.variant}
  /// The variant of the toast, either [ToastVariant.primary] or
  /// [ToastVariant.destructive]. Determines the visual style applied
  /// through the [Theme].
  /// {@endtemplate}
  final ToastVariant variant;

  /// {@template Toast.constraints}
  /// Constraints applied to the toast’s layout.
  /// Responsive to screen size; defaults to unbounded min width and 420 max
  /// width on larger screens.
  /// {@endtemplate}
  final BoxConstraints? constraints;

  /// {@template Toast.mainAxisSize}
  /// The main axis size of the toast's content (horizontal).
  /// Defaults to [MainAxisSize.max] if not specified.
  /// {@endtemplate}
  final MainAxisSize? mainAxisSize;

  /// How long a toast stays on screen when neither it nor its theme sets a
  /// duration.
  static const defaultDuration = Duration(seconds: 5);

  /// Where a toast aligned to [alignment] comes from and leaves to, as a
  /// fraction of its own size: the edge of the screen it sits against.
  static Offset? _edgeOf(Alignment alignment) {
    if (alignment.y > 0) return const Offset(0, .5);
    if (alignment.y < 0) return const Offset(0, -.5);
    if (alignment.x > 0) return const Offset(.25, 0);
    if (alignment.x < 0) return const Offset(-.25, 0);
    return null;
  }

  /// The default entrance of a toast aligned to [alignment], built from the
  /// [motion] tokens: it fades in while it rises from the screen edge it
  /// sits against and grows the last few percent, on the `snappy` spring.
  /// With reduced motion it is a plain fade.
  ///
  /// Used when neither the toast nor its theme gives `animateIn`.
  static List<Effect<dynamic>> enterEffects(
    Alignment alignment,
    Motion motion,
  ) {
    if (motion.reduced) {
      return [FadeEffect(duration: motion.fast, curve: motion.standard)];
    }
    final spring = motion.snappy;
    final duration = spring.settleDuration;
    final edge = _edgeOf(alignment);
    return [
      FadeEffect(duration: motion.normal, curve: motion.standard),
      if (edge != null)
        SlideEffect(
          begin: edge,
          end: Offset.zero,
          duration: duration,
          curve: spring.curve,
        ),
      ScaleEffect(
        begin: Offset(motion.overlayScale, motion.overlayScale),
        end: const Offset(1, 1),
        duration: duration,
        curve: spring.curve,
      ),
    ];
  }

  /// The default exit of a toast aligned to [alignment], built from the
  /// [motion] tokens: the entrance backwards, but shorter and faster — a
  /// toast leaves quicker than it arrives. With reduced motion it is a plain
  /// fade.
  ///
  /// Used when neither the toast nor its theme gives `animateOut`.
  static List<Effect<dynamic>> exitEffects(
    Alignment alignment,
    Motion motion,
  ) {
    if (motion.reduced) {
      return [
        FadeEffect(
          begin: 1,
          end: 0,
          duration: motion.fast,
          curve: motion.standard,
        ),
      ];
    }
    final edge = _edgeOf(alignment);
    return [
      FadeEffect(
        begin: 1,
        end: 0,
        duration: motion.normal,
        curve: motion.exit,
      ),
      if (edge != null)
        SlideEffect(
          begin: Offset.zero,
          end: edge / 2,
          duration: motion.normal,
          curve: motion.exit,
        ),
      ScaleEffect(
        begin: const Offset(1, 1),
        end: Offset(motion.overlayScale, motion.overlayScale),
        duration: motion.normal,
        curve: motion.exit,
      ),
    ];
  }

  /// How long this toast stays on screen: [displayDuration], else its
  /// variant's theme, else [defaultDuration].
  Duration resolveDisplayDuration(BuildContext context) {
    final theme = Theme.of(context, listen: false);
    final variantTheme = switch (variant) {
      ToastVariant.primary => theme.primaryToastTheme,
      ToastVariant.destructive => theme.destructiveToastTheme,
    };
    return displayDuration ?? variantTheme.displayDuration ?? defaultDuration;
  }

  @override
  State<Toast> createState() => _ToastState();
}

class _ToastState extends State<Toast> {
  final hovered = ValueNotifier(false);

  @override
  void dispose() {
    hovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveToastTheme = switch (widget.variant) {
      ToastVariant.primary => theme.primaryToastTheme,
      ToastVariant.destructive => theme.destructiveToastTheme,
    };
    final effectiveForegroundColor = switch (widget.variant) {
      ToastVariant.primary => theme.colorScheme.foreground,
      ToastVariant.destructive => theme.colorScheme.destructiveForeground,
    };

    final effectiveCloseIcon =
        widget.closeIcon ??
        effectiveToastTheme.closeIcon ??
        IconButton.ghost(
          icon: Icon(
            size: 16,
            widget.closeIconData ??
                effectiveToastTheme.closeIconData ??
                PhosphorIconsRegular.x,
          ),
          width: 20,
          height: 20,
          padding: EdgeInsets.zero,
          foregroundColor: effectiveForegroundColor.withValues(alpha: .5),
          hoverBackgroundColor: const Color(0x00000000),
          hoverForegroundColor: effectiveForegroundColor,
          pressedForegroundColor: effectiveForegroundColor,
          onPressed: () => Toaster.of(context).hide(),
        );
    final effectiveTitleStyle =
        widget.titleStyle ??
        effectiveToastTheme.titleStyle ??
        theme.textTheme.muted.copyWith(
          fontWeight: FontWeight.w500,
          color: effectiveForegroundColor,
        );
    final effectiveDescriptionStyle =
        widget.descriptionStyle ??
        effectiveToastTheme.descriptionStyle ??
        theme.textTheme.muted.copyWith(
          color: effectiveForegroundColor.withValues(alpha: .9),
        );
    final effectiveActionPadding =
        widget.actionPadding ??
        effectiveToastTheme.actionPadding ??
        const EdgeInsetsDirectional.only(start: 16);
    final effectiveBorder =
        widget.border ??
        effectiveToastTheme.border ??
        FinesseBorder.all(color: theme.colorScheme.border, width: 1);
    final effectiveBorderRadius =
        widget.radius ?? effectiveToastTheme.radius ?? theme.radius;
    final effectiveShadows =
        widget.shadows ?? effectiveToastTheme.shadows ?? Shadows.lg;
    final effectiveBackgroundColor =
        widget.backgroundColor ??
        effectiveToastTheme.backgroundColor ??
        theme.colorScheme.background;
    final effectivePadding =
        widget.padding ??
        effectiveToastTheme.padding ??
        const EdgeInsetsDirectional.fromSTEB(24, 24, 32, 24);
    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        effectiveToastTheme.crossAxisAlignment ??
        CrossAxisAlignment.center;
    final effectiveMainAxisAlignment =
        widget.mainAxisAlignment ??
        effectiveToastTheme.mainAxisAlignment ??
        MainAxisAlignment.spaceBetween;
    final effectiveCloseIconPosition =
        widget.closeIconPosition ??
        effectiveToastTheme.closeIconPosition ??
        Position.directional(
          top: 8,
          end: 8,
          textDirection: Directionality.of(context),
        );
    final effectiveShowCloseIconOnlyWhenHovered =
        widget.showCloseIconOnlyWhenHovered ??
        effectiveToastTheme.showCloseIconOnlyWhenHovered ??
        true;
    final effectiveTextDirection =
        widget.textDirection ?? effectiveToastTheme.textDirection;
    final effectiveMainAxisSize =
        widget.mainAxisSize ??
        effectiveToastTheme.mainAxisSize ??
        MainAxisSize.max;

    return MouseRegion(
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: ResponsiveBuilder(
        builder: (context, breakpoint) {
          final effectiveConstraints =
              widget.constraints ??
              effectiveToastTheme.constraints ??
              BoxConstraints(
                minWidth: breakpoint >= theme.breakpoints.md
                    ? 0
                    : double.infinity,
                maxWidth: breakpoint >= theme.breakpoints.md
                    ? 420
                    : double.infinity,
              );
          return ConstrainedBox(
            constraints: effectiveConstraints,
            child: DecoratedBox(
              decoration: ShadowDecoration.box(
                border: effectiveBorder.toBorder(),
                borderRadius: effectiveBorderRadius,
                shadows: effectiveShadows,
                color: effectiveBackgroundColor,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: effectivePadding,
                    child: Row(
                      textDirection: effectiveTextDirection,
                      mainAxisAlignment: effectiveMainAxisAlignment,
                      mainAxisSize: effectiveMainAxisSize,
                      crossAxisAlignment: effectiveCrossAxisAlignment,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.title != null)
                                DefaultTextStyle(
                                  style: effectiveTitleStyle,
                                  child: widget.title!,
                                ),
                              if (widget.description != null)
                                DefaultTextStyle(
                                  style: effectiveDescriptionStyle,
                                  child: widget.description!,
                                ),
                            ],
                          ),
                        ),
                        if (widget.action != null)
                          Padding(
                            padding: effectiveActionPadding,
                            child: widget.action,
                          ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: hovered,
                    builder: (context, hovered, child) {
                      if (!effectiveShowCloseIconOnlyWhenHovered) {
                        return child!;
                      }
                      return Visibility.maintain(
                        visible: hovered,
                        child: child!,
                      );
                    },
                    child: effectiveCloseIcon,
                  ).positionedWith(effectiveCloseIconPosition),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
