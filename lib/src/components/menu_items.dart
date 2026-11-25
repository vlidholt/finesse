part of 'context_menu.dart';

/// Marks the row below it as checkable, with its state.
///
/// [MenuCheckboxItem] and [MenuRadioItem] put one directly around the
/// [MenuItem] they build, which draws the indicator from it.
class _MenuCheckable extends InheritedWidget {
  const _MenuCheckable({
    required this.checked,
    required this.radio,
    required super.child,
  });

  /// Whether the row is checked.
  final bool checked;

  /// Whether the row is one of a group of which exactly one is checked.
  final bool radio;

  @override
  bool updateShouldNotify(_MenuCheckable oldWidget) =>
      checked != oldWidget.checked || radio != oldWidget.radio;
}

/// The side of the indicator column's box: the theme's
/// `ContextMenuTheme.indicatorSize`, grown with the text.
///
/// The mark says what state the row is in, so unlike an ornamental icon it
/// keeps its size beside the label when the user enlarges the text.
double _menuIndicatorSize(BuildContext context, ThemeData theme) =>
    MediaQuery.textScalerOf(
      context,
    ).scale(theme.contextMenuTheme.indicatorSize ?? 16);

/// Tells a screen reader what the row below is — a menu item, or a
/// checkbox or radio item that is checked or not — as one node with the
/// row's label and its tap action.
class _CheckableSemantics extends StatelessWidget {
  const _CheckableSemantics({required this.checkable, required this.child});

  final _MenuCheckable? checkable;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final checkable = this.checkable;
    // A menu item has to be in a menu: the framework asserts it. A row
    // built anywhere else is a plain button.
    final inMenu = context.getInheritedWidgetOfExactType<_MenuLevel>() != null;
    return MergeSemantics(
      child: Semantics(
        role: !inMenu
            ? null
            : checkable == null
            ? SemanticsRole.menuItem
            : checkable.radio
            ? SemanticsRole.menuItemRadio
            : SemanticsRole.menuItemCheckbox,
        checked: checkable?.checked,
        inMutuallyExclusiveGroup: checkable?.radio,
        child: child,
      ),
    );
  }
}

/// The check mark or the dot in a menu's indicator column.
///
/// It takes the row's own foreground through the icon theme, so it follows
/// the highlight as the label does.
class _MenuIndicator extends StatelessWidget {
  const _MenuIndicator({
    required this.checked,
    required this.radio,
    required this.size,
  });

  final bool checked;
  final bool radio;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (radio) {
      return Center(
        // The dot grows out of its centre, as a radio button's does.
        child: PopIn(
          visible: checked,
          scale: .2,
          child: SizedBox.square(
            dimension: size / 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: IconTheme.of(context).color,
              ),
            ),
          ),
        ),
      );
    }
    return Center(
      // The mark is drawn from its leading edge, as a checkbox's is.
      child: PopIn(
        visible: checked,
        wipe: true,
        child: PhosphorIcon(PhosphorIconsRegular.check, size: size),
      ),
    );
  }
}

/// {@template MenuCheckboxItem}
/// A menu row that is checked or not, shadcn's `DropdownMenuCheckboxItem`.
///
/// It is controlled: [onChanged] reports the new value and the parent
/// rebuilds the menu with it. A click toggles the row and leaves the menu
/// open unless [closeOnTap] is true; from the keyboard Space always toggles
/// and stays, and Enter does what a click does.
///
/// A menu with a checkable row keeps a column free for the check marks in
/// every row, so the labels line up.
///
/// ```dart
/// DropdownMenu(
///   items: [
///     MenuCheckboxItem(
///       checked: showGrid,
///       onChanged: (value) => setState(() => showGrid = value),
///       child: const Text('Show grid'),
///     ),
///   ],
///   builder: (context, controller, _) => Button.outline(
///     onPressed: controller.toggle,
///     child: const Text('View'),
///   ),
/// )
/// ```
/// {@endtemplate}
class MenuCheckboxItem extends StatelessWidget {
  /// {@macro MenuCheckboxItem}
  const MenuCheckboxItem({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.child,
    this.leading,
    this.trailing,
    this.shortcut,
    this.closeOnTap = false,
    this.enabled = true,
  });

  /// Whether the row is checked.
  final bool checked;

  /// Called with the new value when the row is toggled. A null callback
  /// disables the row.
  final ValueChanged<bool>? onChanged;

  /// The label.
  final Widget child;

  /// {@macro MenuItem.leading}
  ///
  /// It follows the check mark.
  final Widget? leading;

  /// {@macro MenuItem.trailing}
  final Widget? trailing;

  /// {@macro MenuItem.shortcut}
  final MenuShortcut? shortcut;

  /// Whether a click or Enter closes the menu after toggling. Defaults to
  /// false, so several rows can be toggled in one visit.
  final bool closeOnTap;

  /// Whether the row can be toggled. Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return _MenuCheckable(
      checked: checked,
      radio: false,
      child: MenuItem(
        enabled: enabled && onChanged != null,
        leading: leading,
        trailing: trailing,
        shortcut: shortcut,
        closeOnTap: closeOnTap,
        onPressed: onChanged == null ? null : () => onChanged(!checked),
        child: child,
      ),
    );
  }
}

/// {@template MenuRadioGroup}
/// A group of [MenuRadioItem]s of which one is selected, shadcn's
/// `DropdownMenuRadioGroup`.
///
/// It is controlled: [onChanged] reports the value of the row that was
/// chosen and the parent rebuilds the menu with it as [value].
///
/// ```dart
/// MenuRadioGroup<Density>(
///   value: density,
///   onChanged: (value) => setState(() => density = value),
///   children: const [
///     MenuRadioItem(value: Density.compact, child: Text('Compact')),
///     MenuRadioItem(value: Density.regular, child: Text('Regular')),
///   ],
/// )
/// ```
/// {@endtemplate}
class MenuRadioGroup<T> extends StatelessWidget {
  /// {@macro MenuRadioGroup}
  const MenuRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.children,
  });

  /// The value of the selected row, or null when none is.
  final T? value;

  /// Called with a row's value when it is chosen. A null callback disables
  /// every row of the group.
  final ValueChanged<T>? onChanged;

  /// The rows, typically [MenuRadioItem]s. Other menu widgets — a
  /// [MenuLabel], a [MenuDivider] — may sit between them.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _MenuRadioScope<T>(
      value: value,
      onChanged: onChanged,
      // Laid out as the menu lays out its own rows.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _MenuRadioScope<T> extends InheritedWidget {
  const _MenuRadioScope({
    required this.value,
    required this.onChanged,
    required super.child,
  });

  final T? value;
  final ValueChanged<T>? onChanged;

  @override
  bool updateShouldNotify(_MenuRadioScope<T> oldWidget) =>
      value != oldWidget.value || onChanged != oldWidget.onChanged;
}

/// {@template MenuRadioItem}
/// One choice of a [MenuRadioGroup], shadcn's `DropdownMenuRadioItem`.
///
/// The row whose [value] is the group's shows a dot. A click or Enter
/// chooses the row and closes the menu unless [closeOnTap] is false; Space
/// chooses it and leaves the menu open.
/// {@endtemplate}
class MenuRadioItem<T> extends StatelessWidget {
  /// {@macro MenuRadioItem}
  const MenuRadioItem({
    super.key,
    required this.value,
    required this.child,
    this.leading,
    this.trailing,
    this.shortcut,
    this.closeOnTap = true,
    this.enabled = true,
  });

  /// What the group reports when this row is chosen.
  final T value;

  /// The label.
  final Widget child;

  /// {@macro MenuItem.leading}
  ///
  /// It follows the dot.
  final Widget? leading;

  /// {@macro MenuItem.trailing}
  final Widget? trailing;

  /// {@macro MenuItem.shortcut}
  final MenuShortcut? shortcut;

  /// Whether a click or Enter closes the menu after choosing. Defaults to
  /// true.
  final bool closeOnTap;

  /// Whether the row can be chosen. Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final group = context
        .dependOnInheritedWidgetOfExactType<_MenuRadioScope<T>>();
    assert(
      group != null,
      'A MenuRadioItem<$T> needs a MenuRadioGroup<$T> above it. Give both '
      'the same type argument when it cannot be inferred.',
    );
    final onChanged = group?.onChanged;
    return _MenuCheckable(
      checked: group != null && group.value == value,
      radio: true,
      child: MenuItem(
        enabled: enabled && onChanged != null,
        leading: leading,
        trailing: trailing,
        shortcut: shortcut,
        closeOnTap: closeOnTap,
        onPressed: onChanged == null ? null : () => onChanged(value),
        child: child,
      ),
    );
  }
}

/// {@template MenuLabel}
/// The heading of a group of menu rows, shadcn's `DropdownMenuLabel`.
///
/// It is set in the menu's label style, lines up with the labels of the
/// rows under it, cannot be focused and is announced as a header.
///
/// ```dart
/// const MenuLabel(child: Text('Appearance'))
/// ```
/// {@endtemplate}
class MenuLabel extends StatelessWidget {
  /// {@macro MenuLabel}
  const MenuLabel({super.key, required this.child, this.padding});

  /// The heading, typically a [Text].
  final Widget child;

  /// The space around the heading, inside the menu's own padding.
  ///
  /// Defaults to the theme's `ContextMenuTheme.labelPadding`, and then to
  /// the horizontal padding of a row.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuTheme = theme.contextMenuTheme;
    final level = context.dependOnInheritedWidgetOfExactType<_MenuLevel>();

    final itemPaddingX = theme.style.itemPaddingX * theme.spacing.step / 4;
    final effectivePadding =
        padding ??
        menuTheme.labelPadding ??
        EdgeInsets.symmetric(horizontal: itemPaddingX, vertical: 6);

    // What a row puts before its label when the menu has check marks.
    final indicatorColumn = level?.indicatorColumn ?? false
        ? EdgeInsetsDirectional.only(
            start:
                _menuIndicatorSize(context, theme) +
                (menuTheme.leadingPadding ??
                        const EdgeInsetsDirectional.only(end: 8))
                    .horizontal,
          )
        : EdgeInsets.zero;

    final effectiveStyle = (menuTheme.labelTextStyle ?? theme.textTheme.caption)
        .fallback(
          color: theme.colorScheme.mutedForeground,
        );

    return Padding(
      padding: (menuTheme.itemPadding ?? EdgeInsets.zero)
          .add(effectivePadding)
          .add(indicatorColumn),
      child: Semantics(
        header: true,
        child: DefaultTextStyle(style: effectiveStyle, child: child),
      ),
    );
  }
}

/// {@template MenuDivider}
/// The hairline between two groups of menu rows, shadcn's
/// `DropdownMenuSeparator`.
///
/// It runs the full width of the menu, in the menu's own colours — a plain
/// `Divider` takes the page's, which is the wrong one on an inverted menu.
/// {@endtemplate}
class MenuDivider extends StatelessWidget {
  /// {@macro MenuDivider}
  const MenuDivider({super.key, this.margin, this.color});

  /// The space around the line. Defaults to the theme's
  /// `ContextMenuTheme.dividerMargin`, and then to 4 above and below.
  final EdgeInsetsGeometry? margin;

  /// The colour of the line. Defaults to the theme's
  /// `ContextMenuTheme.dividerColor`, and then to the scheme's border.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuTheme = theme.contextMenuTheme;
    return Divider(
      margin:
          margin ??
          menuTheme.dividerMargin ??
          const EdgeInsets.symmetric(vertical: 4),
      color: color ?? menuTheme.dividerColor ?? theme.colorScheme.border,
    );
  }
}

/// {@template MenuShortcut}
/// The keyboard shortcut shown at the end of a menu row, shadcn's
/// `DropdownMenuShortcut`.
///
/// Built from a [SingleActivator] it is written the way the platform
/// writes it: `⇧⌘P` on Apple's, `Ctrl+Shift+P` elsewhere. [MenuShortcut.text]
/// shows a string as it is.
///
/// It only displays the keys. Binding them — with `Shortcuts`,
/// `CallbackShortcuts` or the platform's menu bar — is the app's job, and
/// the same [SingleActivator] can be handed to both.
///
/// ```dart
/// MenuItem(
///   shortcut: const MenuShortcut(
///     SingleActivator(LogicalKeyboardKey.keyS, meta: true),
///   ),
///   onPressed: save,
///   child: const Text('Save'),
/// )
/// ```
/// {@endtemplate}
class MenuShortcut extends StatelessWidget {
  /// Shows [activator] in the platform's notation.
  const MenuShortcut(SingleActivator this.activator, {super.key}) : text = null;

  /// Shows [text] as it is.
  const MenuShortcut.text(String this.text, {super.key}) : activator = null;

  /// The keys to show, or null for [MenuShortcut.text].
  final SingleActivator? activator;

  /// The text to show, or null when built from an [activator].
  final String? text;

  static final Map<LogicalKeyboardKey, String> _arrows = {
    LogicalKeyboardKey.arrowLeft: '←',
    LogicalKeyboardKey.arrowUp: '↑',
    LogicalKeyboardKey.arrowRight: '→',
    LogicalKeyboardKey.arrowDown: '↓',
  };

  /// The glyphs Apple's menus use for keys that have no letter.
  static final Map<LogicalKeyboardKey, String> _appleGlyphs = {
    LogicalKeyboardKey.enter: '↩',
    LogicalKeyboardKey.numpadEnter: '⌤',
    LogicalKeyboardKey.escape: '⎋',
    LogicalKeyboardKey.tab: '⇥',
    LogicalKeyboardKey.backspace: '⌫',
    LogicalKeyboardKey.delete: '⌦',
    LogicalKeyboardKey.home: '↖',
    LogicalKeyboardKey.end: '↘',
    LogicalKeyboardKey.pageUp: '⇞',
    LogicalKeyboardKey.pageDown: '⇟',
  };

  /// How [activator] is written on [platform]: the modifiers in the
  /// platform's order, then the key.
  ///
  /// Apple's platforms use the glyphs of their menus, with nothing between
  /// them; the others spell the modifiers out and join them with `+`.
  /// [FinesseLocalizations] names the keys that are spelled out.
  static String describe(
    BuildContext context,
    SingleActivator activator, {
    TargetPlatform? platform,
  }) {
    final strings = FinesseLocalizations.of(context).menu;
    final effectivePlatform = platform ?? defaultTargetPlatform;
    final apple =
        effectivePlatform == TargetPlatform.macOS ||
        effectivePlatform == TargetPlatform.iOS;
    final key = activator.trigger;

    final named = <LogicalKeyboardKey, String>{
      LogicalKeyboardKey.enter: strings.enter,
      LogicalKeyboardKey.numpadEnter: strings.enter,
      LogicalKeyboardKey.escape: strings.escape,
      LogicalKeyboardKey.tab: strings.tab,
      LogicalKeyboardKey.backspace: strings.backspace,
      LogicalKeyboardKey.delete: strings.delete,
      LogicalKeyboardKey.insert: strings.insert,
      LogicalKeyboardKey.home: strings.home,
      LogicalKeyboardKey.end: strings.end,
      LogicalKeyboardKey.pageUp: strings.pageUp,
      LogicalKeyboardKey.pageDown: strings.pageDown,
      LogicalKeyboardKey.space: strings.space,
    };
    final label = key.keyLabel;
    final keyName =
        _arrows[key] ??
        (apple ? _appleGlyphs[key] : null) ??
        named[key] ??
        (label.isNotEmpty ? label.toUpperCase() : key.debugName ?? '');

    if (apple) {
      return [
        if (activator.control) '⌃',
        if (activator.alt) '⌥',
        if (activator.shift) '⇧',
        if (activator.meta) '⌘',
        keyName,
      ].join();
    }
    // The key cap's own name where the platform has one.
    final meta = effectivePlatform == TargetPlatform.windows
        ? 'Win'
        : strings.meta;
    return [
      if (activator.control) strings.control,
      if (activator.alt) strings.alt,
      if (activator.shift) strings.shift,
      if (activator.meta) meta,
      keyName,
    ].join('+');
  }

  @override
  Widget build(BuildContext context) {
    final activator = this.activator;
    return Text(
      activator == null ? text! : describe(context, activator),
      // Keys are read in the order they are pressed, whatever the
      // direction of the text around them; the glyphs have no direction of
      // their own and would be reordered.
      textDirection: TextDirection.ltr,
      maxLines: 1,
      softWrap: false,
    );
  }
}
