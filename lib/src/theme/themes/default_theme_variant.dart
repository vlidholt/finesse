import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/select.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/color_scheme/base.dart';
import 'package:finesse/src/theme/components/accordion.dart';
import 'package:finesse/src/theme/components/alert.dart';
import 'package:finesse/src/theme/components/app_bar.dart';
import 'package:finesse/src/theme/components/avatar.dart';
import 'package:finesse/src/theme/components/badge.dart';
import 'package:finesse/src/theme/components/bottom_navigation_bar.dart';
import 'package:finesse/src/theme/components/breadcrumb.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/button_sizes.dart';
import 'package:finesse/src/theme/components/calendar.dart';
import 'package:finesse/src/theme/components/card.dart';
import 'package:finesse/src/theme/components/chat_bubble.dart';
import 'package:finesse/src/theme/components/checkbox.dart';
import 'package:finesse/src/theme/components/chip.dart';
import 'package:finesse/src/theme/components/collapsible.dart';
import 'package:finesse/src/theme/components/command.dart';
import 'package:finesse/src/theme/components/context_menu.dart';
import 'package:finesse/src/theme/components/date_picker.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/default_keyboard_toolbar.dart';
import 'package:finesse/src/theme/components/dialog.dart';
import 'package:finesse/src/theme/components/divider.dart';
import 'package:finesse/src/theme/components/empty.dart';
import 'package:finesse/src/theme/components/glass.dart';
import 'package:finesse/src/theme/components/icon_tile.dart';
import 'package:finesse/src/theme/components/indicator_badge.dart';
import 'package:finesse/src/theme/components/kbd.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/components/list_tile.dart';
import 'package:finesse/src/theme/components/menubar.dart';
import 'package:finesse/src/theme/components/navigation_bar.dart';
import 'package:finesse/src/theme/components/otp_field.dart';
import 'package:finesse/src/theme/components/pagination.dart';
import 'package:finesse/src/theme/components/popover.dart';
import 'package:finesse/src/theme/components/progress_bar.dart';
import 'package:finesse/src/theme/components/radio.dart';
import 'package:finesse/src/theme/components/resizable.dart';
import 'package:finesse/src/theme/components/scroll_area.dart';
import 'package:finesse/src/theme/components/select.dart';
import 'package:finesse/src/theme/components/select_option.dart';
import 'package:finesse/src/theme/components/sheet.dart';
import 'package:finesse/src/theme/components/sidebar.dart';
import 'package:finesse/src/theme/components/skeleton.dart';
import 'package:finesse/src/theme/components/slider.dart';
import 'package:finesse/src/theme/components/sonner.dart';
import 'package:finesse/src/theme/components/spinner.dart';
import 'package:finesse/src/theme/components/switch.dart';
import 'package:finesse/src/theme/components/table.dart';
import 'package:finesse/src/theme/components/tabs.dart';
import 'package:finesse/src/theme/components/text_field.dart';
import 'package:finesse/src/theme/components/textarea.dart';
import 'package:finesse/src/theme/components/time_picker.dart';
import 'package:finesse/src/theme/components/timeline.dart';
import 'package:finesse/src/theme/components/toast.dart';
import 'package:finesse/src/theme/components/toggle.dart';
import 'package:finesse/src/theme/components/tooltip.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/radii.dart';
import 'package:finesse/src/theme/spacing.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:finesse/src/theme/text_role.dart';
import 'package:finesse/src/theme/text_theme/text_styles_default.dart';
import 'package:finesse/src/theme/text_theme/theme.dart';
import 'package:finesse/src/theme/themes/base.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The default [ThemeVariant]: shadcn/ui's v4 components, rendered in one
/// of its styles.
///
/// Shows focus as an outward ring. `ThemeData` uses it unless
/// `disableSecondaryBorder` is true.
class DefaultThemeVariant extends ThemeVariant {
  /// Creates the variant.
  ///
  /// [style] defaults to [StyleTokens.finesse], [formFactor] to
  /// [FormFactor.desktop], [spacing] to the 4px step and
  /// [menuTranslucent] to false. A null [menuColorScheme] makes menus follow
  /// [colorScheme].
  DefaultThemeVariant({
    required this.colorScheme,
    required this.radius,
    required this.effectiveTextTheme,
    StyleTokens style = StyleTokens.finesse,
    this.formFactor = FormFactor.desktop,
    this.spacing = const Spacing(),
    this.menuColorScheme,
    this.menuTranslucent = false,
  }) : baseStyle = style,
       style = style.forFormFactor(formFactor);

  @override
  final ColorScheme colorScheme;

  /// The component ("md") radius. The rest of the scale derives from it.
  @override
  final BorderRadius radius;

  @override
  final TextTheme effectiveTextTheme;

  /// The style this variant was created with, before its [formFactor] was
  /// applied.
  @override
  final StyleTokens baseStyle;

  /// [baseStyle]'s metrics for [formFactor]. Every component theme reads this.
  @override
  final StyleTokens style;

  @override
  final FormFactor formFactor;

  /// The spacing scale every padding and gap is a multiple of.
  @override
  final Spacing spacing;

  /// The palette menu surfaces draw from, when it differs from the page's.
  ///
  /// shadcn's theme editor offers an "Inverted" menu colour, implemented by
  /// giving every menu surface — select, dropdown, context menu, menubar —
  /// the `dark` class, i.e. the *whole* opposite-brightness token set. Pass
  /// that scheme here and the menu component themes are derived from it while
  /// everything else keeps using [colorScheme]. Null means menus follow the
  /// page.
  final ColorScheme? menuColorScheme;

  /// Whether menu surfaces are translucent, shadcn's "Translucent" finish:
  /// the popover colour at 70% over a backdrop blur, with row highlights as a
  /// `foreground/10` wash so they read through the glass.
  final bool menuTranslucent;

  /// The radius scale derived from [radius].
  @override
  Radii get radii => Radii(radius, style.radiusScale);

  @override
  DefaultThemeVariant rebuild({
    ColorScheme? colorScheme,
    BorderRadius? radius,
    TextTheme? effectiveTextTheme,
    StyleTokens? style,
    FormFactor? formFactor,
    Spacing? spacing,
    Object? menuColorScheme = unsetMenuColorScheme,
    bool? menuTranslucent,
  }) {
    return DefaultThemeVariant(
      colorScheme: colorScheme ?? this.colorScheme,
      radius: radius ?? this.radius,
      effectiveTextTheme: effectiveTextTheme ?? this.effectiveTextTheme,
      style: style ?? baseStyle,
      formFactor: formFactor ?? this.formFactor,
      spacing: spacing ?? this.spacing,
      // `null` is meaningful here (menus follow the page), so an explicit
      // sentinel distinguishes "not passed" from "reset to null".
      menuColorScheme: identical(menuColorScheme, unsetMenuColorScheme)
          ? this.menuColorScheme
          : menuColorScheme as ColorScheme?,
      menuTranslucent: menuTranslucent ?? this.menuTranslucent,
    );
  }

  /// Sentinel for [rebuild]'s `menuColorScheme`: `null` there is meaningful
  /// ("menus follow the page"), so "leave unchanged" needs its own value.
  static const Object unsetMenuColorScheme = Object();

  /// Scales a metric shadcn expresses in spacing units.
  ///
  /// Tailwind's `h-9` and `px-2.5` are multiples of `--spacing`, so they follow
  /// [spacing]; its bracketed literals — `h-[18.4px]`, `rounded-[4px]`,
  /// `p-[3px]` — do not. [StyleTokens] stores everything in the pixels it
  /// renders at the default 4px step, and this converts the unit-based ones
  /// when that step changes.
  double scaled(double value) => value * spacing.step / 4;

  /// Table headers and footers.
  ///
  /// Most styles simply bold the body size; `sera` sets them as small
  /// uppercase overlines, which is what [StyleTokens.overline] carries.
  TextStyle get _tableHeaderStyle => style.overline.uppercase
      ? style.overline.apply(effectiveTextTheme.muted)
      : style.body
            .apply(effectiveTextTheme.muted)
            .copyWith(fontWeight: style.label.fontWeight);

  /// The border a text field draws.
  ///
  /// Most styles box the field; `sera` underlines it, which is what
  /// [StyleTokens.underlinedFields] selects.
  /// The focus ring for an element with the given corner radius.
  ///
  /// `OutwardBorderPainter` inflates by `offset` and strokes inside it, so
  /// `offset == width` puts the stroke flush against the element; each
  /// *rounded* corner grows by the ring width so the two stay concentric,
  /// while square corners stay square (adding to them would round the ring
  /// on the square styles).
  FinesseBorder ringFor(BorderRadius elementRadius) {
    Radius inflate(Radius corner) => corner == Radius.zero
        ? Radius.zero
        : Radius.elliptical(
            corner.x + style.ringWidth,
            corner.y + style.ringWidth,
          );
    return FinesseBorder.all(
      width: style.ringWidth,
      color: colorScheme.ring.withValues(alpha: style.ringOpacity),
      radius: BorderRadius.only(
        topLeft: inflate(elementRadius.topLeft),
        topRight: inflate(elementRadius.topRight),
        bottomLeft: inflate(elementRadius.bottomLeft),
        bottomRight: inflate(elementRadius.bottomRight),
      ),
      offset: style.ringWidth,
    );
  }

  /// Whether [scheme] is a dark palette.
  ///
  /// A variant is built from a scheme, not a [Brightness], so dark-only
  /// treatments (`dark:bg-input/30`, `dark:ring-foreground/10`) key off the
  /// background's luminance.
  static bool _schemeIsDark(ColorScheme scheme) =>
      scheme.background.computeLuminance() < .5;

  bool get _isDark => _schemeIsDark(colorScheme);

  /// A colour at a fraction of its own opacity — Tailwind's `input/30`.
  ///
  /// The dark `--input` is already a translucent white, and `bg-input/30`
  /// multiplies that alpha rather than replacing it, so 15% becomes 4.5%.
  static Color _wash(Color color, double factor) =>
      color.withValues(alpha: color.a * factor);

  /// Resolves one of the named washes a style can paint, against [scheme].
  Color? _fill(SurfaceFill fill, ColorScheme scheme) => switch (fill) {
    SurfaceFill.none => null,
    SurfaceFill.background => scheme.background,
    SurfaceFill.muted => scheme.muted,
    SurfaceFill.muted50 => _wash(scheme.muted, .5),
    SurfaceFill.input20 => _wash(scheme.input, .2),
    SurfaceFill.input30 => _wash(scheme.input, .3),
    SurfaceFill.input50 => _wash(scheme.input, .5),
    SurfaceFill.input90 => _wash(scheme.input, .9),
    SurfaceFill.glass => _wash(scheme.card, style.glassStrongOpacity),
    SurfaceFill.secondary => scheme.secondary,
    SurfaceFill.card => scheme.card,
  };

  /// A card's hairline outline, shadcn's `ring-foreground/10`.
  Color get cardBorderColor => _wash(
    colorScheme.foreground,
    _isDark
        ? style.cardBorderOpacityDark ?? style.cardBorderOpacity
        : style.cardBorderOpacity,
  );

  /// A popover or menu outline on the page palette.
  Color get surfaceBorderColor => _surfaceBorderColorOf(colorScheme);

  Color _surfaceBorderColorOf(ColorScheme scheme) => _wash(
    scheme.foreground,
    _schemeIsDark(scheme)
        ? style.surfaceBorderOpacityDark ?? style.surfaceBorderOpacity
        : style.surfaceBorderOpacity,
  );

  /// A dialog or sheet outline, which a few styles keep at a different
  /// opacity than their menus.
  Color get dialogBorderColor => _wash(
    colorScheme.foreground,
    _isDark
        ? style.dialogBorderOpacityDark ??
              style.dialogBorderOpacity ??
              style.surfaceBorderOpacityDark ??
              style.surfaceBorderOpacity
        : style.dialogBorderOpacity ?? style.surfaceBorderOpacity,
  );

  /// The fill an unchecked checkbox or radio carries.
  ///
  /// Most styles leave them transparent in light mode and wash them with
  /// `input/30` in dark; `luma` and `rhea` fill with `input/90` in both modes,
  /// and `sera` keeps them transparent everywhere. Both controls use the same
  /// value, which is what keeps a checkbox and a radio looking like the same
  /// family.
  Color get uncheckedControlFill =>
      _fill(
        _isDark ? style.controlFillDark : style.controlFill,
        colorScheme,
      ) ??
      const Color(0x00000000);

  /// The outline of a checkbox or radio: `border-input`, or transparent in
  /// the styles that fill their controls instead of outlining them.
  Color get controlBorderColor =>
      style.controlBorderless ? const Color(0x00000000) : colorScheme.input;

  // --- Menus ---------------------------------------------------------------

  /// The palette menu surfaces are derived from; see [menuColorScheme].
  ColorScheme get menuScheme => menuColorScheme ?? colorScheme;

  bool get _menuIsDark => _schemeIsDark(menuScheme);

  /// The surface behind a menu's rows.
  Color get menuSurfaceColor =>
      menuTranslucent ? _wash(menuScheme.popover, .7) : menuScheme.popover;

  /// A menu surface's hairline outline, on the menu palette.
  Color get menuSurfaceBorderColor => _surfaceBorderColorOf(menuScheme);

  /// The highlight behind a hovered or open menu row.
  ///
  /// `focus:bg-accent` normally; on a translucent surface shadcn switches to
  /// a `foreground/10` wash so the highlight reads through the glass.
  Color get menuItemHighlight =>
      menuTranslucent ? _wash(menuScheme.foreground, .1) : menuScheme.accent;

  /// The text and icon colour on [menuItemHighlight],
  /// `focus:text-accent-foreground`.
  Color get menuItemHighlightForeground => menuTranslucent
      ? menuScheme.popoverForeground
      : menuScheme.accentForeground;

  /// The backdrop filter of a translucent menu,
  /// `backdrop-blur-2xl backdrop-saturate-150`.
  ///
  /// CSS's `blur(40px)` is a Gaussian with sigma 20; the saturation boost is
  /// the standard luminance-preserving matrix at s = 1.5.
  static final ImageFilter _menuBackdropFilter = ImageFilter.compose(
    outer: const ColorFilter.matrix([
      1.3935, -0.3575, -0.036, 0, 0, //
      -0.1065, 1.1425, -0.036, 0, 0,
      -0.1065, -0.3575, 1.464, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    inner: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  );

  /// The backdrop filter of menu surfaces: a blur and saturation boost when
  /// [menuTranslucent] is true, otherwise null.
  ImageFilter? get menuFilter => menuTranslucent ? _menuBackdropFilter : null;

  /// A menu row's height: its vertical padding around one line of body text.
  ///
  /// shadcn sizes rows implicitly (`py-1.5 text-sm` is 6 + 20 + 6 = 32);
  /// a fixed 32 was only ever correct for the default style.
  double get menuItemHeight =>
      2 * scaled(style.itemPaddingY) + _lineHeightOf(style.body);

  /// The rendered line height of [role], following Tailwind's default line
  /// heights (`text-sm` is 14/20, `text-xs` is 12/16) when the role does not
  /// set one.
  double _lineHeightOf(TextRole role) {
    final ratio = role.height ?? (role.fontSize <= 12 ? 16 / 12 : 20 / 14);
    return role.fontSize * ratio;
  }

  /// What a field paints behind itself: `bg-transparent` with a dark
  /// `input/30` wash by default, a stronger wash in the filled styles.
  Color? get fieldFillColor => _fill(
    _isDark ? style.fieldFillDark : style.fieldFill,
    colorScheme,
  );

  /// A field's outline colour: `border-input`, or transparent in the styles
  /// that fill their fields instead of outlining them.
  Color get fieldBorderColor =>
      style.fieldBorderless ? const Color(0x00000000) : colorScheme.input;

  /// The border a multi-line field draws.
  ///
  /// Same treatment as [fieldBorder] but on [StyleTokens.textareaRadius],
  /// which stays moderate even in the pill-shaped styles.
  FinesseBorder get textareaBorder => style.underlinedFields
      ? fieldBorder
      : FinesseBorder.all(
          width: 1,
          color: fieldBorderColor,
          radius: radii.resolve(style.textareaRadius),
        );

  /// The border a single-line field draws: `border-input` on the control
  /// radius, or a bottom rule only in the underlined styles.
  FinesseBorder get fieldBorder => style.underlinedFields
      ? FinesseBorder(
          bottom: FinesseBorderSide(width: 1, color: colorScheme.input),
          radius: BorderRadius.zero,
        )
      : FinesseBorder.all(
          width: 1,
          color: fieldBorderColor,
          radius: controlRadius,
        );

  /// The inner inset the focus treatment reserves inside a control's border.
  ///
  /// This variant shows focus as an outward ring, which needs no room inside
  /// the control, so there is none. The no-secondary-border variant recolours
  /// a 2px inner border instead and reserves that thickness here, so focusing
  /// never shifts the content.
  @protected
  EdgeInsetsGeometry? focusReserve(double borderWidth) => null;

  /// The radius controls use, per [style].
  BorderRadius get controlRadius => radii.resolve(style.buttonRadius);

  /// Applies [StyleTokens.surfaceRadiusCap] to a resolved radius —
  /// `rhea`'s `rounded-[min(var(--radius-4xl),24px)]`.
  BorderRadius _capped(BorderRadius resolved) {
    final cap = style.surfaceRadiusCap;
    if (cap == null) return resolved;
    Radius clamp(Radius r) =>
        Radius.elliptical(math.min(r.x, cap), math.min(r.y, cap));
    return BorderRadius.only(
      topLeft: clamp(resolved.topLeft),
      topRight: clamp(resolved.topRight),
      bottomLeft: clamp(resolved.bottomLeft),
      bottomRight: clamp(resolved.bottomRight),
    );
  }

  /// The radius cards use, per [style].
  BorderRadius get cardRadius => _capped(radii.resolve(style.cardRadius));

  /// The radius dialogs and sheets use, per [style].
  BorderRadius get dialogRadius => _capped(radii.resolve(style.dialogRadius));

  /// The radius popovers, select and menu surfaces use, per [style].
  BorderRadius get popoverRadius => radii.resolve(style.popoverRadius);

  /// The radius command palettes use, per [style].
  BorderRadius get commandRadius => _capped(radii.resolve(style.commandRadius));

  /// The radius rows inside a surface use, per [style].
  BorderRadius get itemRadius => radii.resolve(style.itemRadius);

  /// The calendar's `--cell-radius`, per [style].
  BorderRadius get _calendarCellRadius =>
      radii.resolve(style.calendarCellRadius);

  @override
  ButtonTheme primaryButtonTheme() {
    return ButtonTheme(
      textStyle: style.label.apply(effectiveTextTheme.small),
      backgroundColor: colorScheme.primary,
      // `hover:bg-primary/80`.
      hoverBackgroundColor: _wash(colorScheme.primary, .8),
      foregroundColor: colorScheme.primaryForeground,
      hoverForegroundColor: colorScheme.primaryForeground,
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: controlRadius,
          width: 0,
          padding: focusReserve(0),
        ),
      ),
      gap: scaled(style.buttonGap),
      expands: false,
    );
  }

  @override
  ButtonTheme secondaryButtonTheme() {
    return ButtonTheme(
      textStyle: style.label.apply(effectiveTextTheme.small),
      backgroundColor: colorScheme.secondary,
      // `hover:bg-[color-mix(in_oklch,var(--secondary),var(--foreground)_5%)]`:
      // a nudge towards the foreground rather than towards transparency, so
      // the hover reads on any page colour.
      hoverBackgroundColor: Color.lerp(
        colorScheme.secondary,
        colorScheme.foreground,
        .05,
      ),
      foregroundColor: colorScheme.secondaryForeground,
      hoverForegroundColor: colorScheme.secondaryForeground,
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: controlRadius,
          width: 0,
          padding: focusReserve(0),
        ),
      ),
      gap: scaled(style.buttonGap),
      expands: false,
    );
  }

  @override
  ButtonTheme destructiveButtonTheme() {
    // The destructive button is a *soft* tint, not a solid fill:
    // `bg-destructive/10 text-destructive hover:bg-destructive/20`, one step
    // stronger in dark mode (`dark:bg-destructive/20 dark:hover:bg-destructive/30`).
    return ButtonTheme(
      textStyle: style.label.apply(effectiveTextTheme.small),
      backgroundColor: _wash(colorScheme.destructive, _isDark ? .2 : .1),
      hoverBackgroundColor: _wash(colorScheme.destructive, _isDark ? .3 : .2),
      foregroundColor: colorScheme.destructive,
      hoverForegroundColor: colorScheme.destructive,
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: controlRadius,
          width: 0,
          padding: focusReserve(0),
        ),
        // `focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40`.
        secondaryFocusedBorder: FinesseBorder.all(
          width: style.ringWidth,
          color: _wash(colorScheme.destructive, _isDark ? .4 : .2),
          radius: controlRadius.add(BorderRadius.circular(style.ringWidth)),
          offset: style.ringWidth,
        ),
      ),
      gap: scaled(style.buttonGap),
      expands: false,
    );
  }

  @override
  ButtonTheme outlineButtonTheme() {
    // `border-border bg-background hover:bg-muted hover:text-foreground`,
    // with `dark:bg-input/30 dark:border-input dark:hover:bg-input/50` — and
    // per-style fills, which is what the [SurfaceFill] tokens carry.
    return ButtonTheme(
      textStyle: style.label.apply(effectiveTextTheme.small),
      backgroundColor: _fill(
        _isDark ? style.outlineButtonFillDark : style.outlineButtonFill,
        colorScheme,
      ),
      hoverBackgroundColor: _fill(
        _isDark
            ? style.outlineButtonHoverFillDark
            : style.outlineButtonHoverFill,
        colorScheme,
      ),
      foregroundColor: colorScheme.foreground,
      hoverForegroundColor: colorScheme.foreground,
      shadows: style.controlShadow,
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: controlRadius,
          color: style.outlineButtonStrongBorder
              ? colorScheme.borderStrong
              : _isDark && style.outlineButtonDarkInputBorder
              ? colorScheme.input
              : colorScheme.border,
          width: 1,
          padding: focusReserve(1),
        ),
      ),
      gap: scaled(style.buttonGap),
      expands: false,
    );
  }

  @override
  ButtonTheme ghostButtonTheme() {
    // `hover:bg-muted hover:text-foreground dark:hover:bg-muted/50`. The rest
    // colour is simply the inherited body colour — using the primary here
    // painted ghost content in the accent hue on themed palettes.
    return ButtonTheme(
      textStyle: style.label.apply(effectiveTextTheme.small),
      hoverBackgroundColor: _isDark
          ? _wash(colorScheme.muted, .5)
          : colorScheme.muted,
      foregroundColor: colorScheme.foreground,
      hoverForegroundColor: colorScheme.foreground,
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: controlRadius,
          width: 0,
          padding: focusReserve(0),
        ),
      ),
      gap: scaled(style.buttonGap),
      expands: false,
    );
  }

  @override
  ButtonTheme linkButtonTheme() {
    return ButtonTheme(
      textStyle: style.label.apply(effectiveTextTheme.small),
      foregroundColor: colorScheme.primary,
      hoverForegroundColor: colorScheme.primary,
      // `sera` underlines its links at rest; every style underlines on hover.
      textDecoration: style.linkUnderline ? TextDecoration.underline : null,
      hoverTextDecoration: TextDecoration.underline,
      gap: scaled(style.buttonGap),
      expands: false,
    );
  }

  @override
  ButtonSizesTheme buttonSizesTheme() {
    // Matches shadcn/ui's button sizes: default `h-9 px-4 py-2`,
    // sm `h-8 px-3`, lg `h-10 px-6`, icon `size-9`. The icon sizes are the
    // style's `[&_svg:not([class*='size-'])]:size-*`, which is why the square
    // sizes carry their own rather than reusing sm/lg.
    return ButtonSizesTheme(
      regular: ButtonSizeTheme(
        height: scaled(style.buttonHeight),
        padding: EdgeInsets.symmetric(horizontal: scaled(style.buttonPaddingX)),
        iconSize: scaled(style.buttonIconSize),
      ),
      sm: ButtonSizeTheme(
        height: scaled(style.buttonHeightSm),
        padding: EdgeInsets.symmetric(
          horizontal: scaled(style.buttonPaddingXSm),
        ),
        iconSize: scaled(style.buttonIconSizeSm),
      ),
      lg: ButtonSizeTheme(
        height: scaled(style.buttonHeightLg),
        padding: EdgeInsets.symmetric(
          horizontal: scaled(style.buttonPaddingXLg),
        ),
        iconSize: scaled(style.buttonIconSizeLg),
      ),
      icon: ButtonSizeTheme(
        height: scaled(style.iconButtonSize),
        width: scaled(style.iconButtonSize),
        padding: EdgeInsets.zero,
        iconSize: scaled(style.iconButtonIconSize),
      ),
      iconSm: ButtonSizeTheme(
        height: scaled(style.iconButtonSizeSm),
        width: scaled(style.iconButtonSizeSm),
        padding: EdgeInsets.zero,
        iconSize: scaled(style.iconButtonIconSizeSm),
      ),
      iconLg: ButtonSizeTheme(
        height: scaled(style.iconButtonSizeLg),
        width: scaled(style.iconButtonSizeLg),
        padding: EdgeInsets.zero,
        iconSize: scaled(style.iconButtonIconSizeLg),
      ),
    );
  }

  @override
  BadgeTheme primaryBadgeTheme() {
    if (style.flatBadges) {
      return _flatBadgeTheme(colorScheme.foreground);
    }
    // No hover: the reference only restyles badges rendered as links
    // (`[a]:hover:bg-primary/80`); a plain badge is inert.
    return BadgeTheme(
      // `[&>svg]:size-3`.
      iconSize: scaled(style.badgeIconSize),
      backgroundColor: colorScheme.primary,
      hoverBackgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.primaryForeground,
      shape: _badgeShape,
      padding: _badgePadding,
      textStyle: style.caption.apply(effectiveTextTheme.small),
    );
  }

  @override
  BadgeTheme secondaryBadgeTheme() {
    if (style.flatBadges) {
      return _flatBadgeTheme(colorScheme.mutedForeground);
    }
    return BadgeTheme(
      // `[&>svg]:size-3`.
      iconSize: scaled(style.badgeIconSize),
      backgroundColor: colorScheme.secondary,
      hoverBackgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.secondaryForeground,
      shape: _badgeShape,
      padding: _badgePadding,
      textStyle: style.caption.apply(effectiveTextTheme.small),
    );
  }

  @override
  BadgeTheme destructiveBadgeTheme() {
    if (style.flatBadges) {
      return _flatBadgeTheme(colorScheme.destructive);
    }
    // A soft tint like the destructive button:
    // `bg-destructive/10 text-destructive dark:bg-destructive/20`.
    return BadgeTheme(
      // `[&>svg]:size-3`.
      iconSize: scaled(style.badgeIconSize),
      backgroundColor: _wash(colorScheme.destructive, _isDark ? .2 : .1),
      hoverBackgroundColor: _wash(colorScheme.destructive, _isDark ? .2 : .1),
      foregroundColor: colorScheme.destructive,
      shape: _badgeShape,
      padding: _badgePadding,
      textStyle: style.caption.apply(effectiveTextTheme.small),
    );
  }

  @override
  BadgeTheme outlineBadgeTheme() {
    if (style.flatBadges) {
      return _flatBadgeTheme(colorScheme.foreground);
    }
    return BadgeTheme(
      // `[&>svg]:size-3`.
      iconSize: scaled(style.badgeIconSize),
      foregroundColor: colorScheme.foreground,
      shape: _badgeShape is StadiumBorder
          ? StadiumBorder(side: BorderSide(color: colorScheme.border))
          : RoundedRectangleBorder(side: BorderSide(color: colorScheme.border)),
      padding: _badgePadding,
      textStyle: style.caption.apply(effectiveTextTheme.small),
    );
  }

  /// Badge geometry: `rounded-4xl px-2 py-0.5` — a pill in every style
  /// except the square ones.
  ShapeBorder get _badgeShape => switch (style.badgeRadius) {
    final token? => RoundedRectangleBorder(
      borderRadius: radii.resolve(token),
    ),
    null when style.buttonRadius == RadiusToken.none =>
      const RoundedRectangleBorder(),
    null => const StadiumBorder(),
  };

  EdgeInsetsGeometry get _badgePadding {
    final horizontal = scaled(style.badgePaddingX);
    // A fixed-height badge centres its label, so only the sides are padded.
    final height = style.badgeHeight;
    if (height == null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: spacing(.5),
      );
    }
    final vertical = (scaled(height) - _lineHeightOf(style.caption)) / 2;
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical < 0 ? 0 : vertical,
    );
  }

  /// `sera`'s badges are bare uppercase captions: no fill, border or padding.
  BadgeTheme _flatBadgeTheme(Color foreground) => BadgeTheme(
    // `[&>svg]:size-3`.
    iconSize: scaled(style.badgeIconSize),
    foregroundColor: foreground,
    shape: const RoundedRectangleBorder(),
    padding: EdgeInsets.zero,
    textStyle: style.caption.apply(effectiveTextTheme.small),
  );

  @override
  AvatarTheme avatarTheme() {
    return AvatarTheme(
      // `size-8`, with `size-10` as the large step.
      size: Size.square(style.avatarSize),
      shape: const CircleBorder(),
      backgroundColor: colorScheme.muted,
    );
  }

  @override
  BreadcrumbTheme breadcrumbTheme() {
    return BreadcrumbTheme(
      // No default `ellipsis` widget: [BreadcrumbEllipsis] already renders
      // the same icon from `ellipsisSize` and `colorScheme.mutedForeground`,
      // and nothing reads this field. Defaulting it to a non-const Widget gave
      // BreadcrumbTheme identity equality, which propagated all the way up
      // and made every ThemeData unequal to every other.
      spacing: 10,
      ellipsisSize: 16,
      separatorSize: 14,
      itemTextStyle: style.body
          .apply(effectiveTextTheme.small)
          .fallback(color: colorScheme.mutedForeground),
      lastItemTextColor: colorScheme.foreground,
      linkTextStyle: style.body
          .apply(effectiveTextTheme.small)
          .fallback(color: colorScheme.mutedForeground),
      linkNormalTextColor: colorScheme.mutedForeground,
      linkHoverTextColor: colorScheme.foreground,
      mainAxisAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      dropdownMenuBackgroundColor: colorScheme.popover,
      dropdownMenuPadding: spacing.all(1),
      dropdownTextStyle: style.body
          .apply(effectiveTextTheme.small)
          .fallback(
            color: colorScheme.foreground,
          ),
      dropdownItemPadding: spacing.symmetric(horizontal: 3, vertical: 2.5),
      dropdownMenuAnchor: const AnchorAuto(
        offset: Offset(0, 4),
        targetAnchor: AlignmentDirectional.bottomStart,
        followerAnchor: AlignmentDirectional.bottomEnd,
        fallback: AnchorAuto(
          offset: Offset(0, -4),
          targetAnchor: AlignmentDirectional.topStart,
          followerAnchor: AlignmentDirectional.topEnd,
        ),
      ),
      dropdownArrowGap: 4,
    );
  }

  @override
  TooltipTheme tooltipTheme() {
    return TooltipTheme(
      effects: const [
        FadeEffect(),
        ScaleEffect(begin: Offset(.95, .95), end: Offset(1, 1)),
        MoveEffect(begin: Offset(0, 2), end: Offset.zero),
      ],
      // `px-3 py-1.5` — fixed across the styles, unlike the popover's.
      padding: spacing.symmetric(horizontal: 3, vertical: 1.5),
      // The inverted surface: `bg-foreground text-background`, with no
      // border and no shadow, at the tooltip's own radius (`rounded-md`,
      // tighter than the popover's in most styles).
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: radii.resolve(style.tooltipRadius),
          width: 0,
        ),
        color: colorScheme.foreground,
      ),
      // `text-xs` on the inverted surface.
      textStyle: effectiveTextTheme.muted.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.normal,
        color: colorScheme.background,
      ),
      // `max-w-xs`.
      maxWidth: 320,
      showArrow: true,
      // `size-2.5 rotate-45 rounded-[2px]`; the square styles keep the tip
      // sharp (`rounded-none`).
      arrowSize: scaled(10),
      arrowRadius: style.itemRadius == RadiusToken.none ? 0 : 2,
      anchor: const AnchorAuto(
        offset: Offset(0, -4),
        followerAnchor: Alignment.topCenter,
        targetAnchor: Alignment.topCenter,
        fallback: AnchorAuto(
          offset: Offset(0, 4),
        ),
      ),
      duration: Animate.defaultDuration,
      reverseDuration: Duration.zero,
      hoverStrategies: const HoverStrategies(
        hover: {
          HoverStrategy.onTap,
          HoverStrategy.onLongPressDown,
          HoverStrategy.onLongPressStart,
        },
        unhover: {
          HoverStrategy.onTap,
          HoverStrategy.onTapOutside,
          HoverStrategy.onLongPressUp,
          HoverStrategy.onLongPressEnd,
          HoverStrategy.onLongPressCancel,
        },
        longPressDuration: kLongPressTimeout,
      ),
    );
  }

  @override
  PopoverTheme popoverTheme() {
    return PopoverTheme(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 150),
        ),
        ScaleEffect(
          begin: Offset(.95, .95),
          end: Offset(1, 1),
          duration: Duration(milliseconds: 150),
        ),
        MoveEffect(
          begin: Offset(0, 2),
          end: Offset.zero,
          duration: Duration(milliseconds: 150),
        ),
      ],
      reverseDuration: const Duration(milliseconds: 150),
      shadows: style.popoverShadow,
      textStyle: style.body.apply(effectiveTextTheme.muted),
      padding: EdgeInsets.all(scaled(style.popoverPadding)),
      decoration: FinesseDecoration(
        color: colorScheme.popover,
        shadows: style.popoverShadow,
        border: FinesseBorder.all(
          radius: popoverRadius,
          color: surfaceBorderColor,
          width: 1,
        ),
      ),
      anchor: const AnchorAuto(
        offset: Offset(0, 4),
        fallback: AnchorAuto(
          offset: Offset(0, -4),
          followerAnchor: Alignment.topCenter,
          targetAnchor: Alignment.topCenter,
        ),
      ),
    );
  }

  @override
  FinesseDecoration decorationTheme() {
    return FinesseDecoration(
      secondaryBorder: FinesseBorder.all(
        width: 0,
      ),
      // shadcn/ui's focus ring is `focus-visible:ring-[3px] ring-ring/50`:
      // a 3px ring at 50% opacity sitting directly against the element, with
      // no gap. Tailwind paints it as a box-shadow with zero offset and 3px
      // spread.
      //
      // OutwardBorderPainter inflates the rect by `offset` and strokes
      // inside it, so `offset == width` makes the stroke occupy exactly
      // [0, 3] outside the element. The previous `offset: 4` with a 2px stroke
      // left 2px of blank space between element and ring — the visible "gap".
      // The outer radius is the element radius plus the ring width so the two
      // stay concentric.
      secondaryFocusedBorder: ringFor(controlRadius),
      labelStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(
            height: 1.375,
            color: colorScheme.foreground,
          ),
      errorStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.destructive,
          ),
      labelPadding: spacing.only(bottom: 2),
      descriptionStyle: style.body.apply(effectiveTextTheme.muted),
      descriptionPadding: spacing.only(top: 2),
      errorPadding: spacing.only(top: 2),
      errorLabelStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.destructive,
          ),
    );
  }

  /// The text theme used when the caller gives none: the [TextDefaultTheme]
  /// styles in the platform font.
  static TextTheme get defaultTextTheme {
    return TextTheme.custom(
      h1Large: TextDefaultTheme.h1Large(),
      h1: TextDefaultTheme.h1(),
      h2: TextDefaultTheme.h2(),
      h3: TextDefaultTheme.h3(),
      h4: TextDefaultTheme.h4(),
      p: TextDefaultTheme.p(),
      blockquote: TextDefaultTheme.blockquote(),
      table: TextDefaultTheme.table(),
      list: TextDefaultTheme.list(),
      lead: TextDefaultTheme.lead(),
      large: TextDefaultTheme.large(),
      small: TextDefaultTheme.small(),
      muted: TextDefaultTheme.muted(),
    );
  }

  @override
  SelectTheme selectTheme() {
    return SelectTheme(
      minWidth: Select.defaultMinWidth,
      maxHeight: Select.defaultMaxHeight,
      // The reference pins the trigger at the field height
      // (`data-[size=default]:h-9` and friends), which is what keeps it level
      // with inputs and buttons on a row; its `py-2` never gets to act on a
      // single-line trigger, so only the horizontal padding is real.
      minHeight: scaled(style.inputHeight),
      padding: EdgeInsets.symmetric(
        horizontal: scaled(style.selectPaddingX),
      ),
      decoration: FinesseDecoration(
        color: fieldFillColor,
        shadows: style.controlShadow,
        // The same border treatment as a text field — `sera` underlines its
        // select triggers too (`border-transparent border-b-input px-0`).
        border: fieldBorder,
      ),
      optionsPadding: EdgeInsets.all(scaled(style.menuPadding)),
      showScrollToTopChevron: true,
      showScrollToBottomChevron: true,
      popoverReverseDuration: Duration.zero,
      anchor: const AnchorAuto(
        offset: Offset(0, 4),
        fallback: AnchorAuto(
          offset: Offset(0, -4),
          followerAnchor: Alignment.topCenter,
          targetAnchor: Alignment.topCenter,
        ),
      ),
      searchPadding: EdgeInsets.all(scaled(style.popoverPadding) * .75),
      // The options list is a menu surface, so it draws from the menu palette
      // rather than inheriting the page popover's decoration.
      popoverDecoration: FinesseDecoration(
        color: menuSurfaceColor,
        shadows: style.popoverShadow,
        border: FinesseBorder.all(
          radius: popoverRadius,
          color: menuSurfaceBorderColor,
          width: 1,
        ),
      ),
      filter: menuFilter,
    );
  }

  @override
  SelectOptionTheme selectOptionTheme() {
    // `focus:bg-accent focus:text-accent-foreground`, with every descendant —
    // check icon included — following the highlight's foreground.
    return SelectOptionTheme(
      padding: EdgeInsets.symmetric(
        horizontal: scaled(style.itemPaddingX),
        vertical: scaled(style.itemPaddingY),
      ),
      radius: itemRadius,
      textStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(color: menuScheme.popoverForeground),
      selectedTextStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(color: menuItemHighlightForeground),
      hoveredBackgroundColor: menuItemHighlight,
      selectedIconColor: menuScheme.popoverForeground,
      selectedHoveredIconColor: menuItemHighlightForeground,
    );
  }

  @override
  CardTheme cardTheme() {
    return CardTheme(
      backgroundColor: _wash(
        colorScheme.card,
        _isDark
            ? style.cardOpacityDark ?? style.cardOpacity
            : style.cardOpacity,
      ),
      blur: style.cardBlur ? style.glassBlur : 0,
      saturation: style.cardBlur ? style.glassSaturation : 1,
      padding: EdgeInsets.all(scaled(style.cardPadding)),
      border: FinesseBorder.all(color: cardBorderColor, width: 1),
      radius: cardRadius,
      shadows: _isDark
          ? style.cardShadowDark ?? style.cardShadow
          : style.cardShadow,
      gap: scaled(style.cardGap),
      // `gap-(--card-spacing)`: sections sit a full card padding apart.
      sectionGap: scaled(style.cardPadding),
      titleStyle: style.title.apply(effectiveTextTheme.large),
      descriptionStyle: style.body.apply(effectiveTextTheme.muted),
      rowMainAxisSize: MainAxisSize.min,
      rowCrossAxisAlignment: CrossAxisAlignment.start,
      rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
      columnMainAxisSize: MainAxisSize.min,
      columnCrossAxisAlignment: CrossAxisAlignment.start,
      columnMainAxisAlignment: MainAxisAlignment.start,
    );
  }

  @override
  SwitchTheme switchTheme() {
    final width = style.switchWidth;
    final height = style.switchHeight;
    // The thumb is inset by whatever is left over, so a style that specifies
    // a bigger thumb automatically gets a tighter track.
    final margin = (height - style.switchThumbSize) / 2;
    final radius = BorderRadius.all(Radius.circular(height / 2));
    return SwitchTheme(
      width: width,
      height: height,
      margin: margin,
      duration: 100.milliseconds,
      thumbColor: colorScheme.background,
      // `not-data-selected:bg-input dark:not-data-selected:bg-input/80`;
      // the filled styles use their control wash instead.
      uncheckedTrackColor: style.controlBorderless
          ? _wash(colorScheme.input, .9)
          : _isDark
          ? _wash(colorScheme.input, .8)
          : colorScheme.input,
      checkedTrackColor: colorScheme.primary,
      padding: spacing.directional(start: 2),
      decoration: FinesseDecoration(
        border: FinesseBorder.all(radius: radius.add(radius / 2), width: 0),
        // FinesseBorder.merge takes `other`'s radius and offset unconditionally,
        // so an override has to restate both or they fall back to null.
        secondaryFocusedBorder: FinesseBorder.all(
          radius: radius
              .add(radius / 2)
              .add(
                const BorderRadius.all(Radius.circular(3)),
              ),
          width: 3,
          offset: 3,
        ),
      ),
    );
  }

  @override
  CheckboxTheme checkboxTheme() {
    final checkboxRadius = BorderRadius.all(
      Radius.circular(style.checkboxRadius),
    );
    return CheckboxTheme(
      size: scaled(style.checkboxSize),
      duration: 100.milliseconds,
      color: colorScheme.primary,
      uncheckedColor: uncheckedControlFill,
      padding: spacing.directional(start: 2),
      checkboxPadding: spacing.only(top: 0.25),
      decoration: FinesseDecoration(
        shadows: style.controlShadow,
        border: FinesseBorder.all(
          color: controlBorderColor,
          radius: checkboxRadius,
          width: 1,
        ),
      ),
      // `data-checked:border-primary`: the outline follows the fill, so a
      // checked box has no pale halo around it.
      checkedDecoration: FinesseDecoration(
        shadows: style.controlShadow,
        border: FinesseBorder.all(
          color: colorScheme.primary,
          radius: checkboxRadius,
          width: 1,
        ),
      ),
    );
  }

  @override
  TextFieldTheme textFieldTheme() {
    return TextFieldTheme(
      style: style.field.apply(effectiveTextTheme.muted),
      placeholderStyle: style.field.apply(effectiveTextTheme.muted),
      inputPadding: EdgeInsets.zero,
      decoration: FinesseDecoration(
        color: fieldFillColor,
        shadows: style.controlShadow,
        border: fieldBorder,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scaled(style.inputPaddingX),
        vertical: scaled(style.inputPaddingY),
      ),
      constraints: BoxConstraints(minHeight: scaled(style.inputHeight)),
      // The field has a fixed height, so its text sits in the middle of it.
      // The default is top-aligned, which left the text riding high once the
      // height stopped being derived from the padding.
      alignment: AlignmentDirectional.centerStart,
      placeholderAlignment: AlignmentDirectional.centerStart,
      gap: 8,
    );
  }

  @override
  RadioTheme radioTheme() {
    // The radio itself is a circle, so its ring is fully rounded too.
    final focusRing = FinesseBorder.all(
      radius: const BorderRadius.all(Radius.circular(9999)),
      width: style.ringWidth,
      color: colorScheme.ring.withValues(alpha: style.ringOpacity),
      offset: style.ringWidth,
    );
    // `sera` keeps the outline form when selected — foreground border and
    // dot, no fill; every other style fills with the primary and cuts the
    // dot out of it in the primary foreground.
    final outlined = style.radioCheckedOutline;
    return RadioTheme(
      size: scaled(style.radioSize),
      // The dot is `size-2`; `luma` and `rhea` grow it a step in dark mode,
      // where their filled controls would otherwise swallow it.
      circleSize: scaled(
        _isDark && style.controlBorderless && !outlined ? 10 : 8,
      ),
      duration: 100.milliseconds,
      color: outlined ? colorScheme.foreground : colorScheme.primaryForeground,
      padding: spacing.directional(start: 2),
      decoration: FinesseDecoration(
        shape: BoxShape.circle,
        color: uncheckedControlFill,
        border: FinesseBorder.all(
          color: controlBorderColor,
          width: 1,
        ),
        secondaryFocusedBorder: focusRing,
      ),
      checkedDecoration: FinesseDecoration(
        shape: BoxShape.circle,
        color: outlined ? null : colorScheme.primary,
        border: FinesseBorder.all(
          color: outlined
              ? colorScheme.foreground
              : style.controlBorderless
              ? const Color(0x00000000)
              : colorScheme.primary,
          width: 1,
        ),
        secondaryFocusedBorder: focusRing,
      ),
      spacing: 4,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      axis: Axis.vertical,
      radioPadding: spacing.only(top: 0.25),
    );
  }

  @override
  ToastTheme primaryToastTheme() {
    return ToastTheme(
      alignment: Alignment.bottomRight,
      closeIconData: PhosphorIconsRegular.x,
      titleStyle: style.label
          .apply(effectiveTextTheme.muted)
          .copyWith(
            color: colorScheme.foreground,
          ),
      descriptionStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(
            color: colorScheme.foreground.withValues(alpha: .9),
          ),
      actionPadding: spacing.directional(start: 4),
      border: FinesseBorder.all(color: surfaceBorderColor, width: 1),
      // A toast is a floating surface; shadcn gives it the sheet's shadow.
      shadows: style.sheetShadow,
      backgroundColor: colorScheme.background,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      showCloseIconOnlyWhenHovered: true,
      padding: const EdgeInsetsGeometry.fromSTEB(24, 24, 32, 24),
      mainAxisSize: MainAxisSize.max,
    );
  }

  @override
  ToastTheme destructiveToastTheme() {
    return ToastTheme(
      alignment: Alignment.bottomRight,
      closeIconData: PhosphorIconsRegular.x,
      titleStyle: style.label
          .apply(effectiveTextTheme.muted)
          .copyWith(
            color: colorScheme.destructiveForeground,
          ),
      descriptionStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(
            color: colorScheme.destructiveForeground.withValues(alpha: .9),
          ),
      actionPadding: spacing.directional(start: 4),
      border: FinesseBorder.all(color: surfaceBorderColor, width: 1),
      // A toast is a floating surface; shadcn gives it the sheet's shadow.
      shadows: style.sheetShadow,
      backgroundColor: colorScheme.destructive,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      showCloseIconOnlyWhenHovered: true,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 32, 24),
      mainAxisSize: MainAxisSize.max,
    );
  }

  /// The alert box shared by both variants: `bg-card` on a plain `border` —
  /// the destructive variant recolours its *text*, not its outline — at the
  /// alert's own radius (`rounded-lg`, a step below the card's in most
  /// styles). `sera` runs a 2px accent bar down the left edge
  /// (`after:-left-px after:w-0.5`), drawn here as a thicker left side in
  /// [accent]; non-uniform side colours are safe because [FinesseBoxBorder]
  /// paints them.
  FinesseDecoration _alertDecoration({required Color accent}) {
    final radius = radii.resolve(style.alertRadius);
    final padding = EdgeInsets.symmetric(
      horizontal: scaled(style.alertPaddingX),
      vertical: scaled(style.alertPaddingY),
    );
    final side = FinesseBorderSide(color: colorScheme.border, width: 1);
    return FinesseDecoration(
      color: colorScheme.card,
      border: style.alertAccentBar
          ? FinesseBorder(
              radius: radius,
              padding: padding,
              top: side,
              right: side,
              bottom: side,
              left: FinesseBorderSide(color: accent, width: scaled(2)),
            )
          : FinesseBorder.all(
              color: colorScheme.border,
              radius: radius,
              padding: padding,
              width: 1,
            ),
    );
  }

  /// The icon's inset: the column gap to the text (`has-[>svg]:gap-x-2.5`)
  /// plus the downward nudge (`*:[svg]:translate-y-0.5`) that lines the
  /// glyph up with the title's cap height.
  EdgeInsetsGeometry get _alertIconPadding => EdgeInsetsDirectional.only(
    end: scaled(style.alertIconGap),
    top: scaled(style.alertIconOffset),
  );

  @override
  AlertTheme primaryAlertTheme() {
    return AlertTheme(
      iconPadding: _alertIconPadding,
      decoration: _alertDecoration(accent: colorScheme.foreground),
      iconColor: colorScheme.cardForeground,
      iconSize: scaled(style.alertIconSize),
      gap: scaled(style.alertGap),
      titleStyle: style.body
          .apply(effectiveTextTheme.p)
          .copyWith(
            color: colorScheme.cardForeground,
            fontWeight: style.label.fontWeight,
          ),
      descriptionStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(color: colorScheme.mutedForeground),
    );
  }

  @override
  AlertTheme destructiveAlertTheme() {
    return AlertTheme(
      iconPadding: _alertIconPadding,
      decoration: _alertDecoration(accent: colorScheme.destructive),
      iconColor: colorScheme.destructive,
      iconSize: scaled(style.alertIconSize),
      gap: scaled(style.alertGap),
      titleStyle: style.body
          .apply(effectiveTextTheme.p)
          .copyWith(
            color: colorScheme.destructive,
            fontWeight: style.label.fontWeight,
          ),
      // `*:data-[slot=alert-description]:text-destructive/90`.
      descriptionStyle: style.body
          .apply(effectiveTextTheme.muted)
          .copyWith(
            color: colorScheme.destructive.withValues(alpha: 0.9),
          ),
    );
  }

  @override
  DialogTheme primaryDialogTheme() {
    return DialogTheme(
      closeIconData: PhosphorIconsRegular.x,
      radius: dialogRadius,
      // A dialog sits on the popover surface (`bg-popover`), which in dark
      // mode is a step lighter than the page, with the same hairline ring as
      // the other floating surfaces.
      backgroundColor: colorScheme.popover,
      border: Border.all(color: dialogBorderColor),
      removeBorderRadiusWhenTiny: true,
      expandActionsWhenTiny: true,
      animateIn: const [
        FadeEffect(),
        ScaleEffect(begin: Offset(.95, .95), end: Offset(1, 1)),
      ],
      animateOut: const [
        FadeEffect(begin: 1, end: 0),
        ScaleEffect(begin: Offset(1, 1), end: Offset(.95, .95)),
      ],
      constraints: const BoxConstraints(maxWidth: 512),
      // shadcn's overlay is `bg-black/10` with `backdrop-blur-xs`: the blur is
      // what separates the dialog from the page, so the tint can stay light
      // and the palette behind it stays recognisable in both modes.
      barrierColor: const Color(0x1a000000),
      barrierBlurSigma: 2,
      shadows: style.dialogShadow.isEmpty ? Shadows.lg : style.dialogShadow,
      padding: EdgeInsets.all(scaled(style.dialogPadding)),
      gap: scaled(style.dialogGap),
      titleStyle: style.title.apply(effectiveTextTheme.large),
      descriptionStyle: style.body.apply(effectiveTextTheme.muted),
      alignment: Alignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      actionsGap: 8,
    );
  }

  @override
  DialogTheme alertDialogTheme() {
    return DialogTheme(
      backgroundColor: colorScheme.popover,
      border: Border.all(color: dialogBorderColor),
      radius: dialogRadius,
      removeBorderRadiusWhenTiny: true,
      expandActionsWhenTiny: true,
      animateIn: const [
        FadeEffect(),
        ScaleEffect(begin: Offset(.95, .95), end: Offset(1, 1)),
      ],
      animateOut: const [
        FadeEffect(begin: 1, end: 0),
        ScaleEffect(begin: Offset(1, 1), end: Offset(.95, .95)),
      ],
      constraints: const BoxConstraints(maxWidth: 512),
      // shadcn's overlay is `bg-black/10` with `backdrop-blur-xs`: the blur is
      // what separates the dialog from the page, so the tint can stay light
      // and the palette behind it stays recognisable in both modes.
      barrierColor: const Color(0x1a000000),
      barrierBlurSigma: 2,
      shadows: style.dialogShadow.isEmpty ? Shadows.lg : style.dialogShadow,
      padding: EdgeInsets.all(scaled(style.dialogPadding)),
      gap: scaled(style.dialogGap),
      titleStyle: style.title.apply(effectiveTextTheme.large),
      descriptionStyle: style.body.apply(effectiveTextTheme.muted),
      alignment: Alignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  @override
  SliderTheme sliderTheme() {
    return SliderTheme(
      mouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      min: 0,
      max: 1,
      // The thumb is `bg-white` in both modes, outlined with the primary;
      // `sera` fills it with the primary instead.
      thumbColor: style.sliderThumbFilled
          ? colorScheme.primary
          : const Color(0xffffffff),
      thumbBorderColor: style.sliderThumbFilled
          ? const Color(0x00000000)
          : colorScheme.primary,
      disabledThumbColor: style.sliderThumbFilled
          ? _wash(colorScheme.primary, .5)
          : const Color(0xffffffff),
      disabledThumbBorderColor: style.sliderThumbFilled
          ? const Color(0x00000000)
          : _wash(colorScheme.primary, .5),
      activeTrackColor: colorScheme.primary,
      // `bg-muted`, not the secondary: an accent theme tints the secondary
      // pair, and the track must stay neutral.
      inactiveTrackColor: _fill(style.sliderTrackFill, colorScheme),
      disabledActiveTrackColor: _wash(colorScheme.primary, .5),
      disabledInactiveTrackColor: _wash(
        _fill(style.sliderTrackFill, colorScheme) ?? colorScheme.muted,
        .5,
      ),
      trackHeight: scaled(style.sliderTrackHeight),
      thumbRadius: scaled(style.sliderThumbSize) / 2,
    );
  }

  @override
  SheetTheme sheetTheme() {
    return const SheetTheme(
      radius: BorderRadius.zero,
      expandCrossSide: true,
    );
  }

  @override
  ProgressBarTheme progressBarTheme() {
    return ProgressBarTheme(
      minHeight: scaled(style.progressHeight),
      color: colorScheme.primary,
      // `bg-muted`, not the secondary, for the same reason as the slider.
      backgroundColor: colorScheme.muted,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
    );
  }

  @override
  AccordionTheme accordionTheme() {
    const bezierCurve = Cubic(0.87, 0, 0.13, 1);
    const duration = Duration(milliseconds: 300);
    return AccordionTheme(
      iconData: PhosphorIconsRegular.caretDown,
      padding: spacing.symmetric(vertical: 4),
      underlineTitleOnHover: true,
      duration: duration,
      maintainState: false,
      iconEffects: const [
        RotateEffect(
          begin: 0,
          end: .5,
          duration: duration,
          curve: bezierCurve,
        ),
      ],
      curve: bezierCurve,
      titleStyle: style.label
          .apply(effectiveTextTheme.list)
          .copyWith(
            fontWeight: FontWeight.w500,
          ),
    );
  }

  @override
  TableTheme tableTheme() {
    return TableTheme(
      diagonalDragBehavior: DiagonalDragBehavior.none,
      dragStartBehavior: DragStartBehavior.start,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      cellAlignment: Alignment.centerLeft,
      cellHeight: 48,
      // Horizontal only: shadcn's `p-2` sits on a cell that grows with its
      // content, while FinesseTable rows have a fixed height, so vertical padding
      // there just squeezes the content out.
      cellPadding: EdgeInsets.symmetric(
        horizontal: scaled(style.tableCellPadding),
      ),
      cellStyle: style.body.apply(effectiveTextTheme.muted),
      cellHeaderStyle: _tableHeaderStyle,
      cellFooterStyle: _tableHeaderStyle,
    );
  }

  @override
  ResizableTheme resizableTheme() {
    return ResizableTheme(
      showHandle: false,
      dividerThickness: 1,
      dividerSize: 8,
      dividerColor: colorScheme.border,
      resetOnDoubleTap: true,
      handleDecoration: FinesseDecoration(
        color: colorScheme.border,
        border: FinesseBorder.all(
          radius: const BorderRadius.all(Radius.circular(4)),
          width: 0,
        ),
        disableSecondaryBorder: true,
      ),
      handleSize: 10,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      verticalDirection: VerticalDirection.down,
    );
  }

  @override
  HoverStrategies hoverStrategies() {
    return const HoverStrategies(
      hover: {
        HoverStrategy.onTapDown,
        HoverStrategy.onLongPressDown,
        HoverStrategy.onLongPressStart,
      },
      unhover: {
        HoverStrategy.onTapUp,
        HoverStrategy.onTapOutside,
        HoverStrategy.onTapCancel,
        HoverStrategy.onLongPressUp,
        HoverStrategy.onLongPressEnd,
        HoverStrategy.onLongPressCancel,
      },
      longPressDuration: kLongPressTimeout,
    );
  }

  @override
  TabsTheme tabsTheme() {
    final listRadius = radii.resolve(style.tabsListRadius);
    // Concentric corners: the tab's radius is the list's less the padding
    // between them, so the two curves share a centre.
    Radius inset(Radius r) {
      final x = r.x - style.tabsListPadding;
      final y = r.y - style.tabsListPadding;
      return Radius.elliptical(x < 0 ? 0 : x, y < 0 ? 0 : y);
    }

    final tabRadius = style.concentricTabs
        ? BorderRadius.only(
            topLeft: inset(listRadius.topLeft),
            topRight: inset(listRadius.topRight),
            bottomLeft: inset(listRadius.bottomLeft),
            bottomRight: inset(listRadius.bottomRight),
          )
        : radii.resolve(style.tabRadius);
    final tabHeight = style.tabHeight;
    final verticalPadding = tabHeight == null
        ? scaled(style.tabPaddingY)
        : ((scaled(tabHeight) - _lineHeightOf(style.label)) / 2).clamp(
            0.0,
            double.infinity,
          );
    final selectedFill =
        _fill(style.tabSelectedFill, colorScheme) ?? colorScheme.background;
    return TabsTheme(
      dragStartBehavior: DragStartBehavior.start,
      padding: EdgeInsets.all(style.tabsListPadding),
      // The strip is `bg-muted rounded-lg p-[3px]`; each tab sits one radius
      // step inside it (`rounded-md`).
      decoration: FinesseDecoration(
        color: _fill(style.tabsListFill, colorScheme) ?? colorScheme.muted,
        border: FinesseBorder.all(
          radius: listRadius,
          width: 0,
          color: colorScheme.ring,
        ),
      ),
      tabDecoration: FinesseDecoration(
        border: FinesseBorder.all(radius: tabRadius, width: 0),
      ),
      gap: 8,
      tabsGap: scaled(style.tabsGap),
      tabHeight: tabHeight == null ? null : scaled(tabHeight),
      expandContent: false,
      tabBackgroundColor: const Color(0x00000000),
      tabSelectedBackgroundColor: selectedFill,
      tabHoverBackgroundColor: const Color(0x00000000),
      tabSelectedHoverBackgroundColor: selectedFill,
      tabPadding: EdgeInsets.symmetric(
        horizontal: scaled(style.tabPaddingX),
        vertical: verticalPadding,
      ),
      tabTextStyle: style.label.apply(effectiveTextTheme.small),
      tabForegroundColor: style.tabUnselectedMuted
          ? colorScheme.mutedForeground
          : colorScheme.foreground,
      tabHoverForegroundColor: colorScheme.foreground,
      tabSelectedForegroundColor: colorScheme.foreground,
      // `data-active:shadow-sm`; most styles drop it.
      tabSelectedShadows: style.tabSelectedShadow,
    );
  }

  @override
  TextTheme textTheme() {
    // shadcn's typography examples are a fixed prose scale — they do not
    // change with the style preset. Style roles reach components through their
    // own theme slots (`style.label.apply(...)` on buttons, menus, and so on),
    // not by rewriting these entries.
    final t = effectiveTextTheme;
    final display = style.display;
    final headline = style.headline;
    final subtitle = style.subtitle;
    final small = style.small;
    if (display == null &&
        headline == null &&
        subtitle == null &&
        small == null) {
      return t;
    }
    // A style that names these roles owns the whole scale, so its body role
    // sets the paragraph size too — that is what moves running text from 14
    // to 15 on a phone.
    return t.copyWith(
      h1: display?.apply(t.h1),
      h3: headline?.apply(t.h3),
      h4: style.title.apply(t.h4),
      p: style.body.apply(t.p),
      list: style.body.apply(t.list),
      large: subtitle?.apply(t.large),
      small: small?.apply(t.small),
      muted: small?.apply(t.muted),
    );
  }

  /// The bar opacity for this scheme's brightness.
  double get _barOpacity =>
      _isDark ? style.barOpacityDark ?? style.barOpacity : style.barOpacity;

  double get _glassOpacity => _isDark
      ? style.glassOpacityDark ?? style.glassOpacity
      : style.glassOpacity;

  @override
  GlassTheme glassTheme() {
    return GlassTheme(
      blur: style.glassBlur,
      saturation: style.glassSaturation,
      color: colorScheme.card,
      opacity: _glassOpacity,
      strongOpacity: style.glassStrongOpacity,
      borderColor: colorScheme.border,
      borderWidth: 1,
      radius: cardRadius,
    );
  }

  @override
  AppBarTheme appBarTheme() {
    final opacity = _barOpacity;
    return AppBarTheme(
      height: scaled(style.appBarHeight),
      backgroundColor: _wash(colorScheme.bar, opacity),
      foregroundColor: colorScheme.foreground,
      borderColor: colorScheme.border,
      blur: opacity < 1 ? style.glassBlur : 0,
      saturation: opacity < 1 ? style.glassSaturation : 1,
      padding: EdgeInsets.symmetric(horizontal: scaled(style.pagePaddingX)),
      // The bar's *content* is as wide as the page's padding box: in the
      // Strand designs the logo sits one page margin outside the first
      // card, and the 280-point search field only fits at that width. The
      // cap applies outside the bar's own padding, hence the addition.
      maxWidth: style.pageMaxWidth + 2 * scaled(style.pagePaddingX),
      gap: scaled(style.gapXl),
      titleStyle: style.title.apply(effectiveTextTheme.large),
    );
  }

  @override
  NavigationBarTheme navigationBarTheme() {
    return NavigationBarTheme(
      itemWidth: scaled(style.navigationItemWidth),
      iconSize: scaled(style.navigationIconSize),
      gap: scaled(4),
      labelStyle: style.caption
          .apply(effectiveTextTheme.small)
          .copyWith(height: 1),
      foregroundColor: colorScheme.mutedForeground,
      selectedIconColor: colorScheme.tint,
      selectedLabelColor: colorScheme.foreground,
      hoverColor: colorScheme.foreground,
      indicatorColor: colorScheme.tint,
      indicatorHeight: style.navigationIndicatorHeight,
      indicatorInset: scaled(12),
    );
  }

  @override
  BottomNavigationBarTheme bottomNavigationBarTheme() {
    final opacity = _barOpacity;
    return BottomNavigationBarTheme(
      floating: style.bottomNavigationFloating,
      itemWidth: scaled(style.bottomNavigationItemWidth),
      itemHeight: scaled(style.bottomNavigationItemHeight),
      iconSize: scaled(style.bottomNavigationIconSize),
      actionIconSize: scaled(22),
      padding: EdgeInsets.all(scaled(style.bottomNavigationPadding)),
      margin: EdgeInsets.only(bottom: scaled(22)),
      gap: scaled(4),
      radius: radii.full,
      backgroundColor: _wash(colorScheme.bar, opacity),
      borderColor: colorScheme.border,
      blur: opacity < 1 ? style.glassBlur : 0,
      saturation: opacity < 1 ? style.glassSaturation : 1,
      foregroundColor: colorScheme.foregroundSubtle,
      selectedForegroundColor: colorScheme.tint,
      selectedBackgroundColor: colorScheme.accent,
      actionBackgroundColor: colorScheme.primary,
      actionForegroundColor: colorScheme.primaryForeground,
    );
  }

  @override
  ChipTheme chipTheme() {
    return ChipTheme(
      height: scaled(style.chipHeight),
      padding: EdgeInsets.symmetric(horizontal: scaled(style.chipPaddingX)),
      gap: scaled(style.chipGap),
      iconSize: scaled(style.chipIconSize),
      radius: radii.resolve(style.chipRadius),
      borderWidth: 1,
      textStyle: (style.small ?? style.body)
          .apply(effectiveTextTheme.small)
          .copyWith(fontWeight: FontWeight.w500, height: 1),
      backgroundColor: _fill(SurfaceFill.glass, colorScheme),
      hoverBackgroundColor: colorScheme.muted,
      foregroundColor: colorScheme.foregroundSubtle,
      borderColor: colorScheme.border,
      selectedBackgroundColor: colorScheme.accent,
      selectedForegroundColor: colorScheme.accentForeground,
      selectedBorderColor: colorScheme.accentBorder,
    );
  }

  @override
  ListTileTheme listTileTheme() {
    return ListTileTheme(
      padding: EdgeInsets.symmetric(
        horizontal: scaled(style.listTilePaddingX),
        vertical: scaled(style.listTilePaddingY),
      ),
      gap: scaled(style.listTileGap),
      titleGap: 0,
      radius: radii.lg,
      titleStyle: (style.subtitle ?? style.label).apply(
        effectiveTextTheme.large,
      ),
      subtitleStyle: (style.small ?? style.body).apply(
        effectiveTextTheme.muted,
      ),
      hoverColor: colorScheme.muted,
      selectedColor: colorScheme.accent,
    );
  }

  @override
  ChatBubbleTheme chatBubbleTheme() {
    return ChatBubbleTheme(
      radius: style.chatBubbleRadius,
      tailRadius: style.chatBubbleTailRadius,
      padding: EdgeInsets.symmetric(
        horizontal: scaled(style.chatBubblePaddingX),
        vertical: scaled(style.chatBubblePaddingY),
      ),
      textStyle: effectiveTextTheme.p.copyWith(fontSize: 15, height: 22 / 15),
      // A received message is a soft accent wash in the light, where the
      // accent is a pale solid; a dark accent is a saturated wash, so the
      // neutral fill reads better there.
      incomingColor: _isDark
          ? _wash(colorScheme.secondary, .8)
          : colorScheme.accent,
      incomingForegroundColor: colorScheme.foreground,
      outgoingColor: colorScheme.tint,
      outgoingForegroundColor: colorScheme.tintForeground,
      maxWidthFactor: .78,
    );
  }

  @override
  IndicatorBadgeTheme indicatorBadgeTheme() {
    return IndicatorBadgeTheme(
      size: 18,
      dotSize: 10,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      backgroundColor: colorScheme.destructive,
      foregroundColor: colorScheme.destructiveForeground,
      textStyle: effectiveTextTheme.small.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 18 / 11,
        letterSpacing: 0,
      ),
      ringColor: colorScheme.card,
      ringWidth: 2,
    );
  }

  @override
  IconTileTheme iconTileTheme() {
    return IconTileTheme(
      size: scaled(40),
      iconSize: scaled(22),
      radius: radii.lg,
      backgroundColor: colorScheme.accent,
      foregroundColor: colorScheme.tint,
    );
  }

  @override
  TimelineTheme timelineTheme() {
    return TimelineTheme(
      lineColor: colorScheme.borderStrong,
      lineWidth: 2,
      gap: scaled(14),
      spacing: scaled(20),
      lineGap: scaled(6),
    );
  }

  @override
  LayoutTheme layoutTheme() {
    return LayoutTheme(
      pagePadding: EdgeInsets.symmetric(
        horizontal: scaled(style.pagePaddingX),
        vertical: scaled(style.pagePaddingY),
      ),
      pageMaxWidth: style.pageMaxWidth,
      gapXs: scaled(style.gapXs),
      gapSm: scaled(style.gapSm),
      gapMd: scaled(style.gapMd),
      gapLg: scaled(style.gapLg),
      gapXl: scaled(style.gapXl),
    );
  }

  @override
  ContextMenuTheme contextMenuTheme() => ContextMenuTheme(
    constraints: BoxConstraints(minWidth: scaled(style.menuMinWidth)),
    // The surface's `p-1`, split so a row's highlight stops at the padding on
    // every side: the surface takes the vertical half and each item wraps
    // itself in the horizontal half.
    padding: EdgeInsets.symmetric(vertical: scaled(style.menuPadding)),
    itemPadding: EdgeInsets.symmetric(horizontal: scaled(style.menuPadding)),
    leadingPadding: spacing.directional(end: 2),
    trailingPadding: spacing.directional(start: 2),
    showDelay: const Duration(milliseconds: 100),
    height: menuItemHeight,
    buttonVariant: ButtonVariant.ghost,
    itemDecoration: FinesseDecoration(
      border: FinesseBorder.all(radius: itemRadius, width: 0),
      secondaryBorder: FinesseBorder.none,
      secondaryFocusedBorder: FinesseBorder.none,
    ),
    decoration: FinesseDecoration(
      color: menuSurfaceColor,
      shadows: style.popoverShadow,
      border: FinesseBorder.all(
        radius: popoverRadius,
        color: menuSurfaceBorderColor,
        width: 1,
      ),
    ),
    filter: menuFilter,
    textStyle: style.body
        .apply(effectiveTextTheme.muted)
        .copyWith(color: menuScheme.popoverForeground),
    selectedTextStyle: style.body
        .apply(effectiveTextTheme.muted)
        .copyWith(color: menuItemHighlightForeground),
    trailingTextStyle: style.caption
        .apply(effectiveTextTheme.muted)
        .copyWith(
          height: 1,
          color: menuScheme.mutedForeground,
        ),
    selectedTrailingTextStyle: style.caption
        .apply(effectiveTextTheme.muted)
        .copyWith(
          height: 1,
          color: menuItemHighlightForeground,
        ),
    selectedBackgroundColor: menuItemHighlight,
    destructiveForegroundColor: menuTranslucent
        ? menuItemHighlightForeground
        : menuScheme.destructive,
    destructiveSelectedBackgroundColor: menuTranslucent
        ? menuItemHighlight
        : _wash(menuScheme.destructive, _menuIsDark ? .2 : .1),
  );

  @override
  CalendarTheme calendarTheme() => CalendarTheme(
    dayButtonDecoration: FinesseDecoration(
      // Day cells sit on a tight grid, so the ring is kept to 2px rather than
      // the global 3px to avoid neighbouring cells colliding.
      secondaryFocusedBorder: FinesseBorder.all(
        width: 2,
        offset: 2,
        radius: _calendarCellRadius.add(
          const BorderRadius.all(Radius.circular(2)),
        ),
        color: colorScheme.ring.withValues(alpha: .5),
      ),
    ),
    hideNavigation: false,
    yearSelectorMinWidth: 64,
    monthSelectorMinWidth: 64,
    // Horizontal only: the trigger height is pinned (`h-8` and friends), so
    // vertical padding could only push past it — same story as the select
    // trigger's inert `py-2`.
    yearSelectorPadding: spacing.symmetric(horizontal: 2),
    monthSelectorPadding: spacing.symmetric(horizontal: 2),
    // `size-(--cell-size)`: navigation buttons, day cells and the caption
    // row all share the cell size.
    navigationButtonSize: scaled(style.calendarCellSize),
    navigationButtonIconSize: scaled(style.iconButtonIconSize),
    backNavigationButtonIconData: PhosphorIconsRegular.caretLeft,
    forwardNavigationButtonIconData: PhosphorIconsRegular.caretRight,
    navigationButtonPadding: EdgeInsets.zero,
    navigationButtonDisabledOpacity: .5,
    decoration: FinesseDecoration(
      border: FinesseBorder.all(
        radius: radius,
        padding: EdgeInsets.all(scaled(style.calendarPadding)),
        color: colorScheme.border,
        width: 1,
      ),
    ),
    spacingBetweenMonths: 16,
    runSpacingBetweenMonths: 16,
    // The caption row is `h-(--cell-size)`, but `mira`'s dropdown triggers
    // are a step taller than its cells, so the header makes room for both.
    headerHeight: math.max(
      scaled(style.calendarCellSize),
      scaled(style.calendarCaptionHeight),
    ),
    headerPadding: spacing.only(bottom: 4),
    captionLayoutGap: 6,
    headerTextStyle: style.label.apply(effectiveTextTheme.small),
    // No monthConstraints here: the widget derives the month width from the
    // day cell size — and widens it when week numbers add a column.
    dayButtonRadius: _calendarCellRadius,
    selectorMinHeight: scaled(style.calendarCaptionHeight),
    weekdaysPadding: spacing.only(bottom: 2),
    weekNumbersHeaderText: '#',
    weekNumbersHeaderTextStyle: textTheme().muted.copyWith(fontSize: 12.8),
    weekNumbersTextStyle: textTheme().muted.copyWith(fontSize: 12.8),
    dayButtonSize: scaled(style.calendarCellSize),
    dayButtonOutsideMonthOpacity: .5,
    dayButtonPadding: EdgeInsets.zero,
    selectedDayButtonTextStyle: textTheme().small.copyWith(
      fontWeight: FontWeight.normal,
      color: colorScheme.primaryForeground,
    ),
    insideRangeDayButtonTextStyle: textTheme().small.copyWith(
      color: colorScheme.foreground,
    ),
    dayButtonTextStyle: textTheme().small.copyWith(
      fontWeight: FontWeight.normal,
      color: colorScheme.foreground,
    ),
    dayButtonOutsideMonthVariant: ButtonVariant.ghost,
    dayButtonOutsideMonthTextStyle: textTheme().muted,
    dayButtonVariant: ButtonVariant.ghost,
    todayButtonVariant: ButtonVariant.secondary,
    selectedDayButtonVariant: ButtonVariant.primary,
    selectedDayButtonOutsideMonthVariant: ButtonVariant.secondary,
    insideRangeDayButtonVariant: ButtonVariant.secondary,
    weekdaysTextStyle: textTheme().muted.copyWith(fontSize: 12.8),
    weekdaysTextAlign: TextAlign.center,
    gridMainAxisSpacing: 8,
    gridCrossAxisSpacing: 0,
    hideWeekdayNames: false,
    showOutsideDays: true,
    showWeekNumbers: false,
    weekStartsOn: 1,
    fixedWeeks: false,
    allowDeselection: false,
  );

  @override
  DatePickerTheme datePickerTheme() {
    return const DatePickerTheme(
      calendarDecoration: FinesseDecoration.none,
      allowDeselection: true,
      buttonVariant: ButtonVariant.outline,
      width: 276,
      mainAxisAlignment: MainAxisAlignment.start,
      iconData: PhosphorIconsRegular.calendarBlank,
    );
  }

  @override
  TimePickerTheme timePickerTheme() {
    return TimePickerTheme(
      axis: Axis.horizontal,
      spacing: 8,
      runSpacing: 4,
      jumpToNextFieldWhenFilled: true,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      gap: 4,
      // The reference has no time picker; its fields take the same text,
      // outline, fill and height as a text field so a picker sits level with
      // the other controls on a row.
      style: style.field
          .apply(effectiveTextTheme.muted)
          .copyWith(color: colorScheme.foreground),
      placeholderStyle: style.field.apply(effectiveTextTheme.muted),
      labelStyle: effectiveTextTheme.small.copyWith(fontSize: 12),
      fieldWidth: 48,
      fieldPadding: EdgeInsets.symmetric(
        horizontal: scaled(style.inputPaddingX),
        vertical: scaled(style.inputPaddingY),
      ),
      periodHeight: scaled(style.inputHeight),
      periodMinWidth: 65,
      fieldDecoration: FinesseDecoration(
        color: fieldFillColor,
        shadows: style.controlShadow,
        border: fieldBorder,
      ),
    );
  }

  @override
  OtpFieldTheme otpFieldTheme() {
    return OtpFieldTheme(
      width: scaled(style.inputHeight),
      height: scaled(style.inputHeight),
      style: effectiveTextTheme.muted.copyWith(
        color: colorScheme.foreground,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      // shadcn rounds only the outer corners of the strip, at the control
      // radius: `first:rounded-l-md last:rounded-r-md`.
      firstRadius: BorderRadius.only(
        topLeft: controlRadius.topLeft,
        bottomLeft: controlRadius.bottomLeft,
      ),
      lastRadius: BorderRadius.only(
        topRight: controlRadius.topRight,
        bottomRight: controlRadius.bottomRight,
      ),
      singleRadius: controlRadius,
      middleRadius: BorderRadius.zero,
      decoration: FinesseDecoration(
        focusedBorder: FinesseBorder.all(color: colorScheme.ring, width: 1),
        // Same ring as every other field; the slot supplies the radius, since
        // only the ends of the strip are rounded.
        secondaryFocusedBorder: FinesseBorder.all(
          width: style.ringWidth,
          color: colorScheme.ring.withValues(alpha: style.ringOpacity),
          offset: style.ringWidth,
        ),
        // `border-y border-r` with `first:border-l`: the slots share their
        // vertical edges, so only the right one is drawn per slot. An
        // underlined style draws the bottom edge alone.
        border: style.underlinedFields
            ? FinesseBorder(
                bottom: FinesseBorderSide(color: colorScheme.input, width: 1),
              )
            : FinesseBorder(
                top: FinesseBorderSide(color: colorScheme.input, width: 1),
                bottom: FinesseBorderSide(color: colorScheme.input, width: 1),
                right: FinesseBorderSide(color: colorScheme.input, width: 1),
              ),
      ),
    );
  }

  @override
  MenubarTheme menubarTheme() {
    // The strip is `h-9 gap-1 rounded-md border p-1 shadow-xs`; its triggers
    // highlight with `bg-muted` on hover *and* while their menu is open
    // (`aria-expanded:bg-muted`) — not with the accent, which belongs to the
    // rows inside the menus.
    return MenubarTheme(
      radius: controlRadius,
      padding: EdgeInsets.all(style.menubarPadding),
      border: FinesseBorder.all(color: colorScheme.border, width: 1),
      anchor: const Anchor(
        offset: Offset(-4, 8),
        childAlignment: AlignmentDirectional.bottomStart,
        overlayAlignment: AlignmentDirectional.topStart,
      ),
      // Border-box: the strip's height minus its padding and hairline.
      buttonHeight: scaled(style.menubarHeight) - 2 * style.menubarPadding - 2,
      buttonVariant: ButtonVariant.ghost,
      buttonForegroundColor: colorScheme.foreground,
      buttonHoverForegroundColor: colorScheme.foreground,
      buttonHoverBackgroundColor: colorScheme.muted,
      buttonSelectedBackgroundColor: colorScheme.muted,
      buttonDecoration: FinesseDecoration(
        border: FinesseBorder.all(radius: itemRadius, width: 0),
        disableSecondaryBorder: true,
      ),
    );
  }

  @override
  DividerTheme dividerTheme() {
    return DividerTheme(
      thickness: 1,
      color: colorScheme.border,
      verticalMargin: spacing.symmetric(horizontal: 4),
      horizontalMargin: spacing.symmetric(vertical: 4),
    );
  }

  @override
  SonnerTheme sonnerTheme() {
    return SonnerTheme(
      alignment: Alignment.bottomRight,
      padding: spacing.all(4),
      collapsedGap: 16,
      expandedGap: 8,
      scaleFactor: 0.05,
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: const Cubic(0.215, 0.61, 0.355, 1),
    );
  }

  @override
  TextareaTheme textareaTheme() {
    return TextareaTheme(
      style: style.field.apply(effectiveTextTheme.muted),
      placeholderStyle: style.field.apply(effectiveTextTheme.muted),
      inputPadding: EdgeInsets.zero,
      decoration: FinesseDecoration(
        color: fieldFillColor,
        border: textareaBorder,
        // A textarea is rounder or squarer than a control, so its ring has to
        // be built from its own radius rather than the shared one.
        secondaryFocusedBorder: ringFor(radii.resolve(style.textareaRadius)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scaled(style.textareaPaddingX),
        vertical: scaled(style.textareaPaddingY),
      ),
      gap: 8,
      minHeight: 80,
      maxHeight: 500,
      resizable: true,
      scrollbarPadding: spacing.only(bottom: 2.5),
    );
  }

  @override
  DefaultKeyboardToolbarTheme defaultKeyboardToolbarTheme() {
    return DefaultKeyboardToolbarTheme(
      backgroundColor: colorScheme.accent,
      doneText: 'Done',
      showDoneButton: true,
      showNextButton: true,
      showPreviousButton: true,
    );
  }

  @override
  SkeletonTheme skeletonTheme() {
    return SkeletonTheme(
      color: colorScheme.muted,
      highlightColor: colorScheme.muted.withValues(alpha: .4),
      radius: radius,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      animate: true,
    );
  }

  @override
  ScrollAreaTheme scrollAreaTheme() {
    // `.cn-scroll-area-scrollbar` is `w-2.5 p-px border-l border-transparent`:
    // a 10px track holding a 7px thumb, inset 1px from the edge.
    // `.cn-scroll-area-thumb` is `rounded-full bg-border`, square in the
    // styles whose items are square (lyra, sera).
    return ScrollAreaTheme(
      thickness: scaled(10) - 3,
      crossAxisMargin: 1,
      mainAxisMargin: 1,
      radius: style.itemRadius == RadiusToken.none
          ? Radius.zero
          : const Radius.circular(999),
      thumbColor: colorScheme.border,
      fadeDuration: const Duration(milliseconds: 300),
      // Radix's `scrollHideDelay`.
      timeToFade: const Duration(milliseconds: 600),
    );
  }

  @override
  KbdTheme kbdTheme() {
    return KbdTheme(
      backgroundColor: colorScheme.muted,
      foregroundColor: colorScheme.mutedForeground,
      // No outline: shadcn's kbd is a plain `bg-muted rounded-sm` chip.
      border: FinesseBorder.all(width: 0, radius: itemRadius),
      padding: EdgeInsets.symmetric(horizontal: scaled(style.kbdPaddingX)),
      // `font-sans text-xs font-medium` — a key cap is not code.
      textStyle: style.caption.apply(effectiveTextTheme.muted),
      gap: 4,
      height: scaled(style.kbdHeight),
      minWidth: scaled(style.kbdHeight),
    );
  }

  @override
  SpinnerTheme spinnerTheme() {
    // No colour here: the spinner is `text-current` in the reference, so it
    // follows the ambient IconTheme — a primary button's spinner spins in
    // the primary foreground, a plain one in the page foreground. A colour
    // baked into the theme would override that everywhere.
    return const SpinnerTheme(
      size: 16,
      strokeWidth: 2,
      duration: Duration(milliseconds: 900),
    );
  }

  @override
  ToggleTheme toggleTheme() => _toggleTheme(borderWidth: 0);

  @override
  ToggleTheme outlineToggleTheme() => _toggleTheme(borderWidth: 1);

  /// Shared toggle metrics; outline adds `border-input shadow-xs`.
  ToggleTheme _toggleTheme({required double borderWidth}) {
    // `hover:bg-muted hover:text-foreground aria-pressed:bg-muted` — the
    // pressed state is the muted surface, not the accent, and its size
    // follows the button metrics (`h-9 min-w-9 px-2.5`).
    return ToggleTheme(
      hoverBackgroundColor: colorScheme.muted,
      selectedBackgroundColor: colorScheme.muted,
      selectedHoverBackgroundColor: colorScheme.muted,
      foregroundColor: colorScheme.foreground,
      hoverForegroundColor: colorScheme.foreground,
      selectedForegroundColor: colorScheme.foreground,
      padding: EdgeInsets.symmetric(horizontal: scaled(style.buttonPaddingX)),
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: controlRadius,
          color: borderWidth == 0 ? null : colorScheme.input,
          width: borderWidth,
          padding: focusReserve(borderWidth),
        ),
        shadows: borderWidth == 0 ? null : style.controlShadow,
      ),
      textStyle: style.label.apply(effectiveTextTheme.small),
      gap: scaled(style.buttonGap),
      height: scaled(style.buttonHeight),
      // `[&_svg:not([class*='size-'])]:size-4`.
      iconSize: scaled(style.toggleIconSize),
    );
  }

  @override
  EmptyTheme emptyTheme() {
    return EmptyTheme(
      padding: spacing.symmetric(horizontal: 6, vertical: 12),
      gap: 8,
      iconSize: 40,
      // The icon chip is `bg-muted text-foreground` (`cn-empty-media-icon`).
      iconColor: colorScheme.foreground,
      titleStyle: style.title.apply(effectiveTextTheme.large),
      descriptionStyle: style.body.apply(effectiveTextTheme.muted),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  @override
  PaginationTheme paginationTheme() {
    return PaginationTheme(
      gap: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      siblingCount: 1,
      boundaryCount: 1,
      showEdges: true,
      ellipsisTextStyle: effectiveTextTheme.muted,
    );
  }

  @override
  CollapsibleTheme collapsibleTheme() {
    return const CollapsibleTheme(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
  }

  /// A surface-level radius for the sidebar's floating and inset chrome.
  ///
  /// The reference uses `rounded-lg`/`rounded-xl` on the standard styles,
  /// `rounded-none` on the square ones and `rounded-2xl` on the pill ones —
  /// the popover radius capped at the 2xl step reproduces that pattern
  /// (within 2px on `mira`) without a dedicated token.
  BorderRadius get _sidebarSurfaceRadius {
    final popover = radii.resolve(style.popoverRadius);
    final cap = radii.xl2;
    Radius min(Radius a, Radius b) => a.x <= b.x ? a : b;
    return BorderRadius.only(
      topLeft: min(popover.topLeft, cap.topLeft),
      topRight: min(popover.topRight, cap.topRight),
      bottomLeft: min(popover.bottomLeft, cap.bottomLeft),
      bottomRight: min(popover.bottomRight, cap.bottomRight),
    );
  }

  @override
  SidebarTheme sidebarTheme() {
    // `text-sm` following the style's body role, coloured with the sidebar's
    // own foreground; `lyra` and `mira` drop to 12px through the role.
    final itemTextStyle = style.body
        .apply(effectiveTextTheme.small)
        .copyWith(color: colorScheme.sidebarForeground);
    final itemPaddingX = scaled(style.sidebarItemPaddingX);
    return SidebarTheme(
      // --sidebar-width: 16rem, --sidebar-width-icon: 3rem, mobile 18rem.
      width: scaled(256),
      collapsedWidth: scaled(48),
      mobileWidth: scaled(288),
      backgroundColor: colorScheme.sidebar,
      foregroundColor: colorScheme.sidebarForeground,
      borderColor: colorScheme.sidebarBorder,
      accentColor: colorScheme.sidebarAccent,
      accentForegroundColor: colorScheme.sidebarAccentForeground,
      ringColor: colorScheme.sidebarRing,
      ringWidth: 2,
      headerPadding: EdgeInsets.all(scaled(8)),
      footerPadding: EdgeInsets.all(scaled(8)),
      groupPadding: EdgeInsets.all(scaled(8)),
      contentGap: scaled(8),
      menuGap: scaled(4),
      groupLabelHeight: scaled(32),
      groupLabelPadding: EdgeInsets.symmetric(horizontal: itemPaddingX),
      // `text-xs font-medium text-sidebar-foreground/70`, with `sera`'s
      // uppercase tracking coming through the overline role.
      groupLabelTextStyle: style.overline
          .apply(effectiveTextTheme.small)
          .copyWith(
            fontSize: 12,
            color: colorScheme.sidebarForeground.withValues(alpha: .7),
          ),
      menuButtonHeight: scaled(style.sidebarItemHeight),
      menuButtonHeightSm: scaled(style.sidebarItemHeightSm),
      menuButtonHeightLg: scaled(style.sidebarItemHeightLg),
      menuButtonPadding: EdgeInsets.symmetric(horizontal: itemPaddingX),
      menuButtonGap: scaled(8),
      menuButtonRadius: itemRadius,
      menuButtonTextStyle: itemTextStyle,
      // The sm size is `text-xs` in every style.
      menuButtonTextStyleSm: itemTextStyle.copyWith(fontSize: 12),
      iconSize: scaled(16),
      subMenuMargin: EdgeInsets.symmetric(horizontal: scaled(14)),
      subMenuPadding: EdgeInsets.symmetric(
        horizontal: scaled(10),
        vertical: scaled(2),
      ),
      subButtonHeight: scaled(28),
      subButtonPadding: EdgeInsets.symmetric(
        horizontal: scaled(style.sidebarSubItemPaddingX),
      ),
      subButtonTextStyle: itemTextStyle,
      // `h-5 min-w-5 px-1 text-xs font-medium`.
      badgeTextStyle: style.caption
          .apply(effectiveTextTheme.small)
          .copyWith(color: colorScheme.sidebarForeground),
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      floatingMargin: EdgeInsets.all(scaled(8)),
      floatingRadius: _sidebarSurfaceRadius,
      floatingShadows: Shadows.sm,
      insetMargin: EdgeInsets.all(scaled(8)),
      insetRadius: _sidebarSurfaceRadius,
      insetShadows: Shadows.sm,
    );
  }

  @override
  CommandTheme commandTheme() {
    final pad = scaled(style.commandPadding);
    // `.cn-command-input-group`: an `--input` wash inside a soft `--input`
    // outline. The underlined styles keep only the bottom hairline (`sera`'s
    // `border-b-input`, `lyra`'s wrapper `border-b`). No focus ring — the
    // command palette's search field is always focused, and shadcn silences
    // the box's ring and shadow (`shadow-none!`).
    final searchBorderColor = _wash(
      colorScheme.input,
      style.commandSearchBorderOpacity,
    );
    final searchRadius = radii.resolve(style.commandSearchRadius);
    final searchDecoration = FinesseDecoration(
      color: _fill(
        _isDark ? style.commandSearchFillDark : style.commandSearchFill,
        colorScheme,
      ),
      border: style.commandSearchUnderline
          ? FinesseBorder(
              radius: searchRadius,
              bottom: FinesseBorderSide(color: colorScheme.input, width: 1),
            )
          : FinesseBorder.all(
              radius: searchRadius,
              color: searchBorderColor,
              width: 1,
            ),
      disableSecondaryBorder: true,
    );
    return CommandTheme(
      backgroundColor: colorScheme.popover,
      // `.cn-command` carries the surface hairline; shadow comes from the
      // inline demo's `shadow-md`, not from the base style block.
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: commandRadius,
          color: surfaceBorderColor,
          width: 1,
        ),
      ),
      // `.cn-command p-1` around the search wrapper and the list; the
      // wrapper adds its own `p-1 pb-0`, so the search box sits at 8 and the
      // list runs to the root padding.
      padding: EdgeInsets.zero,
      searchPadding: style.underlinedFields
          ? spacing.all(1)
          : EdgeInsets.fromLTRB(pad * 2, pad * 2, pad * 2, 0),
      optionsPadding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
      searchDecoration: searchDecoration,
      searchHeight: scaled(style.commandSearchHeight),
      // The addon is `text-muted-foreground` and the icon `opacity-50`.
      searchIconColor: _wash(colorScheme.mutedForeground, .5),
      searchIconSize: scaled(16),
      // Addon `pl-2`, input `pl-1.5` past it; `sera` boxes with `px-3`.
      searchInputPadding: style.underlinedFields
          ? spacing.symmetric(horizontal: 3)
          : spacing.symmetric(horizontal: 2),
      searchGap: scaled(6),
      listMaxHeight: scaled(288),
      groupPadding: EdgeInsets.all(scaled(style.commandGroupPadding)),
      groupHeadingStyle: style.overline.apply(effectiveTextTheme.muted),
      groupHeadingPadding: EdgeInsets.symmetric(
        horizontal: scaled(style.itemPaddingX),
        vertical: scaled(style.itemPaddingY),
      ),
      itemPadding: EdgeInsets.symmetric(
        horizontal: scaled(style.itemPaddingX),
        vertical: scaled(style.itemPaddingY),
      ),
      itemTextStyle: style.body
          .apply(effectiveTextTheme.small)
          .copyWith(
            fontWeight: FontWeight.normal,
          ),
      // `data-selected:bg-muted data-selected:text-foreground` — the command
      // palette highlights with the muted surface, not the accent.
      itemSelectedBackgroundColor: colorScheme.muted,
      itemSelectedForegroundColor: colorScheme.foreground,
      itemForegroundColor: colorScheme.popoverForeground,
      itemRadius: itemRadius,
      dialogItemRadius: radii.resolve(style.commandItemDialogRadius),
      itemGap: 8,
      // The base glyph, `size-4` — 3.5 in the two styles whose buttons also
      // drop to it, which is what [StyleTokens.buttonIconSize] measures.
      itemIconSize: scaled(style.buttonIconSize),
      width: 400,
      // `.cn-command-empty py-6 text-center text-sm`, in the palette's own
      // foreground.
      emptyPadding: spacing.symmetric(vertical: 6),
      emptyTextStyle: style.body
          .apply(effectiveTextTheme.small)
          .copyWith(
            fontWeight: FontWeight.normal,
            color: colorScheme.popoverForeground,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DefaultThemeVariant &&
        other.colorScheme == colorScheme &&
        other.radius == radius &&
        other.effectiveTextTheme == effectiveTextTheme &&
        other.style == style &&
        other.spacing == spacing;
  }

  @override
  int get hashCode =>
      Object.hash(colorScheme, radius, effectiveTextTheme, style, spacing);
}
