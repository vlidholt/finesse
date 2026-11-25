import 'package:finesse/src/components/button_group.dart';
import 'package:finesse/src/components/spinner.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:finesse/src/utils/separated_iterable.dart';
import 'package:finesse/src/utils/text_scaled_height.dart';
import 'package:flutter/widgets.dart';

/// Variants available for the [Button] widget.
enum ButtonVariant {
  /// Filled with the primary colour. The default.
  primary,

  /// In the destructive colour, for actions such as delete.
  destructive,

  /// A button with a border.
  outline,

  /// Filled with the secondary colour.
  secondary,

  /// No fill and no border until hovered.
  ghost,

  /// Looks like a text link, underlined on hover.
  link,
}

/// Size options available for the [Button] widget.
///
/// Maps onto shadcn/ui's `size` prop: [regular] is `default`, plus `sm` and
/// `lg`. An `IconButton` takes the same three and reads them as the square
/// sizes, shadcn's `icon`, `icon-sm` and `icon-lg`.
///
/// The concrete metrics for each size come from `ButtonSizesTheme`.
enum ButtonSize {
  /// The default size, shadcn's `default`.
  regular,

  /// A smaller, denser button.
  sm,

  /// A larger button.
  lg,
}

/// A button: a label, with an optional widget before and after it, that
/// does something when pressed.
///
/// ```dart
/// Button(
///   onPressed: _save,
///   leading: const PhosphorIcon(PhosphorIconsRegular.floppyDisk),
///   child: const Text('Save'),
/// )
/// ```
///
/// It comes in six variants — primary, secondary, outline, ghost,
/// destructive and link — and three sizes. Pass [variant], or use the named
/// constructors ([Button.outline], [Button.ghost], …), which are shortcuts
/// for it. A button that holds only an icon is an `IconButton`.
///
/// How it looks comes from the variant's `ButtonTheme` in the theme. To
/// change one button, pass a [style]: a `ButtonTheme` that is merged over
/// the variant's, so it only says what is different.
///
/// ```dart
/// Button.outline(
///   style: ButtonTheme(
///     decoration: theme.buttonDecoration(radius: theme.radii.full),
///     padding: const EdgeInsets.symmetric(horizontal: 20),
///   ),
///   onPressed: _follow,
///   child: const Text('Follow'),
/// )
/// ```
///
/// A press scales the button a little and, with a mouse, hovering changes
/// its colours; both, the focus ring and activation from the keyboard come
/// from `Pressable`, as for every other control. For a gesture a button has
/// no callback for — a double tap, a secondary tap, the moment a press
/// starts — wrap it in a `FinesseGestureDetector`.
class Button extends StatefulWidget {
  /// Creates a button: the primary variant unless [variant] says otherwise.
  const Button({
    super.key,
    this.variant = ButtonVariant.primary,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.expands,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  });

  /// Creates a destructive variant button widget, typically for warning or
  /// error actions.
  const Button.destructive({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.expands,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  }) : variant = ButtonVariant.destructive;

  /// Creates an outline variant button widget, typically with a bordered
  /// appearance.
  const Button.outline({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.expands,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  }) : variant = ButtonVariant.outline;

  /// Creates a secondary variant button widget, typically for less prominent
  /// actions.
  const Button.secondary({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.expands,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  }) : variant = ButtonVariant.secondary;

  /// Creates a ghost variant button widget, typically with minimal styling.
  const Button.ghost({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.expands,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  }) : variant = ButtonVariant.ghost;

  /// Creates a link variant button widget, styled like a hyperlink.
  const Button.link({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.expands,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  }) : variant = ButtonVariant.link;

  /// {@template Button.onPressed}
  /// Called when the button is tapped, or activated from the keyboard with
  /// Enter or Space while it has the focus.
  ///
  /// A button with no callback keeps its look and does nothing; [enabled]
  /// is what dims it.
  /// {@endtemplate}
  final VoidCallback? onPressed;

  /// {@template Button.onLongPress}
  /// Called when the button is held.
  /// {@endtemplate}
  final VoidCallback? onLongPress;

  /// {@template Button.leading}
  /// The widget before the [child], usually an icon. It takes the button's
  /// icon size and foreground colour.
  /// {@endtemplate}
  final Widget? leading;

  /// {@template Button.child}
  /// The label, usually a [Text]. It takes the button's text style and
  /// foreground colour, and is centred.
  /// {@endtemplate}
  final Widget? child;

  /// {@template Button.trailing}
  /// The widget after the [child], usually an icon. It takes the button's
  /// icon size and foreground colour.
  /// {@endtemplate}
  final Widget? trailing;

  /// {@template Button.variant}
  /// Which of the theme's button looks this is. The named constructors set
  /// it.
  /// {@endtemplate}
  final ButtonVariant variant;

  /// {@template Button.size}
  /// The size: its height, padding and icon size come from the theme's
  /// `ButtonSizesTheme`. Defaults to the variant theme's, which is
  /// [ButtonSize.regular] unless a theme says otherwise.
  /// {@endtemplate}
  final ButtonSize? size;

  /// {@template Button.mouseCursor}
  /// The cursor over the enabled button. Defaults to the variant theme's,
  /// which is [SystemMouseCursors.click] unless a theme says otherwise.
  /// {@endtemplate}
  final MouseCursor? mouseCursor;

  /// {@template Button.autofocus}
  /// Whether the button takes the focus when it is first built, if nothing
  /// else has it.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template Button.focusNode}
  /// The focus node to use; one is created when null.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Button.enabled}
  /// Whether the button responds. A disabled button is dimmed, takes no
  /// focus and ignores presses.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Button.loading}
  /// Whether the button's action is in progress.
  ///
  /// A loading button shows a spinner in the place of its [leading] widget
  /// or, when it has none, over its label, which keeps its room: the button
  /// is exactly as wide as it was. It ignores presses, by pointer and by
  /// keyboard, without dimming or giving up the focus, and assistive
  /// technology is told that it is busy.
  ///
  /// ```dart
  /// Button(
  ///   loading: _saving,
  ///   onPressed: _save,
  ///   child: const Text('Save'),
  /// )
  /// ```
  /// {@endtemplate}
  final bool loading;

  /// {@template Button.statesController}
  /// Holds the button's interaction states ([WidgetState.hovered],
  /// [WidgetState.pressed], [WidgetState.focused] and
  /// [WidgetState.disabled]) for whoever else wants to follow them.
  ///
  /// This is Flutter's own [WidgetStatesController], which changes its
  /// [WidgetStatesController.value] set in place before notifying: a listener
  /// that needs to know which state flipped has to keep its own copy of the
  /// states it last saw.
  /// {@endtemplate}
  final WidgetStatesController? statesController;

  /// {@template Button.onHover}
  /// Called when a mouse pointer enters or leaves the enabled button.
  /// {@endtemplate}
  final ValueChanged<bool>? onHover;

  /// {@template Button.onFocusChange}
  /// Called when the button gains or loses the focus.
  /// {@endtemplate}
  final ValueChanged<bool>? onFocusChange;

  /// {@template Button.expands}
  /// Whether the [child] takes all the room the button has, pushing
  /// [leading] and [trailing] to its ends. Defaults to the variant theme's,
  /// which is false.
  /// {@endtemplate}
  final bool? expands;

  /// {@template Button.semanticLabel}
  /// What assistive technology reads for the button, in place of its
  /// content. A button with a text label does not need one.
  /// {@endtemplate}
  final String? semanticLabel;

  /// {@template Button.style}
  /// Overrides of the variant's look for this one button: colours, padding,
  /// decoration, sizes, text style, press response.
  ///
  /// It is merged over the variant's `ButtonTheme` from the theme, so only
  /// the fields that are set change anything, and a
  /// `ButtonTheme.decoration` is merged into the variant's rather than
  /// replacing it. Build it from the theme, outside `build` where it does
  /// not depend on anything that changes.
  /// {@endtemplate}
  final ButtonTheme? style;

  /// The theme a button of [variant] starts from under [context]: the one
  /// its [style] is merged over.
  static ButtonTheme themeOf(BuildContext context, ButtonVariant variant) {
    return _variantTheme(Theme.of(context), variant);
  }

  static ButtonTheme _variantTheme(ThemeData theme, ButtonVariant variant) {
    return switch (variant) {
      ButtonVariant.primary => theme.primaryButtonTheme,
      ButtonVariant.destructive => theme.destructiveButtonTheme,
      ButtonVariant.secondary => theme.secondaryButtonTheme,
      ButtonVariant.ghost => theme.ghostButtonTheme,
      ButtonVariant.outline => theme.outlineButtonTheme,
      ButtonVariant.link => theme.linkButtonTheme,
    };
  }

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  /// Whether the button has been built in its loading state. From then on
  /// the label keeps the wrapper the spinner is swapped in under, so it is
  /// not re-parented — and its state lost — each time loading ends.
  bool _hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final iconTheme = IconTheme.of(context);
    final style = Button._variantTheme(
      theme,
      widget.variant,
    ).merge(widget.style);

    final sizes = style.sizesTheme;
    final sizeTheme = switch (widget.size ?? style.size ?? ButtonSize.regular) {
      ButtonSize.regular => sizes?.regular ?? theme.buttonSizesTheme.regular!,
      ButtonSize.sm => sizes?.sm ?? theme.buttonSizesTheme.sm!,
      ButtonSize.lg => sizes?.lg ?? theme.buttonSizesTheme.lg!,
    };

    var decoration = style.decoration ?? const FinesseDecoration();
    // In a `ButtonGroup` the corners and the edge towards a neighbour are
    // the group's to decide.
    final group = ButtonGroupScope.maybeOf(context);
    if (group != null) {
      decoration = group.join(
        decoration,
        Directionality.of(context),
        fallback: theme.decoration,
      );
    }
    decoration = decoration.copyWith(
      gradient: style.gradient,
      shadows: style.shadows,
    );

    final foreground = style.foregroundColor ?? theme.colorScheme.foreground;
    final hoverForeground = style.hoverForegroundColor ?? foreground;
    final textStyle = style.textStyle ?? theme.textTheme.small;
    final gap = style.gap ?? 8;
    final expands = widget.expands ?? style.expands ?? false;

    final width = style.width ?? sizeTheme.width ?? 0;
    final height = style.height ?? sizeTheme.height;
    // The style height is the height at the platform's text size: a larger
    // text scale lets the button grow to keep its label whole, and at a
    // scale of 1 this is the height itself.
    final maxHeight = textScaledMaxHeight(context, height);
    // Null keeps whatever the ambient IconTheme says, rather than falling
    // back to Flutter's 24 — but every shipped style sets one.
    final iconSize = style.iconSize ?? sizeTheme.iconSize ?? iconTheme.size;
    final padding = style.padding ?? sizeTheme.padding;

    final motion = Motion.of(context);
    final transitionDuration = style.transitionDuration ?? motion.fast;
    // shadcn/ui nudges a button down a pixel while active
    // (`active:translate-y-px`), animated by its `transition-all`.
    final pressedOffset = style.pressedOffset ?? const Offset(0, 1);
    final pressDuration =
        style.pressAnimationDuration ?? const Duration(milliseconds: 100);

    final loading = widget.loading;

    return Pressable(
      // Busy: there, and in the focus order, but not to be pressed.
      onPressed: loading ? null : widget.onPressed,
      onLongPress: loading ? null : widget.onLongPress,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      statesController: widget.statesController,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      mouseCursor: loading
          ? MouseCursor.defer
          : widget.mouseCursor ?? style.mouseCursor ?? SystemMouseCursors.click,
      semanticLabel: widget.semanticLabel,
      // One node: the role, the label, whether it can be pressed and the
      // tap. Without it they are merged into whatever container is above,
      // with the text beside the button.
      semanticContainer: true,
      semanticValue: loading
          ? FinesseLocalizations.of(context).button.loading
          : null,
      // The press is acknowledged by a scale, a paint-time transform: the
      // button's box, and so its height, never changes.
      pressScale: style.pressScale,
      builder: (context, states) {
        final enabled = !states.contains(WidgetState.disabled);
        final pressed =
            enabled && !loading && states.contains(WidgetState.pressed);
        // A finger has no hover: while it is down the button looks as it
        // does under a pointer, which is also what a held mouse button
        // shows.
        final hovered =
            pressed ||
            (enabled && !loading && states.contains(WidgetState.hovered));

        final background = pressed && style.pressedBackgroundColor != null
            ? style.pressedBackgroundColor
            : hovered
            ? style.hoverBackgroundColor
            : style.backgroundColor;
        final content = pressed && style.pressedForegroundColor != null
            ? style.pressedForegroundColor!
            : hovered
            ? hoverForeground
            : foreground;

        var child = widget.child;

        // A child that is already Flexible (or Expanded) brings its own
        // flex. Wrapping it in Expanded would put it under the Expanded
        // instead of directly under the Row, which Flutter rejects as an
        // incorrect use of ParentDataWidget.
        if (child != null && expands && child is! Flexible) {
          child = Expanded(child: child);
        }

        // The spinner takes the place of the leading widget, or lies over
        // the label when there is none. What it replaces stays in the
        // layout, unseen, so the button does not change size.
        var leading = widget.leading;
        if (loading) _hasLoaded = true;
        if (_hasLoaded) {
          final spinnerSize = iconSize ?? 16;
          if (leading != null) {
            leading = _LoadingSwap(
              loading: loading,
              spinnerSize: spinnerSize,
              child: leading,
            );
          } else if (widget.child != null) {
            final swapped = _LoadingSwap(
              loading: loading,
              spinnerSize: spinnerSize,
              child: widget.child!,
            );
            child = child is Expanded ? Expanded(child: swapped) : swapped;
          }
        }

        // Requires a real handler as well as the enabled state: a button
        // with no onPressed does nothing, so it should not appear to
        // depress.
        final depressed = pressed && widget.onPressed != null;

        return AnimatedSlide(
          // AnimatedSlide takes a fraction of the child's size, so convert
          // the pixel offset once the height is known.
          offset: depressed
              ? Offset(pressedOffset.dx / 100, pressedOffset.dy / height)
              : Offset.zero,
          duration: pressDuration,
          curve: Curves.easeOut,
          // Hover and press change the colours over a short fade rather
          // than at once. Each fade starts from the colour on screen, so
          // leaving mid-fade turns around without a flash.
          child: AnimatedColorBuilder(
            color: content,
            duration: transitionDuration,
            curve: motion.standard,
            builder: (context, color, child) => IconTheme(
              data: iconTheme.copyWith(color: color, size: iconSize),
              child: DefaultTextStyle(
                style: textStyle.copyWith(
                  color: color,
                  decoration: hovered
                      ? style.hoverTextDecoration
                      : style.textDecoration,
                  decorationColor: foreground,
                  decorationStyle: TextDecorationStyle.solid,
                ),
                textAlign: TextAlign.center,
                child: child!,
              ),
            ),
            child: Opacity(
              opacity: enabled ? 1 : .5,
              child: AbsorbPointer(
                absorbing: !enabled,
                // The size constraints sit *outside* the decorator so the
                // border — and the focus reserve of the
                // no-secondary-border variant — is counted into the
                // button's height, the way CSS `h-9` is border-box.
                // Constraining inside made an outline button 2px taller
                // than a primary one.
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: width,
                    // A width of 0 leaves the button as wide as its
                    // content.
                    maxWidth: width == 0 ? double.infinity : width,
                    minHeight: height,
                    // And a height of 0 as tall.
                    maxHeight: height == 0 ? double.infinity : maxHeight,
                  ),
                  child: AnimatedColorBuilder(
                    color: background ?? decoration.color,
                    duration: transitionDuration,
                    curve: motion.standard,
                    builder: (context, color, child) => Decorator(
                      decoration: color == null
                          ? decoration
                          : decoration.copyWith(color: color),
                      focused: states.contains(WidgetState.focused),
                      child: child,
                    ),
                    child: SelectionContainer.disabled(
                      child: Padding(
                        padding: padding,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              style.crossAxisAlignment ??
                              CrossAxisAlignment.center,
                          mainAxisAlignment:
                              style.mainAxisAlignment ??
                              MainAxisAlignment.center,
                          children: [
                            ?leading,
                            ?child,
                            ?widget.trailing,
                          ].separatedBy(SizedBox(width: gap)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows a spinner in the place of [child] while [loading]: the child stays
/// in the layout, unseen, so nothing around it moves.
class _LoadingSwap extends StatefulWidget {
  const _LoadingSwap({
    required this.loading,
    required this.spinnerSize,
    required this.child,
  });

  final bool loading;
  final double spinnerSize;
  final Widget child;

  @override
  State<_LoadingSwap> createState() => _LoadingSwapState();
}

class _LoadingSwapState extends State<_LoadingSwap> {
  /// What is shown. It follows the widget, except that a swap created
  /// already loading — the button's first time — starts out not loading
  /// and turns in its first frame, so that time is animated like the rest.
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _loading = widget.loading);
      });
    }
  }

  @override
  void didUpdateWidget(_LoadingSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loading = widget.loading;
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    return Stack(
      alignment: Alignment.center,
      // A spinner larger than a one-letter label still shows whole.
      clipBehavior: Clip.none,
      children: [
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: motion.fast,
          curve: motion.standard,
          // Unseen, it is still the button's name.
          alwaysIncludeSemantics: true,
          child: widget.child,
        ),
        // Out of the tree when it is not showing: a spinner never rests.
        // It is not read: the button says that it is busy.
        Positioned.fill(
          child: Center(
            child: PopIn(
              visible: _loading,
              child: ExcludeSemantics(
                child: Spinner(size: widget.spinnerSize),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
