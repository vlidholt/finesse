import 'package:finesse/src/components/bar_button_scope.dart';
import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/button_group.dart';
import 'package:finesse/src/components/tooltip.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:flutter/widgets.dart';

/// A button that holds only an icon.
///
/// ```dart
/// IconButton.ghost(
///   icon: const PhosphorIcon(PhosphorIconsRegular.archive),
///   tooltip: 'Archive',
///   onPressed: _archive,
/// )
/// ```
///
/// It is a [Button] in the square sizes — shadcn/ui's
/// `<Button size="icon">`, `icon-sm` and `icon-lg` — with the name an
/// icon-only control needs: give it a [tooltip], which also names it for
/// assistive technology, or a [semanticLabel].
///
/// It takes the same variants as a button, except the link (pass `variant:`
/// or use named constructors like [IconButton.ghost]), the same three
/// sizes, and the same [style] object for anything else.
class IconButton extends StatefulWidget {
  /// Creates an icon button: the primary variant unless [variant] says
  /// otherwise or, in an `AppBar` or `SliverAppBar`, the variant the bar
  /// gives the buttons in it.
  const IconButton({
    super.key,
    this.variant,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.tooltip,
    this.style,
  }) : assert(
         variant != ButtonVariant.link,
         "IconButton doesn't support the link variant",
       );

  /// Creates a destructive variant icon button, typically for warning or
  /// error actions.
  const IconButton.destructive({
    super.key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.tooltip,
    this.style,
  }) : variant = ButtonVariant.destructive;

  /// Creates an outline variant icon button, typically with a bordered
  /// appearance.
  const IconButton.outline({
    super.key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.tooltip,
    this.style,
  }) : variant = ButtonVariant.outline;

  /// Creates a secondary variant icon button, typically for less prominent
  /// actions.
  const IconButton.secondary({
    super.key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.tooltip,
    this.style,
  }) : variant = ButtonVariant.secondary;

  /// Creates a ghost variant icon button, typically with minimal styling.
  const IconButton.ghost({
    super.key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.enabled = true,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.tooltip,
    this.style,
  }) : variant = ButtonVariant.ghost;

  /// {@macro Button.variant}
  final ButtonVariant? variant;

  /// {@macro Button.onPressed}
  final VoidCallback? onPressed;

  /// {@macro Button.onLongPress}
  final VoidCallback? onLongPress;

  /// The icon. It takes the button's icon size and foreground colour.
  final Widget icon;

  /// The size: [ButtonSize.regular], the default, [ButtonSize.sm] or
  /// [ButtonSize.lg]. They are read as the theme's square sizes
  /// (`ButtonSizesTheme.icon`, `iconSm`, `iconLg`), which size the glyph
  /// independently of a text button's at the same step.
  final ButtonSize? size;

  /// What assistive technology reads for the button. An icon alone says
  /// nothing, so give this or a [tooltip].
  final String? semanticLabel;

  /// What the button does, in a word or two: "Archive", "More options".
  ///
  /// Shown in a `Tooltip` when the button is hovered, focused or, on a
  /// touch screen, held, and used as the [semanticLabel] when that is not
  /// given — so an icon button with a tooltip is named for everyone.
  final String? tooltip;

  /// {@macro Button.loading}
  ///
  /// On an icon button the spinner takes the place of the icon.
  final bool loading;

  /// {@macro Button.mouseCursor}
  final MouseCursor? mouseCursor;

  /// {@macro Button.autofocus}
  final bool autofocus;

  /// {@macro Button.focusNode}
  final FocusNode? focusNode;

  /// {@macro Button.enabled}
  final bool enabled;

  /// {@macro Button.statesController}
  final WidgetStatesController? statesController;

  /// {@macro Button.onHover}
  final ValueChanged<bool>? onHover;

  /// {@macro Button.onFocusChange}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro Button.style}
  ///
  /// On an icon button `ButtonTheme.width`, `height`, `padding` and
  /// `iconSize` replace the square size's.
  final ButtonTheme? style;

  @override
  State<IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
  /// The node the button and its tooltip share when the caller gives
  /// none: the tooltip shows on keyboard focus by listening to it.
  FocusNode? _ownFocusNode;

  FocusNode? get _focusNode {
    if (widget.focusNode != null) return widget.focusNode;
    // Kept once made, so a tooltip coming or going does not move the
    // focus to another node.
    if (widget.tooltip == null && _ownFocusNode == null) return null;
    return _ownFocusNode ??= FocusNode(debugLabel: 'IconButton');
  }

  @override
  void didUpdateWidget(IconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != null && _ownFocusNode != null) {
      // The caller's node takes over. Disposed after the frame, once the
      // Focus below has let go of it.
      final node = _ownFocusNode!;
      _ownFocusNode = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => node.dispose());
    }
  }

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));

    final theme = Theme.of(context);
    final widget = this.widget;
    final style = BarButtonScope.styleOf(context, widget.style);
    final variant = BarButtonScope.variantOf(context, widget.variant);
    final tooltip = widget.tooltip;
    final focusNode = _focusNode;

    final merged = Button.themeOf(context, variant).merge(style);
    final sizes = merged.sizesTheme;
    // The square sizes, not the text-button ones: shadcn sizes an icon
    // button's glyph independently of a text button's at the same step
    // (`.cn-button-size-icon-sm` keeps 16 where `.cn-button-size-sm` drops
    // to 14). Which step, as for a text button, falls back to the variant
    // theme's.
    final metrics = switch (widget.size ?? merged.size ?? ButtonSize.regular) {
      ButtonSize.regular => sizes?.icon ?? theme.buttonSizesTheme.icon!,
      ButtonSize.sm =>
        sizes?.iconSm ??
            theme.buttonSizesTheme.iconSm ??
            sizes?.sm ??
            theme.buttonSizesTheme.sm!,
      ButtonSize.lg =>
        sizes?.iconLg ??
            theme.buttonSizesTheme.iconLg ??
            sizes?.lg ??
            theme.buttonSizesTheme.lg!,
    };

    final height = style?.height ?? metrics.height;

    // The style can round icon buttons differently from text buttons — a
    // circle beside a 10-point rectangle. The focus ring has to follow the
    // new radius or it stays a rounded square around a round button.
    var decoration = style?.decoration;
    final radiusToken = theme.style.iconButtonRadius;
    // Not in a group: joined to its neighbours an icon button is one
    // segment of a bar, and takes the bar's corners.
    if (radiusToken != null &&
        decoration == null &&
        !ButtonGroupScope.isWithin(context)) {
      decoration = theme.buttonDecoration(
        radius: theme.radii.resolve(radiusToken),
      );
    }

    final label = widget.semanticLabel ?? tooltip;
    final Widget button = Button(
      variant: variant,
      style: (style ?? const ButtonTheme()).copyWith(
        // A size with no width of its own stays square.
        width: style?.width ?? metrics.width ?? height,
        height: height,
        padding: style?.padding ?? metrics.padding,
        iconSize: style?.iconSize ?? metrics.iconSize,
        decoration: decoration,
      ),
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
      mouseCursor: widget.mouseCursor,
      autofocus: widget.autofocus,
      focusNode: focusNode,
      enabled: widget.enabled,
      loading: widget.loading,
      statesController: widget.statesController,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      // An icon-only button carries no text, so without a label a screen
      // reader announces nothing at all. It stands in for the icon: both
      // would be read otherwise.
      semanticLabel: label,
      child: widget.icon,
    );

    if (tooltip == null) return button;
    return Tooltip(
      focusNode: focusNode,
      builder: (context) => Text(tooltip),
      child: button,
    );
  }
}
