// The example shows Material widgets beside finesse's through the SDK's own
// Material library, as `package:finesse/material.dart` does; Flutter
// deprecated it in 3.47 in favour of the `material_ui` package.
// ignore_for_file: deprecated_member_use

import 'package:example/common/code_style.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/common/theme_editor/picker.dart';
import 'package:example/common/theme_editor/presets.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/material.dart'
    hide Dialog, Divider, IconButton, Theme, ThemeData, showDialog;
import 'package:flutter/services.dart';

/// The theme customizer: a panel docked beside the app.
///
/// It edits the configuration the whole app is themed from: the component
/// library follows it. The panel itself does not: it renders as fixed dark chrome at an unscaled text size,
/// because a panel that followed the configuration becomes unreadable while
/// editing a light, menu-inverted or heavily scaled theme.
///
/// From the top: the curated [ThemePreset]s, then every option one of them
/// sets, grouped into sections that fold away. Changing any option leaves
/// the preset, and the grid says so with a "Custom" tile.
class ThemeCustomizerPanel extends StatelessWidget {
  const ThemeCustomizerPanel({
    super.key,
    required this.config,
    required this.onChanged,
    this.showLeadingBorder = true,
    this.onClose,
  });

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  /// Drawn when the panel sits beside the app; dropped when it fills a narrow
  /// viewport and there is nothing to separate it from.
  final bool showLeadingBorder;

  /// When given, the panel opens with a title row and a close button that
  /// calls this. The shell passes it when the panel covers a narrow
  /// viewport, where nothing else on screen could close it.
  final VoidCallback? onClose;

  /// Width of the docked panel on a wide viewport.
  static const width = 272.0;

  /// Chrome, not content: a fixed dark palette at a fixed text size, so the
  /// panel stays readable whatever the configuration under it does.
  ///
  /// Built once. The factory bakes ~54 component themes, and this one never
  /// varies, so rebuilding it per panel build was pure cost.
  static final _chrome = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const NeutralColorScheme.dark(),
    radius: const BorderRadius.all(Radius.circular(8)),
    // Pinned too: the panel is laid out against shadcn's compact Nova
    // metrics, and the package default — Finesse — is roomier.
    style: StyleTokens.nova,
  );

  /// [_chrome] with touch-sized controls, for when the panel covers a phone.
  static final _touchChrome = _chrome.withFormFactor(FormFactor.mobile);

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      // The panel has a close button exactly when it covers the viewport,
      // which it only does on a narrow one.
      data: onClose == null ? _chrome : _touchChrome,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.noScaling),
        child: Builder(builder: _buildPanel),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final theme = Theme.of(context);
    final safeArea = MediaQuery.paddingOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: showLeadingBorder
            ? BorderDirectional(
                start: BorderSide(color: theme.colorScheme.border),
              )
            : null,
      ),
      child: Column(
        children: [
          if (onClose != null)
            Padding(
              padding: EdgeInsets.fromLTRB(14, 8 + safeArea.top, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Theme editor', style: theme.textTheme.large),
                  ),
                  IconButton.ghost(
                    icon: const PhosphorIcon(PhosphorIconsRegular.x),
                    semanticLabel: 'Close the theme editor',
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _Settings(config: config, onChanged: onChanged),
          ),
          const Divider(margin: EdgeInsets.zero),
          Padding(
            padding: EdgeInsets.only(
              bottom: onClose == null ? 0 : safeArea.bottom,
            ),
            child: _Actions(config: config, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

/// The panel's sections, in the order they are listed.
enum _SectionId {
  theme('Theme'),
  color('Color'),
  fonts('Fonts'),
  shape('Shape'),
  glass('Glass'),
  layout('Layout'),
  menus('Menus'),
  preview('Preview');

  const _SectionId(this.title);

  final String title;
}

class _Settings extends StatefulWidget {
  const _Settings({required this.config, required this.onChanged});

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  static const _sameAsBody = 'Same as body';

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  /// The sections folded away. The finer controls start closed, so the
  /// panel opens on the choices most people make — a theme, its colours,
  /// its fonts — without hiding that the rest exist.
  final _collapsed = <_SectionId>{
    _SectionId.glass,
    _SectionId.layout,
    _SectionId.menus,
  };

  ThemeEditorConfig get config => widget.config;

  void _toggle(_SectionId id) => setState(() {
    if (!_collapsed.remove(id)) _collapsed.add(id);
  });

  Widget _section(_SectionId id, List<Widget> children) => _Section(
    title: id.title,
    expanded: !_collapsed.contains(id),
    onToggle: () => _toggle(id),
    children: children,
  );

  static String _percent(double value) => '${(value * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final onChanged = widget.onChanged;
    final tokens = config.style.tokens;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _section(_SectionId.theme, [
            _PresetGrid(config: config, onChanged: onChanged),
          ]),
          _section(_SectionId.color, [
            ThemePicker<BaseColor>(
              label: 'Base Color',
              value: config.baseColor,
              options: [
                for (final b in BaseColor.values)
                  PickerOption(value: b, label: b.label, swatch: b.swatch),
              ],
              onChanged: (v) => onChanged(config.copyWith(baseColor: v)),
            ),
            ThemePicker<AccentColor>(
              label: 'Accent',
              value: config.accentColor,
              options: [
                for (final accent in AccentColor.values)
                  PickerOption(
                    value: accent,
                    label: accent.label,
                    // "Base" inherits the base colour's own hue.
                    swatch: accent.swatch(Brightness.light, config.baseColor),
                  ),
              ],
              onChanged: (v) => onChanged(config.copyWith(accentColor: v)),
            ),
          ]),
          _section(_SectionId.fonts, [
            _FontPicker(
              label: 'Heading',
              icon: PhosphorIconsRegular.textH,
              value: config.headingFontTitle ?? _Settings._sameAsBody,
              includeSameAsBody: true,
              onLoaded: (v) => onChanged(
                v == _Settings._sameAsBody
                    ? config.copyWith(clearHeadingFont: true)
                    : config.copyWith(headingFontTitle: v),
              ),
            ),
            _FontPicker(
              label: 'Font',
              icon: PhosphorIconsRegular.textT,
              value: config.fontTitle,
              onLoaded: (v) => onChanged(config.copyWith(fontTitle: v)),
            ),
          ]),
          _section(_SectionId.shape, [
            ThemePicker<StylePreset>(
              label: 'Style',
              icon: PhosphorIconsRegular.shapes,
              value: config.style,
              options: [
                for (final s in StylePreset.values)
                  PickerOption(value: s, label: s.label),
              ],
              onChanged: (v) => onChanged(config.copyWith(style: v)),
            ),
            ThemePicker<RadiusPreset>(
              label: 'Radius',
              icon: PhosphorIconsRegular.square,
              value: config.radius,
              options: [
                for (final r in RadiusPreset.values)
                  PickerOption(value: r, label: r.label),
              ],
              onChanged: (v) => onChanged(
                config.copyWith(radius: v, clearCustomRadius: true),
              ),
            ),
            ThemeSegments<FocusRingPlacement>(
              label: 'Focus Ring',
              value: config.focusRing,
              options: [
                for (final f in FocusRingPlacement.values)
                  PickerOption(value: f, label: f.label),
              ],
              onChanged: (v) => onChanged(config.copyWith(focusRing: v)),
            ),
          ]),
          _section(_SectionId.glass, [
            ThemeSlider(
              label: 'Card Opacity',
              value: config.effectiveCardOpacity,
              min: .4,
              max: 1,
              format: _percent,
              onChanged: (v) =>
                  onChanged(config.copyWith(cardOpacity: () => v)),
              onReset: config.cardOpacity == null
                  ? null
                  : () => onChanged(config.copyWith(cardOpacity: () => null)),
            ),
            ThemeSwitch(
              label: 'Card Blur',
              // An opaque card has nothing behind it to blur; the switch is
              // locked off to say so.
              value: config.cardsAreTranslucent && config.effectiveCardBlur,
              enabled: config.cardsAreTranslucent,
              onChanged: (v) => onChanged(
                // Back on the style's own value is not an override.
                config.copyWith(
                  cardBlur: () => v == tokens.cardBlur ? null : v,
                ),
              ),
            ),
            ThemeSlider(
              label: 'Bar Opacity',
              value: config.effectiveBarOpacity,
              min: .4,
              max: 1,
              format: _percent,
              onChanged: (v) => onChanged(config.copyWith(barOpacity: () => v)),
              onReset: config.barOpacity == null
                  ? null
                  : () => onChanged(config.copyWith(barOpacity: () => null)),
            ),
            ThemeSlider(
              label: 'Blur Strength',
              value: config.effectiveGlassBlur,
              min: 0,
              max: 48,
              step: 1,
              format: (v) => v.round().toString(),
              onChanged: (v) => onChanged(config.copyWith(glassBlur: () => v)),
              onReset: config.glassBlur == null
                  ? null
                  : () => onChanged(config.copyWith(glassBlur: () => null)),
            ),
          ]),
          _section(_SectionId.layout, [
            ThemePicker<Density>(
              label: 'Density',
              icon: PhosphorIconsRegular.arrowsInLineVertical,
              value: config.density,
              options: [
                for (final d in Density.values)
                  PickerOption(value: d, label: d.label),
              ],
              onChanged: (v) => onChanged(config.copyWith(density: v)),
            ),
            ThemeSlider(
              label: 'Page Margin',
              value: config.pageMarginScale,
              min: 0,
              max: 2,
              step: .1,
              format: _percent,
              onChanged: (v) => onChanged(config.copyWith(pageMarginScale: v)),
              onReset: config.pageMarginScale == 1
                  ? null
                  : () => onChanged(config.copyWith(pageMarginScale: 1)),
            ),
            ThemeSlider(
              label: 'Card Padding',
              value: config.cardPaddingScale,
              min: .5,
              max: 2,
              step: .1,
              format: _percent,
              onChanged: (v) => onChanged(config.copyWith(cardPaddingScale: v)),
              onReset: config.cardPaddingScale == 1
                  ? null
                  : () => onChanged(config.copyWith(cardPaddingScale: 1)),
            ),
            ThemeSegments<bool>(
              label: 'Bottom Bar',
              value: config.effectiveBottomBarFloating,
              options: const [
                PickerOption(value: true, label: 'Floating'),
                PickerOption(value: false, label: 'Docked'),
              ],
              onChanged: (v) => onChanged(
                config.copyWith(
                  // Back on the style's own value is not an override.
                  bottomBarFloating: () =>
                      v == tokens.bottomNavigationFloating ? null : v,
                ),
              ),
            ),
          ]),
          _section(_SectionId.menus, [
            // One row, two radio groups — shadcn's Menu picker shape.
            ThemeGroupPicker(
              label: 'Menu',
              icon: PhosphorIconsRegular.list,
              value: '${config.menuColor.label} / ${config.menuFinish.label}',
              groups: [
                PickerGroup(
                  label: 'Color',
                  options: [for (final m in MenuSurfaceColor.values) m.label],
                  selected: config.menuColor.label,
                  onSelected: (v) => onChanged(
                    config.copyWith(
                      menuColor: MenuSurfaceColor.values.firstWhere(
                        (m) => m.label == v,
                      ),
                    ),
                  ),
                ),
                PickerGroup(
                  label: 'Surface',
                  options: [for (final m in MenuSurfaceFinish.values) m.label],
                  selected: config.menuFinish.label,
                  onSelected: (v) => onChanged(
                    config.copyWith(
                      menuFinish: MenuSurfaceFinish.values.firstWhere(
                        (m) => m.label == v,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ThemeSegments<EditorMenuAccent>(
              label: 'Menu Accent',
              // shadcn's translucent finish highlights with a foreground
              // wash, so the accent has no effect there; the picker is
              // locked to make that visible, as shadcn's editor does. A
              // style's own glass keeps the accent.
              value: config.menuFinish != MenuSurfaceFinish.translucent
                  ? config.menuAccent
                  : EditorMenuAccent.subtle,
              enabled: config.menuFinish != MenuSurfaceFinish.translucent,
              options: [
                for (final m in EditorMenuAccent.values)
                  PickerOption(value: m, label: m.label),
              ],
              onChanged: (v) => onChanged(config.copyWith(menuAccent: v)),
            ),
          ]),
          // How the theme is being looked at, not part of it: neither
          // leaves a preset, and neither is exported as theme code.
          _section(_SectionId.preview, [
            ThemeSegments<EditorFormFactor>(
              label: 'Form Factor',
              value: config.formFactor,
              options: [
                for (final f in EditorFormFactor.values)
                  PickerOption(value: f, label: f.label),
              ],
              onChanged: (v) => onChanged(config.copyWith(formFactor: v)),
            ),
            ThemeSlider(
              label: 'Text Scale',
              value: config.textScale,
              min: .8,
              max: 1.6,
              step: .05,
              format: _percent,
              onChanged: (v) => onChanged(config.copyWith(textScale: v)),
              onReset: config.textScale == 1
                  ? null
                  : () => onChanged(config.copyWith(textScale: 1)),
            ),
          ]),
        ],
      ),
    );
  }
}

/// A titled group of settings that folds away.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final touch = theme.formFactor == FormFactor.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: FinesseGestureDetector(
            mouseCursor: SystemMouseCursors.click,
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: SizedBox(
              height: touch ? 44 : 36,
              child: Row(
                children: [
                  Expanded(
                    // Upper case, tracked out: a section title, not one more
                    // setting in the list under it.
                    child: Text(
                      title.toUpperCase(),
                      style: theme.textTheme.small.copyWith(
                        fontSize: 11,
                        height: 16 / 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .88,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  PhosphorIcon(
                    expanded
                        ? PhosphorIconsRegular.caretDown
                        : PhosphorIconsRegular.caretRight,
                    size: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: children,
            ),
          ),
        const Divider(margin: EdgeInsets.zero),
      ],
    );
  }
}

/// The presets, two to a row, with a "Custom" tile once the configuration
/// has left them.
class _PresetGrid extends StatefulWidget {
  const _PresetGrid({required this.config, required this.onChanged});

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  @override
  State<_PresetGrid> createState() => _PresetGridState();
}

class _PresetGridState extends State<_PresetGrid> {
  /// The preset whose fonts are being fetched. A newer pick supersedes it.
  ThemePreset? _loading;

  /// Applies [preset] once its fonts are in, for the same reason the font
  /// pickers wait: applying first lays the whole app out in the fallback
  /// face and again when the real one arrives.
  Future<void> _select(ThemePreset preset) async {
    setState(() => _loading = preset);
    await Future.wait([for (final font in preset.config.fonts) font.load()]);
    if (!mounted || _loading != preset) return;
    setState(() => _loading = null);
    widget.onChanged(preset.applyTo(widget.config));
  }

  @override
  Widget build(BuildContext context) {
    final current = ThemePreset.of(widget.config);
    const gap = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = ((constraints.maxWidth - gap) / 2).floorToDouble();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final preset in ThemePreset.values)
              SizedBox(
                width: tileWidth,
                child: _PresetTile(
                  label: preset.label,
                  config: preset.config,
                  selected: preset == current && _loading == null,
                  busy: preset == _loading,
                  onTap: () => _select(preset),
                ),
              ),
            if (current == null)
              SizedBox(
                width: tileWidth,
                child: _PresetTile(
                  label: 'Custom',
                  config: widget.config,
                  selected: _loading == null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PresetTile extends StatefulWidget {
  const _PresetTile({
    required this.label,
    required this.config,
    required this.selected,
    this.busy = false,
    this.onTap,
  });

  final String label;

  /// The configuration the tile's swatch is drawn from.
  final ThemeEditorConfig config;
  final bool selected;
  final bool busy;

  /// Null for the "Custom" tile, which is a state and not a choice.
  final VoidCallback? onTap;

  @override
  State<_PresetTile> createState() => _PresetTileState();
}

class _PresetTileState extends State<_PresetTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final touch = theme.formFactor == FormFactor.mobile;

    return Semantics(
      button: widget.onTap != null,
      selected: widget.selected,
      child: FinesseGestureDetector(
        mouseCursor: widget.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        behavior: HitTestBehavior.opaque,
        onTap: widget.selected ? null : widget.onTap,
        onHover: (v) => setState(() => hovered = v),
        child: Container(
          height: touch ? 48 : 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: hovered && widget.onTap != null && !widget.selected
                ? colors.accent
                : colors.card,
            borderRadius: theme.radius,
            // The selected tile takes the foreground as its outline. Same
            // width either way, so selecting does not move the content.
            border: Border.all(
              color: widget.selected ? colors.foreground : colors.border,
            ),
          ),
          child: Row(
            children: [
              if (widget.busy)
                SizedBox.square(
                  dimension: 26,
                  child: Center(
                    child: Spinner(size: 15, color: colors.mutedForeground),
                  ),
                )
              else
                _PresetSwatch(config: widget.config),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.small.copyWith(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A preset in 26 pixels: its page colour, with a button in its primary
/// colour and its corner shape.
class _PresetSwatch extends StatelessWidget {
  const _PresetSwatch({required this.config});

  final ThemeEditorConfig config;

  @override
  Widget build(BuildContext context) {
    final scheme = config.copyWith(brightness: Brightness.light).colorScheme;
    // Square stays square and a pill stays a pill; everything between is a
    // softened corner at this size.
    final tokens = config.style.tokens;
    final buttonRadius = config.effectiveRadius == 0
        ? 0.0
        : tokens.buttonRadius == RadiusToken.xl4
        ? 5.0
        : 2.5;

    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.background,
        borderRadius: BorderRadius.circular(
          config.effectiveRadius == 0 ? 0 : 6,
        ),
        border: Border.all(color: Theme.of(context).colorScheme.border),
      ),
      child: Container(
        width: 14,
        height: 10,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.config, required this.onChanged});

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        spacing: 8,
        children: [
          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () => _copy(context, config),
              leading: const PhosphorIcon(PhosphorIconsRegular.clipboard),
              child: const Text('Copy Theme'),
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Button.outline(
                  onPressed: () => _showCode(context, config),
                  leading: const PhosphorIcon(PhosphorIconsRegular.code),
                  child: const Text('Code'),
                ),
              ),
              Expanded(
                child: Button.outline(
                  // All the way back: the Original preset, viewed the default
                  // way.
                  onPressed: () => onChanged(const ThemeEditorConfig()),
                  leading: const PhosphorIcon(
                    PhosphorIconsRegular.arrowCounterClockwise,
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, ThemeEditorConfig config) async {
    await Clipboard.setData(ClipboardData(text: config.toAppSnippet()));
    if (!context.mounted) return;
    Toaster.of(context).show(
      const Toast(
        variant: ToastVariant.success,
        title: Text('Theme copied to clipboard'),
      ),
    );
  }

  void _showCode(BuildContext context, ThemeEditorConfig config) {
    final snippet = config.toAppSnippet();
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        title: const Text('Theme code'),
        description: const Text(
          'The light and dark themes of this configuration. Pass them to '
          'your FinesseApp.',
        ),
        semanticLabel: 'Generated theme code',
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          Button(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: snippet));
              if (context.mounted) Navigator.of(context).pop();
            },
            leading: const PhosphorIcon(PhosphorIconsRegular.copy),
            child: const Text('Copy'),
          ),
        ],
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SelectableText(
            snippet,
            style: Theme.of(context).textTheme.small.merge(
              CodeStyle.compact,
            ),
          ),
        ),
      ),
    );
  }
}

/// A font [ThemePicker] that fetches the picked font before applying it.
///
/// Applying first and loading after would lay every control out in the
/// fallback face and then again when the real one arrives, so the text jumps
/// twice.
///
/// Each option is listed in its own face, and that preview is fetched when
/// the option's row is built — which the picker's list only does for rows in
/// view. Nothing is fetched by opening the panel.
class _FontPicker extends StatefulWidget {
  const _FontPicker({
    required this.label,
    required this.icon,
    required this.value,
    required this.onLoaded,
    this.includeSameAsBody = false,
  });

  final String label;
  final IconData icon;
  final String value;
  final ValueChanged<String> onLoaded;
  final bool includeSameAsBody;

  @override
  State<_FontPicker> createState() => _FontPickerState();
}

class _FontPickerState extends State<_FontPicker> {
  /// The title being loaded, if any. A newer pick supersedes an older one.
  String? loading;

  Future<void> pick(String title) async {
    if (title == _Settings._sameAsBody) {
      setState(() => loading = null);
      widget.onLoaded(title);
      return;
    }
    setState(() => loading = title);
    await EditorFont.byTitle(title).load();
    if (!mounted || loading != title) return;
    setState(() => loading = null);
    widget.onLoaded(title);
  }

  @override
  Widget build(BuildContext context) {
    return ThemePicker<String>(
      label: widget.label,
      icon: widget.icon,
      busy: loading != null,
      value: loading ?? widget.value,
      options: [
        if (widget.includeSameAsBody)
          const PickerOption(
            value: _Settings._sameAsBody,
            label: _Settings._sameAsBody,
          ),
        for (final f in EditorFont.all)
          PickerOption(
            value: f.title,
            label: f.title,
            // A tear-off, not a call: the row calls it when it is built.
            labelStyleBuilder: f.previewStyle,
          ),
      ],
      onChanged: pick,
    );
  }
}
