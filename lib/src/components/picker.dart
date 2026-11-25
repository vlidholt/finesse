import 'dart:ui' show ImageFilter;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/layout.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/sheet.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
typedef PickerTriggerBuilder<T> =
    Widget Function(BuildContext context, T value, VoidCallback toggle);

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
    this.groupId,
    this.onOpenChanged,
    this.effects,
    this.reverseDuration,
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

  /// The tap-region group of the popover, for content that opens popovers
  /// of its own.
  final Object? groupId;

  /// Called when the picker opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// The popover's entrance effects, when the picker has its own.
  final List<Effect<dynamic>>? effects;

  /// How long the popover takes to leave, when the picker says.
  final Duration? reverseDuration;

  /// The popover's shadows, when the picker has its own.
  final List<BoxShadow>? shadows;

  /// The popover's backdrop filter, when the picker has its own.
  final ImageFilter? filter;

  /// The popover's decoration, when the picker has its own.
  final FinesseDecoration? decoration;

  @override
  State<PickerHost> createState() => _PickerHostState();
}

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
    return Popover(
      controller: _controller,
      groupId: widget.groupId,
      requestFocus: widget.requestFocus,
      closeOnTapOutside: widget.closeOnTapOutside,
      padding: widget.popoverPadding,
      anchor: widget.anchor,
      effects: widget.effects,
      reverseDuration: widget.reverseDuration,
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

/// The button a picker shows: the formatted value, or a placeholder in the
/// muted colour, between an icon and whatever trails it.
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

  /// The look of the button.
  final ButtonVariant? variant;

  /// The size of the button.
  final ButtonSize? size;

  /// A fixed width.
  final double? width;

  /// Whether the button fills the width it is given.
  final bool expands;

  /// Whether the button can be pressed.
  final bool enabled;

  /// The focus node of the button.
  final FocusNode? focusNode;

  /// Whether the button takes the focus when it first appears.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = this.label;
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
      variant: variant ?? ButtonVariant.outline,
      pressScale: 1,
      size: size,
      width: width,
      expands: expands,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      mainAxisAlignment: MainAxisAlignment.start,
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
    final l = FinesseLocalizations.of(context);
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
            FinesseRow(
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
