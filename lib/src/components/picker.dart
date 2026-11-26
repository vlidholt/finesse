import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/layout.dart';
import 'package:una/src/components/popover.dart';
import 'package:una/src/components/sheet.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/raw_components/portal.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/components/button.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/components/layout.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/form_factor.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/entrance.dart';
import 'package:una/src/utils/extensions/text_style.dart';

/// How a picker — `DatePicker`, `TimePicker`, `Select`, `ColorPickerButton`
/// — shows its choices when it is opened.
enum PickerPresentation {
  /// A bottom sheet on a phone and a popover on a desktop, following the
  /// theme's form factor.
  auto,

  /// A popover anchored to the trigger, on every form factor.
  popover,

  /// A sheet from the bottom of the screen, on every form factor.
  sheet,
}

/// Builds the control that opens a picker, in place of its own button.
///
/// [value] is what the picker holds and [toggle] opens it, or closes it
/// when it is open.
typedef PickerTriggerBuilder<T> = Widget Function(
  BuildContext context,
  T value,
  VoidCallback toggle,
);

/// Whether [presentation] is a sheet under the theme of [context].
bool pickerOpensSheet(BuildContext context, PickerPresentation presentation) {
  return switch (presentation) {
    PickerPresentation.sheet => true,
    PickerPresentation.popover => false,
    PickerPresentation.auto =>
      Theme.of(context).formFactor == FormFactor.mobile,
  };
}

/// The part every picker shares: a trigger, and its choices in a popover or
/// a bottom sheet, opened and closed through one [PopoverController].
///
/// Internal to the package.
class PickerHost extends StatefulWidget {
  /// Creates a picker host.
  const PickerHost({
    required this.presentation,
    required this.triggerBuilder,
    required this.popoverBuilder,
    required this.sheetBuilder,
    this.controller,
    this.requestFocus = true,
    this.closeOnTapOutside = true,
    this.popoverPadding,
    this.anchor,
    this.onOpenChanged,
    this.exitDuration,
    this.instant = false,
    this.shadows,
    this.filter,
    this.decoration,
    super.key,
  });

  /// Which of the two presentations to use.
  final PickerPresentation presentation;

  /// Builds the trigger; `toggle` opens or closes the picker.
  final Widget Function(BuildContext context, VoidCallback toggle)
  triggerBuilder;

  /// Builds the content of the popover; `close` closes it.
  final Widget Function(BuildContext context, VoidCallback close)
  popoverBuilder;

  /// Builds the sheet, normally a [Sheet]; `close` closes it.
  final Widget Function(BuildContext context, VoidCallback close) sheetBuilder;

  /// Opens and closes the picker from outside.
  final PopoverController? controller;

  /// Whether the popover takes the focus when it opens.
  final bool requestFocus;

  /// Whether a tap outside the popover closes it.
  final bool closeOnTapOutside;

  /// The padding inside the popover.
  final EdgeInsetsGeometry? popoverPadding;

  /// Where the popover sits against the trigger.
  final AnchorBase? anchor;

  /// Called when the picker opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// How long the popover takes to leave, when it is not the theme's
  /// `Motion.fast`.
  final Duration? exitDuration;

  /// Whether the popover is simply there when it opens, and gone when it
  /// closes, with no entrance or exit: the calendar of a date picker, whose
  /// grid growing and sliding in from the trigger reads as content that
  /// scrolls into place.
  final bool instant;

  /// The popover's shadows, when the picker has its own.
  final List<BoxShadow>? shadows;

  /// The popover's backdrop filter, when the picker has its own.
  final ImageFilter? filter;

  /// The popover's decoration, when the picker has its own.
  final UnaDecoration? decoration;

  @override
  State<PickerHost> createState() => _PickerHostState();
}

const _noEntrance = EntranceSpec(duration: Duration.zero, curve: Curves.linear);

class _PickerHostState extends State<PickerHost> {
  PopoverController? _ownController;
  Route<void>? _sheetRoute;

  /// Whether a sheet has been pushed and not yet told to leave. Its builder
  /// runs again while it leaves, and must not be taken for a new sheet.
  bool _sheetShowing = false;
  bool _wasOpen = false;
  bool _sheet = false;

  PopoverController get _controller =>
      widget.controller ?? (_ownController ??= PopoverController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onController);
    _wasOpen = _controller.isOpen;
  }

  @override
  void didUpdateWidget(PickerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onController);
      _controller.addListener(_onController);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sheet = pickerOpensSheet(context, widget.presentation);
    if (sheet != _sheet) {
      // A picker left open while the form factor changes would have to turn
      // from one presentation into the other; it closes instead.
      if (_controller.isOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _controller.close();
        });
      }
      _sheet = sheet;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onController);
    _closeSheet();
    _ownController?.dispose();
    super.dispose();
  }

  void _onController() {
    final open = _controller.isOpen;
    if (open == _wasOpen) return;
    _wasOpen = open;
    widget.onOpenChanged?.call(open);
    if (!_sheet) return;
    if (open) {
      _openSheet();
    } else {
      _closeSheet();
    }
  }

  void _openSheet() {
    if (_sheetShowing || !mounted) return;
    _sheetShowing = true;
    showSheet<void>(
      context: context,
      side: SheetSide.bottom,
      builder: (sheetContext) {
        // The route is known only from inside it. Closing goes through it,
        // so a dialog opened over the sheet is never popped in its place.
        if (_sheetShowing) _sheetRoute ??= ModalRoute.of(sheetContext);
        return widget.sheetBuilder(sheetContext, _controller.close);
      },
    ).whenComplete(() {
      // The picker may be gone by the time its sheet has left.
      if (!mounted) return;
      _sheetShowing = false;
      _sheetRoute = null;
      // Dismissed by the barrier, a drag or the system back gesture.
      if (_controller.isOpen) _controller.close();
    });
  }

  void _closeSheet() {
    final route = _sheetRoute;
    _sheetShowing = false;
    if (route == null) return;
    _sheetRoute = null;
    final navigator = route.navigator;
    if (navigator == null) return;
    if (route.isCurrent) {
      navigator.pop();
    } else if (route.isActive) {
      navigator.removeRoute(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trigger = Builder(
      builder: (context) => widget.triggerBuilder(context, _controller.toggle),
    );
    if (_sheet) return trigger;
    return Popover.internal(
      controller: _controller,
      requestFocus: widget.requestFocus,
      closeOnTapOutside: widget.closeOnTapOutside,
      padding: widget.popoverPadding,
      anchor: widget.anchor,
      exitDuration: widget.instant ? Duration.zero : widget.exitDuration,
      entrance: widget.instant ? _noEntrance : null,
      shadows: widget.shadows,
      filter: widget.filter,
      decoration: widget.decoration,
      builder: (context) => widget.popoverBuilder(context, _controller.close),
      child: trigger,
    );
  }
}

/// Gives the focus to [focusNode] when it first appears, whatever has it.
///
/// A popover that takes the focus asks for it on a node of its own as it
/// opens, so an `autofocus` inside it — which only acts while its scope has
/// no focus — never does. Internal to the package.
class PickerFocusOnOpen extends StatefulWidget {
  /// Creates a widget that focuses [focusNode] once.
  const PickerFocusOnOpen({
    required this.focusNode,
    required this.child,
    super.key,
  });

  /// The node to focus.
  final FocusNode focusNode;

  /// The content that owns [focusNode].
  final Widget child;

  @override
  State<PickerFocusOnOpen> createState() => _PickerFocusOnOpenState();
}

class _PickerFocusOnOpenState extends State<PickerFocusOnOpen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.focusNode.context != null) {
        widget.focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// What a picker shows to open it: the formatted value, or a placeholder in
/// the muted colour, between an icon and whatever trails it.
///
/// With no [variant] it is a field, as a text field or a select is: their
/// outline, fill, height, padding and text, so a picker sits level with the
/// other fields of a form. With a [variant] it is that button.
///
/// Internal to the package.
class PickerTrigger extends StatelessWidget {
  /// Creates a picker's trigger.
  const PickerTrigger({
    required this.onPressed,
    required this.placeholder,
    this.label,
    this.leading,
    this.trailing,
    this.variant,
    this.size,
    this.width,
    this.expands = false,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// Opens the picker.
  final VoidCallback? onPressed;

  /// The value as text; null shows [placeholder].
  final String? label;

  /// Shown while there is no value.
  final Widget placeholder;

  /// The widget before the label, usually an icon.
  final Widget? leading;

  /// The widget after the label.
  final Widget? trailing;

  /// The button it is; null makes it a field.
  final ButtonVariant? variant;

  /// The size of the button. A field is a field's height.
  final ButtonSize? size;

  /// A fixed width.
  final double? width;

  /// Whether it fills the width it is given.
  final bool expands;

  /// Whether it can be pressed.
  final bool enabled;

  /// Its focus node.
  final FocusNode? focusNode;

  /// Whether it takes the focus when it first appears.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = this.label;
    final variant = this.variant;
    if (variant == null) return _field(context, theme);
    final iconColor = label == null
        ? scheme.mutedForeground
        : scheme.foreground;
    Widget? tinted(Widget? icon) => icon == null
        ? null
        : IconTheme.merge(
            data: IconThemeData(color: iconColor),
            child: icon,
          );
    return Button(
      variant: variant,
      style: ButtonTheme(
        pressScale: 1,
        width: width,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
      size: size,
      expands: expands,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      onPressed: onPressed,
      leading: tinted(leading),
      trailing: tinted(trailing),
      // Flexible, so a date too long for a fixed-width button ends in an
      // ellipsis instead of overflowing it.
      child: Flexible(
        child: label != null
            ? Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)
            // The placeholder is the muted text style, as in a field: it
            // is not the button's label.
            : DefaultTextStyle(
                style: theme.textTheme.muted.copyWith(
                  color: scheme.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: placeholder,
              ),
      ),
    );
  }

  /// The field look: a text field's decoration, height, padding and text.
  Widget _field(BuildContext context, ThemeData theme) {
    final scheme = theme.colorScheme;
    final field = theme.textFieldTheme;
    final label = this.label;
    final decoration = field.decoration ?? const UnaDecoration();
    final padding =
        field.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    // What is typed into a text field, and its placeholder.
    final valueStyle = theme.textTheme.muted
        .copyWith(color: scheme.foreground)
        .merge(field.style);
    final placeholderStyle = theme.textTheme.muted
        .merge(field.placeholderStyle)
        .fallback(color: scheme.mutedForeground);
    final gap = theme.layoutTheme.gap(GapSize.sm);

    Widget? icon(Widget? icon) => icon == null
        ? null
        : IconTheme.merge(
            // A field's icons are quiet, whatever it holds.
            data: IconThemeData(color: scheme.mutedForeground, size: 16),
            child: icon,
          );
    final leading = icon(this.leading);
    final trailing = icon(this.trailing);

    final row = Row(
      mainAxisSize: expands || width != null
          ? MainAxisSize.max
          : MainAxisSize.min,
      children: [
        if (leading != null) ...[leading, SizedBox(width: gap)],
        Flexible(
          child: DefaultTextStyle(
            style: label == null ? placeholderStyle : valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: label == null ? placeholder : Text(label),
          ),
        ),
        if (trailing != null) ...[SizedBox(width: gap), trailing],
      ],
    );

    Widget trigger = Pressable(
      onPressed: onPressed,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticContainer: true,
      pressScale: 1,
      builder: (context, states) => ConstrainedBox(
        // Outside the decorator, so the height counts the border in, as a
        // text field's does.
        constraints: field.constraints ?? const BoxConstraints(),
        child: Decorator(
          decoration: decoration,
          focused: states.contains(WidgetState.focused),
          child: Padding(
            padding: padding,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: expands || width != null ? null : 1,
              heightFactor: 1,
              child: row,
            ),
          ),
        ),
      ),
    );
    if (width != null) trigger = SizedBox(width: width, child: trigger);
    return Opacity(
      opacity: enabled ? 1 : theme.disabledOpacity,
      child: trigger,
    );
  }
}

/// A picker's sheet: the choices, and for its actions one row with Cancel
/// and Done side by side, each half the width, and Clear before them when
/// there is something to clear.
///
/// The row is one action of the sheet, so it stays put under choices that
/// have to scroll. It is a row on a phone too, where a sheet stacks its
/// buttons: three full-width buttons under a wheel push the wheel off a
/// small screen. Internal to the package.
class PickerSheet extends StatelessWidget {
  /// Creates a picker's sheet.
  const PickerSheet({
    required this.child,
    required this.onDone,
    this.title,
    this.onCancel,
    this.onClear,
    this.maxWidth,
    super.key,
  });

  /// The sheet's title.
  final Widget? title;

  /// The choices.
  final Widget child;

  /// Keeps what was chosen. Null leaves the button out, for a sheet in
  /// which a tap on a choice is the choice.
  final VoidCallback? onDone;

  /// The widest the choices and the buttons are laid out. A bottom sheet
  /// is as wide as the window, which on a desktop is far wider than a
  /// picker reads well.
  final double? maxWidth;

  /// Drops it. Null leaves the button out, for a sheet whose choices take
  /// effect as they are made.
  final VoidCallback? onCancel;

  /// Clears the value. Null leaves the button out.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l = UnaLocalizations.of(context);
    // As wide as the sheet, up to the cap, in its middle.
    Widget capped(Widget child) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 420),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
    final hasActions = onClear != null || onCancel != null || onDone != null;
    return Sheet(
      title: title,
      actions: [
        if (hasActions)
          capped(
            UnaRow(
              gap: GapSize.sm,
              children: [
                if (onClear != null)
                  Button.ghost(
                    onPressed: onClear,
                    child: Text(l.datePicker.clear),
                  ),
                if (onCancel != null)
                  Expanded(
                    child: Button.outline(
                      onPressed: onCancel,
                      expands: true,
                      child: Text(l.datePicker.cancel),
                    ),
                  ),
                if (onDone != null)
                  Expanded(
                    child: Button(
                      onPressed: onDone,
                      expands: true,
                      child: Text(l.datePicker.done),
                    ),
                  ),
              ],
            ),
          ),
      ],
      child: capped(child),
    );
  }
}
