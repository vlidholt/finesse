import 'package:finesse/src/theme/color_scheme/base.dart';
import 'package:finesse/src/theme/components/accordion.dart';
import 'package:finesse/src/theme/components/alert.dart';
import 'package:finesse/src/theme/components/avatar.dart';
import 'package:finesse/src/theme/components/badge.dart';
import 'package:finesse/src/theme/components/breadcrumb.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/button_sizes.dart';
import 'package:finesse/src/theme/components/calendar.dart';
import 'package:finesse/src/theme/components/card.dart';
import 'package:finesse/src/theme/components/checkbox.dart';
import 'package:finesse/src/theme/components/collapsible.dart';
import 'package:finesse/src/theme/components/command.dart';
import 'package:finesse/src/theme/components/context_menu.dart';
import 'package:finesse/src/theme/components/date_picker.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/default_keyboard_toolbar.dart';
import 'package:finesse/src/theme/components/dialog.dart';
import 'package:finesse/src/theme/components/divider.dart';
import 'package:finesse/src/theme/components/empty.dart';
import 'package:finesse/src/theme/components/kbd.dart';
import 'package:finesse/src/theme/components/glass.dart';
import 'package:finesse/src/theme/components/app_bar.dart';
import 'package:finesse/src/theme/components/navigation_bar.dart';
import 'package:finesse/src/theme/components/bottom_navigation_bar.dart';
import 'package:finesse/src/theme/components/chip.dart';
import 'package:finesse/src/theme/components/list_tile.dart';
import 'package:finesse/src/theme/components/chat_bubble.dart';
import 'package:finesse/src/theme/components/indicator_badge.dart';
import 'package:finesse/src/theme/components/icon_tile.dart';
import 'package:finesse/src/theme/components/timeline.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/components/menubar.dart';
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
import 'package:finesse/src/theme/components/toast.dart';
import 'package:finesse/src/theme/components/toggle.dart';
import 'package:finesse/src/theme/components/tooltip.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/radii.dart';
import 'package:finesse/src/theme/spacing.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:finesse/src/theme/text_theme/theme.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/responsive.dart';
import 'package:flutter/widgets.dart';

/// The resolved values of a theme: the colour scheme, the text theme, the
/// shared settings and one theme per component.
///
/// `ThemeData` is the only implementation. Its fields are documented here.
@immutable
abstract class BaseTheme {
  /// Creates a base theme with every value given.
  const BaseTheme({
    required this.colorScheme,
    required this.brightness,
    required this.primaryButtonTheme,
    required this.secondaryButtonTheme,
    required this.destructiveButtonTheme,
    required this.outlineButtonTheme,
    required this.ghostButtonTheme,
    required this.linkButtonTheme,
    required this.primaryBadgeTheme,
    required this.secondaryBadgeTheme,
    required this.destructiveBadgeTheme,
    required this.outlineBadgeTheme,
    required this.breadcrumbTheme,
    required this.radius,
    required this.avatarTheme,
    required this.buttonSizesTheme,
    required this.tooltipTheme,
    required this.popoverTheme,
    required this.decoration,
    required this.textTheme,
    required this.disabledOpacity,
    required this.selectTheme,
    required this.selectOptionTheme,
    required this.cardTheme,
    required this.switchTheme,
    required this.checkboxTheme,
    required this.textFieldTheme,
    required this.radioTheme,
    required this.primaryToastTheme,
    required this.destructiveToastTheme,
    required this.breakpoints,
    required this.primaryAlertTheme,
    required this.destructiveAlertTheme,
    required this.primaryDialogTheme,
    required this.alertDialogTheme,
    required this.sliderTheme,
    required this.sheetTheme,
    required this.progressBarTheme,
    required this.accordionTheme,
    required this.tableTheme,
    required this.resizableTheme,
    required this.hoverStrategies,
    required this.disableSecondaryBorder,
    required this.tabsTheme,
    required this.contextMenuTheme,
    required this.calendarTheme,
    required this.datePickerTheme,
    required this.timePickerTheme,
    required this.otpFieldTheme,
    required this.menubarTheme,
    required this.dividerTheme,
    required this.sonnerTheme,
    required this.textareaTheme,
    required this.defaultKeyboardToolbarTheme,
    required this.skeletonTheme,
    required this.kbdTheme,
    required this.glassTheme,
    required this.appBarTheme,
    required this.navigationBarTheme,
    required this.bottomNavigationBarTheme,
    required this.chipTheme,
    required this.listTileTheme,
    required this.chatBubbleTheme,
    required this.indicatorBadgeTheme,
    required this.iconTileTheme,
    required this.timelineTheme,
    required this.layoutTheme,
    required this.scrollAreaTheme,
    required this.spinnerTheme,
    required this.toggleTheme,
    required this.outlineToggleTheme,
    required this.emptyTheme,
    required this.paginationTheme,
    required this.collapsibleTheme,
    required this.commandTheme,
    required this.sidebarTheme,
    required this.variant,
  });

  /// The variant that produced the component theme defaults below.
  ///
  /// Stored so that `ThemeData.copyWith` re-derives from the same variant
  /// instead of silently falling back to the default one.
  final ThemeVariant variant;

  /// The theme of `Command`.
  final CommandTheme commandTheme;

  /// The theme of `Sidebar` and its menu.
  final SidebarTheme sidebarTheme;

  /// The theme of `Skeleton`.
  final SkeletonTheme skeletonTheme;

  /// The theme of `Kbd` keyboard keys.
  final KbdTheme kbdTheme;

  /// The theme of the matching widget.
  final GlassTheme glassTheme;

  /// The theme of the matching widget.
  final AppBarTheme appBarTheme;

  /// The theme of the matching widget.
  final NavigationBarTheme navigationBarTheme;

  /// The theme of the matching widget.
  final BottomNavigationBarTheme bottomNavigationBarTheme;

  /// The theme of the matching widget.
  final ChipTheme chipTheme;

  /// The theme of the matching widget.
  final ListTileTheme listTileTheme;

  /// The theme of the matching widget.
  final ChatBubbleTheme chatBubbleTheme;

  /// The theme of the matching widget.
  final IndicatorBadgeTheme indicatorBadgeTheme;

  /// The theme of the matching widget.
  final IconTileTheme iconTileTheme;

  /// The theme of the matching widget.
  final TimelineTheme timelineTheme;

  /// The theme of the matching widget.
  final LayoutTheme layoutTheme;

  /// The theme of `ScrollArea`.
  final ScrollAreaTheme scrollAreaTheme;

  /// The theme of `Spinner`.
  final SpinnerTheme spinnerTheme;

  /// The theme of `Toggle` in its default variant.
  final ToggleTheme toggleTheme;

  /// The theme of outline toggles, `Toggle.outline`.
  final ToggleTheme outlineToggleTheme;

  /// The theme of `Empty`.
  final EmptyTheme emptyTheme;

  /// The theme of `Pagination`.
  final PaginationTheme paginationTheme;

  /// The theme of `Collapsible`.
  final CollapsibleTheme collapsibleTheme;

  /// The colour tokens every component theme is built from.
  final ColorScheme colorScheme;

  /// Whether the theme is light or dark.
  final Brightness brightness;

  /// The theme of primary buttons, `Button`'s default variant.
  final ButtonTheme primaryButtonTheme;

  /// The theme of secondary buttons, `Button.secondary`.
  final ButtonTheme secondaryButtonTheme;

  /// The theme of destructive buttons, `Button.destructive`.
  final ButtonTheme destructiveButtonTheme;

  /// The theme of outline buttons, `Button.outline`.
  final ButtonTheme outlineButtonTheme;

  /// The theme of ghost buttons, `Button.ghost`.
  final ButtonTheme ghostButtonTheme;

  /// The theme of link buttons, `Button.link`.
  final ButtonTheme linkButtonTheme;

  /// The theme of primary badges, `Badge`'s default variant.
  final BadgeTheme primaryBadgeTheme;

  /// The theme of secondary badges, `Badge.secondary`.
  final BadgeTheme secondaryBadgeTheme;

  /// The theme of destructive badges, `Badge.destructive`.
  final BadgeTheme destructiveBadgeTheme;

  /// The theme of outline badges, `Badge.outline`.
  final BadgeTheme outlineBadgeTheme;

  /// The theme of `Breadcrumb`.
  final BreadcrumbTheme breadcrumbTheme;

  /// The component radius, the `md` step of [Radii]. Defaults to 8.
  final BorderRadius radius;

  /// The theme of `Avatar`.
  final AvatarTheme avatarTheme;

  /// The metrics of each `Button` size.
  final ButtonSizesTheme buttonSizesTheme;

  /// The theme of `Tooltip`.
  final TooltipTheme tooltipTheme;

  /// The theme of `Popover`.
  final PopoverTheme popoverTheme;

  /// The default border and label styling of controls. Component decorations
  /// are merged over it.
  final FinesseDecoration decoration;

  /// The text styles. These have the style's text roles applied, so they can
  /// differ from the text theme passed in.
  final TextTheme textTheme;

  /// The opacity of disabled components. Defaults to 0.5.
  final double disabledOpacity;

  /// The theme of `Select`.
  final SelectTheme selectTheme;

  /// The theme of `SelectOption`, the rows of a select.
  final SelectOptionTheme selectOptionTheme;

  /// The theme of `Card`.
  final CardTheme cardTheme;

  /// The theme of `Switch`.
  final SwitchTheme switchTheme;

  /// The theme of `Checkbox`.
  final CheckboxTheme checkboxTheme;

  /// The theme of `TextField`.
  final TextFieldTheme textFieldTheme;

  /// The theme of `Radio`.
  final RadioTheme radioTheme;

  /// The theme of default toasts, `Toast`.
  final ToastTheme primaryToastTheme;

  /// The theme of destructive toasts, `Toast.destructive`.
  final ToastTheme destructiveToastTheme;

  /// The screen widths at which the layout changes.
  final Breakpoints breakpoints;

  /// The theme of default alerts, `Alert`.
  final AlertTheme primaryAlertTheme;

  /// The theme of destructive alerts, `Alert.destructive`.
  final AlertTheme destructiveAlertTheme;

  /// The theme of `Dialog`.
  final DialogTheme primaryDialogTheme;

  /// The theme of alert dialogs, `Dialog.alert`.
  final DialogTheme alertDialogTheme;

  /// The theme of `Slider`.
  final SliderTheme sliderTheme;

  /// The theme of `Sheet`.
  final SheetTheme sheetTheme;

  /// The theme of `ProgressBar`.
  final ProgressBarTheme progressBarTheme;

  /// The theme of `Accordion`.
  final AccordionTheme accordionTheme;

  /// The theme of `FinesseTable`.
  final TableTheme tableTheme;

  /// The theme of `ResizablePanelGroup`.
  final ResizableTheme resizableTheme;

  /// The gestures that give touch devices a hover state.
  final HoverStrategies hoverStrategies;

  /// Whether controls show focus without the outward ring. Defaults to false.
  ///
  /// When true, `ThemeData` uses
  /// `DefaultThemeNoSecondaryBorderVariant`.
  final bool disableSecondaryBorder;

  /// The theme of `Tabs`.
  final TabsTheme tabsTheme;

  /// The theme of `ContextMenu`.
  final ContextMenuTheme contextMenuTheme;

  /// The theme of `Calendar`.
  final CalendarTheme calendarTheme;

  /// The theme of `DatePicker`.
  final DatePickerTheme datePickerTheme;

  /// The theme of `TimePicker`.
  final TimePickerTheme timePickerTheme;

  /// The theme of `OtpField`.
  final OtpFieldTheme otpFieldTheme;

  /// The theme of `Menubar`.
  final MenubarTheme menubarTheme;

  /// The theme of `Divider`.
  final DividerTheme dividerTheme;

  /// The theme of `Sonner`.
  final SonnerTheme sonnerTheme;

  /// The theme of `Textarea`.
  final TextareaTheme textareaTheme;

  /// The theme of `DefaultKeyboardToolbar`.
  final DefaultKeyboardToolbarTheme defaultKeyboardToolbarTheme;
}

/// Derives every component theme from one colour scheme, radius, text theme,
/// style and spacing scale.
///
/// A variant bakes its inputs into the themes it returns, so call [rebuild] to
/// change one of them. `ThemeData` calls the builder methods when it is
/// created, and an explicit component theme is merged over the result. See
/// `DefaultThemeVariant` and `DefaultThemeNoSecondaryBorderVariant`.
@immutable
abstract class ThemeVariant {
  /// The palette every component theme is built from.
  ColorScheme get colorScheme;

  /// The base ("md") radius the rest of the scale derives from.
  BorderRadius get radius;

  /// The already-merged text theme.
  TextTheme get effectiveTextTheme;

  /// Returns a variant of the same kind with the given inputs replaced.
  ///
  /// A variant bakes its inputs into the component themes when it is
  /// constructed, so changing one of them means building a new variant.
  /// `ThemeData.copyWith` relies on this: without it, `copyWith(radius:)`
  /// on a theme that carries a variant would update the theme's `radius` field
  /// and leave every component at the old one.
  ThemeVariant rebuild({
    ColorScheme? colorScheme,
    BorderRadius? radius,
    TextTheme? effectiveTextTheme,
    StyleTokens? style,
    FormFactor? formFactor,
    Spacing? spacing,
  });

  /// The shadcn/ui style this variant renders — the radius, focus-ring and
  /// label knobs that distinguish one style from another.
  StyleTokens get style;

  /// The style the variant was created with, before [formFactor] was
  /// applied. Defaults to [style] for a variant with one set of metrics.
  StyleTokens get baseStyle => style;

  /// The class of screen [style]'s metrics are for.
  FormFactor get formFactor => FormFactor.desktop;

  /// The corner-radius scale, derived from the variant's base radius.
  Radii get radii;

  /// The spacing scale every padding and gap is a multiple of.
  Spacing get spacing;

  /// Builds the theme of primary buttons, `Button`'s default variant.
  ButtonTheme primaryButtonTheme();

  /// Builds the theme of secondary buttons, `Button.secondary`.
  ButtonTheme secondaryButtonTheme();

  /// Builds the theme of destructive buttons, `Button.destructive`.
  ButtonTheme destructiveButtonTheme();

  /// Builds the theme of outline buttons, `Button.outline`.
  ButtonTheme outlineButtonTheme();

  /// Builds the theme of ghost buttons, `Button.ghost`.
  ButtonTheme ghostButtonTheme();

  /// Builds the theme of link buttons, `Button.link`.
  ButtonTheme linkButtonTheme();

  /// Builds the metrics of each `Button` size.
  ButtonSizesTheme buttonSizesTheme();

  /// Builds the theme of primary badges, `Badge`'s default variant.
  BadgeTheme primaryBadgeTheme();

  /// Builds the theme of secondary badges, `Badge.secondary`.
  BadgeTheme secondaryBadgeTheme();

  /// Builds the theme of destructive badges, `Badge.destructive`.
  BadgeTheme destructiveBadgeTheme();

  /// Builds the theme of outline badges, `Badge.outline`.
  BadgeTheme outlineBadgeTheme();

  /// Builds the theme of `Avatar`.
  AvatarTheme avatarTheme();

  /// Builds the theme of `Breadcrumb`.
  BreadcrumbTheme breadcrumbTheme();

  /// Builds the theme of `Tooltip`.
  TooltipTheme tooltipTheme();

  /// Builds the theme of `Popover`.
  PopoverTheme popoverTheme();

  /// Builds the default [FinesseDecoration] of controls.
  FinesseDecoration decorationTheme();

  /// Builds the text theme: [effectiveTextTheme] with the style's text roles
  /// applied to `small`, `muted`, `p`, `list` and `large`.
  TextTheme textTheme();

  /// Builds the theme of `Select`.
  SelectTheme selectTheme();

  /// Builds the theme of `SelectOption`, the rows of a select.
  SelectOptionTheme selectOptionTheme();

  /// Builds the theme of `Card`.
  CardTheme cardTheme();

  /// Builds the theme of `Switch`.
  SwitchTheme switchTheme();

  /// Builds the theme of `Checkbox`.
  CheckboxTheme checkboxTheme();

  /// Builds the theme of `TextField`.
  TextFieldTheme textFieldTheme();

  /// Builds the theme of `Radio`.
  RadioTheme radioTheme();

  /// Builds the theme of default toasts, `Toast`.
  ToastTheme primaryToastTheme();

  /// Builds the theme of destructive toasts, `Toast.destructive`.
  ToastTheme destructiveToastTheme();

  /// Builds the theme of default alerts, `Alert`.
  AlertTheme primaryAlertTheme();

  /// Builds the theme of destructive alerts, `Alert.destructive`.
  AlertTheme destructiveAlertTheme();

  /// Builds the theme of `Dialog`.
  DialogTheme primaryDialogTheme();

  /// Builds the theme of alert dialogs, `Dialog.alert`.
  DialogTheme alertDialogTheme();

  /// Builds the theme of `Slider`.
  SliderTheme sliderTheme();

  /// Builds the theme of `Sheet`.
  SheetTheme sheetTheme();

  /// Builds the theme of `ProgressBar`.
  ProgressBarTheme progressBarTheme();

  /// Builds the theme of `Accordion`.
  AccordionTheme accordionTheme();

  /// Builds the theme of `FinesseTable`.
  TableTheme tableTheme();

  /// Builds the theme of `ResizablePanelGroup`.
  ResizableTheme resizableTheme();

  /// Builds the gestures that give touch devices a hover state.
  HoverStrategies hoverStrategies();

  /// Builds the theme of `Tabs`.
  TabsTheme tabsTheme();

  /// Builds the theme of `ContextMenu`.
  ContextMenuTheme contextMenuTheme();

  /// Builds the theme of `Calendar`.
  CalendarTheme calendarTheme();

  /// Builds the theme of `DatePicker`.
  DatePickerTheme datePickerTheme();

  /// Builds the theme of `TimePicker`.
  TimePickerTheme timePickerTheme();

  /// Builds the theme of `OtpField`.
  OtpFieldTheme otpFieldTheme();

  /// Builds the theme of `Menubar`.
  MenubarTheme menubarTheme();

  /// Builds the theme of `Divider`.
  DividerTheme dividerTheme();

  /// Builds the theme of `Sonner`.
  SonnerTheme sonnerTheme();

  /// Builds the theme of `Textarea`.
  TextareaTheme textareaTheme();

  /// Builds the theme of `DefaultKeyboardToolbar`.
  DefaultKeyboardToolbarTheme defaultKeyboardToolbarTheme();

  /// Builds the theme of `Command`.
  CommandTheme commandTheme();

  /// Builds the theme of `Skeleton`.
  SkeletonTheme skeletonTheme();

  /// Builds the theme of `Kbd` keyboard keys.
  KbdTheme kbdTheme();

  /// Builds the [GlassTheme].
  GlassTheme glassTheme();

  /// Builds the [AppBarTheme].
  AppBarTheme appBarTheme();

  /// Builds the [NavigationBarTheme].
  NavigationBarTheme navigationBarTheme();

  /// Builds the [BottomNavigationBarTheme].
  BottomNavigationBarTheme bottomNavigationBarTheme();

  /// Builds the [ChipTheme].
  ChipTheme chipTheme();

  /// Builds the [ListTileTheme].
  ListTileTheme listTileTheme();

  /// Builds the [ChatBubbleTheme].
  ChatBubbleTheme chatBubbleTheme();

  /// Builds the [IndicatorBadgeTheme].
  IndicatorBadgeTheme indicatorBadgeTheme();

  /// Builds the [IconTileTheme].
  IconTileTheme iconTileTheme();

  /// Builds the [TimelineTheme].
  TimelineTheme timelineTheme();

  /// Builds the [LayoutTheme].
  LayoutTheme layoutTheme();

  /// Builds the theme of `ScrollArea`.
  ScrollAreaTheme scrollAreaTheme();

  /// Builds the theme of `Spinner`.
  SpinnerTheme spinnerTheme();

  /// Builds the theme of `Toggle` in its default variant.
  ToggleTheme toggleTheme();

  /// Builds the theme of outline toggles, `Toggle.outline`.
  ToggleTheme outlineToggleTheme();

  /// Builds the theme of `Empty`.
  EmptyTheme emptyTheme();

  /// Builds the theme of `Pagination`.
  PaginationTheme paginationTheme();

  /// Builds the theme of `Collapsible`.
  CollapsibleTheme collapsibleTheme();

  /// Builds the theme of `Sidebar` and its menu.
  SidebarTheme sidebarTheme();
}
