// App
// External libraries.
//
// Only what the package's own public API requires is re-exported. `boxy`,
// `flutter_svg` and `universal_image` used to be re-exported wholesale even
// though they appear nowhere in a Finesse* signature; importing finesse dumped
// several hundred unrelated symbols (BoxyDelegate, RenderBoxy, SvgPicture, …)
// into the caller's namespace. Depend on those packages directly if you need
// them.

// Required by the `effects:` parameter on Popover, Select,
// Accordion, Menubar and friends.
export 'package:flutter_animate/flutter_animate.dart' hide Effect;
// DateFormat/NumberFormat are what the calendar, date picker and pagination
// docs use. The rest of `intl` (Intl, Bidi, plural/gender helpers, …) is not
// part of this package's API.
export 'package:intl/intl.dart' show DateFormat, NumberFormat;
// Required by FinesseTable's public signature; FinesseTableCell extends
// TableViewCell.
export 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart'
    show
        FixedTableSpanExtent,
        FractionalTableSpanExtent,
        MaxTableSpanExtent,
        MinTableSpanExtent,
        RemainingTableSpanExtent,
        SpanDecoration,
        SpanPadding,
        TableSpan,
        TableSpanBuilder,
        TableSpanDecoration,
        TableSpanExtent,
        TableVicinity,
        TableViewCell;

export 'src/app.dart';
// Components
export 'src/components/accordion.dart';
export 'src/components/alert.dart';
export 'src/components/app_bar.dart';
export 'src/components/avatar.dart';
export 'src/components/avatar_group.dart';
export 'src/components/badge.dart';
export 'src/components/board.dart';
export 'src/components/breadcrumb.dart';
export 'src/components/button.dart';
export 'src/components/calendar.dart' hide CalendarModel;
export 'src/components/card.dart';
export 'src/components/chat_bubble.dart';
export 'src/components/chat_list.dart';
export 'src/components/checkbox.dart';
export 'src/components/chip.dart';
export 'src/components/collapsible.dart';
export 'src/components/command.dart';
export 'src/components/context_menu.dart' hide ContextMenuItemController;
export 'src/components/data_table.dart';
export 'src/components/date_picker.dart';
export 'src/components/default_keyboard_toolbar.dart';
export 'src/components/dialog.dart';
export 'src/components/disabled.dart';
export 'src/components/divider.dart';
export 'src/components/dropdown_menu.dart';
export 'src/components/empty.dart';
export 'src/components/form/field.dart';
export 'src/components/form/fields/checkbox.dart';
export 'src/components/form/fields/date_picker.dart';
export 'src/components/form/fields/date_range_picker.dart';
export 'src/components/form/fields/otp_field.dart';
export 'src/components/form/fields/radio.dart';
export 'src/components/form/fields/select.dart';
export 'src/components/form/fields/switch.dart';
export 'src/components/form/fields/text_field.dart';
export 'src/components/form/fields/textarea.dart';
export 'src/components/form/fields/time_picker.dart';
export 'src/components/form/form.dart';
export 'src/components/glass.dart';
export 'src/components/icon_button.dart';
export 'src/components/icon_tile.dart';
export 'src/components/indicator_badge.dart';
export 'src/components/kbd.dart';
export 'src/components/layout.dart';
export 'src/components/list_tile.dart';
export 'src/components/menubar.dart';
export 'src/components/navigation_bar.dart';
export 'src/components/otp_field.dart' hide kInvisibleCharCode;
export 'src/components/page_container.dart';
export 'src/components/pagination.dart';
export 'src/components/popover.dart';
export 'src/components/progress_bar.dart';
export 'src/components/radio.dart';
export 'src/components/resizable.dart';
export 'src/components/scaffold.dart';
export 'src/components/scroll_area.dart';
export 'src/components/segmented_control.dart';
export 'src/components/select.dart';
export 'src/components/sheet.dart'
    hide
        RenderSheetLayoutWithSizeListener,
        SheetGestureDetector,
        SheetLayoutWithSizeListener,
        SizeChangeCallback;
export 'src/components/sidebar.dart';
export 'src/components/skeleton.dart';
export 'src/components/slider.dart';
export 'src/components/sonner.dart' hide ToastInfo;
export 'src/components/spinner.dart';
export 'src/components/streaming_text.dart';
export 'src/components/surface.dart';
export 'src/components/switch.dart';
export 'src/components/tab_bar.dart';
export 'src/components/tab_bar_view.dart' hide TabPages;
export 'src/components/tab_list.dart' show TabBarVariant;
export 'src/components/table.dart';
export 'src/components/tabs.dart' hide tabListItems;
export 'src/components/text_field.dart';
export 'src/components/textarea.dart' hide ResizeGripPainter;
export 'src/components/time_picker.dart' hide TimePickerTextEditingController;
export 'src/components/timeline.dart';
export 'src/components/toast.dart';
export 'src/components/toggle.dart';
export 'src/components/tooltip.dart';
// Localizations
export 'src/i18n/localizations_delegate.dart';
// The generated strings file re-exports all of slang and declares an
// unprefixed AppLocaleUtils; neither is part of this package's API, and
// AppLocaleUtils collides with the one slang generates in an app.
export 'src/i18n/strings.g.dart'
    show FinesseLocale, FinesseLocalizationsData, FinesseLocalizationsDataEn;
export 'src/icons/phosphor_icons.dart';
// Routes
export 'src/page_route.dart';
// Raw Components
export 'src/raw_components/focusable.dart';
export 'src/raw_components/keyboard_toolbar.dart';
export 'src/raw_components/portal.dart' hide PositionDelegate;
export 'src/raw_components/pressable.dart';
export 'src/raw_components/roving_focus.dart';
// App Themes & Color Schemes
export 'src/theme/color_scheme/accent.dart';
export 'src/theme/color_scheme/base.dart';
export 'src/theme/color_scheme/neutral.dart';
export 'src/theme/color_scheme/stone.dart';
export 'src/theme/color_scheme/teal.dart';
export 'src/theme/color_scheme/zinc.dart';
// Component Themes
export 'src/theme/components/accordion.dart';
export 'src/theme/components/alert.dart';
export 'src/theme/components/app_bar.dart';
export 'src/theme/components/avatar.dart';
export 'src/theme/components/badge.dart';
export 'src/theme/components/board.dart';
export 'src/theme/components/bottom_navigation_bar.dart';
export 'src/theme/components/breadcrumb.dart';
export 'src/theme/components/button.dart';
export 'src/theme/components/button_sizes.dart';
export 'src/theme/components/calendar.dart';
export 'src/theme/components/card.dart';
export 'src/theme/components/chat_bubble.dart';
export 'src/theme/components/chat_list.dart';
export 'src/theme/components/checkbox.dart';
export 'src/theme/components/chip.dart';
export 'src/theme/components/collapsible.dart';
export 'src/theme/components/command.dart';
export 'src/theme/components/context_menu.dart';
export 'src/theme/components/date_picker.dart';
export 'src/theme/components/decorator.dart' hide OutwardBorderPainter;
export 'src/theme/components/default_keyboard_toolbar.dart';
export 'src/theme/components/dialog.dart';
export 'src/theme/components/divider.dart';
export 'src/theme/components/empty.dart';
export 'src/theme/components/glass.dart';
export 'src/theme/components/icon_tile.dart';
export 'src/theme/components/indicator_badge.dart';
export 'src/theme/components/input_decorator.dart';
export 'src/theme/components/kbd.dart';
export 'src/theme/components/layout.dart';
export 'src/theme/components/list_tile.dart';
export 'src/theme/components/menubar.dart';
export 'src/theme/components/navigation_bar.dart';
export 'src/theme/components/otp_field.dart';
export 'src/theme/components/pagination.dart';
export 'src/theme/components/phosphor_icon.dart';
export 'src/theme/components/popover.dart';
export 'src/theme/components/progress_bar.dart';
export 'src/theme/components/radio.dart';
export 'src/theme/components/resizable.dart';
export 'src/theme/components/scroll_area.dart';
export 'src/theme/components/select.dart';
export 'src/theme/components/select_option.dart';
export 'src/theme/components/sheet.dart';
export 'src/theme/components/sidebar.dart';
export 'src/theme/components/skeleton.dart';
export 'src/theme/components/slider.dart';
export 'src/theme/components/sonner.dart';
export 'src/theme/components/spinner.dart';
export 'src/theme/components/streaming_text.dart';
export 'src/theme/components/switch.dart';
export 'src/theme/components/table.dart';
export 'src/theme/components/tabs.dart';
export 'src/theme/components/text_field.dart';
export 'src/theme/components/textarea.dart';
export 'src/theme/components/time_picker.dart';
export 'src/theme/components/timeline.dart';
export 'src/theme/components/toast.dart';
export 'src/theme/components/toggle.dart';
export 'src/theme/components/tooltip.dart';
export 'src/theme/cross_fade_theme.dart';
export 'src/theme/data.dart';
export 'src/theme/form_factor.dart';
export 'src/theme/motion.dart';
export 'src/theme/radii.dart';
export 'src/theme/spacing.dart';
export 'src/theme/style.dart';
export 'src/theme/text_role.dart';
export 'src/theme/text_theme/text_styles_default.dart';
export 'src/theme/text_theme/theme.dart' hide OmitFamilyAndPackageExtension;
export 'src/theme/theme.dart' hide FinesseInheritedTheme;
export 'src/theme/theme_scope.dart' hide DefaultStyles;
export 'src/theme/themes/base.dart';
export 'src/theme/themes/default_theme_no_secondary_border_variant.dart';
export 'src/theme/themes/default_theme_variant.dart';
export 'src/theme/themes/shadows.dart';
// Utils
export 'src/utils/backdrop.dart';
export 'src/utils/border.dart';
export 'src/utils/clipboard/clipboard_service.dart';
export 'src/utils/content_switch.dart';
export 'src/utils/dismiss_shortcut.dart';
export 'src/utils/effects.dart';
export 'src/utils/entrance.dart';
export 'src/utils/expand_reveal.dart';
// Extensions on core Dart/Flutter types (double, Duration, List, Map, Set,
// TextStyle, TapDownDetails) are no longer re-exported. They silently added
// methods — and, for Duration, `+ - * /` operator overloads — to every type in
// every file that imported this package. They remain internal.
export 'src/utils/extensions/breakpoints.dart';
export 'src/utils/gesture_detector.dart';
export 'src/utils/input_formatters.dart';
export 'src/utils/motion_color.dart';
export 'src/utils/mouse_area.dart' show MouseArea, MouseAreaSurface;
export 'src/utils/moving_indicator.dart';
export 'src/utils/pop_in.dart';
export 'src/utils/position.dart' hide PositionedExt;
export 'src/utils/responsive.dart';
export 'src/utils/shadow.dart' hide paintOuterShadows;
export 'src/utils/spring.dart';
export 'src/utils/spring_size.dart';
