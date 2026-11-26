import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// One option in a [ThemePicker].
@immutable
class PickerOption<T> {
  const PickerOption({
    required this.value,
    required this.label,
    this.swatch,
    this.labelStyleBuilder,
  });

  final T value;
  final String label;

  /// Builds a style merged into the label's in the list, e.g. to show a font
  /// option in its own face.
  ///
  /// A builder rather than a style because it is only called by a row that
  /// is actually on screen. For a font that matters: resolving the style is
  /// what starts the download, and a list of twenty-six fonts shows nine at
  /// a time.
  final ValueGetter<TextStyle>? labelStyleBuilder;

  /// Shown as a colour dot before the label, as shadcn's colour pickers do.
  final Color? swatch;
}

/// The style of a setting row's small heading, e.g. "Style" or "Base Color".
///
/// shadcn's customizer sets these `text-xs text-muted-foreground`. The colour
/// has to be stated: `TextTheme.muted` carries the muted *metrics* but no
/// colour, so on its own it renders in the ambient foreground.
TextStyle _labelStyle(ThemeData theme) => theme.textTheme.muted.copyWith(
  fontSize: 11,
  height: 16 / 11,
  color: theme.colorScheme.mutedForeground,
);

/// The style of a row's current value.
TextStyle _valueStyle(ThemeData theme) =>
    theme.textTheme.small.copyWith(fontSize: 14, height: 20 / 14);

/// Whether the panel is laid out for touch — it is when it covers a phone.
bool _touch(ThemeData theme) => theme.formFactor == FormFactor.mobile;

/// The height of one option in a picker's list.
double _itemExtent(ThemeData theme) => _touch(theme) ? 44 : 34;

/// The box every setting row is drawn in: a small muted label above the
/// current value, with an indicator at the trailing edge.
///
/// This is the shape every picker in shadcn's `/create` sidebar uses, where
/// that indicator is positioned `right-2.5 top-1/2 -translate-y-1/2`.
class _SettingBox extends StatelessWidget {
  const _SettingBox({
    required this.label,
    required this.value,
    this.trailing,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: UnaGestureDetector(
        mouseCursor: enabled && onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: _touch(theme) ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: theme.radius,
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: _labelStyle(theme),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      value,
                      style: _valueStyle(theme),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A row's trailing icon.
class _RowIcon extends StatelessWidget {
  const _RowIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PhosphorIcon(
      icon,
      size: 15,
      color: Theme.of(context).colorScheme.mutedForeground,
    );
  }
}

/// A single-select setting row from shadcn/ui's customizer: tapping it opens
/// a popover holding the options.
class ThemePicker<T> extends StatefulWidget {
  const ThemePicker({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.icon,
    this.busy = false,
  });

  final String label;
  final T value;
  final List<PickerOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool enabled;

  /// Shown at the trailing edge when the setting has no colour to show.
  ///
  /// shadcn's customizer gives every row its own icon, which is what makes the
  /// list scannable without reading it.
  final IconData? icon;

  /// Shows a spinner in place of [icon], while a choice is being prepared
  /// (a font loading, for instance).
  final bool busy;

  @override
  State<ThemePicker<T>> createState() => _ThemePickerState<T>();
}

class _ThemePickerState<T> extends State<ThemePicker<T>> {
  final controller = PopoverController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = math.max(
      0,
      widget.options.indexWhere((o) => o.value == widget.value),
    );
    final selected = widget.options[selectedIndex];

    return Popover(
      controller: controller,
      padding: const EdgeInsets.all(4),
      anchor: const AnchorAuto(offset: Offset(0, 4)),
      decoration: UnaDecoration(
        border: UnaBorder.all(
          color: theme.colorScheme.foreground.withValues(alpha: .1),
          borderRadius: theme.radii.lg,
          width: 1,
        ),
      ),
      builder: (context) => _PickerList<T>(
        options: widget.options,
        selectedIndex: selectedIndex,
        onSelected: (option) {
          // Re-picking the current option would otherwise rebuild both app
          // themes to arrive back where it started.
          if (option.value != widget.value) widget.onChanged(option.value);
          controller.close();
        },
      ),
      child: _SettingBox(
        label: widget.label,
        value: selected.label,
        enabled: widget.enabled,
        onTap: controller.toggle,
        // The row's indicator sits at the trailing edge, centred on the
        // two-line stack.
        trailing: widget.busy
            ? Spinner(size: 15, color: theme.colorScheme.mutedForeground)
            : selected.swatch != null
            ? _Swatch(color: selected.swatch!)
            : widget.icon != null
            ? _RowIcon(widget.icon!)
            : null,
      ),
    );
  }
}

/// The options of a [ThemePicker], built lazily.
///
/// A fixed-extent `ListView.builder` with a one-row cache: only the rows in
/// view are built, so an option's [PickerOption.labelStyleBuilder] — a font
/// download, for the font pickers — runs when its row scrolls into view and
/// not before. It opens scrolled to the selected option.
class _PickerList<T> extends StatefulWidget {
  const _PickerList({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<PickerOption<T>> options;
  final int selectedIndex;
  final ValueChanged<PickerOption<T>> onSelected;

  static const _maxHeight = 320.0;

  @override
  State<_PickerList<T>> createState() => _PickerListState<T>();
}

class _PickerListState<T> extends State<_PickerList<T>> {
  ScrollController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extent = _itemExtent(Theme.of(context));
    final contentHeight = extent * widget.options.length;
    final height = math.min(_PickerList._maxHeight, contentHeight);
    // Centre the selected option, as far as the list can scroll.
    final controller = _controller ??= ScrollController(
      initialScrollOffset:
          (extent * widget.selectedIndex - (height - extent) / 2).clamp(
            0.0,
            contentHeight - height,
          ),
    );

    return ConstrainedBox(
      // Without a maxWidth the popover matches the anchor's incoming
      // constraints, which in a stretched sidebar column is the whole
      // viewport.
      constraints: const BoxConstraints(minWidth: 232, maxWidth: 264),
      child: SizedBox(
        height: height,
        child: ListView.builder(
          controller: controller,
          primary: false,
          padding: EdgeInsets.zero,
          itemExtent: extent,
          scrollCacheExtent: ScrollCacheExtent.pixels(extent),
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            return _PickerItem(
              label: option.label,
              labelStyleBuilder: option.labelStyleBuilder,
              swatch: option.swatch,
              selected: index == widget.selectedIndex,
              onTap: () => widget.onSelected(option),
            );
          },
        ),
      ),
    );
  }
}

class _PickerItem extends StatefulWidget {
  const _PickerItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.swatch,
    this.labelStyleBuilder,
  });

  final String label;
  final ValueGetter<TextStyle>? labelStyleBuilder;
  final bool selected;
  final VoidCallback onTap;
  final Color? swatch;

  @override
  State<_PickerItem> createState() => _PickerItemState();
}

class _PickerItemState extends State<_PickerItem> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnaGestureDetector(
      mouseCursor: SystemMouseCursors.click,
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onHover: (v) => setState(() => hovered = v),
      child: Container(
        height: _itemExtent(theme),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: hovered ? theme.colorScheme.accent : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (widget.swatch != null) ...[
              _Swatch(color: widget.swatch!),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.label,
                style: _valueStyle(
                  theme,
                ).merge(widget.labelStyleBuilder?.call()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.selected)
              PhosphorIcon(
                PhosphorIconsRegular.check,
                size: 14,
                color: theme.colorScheme.foreground,
              ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.border,
        ),
      ),
    );
  }
}

/// A labelled slider: the label and the current value on one line, the track
/// on the next.
///
/// Two lines because the panel is 272 wide — a label, a track and a value
/// side by side leave the track some 90 pixels, too short to set anything
/// with.
class ThemeSlider extends StatelessWidget {
  const ThemeSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = .01,
    this.format,
    this.onReset,
    this.enabled = true,
    this.icon,
  });

  /// {@macro ThemePicker.icon}
  final IconData? icon;

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  /// The slider only reports multiples of this, so a value can be found
  /// again — and so the exported code reads `0.7`, not `0.7031`.
  final double step;

  /// How [value] is written beside the label. Defaults to two decimals.
  final String Function(double value)? format;

  /// When given, the value is an override of something the style defines:
  /// a small button beside it calls this to hand the setting back.
  final VoidCallback? onReset;

  final bool enabled;

  double _snapped(double raw) {
    final snapped = (raw / step).roundToDouble() * step;
    // Trim the binary-fraction noise multiplication leaves behind.
    return double.parse(snapped.clamp(min, max).toStringAsFixed(4));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = format?.call(value) ?? value.toStringAsFixed(2);

    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            child: Row(
              children: [
                if (icon != null) ...[
                  _RowIcon(icon!),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: _labelStyle(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onReset != null)
                  UnaGestureDetector(
                    mouseCursor: SystemMouseCursors.click,
                    behavior: HitTestBehavior.opaque,
                    onTap: onReset,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: PhosphorIcon(
                        PhosphorIconsRegular.arrowCounterClockwise,
                        size: 13,
                        color: theme.colorScheme.mutedForeground,
                        semanticLabel: 'Use the style\'s $label',
                      ),
                    ),
                  ),
                Text(
                  shown,
                  style: _labelStyle(theme).copyWith(
                    // An overridden value is the panel's doing, so it reads
                    // as content; the style's own stays muted.
                    color: onReset != null
                        ? theme.colorScheme.foreground
                        : null,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _touch(theme) ? 32 : 24,
            // The package's own slider, in the panel's theme, with the
            // value in a bubble above the thumb while it is dragged.
            child: Center(
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: ((max - min) / step).round(),
                showDivisionMarks: false,
                enabled: enabled,
                semanticLabel: label,
                valueIndicator: SliderValueIndicator.whileDragging,
                valueLabel: (v) => format?.call(v) ?? v.toStringAsFixed(2),
                onChanged: (raw) {
                  final next = _snapped(raw);
                  if (next != value) onChanged(next);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A setting of two or three choices, all in view: the small label above a
/// `SegmentedControl` that fills the panel's width.
///
/// A choice this short reads better laid out than behind a popover: the
/// row says what the other options are without being opened, and one tap
/// changes it.
class ThemeSegments<T> extends StatelessWidget {
  const ThemeSegments({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final T value;
  final List<PickerOption<T>> options;
  final ValueChanged<T> onChanged;

  /// When false the row is dimmed and its segments do nothing.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // One quiet line: the label, and a small control at the end. A
    // full-width segmented control under every label outweighed the rows
    // around it.
    // Where the two do not fit on one line (long option names, large
    // text), the control goes on the next.
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(label, style: _labelStyle(theme), maxLines: 1),
          Semantics(
            label: label,
            container: true,
            child: SegmentedControl<T>(
              size: ControlSize.sm,
              enabled: enabled,
              value: value,
              onChanged: (next) {
                if (next != value) onChanged(next);
              },
              segments: [
                for (final option in options)
                  Segment(value: option.value, label: Text(option.label)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An on/off setting row: the two states are named, and the row is the
/// switch's tap target.
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onLabel = 'On',
    this.offLabel = 'Off',
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// What the row reads while [value] is true, and while it is false.
  final String onLabel;
  final String offLabel;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return _SettingBox(
      label: label,
      value: value ? onLabel : offLabel,
      enabled: enabled,
      onTap: () => onChanged(!value),
      // The row toggles; the switch only shows the state. Two tap targets
      // on top of each other would toggle twice.
      trailing: IgnorePointer(
        child: ExcludeSemantics(
          child: Switch(value: value, enabled: enabled, onChanged: (_) {}),
        ),
      ),
    );
  }
}

/// A picker whose popover holds arbitrary content rather than one flat list.
///
/// shadcn's Menu picker is a single row reading e.g. "Default / Solid", opening
/// a popover with two labelled radio groups — colour and surface. Modelling it
/// as four flat options would lose that structure.
class ThemeGroupPicker extends StatefulWidget {
  const ThemeGroupPicker({
    super.key,
    required this.label,
    required this.value,
    required this.groups,
    this.icon,
  });

  final String label;

  /// {@macro ThemePicker.icon}
  final IconData? icon;

  /// The summary shown on the trigger, e.g. "Default / Solid".
  final String value;

  final List<PickerGroup> groups;

  @override
  State<ThemeGroupPicker> createState() => _ThemeGroupPickerState();
}

/// A labelled run of mutually exclusive options inside a [ThemeGroupPicker].
@immutable
class PickerGroup {
  const PickerGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  /// shadcn disables the accent group while a menu is translucent.
  final bool enabled;
}

class _ThemeGroupPickerState extends State<ThemeGroupPicker> {
  final controller = PopoverController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Popover(
      controller: controller,
      padding: const EdgeInsets.all(4),
      anchor: const AnchorAuto(offset: Offset(0, 4)),
      builder: (context) => ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 360,
          minWidth: 232,
          maxWidth: 264,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var g = 0; g < widget.groups.length; g++) ...[
                if (g > 0)
                  const Divider(
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                  child: Text(
                    widget.groups[g].label,
                    style: _labelStyle(theme),
                  ),
                ),
                Opacity(
                  opacity: widget.groups[g].enabled ? 1 : .5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final option in widget.groups[g].options)
                        _PickerItem(
                          label: option,
                          selected: option == widget.groups[g].selected,
                          onTap: () {
                            if (!widget.groups[g].enabled) return;
                            widget.groups[g].onSelected(option);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      child: _SettingBox(
        label: widget.label,
        value: widget.value,
        onTap: controller.toggle,
        trailing: widget.icon == null ? null : _RowIcon(widget.icon!),
      ),
    );
  }
}

/// A colour chosen with the package's `ColorPicker`, in a setting row: the
/// hex as its value, a Clear button once one is chosen, and the swatch
/// that opens the picker (a popover on a desktop, a sheet on a phone).
class ThemeColorPicker extends StatelessWidget {
  const ThemeColorPicker({
    required this.label,
    required this.value,
    required this.current,
    required this.onChanged,
    this.emptyLabel = 'None',
    this.swatches = _swatches,
    this.valueLabel,
    this.clearLabel = 'Clear',
    this.clearable = true,
    this.onClear,
    super.key,
  });

  /// What the row reads while no colour is chosen.
  final String emptyLabel;

  /// A name for [value], read instead of its hex (a palette's, a preset's).
  final String? valueLabel;

  /// The clear button's label.
  final String clearLabel;

  /// Whether the row offers to clear what is chosen.
  final bool clearable;

  /// What clearing does; by default it reports a null colour.
  final VoidCallback? onClear;

  /// The swatches the picker offers.
  final List<Color> swatches;

  final String label;

  /// The colour chosen, or null while none is.
  final Color? value;

  /// The colour in use now, which the picker opens on.
  final Color current;

  final ValueChanged<Color?> onChanged;

  static const _swatches = [
    Color(0xFF2563EB),
    Color(0xFF0D9488),
    Color(0xFF16A34A),
    Color(0xFFCA8A04),
    Color(0xFFEA580C),
    Color(0xFFDC2626),
    Color(0xFFDB2777),
    Color(0xFF7C3AED),
  ];

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return _SettingBox(
      label: label,
      value: value == null ? emptyLabel : valueLabel ?? colorToHex(value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (clearable && (onClear != null || value != null))
            Button.ghost(
              size: ButtonSize.sm,
              onPressed: onClear ?? () => onChanged(null),
              child: Text(clearLabel),
            ),
          ColorPickerButton(
            semanticLabel: label,
            size: 24,
            value: value ?? current,
            swatches: swatches,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
