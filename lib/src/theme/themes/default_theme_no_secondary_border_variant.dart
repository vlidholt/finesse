import 'package:finesse/src/theme/color_scheme/base.dart';
import 'package:finesse/src/theme/components/calendar.dart';
import 'package:finesse/src/theme/components/checkbox.dart';
import 'package:finesse/src/theme/components/context_menu.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/otp_field.dart';
import 'package:finesse/src/theme/components/radio.dart';
import 'package:finesse/src/theme/components/select.dart';
import 'package:finesse/src/theme/components/switch.dart';
import 'package:finesse/src/theme/components/tabs.dart';
import 'package:finesse/src/theme/components/time_picker.dart';
import 'package:finesse/src/theme/spacing.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:finesse/src/theme/text_theme/text_styles_default.dart';
import 'package:finesse/src/theme/text_theme/theme.dart';
import 'package:finesse/src/theme/themes/default_theme_variant.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:flutter/widgets.dart';

/// [DefaultThemeVariant] without the outward focus ring.
///
/// Focus is shown by recolouring a 2px border *inside* each control instead of
/// painting a ring around it, and every bordered control reserves that
/// thickness up front (see [focusReserve]) so focusing never shifts content.
/// Everything else — colours, metrics, menu handling — is inherited, so a
/// reference fix in the default variant lands here too.
class DefaultThemeNoSecondaryBorderVariant extends DefaultThemeVariant {
  /// Creates the variant. The arguments are the same as for
  /// [DefaultThemeVariant.new].
  DefaultThemeNoSecondaryBorderVariant({
    required super.colorScheme,
    required super.radius,
    required super.effectiveTextTheme,
    super.style,
    super.spacing,
    super.menuColorScheme,
    super.menuTranslucent,
  });

  @override
  DefaultThemeNoSecondaryBorderVariant rebuild({
    ColorScheme? colorScheme,
    BorderRadius? radius,
    TextTheme? effectiveTextTheme,
    StyleTokens? style,
    Spacing? spacing,
    Object? menuColorScheme = DefaultThemeVariant.unsetMenuColorScheme,
    bool? menuTranslucent,
  }) {
    return DefaultThemeNoSecondaryBorderVariant(
      colorScheme: colorScheme ?? this.colorScheme,
      radius: radius ?? this.radius,
      effectiveTextTheme: effectiveTextTheme ?? this.effectiveTextTheme,
      style: style ?? this.style,
      spacing: spacing ?? this.spacing,
      menuColorScheme:
          identical(
            menuColorScheme,
            DefaultThemeVariant.unsetMenuColorScheme,
          )
          ? this.menuColorScheme
          : menuColorScheme as ColorScheme?,
      menuTranslucent: menuTranslucent ?? this.menuTranslucent,
    );
  }

  /// The room the 2px focus border needs inside a control: whatever the
  /// control's own border does not already occupy. `spacing`-based so it
  /// follows a custom spacing step like every other inset.
  @override
  EdgeInsetsGeometry? focusReserve(double borderWidth) =>
      borderWidth >= 2 ? null : spacing.all((2 - borderWidth) / 4);

  @override
  FinesseBorder get fieldBorder => super.fieldBorder.copyWith(
    padding: focusReserve(1),
  );

  @override
  FinesseBorder get textareaBorder => super.textareaBorder.copyWith(
    padding: focusReserve(1),
  );

  @override
  FinesseDecoration decorationTheme() {
    // No outward ring in this variant: a transparent 2px border reserves the
    // space and is recoloured with the ring colour on focus. The inherited
    // secondary (outward) borders never paint, because the decorator checks
    // the theme-wide `disableSecondaryBorder` flag this variant is built for.
    return super.decorationTheme().copyWith(
      border: FinesseBorder.all(width: 2, color: const Color(0x00000000)),
      focusedBorder: FinesseBorder.all(
        color: colorScheme.ring,
        radius: radius,
        width: 2,
      ),
    );
  }

  @override
  SelectTheme selectTheme() => super.selectTheme().merge(
    SelectTheme(
      decoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: controlRadius,
          color: colorScheme.input,
          padding: focusReserve(1),
          width: 1,
        ),
      ),
    ),
  );

  @override
  SwitchTheme switchTheme() {
    final height = style.switchHeight;
    final radius = BorderRadius.all(Radius.circular(height));
    return super.switchTheme().merge(
      SwitchTheme(
        decoration: FinesseDecoration(
          border: FinesseBorder.all(
            radius: radius,
            width: 0,
            padding: focusReserve(0),
          ),
          focusedBorder: FinesseBorder.all(radius: radius, width: 2),
        ),
      ),
    );
  }

  @override
  CheckboxTheme checkboxTheme() {
    final checkboxRadius = BorderRadius.all(
      Radius.circular(style.checkboxRadius),
    );
    FinesseDecoration decorationWith(Color borderColor) => FinesseDecoration(
      shadows: style.controlShadow,
      border: FinesseBorder.all(
        color: borderColor,
        radius: checkboxRadius,
        padding: focusReserve(1),
        width: 1,
      ),
      focusedBorder: FinesseBorder.all(width: 2),
    );
    return super.checkboxTheme().merge(
      CheckboxTheme(
        decoration: decorationWith(controlBorderColor),
        checkedDecoration: decorationWith(colorScheme.primary),
      ),
    );
  }

  @override
  RadioTheme radioTheme() {
    final base = super.radioTheme();
    final circleRadius = BorderRadius.all(
      Radius.circular(base.circleSize ?? 8),
    );
    FinesseDecoration adapt(FinesseDecoration? decoration) =>
        (decoration ?? const FinesseDecoration()).copyWith(
          border: decoration?.border?.copyWith(padding: focusReserve(1)),
          focusedBorder: FinesseBorder.all(
            radius: circleRadius.add(circleRadius / 2),
            width: 2,
          ),
        );
    return base.merge(
      RadioTheme(
        decoration: adapt(base.decoration),
        checkedDecoration: adapt(base.checkedDecoration),
      ),
    );
  }

  @override
  TabsTheme tabsTheme() => super.tabsTheme().merge(
    TabsTheme(
      tabDecoration: FinesseDecoration(
        border: FinesseBorder.all(
          radius: const BorderRadius.all(Radius.circular(4)),
          width: 0,
        ),
        focusedBorder: FinesseBorder.all(
          radius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
    ),
  );

  @override
  ContextMenuTheme contextMenuTheme() => super.contextMenuTheme().merge(
    ContextMenuTheme(
      itemDecoration: FinesseDecoration(
        border: FinesseBorder.all(radius: itemRadius, width: 0),
        focusedBorder: decorationTheme().border,
      ),
    ),
  );

  @override
  CalendarTheme calendarTheme() => super.calendarTheme().merge(
    const CalendarTheme(
      yearSelectorMinWidth: 100,
      monthSelectorMinWidth: 130,
    ),
  );

  @override
  TimePickerTheme timePickerTheme() => super.timePickerTheme().merge(
    TimePickerTheme(
      spacing: 4,
      gap: 2,
      fieldWidth: 50,
      periodHeight: 44,
      periodDecoration: FinesseDecoration(
        border: FinesseBorder.all(
          width: 2,
          color: colorScheme.border,
          radius: radius,
        ),
        focusedBorder: FinesseBorder.all(
          width: 2,
          color: colorScheme.ring,
          radius: radius,
          padding: spacing.symmetric(horizontal: 0.25),
        ),
      ),
    ),
  );

  @override
  OtpFieldTheme otpFieldTheme() {
    final base = super.otpFieldTheme();
    // No extra slot padding here: a slot is a fixed square with a centred
    // glyph, so vertical padding cannot move anything — but it can overflow
    // the box once the reserve and a tall text role (mira) use up the room.
    return base.merge(
      OtpFieldTheme(
        decoration: (base.decoration ?? const FinesseDecoration()).copyWith(
          border: base.decoration?.border?.copyWith(
            padding: focusReserve(1),
          ),
        ),
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
}
