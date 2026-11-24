import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/widgets.dart';

/// {@template Breadcrumb}
/// A breadcrumb navigation component that displays the current page location
/// within a navigational hierarchy.
///
/// Breadcrumbs provide users with a clear understanding of their current
/// location and allow them to navigate back to parent pages in the hierarchy.
/// {@endtemplate}
class Breadcrumb extends StatelessWidget {
  /// {@macro Breadcrumb}
  const Breadcrumb({
    super.key,
    required this.children,
    this.separator,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.textDirection,
    this.verticalDirection,
    this.spacing,
    this.textStyle,
    this.lastItemTextColor,
  });

  /// The list of breadcrumb items to display.
  final List<Widget> children;

  /// Custom separator widget between breadcrumb items.
  /// If null, uses the default chevron right icon.
  final Widget? separator;

  /// {@template Breadcrumb.wrapAlignment}
  /// How the children should be placed along the wraps main axis.
  /// {@endtemplate}
  final WrapAlignment? mainAxisAlignment;

  /// {@template Breadcrumb.wrapCrossAxisAlignment}
  /// How the children should be placed along the wraps cross axis.
  /// {@endtemplate}
  final WrapCrossAlignment? crossAxisAlignment;

  /// {@template Breadcrumb.textDirection}
  /// The text direction to use for the breadcrumb.
  /// {@endtemplate}
  final TextDirection? textDirection;

  /// {@template Breadcrumb.verticalDirection}
  /// The vertical direction to use for the breadcrumb.
  /// {@endtemplate}
  final VerticalDirection? verticalDirection;

  /// {@template Breadcrumb.spacing}
  /// The spacing between breadcrumb items.
  /// Defaults to 10.
  /// {@endtemplate}
  final double? spacing;

  /// {@template Breadcrumb.itemTextStyle}
  /// The style for the breadcrumb link text.
  /// defaults to [Theme.of(context).textTheme.small]
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// {@template Breadcrumb.lastItemTextColor}
  /// The color for the last breadcrumb items text.
  /// defaults to [Theme.of(context).colorScheme.foreground]
  /// {@endtemplate}
  final Color? lastItemTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breadcrumbTheme = theme.breadcrumbTheme;

    final effectiveSeparator =
        separator ?? breadcrumbTheme.separator ?? const BreadcrumbSeparator();

    final effectiveMainAxisAlignment =
        mainAxisAlignment ??
        breadcrumbTheme.mainAxisAlignment ??
        WrapAlignment.start;

    final effectiveCrossAxisAlignment =
        crossAxisAlignment ??
        breadcrumbTheme.crossAxisAlignment ??
        WrapCrossAlignment.center;

    final effectiveSpacing = spacing ?? breadcrumbTheme.spacing ?? 10;

    final effectiveTextStyle =
        textStyle ??
        breadcrumbTheme.itemTextStyle ??
        theme.textTheme.small
            .copyWith(fontWeight: FontWeight.normal)
            .fallback(color: theme.colorScheme.mutedForeground);

    final effectiveLastItemColor =
        lastItemTextColor ??
        breadcrumbTheme.lastItemTextColor ??
        theme.colorScheme.foreground;

    return Wrap(
      alignment: effectiveMainAxisAlignment,
      crossAxisAlignment: effectiveCrossAxisAlignment,
      runSpacing: effectiveSpacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection ?? VerticalDirection.down,
      children: List.generate(
        children.length,
        (int index) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: effectiveTextStyle.copyWith(
                color: index == children.length - 1
                    ? effectiveLastItemColor
                    : effectiveTextStyle.color,
              ),
              child: children[index],
            ),
            if (index < children.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: effectiveSpacing),
                child: IconTheme.merge(
                  data: IconThemeData(color: theme.colorScheme.mutedForeground),
                  child: effectiveSeparator,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// {@template BreadcrumbLink}
/// A clickable breadcrumb item that navigates when tapped.
///
/// This widget wraps content in a clickable area and applies appropriate
/// hover and focus styling for interactive breadcrumb items.
/// {@endtemplate}
class BreadcrumbLink extends StatefulWidget {
  /// {@macro BreadcrumbLink}
  const BreadcrumbLink({
    super.key,
    required this.child,
    this.onPressed,
    this.normalColor,
    this.hoverColor,
    this.textStyle,
    this.onHoverChange,
  });

  /// The widget to display as the link content.
  final Widget child;

  /// Called when the breadcrumb link is tapped.
  final VoidCallback? onPressed;

  /// {@template Breadcrumb.linkNormalTextColor}
  /// The color for the breadcrumb link text when not hovered.
  /// defaults to [Theme.of(context).colorScheme.mutedForeground]
  /// {@endtemplate}
  final Color? normalColor;

  /// {@template Breadcrumb.linkHoverTextColor}
  /// The color for the breadcrumb link text when hovered.
  /// defaults to [Theme.of(context).colorScheme.foreground]
  /// {@endtemplate}
  final Color? hoverColor;

  /// {@template Breadcrumb.linkTextStyle}
  /// The style for the breadcrumb link text.
  /// defaults to [Theme.of(context).textTheme.small]
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// Called when the hover state changes.
  final void Function(bool)? onHoverChange;

  @override
  State<BreadcrumbLink> createState() => _BreadcrumbLinkState();
}

class _BreadcrumbLinkState extends State<BreadcrumbLink> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveNormalColor =
        widget.normalColor ??
        theme.breadcrumbTheme.linkNormalTextColor ??
        theme.colorScheme.mutedForeground;

    final effectiveHoverColor =
        widget.hoverColor ??
        theme.breadcrumbTheme.linkHoverTextColor ??
        theme.colorScheme.foreground;

    final effectiveTextColor = isHovered
        ? effectiveHoverColor
        : effectiveNormalColor;

    final effectiveTextStyle =
        widget.textStyle ??
        theme.breadcrumbTheme.linkTextStyle ??
        theme.textTheme.small
            .copyWith(fontWeight: FontWeight.normal)
            .fallback(color: theme.colorScheme.mutedForeground);

    return Button.raw(
      variant: ButtonVariant.link,
      onHoverChange:
          widget.onHoverChange ??
          (isHovered) => setState(() => this.isHovered = isHovered),
      padding: EdgeInsets.zero,
      // Use zero dimensions; Button's minWidth/minHeight constraints
      // allow the button to size to its child content
      height: 0,
      width: 0,
      onPressed: widget.onPressed,
      child: DefaultTextStyle(
        style: effectiveTextStyle.copyWith(
          color: effectiveTextColor,
        ),
        child: widget.child,
      ),
    );
  }
}

/// {@template BreadcrumbSeparator}
/// A separator widget used between breadcrumb items.
///
/// This widget provides a visual separator between breadcrumb items.
/// By default, it displays a chevron right icon.
/// {@endtemplate}
class BreadcrumbSeparator extends StatelessWidget {
  /// {@macro BreadcrumbSeparator}
  const BreadcrumbSeparator({
    super.key,
    this.size,
    this.color,
  });

  /// {@template Breadcrumb.separatorSize}
  /// The size of the separator.
  /// defaults value is 14.0
  /// {@endtemplate}
  final double? size;

  /// {@template Breadcrumb.separatorColor}
  /// The color of the separator.
  /// defaults to `ColorScheme.mutedForeground`
  /// {@endtemplate}
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSeparatorSize =
        size ?? theme.breadcrumbTheme.separatorSize ?? 14.0;
    final effectiveColor =
        color ??
        theme.breadcrumbTheme.separatorColor ??
        theme.colorScheme.mutedForeground;

    return PhosphorIcon(
      PhosphorIconsRegular.caretRight,
      size: effectiveSeparatorSize,
      color: effectiveColor,
    );
  }
}

/// {@template BreadcrumbEllipsis}
/// An ellipsis indicator for breadcrumb navigation.
///
/// This widget is used to indicate that there are more breadcrumb items
/// that are not currently visible, typically in a collapsed state.
/// It's often used with dropdown menus to show hidden breadcrumb levels.
/// {@endtemplate}
class BreadcrumbEllipsis extends StatelessWidget {
  /// {@macro BreadcrumbEllipsis}
  const BreadcrumbEllipsis({
    super.key,
    this.size,
  });

  /// {@template Breadcrumb.ellipsisSize}
  /// The size of the ellipsis indicator.
  /// defaults value is 16.0
  /// {@endtemplate}
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final custom = theme.breadcrumbTheme.ellipsis;
    if (custom != null) return custom;
    final effectiveSize = size ?? theme.breadcrumbTheme.ellipsisSize ?? 16.0;

    return PhosphorIcon(
      PhosphorIconsRegular.dotsThree,
      size: effectiveSize,
      color: theme.colorScheme.mutedForeground,
    );
  }
}

/// {@template BreadcrumbDropdown}
/// A dropdown breadcrumb item that displays a menu when clicked.
///
/// This widget is used to show collapsed breadcrumb items in a dropdown menu,
/// typically represented by an ellipsis. It follows the shadcn/ui pattern of
/// using a popover to show hidden navigation levels.
/// {@endtemplate}
class BreadcrumbDropdown extends StatefulWidget {
  /// {@macro BreadcrumbDropdown}
  const BreadcrumbDropdown({
    super.key,
    required this.child,
    required this.items,
    this.backgroundColor,
    this.padding,
    this.anchor,
    this.arrowGap,
    this.normalTextColor,
    this.hoverTextColor,
    this.showDropdownArrow,
  });

  /// The widget that triggers the dropdown.
  final Widget child;

  /// The list of dropdown menu items to display.
  final List<BreadcrumbDropMenuItem> items;

  /// {@template Breadcrumb.dropdownMenuBackgroundColor}
  /// The color for dropdown menu. defaults to
  /// [Theme.of(context).colorScheme.popover]
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Breadcrumb.dropdownMenuPadding}
  /// The padding value for dropdown menu. defaults to
  /// [EdgeInsets.all(4)]
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Breadcrumb.dropdownMenuAnchor}
  /// The anchor configuration for the dropdown popover.
  /// Defaults to
  /// ```dart
  /// AnchorAuto(
  ///   offset: Offset(0, 4),
  ///   targetAnchor: Alignment.bottomLeft,
  ///   followerAnchor: Alignment.bottomRight,
  /// ),
  /// ```
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@template Breadcrumb.dropdownArrowGap}
  /// The gap between the child and dropdown icon.
  /// defaults to 4
  /// {@endtemplate}
  final double? arrowGap;

  /// {@template Breadcrumb.linkNormalTextColor}
  /// The color for the breadcrumb link text when not hovered.
  /// defaults to [Theme.of(context).colorScheme.mutedForeground]
  /// {@endtemplate}
  final Color? normalTextColor;

  /// {@template Breadcrumb.linkHoverTextColor}
  /// The color for the breadcrumb link text when hovered.
  /// defaults to [Theme.of(context).colorScheme.foreground]
  /// {@endtemplate}
  final Color? hoverTextColor;

  /// {@template Breadcrumb.showDropdownArrow}
  /// Whether to show the dropdown arrow icon.
  /// Defaults to true.
  /// {@endtemplate}
  final bool? showDropdownArrow;

  @override
  State<BreadcrumbDropdown> createState() => _BreadcrumbDropdownState();
}

class _BreadcrumbDropdownState extends State<BreadcrumbDropdown> {
  final controller = PopoverController();
  bool isHovered = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveDropdownMenuBackgroundColor =
        widget.backgroundColor ??
        theme.breadcrumbTheme.dropdownMenuBackgroundColor ??
        theme.colorScheme.popover;

    final effectiveDropdownMenuPadding =
        widget.padding ??
        theme.breadcrumbTheme.dropdownMenuPadding ??
        const EdgeInsets.all(4);

    final effectiveAnchor =
        widget.anchor ??
        theme.breadcrumbTheme.dropdownMenuAnchor ??
        const AnchorAuto(
          offset: Offset(0, 4),
          targetAnchor: AlignmentDirectional.bottomStart,
          followerAnchor: AlignmentDirectional.bottomEnd,
          fallback: AnchorAuto(
            offset: Offset(0, -4),
            targetAnchor: AlignmentDirectional.topStart,
            followerAnchor: AlignmentDirectional.topEnd,
          ),
        );

    final effectiveArrowGap =
        widget.arrowGap ?? theme.breadcrumbTheme.dropdownArrowGap ?? 4;

    final effectiveNormalTextColor =
        widget.normalTextColor ??
        theme.breadcrumbTheme.linkNormalTextColor ??
        theme.colorScheme.mutedForeground;

    final effectiveHoverTextColor =
        widget.hoverTextColor ??
        theme.breadcrumbTheme.linkHoverTextColor ??
        theme.colorScheme.foreground;

    final effectiveTextColor = isHovered || controller.isOpen
        ? effectiveHoverTextColor
        : effectiveNormalTextColor;

    final effectiveShowDropdownArrow =
        widget.showDropdownArrow ??
        theme.breadcrumbTheme.showDropdownArrow ??
        true;

    return Popover(
      anchor: effectiveAnchor,
      decoration: FinesseDecoration(
        color: effectiveDropdownMenuBackgroundColor,
      ),
      controller: controller,
      padding: effectiveDropdownMenuPadding,
      popover: (context) => IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.items,
        ),
      ),
      child: BreadcrumbLink(
        normalColor: effectiveTextColor,
        onHoverChange: (isHovered) =>
            setState(() => this.isHovered = isHovered),
        onPressed: controller.toggle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: effectiveArrowGap,
          children: [
            widget.child,
            if (effectiveShowDropdownArrow)
              AnimatedRotation(
                turns: controller.isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: PhosphorIcon(
                  PhosphorIconsRegular.caretDown,
                  size: theme.breadcrumbTheme.separatorSize ?? 14,
                  color: effectiveTextColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// {@template Breadcrumb.DropMenuItem}
/// A single item in a breadcrumb dropdown.
///
/// This widget represents a child in a dropdown menu and can
/// contain text, links, or other interactive elements.
/// {@endtemplate}
class BreadcrumbDropMenuItem extends StatelessWidget {
  /// {@macro Breadcrumb.DropMenuItem}
  const BreadcrumbDropMenuItem({
    super.key,
    required this.child,
    this.onPressed,
    this.textStyle,
    this.itemPadding,
  });

  /// The widget to display as the breadcrumb item content.
  final Widget child;

  /// Called when the Widget is tapped.
  final VoidCallback? onPressed;

  /// {@template Breadcrumb.dropdownTextStyle}
  /// The text style for dropdown menu items.
  /// defaults to [Theme.of(context).textTheme.small]
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// {@template Breadcrumb.dropdownItemPadding}
  /// The padding value for dropdown menu items.
  /// defaults to [EdgeInsets.symmetric(horizontal: 12, vertical: 10)]
  /// {@endtemplate}
  final EdgeInsetsGeometry? itemPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle =
        textStyle ??
        theme.breadcrumbTheme.dropdownTextStyle ??
        theme.textTheme.small.fallback(
          color: theme.colorScheme.foreground,
        );
    final effectiveItemPadding =
        itemPadding ??
        theme.breadcrumbTheme.dropdownItemPadding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    return Button.raw(
      variant: ButtonVariant.ghost,
      height: 0,
      width: 0,
      padding: effectiveItemPadding,
      mainAxisAlignment: MainAxisAlignment.start,
      onPressed: onPressed,
      child: DefaultTextStyle(
        style: effectiveTextStyle,
        child: child,
      ),
    );
  }
}
