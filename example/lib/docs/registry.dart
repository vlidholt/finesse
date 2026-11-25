import 'package:example/docs/docs.dart';
import 'package:example/docs/pages/accordion.dart';
import 'package:example/docs/pages/action_sheet.dart';
import 'package:example/docs/pages/alert.dart';
import 'package:example/docs/pages/app_bar.dart';
import 'package:example/docs/pages/avatar.dart';
import 'package:example/docs/pages/avatar_group.dart';
import 'package:example/docs/pages/back_button.dart';
import 'package:example/docs/pages/badge.dart';
import 'package:example/docs/pages/board.dart';
import 'package:example/docs/pages/breadcrumb.dart';
import 'package:example/docs/pages/button.dart';
import 'package:example/docs/pages/calendar.dart';
import 'package:example/docs/pages/card.dart';
import 'package:example/docs/pages/chat_bubble.dart';
import 'package:example/docs/pages/chat_list.dart';
import 'package:example/docs/pages/checkbox.dart';
import 'package:example/docs/pages/chip.dart';
import 'package:example/docs/pages/collapsible.dart';
import 'package:example/docs/pages/command.dart';
import 'package:example/docs/pages/context_menu.dart';
import 'package:example/docs/pages/data_table.dart';
import 'package:example/docs/pages/date_picker.dart';
import 'package:example/docs/pages/dialog.dart';
import 'package:example/docs/pages/divider.dart';
import 'package:example/docs/pages/dropdown_menu.dart';
import 'package:example/docs/pages/empty.dart';
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
import 'package:example/docs/pages/list_detail_layout.dart';
import 'package:example/docs/pages/layout.dart';
import 'package:example/docs/pages/list_tile.dart';
import 'package:example/docs/pages/menubar.dart';
import 'package:example/docs/pages/motion.dart';
import 'package:example/docs/pages/navigation_bar.dart';
import 'package:example/docs/pages/navigation_rail.dart';
import 'package:example/docs/pages/otp_field.dart';
import 'package:example/docs/pages/overview.dart';
import 'package:example/docs/pages/page_container.dart';
import 'package:example/docs/pages/page_route.dart';
import 'package:example/docs/pages/pagination.dart';
import 'package:example/docs/pages/popover.dart';
import 'package:example/docs/pages/portal.dart';
import 'package:example/docs/pages/pressable.dart';
import 'package:example/docs/pages/progress_bar.dart';
import 'package:example/docs/pages/radio_group.dart';
import 'package:example/docs/pages/resizable.dart';
import 'package:example/docs/pages/responsive.dart';
import 'package:example/docs/pages/scaffold.dart';
import 'package:example/docs/pages/scroll_area.dart';
import 'package:example/docs/pages/segmented_control.dart';
import 'package:example/docs/pages/select.dart';
import 'package:example/docs/pages/sheet.dart';
import 'package:example/docs/pages/sidebar.dart';
import 'package:example/docs/pages/skeleton.dart';
import 'package:example/docs/pages/slider.dart';
import 'package:example/docs/pages/sliver_app_bar.dart';
import 'package:example/docs/pages/sonner.dart';
import 'package:example/docs/pages/spinner.dart';
import 'package:example/docs/pages/streaming_text.dart';
import 'package:example/docs/pages/styles.dart';
import 'package:example/docs/pages/surface.dart';
import 'package:example/docs/pages/switch.dart';
import 'package:example/docs/pages/tab_bar.dart';
import 'package:example/docs/pages/table.dart';
import 'package:example/docs/pages/tabs.dart';
import 'package:example/docs/pages/text_field.dart';
import 'package:example/docs/pages/textarea.dart';
import 'package:example/docs/pages/theming.dart';
import 'package:example/docs/pages/time_picker.dart';
import 'package:example/docs/pages/timeline.dart';
import 'package:example/docs/pages/toast.dart';
import 'package:example/docs/pages/toggle.dart';
import 'package:example/docs/pages/toggle_group.dart';
import 'package:example/docs/pages/toolbar.dart';
import 'package:example/docs/pages/tooltip.dart';
import 'package:example/docs/pages/typography.dart';

/// Every documented page, in the order the sidebar shows them.
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
      formDoc,
      portalDoc,
    ],
  ),
  DocGroup(
    title: 'Components',
    items: [
      overviewDoc,
      ...componentDocs,
    ],
  ),
];

/// Every component reference page, in sidebar order: alphabetical by title.
final componentDocs = [
  accordionDoc,
  actionSheetDoc,
  alertDoc,
  appBarDoc,
  avatarDoc,
  avatarGroupDoc,
  backButtonDoc,
  badgeDoc,
  boardDoc,
  breadcrumbDoc,
  buttonDoc,
  calendarDoc,
  cardDoc,
  chatBubbleDoc,
  chatListDoc,
  checkboxDoc,
  chipDoc,
  collapsibleDoc,
  commandDoc,
  contextMenuDoc,
  dataTableDoc,
  datePickerDoc,
  dialogDoc,
  dividerDoc,
  dropdownMenuDoc,
  emptyDoc,
  floatingActionButtonDoc,
  glassDoc,
  hoverCardDoc,
  iconButtonDoc,
  iconTileDoc,
  indicatorBadgeDoc,
  kbdDoc,
  keyboardToolbarDoc,
  listDetailLayoutDoc,
  listTileDoc,
  menubarDoc,
  navigationBarDoc,
  navigationRailDoc,
  otpFieldDoc,
  pageContainerDoc,
  pageRouteDoc,
  paginationDoc,
  popoverDoc,
  pressableDoc,
  progressBarDoc,
  radioGroupDoc,
  resizableDoc,
  scaffoldDoc,
  scrollAreaDoc,
  segmentedControlDoc,
  selectDoc,
  sheetDoc,
  sidebarDoc,
  skeletonDoc,
  sliderDoc,
  sliverAppBarDoc,
  sonnerDoc,
  spinnerDoc,
  streamingTextDoc,
  surfaceDoc,
  switchDoc,
  tabBarDoc,
  tableDoc,
  tabsDoc,
  textFieldDoc,
  textareaDoc,
  timePickerDoc,
  timelineDoc,
  toastDoc,
  toggleDoc,
  toggleGroupDoc,
  toolbarDoc,
  tooltipDoc,
];

final overviewDoc = ComponentDoc(
  slug: 'overview',
  title: 'Overview',
  description:
      'Every component in the library. Pick one to open its documentation.',
  body: (context) => ComponentsOverview(components: componentDocs),
);
