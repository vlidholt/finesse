// The example shows Material widgets beside una's through the SDK's own
// Material library, as `package:una/material.dart` does; Flutter
// deprecated it in 3.47 in favour of the `material_ui` package.
// ignore_for_file: deprecated_member_use

import 'package:example/docs/docs.dart' show CodeBlock;
import 'package:example/common/theme_editor/color_tokens.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/editor_rows.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/common/theme_editor/picker.dart';
import 'package:flutter/material.dart'
    hide Dialog, DialogTheme, Divider, IconButton, Theme, ThemeData, showDialog;
import 'package:flutter/services.dart';
import 'package:una/una.dart';

/// The theme customizer: a panel docked beside the app.
///
/// It edits the configuration the whole app is themed from: the component
/// library follows it. The panel itself does not: it renders as fixed dark chrome at an unscaled text size,
/// because a panel that followed the configuration becomes unreadable while
/// editing a light, menu-inverted or heavily scaled theme.
///
/// From the top: the look (a style) and whether it is drawn in Liquid
/// Glass, the colour and the neutral, then every other option, grouped
/// into sections that fold away.
class ThemeCustomizerPanel extends StatelessWidget {
  const ThemeCustomizerPanel({
    super.key,
    required this.config,
    required this.onChanged,
    this.brightness = Brightness.light,
    this.formFactor = FormFactor.desktop,
    this.showLeadingBorder = true,
    this.onClose,
  });

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  /// What the app is showing: the colours and the metrics the lists below
  /// edit are this brightness's and this form factor's.
  final Brightness brightness;
  final FormFactor formFactor;

  /// Drawn when the panel sits beside the app; dropped when it fills a narrow
  /// viewport and there is nothing to separate it from.
  final bool showLeadingBorder;

  /// When given, the panel opens with a title row and a close button that
  /// calls this. The shell passes it when the panel covers a narrow
  /// viewport, where nothing else on screen could close it.
  final VoidCallback? onClose;

  /// Width of the docked panel on a wide viewport.
  static const width = 300.0;

  /// Chrome, not content: a fixed dark palette at a fixed text size, so the
  /// panel stays readable whatever the configuration under it does.
  ///
  /// Built once. The factory bakes ~54 component themes, and this one never
  /// varies, so rebuilding it per panel build was pure cost.
  static final _chrome = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const GraphiteColorScheme.dark(),
    radius: const BorderRadius.all(Radius.circular(8)),
    // Pinned too: the panel is laid out against the compact Crisp
    // metrics, and the package default — Fluid — is roomier.
    style: StyleTokens.crisp,
    // The panel is the same chrome on every platform: no Liquid Glass
    // capsules among its rows on Apple ones.
    liquidGlass: const LiquidGlassTheme(mode: LiquidGlassMode.never),
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
            child: _Settings(
              config: config,
              onChanged: onChanged,
              brightness: brightness,
              formFactor: formFactor,
            ),
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
  look('Look'),
  color('Color'),
  fonts('Fonts'),
  shape('Shape'),
  glass('Glass'),
  layout('Layout'),
  menus('Menus'),
  preview('Preview'),
  all('All settings');

  const _SectionId(this.title);

  final String title;
}

class _Settings extends StatefulWidget {
  const _Settings({
    required this.config,
    required this.onChanged,
    required this.brightness,
    required this.formFactor,
  });

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;
  final Brightness brightness;
  final FormFactor formFactor;

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
    _SectionId.all,
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
          _section(_SectionId.look, [
            _LookGrid(config: config, onChanged: onChanged),
            // Auto draws Liquid Glass on iOS and macOS only; On shows it on
            // whatever this runs on. A way of looking at the theme, kept
            // whatever else changes.
            ThemeSegments<EditorLiquidGlass>(
              label: 'Liquid Glass',
              value: config.liquidGlass,
              options: [
                for (final m in EditorLiquidGlass.values)
                  PickerOption(value: m, label: m.label),
              ],
              onChanged: (v) => onChanged(config.copyWith(liquidGlass: v)),
            ),
          ]),
          _section(_SectionId.color, [
            _ColorRow(config: config, onChanged: onChanged),
            _NeutralRow(config: config, onChanged: onChanged),
            ThemePicker<ChartPreset>(
              label: 'Charts',
              value: config.charts,
              options: [
                for (final c in ChartPreset.values)
                  PickerOption(
                    value: c,
                    label: c.label,
                    swatches: c.palette.of(widget.brightness),
                  ),
              ],
              // Picking a palette starts the chart colours afresh.
              onChanged: (v) => onChanged(
                config.copyWith(
                  charts: v,
                  lightColors: config.lightColors.withoutCharts,
                  darkColors: config.darkColors.withoutCharts,
                ),
              ),
            ),
            ColorTokenList(
              config: config,
              brightness: widget.brightness,
              onChanged: onChanged,
            ),
          ]),
          _section(_SectionId.fonts, [
            _FontPicker(
              label: 'Font',
              icon: PhosphorIconsRegular.textT,
              value: config.fontTitle,
              onLoaded: (v) => onChanged(config.copyWith(fontTitle: v)),
            ),
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
          ]),
          _section(_SectionId.shape, [
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
              onChanged: (v) => onChanged(
                config.copyWith(
                  cardOpacity: () => v == tokens.cardOpacity ? null : v,
                ),
              ),
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
              onChanged: (v) => onChanged(
                config.copyWith(
                  barOpacity: () => v == tokens.barOpacity ? null : v,
                ),
              ),
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
              onChanged: (v) => onChanged(
                config.copyWith(
                  glassBlur: () => v == tokens.glassBlur ? null : v,
                ),
              ),
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
          // Every field of the style, for what the sections above do not
          // reach. Applied over them.
          _section(_SectionId.all, [
            StyleFieldList(
              config: config,
              formFactor: widget.formFactor,
              onChanged: onChanged,
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
          child: UnaGestureDetector(
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
          'your UnaApp.',
        ),
        semanticLabel: 'Generated theme code',
        style: const DialogTheme(
          constraints: BoxConstraints(maxWidth: 720),
        ),
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
        // The docs' own code block: dark, highlighted, in the code face,
        // scrolling inside the dialog rather than past the screen.
        child: SizedBox(
          width: 640,
          child: CodeBlock(
            code: snippet,
            maxHeight: MediaQuery.sizeOf(context).height * .6,
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

/// The four looks, two to a row: a style each, with a small picture of
/// its shapes in the current colours.
class _LookGrid extends StatelessWidget {
  const _LookGrid({required this.config, required this.onChanged});

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ((constraints.maxWidth - gap) / 2).floorToDouble();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final style in StylePreset.values)
              SizedBox(
                width: width,
                child: _LookTile(
                  style: style,
                  config: config.copyWith(style: style),
                  selected: config.style == style,
                  onTap: () => onChanged(config.copyWith(style: style)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LookTile extends StatefulWidget {
  const _LookTile({
    required this.style,
    required this.config,
    required this.selected,
    required this.onTap,
  });

  final StylePreset style;

  /// The configuration the tile's picture is drawn from.
  final ThemeEditorConfig config;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LookTile> createState() => _LookTileState();
}

class _LookTileState extends State<_LookTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final touch = theme.formFactor == FormFactor.mobile;
    return Semantics(
      button: true,
      selected: widget.selected,
      child: UnaGestureDetector(
        mouseCursor: SystemMouseCursors.click,
        behavior: HitTestBehavior.opaque,
        onTap: widget.selected ? null : widget.onTap,
        onHover: (v) => setState(() => hovered = v),
        child: Container(
          height: touch ? 48 : 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: hovered && !widget.selected ? colors.accent : colors.card,
            borderRadius: theme.radius,
            // The selected tile takes the foreground as its outline. Same
            // width either way, so selecting does not move the content.
            border: Border.all(
              color: widget.selected ? colors.foreground : colors.border,
            ),
          ),
          child: Row(
            children: [
              _LookSwatch(config: widget.config),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.style.label,
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

/// A look in 26 pixels: a page with a button on it, in the look's corner
/// shapes. Only the shape: drawn in the panel's own ink, not the theme's
/// colours, so four tiles side by side compare corners and nothing else.
class _LookSwatch extends StatelessWidget {
  const _LookSwatch({required this.config});

  final ThemeEditorConfig config;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme;
    final tokens = config.style.tokens;
    // Square stays square and a pill stays a pill; everything between is a
    // softened corner at this size.
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
        borderRadius: BorderRadius.circular(
          config.effectiveRadius == 0 ? 0 : 6,
        ),
        border: Border.all(color: ink.mutedForeground, width: 1.25),
      ),
      child: Container(
        width: 14,
        height: 10,
        decoration: BoxDecoration(
          color: ink.foreground,
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    );
  }
}

/// The colour the scheme is made from, picked from the palettes' swatches
/// or by hand. A built-in scheme's own colour gives that scheme; any other
/// is a seed for `ColorScheme.fromSeed`.
class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.config, required this.onChanged});

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = ColorPalette.of(config);
    final current = config.seed ?? config.colors.light.primary;
    return ThemeColorPicker(
      label: 'Color',
      value: current,
      valueLabel: palette?.label,
      current: current,
      swatches: [for (final p in ColorPalette.values) p.swatch],
      clearLabel: 'Default',
      // Back to the package default's.
      clearable: config.seed != null || config.colors != ColorSchemes.slate,
      onClear: () => onChanged(ColorPalette.slate.applyTo(config)),
      onChanged: (color) {
        if (color == null) return;
        // A swatch of a palette is that palette; a colour of its own a
        // seed. Colours picked by hand start afresh either way.
        for (final p in ColorPalette.values) {
          if (p.swatch == color) {
            onChanged(p.applyTo(config));
            return;
          }
        }
        onChanged(
          config.copyWith(
            seed: () => color,
            lightColors: const ColorEdits(),
            darkColors: const ColorEdits(),
          ),
        );
      },
    );
  }
}

/// The colour the greys lean towards: a preset, one picked by hand, or none
/// (they follow the colour).
class _NeutralRow extends StatelessWidget {
  const _NeutralRow({required this.config, required this.onChanged});

  final ThemeEditorConfig config;
  final ValueChanged<ThemeEditorConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final neutral = config.neutral;
    return ThemeColorPicker(
      label: 'Neutral',
      value: neutral,
      valueLabel: NeutralPreset.of(neutral)?.label,
      emptyLabel: 'Follows the color',
      current: neutral ?? config.colorScheme.mutedForeground,
      swatches: [for (final n in NeutralPreset.values) n.color],
      onChanged: (color) => onChanged(config.copyWith(neutral: () => color)),
    );
  }
}
