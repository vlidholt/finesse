import 'dart:math' as math;

import 'package:finesse/src/components/divider.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/activation_keys.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/animation_builder.dart';
import 'package:finesse/src/utils/effects.dart';
import 'package:finesse/src/utils/expand_reveal.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// {@template AccordionController}
/// A controller for managing the state of a [Accordion] widget.
///
/// Supports both single `AccordionController` and multiple item expansion
/// modes `AccordionController.multiple`.
/// {@endtemplate}
class AccordionController<T> extends ValueNotifier<List<T>> {
  /// {@macro AccordionController}
  AccordionController([T? value])
    : _variant = AccordionVariant.single,
      super(List<T>.unmodifiable([?value]));

  /// Creates a controller for [Accordion.multiple], where any number of
  /// items can be open at once. [value] lists the items open at the start.
  AccordionController.multiple([List<T>? value])
    : _variant = AccordionVariant.multiple,
      super(List<T>.unmodifiable(value ?? <T>[]));

  @override
  set value(List<T> newValue) {
    super.value = List<T>.unmodifiable(newValue);
  }

  final AccordionVariant _variant;

  /// Toggles the expansion state of the item with the given value [v].
  ///
  /// In single mode, expands the item if it's not already expanded, or
  /// collapses it if it is. In multiple mode, adds or removes the item from the
  /// list of expanded items.
  void toggle(T v) {
    switch (_variant) {
      case AccordionVariant.single:
        if (value.contains(v)) {
          value = <T>[];
        } else {
          value = <T>[v];
        }
      case AccordionVariant.multiple:
        if (value.contains(v)) {
          value = value.toList()..remove(v);
        } else {
          value = value.toList()..add(v);
        }
    }
  }
}

/// Variants available for the [Accordion] widget.
enum AccordionVariant {
  /// Only one item can be open at a time. Opening an item closes the others.
  single,

  /// Any number of items can be open at once.
  multiple,
}

/// A customizable accordion widget that manages collapsible items.
///
/// The [Accordion] widget allows users to expand and collapse items,
/// supporting either single or multiple open items at a time. Use
/// [Accordion.multiple] for multiple open items or the default constructor
/// for single-item behavior. Items are defined using [AccordionItem].
class Accordion<T> extends StatefulWidget {
  /// Creates a single-type accordion where only one item can be expanded at a
  /// time.
  Accordion({
    super.key,
    required this.children,
    T? initialValue,
    this.maintainState,
    this.controller,
  }) : variant = AccordionVariant.single,
       initialValue = <T>[?initialValue],
       assert(
         controller == null || controller._variant == AccordionVariant.single,
         'Pass a single-mode AccordionController to Accordion(...)',
       );

  /// Creates a multiple-type accordion where multiple items can be expanded
  /// simultaneously.
  Accordion.multiple({
    super.key,
    required this.children,
    this.initialValue,
    this.maintainState,
    this.controller,
  }) : variant = AccordionVariant.multiple,
       assert(
         controller == null || controller._variant == AccordionVariant.multiple,
         'Pass a multiple-mode AccordionController to '
         'Accordion.multiple(...)',
       );

  /// {@template Accordion.variant}
  /// The type of accordion, either [AccordionVariant.single] or
  /// [AccordionVariant.multiple].
  /// Determines whether only one or multiple items can be expanded at once.
  /// {@endtemplate}
  final AccordionVariant variant;

  /// {@template Accordion.children}
  /// The list of [AccordionItem] widgets that make up the accordion's
  /// content. Each item can be expanded or collapsed independently based on
  /// [variant].
  /// {@endtemplate}
  final Iterable<Widget> children;

  /// {@template Accordion.initialValue}
  /// The initial list of values for items that should be expanded on creation.
  /// For single type, only the first value is used; for multiple, all values
  /// are used.
  /// {@endtemplate}
  final List<T>? initialValue;

  /// {@template Accordion.maintainState}
  /// Whether to maintain the state of closed items in the widget tree.
  /// If true, closed items remain built but hidden; if false, they are removed.
  /// {@endtemplate}
  final bool? maintainState;

  /// {@macro AccordionController}
  final AccordionController<T>? controller;

  @override
  State<Accordion<T>> createState() => AccordionState<T>();
}

/// The state of a [Accordion].
///
/// Its items find it in the widget tree to read the controller and
/// [maintainState].
class AccordionState<T> extends State<Accordion<T>> {
  AccordionController<T>? _controller;

  /// The controller in use: [Accordion.controller] when given, otherwise
  /// an internal one created from [Accordion.initialValue].
  AccordionController<T> get effectiveController {
    if (widget.controller != null) return widget.controller!;
    if (_controller != null) return _controller!;
    return switch (widget.variant) {
      AccordionVariant.single => _controller ??= AccordionController<T>(
        widget.initialValue != null && widget.initialValue!.isNotEmpty
            ? widget.initialValue!.first
            : null,
      ),
      AccordionVariant.multiple =>
        _controller ??= AccordionController<T>.multiple(
          widget.initialValue,
        ),
    };
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Accordion<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switched from internal to external controller: dispose internal.
    if (oldWidget.controller == null && widget.controller != null) {
      _controller?.dispose();
      _controller = null;
    }
    // Switched from external to internal or variant changed: recreate lazily.
    if ((oldWidget.controller != null && widget.controller == null) ||
        (oldWidget.variant != widget.variant && widget.controller == null)) {
      _controller?.dispose();
      _controller = null;
    }
  }

  /// Whether closed items stay in the tree.
  ///
  /// Resolves [Accordion.maintainState], then the theme, then false.
  bool get maintainState {
    return widget.maintainState ??
        Theme.of(context, listen: false).accordionTheme.maintainState ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      data: this as AccordionState<dynamic>,
      notifyUpdate: (_) => true,
      child: FocusTraversalGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: widget.children.toList(),
        ),
      ),
    );
  }
}

/// An individual item within a [Accordion], capable of being expanded or
/// collapsed.
///
/// Each item has a title and content, with customizable appearance and
/// animations.
class AccordionItem<T> extends StatefulWidget {
  /// Creates an accordion item with a specific value, title, and content.
  const AccordionItem({
    super.key,
    required this.value,
    required this.title,
    required this.child,
    this.separator,
    this.icon,
    this.iconEffects,
    this.padding,
    this.underlineTitleOnHover,
    this.titleStyle,
    this.curve,
    this.duration,
    this.focusNode,
    this.effects,
    this.trailing,
  });

  /// {@template AccordionItem.value}
  /// The unique value identifying this item within the accordion.
  /// Used to track its expansion state in the [AccordionState].
  /// {@endtemplate}
  final T value;

  /// {@template AccordionItem.title}
  /// The title widget of the item, typically a [Text] widget, displayed in the
  /// header.
  /// Styled by [titleStyle] or theme defaults.
  /// {@endtemplate}
  final Widget title;

  /// {@template AccordionItem.child}
  /// The content widget displayed when the item is expanded.
  /// Animated in and out based on [effects].
  /// {@endtemplate}
  final Widget child;

  /// {@template AccordionItem.separator}
  /// The widget displayed below the item as a separator, defaults to a
  /// Divider if null.
  /// {@endtemplate}
  final Widget? separator;

  /// {@template AccordionItem.icon}
  /// The item's icon, a caret pointing down by default.
  /// Displayed in the header and animated based on [iconEffects].
  /// {@endtemplate}
  final Widget? icon;

  /// {@template AccordionItem.iconEffects}
  /// The animation effects applied to the icon when the item expands or
  /// collapses.
  /// Defaults to a rotation effect if not specified.
  /// {@endtemplate}
  final List<Effect<dynamic>>? iconEffects;

  /// {@template AccordionItem.padding}
  /// Padding around the header content, defaults to vertical padding of 16 if
  /// not specified.
  /// Controls the spacing within the item's header.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template AccordionItem.underlineTitleOnHover}
  /// Whether to underline the title when hovered, defaults to true if not
  /// specified.
  /// Enhances visual feedback on mouse hover.
  /// {@endtemplate}
  final bool? underlineTitleOnHover;

  /// {@template AccordionItem.titleStyle}
  /// Style for the title text, overrides theme default if provided.
  /// Controls font size, weight, and other text properties of the [title].
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template AccordionItem.curve}
  /// The curve for animations. When null — and no [effects] are given — the
  /// item opens and closes on a spring, the theme's `Motion.smooth`, which
  /// keeps its velocity when interrupted. Giving a curve switches to a
  /// fixed-duration animation with that curve.
  /// {@endtemplate}
  final Curve? curve;

  /// {@template AccordionItem.duration}
  /// The duration of animations. With the default spring it replaces the
  /// spring's duration; with a [curve] or [effects] it is the animation's
  /// length, 300ms when null.
  /// {@endtemplate}
  final Duration? duration;

  /// {@template AccordionItem.focusNode}
  /// The focus node for keyboard navigation, created internally if not
  /// provided.
  /// Enables focus handling and shortcuts like Enter key toggling.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template AccordionItem.effects}
  /// The animation effects applied to the content when expanding or
  /// collapsing, in place of the default: the content's height growing
  /// while it fades in.
  /// {@endtemplate}
  final List<Effect<dynamic>>? effects;

  /// {@template AccordionItem.trailing}
  /// An action in the header, between the title and the chevron: a
  /// "Reset" link or a count badge. Taps on it do not toggle the item.
  /// {@endtemplate}
  final Widget? trailing;

  @override
  State<AccordionItem<T>> createState() => _AccordionItemState<T>();
}

class _AccordionItemState<T> extends State<AccordionItem<T>>
    with SingleTickerProviderStateMixin {
  final hovered = ValueNotifier(false);
  FocusNode? _focusNode;

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _focusNode = FocusNode();
    focusNode.addListener(onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AccordionItem<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Internal -> external: detach from internal, attach to external.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _focusNode?.removeListener(onFocusChange);
      _focusNode?.dispose();
      _focusNode = null;
      widget.focusNode!.addListener(onFocusChange);
    }
    // External -> internal: detach from external, create internal, attach.
    if (oldWidget.focusNode != null && widget.focusNode == null) {
      oldWidget.focusNode!.removeListener(onFocusChange);
      _focusNode?.dispose();
      _focusNode = FocusNode();
      focusNode.addListener(onFocusChange);
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChange);
    _focusNode?.dispose();
    hovered.dispose();
    super.dispose();
  }

  void onFocusChange() {
    hovered.value = focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    final inherited =
        context.watch<AccordionState<dynamic>>() as AccordionState<T>;

    return ValueListenableBuilder(
      valueListenable: inherited.effectiveController,
      builder: (context, value, child) {
        final expanded = value.contains(widget.value);
        final theme = Theme.of(context);
        final effectiveSeparator = widget.separator ?? const Divider();

        final motion = Motion.of(context);
        final customEffects = widget.effects ?? theme.accordionTheme.effects;
        final customCurve = widget.curve ?? theme.accordionTheme.curve;
        final customDuration = widget.duration ?? theme.accordionTheme.duration;
        // A spring unless the caller asked for a particular curve or set of
        // effects, which need a fixed duration to run over.
        final sprung = customEffects == null && customCurve == null;
        final spring = customDuration == null || motion.smooth.isInstant
            ? motion.smooth
            : motion.smooth.copyWith(duration: customDuration);

        final effectiveDuration = customDuration ?? 300.milliseconds;

        final effectiveCurve = customCurve ?? const Cubic(0.87, 0, 0.13, 1);

        final effectiveTitleStyle =
            (widget.titleStyle ??
                    theme.accordionTheme.titleStyle ??
                    theme.textTheme.list.copyWith(
                      fontWeight: FontWeight.w500,
                    ))
                .fallback(color: theme.colorScheme.foreground);

        final effectiveUnderlineTitleOnHover =
            widget.underlineTitleOnHover ??
            theme.accordionTheme.underlineTitleOnHover ??
            true;

        final customIconEffects =
            widget.iconEffects ?? theme.accordionTheme.iconEffects;
        final effectiveIconEffects =
            customIconEffects ??
            [
              RotateEffect(
                begin: 0,
                end: .5,
                duration: 300.milliseconds,
                curve: effectiveCurve,
              ),
            ];

        // The theme's icon is drawn as the default one is; an icon given
        // to the item itself is the caller's to size and colour.
        final effectiveIcon =
            widget.icon ??
            IconTheme.merge(
              data: IconThemeData(
                color: theme.colorScheme.foreground,
                size: 16,
              ),
              child:
                  theme.accordionTheme.icon ??
                  const PhosphorIcon(PhosphorIconsRegular.caretDown),
            );

        final effectivePadding =
            widget.padding ??
            theme.accordionTheme.padding ??
            const EdgeInsets.symmetric(vertical: 16);

        final effectiveEffects =
            customEffects ??
            [
              PaddingEffect(
                padding: const EdgeInsets.only(bottom: 8),
                curve: effectiveCurve,
                duration: effectiveDuration,
              ),
              SlideEffect(
                curve: effectiveCurve,
                begin: const Offset(0, -1),
                end: Offset.zero,
                duration: effectiveDuration,
              ),
              SizeEffect(
                curve: effectiveCurve,
                duration: effectiveDuration,
              ),
            ];

        final header = FinesseGestureDetector(
          mouseCursor: SystemMouseCursors.click,
          onHover: (value) => hovered.value = value,
          behavior: HitTestBehavior.opaque,
          onTap: () => inherited.effectiveController.toggle(widget.value),
          child: Padding(
            padding: effectivePadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CallbackShortcuts(
                    bindings: {
                      for (final trigger in activationKeys)
                        trigger: () {
                          inherited.effectiveController.toggle(
                            widget.value,
                          );
                        },
                    },
                    child: Focusable(
                      focusNode: focusNode,
                      builder: (context, focused, child) {
                        return ValueListenableBuilder(
                          valueListenable: hovered,
                          builder: (context, hovered, child) {
                            return DefaultTextStyle(
                              style: effectiveTitleStyle.copyWith(
                                decoration:
                                    hovered && effectiveUnderlineTitleOnHover
                                    ? TextDecoration.underline
                                    : null,
                              ),
                              child: child!,
                            );
                          },
                          child: widget.title,
                        );
                      },
                    ),
                  ),
                ),
                if (widget.trailing != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8,
                      end: 8,
                    ),
                    // Its own gesture arena entry, so a tap on the
                    // action does not also toggle the item.
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: widget.trailing,
                    ),
                  ),
                if (sprung && customIconEffects == null)
                  // The chevron turns on the same spring as the
                  // content opens.
                  SpringBuilder(
                    value: expanded ? 1 : 0,
                    spring: spring,
                    builder: (context, t, child) => Transform.rotate(
                      angle: t * math.pi,
                      child: child,
                    ),
                    child: effectiveIcon,
                  )
                else
                  FinesseAnimate(
                    target: expanded ? 1 : 0,
                    effects: effectiveIconEffects,
                    child: effectiveIcon,
                  ),
              ],
            ),
          ),
        );

        if (sprung) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              SpringBuilder(
                value: expanded ? 1 : 0,
                spring: spring,
                builder: (context, t, child) {
                  // Gone once fully closed, unless its state is to be kept.
                  if (t <= 0 && !expanded && !inherited.maintainState) {
                    return const SizedBox.shrink();
                  }
                  return ExpandReveal(
                    factor: t,
                    travel: motion.overlayTravel,
                    alignment: Alignment.topCenter,
                    child: child!,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: widget.child,
                ),
              ),
              effectiveSeparator,
            ],
          );
        }

        return AnimationBuilder(
          duration: effectiveDuration,
          builder: (context, controller) {
            if (expanded && !controller.isCompleted) {
              // animates the opened item, to show it
              controller.forward();
            } else if (!expanded && !controller.isDismissed) {
              // animates the closed item, to hide it
              controller.reverse();
            }

            final closed = !expanded && controller.isDismissed;
            final shouldRemoveChild = closed && !inherited.maintainState;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                if (!shouldRemoveChild)
                  FinesseAnimate(
                    controller: controller,
                    effects: effectiveEffects,
                    child: widget.child,
                  ),
                effectiveSeparator,
              ],
            );
          },
        );
      },
    );
  }
}
