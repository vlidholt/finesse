import 'package:finesse/src/theme/color_scheme/accent.dart';
import 'package:finesse/src/theme/color_scheme/neutral.dart';
import 'package:finesse/src/theme/color_scheme/stone.dart';
import 'package:finesse/src/theme/color_scheme/teal.dart';
import 'package:finesse/src/theme/color_scheme/zinc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The colour tokens of a theme, one field per shadcn/ui CSS variable.
///
/// A scheme bundles a neutral base palette and the hue-carrying tokens of an
/// accent. Use one of the shipped schemes, such as
/// [NeutralColorScheme.light], and [applyAccentScheme] to change its hue.
/// The `--chart-*` and `--sidebar-*` tokens are optional and fall back to the
/// closest core token.
@immutable
class ColorScheme {
  /// Creates a colour scheme from explicit colours.
  ///
  /// Set [canMerge] to false so that merging this scheme into another one
  /// returns it unchanged.
  const ColorScheme({
    bool canMerge = true,
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.selection,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? sidebar,
    Color? sidebarForeground,
    Color? sidebarPrimary,
    Color? sidebarPrimaryForeground,
    Color? sidebarAccent,
    Color? sidebarAccentForeground,
    Color? sidebarBorder,
    Color? sidebarRing,
    Color? foregroundSubtle,
    Color? tint,
    Color? tintForeground,
    Color? success,
    Color? successMuted,
    Color? warning,
    Color? borderStrong,
    Color? accentBorder,
    Color? bar,
    this.custom = const {},
  }) : _canMerge = canMerge,
       _chart1 = chart1,
       _chart2 = chart2,
       _chart3 = chart3,
       _chart4 = chart4,
       _chart5 = chart5,
       _sidebar = sidebar,
       _sidebarForeground = sidebarForeground,
       _sidebarPrimary = sidebarPrimary,
       _sidebarPrimaryForeground = sidebarPrimaryForeground,
       _sidebarAccent = sidebarAccent,
       _sidebarAccentForeground = sidebarAccentForeground,
       _sidebarBorder = sidebarBorder,
       _sidebarRing = sidebarRing,
       _foregroundSubtle = foregroundSubtle,
       _tint = tint,
       _tintForeground = tintForeground,
       _success = success,
       _successMuted = successMuted,
       _warning = warning,
       _borderStrong = borderStrong,
       _accentBorder = accentBorder,
       _bar = bar;

  /// Returns the light or dark scheme called [name]: `teal`, `neutral`,
  /// `stone` or `zinc`.
  ///
  /// Throws an [Exception] for an unknown name.
  factory ColorScheme.fromName(
    String name, {
    Brightness brightness = Brightness.light,
  }) {
    return switch (name) {
      'teal' =>
        brightness == Brightness.light
            ? const TealColorScheme.light()
            : const TealColorScheme.dark(),
      'neutral' =>
        brightness == Brightness.light
            ? const NeutralColorScheme.light()
            : const NeutralColorScheme.dark(),
      'stone' =>
        brightness == Brightness.light
            ? const StoneColorScheme.light()
            : const StoneColorScheme.dark(),
      'zinc' =>
        brightness == Brightness.light
            ? const ZincColorScheme.light()
            : const ZincColorScheme.dark(),
      _ => throw Exception('Invalid color scheme name'),
    };
  }

  final bool _canMerge;

  /// Whether this scheme combines with the one it is merged into.
  ///
  /// When false, `other.merge(this)` returns this scheme unchanged.
  bool get canMerge => _canMerge;

  /// The page background, `--background`.
  final Color background;

  /// The default text and icon colour, `--foreground`.
  final Color foreground;

  /// The card surface, `--card`.
  final Color card;

  /// The text and icon colour on [card], `--card-foreground`.
  final Color cardForeground;

  /// The surface of popovers, menus and tooltips, `--popover`.
  final Color popover;

  /// The text and icon colour on [popover], `--popover-foreground`.
  final Color popoverForeground;

  /// The main brand colour, `--primary`. Fills primary buttons, checked
  /// controls and badges.
  final Color primary;

  /// The text and icon colour on [primary], `--primary-foreground`.
  final Color primaryForeground;

  /// The colour of secondary buttons and badges, `--secondary`.
  final Color secondary;

  /// The text and icon colour on [secondary], `--secondary-foreground`.
  final Color secondaryForeground;

  /// A low-contrast surface for tracks, skeletons and hovered rows, `--muted`.
  final Color muted;

  /// Low-contrast text such as descriptions and placeholders,
  /// `--muted-foreground`.
  final Color mutedForeground;

  /// The highlight of hovered and focused menu rows, `--accent`.
  final Color accent;

  /// The text and icon colour on [accent], `--accent-foreground`.
  final Color accentForeground;

  /// The colour of destructive actions and errors, `--destructive`.
  final Color destructive;

  /// The text and icon colour on [destructive], `--destructive-foreground`.
  final Color destructiveForeground;

  /// The hairline colour of separators and surfaces, `--border`.
  final Color border;

  /// The outline colour of fields, checkboxes, radios and OTP slots, `--input`.
  final Color input;

  /// The focus ring colour, `--ring`.
  final Color ring;

  /// The background of selected text.
  final Color selection;

  /// Extra colours an app defines on top of the shadcn/ui tokens, by name.
  ///
  /// [lerp] and [merge] carry them along. Empty by default.
  final Map<String, Color> custom;

  // shadcn/ui's `--chart-1`..`--chart-5` and `--sidebar-*` tokens.
  //
  // Stored nullable and resolved through the getters below so that a scheme
  // a caller wrote by hand keeps compiling. A null token falls back to the
  // closest existing one, which is what shadcn's own neutral themes do anyway.
  final Color? _chart1;
  final Color? _chart2;
  final Color? _chart3;
  final Color? _chart4;
  final Color? _chart5;
  final Color? _sidebar;
  final Color? _sidebarForeground;
  final Color? _sidebarPrimary;
  final Color? _sidebarPrimaryForeground;
  final Color? _sidebarAccent;
  final Color? _sidebarAccentForeground;
  final Color? _sidebarBorder;
  final Color? _sidebarRing;
  final Color? _foregroundSubtle;
  final Color? _tint;
  final Color? _tintForeground;
  final Color? _success;
  final Color? _successMuted;
  final Color? _warning;
  final Color? _borderStrong;
  final Color? _accentBorder;
  final Color? _bar;

  /// The first categorical chart colour.
  ///
  /// Defaults to [primary]; the remaining four step towards [mutedForeground]
  /// so an unspecified scheme still yields a usable, ordered ramp.
  Color get chart1 => _chart1 ?? primary;

  /// The second chart colour, `--chart-2`. Defaults to a quarter of the way
  /// from [primary] to [mutedForeground].
  Color get chart2 => _chart2 ?? Color.lerp(primary, mutedForeground, .25)!;

  /// The third chart colour, `--chart-3`. Defaults to halfway between [primary]
  /// and [mutedForeground].
  Color get chart3 => _chart3 ?? Color.lerp(primary, mutedForeground, .5)!;

  /// The fourth chart colour, `--chart-4`. Defaults to three quarters of the
  /// way from [primary] to [mutedForeground].
  Color get chart4 => _chart4 ?? Color.lerp(primary, mutedForeground, .75)!;

  /// The fifth chart colour, `--chart-5`. Defaults to [mutedForeground].
  Color get chart5 => _chart5 ?? mutedForeground;

  /// The chart ramp in order, handy for feeding a series list.
  List<Color> get charts => [chart1, chart2, chart3, chart4, chart5];

  /// The sidebar surface. Defaults to [card].
  Color get sidebar => _sidebar ?? card;

  /// The text and icon colour on [sidebar], `--sidebar-foreground`. Defaults to
  /// [cardForeground].
  Color get sidebarForeground => _sidebarForeground ?? cardForeground;

  /// The sidebar's primary colour, `--sidebar-primary`. Defaults to [primary].
  Color get sidebarPrimary => _sidebarPrimary ?? primary;

  /// The text and icon colour on [sidebarPrimary],
  /// `--sidebar-primary-foreground`. Defaults to [primaryForeground].
  Color get sidebarPrimaryForeground =>
      _sidebarPrimaryForeground ?? primaryForeground;

  /// The highlight of hovered sidebar items, `--sidebar-accent`. Defaults to
  /// [accent].
  Color get sidebarAccent => _sidebarAccent ?? accent;

  /// The text and icon colour on [sidebarAccent],
  /// `--sidebar-accent-foreground`. Defaults to [accentForeground].
  Color get sidebarAccentForeground =>
      _sidebarAccentForeground ?? accentForeground;

  /// The sidebar's hairline colour, `--sidebar-border`. Defaults to [border].
  Color get sidebarBorder => _sidebarBorder ?? border;

  /// The focus ring colour inside the sidebar, `--sidebar-ring`. Defaults to
  /// [ring].
  Color get sidebarRing => _sidebarRing ?? ring;

  /// Text one step quieter than [foreground] and one louder than
  /// [mutedForeground]: chip labels, ghost button labels, secondary lines.
  ///
  /// Falls back to a mix of the two.
  Color get foregroundSubtle =>
      _foregroundSubtle ?? Color.lerp(foreground, mutedForeground, .5)!;

  /// The brand colour for things drawn directly on a surface: the selected
  /// navigation icon, links, progress fills, a liked heart.
  ///
  /// [primary] fills buttons and has to carry [primaryForeground] text in both
  /// brightnesses; [tint] has to read against the page, so a dark scheme
  /// usually makes it lighter than its [primary]. Falls back to [primary].
  Color get tint => _tint ?? primary;

  /// The colour of content on a [tint] fill. Falls back to
  /// [primaryForeground].
  Color get tintForeground => _tintForeground ?? primaryForeground;

  /// The colour of positive status text and icons.
  Color get success => _success ?? const Color(0xff15803d);

  /// The soft fill behind [success] content. Falls back to a 12% wash of
  /// [success].
  Color get successMuted => _successMuted ?? success.withValues(alpha: .12);

  /// The colour of cautionary status text and icons.
  Color get warning => _warning ?? const Color(0xffb45309);

  /// A hairline one step stronger than [border], for controls that sit on a
  /// surface of nearly the same colour: outline buttons, key caps. Falls back
  /// to [input].
  Color get borderStrong => _borderStrong ?? input;

  /// The outline of a selected, [accent]-filled control such as a chip. Falls
  /// back to a third of [tint].
  Color get accentBorder => _accentBorder ?? tint.withValues(alpha: .32);

  /// The colour of app and navigation bars, before the style's bar opacity is
  /// applied. Falls back to [card].
  Color get bar => _bar ?? card;

  /// Linearly interpolates between [a] and [b] by [t].
  ///
  /// A custom colour that only one scheme defines is interpolated against the
  /// other scheme's [foreground]. An optional token that only one scheme
  /// states is interpolated against the other scheme's fallback for it; one
  /// that neither states stays unset, so it keeps following the token it
  /// falls back to.
  static ColorScheme lerp(
    ColorScheme a,
    ColorScheme b,
    double t,
  ) {
    // `Color.lerp(null, colour, t)` fades the colour in from transparent,
    // which is not what an unset token means: it means "the fallback". So a
    // token only one side states is lerped between the two *resolved*
    // colours.
    Color? optional(Color? x, Color? y, Color Function(ColorScheme) resolved) {
      if (x == null && y == null) return null;
      return Color.lerp(x ?? resolved(a), y ?? resolved(b), t);
    }

    return ColorScheme(
      canMerge: t < 0.5 ? a.canMerge : b.canMerge,
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      card: Color.lerp(a.card, b.card, t)!,
      cardForeground: Color.lerp(a.cardForeground, b.cardForeground, t)!,
      popover: Color.lerp(a.popover, b.popover, t)!,
      popoverForeground: Color.lerp(
        a.popoverForeground,
        b.popoverForeground,
        t,
      )!,
      primary: Color.lerp(a.primary, b.primary, t)!,
      primaryForeground: Color.lerp(
        a.primaryForeground,
        b.primaryForeground,
        t,
      )!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      secondaryForeground: Color.lerp(
        a.secondaryForeground,
        b.secondaryForeground,
        t,
      )!,
      muted: Color.lerp(a.muted, b.muted, t)!,
      mutedForeground: Color.lerp(a.mutedForeground, b.mutedForeground, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      accentForeground: Color.lerp(a.accentForeground, b.accentForeground, t)!,
      destructive: Color.lerp(a.destructive, b.destructive, t)!,
      destructiveForeground: Color.lerp(
        a.destructiveForeground,
        b.destructiveForeground,
        t,
      )!,
      border: Color.lerp(a.border, b.border, t)!,
      input: Color.lerp(a.input, b.input, t)!,
      ring: Color.lerp(a.ring, b.ring, t)!,
      selection: Color.lerp(a.selection, b.selection, t)!,
      chart1: optional(a._chart1, b._chart1, (s) => s.chart1),
      chart2: optional(a._chart2, b._chart2, (s) => s.chart2),
      chart3: optional(a._chart3, b._chart3, (s) => s.chart3),
      chart4: optional(a._chart4, b._chart4, (s) => s.chart4),
      chart5: optional(a._chart5, b._chart5, (s) => s.chart5),
      sidebar: optional(a._sidebar, b._sidebar, (s) => s.sidebar),
      sidebarForeground: optional(
        a._sidebarForeground,
        b._sidebarForeground,
        (s) => s.sidebarForeground,
      ),
      sidebarPrimary: optional(
        a._sidebarPrimary,
        b._sidebarPrimary,
        (s) => s.sidebarPrimary,
      ),
      sidebarPrimaryForeground: optional(
        a._sidebarPrimaryForeground,
        b._sidebarPrimaryForeground,
        (s) => s.sidebarPrimaryForeground,
      ),
      sidebarAccent: optional(
        a._sidebarAccent,
        b._sidebarAccent,
        (s) => s.sidebarAccent,
      ),
      sidebarAccentForeground: optional(
        a._sidebarAccentForeground,
        b._sidebarAccentForeground,
        (s) => s.sidebarAccentForeground,
      ),
      sidebarBorder: optional(
        a._sidebarBorder,
        b._sidebarBorder,
        (s) => s.sidebarBorder,
      ),
      sidebarRing: optional(
        a._sidebarRing,
        b._sidebarRing,
        (s) => s.sidebarRing,
      ),
      foregroundSubtle: optional(
        a._foregroundSubtle,
        b._foregroundSubtle,
        (s) => s.foregroundSubtle,
      ),
      tint: optional(a._tint, b._tint, (s) => s.tint),
      tintForeground: optional(
        a._tintForeground,
        b._tintForeground,
        (s) => s.tintForeground,
      ),
      success: optional(a._success, b._success, (s) => s.success),
      successMuted: optional(
        a._successMuted,
        b._successMuted,
        (s) => s.successMuted,
      ),
      warning: optional(a._warning, b._warning, (s) => s.warning),
      borderStrong: optional(
        a._borderStrong,
        b._borderStrong,
        (s) => s.borderStrong,
      ),
      accentBorder: optional(
        a._accentBorder,
        b._accentBorder,
        (s) => s.accentBorder,
      ),
      bar: optional(a._bar, b._bar, (s) => s.bar),
      custom: {
        for (final key in {...a.custom.keys, ...b.custom.keys})
          key: Color.lerp(
            a.custom[key] ?? a.foreground,
            b.custom[key] ?? b.foreground,
            t,
          )!,
      },
    );
  }

  /// Creates a copy of this [ColorScheme] but with the given fields
  /// replaced with the new values.
  ColorScheme copyWith({
    bool? canMerge,
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? destructiveForeground,
    Color? border,
    Color? input,
    Color? ring,
    Color? selection,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? sidebar,
    Color? sidebarForeground,
    Color? sidebarPrimary,
    Color? sidebarPrimaryForeground,
    Color? sidebarAccent,
    Color? sidebarAccentForeground,
    Color? sidebarBorder,
    Color? sidebarRing,
    Color? foregroundSubtle,
    Color? tint,
    Color? tintForeground,
    Color? success,
    Color? successMuted,
    Color? warning,
    Color? borderStrong,
    Color? accentBorder,
    Color? bar,
    Map<String, Color>? custom,
  }) {
    return ColorScheme(
      canMerge: canMerge ?? this.canMerge,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      destructiveForeground:
          destructiveForeground ?? this.destructiveForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
      selection: selection ?? this.selection,
      chart1: chart1 ?? _chart1,
      chart2: chart2 ?? _chart2,
      chart3: chart3 ?? _chart3,
      chart4: chart4 ?? _chart4,
      chart5: chart5 ?? _chart5,
      sidebar: sidebar ?? _sidebar,
      sidebarForeground: sidebarForeground ?? _sidebarForeground,
      sidebarPrimary: sidebarPrimary ?? _sidebarPrimary,
      sidebarPrimaryForeground:
          sidebarPrimaryForeground ?? _sidebarPrimaryForeground,
      sidebarAccent: sidebarAccent ?? _sidebarAccent,
      sidebarAccentForeground:
          sidebarAccentForeground ?? _sidebarAccentForeground,
      sidebarBorder: sidebarBorder ?? _sidebarBorder,
      sidebarRing: sidebarRing ?? _sidebarRing,
      foregroundSubtle: foregroundSubtle ?? _foregroundSubtle,
      tint: tint ?? _tint,
      tintForeground: tintForeground ?? _tintForeground,
      success: success ?? _success,
      successMuted: successMuted ?? _successMuted,
      warning: warning ?? _warning,
      borderStrong: borderStrong ?? _borderStrong,
      accentBorder: accentBorder ?? _accentBorder,
      bar: bar ?? _bar,
      custom: custom ?? this.custom,
    );
  }

  /// Returns a copy of this scheme with [accent] applied as the accent hue,
  /// leaving the neutral palette (backgrounds, borders, muted tones) intact.
  ///
  /// shadcn/ui's theme editor treats the neutral *base colour* and the
  /// *accent* as two independent choices: pick `zinc` for the greys, then
  /// `blue` for the primary and focus ring. A [ColorScheme] bundles both,
  /// so this re-tints only the parts that follow the accent — [primary],
  /// [ring], [selection] and the [tint] — and derives a readable
  /// [primaryForeground] when one is not supplied.
  ///
  /// The [tint] is the brand colour drawn directly on the page (selected
  /// icons, links, progress fills), so it only follows [accent] where the
  /// accent can be read there:
  ///
  /// * If [accent] has a contrast of at least 4.5:1 against both [background]
  ///   and [card], it becomes the [tint]; [tintForeground] becomes the new
  ///   [primaryForeground] and [accentBorder] the tint at 32% opacity. A
  ///   scheme that names its own tint, as `TealColorScheme` does, has it
  ///   replaced.
  /// * Otherwise the three are left as they are. A scheme that names no tint
  ///   still follows the new [primary], because that is what [tint] falls
  ///   back to; a scheme that names one keeps it, since a legible tint of
  ///   the old hue serves better than an illegible one of the new. Pass a
  ///   tint of your own with [copyWith], or use [applyAccentScheme], whose
  ///   accents carry a ramp to pick a legible step from.
  ///
  /// ```dart
  /// ThemeData(
  ///   colorScheme: const ZincColorScheme.light()
  ///       .applyAccent(const Color(0xff3b82f6)),
  /// )
  /// ```
  ColorScheme applyAccent(
    Color accent, {
    Color? accentForeground,
    bool tintSelection = true,
  }) {
    final foreground = accentForeground ?? contrastingForeground(accent);
    // The same bar applyAccentScheme sets for a tint: it is drawn *on* a
    // surface, so it has to read against the page and against a card.
    final legible =
        _contrast(accent, background) >= 4.5 && _contrast(accent, card) >= 4.5;
    return copyWith(
      primary: accent,
      primaryForeground: foreground,
      ring: accent,
      selection: tintSelection ? accent.withValues(alpha: .3) : null,
      tint: legible ? accent : null,
      tintForeground: legible ? foreground : null,
      accentBorder: legible ? accent.withValues(alpha: .32) : null,
    );
  }

  /// Returns a copy of this scheme with [accent]'s hue-carrying tokens applied.
  ///
  /// This is shadcn/ui's base-colour + accent composition: the neutral palette
  /// is this scheme's, while the primary pair, secondary pair, chart ramp and
  /// sidebar primary come from the accent. Tokens the accent leaves unset stay
  /// as they are.
  ///
  /// [ring] follows the accent's primary, matching `focus-visible:ring-ring/50`
  /// picking up the themed hue.
  ///
  /// ```dart
  /// const ZincColorScheme.light()
  ///     .applyAccentScheme(AccentScheme.violetLight)
  /// ```
  ColorScheme applyAccentScheme(AccentScheme accent) {
    // The tint is the accent drawn *on* a surface — a selected icon, a link, a
    // progress fill — so it has to read against the page and against a card.
    // An accent's primary is tuned as a button fill and, in the dark
    // palettes, is often too dim for that. So: of the primary and the chart
    // ramp, take the step nearest the primary's own lightness that reaches
    // 4.5:1 on both surfaces, or failing that the most legible one.
    double legibility(Color color) {
      final onPage = _contrast(color, background);
      final onCard = _contrast(color, card);
      return onPage < onCard ? onPage : onCard;
    }

    final candidates = [
      accent.primary,
      ?accent.chart1,
      ?accent.chart2,
      ?accent.chart3,
      ?accent.chart4,
      ?accent.chart5,
    ];
    final primaryLuminance = accent.primary.computeLuminance();
    double distance(Color color) =>
        (color.computeLuminance() - primaryLuminance).abs();
    final legible = [
      for (final candidate in candidates)
        if (legibility(candidate) >= 4.5) candidate,
    ]..sort((a, b) => distance(a).compareTo(distance(b)));
    final tint = legible.isNotEmpty
        ? legible.first
        : candidates.reduce((a, b) => legibility(a) >= legibility(b) ? a : b);
    return copyWith(
      tint: tint,
      tintForeground: tint == accent.primary
          ? accent.primaryForeground
          : contrastingForeground(tint),
      accentBorder: tint.withValues(alpha: .32),
      primary: accent.primary,
      primaryForeground: accent.primaryForeground,
      secondary: accent.secondary,
      secondaryForeground: accent.secondaryForeground,
      ring: accent.primary,
      selection: accent.primary.withValues(alpha: .3),
      chart1: accent.chart1,
      chart2: accent.chart2,
      chart3: accent.chart3,
      chart4: accent.chart4,
      chart5: accent.chart5,
      sidebarPrimary: accent.sidebarPrimary,
      sidebarPrimaryForeground: accent.sidebarPrimaryForeground,
    );
  }

  /// Picks black or white — whichever reads better on [background].
  ///
  /// Uses the relative luminance rather than a naive average so that, say,
  /// a saturated yellow correctly gets dark text.
  static Color contrastingForeground(Color background) {
    // 0.18 is where near-black and near-white text have the same WCAG
    // contrast against the fill; above it dark text reads better.
    return background.computeLuminance() > 0.18
        ? const Color(0xff09090b)
        : const Color(0xfffafafa);
  }

  /// The WCAG contrast ratio between two colours, ignoring their alpha.
  static double _contrast(Color a, Color b) {
    final la = a.withValues(alpha: 1).computeLuminance();
    final lb = b.withValues(alpha: 1).computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + .05) / (darker + .05);
  }

  /// Merges this [ColorScheme] with [other].
  ///
  /// If [other] is null, returns this instance unchanged.
  /// The [custom] maps are combined, with [other]'s values taking precedence
  /// for duplicate keys.
  ColorScheme merge(ColorScheme? other) {
    if (other == null) return this;
    if (!other.canMerge) return other;
    return copyWith(
      // [other] opted into the merge, so the combined scheme stays open to
      // further overrides regardless of this scheme's own [canMerge].
      canMerge: true,
      background: other.background,
      foreground: other.foreground,
      card: other.card,
      cardForeground: other.cardForeground,
      popover: other.popover,
      popoverForeground: other.popoverForeground,
      primary: other.primary,
      primaryForeground: other.primaryForeground,
      secondary: other.secondary,
      secondaryForeground: other.secondaryForeground,
      muted: other.muted,
      mutedForeground: other.mutedForeground,
      accent: other.accent,
      accentForeground: other.accentForeground,
      destructive: other.destructive,
      destructiveForeground: other.destructiveForeground,
      border: other.border,
      input: other.input,
      ring: other.ring,
      selection: other.selection,
      chart1: other._chart1 ?? _chart1,
      chart2: other._chart2 ?? _chart2,
      chart3: other._chart3 ?? _chart3,
      chart4: other._chart4 ?? _chart4,
      chart5: other._chart5 ?? _chart5,
      sidebar: other._sidebar ?? _sidebar,
      sidebarForeground: other._sidebarForeground ?? _sidebarForeground,
      sidebarPrimary: other._sidebarPrimary ?? _sidebarPrimary,
      sidebarPrimaryForeground:
          other._sidebarPrimaryForeground ?? _sidebarPrimaryForeground,
      sidebarAccent: other._sidebarAccent ?? _sidebarAccent,
      sidebarAccentForeground:
          other._sidebarAccentForeground ?? _sidebarAccentForeground,
      sidebarBorder: other._sidebarBorder ?? _sidebarBorder,
      sidebarRing: other._sidebarRing ?? _sidebarRing,
      foregroundSubtle: other._foregroundSubtle ?? _foregroundSubtle,
      tint: other._tint ?? _tint,
      tintForeground: other._tintForeground ?? _tintForeground,
      success: other._success ?? _success,
      successMuted: other._successMuted ?? _successMuted,
      warning: other._warning ?? _warning,
      borderStrong: other._borderStrong ?? _borderStrong,
      accentBorder: other._accentBorder ?? _accentBorder,
      bar: other._bar ?? _bar,
      custom: {...custom, ...other.custom},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ColorScheme &&
        other.background == background &&
        other.foreground == foreground &&
        other.card == card &&
        other.cardForeground == cardForeground &&
        other.popover == popover &&
        other.popoverForeground == popoverForeground &&
        other.primary == primary &&
        other.primaryForeground == primaryForeground &&
        other.secondary == secondary &&
        other.secondaryForeground == secondaryForeground &&
        other.muted == muted &&
        other.mutedForeground == mutedForeground &&
        other.accent == accent &&
        other.accentForeground == accentForeground &&
        other.destructive == destructive &&
        other.destructiveForeground == destructiveForeground &&
        other.border == border &&
        other.input == input &&
        other.ring == ring &&
        other.selection == selection &&
        other._chart1 == _chart1 &&
        other._chart2 == _chart2 &&
        other._chart3 == _chart3 &&
        other._chart4 == _chart4 &&
        other._chart5 == _chart5 &&
        other._sidebar == _sidebar &&
        other._sidebarForeground == _sidebarForeground &&
        other._sidebarPrimary == _sidebarPrimary &&
        other._sidebarPrimaryForeground == _sidebarPrimaryForeground &&
        other._sidebarAccent == _sidebarAccent &&
        other._sidebarAccentForeground == _sidebarAccentForeground &&
        other._sidebarBorder == _sidebarBorder &&
        other._sidebarRing == _sidebarRing &&
        other._foregroundSubtle == _foregroundSubtle &&
        other._tint == _tint &&
        other._tintForeground == _tintForeground &&
        other._success == _success &&
        other._successMuted == _successMuted &&
        other._warning == _warning &&
        other._borderStrong == _borderStrong &&
        other._accentBorder == _accentBorder &&
        other._bar == _bar &&
        mapEquals(other.custom, custom);
  }

  @override
  int get hashCode {
    // Object.hash rather than a chain of `^`: XOR is commutative, so swapping
    // any two colors would collide. `custom` is hashed per entry because
    // MapEntry hashes by identity, which would disagree with the mapEquals
    // used by `==`.
    return Object.hashAll([
      background,
      foreground,
      card,
      cardForeground,
      popover,
      popoverForeground,
      primary,
      primaryForeground,
      secondary,
      secondaryForeground,
      muted,
      mutedForeground,
      accent,
      accentForeground,
      destructive,
      destructiveForeground,
      border,
      input,
      ring,
      selection,
      _chart1,
      _chart2,
      _chart3,
      _chart4,
      _chart5,
      _sidebar,
      _sidebarForeground,
      _sidebarPrimary,
      _sidebarPrimaryForeground,
      _sidebarAccent,
      _sidebarAccentForeground,
      _sidebarBorder,
      _sidebarRing,
      _foregroundSubtle,
      _tint,
      _tintForeground,
      _success,
      _successMuted,
      _warning,
      _borderStrong,
      _accentBorder,
      _bar,
      Object.hashAllUnordered([
        for (final entry in custom.entries) Object.hash(entry.key, entry.value),
      ]),
    ]);
  }
}
