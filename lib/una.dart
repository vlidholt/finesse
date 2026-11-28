// App
// External libraries.
//
// Only what the package's own public API requires is re-exported. `boxy`,
// `flutter_svg` and `universal_image` used to be re-exported wholesale even
// though they appear nowhere in a Una* signature; importing una dumped
// several hundred unrelated symbols (BoxyDelegate, RenderBoxy, SvgPicture, …)
// into the caller's namespace. Depend on those packages directly if you need
// them.

// DateFormat/NumberFormat are what the calendar, date picker and pagination
// docs use. The rest of `intl` (Intl, Bidi, plural/gender helpers, …) is not
// part of this package's API.
export 'package:intl/intl.dart' show DateFormat, NumberFormat;
// Required by UnaTable's public signature; UnaTableCell extends
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
export 'src/components/action_sheet.dart';
export 'src/components/alert.dart';
export 'src/components/app_bar.dart';
export 'src/components/autocomplete.dart'
    hide AutocompleteOptionRow, OptionsPointers;
export 'src/components/avatar.dart';
export 'src/components/avatar_group.dart' hide AvatarGroupClip;
export 'src/components/back_button.dart';
export 'src/components/badge.dart';
export 'src/components/bar_chart.dart';
export 'src/components/board.dart';
export 'src/components/breadcrumb.dart';
export 'src/components/button.dart';
export 'src/components/button_group.dart' hide RenderButtonGroup;
export 'src/components/calendar.dart' hide CalendarModel;
export 'src/components/card.dart';
export 'src/components/carousel.dart';
export 'src/components/chart_data.dart';
export 'src/components/chart_legend.dart';
export 'src/components/chat_bubble.dart';
export 'src/components/chat_list.dart';
export 'src/components/checkbox.dart';
export 'src/components/chip.dart';
export 'src/components/chip_group.dart';
export 'src/components/collapsible.dart';
export 'src/components/color_picker.dart';
export 'src/components/command.dart';
export 'src/components/context_menu.dart' hide MenuEdge;
export 'src/components/control_affinity.dart' show ControlAffinity;
export 'src/components/control_list_tiles.dart';
export 'src/components/control_size.dart' hide ControlMetrics;
export 'src/components/data_table.dart';
export 'src/components/date_field.dart';
export 'src/components/date_picker.dart';
export 'src/components/date_wheel_picker.dart';
export 'src/components/decorator.dart' hide OutwardBorderPainter;
export 'src/components/default_keyboard_toolbar.dart';
export 'src/components/destination_stack.dart';
export 'src/components/dialog.dart';
export 'src/components/disabled.dart';
export 'src/components/divider.dart';
export 'src/components/donut_chart.dart' hide donutSegmentPath;
export 'src/components/dropdown_menu.dart';
export 'src/components/empty.dart';
export 'src/components/expansion_tile.dart';
export 'src/components/floating_action_button.dart';
export 'src/components/form/field.dart';
export 'src/components/form/fields/autocomplete.dart';
export 'src/components/form/fields/checkbox.dart';
export 'src/components/form/fields/chip_group.dart';
export 'src/components/form/fields/color_picker.dart';
export 'src/components/form/fields/date_field.dart';
export 'src/components/form/fields/date_picker.dart';
export 'src/components/form/fields/date_range_picker.dart';
export 'src/components/form/fields/number_field.dart';
export 'src/components/form/fields/otp_field.dart';
export 'src/components/form/fields/radio.dart';
export 'src/components/form/fields/range_slider.dart';
export 'src/components/form/fields/rating.dart';
export 'src/components/form/fields/segmented_control.dart';
export 'src/components/form/fields/select.dart';
export 'src/components/form/fields/slider.dart';
export 'src/components/form/fields/switch.dart';
export 'src/components/form/fields/tag_field.dart';
export 'src/components/form/fields/text_field.dart';
export 'src/components/form/fields/textarea.dart';
export 'src/components/form/fields/time_field.dart';
export 'src/components/form/fields/time_picker.dart';
export 'src/components/form/fields/toggle_group.dart';
export 'src/components/form/form.dart';
export 'src/components/glass.dart';
export 'src/components/hover_card.dart';
export 'src/components/icon_button.dart';
export 'src/components/icon_tile.dart';
export 'src/components/indicator_badge.dart';
export 'src/components/input_decorator.dart';
export 'src/components/kbd.dart';
export 'src/components/layout.dart';
export 'src/components/license_page.dart';
export 'src/components/line_chart.dart';
export 'src/components/list_detail_layout.dart';
export 'src/components/list_section.dart' hide debugListSectionDivider;
export 'src/components/list_tile.dart';
export 'src/components/menubar.dart';
export 'src/components/navigation_bar.dart'
    hide DestinationIcon, badgedDestinationIcon;
export 'src/components/navigation_menu.dart';
export 'src/components/navigation_scaffold.dart';
export 'src/components/number_field.dart';
export 'src/components/otp_field.dart' hide kInvisibleCharCode;
export 'src/components/page_container.dart';
export 'src/components/page_indicator.dart' hide debugPageIndicatorDots;
export 'src/components/pagination.dart';
export 'src/components/picker.dart'
    show PickerPresentation, PickerTriggerBuilder;
export 'src/components/popover.dart' hide PopoverTapGroups;
export 'src/components/progress_bar.dart';
export 'src/components/progress_ring.dart';
export 'src/components/radio.dart' hide RadioGroupFocus;
export 'src/components/rating.dart';
export 'src/components/refresh_indicator.dart';
export 'src/components/resizable.dart' hide PanelInfo, ResizeResult;
export 'src/components/reveal_image.dart';
export 'src/components/scaffold.dart';
export 'src/components/scroll_area.dart';
export 'src/components/search_field.dart';
export 'src/components/search_view.dart';
export 'src/components/segmented_control.dart';
export 'src/components/select.dart' hide SelectState;
export 'src/components/selection_area.dart';
export 'src/components/sheet.dart';
export 'src/components/sidebar.dart';
export 'src/components/skeleton.dart';
export 'src/components/skeleton_shapes.dart';
export 'src/components/slider.dart';
export 'src/components/sliver_app_bar.dart';
export 'src/components/sparkline.dart';
export 'src/components/spinner.dart';
export 'src/components/stepper.dart';
export 'src/components/streaming_text.dart';
export 'src/components/surface.dart' hide SurfacePainter, glassFreeDecoration;
export 'src/components/swipe_actions.dart';
export 'src/components/switch.dart';
export 'src/components/tab_bar.dart';
export 'src/components/tab_bar_view.dart' hide TabPages;
export 'src/components/tab_list.dart' show TabBarVariant;
export 'src/components/table.dart';
export 'src/components/tabs.dart' hide tabListItems;
export 'src/components/tag_field.dart';
export 'src/components/text_field.dart';
export 'src/components/text_magnifier.dart';
export 'src/components/text_selection.dart';
export 'src/components/textarea.dart';
export 'src/components/time_field.dart';
export 'src/components/time_picker.dart';
export 'src/components/time_wheel_picker.dart';
export 'src/components/timeline.dart';
export 'src/components/toast.dart' hide RenderToastStack;
export 'src/components/toggle.dart';
export 'src/components/toolbar.dart';
export 'src/components/tooltip.dart';
export 'src/components/wheel_picker.dart' hide RenderWheel;
// Localizations
export 'src/i18n/localizations_delegate.dart';
// The generated strings file re-exports all of slang and declares an
// unprefixed AppLocaleUtils; neither is part of this package's API, and
// AppLocaleUtils collides with the one slang generates in an app.
export 'src/i18n/strings.g.dart'
    show UnaLocale, UnaLocalizationsData, UnaLocalizationsDataEn;
export 'src/icons/phosphor_icons.dart';
// Liquid Glass: the switch and its setup. The widgets that draw it are
// internal; components build them.
export 'src/liquid_glass/liquid_glass.dart' show LiquidGlass;
export 'src/liquid_glass/liquid_glass_theme.dart';
// Routes
export 'src/page_route.dart';
// Raw Components
export 'src/raw_components/focusable.dart';
export 'src/raw_components/keyboard_toolbar.dart';
export 'src/raw_components/portal.dart' hide PositionDelegate;
export 'src/raw_components/pressable.dart';
export 'src/raw_components/roving_focus.dart';
// App Themes & Color Schemes
export 'src/theme/chart_palette.dart';
export 'src/theme/color_scheme/base.dart';
export 'src/theme/color_scheme/ember.dart';
export 'src/theme/color_scheme/forest.dart';
export 'src/theme/color_scheme/graphite.dart';
export 'src/theme/color_scheme/iris.dart';
export 'src/theme/color_scheme/ocean.dart';
export 'src/theme/color_scheme/rose.dart';
export 'src/theme/color_scheme/slate.dart';
// Component Themes
export 'src/theme/components/accordion.dart';
export 'src/theme/components/action_sheet.dart';
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
export 'src/theme/components/carousel.dart';
export 'src/theme/components/chart.dart';
export 'src/theme/components/chat_bubble.dart';
export 'src/theme/components/chat_list.dart';
export 'src/theme/components/checkbox.dart';
export 'src/theme/components/chip.dart';
export 'src/theme/components/collapsible.dart';
export 'src/theme/components/command.dart';
export 'src/theme/components/context_menu.dart';
export 'src/theme/components/date_picker.dart';
export 'src/theme/components/decorator.dart';
export 'src/theme/components/default_keyboard_toolbar.dart';
export 'src/theme/components/dialog.dart';
export 'src/theme/components/divider.dart';
export 'src/theme/components/empty.dart';
export 'src/theme/components/floating_action_button.dart';
export 'src/theme/components/glass.dart';
export 'src/theme/components/icon_tile.dart';
export 'src/theme/components/indicator_badge.dart';
export 'src/theme/components/kbd.dart';
export 'src/theme/components/layout.dart';
export 'src/theme/components/list_section.dart';
export 'src/theme/components/list_tile.dart';
export 'src/theme/components/menubar.dart';
export 'src/theme/components/navigation_bar.dart';
export 'src/theme/components/navigation_menu.dart';
export 'src/theme/components/navigation_rail.dart';
export 'src/theme/components/otp_field.dart';
export 'src/theme/components/pagination.dart';
export 'src/theme/components/phosphor_icon.dart';
export 'src/theme/components/popover.dart';
export 'src/theme/components/progress_bar.dart';
export 'src/theme/components/radio.dart';
export 'src/theme/components/refresh_indicator.dart';
export 'src/theme/components/resizable.dart';
export 'src/theme/components/scroll_area.dart';
export 'src/theme/components/select.dart';
export 'src/theme/components/select_option.dart';
export 'src/theme/components/sheet.dart';
export 'src/theme/components/sidebar.dart';
export 'src/theme/components/skeleton.dart';
export 'src/theme/components/slider.dart';
export 'src/theme/components/spinner.dart';
export 'src/theme/components/stepper.dart';
export 'src/theme/components/streaming_text.dart';
export 'src/theme/components/switch.dart';
export 'src/theme/components/table.dart';
export 'src/theme/components/tabs.dart';
export 'src/theme/components/text_field.dart';
export 'src/theme/components/text_selection.dart';
export 'src/theme/components/textarea.dart';
export 'src/theme/components/time_field.dart';
export 'src/theme/components/time_picker.dart';
export 'src/theme/components/timeline.dart';
export 'src/theme/components/toast.dart';
export 'src/theme/components/toggle.dart';
export 'src/theme/components/tooltip.dart';
export 'src/theme/components/wheel_picker.dart';
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
export 'src/theme/theme.dart' hide UnaInheritedTheme;
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
export 'src/utils/entrance.dart' hide EntranceSpec, OverlayEntrance;
export 'src/utils/expand_reveal.dart';
// Extensions on core Dart/Flutter types (double, Duration, List, Map, Set,
// TextStyle, TapDownDetails) are no longer re-exported. They silently added
// methods — and, for Duration, `+ - * /` operator overloads — to every type in
// every file that imported this package. They remain internal.
export 'src/utils/extensions/breakpoints.dart';
export 'src/utils/gesture_detector.dart';
export 'src/utils/haptics.dart';
export 'src/utils/input_formatters.dart';
export 'src/utils/motion_color.dart';
export 'src/utils/mouse_area.dart' show MouseArea;
export 'src/utils/moving_indicator.dart'
    hide RenderMovingIndicator, RenderMovingIndicatorTarget;
export 'src/utils/overlay_insets.dart';
export 'src/utils/pop_in.dart';
export 'src/utils/position.dart' hide PositionedExt;
export 'src/utils/responsive.dart';
export 'src/utils/route_on_top.dart';
export 'src/utils/shadow.dart' hide paintOuterShadows;
export 'src/utils/spring.dart';
export 'src/utils/spring_size.dart';
