import 'package:finesse/src/components/context_menu.dart';
import 'package:finesse/src/components/dialog.dart';
import 'package:finesse/src/components/sheet.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/arrow_key_focus.dart';
import 'package:flutter/widgets.dart';

/// One of the choices of an [ActionSheet].
///
/// ```dart
/// ActionSheetAction(
///   label: const Text('Delete draft'),
///   icon: const PhosphorIcon(PhosphorIconsRegular.trash),
///   value: DraftAction.delete,
///   destructive: true,
/// )
/// ```
@immutable
class ActionSheetAction<T> {
  /// Creates a choice labelled [label].
  const ActionSheetAction({
    required this.label,
    this.icon,
    this.value,
    this.onPressed,
    this.destructive = false,
    this.isDefault = false,
    this.enabled = true,
  });

  /// What the choice says, usually a `Text`.
  final Widget label;

  /// An icon before the label. When any action of a sheet has one the
  /// labels are set at the start of their rows, beside the icons; a sheet
  /// without icons centres them.
  final Widget? icon;

  /// What [showActionSheet] completes with when this action is chosen.
  final T? value;

  /// Called when the action is chosen, after the sheet has closed.
  final VoidCallback? onPressed;

  /// Whether the action destroys something: it is drawn in the destructive
  /// colour and does not take the focus when the sheet opens.
  final bool destructive;

  /// Whether this is the action most people want: its label is heavier.
  final bool isDefault;

  /// Whether the action can be chosen.
  final bool enabled;
}

/// Asks the user to pick one of a few [actions] that belong to what they
/// just touched: a post's "more" button, a photograph, a row.
///
/// The presentation follows the form factor. On a phone it is a sheet from
/// the bottom, with the choices as full-width rows and Cancel on a row of
/// its own; a drag down, a tap outside or the back button cancels. On a
/// desktop it is a menu under [anchorRect] — the global rectangle of the
/// control that opened it — or, without one, a small dialog.
///
/// The future completes with the chosen action's `value`, or with null
/// when the sheet was cancelled. An action's `onPressed` runs as well, once
/// the sheet has closed.
///
/// ```dart
/// final action = await showActionSheet<PostAction>(
///   context: context,
///   title: const Text('Post by Maya'),
///   actions: const [
///     ActionSheetAction(value: PostAction.save, label: Text('Save')),
///     ActionSheetAction(value: PostAction.share, label: Text('Share…')),
///     ActionSheetAction(
///       value: PostAction.report,
///       label: Text('Report'),
///       destructive: true,
///     ),
///   ],
/// );
/// ```
///
/// [showCancel] adds the Cancel row to the sheet and the dialog (a menu is
/// cancelled by a click outside it); [cancelLabel] replaces its text.
Future<T?> showActionSheet<T>({
  required BuildContext context,
  required List<ActionSheetAction<T>> actions,
  Widget? title,
  Widget? message,
  bool showCancel = true,
  Widget? cancelLabel,
  Rect? anchorRect,
  bool useRootNavigator = false,
}) {
  final theme = Theme.of(context, listen: false);

  // Close first, then act: an action that opens something of its own does
  // it over the page, not over a sheet that is on its way out.
  void choose(BuildContext context, ActionSheetAction<T> action) {
    Navigator.of(context).pop(action.value);
    action.onPressed?.call();
  }

  if (theme.formFactor == FormFactor.mobile) {
    return showSheet<T>(
      context: context,
      side: SheetSide.bottom,
      useRootNavigator: useRootNavigator,
      builder: (context) => Sheet(
        padding: EdgeInsets.zero,
        showCloseButton: false,
        child: ActionSheet<T>(
          title: title,
          message: message,
          actions: actions,
          showCancel: showCancel,
          cancelLabel: cancelLabel,
          onSelected: (action) => choose(context, action),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  if (anchorRect != null) {
    return showMenu<T>(
      context: context,
      anchorRect: anchorRect,
      useRootNavigator: useRootNavigator,
      items: [
        if (title != null || message != null)
          // A menu's heading: the title, and the message under it in the
          // same quiet style.
          MenuLabel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [?title, ?message],
            ),
          ),
        for (final action in actions)
          MenuItem(
            value: action.value,
            leading: action.icon,
            destructive: action.destructive,
            enabled: action.enabled,
            onPressed: action.onPressed ?? () {},
            child: action.label,
          ),
      ],
    );
  }

  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final sheetTheme = Theme.of(context).actionSheetTheme;
      return Dialog(
        padding: EdgeInsets.zero,
        constraints:
            sheetTheme.dialogConstraints ?? const BoxConstraints(maxWidth: 320),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        child: ActionSheet<T>(
          title: title,
          message: message,
          actions: actions,
          showCancel: showCancel,
          cancelLabel: cancelLabel,
          onSelected: (action) => choose(context, action),
          onCancel: () => Navigator.of(context).pop(),
        ),
      );
    },
  );
}

/// The content of an action sheet: an optional [title] and [message], the
/// [actions] as rows, and a Cancel row.
///
/// [showActionSheet] shows one in a sheet or a dialog. Use the widget
/// directly to put the same list somewhere else — an inline `Sheet`, a
/// popover, a route of your own — and decide in [onSelected] and
/// [onCancel] what a choice does there:
///
/// ```dart
/// ActionSheet<SortOrder>(
///   title: const Text('Sort by'),
///   actions: const [
///     ActionSheetAction(value: SortOrder.recent, label: Text('Recent')),
///     ActionSheetAction(value: SortOrder.name, label: Text('Name')),
///   ],
///   showCancel: false,
///   onSelected: (action) => setState(() => order = action.value!),
/// )
/// ```
///
/// The rows are walked with the arrow keys and chosen with Enter or Space;
/// the first one that is neither destructive nor disabled has the focus
/// when the sheet appears.
class ActionSheet<T> extends StatelessWidget {
  /// Creates the content of an action sheet.
  const ActionSheet({
    super.key,
    required this.actions,
    this.title,
    this.message,
    this.showCancel = true,
    this.cancelLabel,
    this.onSelected,
    this.onCancel,
    this.autofocus = true,
  });

  /// The choices, in the order they are listed.
  final List<ActionSheetAction<T>> actions;

  /// What the choices are about. It names the route for a screen reader.
  final Widget? title;

  /// A sentence under the title, in the muted style: a consequence, a
  /// count, a name.
  final Widget? message;

  /// Whether a Cancel row follows the actions. Defaults to true.
  final bool showCancel;

  /// The content of the Cancel row; the localized "Cancel" by default.
  final Widget? cancelLabel;

  /// Called with the action that was chosen. Its own `onPressed` is not
  /// called by the widget: do it here, before or after closing.
  final ValueChanged<ActionSheetAction<T>>? onSelected;

  /// Called when Cancel is chosen.
  final VoidCallback? onCancel;

  /// Whether the first action that is neither destructive nor disabled
  /// takes the focus when the sheet is built. Defaults to true.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetTheme = theme.actionSheetTheme;
    final direction = Directionality.of(context);
    final padding = (sheetTheme.padding ?? const EdgeInsets.all(8)).resolve(
      direction,
    );
    final hasIcons = actions.any((action) => action.icon != null);
    final focusIndex = !autofocus
        ? -1
        : actions.indexWhere((a) => a.enabled && !a.destructive);

    final title = this.title;
    final message = this.message;
    final dividerColor = sheetTheme.dividerColor ?? theme.colorScheme.border;

    final rows = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];
      if (i > 0) {
        rows.add(_Hairline(color: dividerColor));
      }
      rows.add(
        _ActionRow(
          label: action.label,
          icon: action.icon,
          centered: !hasIcons,
          emphasized: action.isDefault,
          color: action.destructive
              ? sheetTheme.destructiveColor ?? theme.colorScheme.destructive
              : sheetTheme.foregroundColor ?? theme.colorScheme.foreground,
          autofocus: i == focusIndex,
          onPressed: action.enabled
              ? () {
                  final onSelected = this.onSelected;
                  if (onSelected != null) {
                    onSelected(action);
                  } else {
                    action.onPressed?.call();
                  }
                }
              : null,
        ),
      );
    }

    return FocusTraversalGroup(
      // Up and Down walk the rows on every platform; see [ArrowKeyFocus].
      child: ArrowKeyFocus(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || message != null)
                Padding(
                  padding:
                      sheetTheme.headerPadding ??
                      const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Semantics(
                          header: true,
                          namesRoute: true,
                          container: true,
                          child: DefaultTextStyle.merge(
                            style: sheetTheme.titleStyle,
                            textAlign: TextAlign.center,
                            child: title,
                          ),
                        ),
                      if (title != null && message != null)
                        const SizedBox(height: 2),
                      if (message != null)
                        DefaultTextStyle.merge(
                          style: sheetTheme.messageStyle,
                          textAlign: TextAlign.center,
                          child: message,
                        ),
                    ],
                  ),
                ),
              if ((title != null || message != null) && rows.isNotEmpty)
                _Hairline(color: dividerColor, inset: 0),
              ...rows,
              if (showCancel) ...[
                SizedBox(height: sheetTheme.cancelGap ?? 8),
                _ActionRow(
                  label:
                      cancelLabel ??
                      Text(
                        FinesseLocalizations.of(context).actionSheet.cancel,
                      ),
                  icon: null,
                  centered: true,
                  emphasized: true,
                  color:
                      sheetTheme.foregroundColor ??
                      theme.colorScheme.foreground,
                  fill: sheetTheme.cancelColor ?? theme.colorScheme.secondary,
                  autofocus: focusIndex < 0 && autofocus,
                  onPressed: onCancel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The line between two rows, as wide as the rows' content.
class _Hairline extends StatelessWidget {
  const _Hairline({required this.color, this.inset});

  final Color color;
  final double? inset;

  @override
  Widget build(BuildContext context) {
    final sheetTheme = Theme.of(context).actionSheetTheme;
    final padding =
        (sheetTheme.rowPadding ?? const EdgeInsets.symmetric(horizontal: 12))
            .resolve(Directionality.of(context));
    return Padding(
      padding: EdgeInsets.only(
        left: inset ?? padding.left,
        right: inset ?? padding.right,
      ),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: color),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.icon,
    required this.centered,
    required this.emphasized,
    required this.color,
    required this.autofocus,
    required this.onPressed,
    this.fill,
  });

  final Widget label;
  final Widget? icon;
  final bool centered;
  final bool emphasized;
  final Color color;
  final Color? fill;
  final bool autofocus;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetTheme = theme.actionSheetTheme;
    final radius = sheetTheme.rowRadius ?? theme.radius;
    final labelStyle =
        (emphasized ? sheetTheme.defaultLabelStyle : null) ??
        sheetTheme.labelStyle ??
        theme.textTheme.p;
    final highlight = sheetTheme.highlightColor ?? theme.colorScheme.muted;
    final enabled = onPressed != null;
    final ink = enabled ? color : color.withValues(alpha: color.a * .5);

    return Pressable(
      onPressed: onPressed,
      autofocus: autofocus,
      // A row is a large surface: the press is a wash, with only a hint of
      // movement.
      pressScale: Motion.of(context).surfacePressScale,
      builder: (context, states) {
        final active =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused);
        final fill = this.fill;
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: radius,
          inset: true,
          child: AnimatedFill(
            // A filled row (Cancel) darkens a step; a plain one washes.
            color: fill == null
                ? (active ? highlight : null)
                : (active ? Color.alphaBlend(highlight, fill) : fill),
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: sheetTheme.rowHeight ?? 44,
              ),
              child: Padding(
                padding:
                    sheetTheme.rowPadding ??
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: DefaultTextStyle.merge(
                  style: labelStyle.copyWith(color: ink),
                  textAlign: centered ? TextAlign.center : TextAlign.start,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: ink,
                      size: sheetTheme.iconSize ?? 20,
                    ),
                    child: Row(
                      mainAxisAlignment: centered
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          SizedBox(width: sheetTheme.gap ?? 12),
                        ],
                        Flexible(child: label),
                      ],
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
