import 'package:example/docs/docs.dart';
import 'package:example/docs/pages/accordion.dart';
import 'package:example/docs/pages/action_sheet.dart';
import 'package:example/docs/pages/alert.dart';
import 'package:example/docs/pages/app_bar.dart';
import 'package:example/docs/pages/autocomplete.dart';
import 'package:example/docs/pages/avatar.dart';
import 'package:example/docs/pages/avatar_group.dart';
import 'package:example/docs/pages/back_button.dart';
import 'package:example/docs/pages/badge.dart';
import 'package:example/docs/pages/board.dart';
import 'package:example/docs/pages/breadcrumb.dart';
import 'package:example/docs/pages/building_blocks.dart';
import 'package:example/docs/pages/button.dart';
import 'package:example/docs/pages/button_group.dart';
import 'package:example/docs/pages/calendar.dart';
import 'package:example/docs/pages/card.dart';
import 'package:example/docs/pages/carousel.dart';
import 'package:example/docs/pages/charts.dart';
import 'package:example/docs/pages/chat_bubble.dart';
import 'package:example/docs/pages/chat_list.dart';
import 'package:example/docs/pages/checkbox.dart';
import 'package:example/docs/pages/chip.dart';
import 'package:example/docs/pages/collapsible.dart';
import 'package:example/docs/pages/color_picker.dart';
import 'package:example/docs/pages/command.dart';
import 'package:example/docs/pages/context_menu.dart';
import 'package:example/docs/pages/data_table.dart';
import 'package:example/docs/pages/date_field.dart';
import 'package:example/docs/pages/date_picker.dart';
import 'package:example/docs/pages/dialog.dart';
import 'package:example/docs/pages/divider.dart';
import 'package:example/docs/pages/dropdown_menu.dart';
import 'package:example/docs/pages/empty.dart';
import 'package:example/docs/pages/expansion_tile.dart';
import 'package:example/docs/pages/floating_action_button.dart';
import 'package:example/docs/pages/fonts.dart';
import 'package:example/docs/pages/form.dart';
import 'package:example/docs/pages/form_factors.dart';
import 'package:example/docs/pages/glass.dart';
import 'package:example/docs/pages/hover_card.dart';
import 'package:example/docs/pages/icon_button.dart';
import 'package:example/docs/pages/icon_tile.dart';
import 'package:example/docs/pages/icons.dart';
import 'package:example/docs/pages/indicator_badge.dart';
import 'package:example/docs/pages/installation.dart';
import 'package:example/docs/pages/introduction.dart';
import 'package:example/docs/pages/kbd.dart';
import 'package:example/docs/pages/keyboard_toolbar.dart';
import 'package:example/docs/pages/layout.dart';
import 'package:example/docs/pages/license_page.dart';
import 'package:example/docs/pages/liquid_glass.dart';
import 'package:example/docs/pages/list_detail_layout.dart';
import 'package:example/docs/pages/list_section.dart';
import 'package:example/docs/pages/list_tile.dart';
import 'package:example/docs/pages/menubar.dart';
import 'package:example/docs/pages/motion.dart';
import 'package:example/docs/pages/navigation_bar.dart';
import 'package:example/docs/pages/navigation_menu.dart';
import 'package:example/docs/pages/number_field.dart';
import 'package:example/docs/pages/otp_field.dart';
import 'package:example/docs/pages/overview.dart';
import 'package:example/docs/pages/page_container.dart';
import 'package:example/docs/pages/page_indicator.dart';
import 'package:example/docs/pages/page_route.dart';
import 'package:example/docs/pages/pagination.dart';
import 'package:example/docs/pages/popover.dart';
import 'package:example/docs/pages/portal.dart';
import 'package:example/docs/pages/pressable.dart';
import 'package:example/docs/pages/progress_bar.dart';
import 'package:example/docs/pages/progress_ring.dart';
import 'package:example/docs/pages/radio_group.dart';
import 'package:example/docs/pages/rating.dart';
import 'package:example/docs/pages/refresh_indicator.dart';
import 'package:example/docs/pages/reorderable_list_view.dart';
import 'package:example/docs/pages/resizable.dart';
import 'package:example/docs/pages/reveal_image.dart';
import 'package:example/docs/pages/responsive.dart';
import 'package:example/docs/pages/scaffold.dart';
import 'package:example/docs/pages/scroll_area.dart';
import 'package:example/docs/pages/search_field.dart';
import 'package:example/docs/pages/search_view.dart';
import 'package:example/docs/pages/segmented_control.dart';
import 'package:example/docs/pages/select.dart';
import 'package:example/docs/pages/selection_area.dart';
import 'package:example/docs/pages/sheet.dart';
import 'package:example/docs/pages/sidebar.dart';
import 'package:example/docs/pages/skeleton.dart';
import 'package:example/docs/pages/slider.dart';
import 'package:example/docs/pages/sliver_app_bar.dart';
import 'package:example/docs/pages/spinner.dart';
import 'package:example/docs/pages/stepper.dart';
import 'package:example/docs/pages/streaming_text.dart';
import 'package:example/docs/pages/styles.dart';
import 'package:example/docs/pages/surface.dart';
import 'package:example/docs/pages/swipe_actions.dart';
import 'package:example/docs/pages/switch.dart';
import 'package:example/docs/pages/tab_bar.dart';
import 'package:example/docs/pages/table.dart';
import 'package:example/docs/pages/tabs.dart';
import 'package:example/docs/pages/tag_field.dart';
import 'package:example/docs/pages/text_field.dart';
import 'package:example/docs/pages/textarea.dart';
import 'package:example/docs/pages/theming.dart';
import 'package:example/docs/pages/time_field.dart';
import 'package:example/docs/pages/time_picker.dart';
import 'package:example/docs/pages/timeline.dart';
import 'package:example/docs/pages/toast.dart';
import 'package:example/docs/pages/toggle.dart';
import 'package:example/docs/pages/toggle_group.dart';
import 'package:example/docs/pages/toolbar.dart';
import 'package:example/docs/pages/tooltip.dart';
import 'package:example/docs/pages/typography.dart';
import 'package:example/docs/pages/wheel_picker.dart';
import 'package:una/una.dart';

/// Every documented page, in the order the sidebar shows them: the
/// components by [componentCategories].
final docGroups = <DocGroup>[
  DocGroup(
    title: 'Getting started',
    items: [
      introductionDoc,
      installationDoc,
      themingDoc,
      stylesDoc,
    ],
  ),
  DocGroup(
    title: 'Foundations',
    items: [
      typographyDoc,
      fontsDoc,
      iconsDoc,
      layoutDoc,
      formFactorsDoc,
      responsiveDoc,
      motionDoc,
      liquidGlassDoc,
      formDoc,
      portalDoc,
      buildingBlocksDoc,
    ],
  ),
  DocGroup(
    title: 'Components',
    items: [overviewDoc],
    categories: componentCategories,
  ),
];

/// Every component reference page, alphabetical by title.
///
/// The sidebar and the overview show them by [componentCategories], which
/// has to name each of them once (`docs_categories_test.dart` holds that);
/// the skills generator reads this list.
final componentDocs = [
  accordionDoc,
  actionSheetDoc,
  alertDoc,
  appBarDoc,
  autocompleteDoc,
  avatarDoc,
  avatarGroupDoc,
  backButtonDoc,
  badgeDoc,
  boardDoc,
  breadcrumbDoc,
  buttonDoc,
  buttonGroupDoc,
  calendarDoc,
  cardDoc,
  carouselDoc,
  chartsDoc,
  chatBubbleDoc,
  chatListDoc,
  checkboxDoc,
  chipDoc,
  collapsibleDoc,
  colorPickerDoc,
  commandDoc,
  contextMenuDoc,
  dataTableDoc,
  dateFieldDoc,
  datePickerDoc,
  dialogDoc,
  dividerDoc,
  dropdownMenuDoc,
  emptyDoc,
  expansionTileDoc,
  floatingActionButtonDoc,
  glassDoc,
  hoverCardDoc,
  iconButtonDoc,
  iconTileDoc,
  indicatorBadgeDoc,
  kbdDoc,
  keyboardToolbarDoc,
  licensePageDoc,
  listDetailLayoutDoc,
  listSectionDoc,
  listTileDoc,
  menubarDoc,
  navigationBarDoc,
  navigationMenuDoc,
  numberFieldDoc,
  otpFieldDoc,
  pageContainerDoc,
  pageIndicatorDoc,
  pageRouteDoc,
  paginationDoc,
  popoverDoc,
  pressableDoc,
  progressBarDoc,
  progressRingDoc,
  radioGroupDoc,
  ratingDoc,
  refreshIndicatorDoc,
  reorderableListViewDoc,
  resizableDoc,
  revealImageDoc,
  scaffoldDoc,
  scrollAreaDoc,
  searchFieldDoc,
  searchViewDoc,
  segmentedControlDoc,
  selectDoc,
  selectionAreaDoc,
  sheetDoc,
  sidebarDoc,
  skeletonDoc,
  sliderDoc,
  sliverAppBarDoc,
  spinnerDoc,
  stepperDoc,
  streamingTextDoc,
  surfaceDoc,
  swipeActionsDoc,
  switchDoc,
  tabBarDoc,
  tableDoc,
  tabsDoc,
  tagFieldDoc,
  textFieldDoc,
  textareaDoc,
  timeFieldDoc,
  timePickerDoc,
  timelineDoc,
  toastDoc,
  toggleDoc,
  toggleGroupDoc,
  toolbarDoc,
  tooltipDoc,
  wheelPickerDoc,
];

/// The component pages by kind, in the order the sidebar folds them and the
/// overview shows them. Each category's pages are alphabetical by title.
final componentCategories = <DocCategory>[
  DocCategory(
    title: 'Actions',
    icon: PhosphorIconsRegular.cursorClick,
    description:
        'Buttons, toggles and chips: what is pressed to make something '
        'happen.',
    items: [
      backButtonDoc,
      buttonDoc,
      buttonGroupDoc,
      chipDoc,
      floatingActionButtonDoc,
      iconButtonDoc,
      pressableDoc,
      toggleDoc,
      toggleGroupDoc,
    ],
  ),
  DocCategory(
    title: 'Text input',
    icon: PhosphorIconsRegular.textbox,
    description:
        'Fields that take typed text: words, numbers, codes, tags, dates '
        'and times.',
    items: [
      autocompleteDoc,
      dateFieldDoc,
      keyboardToolbarDoc,
      numberFieldDoc,
      otpFieldDoc,
      searchFieldDoc,
      tagFieldDoc,
      textFieldDoc,
      textareaDoc,
      timeFieldDoc,
    ],
  ),
  DocCategory(
    title: 'Selection & pickers',
    icon: PhosphorIconsRegular.checkSquare,
    description:
        'Choosing a value: from a set, along a range, or on a calendar, a '
        'clock, a colour wheel or a wheel of rows.',
    items: [
      calendarDoc,
      checkboxDoc,
      colorPickerDoc,
      datePickerDoc,
      radioGroupDoc,
      ratingDoc,
      segmentedControlDoc,
      selectDoc,
      sliderDoc,
      switchDoc,
      timePickerDoc,
      wheelPickerDoc,
    ],
  ),
  DocCategory(
    title: 'Overlays & menus',
    icon: PhosphorIconsRegular.stack,
    description:
        'What floats over the page: dialogs, sheets, popovers, menus, '
        'tooltips and toasts.',
    items: [
      actionSheetDoc,
      commandDoc,
      contextMenuDoc,
      dialogDoc,
      dropdownMenuDoc,
      hoverCardDoc,
      menubarDoc,
      popoverDoc,
      searchViewDoc,
      sheetDoc,
      toastDoc,
      tooltipDoc,
    ],
  ),
  DocCategory(
    title: 'Navigation',
    icon: PhosphorIconsRegular.compass,
    description:
        'Moving between pages and sections: tabs, the bars and the rail, '
        'the sidebar, and the route from one page to the next.',
    items: [
      breadcrumbDoc,
      navigationBarDoc,
      navigationMenuDoc,
      pageIndicatorDoc,
      pageRouteDoc,
      paginationDoc,
      sidebarDoc,
      stepperDoc,
      tabBarDoc,
      tabsDoc,
    ],
  ),
  DocCategory(
    title: 'App structure',
    icon: PhosphorIconsRegular.layout,
    description:
        'The frame of a screen: the scaffold and its bars, page margins, '
        'scrolling and split layouts.',
    items: [
      appBarDoc,
      licensePageDoc,
      listDetailLayoutDoc,
      pageContainerDoc,
      resizableDoc,
      scaffoldDoc,
      scrollAreaDoc,
      sliverAppBarDoc,
      toolbarDoc,
    ],
  ),
  DocCategory(
    title: 'Surfaces',
    icon: PhosphorIconsRegular.cards,
    description:
        'What content sits on: cards, glass and floating chrome, dividers, '
        'and sections that open and close.',
    items: [
      accordionDoc,
      cardDoc,
      collapsibleDoc,
      dividerDoc,
      glassDoc,
      surfaceDoc,
    ],
  ),
  DocCategory(
    title: 'Lists & data',
    icon: PhosphorIconsRegular.rows,
    description:
        'Rows, tables and boards, with sections, swipes, reordering and '
        'pull to refresh.',
    items: [
      boardDoc,
      dataTableDoc,
      expansionTileDoc,
      listSectionDoc,
      listTileDoc,
      refreshIndicatorDoc,
      reorderableListViewDoc,
      swipeActionsDoc,
      tableDoc,
      timelineDoc,
    ],
  ),
  DocCategory(
    title: 'Feedback & status',
    icon: PhosphorIconsRegular.bellSimple,
    description:
        'Telling people what is going on: alerts, badges, progress, and '
        'placeholders for what has not arrived.',
    items: [
      alertDoc,
      badgeDoc,
      emptyDoc,
      indicatorBadgeDoc,
      progressBarDoc,
      progressRingDoc,
      skeletonDoc,
      spinnerDoc,
    ],
  ),
  DocCategory(
    title: 'Charts',
    icon: PhosphorIconsRegular.chartBar,
    description:
        'Lines, bars, donuts and sparklines in the chart colours, with '
        'tooltips, keyboard stepping and an entrance that grows.',
    items: [chartsDoc],
  ),
  DocCategory(
    title: 'Content & media',
    icon: PhosphorIconsRegular.image,
    description:
        'People, icons, keys and photographs, and text that can be '
        'selected.',
    items: [
      avatarDoc,
      avatarGroupDoc,
      carouselDoc,
      iconTileDoc,
      kbdDoc,
      revealImageDoc,
      selectionAreaDoc,
    ],
  ),
  DocCategory(
    title: 'Chat',
    icon: PhosphorIconsRegular.chatsCircle,
    description:
        'Conversations: message bubbles, a list that keeps its place, and '
        'text that streams in.',
    items: [chatBubbleDoc, chatListDoc, streamingTextDoc],
  ),
];

final overviewDoc = ComponentDoc(
  slug: 'overview',
  title: 'Overview',
  description:
      'Every component in the library, by what it is for. Pick one to open '
      'its documentation.',
  body: (context) => ComponentsOverview(categories: componentCategories),
);
