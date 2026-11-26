import 'package:example/common/theme_editor/color_tokens.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/style_field.dart';
import 'package:example/common/theme_editor/style_fields.g.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

// The long lists of the theme editor: every colour of the scheme and every
// field of the style, each in sections that fold away, one line a setting.

/// Whether the panel is laid out for touch.
bool _touch(BuildContext context) =>
    Theme.of(context).formFactor == FormFactor.mobile;

TextStyle _labelStyle(ThemeData theme) => theme.textTheme.small.copyWith(
  fontSize: 12,
  height: 16 / 12,
  fontWeight: FontWeight.w400,
  color: theme.colorScheme.foreground,
);

TextStyle _noteStyle(ThemeData theme) => theme.textTheme.muted.copyWith(
  fontSize: 11,
  height: 15 / 11,
  color: theme.colorScheme.mutedForeground,
);

/// A section inside a section: a title with a count, folding its rows away.
class EditorFoldOut extends StatelessWidget {
  const EditorFoldOut({
    required this.title,
    required this.children,
    this.count,
    this.edited = 0,
    this.initiallyOpen = false,
    super.key,
  });

  final String title;
  final int? count;

  /// How many of the rows are set by hand, shown beside the title.
  final int edited;
  final bool initiallyOpen;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Collapsible(
      initiallyOpen: initiallyOpen,
      maintainState: false,
      trigger: (context, open, toggle) => Semantics(
        button: true,
        expanded: open,
        child: UnaGestureDetector(
          mouseCursor: SystemMouseCursors.click,
          behavior: HitTestBehavior.opaque,
          onTap: toggle,
          child: SizedBox(
            height: _touch(context) ? 40 : 30,
            child: Row(
              children: [
                PhosphorIcon(
                  open
                      ? PhosphorIconsRegular.caretDown
                      : PhosphorIconsRegular.caretRight,
                  size: 11,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.small.copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (edited > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '$edited set',
                      style: _noteStyle(
                        theme,
                      ).copyWith(color: theme.colorScheme.tint),
                    ),
                  ),
                if (count != null) Text('$count', style: _noteStyle(theme)),
              ],
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 17, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

/// One line of a list: the label (and a note under it), a reset button
/// when the value is set by hand, and the control.
class _SettingLine extends StatelessWidget {
  const _SettingLine({
    required this.label,
    required this.control,
    this.note,
    this.onReset,
    this.tooltip,
  });

  final String label;
  final String? note;
  final String? tooltip;
  final VoidCallback? onReset;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: onReset != null
              ? _labelStyle(theme).copyWith(fontWeight: FontWeight.w600)
              : _labelStyle(theme),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (note != null)
          Text(
            note!,
            style: _noteStyle(theme),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
    if (tooltip != null && tooltip!.isNotEmpty) {
      text = Tooltip(
        builder: (context) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(tooltip!),
        ),
        child: text,
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: _touch(context) ? 44 : 32),
      child: Row(
        children: [
          Expanded(child: text),
          if (onReset != null)
            IconButton.ghost(
              size: ButtonSize.sm,
              icon: const PhosphorIcon(
                PhosphorIconsRegular.arrowCounterClockwise,
                size: 13,
              ),
              semanticLabel: 'Reset $label',
              onPressed: onReset,
            ),
          const SizedBox(width: 4),
          control,
        ],
      ),
    );
  }
}

/// Every colour of the scheme in [brightness], grouped, each with a
/// picker. A colour picked here is pinned in [brightness]; the other
/// brightness takes it over, adjusted to its own palette, until a colour
/// is picked there too.
class ColorTokenList extends StatelessWidget {
  const ColorTokenList({
    required this.config,
    required this.brightness,
    required this.onChanged,
    super.key,
  });

  final ThemeEditorConfig config;
  final Brightness brightness;
  final ValueChanged<ThemeEditorConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = config.copyWith(brightness: brightness).colorScheme;
    final other = brightness == Brightness.dark ? 'light' : 'dark';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'Editing the ${brightness.name} colours. A colour you pick '
            'carries over to $other mode until you pick one there.',
            style: _noteStyle(theme),
          ),
        ),
        for (final group in ColorTokenGroup.values)
          EditorFoldOut(
            title: group.label,
            count: colorTokens.where((t) => t.group == group).length,
            edited: colorTokens
                .where(
                  (t) =>
                      t.group == group &&
                      config.colorSource(t, brightness) == ColorSource.pinned,
                )
                .length,
            children: [
              for (final token in colorTokens)
                if (token.group == group)
                  _ColorLine(
                    token: token,
                    color: token.read(scheme),
                    source: config.colorSource(token, brightness),
                    onChanged: (color) =>
                        onChanged(config.withColor(token, brightness, color)),
                  ),
            ],
          ),
      ],
    );
  }
}

class _ColorLine extends StatelessWidget {
  const _ColorLine({
    required this.token,
    required this.color,
    required this.source,
    required this.onChanged,
  });

  final ColorToken token;
  final Color color;
  final ColorSource source;
  final ValueChanged<Color?> onChanged;

  @override
  Widget build(BuildContext context) {
    final translucent = color.a < 1;
    return _SettingLine(
      label: token.label,
      note: switch (source) {
        ColorSource.pinned => colorToHex(color, alpha: translucent),
        ColorSource.derived => 'From the other mode',
        ColorSource.scheme => null,
      },
      onReset: source == ColorSource.pinned ? () => onChanged(null) : null,
      control: ColorPickerButton(
        semanticLabel: token.label,
        size: _touch(context) ? 28 : 22,
        value: color,
        // A wash (a border, a muted fill) keeps its opacity editable.
        showAlpha: translucent || token.name == 'selection',
        onChanged: onChanged,
      ),
    );
  }
}

/// Every field of the style, grouped, with a search over their names and
/// descriptions. Edits apply to the metrics of [formFactor], the one the
/// app is showing.
class StyleFieldList extends StatefulWidget {
  const StyleFieldList({
    required this.config,
    required this.formFactor,
    required this.onChanged,
    super.key,
  });

  final ThemeEditorConfig config;
  final FormFactor formFactor;
  final ValueChanged<ThemeEditorConfig> onChanged;

  @override
  State<StyleFieldList> createState() => _StyleFieldListState();
}

class _StyleFieldListState extends State<StyleFieldList> {
  String _query = '';

  bool _matches(StyleField field) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return field.label.toLowerCase().contains(q) ||
        field.name.toLowerCase().contains(q) ||
        field.doc.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;
    final formFactor = widget.formFactor;
    final tokens = config.tokensFor(formFactor);
    final phone = formFactor == FormFactor.mobile;

    Widget line(StyleField field) => _StyleLine(
      key: ValueKey(field.name),
      field: field,
      value: field.read(tokens),
      edited: config.styleEdited(field, formFactor),
      onChanged: (value) =>
          widget.onChanged(config.withStyleValue(field, formFactor, value)),
    );

    final matches = styleFields.where(_matches).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          phone
              ? "Editing the phone's metrics, which the app is showing."
              : "Editing the desktop's metrics. A value the phone shares "
                    'changes there too.',
          style: _noteStyle(theme),
        ),
        const SizedBox(height: 6),
        SearchField(
          placeholder: const Text('Search settings'),
          clearOnEscape: true,
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 4),
        if (_query.isNotEmpty) ...[
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No setting matches.', style: _noteStyle(theme)),
            ),
          for (final field in matches) line(field),
        ] else
          for (final group in StyleFieldGroup.values)
            EditorFoldOut(
              title: group.label,
              count: styleFields.where((f) => f.group == group).length,
              edited: styleFields
                  .where(
                    (f) =>
                        f.group == group && config.styleEdited(f, formFactor),
                  )
                  .length,
              children: [
                for (final field in styleFields)
                  if (field.group == group) line(field),
              ],
            ),
      ],
    );
  }
}

class _StyleLine extends StatelessWidget {
  const _StyleLine({
    required this.field,
    required this.value,
    required this.edited,
    required this.onChanged,
    super.key,
  });

  final StyleField field;

  /// The value in use, or null for a nullable field that follows another.
  final Object? value;
  final bool edited;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return _SettingLine(
      label: field.label,
      tooltip: field.doc,
      note: value == null ? 'Follows the light value' : null,
      onReset: edited ? () => onChanged(null) : null,
      control: switch (field.kind) {
        StyleFieldKind.number => _NumberControl(
          field: field,
          value: (value as double?) ?? 0,
          onChanged: onChanged,
        ),
        StyleFieldKind.fraction => _FractionControl(
          field: field,
          value: (value as double?) ?? 1,
          onChanged: onChanged,
        ),
        StyleFieldKind.toggle => Semantics(
          label: field.label,
          child: Switch(
            value: (value as bool?) ?? false,
            onChanged: onChanged,
          ),
        ),
        StyleFieldKind.radius => _Choice<RadiusToken>(
          label: field.label,
          value: value as RadiusToken?,
          options: {for (final r in RadiusToken.values) r: r.name},
          onChanged: onChanged,
        ),
        StyleFieldKind.fill => _Choice<SurfaceFill>(
          label: field.label,
          value: value as SurfaceFill?,
          options: {for (final f in SurfaceFill.values) f: f.name},
          onChanged: onChanged,
        ),
        StyleFieldKind.shadow => _Choice<String>(
          label: field.label,
          value: switch (value) {
            final List<BoxShadow> shadow =>
              StyleField.shadowName(shadow)?.substring(8) ?? 'custom',
            _ => null,
          },
          options: {
            for (final name in StyleField.shadows.keys) name: name,
            if (value is List<BoxShadow> &&
                StyleField.shadowName(value) == null)
              'custom': 'Style\'s own',
          },
          onChanged: (name) {
            if (name != 'custom') onChanged(StyleField.shadows[name]);
          },
        ),
        StyleFieldKind.motion => _Choice<String>(
          label: field.label,
          value: StyleField.motionName(value! as Motion) ?? 'custom',
          options: {
            for (final name in StyleField.motions.keys) name: name,
            if (StyleField.motionName(value as Motion) == null)
              'custom': 'Custom',
          },
          onChanged: (name) {
            if (name != 'custom') onChanged(StyleField.motions[name]);
          },
        ),
        StyleFieldKind.textRole => _TextRoleControl(
          label: field.label,
          role: value as TextRole?,
          onChanged: onChanged,
        ),
      },
    );
  }
}

class _NumberControl extends StatelessWidget {
  const _NumberControl({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final StyleField field;
  final double value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final range = field.range;
    return SizedBox(
      width: 88,
      child: NumberField(
        value: value,
        min: range.min,
        max: range.max,
        step: range.step,
        decimalDigits: range.step < 1 ? 2 : (value % 1 == 0 ? 0 : 1),
        semanticLabel: field.label,
        onChanged: (next) {
          if (next != null && next.toDouble() != value) {
            onChanged(next.toDouble());
          }
        },
      ),
    );
  }
}

class _FractionControl extends StatelessWidget {
  const _FractionControl({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final StyleField field;
  final double value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 120,
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value.clamp(0, 1),
              divisions: 100,
              showDivisionMarks: false,
              semanticLabel: field.label,
              onChanged: (v) {
                final next = (v * 100).roundToDouble() / 100;
                if (next != value) onChanged(next);
              },
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.end,
              style: _noteStyle(theme).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Select<T>(
        value: value,
        placeholder: const Text('Same as light'),
        onChanged: (next) {
          if (next != null && next != value) onChanged(next);
        },
        options: [
          for (final MapEntry(:key, value: text) in options.entries)
            SelectOption(value: key, label: text),
        ],
      ),
    );
  }
}

/// A text role in one line that opens to its parts: size, line height,
/// weight, tracking and case.
class _TextRoleControl extends StatefulWidget {
  const _TextRoleControl({
    required this.label,
    required this.role,
    required this.onChanged,
  });

  final String label;
  final TextRole? role;
  final ValueChanged<Object?> onChanged;

  @override
  State<_TextRoleControl> createState() => _TextRoleControlState();
}

class _TextRoleControlState extends State<_TextRoleControl> {
  final _controller = PopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _weights = [300, 400, 500, 600, 700, 800];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = widget.role ?? const TextRole(fontSize: 14);
    final weight = role.fontWeight?.value ?? 400;
    String n(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';
    void set(TextRole next) {
      if (next != role) widget.onChanged(next);
    }

    TextRole copy({
      double? fontSize,
      double? height,
      int? weight,
      double? letterSpacing,
      bool? uppercase,
    }) => TextRole(
      fontSize: fontSize ?? role.fontSize,
      height: height ?? role.height,
      fontWeight: weight == null
          ? role.fontWeight
          : FontWeight.values.firstWhere((w) => w.value == weight),
      letterSpacing: letterSpacing ?? role.letterSpacing,
      uppercase: uppercase ?? role.uppercase,
    );

    Widget part(String label, Widget control) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _labelStyle(theme))),
          control,
        ],
      ),
    );

    return Popover(
      controller: _controller,
      padding: const EdgeInsets.all(10),
      builder: (context) => SizedBox(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            part(
              'Size',
              SizedBox(
                width: 96,
                child: NumberField(
                  value: role.fontSize,
                  min: 6,
                  max: 96,
                  step: .5,
                  decimalDigits: 1,
                  semanticLabel: '${widget.label} size',
                  onChanged: (v) =>
                      v == null ? null : set(copy(fontSize: v.toDouble())),
                ),
              ),
            ),
            part(
              'Line height',
              SizedBox(
                width: 96,
                child: NumberField(
                  value: role.height ?? 1.4,
                  min: .8,
                  max: 2.5,
                  step: .05,
                  decimalDigits: 2,
                  semanticLabel: '${widget.label} line height',
                  onChanged: (v) =>
                      v == null ? null : set(copy(height: v.toDouble())),
                ),
              ),
            ),
            part(
              'Weight',
              SizedBox(
                width: 96,
                child: Select<int>(
                  value: weight,
                  onChanged: (v) => v == null ? null : set(copy(weight: v)),
                  options: [
                    for (final w in _weights)
                      SelectOption(value: w, label: '$w'),
                  ],
                ),
              ),
            ),
            part(
              'Tracking',
              SizedBox(
                width: 96,
                child: NumberField(
                  value: role.letterSpacing ?? 0,
                  min: -2,
                  max: 4,
                  step: .05,
                  decimalDigits: 2,
                  semanticLabel: '${widget.label} tracking',
                  onChanged: (v) =>
                      v == null ? null : set(copy(letterSpacing: v.toDouble())),
                ),
              ),
            ),
            part(
              'Upper case',
              Semantics(
                label: '${widget.label} in upper case',
                child: Switch(
                  value: role.uppercase,
                  onChanged: (v) => set(copy(uppercase: v)),
                ),
              ),
            ),
          ],
        ),
      ),
      child: Button.outline(
        size: ButtonSize.sm,
        onPressed: _controller.toggle,
        child: Text('${n(role.fontSize)} / ${role.fontWeight?.value ?? 400}'),
      ),
    );
  }
}
