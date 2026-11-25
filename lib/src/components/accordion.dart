import 'dart:math' as math;

import 'package:finesse/src/components/divider.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/activation_keys.dart';
import 'package:finesse/src/utils/expand_reveal.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';

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
       initialValues = <T>[?initialValue],
       assert(
         controller == null || controller._variant == AccordionVariant.single,
         'Pass a single-mode AccordionController to Accordion(...)',
       );

  /// Creates a multiple-type accordion where multiple items can be expanded
  /// simultaneously.
  Accordion.multiple({
    super.key,
    required this.children,
    this.initialValues,
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

  /// {@template Accordion.initialValues}
  /// The values of the items expanded at first: the `initialValue` of an
  /// [Accordion], or every value of an [Accordion.multiple].
  /// {@endtemplate}
  final List<T>? initialValues;

  /// {@template Accordion.maintainState}
  /// Whether to maintain the state of closed items in the widget tree.
  /// If true, closed items remain built but hidden; if false, they are removed.
  /// {@endtemplate}
  final bool? maintainState;

  /// {@macro AccordionController}
  final AccordionController<T>? controller;

  @override
  State<Accordion<T>> createState() => _AccordionState<T>();
}

/// The state of a [Accordion].
///
/// Its items find it in the widget tree to read the controller and
/// [maintainState].
class _AccordionState<T> extends State<Accordion<T>> {
  AccordionController<T>? _controller;

  /// The controller in use: [Accordion.controller] when given, otherwise
  /// an internal one created from [Accordion.initialValues].
  AccordionController<T> get effectiveController {
    if (widget.controller != null) return widget.controller!;
    if (_controller != null) return _controller!;
    return switch (widget.variant) {
      AccordionVariant.single => _controller ??= AccordionController<T>(
        widget.initialValues != null && widget.initialValues!.isNotEmpty
            ? widget.initialValues!.first
            : null,
      ),
      AccordionVariant.multiple =>
        _controller ??= AccordionController<T>.multiple(
          widget.initialValues,
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
      data: this as _AccordionState<dynamic>,
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
    this.padding,
    this.underlineTitleOnHover,
    this.titleStyle,
    this.focusNode,
    this.trailing,
  });

  /// {@template AccordionItem.value}
  /// The unique value identifying this item within the accordion.
  /// Used to track its expansion state in the [_AccordionState].
  /// {@endtemplate}
  final T value;

  /// {@template AccordionItem.title}
  /// The title widget of the item, typically a [Text] widget, displayed in the
  /// header.
  /// Styled by [titleStyle] or theme defaults.
  /// {@endtemplate}
  final Widget title;

  /// {@template AccordionItem.child}
  /// The content widget displayed when the item is expanded. It opens and
  /// closes on the theme's `Motion.smooth` spring, which keeps its velocity
  /// when interrupted.
  /// {@endtemplate}
  final Widget child;

  /// {@template AccordionItem.separator}
  /// The widget displayed below the item as a separator, defaults to a
  /// Divider if null.
  /// {@endtemplate}
  final Widget? separator;

  /// {@template AccordionItem.icon}
  /// The item's icon, a caret pointing down by default. It is shown in the
  /// header and turns half a turn as the item opens.
  /// {@endtemplate}
  final Widget? icon;

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

  /// {@template AccordionItem.focusNode}
  /// The focus node for keyboard navigation, created internally if not
  /// provided.
  /// Enables focus handling and shortcuts like Enter key toggling.
  /// {@endtemplate}
  final FocusNode? focusNode;

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
        context.watch<_AccordionState<dynamic>>() as _AccordionState<T>;

    return ValueListenableBuilder(
      valueListenable: inherited.effectiveController,
      builder: (context, value, child) {
        final expanded = value.contains(widget.value);
        final theme = Theme.of(context);
        final effectiveSeparator = widget.separator ?? const Divider();

        // The content opens and the chevron turns on one spring.
        final motion = Motion.of(context);
        final spring = motion.smooth;

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

        // A button that says whether its content is open, as a disclosure
        // is announced on the web.
        final header = Semantics(
          button: true,
          expanded: expanded,
          child: FinesseGestureDetector(
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
                  // The chevron turns on the same spring as the content
                  // opens.
                  SpringBuilder(
                    value: expanded ? 1 : 0,
                    spring: spring,
                    builder: (context, t, child) => Transform.rotate(
                      angle: t * math.pi,
                      child: child,
                    ),
                    child: effectiveIcon,
                  ),
                ],
              ),
            ),
          ),
        );

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
              // Kept while closed, it is still not there to be used: not a
              // Tab stop, not a target and not read out.
              child: ExcludeFocus(
                excluding: !expanded,
                child: IgnorePointer(
                  ignoring: !expanded,
                  child: ExcludeSemantics(
                    excluding: !expanded,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
            effectiveSeparator,
          ],
        );
      },
    );
  }
}
