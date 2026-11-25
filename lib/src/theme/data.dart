import 'package:finesse/src/theme/color_scheme/base.dart';
import 'package:finesse/src/theme/color_scheme/teal.dart';
import 'package:finesse/src/theme/components/accordion.dart';
import 'package:finesse/src/theme/components/alert.dart';
import 'package:finesse/src/theme/components/app_bar.dart';
import 'package:finesse/src/theme/components/avatar.dart';
import 'package:finesse/src/theme/components/badge.dart';
import 'package:finesse/src/theme/components/board.dart';
import 'package:finesse/src/theme/components/bottom_navigation_bar.dart';
import 'package:finesse/src/theme/components/breadcrumb.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/button_sizes.dart';
import 'package:finesse/src/theme/components/calendar.dart';
import 'package:finesse/src/theme/components/card.dart';
import 'package:finesse/src/theme/components/chat_bubble.dart';
import 'package:finesse/src/theme/components/chat_list.dart';
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
import 'package:finesse/src/theme/components/phosphor_icon.dart';
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
import 'package:finesse/src/theme/components/streaming_text.dart';
import 'package:finesse/src/theme/components/switch.dart';
import 'package:finesse/src/theme/components/table.dart';
import 'package:finesse/src/theme/components/tabs.dart';
import 'package:finesse/src/theme/components/text_field.dart';
import 'package:finesse/src/theme/components/textarea.dart';
import 'package:finesse/src/theme/components/time_field.dart';
import 'package:finesse/src/theme/components/time_picker.dart';
import 'package:finesse/src/theme/components/timeline.dart';
import 'package:finesse/src/theme/components/toast.dart';
import 'package:finesse/src/theme/components/toggle.dart';
import 'package:finesse/src/theme/components/tooltip.dart';
import 'package:finesse/src/theme/components/wheel_picker.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/radii.dart';
import 'package:finesse/src/theme/spacing.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:finesse/src/theme/text_theme/theme.dart';
import 'package:finesse/src/theme/themes/base.dart';
import 'package:finesse/src/theme/themes/default_theme_no_secondary_border_variant.dart';
import 'package:finesse/src/theme/themes/default_theme_variant.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/responsive.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'data.g.theme.dart';

/// The complete visual configuration of a Finesse app: colour scheme, text
/// theme, radius, style, spacing and every component theme.
///
/// The factory resolves its inputs into a [ThemeVariant], which derives the
/// component themes. An explicit component theme passed here is merged over the
/// variant's. Provide it to the tree with `FinesseApp` or `Theme` and read it
/// back with `Theme.of(context)`.
@immutable
@ThemeGen()
class ThemeData extends BaseTheme with _$ThemeData {
  /// Creates a theme.
  ///
  /// Every argument is optional. Null values take the variant's defaults, and
  /// the variant itself defaults to [DefaultThemeVariant], or
  /// [DefaultThemeNoSecondaryBorderVariant] when [disableSecondaryBorder]
  /// is true.
  factory ThemeData({
    /// The color scheme to use for the theme.
    /// Defaults to [TealColorScheme] based on the [brightness].
    ColorScheme? colorScheme,

    /// The overall brightness of the theme, defaults to [Brightness.light].
    Brightness? brightness,
    ButtonTheme? primaryButtonTheme,
    ButtonTheme? secondaryButtonTheme,
    ButtonTheme? destructiveButtonTheme,
    ButtonTheme? outlineButtonTheme,
    ButtonTheme? ghostButtonTheme,
    ButtonTheme? linkButtonTheme,
    BadgeTheme? primaryBadgeTheme,
    BadgeTheme? secondaryBadgeTheme,
    BadgeTheme? destructiveBadgeTheme,
    BadgeTheme? outlineBadgeTheme,
    BreadcrumbTheme? breadcrumbTheme,
    BorderRadius? radius,
    AvatarTheme? avatarTheme,
    ButtonSizesTheme? buttonSizesTheme,
    TooltipTheme? tooltipTheme,
    PopoverTheme? popoverTheme,
    FinesseDecoration? decoration,
    TextTheme? textTheme,
    double? disabledOpacity,
    SelectTheme? selectTheme,
    SelectOptionTheme? selectOptionTheme,
    CardTheme? cardTheme,
    SwitchTheme? switchTheme,
    CheckboxTheme? checkboxTheme,
    TextFieldTheme? textFieldTheme,
    RadioTheme? radioTheme,
    ToastTheme? primaryToastTheme,
    ToastTheme? destructiveToastTheme,
    Breakpoints? breakpoints,
    AlertTheme? primaryAlertTheme,
    AlertTheme? destructiveAlertTheme,
    DialogTheme? primaryDialogTheme,
    DialogTheme? alertDialogTheme,
    SliderTheme? sliderTheme,
    SheetTheme? sheetTheme,
    ProgressBarTheme? progressBarTheme,
    AccordionTheme? accordionTheme,
    TableTheme? tableTheme,
    ResizableTheme? resizableTheme,
    HoverStrategies? hoverStrategies,
    bool? disableSecondaryBorder,
    TabsTheme? tabsTheme,
    SkeletonTheme? skeletonTheme,
    KbdTheme? kbdTheme,
    GlassTheme? glassTheme,
    AppBarTheme? appBarTheme,
    NavigationBarTheme? navigationBarTheme,
    BottomNavigationBarTheme? bottomNavigationBarTheme,
    ChipTheme? chipTheme,
    ListTileTheme? listTileTheme,
    ChatBubbleTheme? chatBubbleTheme,
    ChatListTheme? chatListTheme,
    StreamingTextTheme? streamingTextTheme,
    IndicatorBadgeTheme? indicatorBadgeTheme,
    IconTileTheme? iconTileTheme,
    PhosphorIconTheme? phosphorIconTheme,
    TimelineTheme? timelineTheme,
    BoardTheme? boardTheme,
    LayoutTheme? layoutTheme,
    ScrollAreaTheme? scrollAreaTheme,
    SpinnerTheme? spinnerTheme,
    ToggleTheme? toggleTheme,
    ToggleTheme? outlineToggleTheme,
    EmptyTheme? emptyTheme,
    PaginationTheme? paginationTheme,
    CollapsibleTheme? collapsibleTheme,
    CommandTheme? commandTheme,
    SidebarTheme? sidebarTheme,
    ThemeVariant? variant,
    ContextMenuTheme? contextMenuTheme,
    CalendarTheme? calendarTheme,
    DatePickerTheme? datePickerTheme,
    TimePickerTheme? timePickerTheme,
    TimeFieldTheme? timeFieldTheme,
    WheelPickerTheme? wheelPickerTheme,
    OtpFieldTheme? otpFieldTheme,
    MenubarTheme? menubarTheme,
    DividerTheme? dividerTheme,
    SonnerTheme? sonnerTheme,
    TextareaTheme? textareaTheme,
    DefaultKeyboardToolbarTheme? defaultKeyboardToolbarTheme,

    /// The style: the radius, focus-ring and label treatment shared by every
    /// component. Defaults to [StyleTokens.finesse].
    ///
    /// When a [variant] is also given, the variant is rebuilt with this style.
    StyleTokens? style,

    /// The class of screen the theme is laid out for. [style] carries two
    /// sets of metrics; this picks one. `FinesseApp` sets it from the window
    /// width, so an app rarely passes it. Defaults to the variant's, or
    /// [FormFactor.desktop].
    FormFactor? formFactor,

    /// The spacing scale every padding and gap is a multiple of.
    ///
    /// When a [variant] is also given, the variant is rebuilt with this scale.
    Spacing? spacing,

    /// The palette menu surfaces draw from, when it differs from the page's.
    ///
    /// This is shadcn's "Inverted" menu colour: the reference gives every
    /// menu surface the `dark` class — the whole opposite-brightness token
    /// set — so pass the dark counterpart of [colorScheme] here and select,
    /// context-menu and menubar surfaces derive their colours from it.
    ColorScheme? menuColorScheme,

    /// Whether menu surfaces are translucent.
    ///
    /// Null leaves it to the [style]: menus are glass when its
    /// `popoverOpacity` is below 1, as in the default `finesse` style. True
    /// is shadcn's "Translucent" finish in any style — the popover colour at
    /// 70% over a backdrop blur, with row highlights as a `foreground/10`
    /// wash. False keeps menus solid even in a glass style.
    bool? menuTranslucent,

    /// How strongly menus highlight their rows; see [MenuAccent].
    ///
    /// Bold fills the highlighted row of a menu or a select with the menu
    /// palette's primary pair. Only menus change: [colorScheme] keeps its
    /// accent, and so does everything else that is drawn with it. Null
    /// keeps the [variant]'s, which is [MenuAccent.subtle] unless it was
    /// built otherwise.
    MenuAccent? menuAccent,

    /// The motion vocabulary every component animates with, in place of the
    /// [style]'s own (`StyleTokens.motion`). [Motion.none] switches every
    /// transition off; [Motion.calm] and [Motion.lively] are the shipped
    /// characters.
    Motion? motion,
  }) {
    // A motion override is a style override: the variant reads its motion
    // from the style, on both form factors.
    final styleForMotion = style ?? variant?.baseStyle ?? StyleTokens.finesse;
    final effectiveStyle = motion == null || motion == styleForMotion.motion
        ? style
        : styleForMotion.copyWith(
            motion: motion,
            mobile: styleForMotion.mobile?.copyWith(motion: motion),
          );

    // A variant is built from a colour scheme, a radius and a text theme, and
    // bakes all three into its component themes. Where the caller gives one
    // explicitly it wins and the variant is rebuilt below; where they don't,
    // the variant's own value becomes the theme's, so the two never disagree.
    //
    // shadcn/ui's `--radius` is 0.625rem and `--radius-md` — what button,
    // input, checkbox and most other components use via `rounded-md` — is
    // `calc(var(--radius) * 0.8)`, i.e. 8px.
    // The style a new variant is built from. With a variant and no style the
    // variant keeps its own.
    final defaultStyle =
        effectiveStyle ?? variant?.baseStyle ?? StyleTokens.finesse;
    final effectiveRadius =
        radius ??
        variant?.radius ??
        BorderRadius.all(Radius.circular(defaultStyle.radius));

    final effectiveTextTheme = textTheme == null
        ? (variant?.effectiveTextTheme ?? DefaultThemeVariant.defaultTextTheme)
        : DefaultThemeVariant.defaultTextTheme.merge(textTheme);

    final effectiveDisableSecondaryBorder = disableSecondaryBorder ?? false;
    // With no explicit brightness, follow the scheme: a dark scheme on a theme
    // that calls itself light gets light-mode menus, shadows and Material
    // colours. Schemes do not record their brightness, so read it off the
    // background.
    final schemeForBrightness = colorScheme ?? variant?.colorScheme;
    final effectiveBrightness =
        brightness ??
        (schemeForBrightness == null
            ? Brightness.light
            : _brightnessOf(schemeForBrightness.background));
    final effectiveColorScheme =
        colorScheme ??
        variant?.colorScheme ??
        switch (effectiveBrightness) {
          Brightness.light => const TealColorScheme.light(),
          Brightness.dark => const TealColorScheme.dark(),
        };

    // A supplied variant already baked the colour scheme, radius and text
    // theme into its component themes, so any of those that arrived separately
    // — which is what `copyWith(radius: …)` does — has to be pushed back into
    // it. Without this, `copyWith` would move the theme's own `radius` field
    // and leave every component rendering the old one.
    // Whether the menu options above require the variant to change; a custom
    // variant type cannot receive them (its `rebuild` does not know them), so
    // they only apply to the shipped variants.
    final menuOptionsChanged =
        variant is DefaultThemeVariant &&
        ((menuColorScheme != null &&
                menuColorScheme != variant.menuColorScheme) ||
            (menuTranslucent != null &&
                menuTranslucent != variant.menuTranslucent) ||
            (menuAccent != null && menuAccent != variant.menuAccent));

    final rebuiltVariant = variant == null
        ? null
        : (variant.colorScheme == effectiveColorScheme &&
                  variant.radius == effectiveRadius &&
                  // Either form counts as unchanged: the variant is built
                  // from a raw text theme but publishes one with the style's
                  // roles applied, and `copyWith` hands the published one
                  // back. Comparing only the raw form rebuilt the variant on
                  // every copy.
                  (variant.effectiveTextTheme == effectiveTextTheme ||
                      variant.textTheme() == effectiveTextTheme) &&
                  (effectiveStyle == null ||
                      effectiveStyle == variant.baseStyle) &&
                  (formFactor == null || formFactor == variant.formFactor) &&
                  (spacing == null || spacing == variant.spacing) &&
                  !menuOptionsChanged
              ? variant
              : variant is DefaultThemeVariant
              ? variant.rebuild(
                  colorScheme: effectiveColorScheme,
                  radius: effectiveRadius,
                  effectiveTextTheme: effectiveTextTheme,
                  style: effectiveStyle,
                  formFactor: formFactor,
                  spacing: spacing,
                  menuColorScheme:
                      menuColorScheme ??
                      DefaultThemeVariant.unsetMenuColorScheme,
                  menuTranslucent:
                      menuTranslucent ??
                      DefaultThemeVariant.unsetMenuTranslucent,
                  menuAccent: menuAccent,
                )
              : variant.rebuild(
                  colorScheme: effectiveColorScheme,
                  radius: effectiveRadius,
                  effectiveTextTheme: effectiveTextTheme,
                  style: effectiveStyle,
                  formFactor: formFactor,
                  spacing: spacing,
                ));

    final effectiveVariant =
        rebuiltVariant ??
        switch (effectiveDisableSecondaryBorder) {
          false => DefaultThemeVariant(
            colorScheme: effectiveColorScheme,
            radius: effectiveRadius,
            effectiveTextTheme: effectiveTextTheme,
            style: defaultStyle,
            formFactor: formFactor ?? FormFactor.desktop,
            spacing: spacing ?? const Spacing(),
            menuColorScheme: menuColorScheme,
            menuTranslucent: menuTranslucent,
            menuAccent: menuAccent ?? MenuAccent.subtle,
          ),
          true => DefaultThemeNoSecondaryBorderVariant(
            colorScheme: effectiveColorScheme,
            radius: effectiveRadius,
            effectiveTextTheme: effectiveTextTheme,
            style: defaultStyle,
            formFactor: formFactor ?? FormFactor.desktop,
            spacing: spacing ?? const Spacing(),
            menuColorScheme: menuColorScheme,
            menuTranslucent: menuTranslucent,
            menuAccent: menuAccent ?? MenuAccent.subtle,
          ),
        };

    return ThemeData._internal(
      inputs: _ThemeInputs(
        colorScheme: colorScheme,
        brightness: brightness,
        primaryButtonTheme: primaryButtonTheme,
        secondaryButtonTheme: secondaryButtonTheme,
        destructiveButtonTheme: destructiveButtonTheme,
        outlineButtonTheme: outlineButtonTheme,
        ghostButtonTheme: ghostButtonTheme,
        linkButtonTheme: linkButtonTheme,
        primaryBadgeTheme: primaryBadgeTheme,
        secondaryBadgeTheme: secondaryBadgeTheme,
        destructiveBadgeTheme: destructiveBadgeTheme,
        outlineBadgeTheme: outlineBadgeTheme,
        breadcrumbTheme: breadcrumbTheme,
        radius: radius,
        avatarTheme: avatarTheme,
        buttonSizesTheme: buttonSizesTheme,
        tooltipTheme: tooltipTheme,
        popoverTheme: popoverTheme,
        decoration: decoration,
        textTheme: textTheme,
        disabledOpacity: disabledOpacity,
        selectTheme: selectTheme,
        selectOptionTheme: selectOptionTheme,
        cardTheme: cardTheme,
        switchTheme: switchTheme,
        checkboxTheme: checkboxTheme,
        textFieldTheme: textFieldTheme,
        radioTheme: radioTheme,
        primaryToastTheme: primaryToastTheme,
        destructiveToastTheme: destructiveToastTheme,
        breakpoints: breakpoints,
        primaryAlertTheme: primaryAlertTheme,
        destructiveAlertTheme: destructiveAlertTheme,
        primaryDialogTheme: primaryDialogTheme,
        alertDialogTheme: alertDialogTheme,
        sliderTheme: sliderTheme,
        sheetTheme: sheetTheme,
        progressBarTheme: progressBarTheme,
        accordionTheme: accordionTheme,
        tableTheme: tableTheme,
        resizableTheme: resizableTheme,
        hoverStrategies: hoverStrategies,
        disableSecondaryBorder: disableSecondaryBorder,
        tabsTheme: tabsTheme,
        skeletonTheme: skeletonTheme,
        kbdTheme: kbdTheme,
        glassTheme: glassTheme,
        appBarTheme: appBarTheme,
        navigationBarTheme: navigationBarTheme,
        bottomNavigationBarTheme: bottomNavigationBarTheme,
        chipTheme: chipTheme,
        listTileTheme: listTileTheme,
        chatBubbleTheme: chatBubbleTheme,
        chatListTheme: chatListTheme,
        streamingTextTheme: streamingTextTheme,
        indicatorBadgeTheme: indicatorBadgeTheme,
        iconTileTheme: iconTileTheme,
        phosphorIconTheme: phosphorIconTheme,
        timelineTheme: timelineTheme,
        boardTheme: boardTheme,
        layoutTheme: layoutTheme,
        scrollAreaTheme: scrollAreaTheme,
        spinnerTheme: spinnerTheme,
        toggleTheme: toggleTheme,
        outlineToggleTheme: outlineToggleTheme,
        emptyTheme: emptyTheme,
        paginationTheme: paginationTheme,
        collapsibleTheme: collapsibleTheme,
        commandTheme: commandTheme,
        sidebarTheme: sidebarTheme,
        variant: variant,
        contextMenuTheme: contextMenuTheme,
        calendarTheme: calendarTheme,
        datePickerTheme: datePickerTheme,
        timePickerTheme: timePickerTheme,
        timeFieldTheme: timeFieldTheme,
        wheelPickerTheme: wheelPickerTheme,
        otpFieldTheme: otpFieldTheme,
        menubarTheme: menubarTheme,
        dividerTheme: dividerTheme,
        sonnerTheme: sonnerTheme,
        textareaTheme: textareaTheme,
        defaultKeyboardToolbarTheme: defaultKeyboardToolbarTheme,
        style: style,
        formFactor: formFactor,
        spacing: spacing,
        menuColorScheme: menuColorScheme,
        menuTranslucent: menuTranslucent,
        menuAccent: menuAccent,
        motion: motion,
      ),
      colorScheme: effectiveColorScheme,
      brightness: effectiveBrightness,
      primaryButtonTheme: effectiveVariant.primaryButtonTheme().merge(
        primaryButtonTheme,
      ),
      secondaryButtonTheme: effectiveVariant.secondaryButtonTheme().merge(
        secondaryButtonTheme,
      ),
      destructiveButtonTheme: effectiveVariant.destructiveButtonTheme().merge(
        destructiveButtonTheme,
      ),
      outlineButtonTheme: effectiveVariant.outlineButtonTheme().merge(
        outlineButtonTheme,
      ),
      ghostButtonTheme: effectiveVariant.ghostButtonTheme().merge(
        ghostButtonTheme,
      ),
      linkButtonTheme: effectiveVariant.linkButtonTheme().merge(
        linkButtonTheme,
      ),
      primaryBadgeTheme: effectiveVariant.primaryBadgeTheme().merge(
        primaryBadgeTheme,
      ),
      secondaryBadgeTheme: effectiveVariant.secondaryBadgeTheme().merge(
        secondaryBadgeTheme,
      ),
      destructiveBadgeTheme: effectiveVariant.destructiveBadgeTheme().merge(
        destructiveBadgeTheme,
      ),
      outlineBadgeTheme: effectiveVariant.outlineBadgeTheme().merge(
        outlineBadgeTheme,
      ),
      breadcrumbTheme: effectiveVariant.breadcrumbTheme().merge(
        breadcrumbTheme,
      ),
      buttonSizesTheme: effectiveVariant.buttonSizesTheme().merge(
        buttonSizesTheme,
      ),
      radius: effectiveRadius,
      avatarTheme: effectiveVariant.avatarTheme().merge(avatarTheme),
      tooltipTheme: effectiveVariant.tooltipTheme().merge(tooltipTheme),
      popoverTheme: effectiveVariant.popoverTheme().merge(popoverTheme),
      decoration: effectiveVariant.decorationTheme().merge(decoration),
      // Through the variant, so the style's text roles are applied to the UI
      // entries. Reading `effectiveTextTheme` directly here is what used to
      // make a style change leave every font size untouched.
      textTheme: effectiveVariant.textTheme(),
      disabledOpacity: disabledOpacity ?? .5,
      selectTheme: effectiveVariant.selectTheme().merge(selectTheme),
      selectOptionTheme: effectiveVariant.selectOptionTheme().merge(
        selectOptionTheme,
      ),
      cardTheme: effectiveVariant.cardTheme().merge(cardTheme),
      switchTheme: effectiveVariant.switchTheme().merge(switchTheme),
      checkboxTheme: effectiveVariant.checkboxTheme().merge(checkboxTheme),
      textFieldTheme: effectiveVariant.textFieldTheme().merge(textFieldTheme),
      radioTheme: effectiveVariant.radioTheme().merge(radioTheme),
      primaryToastTheme: effectiveVariant.primaryToastTheme().merge(
        primaryToastTheme,
      ),
      destructiveToastTheme: effectiveVariant.destructiveToastTheme().merge(
        destructiveToastTheme,
      ),
      breakpoints: breakpoints ?? Breakpoints(),
      primaryAlertTheme: effectiveVariant.primaryAlertTheme().merge(
        primaryAlertTheme,
      ),
      destructiveAlertTheme: effectiveVariant.destructiveAlertTheme().merge(
        destructiveAlertTheme,
      ),
      primaryDialogTheme: effectiveVariant.primaryDialogTheme().merge(
        primaryDialogTheme,
      ),
      alertDialogTheme: effectiveVariant.alertDialogTheme().merge(
        alertDialogTheme,
      ),
      sliderTheme: effectiveVariant.sliderTheme().merge(sliderTheme),
      sheetTheme: effectiveVariant.sheetTheme().merge(sheetTheme),
      progressBarTheme: effectiveVariant.progressBarTheme().merge(
        progressBarTheme,
      ),
      accordionTheme: effectiveVariant.accordionTheme().merge(accordionTheme),
      tableTheme: effectiveVariant.tableTheme().merge(tableTheme),
      resizableTheme: effectiveVariant.resizableTheme().merge(resizableTheme),
      hoverStrategies: hoverStrategies ?? effectiveVariant.hoverStrategies(),
      disableSecondaryBorder: effectiveDisableSecondaryBorder,
      tabsTheme: effectiveVariant.tabsTheme().merge(tabsTheme),
      contextMenuTheme: effectiveVariant.contextMenuTheme().merge(
        contextMenuTheme,
      ),
      calendarTheme: effectiveVariant.calendarTheme().merge(calendarTheme),
      datePickerTheme: effectiveVariant.datePickerTheme().merge(
        datePickerTheme,
      ),
      timePickerTheme: effectiveVariant.timePickerTheme().merge(
        timePickerTheme,
      ),
      timeFieldTheme: effectiveVariant.timeFieldTheme().merge(timeFieldTheme),
      wheelPickerTheme: effectiveVariant.wheelPickerTheme().merge(
        wheelPickerTheme,
      ),
      otpFieldTheme: effectiveVariant.otpFieldTheme().merge(otpFieldTheme),
      menubarTheme: effectiveVariant.menubarTheme().merge(menubarTheme),
      dividerTheme: effectiveVariant.dividerTheme().merge(dividerTheme),
      sonnerTheme: effectiveVariant.sonnerTheme().merge(sonnerTheme),
      textareaTheme: effectiveVariant.textareaTheme().merge(textareaTheme),
      defaultKeyboardToolbarTheme: effectiveVariant
          .defaultKeyboardToolbarTheme()
          .merge(defaultKeyboardToolbarTheme),
      skeletonTheme: effectiveVariant.skeletonTheme().merge(skeletonTheme),
      kbdTheme: effectiveVariant.kbdTheme().merge(kbdTheme),
      glassTheme: effectiveVariant.glassTheme().merge(glassTheme),
      appBarTheme: effectiveVariant.appBarTheme().merge(appBarTheme),
      navigationBarTheme: effectiveVariant.navigationBarTheme().merge(
        navigationBarTheme,
      ),
      bottomNavigationBarTheme: effectiveVariant
          .bottomNavigationBarTheme()
          .merge(bottomNavigationBarTheme),
      chipTheme: effectiveVariant.chipTheme().merge(chipTheme),
      listTileTheme: effectiveVariant.listTileTheme().merge(listTileTheme),
      chatBubbleTheme: effectiveVariant.chatBubbleTheme().merge(
        chatBubbleTheme,
      ),
      chatListTheme: effectiveVariant.chatListTheme().merge(chatListTheme),
      streamingTextTheme: effectiveVariant.streamingTextTheme().merge(
        streamingTextTheme,
      ),
      indicatorBadgeTheme: effectiveVariant.indicatorBadgeTheme().merge(
        indicatorBadgeTheme,
      ),
      iconTileTheme: effectiveVariant.iconTileTheme().merge(iconTileTheme),
      phosphorIconTheme: effectiveVariant.phosphorIconTheme().merge(
        phosphorIconTheme,
      ),
      timelineTheme: effectiveVariant.timelineTheme().merge(timelineTheme),
      boardTheme: effectiveVariant.boardTheme().merge(boardTheme),
      layoutTheme: effectiveVariant.layoutTheme().merge(layoutTheme),
      scrollAreaTheme: effectiveVariant.scrollAreaTheme().merge(
        scrollAreaTheme,
      ),
      spinnerTheme: effectiveVariant.spinnerTheme().merge(spinnerTheme),
      toggleTheme: effectiveVariant.toggleTheme().merge(toggleTheme),
      outlineToggleTheme: effectiveVariant.outlineToggleTheme().merge(
        outlineToggleTheme,
      ),
      emptyTheme: effectiveVariant.emptyTheme().merge(emptyTheme),
      paginationTheme: effectiveVariant.paginationTheme().merge(
        paginationTheme,
      ),
      collapsibleTheme: effectiveVariant.collapsibleTheme().merge(
        collapsibleTheme,
      ),
      commandTheme: effectiveVariant.commandTheme().merge(commandTheme),
      sidebarTheme: effectiveVariant.sidebarTheme().merge(sidebarTheme),
      variant: effectiveVariant,
    );
  }

  const ThemeData._internal({
    required _ThemeInputs inputs,
    required super.colorScheme,
    required super.brightness,
    required super.primaryButtonTheme,
    required super.secondaryButtonTheme,
    required super.destructiveButtonTheme,
    required super.outlineButtonTheme,
    required super.ghostButtonTheme,
    required super.linkButtonTheme,
    required super.primaryBadgeTheme,
    required super.secondaryBadgeTheme,
    required super.destructiveBadgeTheme,
    required super.outlineBadgeTheme,
    required super.breadcrumbTheme,
    required super.radius,
    required super.avatarTheme,
    required super.buttonSizesTheme,
    required super.tooltipTheme,
    required super.popoverTheme,
    required super.decoration,
    required super.textTheme,
    required super.disabledOpacity,
    required super.selectTheme,
    required super.selectOptionTheme,
    required super.cardTheme,
    required super.switchTheme,
    required super.checkboxTheme,
    required super.textFieldTheme,
    required super.radioTheme,
    required super.primaryToastTheme,
    required super.destructiveToastTheme,
    required super.breakpoints,
    required super.primaryAlertTheme,
    required super.destructiveAlertTheme,
    required super.primaryDialogTheme,
    required super.alertDialogTheme,
    required super.sliderTheme,
    required super.sheetTheme,
    required super.progressBarTheme,
    required super.accordionTheme,
    required super.tableTheme,
    required super.resizableTheme,
    required super.hoverStrategies,
    required super.disableSecondaryBorder,
    required super.tabsTheme,
    required super.contextMenuTheme,
    required super.calendarTheme,
    required super.datePickerTheme,
    required super.timePickerTheme,
    required super.timeFieldTheme,
    required super.wheelPickerTheme,
    required super.otpFieldTheme,
    required super.menubarTheme,
    required super.dividerTheme,
    required super.sonnerTheme,
    required super.textareaTheme,
    required super.defaultKeyboardToolbarTheme,
    required super.skeletonTheme,
    required super.kbdTheme,
    required super.glassTheme,
    required super.appBarTheme,
    required super.navigationBarTheme,
    required super.bottomNavigationBarTheme,
    required super.chipTheme,
    required super.listTileTheme,
    required super.chatBubbleTheme,
    required super.chatListTheme,
    required super.streamingTextTheme,
    required super.indicatorBadgeTheme,
    required super.iconTileTheme,
    required super.phosphorIconTheme,
    required super.timelineTheme,
    required super.boardTheme,
    required super.layoutTheme,
    required super.scrollAreaTheme,
    required super.spinnerTheme,
    required super.toggleTheme,
    required super.outlineToggleTheme,
    required super.emptyTheme,
    required super.paginationTheme,
    required super.collapsibleTheme,
    required super.commandTheme,
    required super.sidebarTheme,
    required super.variant,
  }) : _inputs = inputs;

  /// What the caller passed to the factory, so [copyWith] can derive the
  /// theme again instead of copying already-resolved component themes.
  @ignore
  final _ThemeInputs _inputs;

  /// Creates a copy of this theme with the given inputs replaced.
  ///
  /// This runs the [ThemeData] factory again, from the inputs this theme
  /// was built from with the given ones replacing them. So
  /// `copyWith(radius: ...)`, `copyWith(colorScheme: ...)`,
  /// `copyWith(style: ...)` or `copyWith(disableSecondaryBorder: true)`
  /// re-derive every component theme. Component themes passed here are merged
  /// over the derived ones, exactly as in the factory.
  @override
  ThemeData copyWith({
    ColorScheme? colorScheme,
    Brightness? brightness,
    ButtonTheme? primaryButtonTheme,
    ButtonTheme? secondaryButtonTheme,
    ButtonTheme? destructiveButtonTheme,
    ButtonTheme? outlineButtonTheme,
    ButtonTheme? ghostButtonTheme,
    ButtonTheme? linkButtonTheme,
    BadgeTheme? primaryBadgeTheme,
    BadgeTheme? secondaryBadgeTheme,
    BadgeTheme? destructiveBadgeTheme,
    BadgeTheme? outlineBadgeTheme,
    BreadcrumbTheme? breadcrumbTheme,
    BorderRadius? radius,
    AvatarTheme? avatarTheme,
    ButtonSizesTheme? buttonSizesTheme,
    TooltipTheme? tooltipTheme,
    PopoverTheme? popoverTheme,
    FinesseDecoration? decoration,
    TextTheme? textTheme,
    double? disabledOpacity,
    SelectTheme? selectTheme,
    SelectOptionTheme? selectOptionTheme,
    CardTheme? cardTheme,
    SwitchTheme? switchTheme,
    CheckboxTheme? checkboxTheme,
    TextFieldTheme? textFieldTheme,
    RadioTheme? radioTheme,
    ToastTheme? primaryToastTheme,
    ToastTheme? destructiveToastTheme,
    Breakpoints? breakpoints,
    AlertTheme? primaryAlertTheme,
    AlertTheme? destructiveAlertTheme,
    DialogTheme? primaryDialogTheme,
    DialogTheme? alertDialogTheme,
    SliderTheme? sliderTheme,
    SheetTheme? sheetTheme,
    ProgressBarTheme? progressBarTheme,
    AccordionTheme? accordionTheme,
    TableTheme? tableTheme,
    ResizableTheme? resizableTheme,
    HoverStrategies? hoverStrategies,
    bool? disableSecondaryBorder,
    TabsTheme? tabsTheme,
    SkeletonTheme? skeletonTheme,
    KbdTheme? kbdTheme,
    GlassTheme? glassTheme,
    AppBarTheme? appBarTheme,
    NavigationBarTheme? navigationBarTheme,
    BottomNavigationBarTheme? bottomNavigationBarTheme,
    ChipTheme? chipTheme,
    ListTileTheme? listTileTheme,
    ChatBubbleTheme? chatBubbleTheme,
    ChatListTheme? chatListTheme,
    StreamingTextTheme? streamingTextTheme,
    IndicatorBadgeTheme? indicatorBadgeTheme,
    IconTileTheme? iconTileTheme,
    PhosphorIconTheme? phosphorIconTheme,
    TimelineTheme? timelineTheme,
    BoardTheme? boardTheme,
    LayoutTheme? layoutTheme,
    ScrollAreaTheme? scrollAreaTheme,
    SpinnerTheme? spinnerTheme,
    ToggleTheme? toggleTheme,
    ToggleTheme? outlineToggleTheme,
    EmptyTheme? emptyTheme,
    PaginationTheme? paginationTheme,
    CollapsibleTheme? collapsibleTheme,
    CommandTheme? commandTheme,
    SidebarTheme? sidebarTheme,
    ThemeVariant? variant,
    ContextMenuTheme? contextMenuTheme,
    CalendarTheme? calendarTheme,
    DatePickerTheme? datePickerTheme,
    TimePickerTheme? timePickerTheme,
    TimeFieldTheme? timeFieldTheme,
    WheelPickerTheme? wheelPickerTheme,
    OtpFieldTheme? otpFieldTheme,
    MenubarTheme? menubarTheme,
    DividerTheme? dividerTheme,
    SonnerTheme? sonnerTheme,
    TextareaTheme? textareaTheme,
    DefaultKeyboardToolbarTheme? defaultKeyboardToolbarTheme,
    StyleTokens? style,
    FormFactor? formFactor,
    Spacing? spacing,
    ColorScheme? menuColorScheme,
    bool? menuTranslucent,
    MenuAccent? menuAccent,
    Motion? motion,
  }) {
    final i = _inputs;
    return ThemeData(
      colorScheme: colorScheme ?? i.colorScheme,
      brightness: brightness ?? i.brightness,
      primaryButtonTheme: primaryButtonTheme ?? i.primaryButtonTheme,
      secondaryButtonTheme: secondaryButtonTheme ?? i.secondaryButtonTheme,
      destructiveButtonTheme:
          destructiveButtonTheme ?? i.destructiveButtonTheme,
      outlineButtonTheme: outlineButtonTheme ?? i.outlineButtonTheme,
      ghostButtonTheme: ghostButtonTheme ?? i.ghostButtonTheme,
      linkButtonTheme: linkButtonTheme ?? i.linkButtonTheme,
      primaryBadgeTheme: primaryBadgeTheme ?? i.primaryBadgeTheme,
      secondaryBadgeTheme: secondaryBadgeTheme ?? i.secondaryBadgeTheme,
      destructiveBadgeTheme: destructiveBadgeTheme ?? i.destructiveBadgeTheme,
      outlineBadgeTheme: outlineBadgeTheme ?? i.outlineBadgeTheme,
      breadcrumbTheme: breadcrumbTheme ?? i.breadcrumbTheme,
      radius: radius ?? i.radius,
      avatarTheme: avatarTheme ?? i.avatarTheme,
      buttonSizesTheme: buttonSizesTheme ?? i.buttonSizesTheme,
      tooltipTheme: tooltipTheme ?? i.tooltipTheme,
      popoverTheme: popoverTheme ?? i.popoverTheme,
      decoration: decoration ?? i.decoration,
      textTheme: textTheme ?? i.textTheme,
      disabledOpacity: disabledOpacity ?? i.disabledOpacity,
      selectTheme: selectTheme ?? i.selectTheme,
      selectOptionTheme: selectOptionTheme ?? i.selectOptionTheme,
      cardTheme: cardTheme ?? i.cardTheme,
      switchTheme: switchTheme ?? i.switchTheme,
      checkboxTheme: checkboxTheme ?? i.checkboxTheme,
      textFieldTheme: textFieldTheme ?? i.textFieldTheme,
      radioTheme: radioTheme ?? i.radioTheme,
      primaryToastTheme: primaryToastTheme ?? i.primaryToastTheme,
      destructiveToastTheme: destructiveToastTheme ?? i.destructiveToastTheme,
      breakpoints: breakpoints ?? i.breakpoints,
      primaryAlertTheme: primaryAlertTheme ?? i.primaryAlertTheme,
      destructiveAlertTheme: destructiveAlertTheme ?? i.destructiveAlertTheme,
      primaryDialogTheme: primaryDialogTheme ?? i.primaryDialogTheme,
      alertDialogTheme: alertDialogTheme ?? i.alertDialogTheme,
      sliderTheme: sliderTheme ?? i.sliderTheme,
      sheetTheme: sheetTheme ?? i.sheetTheme,
      progressBarTheme: progressBarTheme ?? i.progressBarTheme,
      accordionTheme: accordionTheme ?? i.accordionTheme,
      tableTheme: tableTheme ?? i.tableTheme,
      resizableTheme: resizableTheme ?? i.resizableTheme,
      hoverStrategies: hoverStrategies ?? i.hoverStrategies,
      disableSecondaryBorder:
          disableSecondaryBorder ?? i.disableSecondaryBorder,
      tabsTheme: tabsTheme ?? i.tabsTheme,
      skeletonTheme: skeletonTheme ?? i.skeletonTheme,
      kbdTheme: kbdTheme ?? i.kbdTheme,
      glassTheme: glassTheme ?? i.glassTheme,
      appBarTheme: appBarTheme ?? i.appBarTheme,
      navigationBarTheme: navigationBarTheme ?? i.navigationBarTheme,
      bottomNavigationBarTheme:
          bottomNavigationBarTheme ?? i.bottomNavigationBarTheme,
      chipTheme: chipTheme ?? i.chipTheme,
      listTileTheme: listTileTheme ?? i.listTileTheme,
      chatBubbleTheme: chatBubbleTheme ?? i.chatBubbleTheme,
      chatListTheme: chatListTheme ?? i.chatListTheme,
      streamingTextTheme: streamingTextTheme ?? i.streamingTextTheme,
      indicatorBadgeTheme: indicatorBadgeTheme ?? i.indicatorBadgeTheme,
      iconTileTheme: iconTileTheme ?? i.iconTileTheme,
      phosphorIconTheme: phosphorIconTheme ?? i.phosphorIconTheme,
      timelineTheme: timelineTheme ?? i.timelineTheme,
      boardTheme: boardTheme ?? i.boardTheme,
      layoutTheme: layoutTheme ?? i.layoutTheme,
      scrollAreaTheme: scrollAreaTheme ?? i.scrollAreaTheme,
      spinnerTheme: spinnerTheme ?? i.spinnerTheme,
      toggleTheme: toggleTheme ?? i.toggleTheme,
      outlineToggleTheme: outlineToggleTheme ?? i.outlineToggleTheme,
      emptyTheme: emptyTheme ?? i.emptyTheme,
      paginationTheme: paginationTheme ?? i.paginationTheme,
      collapsibleTheme: collapsibleTheme ?? i.collapsibleTheme,
      commandTheme: commandTheme ?? i.commandTheme,
      sidebarTheme: sidebarTheme ?? i.sidebarTheme,
      variant: variant ?? i.variant,
      contextMenuTheme: contextMenuTheme ?? i.contextMenuTheme,
      calendarTheme: calendarTheme ?? i.calendarTheme,
      datePickerTheme: datePickerTheme ?? i.datePickerTheme,
      timePickerTheme: timePickerTheme ?? i.timePickerTheme,
      timeFieldTheme: timeFieldTheme ?? i.timeFieldTheme,
      wheelPickerTheme: wheelPickerTheme ?? i.wheelPickerTheme,
      otpFieldTheme: otpFieldTheme ?? i.otpFieldTheme,
      menubarTheme: menubarTheme ?? i.menubarTheme,
      dividerTheme: dividerTheme ?? i.dividerTheme,
      sonnerTheme: sonnerTheme ?? i.sonnerTheme,
      textareaTheme: textareaTheme ?? i.textareaTheme,
      defaultKeyboardToolbarTheme:
          defaultKeyboardToolbarTheme ?? i.defaultKeyboardToolbarTheme,
      style: style ?? i.style,
      formFactor: formFactor ?? i.formFactor,
      spacing: spacing ?? i.spacing,
      menuColorScheme: menuColorScheme ?? i.menuColorScheme,
      menuTranslucent: menuTranslucent ?? i.menuTranslucent,
      menuAccent: menuAccent ?? i.menuAccent,
      motion: motion ?? i.motion,
    );
  }

  /// The corner-radius scale derived from [radius].
  ///
  /// [radius] is the `md` step — what buttons and inputs use — and the other
  /// steps scale from it, so one setting keeps cards, dialogs and menu rows in
  /// proportion.
  Radii get radii => variant.radii;

  /// The shadcn/ui style this theme renders.
  /// The style's metrics for this theme's [formFactor]. Components read
  /// this.
  ///
  /// It is not what the theme was created with on a phone: to carry a style
  /// over to another theme, pass [baseStyle].
  StyleTokens get style => variant.style;

  /// The style this theme was created with, before [formFactor] picked a set
  /// of metrics from it. `ThemeData(style: other.baseStyle)` reproduces
  /// `other`'s style on either form factor; `other.style` would bake a
  /// phone's metrics in as the desktop ones.
  StyleTokens get baseStyle => variant.baseStyle;

  /// A button decoration with [radius] corners whose focus ring follows the
  /// same curve.
  ///
  /// Pass it to a `Button` or `IconButton` to reshape one — a pill "Follow",
  /// a square icon button — without the ring staying behind as a rounded
  /// rectangle:
  ///
  /// ```dart
  /// Button.outline(
  ///   decoration: theme.buttonDecoration(radius: theme.radii.full),
  ///   onPressed: _follow,
  ///   child: const Text('Follow'),
  /// )
  /// ```
  FinesseDecoration buttonDecoration({required BorderRadius radius}) {
    final themeVariant = variant;
    return FinesseDecoration(
      border: FinesseBorder(radius: radius),
      secondaryFocusedBorder:
          themeVariant is DefaultThemeVariant && !disableSecondaryBorder
          ? themeVariant.ringFor(radius)
          : null,
    );
  }

  /// The class of screen this theme's metrics are for.
  FormFactor get formFactor => variant.formFactor;

  /// The motion vocabulary of this theme: its style's, or the one passed to
  /// the factory.
  ///
  /// Components read it through `Motion.of(context)`, which also honours the
  /// platform's reduced-motion setting.
  Motion get motion => variant.style.motion;

  /// This theme laid out for [formFactor].
  ///
  /// Returns this theme when it already is, and otherwise rebuilds every
  /// component theme from the style's other set of metrics. The result is
  /// cached, so `FinesseApp` can call this on every build.
  ThemeData withFormFactor(FormFactor formFactor) {
    if (formFactor == this.formFactor) return this;
    return _formFactorCache[this] ??= copyWith(formFactor: formFactor);
  }

  static final _formFactorCache = Expando<ThemeData>();

  /// The spacing scale every padding and gap is a multiple of.
  ///
  /// Call it to convert steps to logical pixels: `theme.spacing(6)` is `24`
  /// with the default step. See `Gap` and `FinessePadding` for laying out
  /// against the scale directly.
  Spacing get spacing => variant.spacing;

  /// Linearly interpolates between [a] and [b] by [t].
  static ThemeData? lerp(
    ThemeData? a,
    ThemeData? b,
    double t,
  ) => _$ThemeData.lerp(a, b, t);
}

/// Whether [color] reads as a light or a dark background, by the same rule
/// as Material's `ThemeData.estimateBrightnessForColor`.
Brightness _brightnessOf(Color color) {
  final luminance = color.computeLuminance();
  return (luminance + 0.05) * (luminance + 0.05) > 0.15
      ? Brightness.light
      : Brightness.dark;
}

/// The arguments a [ThemeData] was created with.
@immutable
final class _ThemeInputs {
  const _ThemeInputs({
    this.colorScheme,
    this.brightness,
    this.primaryButtonTheme,
    this.secondaryButtonTheme,
    this.destructiveButtonTheme,
    this.outlineButtonTheme,
    this.ghostButtonTheme,
    this.linkButtonTheme,
    this.primaryBadgeTheme,
    this.secondaryBadgeTheme,
    this.destructiveBadgeTheme,
    this.outlineBadgeTheme,
    this.breadcrumbTheme,
    this.radius,
    this.avatarTheme,
    this.buttonSizesTheme,
    this.tooltipTheme,
    this.popoverTheme,
    this.decoration,
    this.textTheme,
    this.disabledOpacity,
    this.selectTheme,
    this.selectOptionTheme,
    this.cardTheme,
    this.switchTheme,
    this.checkboxTheme,
    this.textFieldTheme,
    this.radioTheme,
    this.primaryToastTheme,
    this.destructiveToastTheme,
    this.breakpoints,
    this.primaryAlertTheme,
    this.destructiveAlertTheme,
    this.primaryDialogTheme,
    this.alertDialogTheme,
    this.sliderTheme,
    this.sheetTheme,
    this.progressBarTheme,
    this.accordionTheme,
    this.tableTheme,
    this.resizableTheme,
    this.hoverStrategies,
    this.disableSecondaryBorder,
    this.tabsTheme,
    this.skeletonTheme,
    this.kbdTheme,
    this.glassTheme,
    this.appBarTheme,
    this.navigationBarTheme,
    this.bottomNavigationBarTheme,
    this.chipTheme,
    this.listTileTheme,
    this.chatBubbleTheme,
    this.chatListTheme,
    this.streamingTextTheme,
    this.indicatorBadgeTheme,
    this.iconTileTheme,
    this.phosphorIconTheme,
    this.timelineTheme,
    this.boardTheme,
    this.layoutTheme,
    this.scrollAreaTheme,
    this.spinnerTheme,
    this.toggleTheme,
    this.outlineToggleTheme,
    this.emptyTheme,
    this.paginationTheme,
    this.collapsibleTheme,
    this.commandTheme,
    this.sidebarTheme,
    this.variant,
    this.contextMenuTheme,
    this.calendarTheme,
    this.datePickerTheme,
    this.timePickerTheme,
    this.timeFieldTheme,
    this.wheelPickerTheme,
    this.otpFieldTheme,
    this.menubarTheme,
    this.dividerTheme,
    this.sonnerTheme,
    this.textareaTheme,
    this.defaultKeyboardToolbarTheme,
    this.style,
    this.formFactor,
    this.spacing,
    this.menuColorScheme,
    this.menuTranslucent,
    this.menuAccent,
    this.motion,
  });

  final ColorScheme? colorScheme;
  final Brightness? brightness;
  final ButtonTheme? primaryButtonTheme;
  final ButtonTheme? secondaryButtonTheme;
  final ButtonTheme? destructiveButtonTheme;
  final ButtonTheme? outlineButtonTheme;
  final ButtonTheme? ghostButtonTheme;
  final ButtonTheme? linkButtonTheme;
  final BadgeTheme? primaryBadgeTheme;
  final BadgeTheme? secondaryBadgeTheme;
  final BadgeTheme? destructiveBadgeTheme;
  final BadgeTheme? outlineBadgeTheme;
  final BreadcrumbTheme? breadcrumbTheme;
  final BorderRadius? radius;
  final AvatarTheme? avatarTheme;
  final ButtonSizesTheme? buttonSizesTheme;
  final TooltipTheme? tooltipTheme;
  final PopoverTheme? popoverTheme;
  final FinesseDecoration? decoration;
  final TextTheme? textTheme;
  final double? disabledOpacity;
  final SelectTheme? selectTheme;
  final SelectOptionTheme? selectOptionTheme;
  final CardTheme? cardTheme;
  final SwitchTheme? switchTheme;
  final CheckboxTheme? checkboxTheme;
  final TextFieldTheme? textFieldTheme;
  final RadioTheme? radioTheme;
  final ToastTheme? primaryToastTheme;
  final ToastTheme? destructiveToastTheme;
  final Breakpoints? breakpoints;
  final AlertTheme? primaryAlertTheme;
  final AlertTheme? destructiveAlertTheme;
  final DialogTheme? primaryDialogTheme;
  final DialogTheme? alertDialogTheme;
  final SliderTheme? sliderTheme;
  final SheetTheme? sheetTheme;
  final ProgressBarTheme? progressBarTheme;
  final AccordionTheme? accordionTheme;
  final TableTheme? tableTheme;
  final ResizableTheme? resizableTheme;
  final HoverStrategies? hoverStrategies;
  final bool? disableSecondaryBorder;
  final TabsTheme? tabsTheme;
  final SkeletonTheme? skeletonTheme;
  final KbdTheme? kbdTheme;
  final GlassTheme? glassTheme;
  final AppBarTheme? appBarTheme;
  final NavigationBarTheme? navigationBarTheme;
  final BottomNavigationBarTheme? bottomNavigationBarTheme;
  final ChipTheme? chipTheme;
  final ListTileTheme? listTileTheme;
  final ChatBubbleTheme? chatBubbleTheme;
  final ChatListTheme? chatListTheme;
  final StreamingTextTheme? streamingTextTheme;
  final IndicatorBadgeTheme? indicatorBadgeTheme;
  final IconTileTheme? iconTileTheme;
  final PhosphorIconTheme? phosphorIconTheme;
  final TimelineTheme? timelineTheme;
  final BoardTheme? boardTheme;
  final LayoutTheme? layoutTheme;
  final ScrollAreaTheme? scrollAreaTheme;
  final SpinnerTheme? spinnerTheme;
  final ToggleTheme? toggleTheme;
  final ToggleTheme? outlineToggleTheme;
  final EmptyTheme? emptyTheme;
  final PaginationTheme? paginationTheme;
  final CollapsibleTheme? collapsibleTheme;
  final CommandTheme? commandTheme;
  final SidebarTheme? sidebarTheme;
  final ThemeVariant? variant;
  final ContextMenuTheme? contextMenuTheme;
  final CalendarTheme? calendarTheme;
  final DatePickerTheme? datePickerTheme;
  final TimePickerTheme? timePickerTheme;
  final TimeFieldTheme? timeFieldTheme;
  final WheelPickerTheme? wheelPickerTheme;
  final OtpFieldTheme? otpFieldTheme;
  final MenubarTheme? menubarTheme;
  final DividerTheme? dividerTheme;
  final SonnerTheme? sonnerTheme;
  final TextareaTheme? textareaTheme;
  final DefaultKeyboardToolbarTheme? defaultKeyboardToolbarTheme;
  final StyleTokens? style;
  final FormFactor? formFactor;
  final Spacing? spacing;
  final ColorScheme? menuColorScheme;
  final bool? menuTranslucent;
  final MenuAccent? menuAccent;
  final Motion? motion;
}
