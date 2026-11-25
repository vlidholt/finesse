---
name: finesse-overview
description: A Flutter design system with no Material or Cupertino dependency. Provides themed, accessible widgets (Button, Card, TextField, Scaffold, AppBar, NavigationBar, ListTile, Chip, Sidebar, and more), four styles, desktop and phone form factors, a named gap scale, bundled Phosphor icons, and theming, layout, and typography guides. Use this skill when building a Flutter UI with `finesse`, implementing a design system, or looking up how to use a specific `finesse` component.
---

# Finesse: a design system for Flutter

`finesse` is a complete design system as plain Flutter widgets, themed by one `ThemeData`. It began as a port of shadcn/ui (and was forked from the `shad` package), so most components and three of its four styles come from there. It now has its own default look, its own app-structure widgets, and a theme that knows whether it is on a desktop or a phone.

Import everything through one file:

```dart
import 'package:finesse/finesse.dart';
```

## What to know before writing code

- **Names have no prefix.** `Button`, `Card`, `Theme`, `ThemeData`, `Scaffold`, `AppBar`, `ListTile`, `Chip`, `Switch`, `Dialog`, `Tooltip`. These clash with Material, which is fine: a `finesse` app does not import Material. A file that needs both hides one side.
- **A name that would clash with Flutter's widgets layer keeps a `Finesse` prefix**: `FinesseApp`, `FinesseRow`, `FinesseColumn`, `FinessePadding`, `FinesseForm`, `FinesseFormField`, `FinesseTable`, `FinesseRadioGroup`, `FinesseBorder`, `FinesseDecoration`, `FinessePageRoute`.
- **Flutter vocabulary where it exists**: `TextField` and `TextFormField` (not Input), `OtpField`, `Divider` (not Separator), `ProgressBar`, `SelectOption`. Components with no Flutter counterpart keep their shadcn name: `Select`, `Sheet`, `Popover`, `Textarea`.
- **The default theme** is `StyleTokens.finesse` on `TealColorScheme`: soft teal glass. `ThemeData()` with no arguments gives it; `ThemeData(brightness: Brightness.dark)` gives its dark form.
- **Form factors.** `FinesseApp` lays the theme out for `FormFactor.mobile` below the `md` breakpoint (768) and `FormFactor.desktop` above. Buttons are 36 tall on a desktop and 44 on a phone without any code asking. Never read the window width to pick a size. See [form-factors.md](guides/form-factors.md).
- **Name the relationship, not the pixel count.** Space between components is a `GapSize` (`xs`, `sm`, `md`, `lg`, `xl`): `FinesseColumn(gap: GapSize.lg)`, `const Gap.md()`. `lg` is 16 on a desktop and 12 on a phone. See [layout.md](guides/layout.md).
- **Icons are Phosphor, bundled.** `PhosphorIcon(PhosphorIconsRegular.house)`: an `Icon` that thickens a small regular icon's line so it does not look thinner than a large one; always write the regular constant. The fill weight (`PhosphorIconsFill.house`) is the selected state. There is no `LucideIcons`. See [icons.md](guides/icons.md).
- **A screen** is a `Scaffold` (or `NavigationScaffold`) with an `AppBar`, and its content a `PageContainer`, which supplies the page margins and the maximum width.
- **`FinessePadding` takes steps, not pixels.** It has no plain constructor, only `.all`, `.symmetric`, `.only`, and `.directional`, and `FinessePadding.symmetric(horizontal: 6, vertical: 4)` is 24 by 16 at the default 4px step. See [layout.md](guides/layout.md#padding).
- **No deprecated aliases.** The old `Shad*` names, `ShadApp`, `LucideIcons`, the `vega`/`mira`/`luma`/`sera`/`rhea` styles and the slate, gray and accent-named base schemes do not exist.

## Guides

- [Installation](guides/installation.md): add the package, set up `FinesseApp`, build a first screen.
- [Theming](guides/theming.md): color schemes, accents, component theme overrides, radius, menus, focus rings, Material/Cupertino interop.
- [Styles](guides/styles.md): the four presets (`finesse`, `nova`, `maia`, `lyra`), custom styles, glass.
- [Form factors](guides/form-factors.md): desktop and phone metrics, how the choice is made, `FormFactorBuilder`, `withFormFactor`.
- [Layout](guides/layout.md): the gap scale, `FinesseRow`, `FinesseColumn`, `Gap`, `PageContainer`, `FinessePadding`.
- [Icons](guides/icons.md): the Phosphor classes, `PhosphorIcon` and optical weight, selected states, duotone, sizing.
- [Typography](guides/typography.md): the text role scale and how to change the font.
- [Form](guides/form.md): `FinesseForm` and the `*FormField` widgets.
- [Responsive](guides/responsive.md): the breakpoint scale, `ResponsiveBuilder`, `context.breakpoint`.
- [Portal](guides/portal.md): the overlay primitive behind popovers, selects, and menus.
- [Motion](guides/motion.md): the `Motion` tokens, what animates on its own, and the spring, press, indicator and entrance building blocks.

## Components

| Name | Description | Reference |
| :--- | :--- | :--- |
| Accordion | A vertically stacked set of interactive headings that each reveal a section of content. | [accordion.md](components/accordion.md) |
| Action Sheet | A short list of choices about the thing just touched. showActionSheet presents it the way the form factor expects: a sheet from the bottom on a phone, a menu or a small dialog on a desktop. | [action-sheet.md](components/action-sheet.md) |
| Alert | Displays a callout for user attention. | [alert.md](components/alert.md) |
| App Bar | The bar across the top of a screen: a logo or back button, a title, and actions. Its height follows the form factor and its fill the bar opacity of the style. Put it in a `Scaffold` so the page scrolls beneath it. For a bar that scrolls with the page or carries a large title, see `SliverAppBar`. | [app-bar.md](components/app-bar.md) |
| Autocomplete | A text field that suggests completions under itself as the user types. The text stays free; where the value has to be one of a list, use `Select.withSearch`. The focus never leaves the field: arrow keys move a highlight, Enter takes it, Escape closes the list. | [autocomplete.md](components/autocomplete.md) |
| Avatar | An image element with a fallback for representing the user. | [avatar.md](components/avatar.md) |
| Avatar Group | A row of overlapping avatars, each ringed in the colour of the surface behind it: the people who reacted, the mutual connections. | [avatar-group.md](components/avatar-group.md) |
| Back Button | The two buttons that leave a page. `BackButton` is a caret pointing at the start of the line; `CloseButton` is a cross. Each pops the page it is on, and an `AppBar` shows the right one by itself: a back button on a page that can be popped, a close button on a full-screen dialog. | [back-button.md](components/back-button.md) |
| Badge | Displays a badge or a component that looks like a badge. | [badge.md](components/badge.md) |
| Board | Columns of cards that are dragged to reorder them and to move them between columns, like a kanban or Trello board. A mouse drags a card at once and a finger after a long press; from the keyboard, Space picks a focused card up, the arrow keys move it and Space drops it. | [board.md](components/board.md) |
| Breadcrumb | Displays the path to the current resource using a hierarchy of links. | [breadcrumb.md](components/breadcrumb.md) |
| Button | Displays a button or a component that looks like a button. Six variants share one API: pick the one matching the action's weight. | [button.md](components/button.md) |
| Button Group | Joins buttons into one control. The children keep their own variant and size; where two meet, the corners are squared and two outlines share one hairline. `Button`, `IconButton` and `Toggle` do that by themselves inside a group. | [button-group.md](components/button-group.md) |
| Calendar | A month calendar that selects a day, several days or a range. Its parameters say what it does: bounds, how many months show, where the week starts, how the caption is laid out. How it looks is the s `CalendarTheme`, which `calendarTheme` overrides for one "
       | [calendar.md](components/calendar.md) |
| Card | Displays a card with title, description, content, and footer. | [card.md](components/card.md) |
| Carousel | Pages to swipe through, one or a few at a time: a post's photographs, a row of cards, an onboarding flow. | [carousel.md](components/carousel.md) |
| Chat Bubble | One message in a conversation. A `ChatBubble` aligns itself to its side, wraps at a fraction of the available width and squares off the corner nearest the sender into a tail. `TypingIndicator` is the three pulsing dots that go in one. | [chat-bubble.md](components/chat-bubble.md) |
| Chat List | A conversation: a lazily built list of messages that is anchored to its newest one and moves when it changes. `ChatList` is generic over your message type and controlled by its parent. Give it the messages, oldest first, an `idOf` and an `itemBuilder`, and it animates what is added, removed or resized, keeps the end in view while you are at it, and holds what you are reading still once you have scrolled away. | [chat-list.md](components/chat-list.md) |
| Checkbox | A control that allows the user to toggle between checked and not checked. | [checkbox.md](components/checkbox.md) |
| Chip | A compact pill for a filter, a choice or a tag. With `onSelected` it toggles, with `onPressed` it is a button, and with neither it is a static tag. Its height follows the form factor. `onDeleted` adds a cross that removes it, `showCheckmark` a check while it is selected, and `ChipGroup` holds the set of chosen chips. | [chip.md](components/chip.md) |
| Collapsible | An interactive component that expands and collapses a panel. | [collapsible.md](components/collapsible.md) |
| Color Picker | A colour chosen by eye, by number or from a list: an area for saturation and brightness, tracks for the hue and the opacity, a hex field and swatches. `ColorPickerButton` puts it behind a swatch, in a popover or, on a phone, a bottom sheet. | [color-picker.md](components/color-picker.md) |
| Command | A composable command menu with filtering and full keyboard navigation. | [command.md](components/command.md) |
| Context Menu | Displays a menu at the pointer, triggered by a right click or a long press. | [context-menu.md](components/context-menu.md) |
| Data Table | A table with sorting, selection, filtering, and pagination, driven by a controller. | [data-table.md](components/data-table.md) |
| Date Picker | A button that shows a date and opens a way to change it: a calendar in a popover on a desktop, a calendar or wheels in a bottom sheet on a phone. `presentation` forces either one and `mode` chooses calendar or wheels. `DateRangePicker` picks a first and a last day, `DateWheelPicker` is the wheels on their own, and `DatePickerFormField` and `DateRangePickerFormField` put the pickers in a form. | [date-picker.md](components/date-picker.md) |
| Dialog | A modal window overlaid on the page, rendering the content underneath inert. | [dialog.md](components/dialog.md) |
| Divider | A `Divider` is a hairline that separates content, horizontally or vertically. | [divider.md](components/divider.md) |
| Dropdown Menu | A menu that opens from a trigger. It flips to stay on screen, scrolls when long, and supports keyboard navigation and type-ahead. | [dropdown-menu.md](components/dropdown-menu.md) |
| Empty | A placeholder for an empty state: icon, title, description, and actions. | [empty.md](components/empty.md) |
| Floating Action Button | A button that floats over the page for the screen's main action: compose, add, start. A pill with a label, a circle without. Give it to a `Scaffold`, which keeps it clear of the bars and the keyboard. | [floating-action-button.md](components/floating-action-button.md) |
| Glass | A frosted surface: a translucent tint over a blurred, saturated backdrop, with a hairline border. Blur, saturation and opacity come from the style, so `Glass` follows the theme and its brightness. | [glass.md](components/glass.md) |
| Hover Card | A card of supplementary content that opens when the pointer rests on its trigger, when the keyboard focuses it, or on a long press. | [hover-card.md](components/hover-card.md) |
| Icon Button | A square button holding a single icon. | [icon-button.md](components/icon-button.md) |
| Icon Tile | An `IconTile` is an icon on a soft, rounded square: the marker beside a statistic, a file type, a setting. A `StatTile` puts one on a card next to a headline number and its label. | [icon-tile.md](components/icon-tile.md) |
| Indicator Badge | A small count or dot pinned to the corner of another widget: unread messages on an icon, presence on an avatar. For a label that stands in the flow of text, use `Badge`. | [indicator-badge.md](components/indicator-badge.md) |
| Kbd | Displays a keyboard key or chord. | [kbd.md](components/kbd.md) |
| Keyboard Toolbar | A toolbar shown above the software keyboard on mobile, with focus navigation and a done button. | [keyboard-toolbar.md](components/keyboard-toolbar.md) |
| License Page | A page that lists the licences of the software the app is built from. It reads them from the `LicenseRegistry` of Flutter, where the build registers the `LICENSE` file of every package, groups them by package, and opens each package on a page of its own. | [license-page.md](components/license-page.md) |
| List Detail Layout | A list and the detail of what is chosen in it. On a desktop they are side by side; on a phone the list has the screen and the detail is pushed over it as a page. It follows the  | [list-detail-layout.md](components/list-detail-layout.md) |
| List Section | A group of rows under one heading: the grouped list of a settings page, the sections of a form, a menu of destinations. | [list-section.md](components/list-section.md) |
| List Tile | A row with a leading widget, a title, a subtitle and a trailing widget: a conversation, a person to follow, a shared file, a settings entry. | [list-tile.md](components/list-tile.md) |
| Menubar | A visually persistent menu, common in desktop applications. | [menubar.md](components/menubar.md) |
| Navigation Bar | The destinations of an app. `NavigationBar` is the row of icons over labels for the top of a wide screen; `BottomNavigationBar` is the bar at the bottom of a phone, icons only unless it is asked for labels. Both take the same `NavigationDestination`s, as does a `NavigationRail`, and `NavigationScaffold` switches between them. | [navigation-bar.md](components/navigation-bar.md) |
| Navigation Rail | s destinations down the start edge of a wide screen: the "
       | [navigation-rail.md](components/navigation-rail.md) |
| Number Field | A field for a number, typed or stepped. It is controlled: `value` and `onChanged`. What is typed is clamped to `min` and `max` and written out again when the field loses the focus. | [number-field.md](components/number-field.md) |
| OTP Field | An `OtpField` takes a one-time password a character per slot, with copy-paste support. | [otp-field.md](components/otp-field.md) |
| Page Container | `PageContainer` centres page content, caps its width and gives it the page margins of the theme, so every screen lines up with the app bar. `FormFactorBuilder` picks between two layouts where a screen is arranged differently on a phone. | [page-container.md](components/page-container.md) |
| Page Indicator | A row of dots, one per page, with a pill on the current one: where you are in a carousel, an onboarding flow, a gallery. | [page-indicator.md](components/page-indicator.md) |
| Page Route | How one page replaces another. `FinessePageRoute` is the route `FinesseApp` pushes by default: a short slide and a fade on the s motion, from the end side on a phone and a few pixelsrise on a desktop. A page can be taken back with a gesture: a drag from its start edge on iOS, and a preview of the predictive back gesture on Android. `FinessePage` is the same route for a declared page list. | [page-route.md](components/page-route.md) |
| Pagination | Page navigation with previous and next links. `Pagination` shows a windowed run of page numbers; `PaginationCompact` fits toolbars, table footers and phones. | [pagination.md](components/pagination.md) |
| Popover | Displays rich content in a portal, triggered by a button. | [popover.md](components/popover.md) |
| Pressable | The behaviour underneath `Chip`, `ListTile` and the navigation bars, for building a control of your own. A `Pressable` handles pointer and keyboard activation, the cursor and button semantics, and hands its interaction states to a builder. It paints nothing itself. `FocusRing` draws the focus ring of the theme around whatever the builder returns. | [pressable.md](components/pressable.md) |
| Progress Bar | A `ProgressBar` shows how much of a task is complete, or that work is under way when the amount is unknown. | [progress-bar.md](components/progress-bar.md) |
| Progress Ring | A ring that fills as something progresses — an upload, a quota, a goal — or spins while the length is unknown. The circular counterpart of the progress bar. | [progress-ring.md](components/progress-ring.md) |
| Radio Group | A set of checkable buttons where only one can be checked at a time. | [radio-group.md](components/radio-group.md) |
| Rating | A row of stars that shows a rating, and takes one when it is given `onChanged`. A tap or a drag rates, a mouse previews, the arrow keys adjust, and assistive technology sees a slider. | [rating.md](components/rating.md) |
| Refresh Indicator | Pull a list down past its top to refresh it. A small circle comes down with the pull, pops when letting go will refresh, and spins until the refresh is done. | [refresh-indicator.md](components/refresh-indicator.md) |
| Reorderable List View | A list whose rows can be dragged into a new order: a playlist, a set of priorities, the sections of a profile. | [reorderable-list-view.md](components/reorderable-list-view.md) |
| Resizable | Resizable panel groups and layouts, with nesting and drag handles. | [resizable.md](components/resizable.md) |
| Scaffold | The frame of a screen. `Scaffold` lays an app bar, a banner, a bottom bar, a footer and a persistent sheet over the page and tells the page how far to inset itself; floats an action button over its corner; slides drawers in from its edges; keeps everything clear of the keyboard; and styles the status bar. `NavigationScaffold` builds the navigation from one list of destinations and moves it with the form factor; `DestinationStack` keeps each destination's page alive. | [scaffold.md](components/scaffold.md) |
| Scroll Area | Scrolls its content with a thin themed scrollbar. Scrollbar puts the same scrollbar on any scrollable. | [scroll-area.md](components/scroll-area.md) |
| Search Field | A text field for a search: a magnifier, a clear button while it has text and the keyboard's search action, at the metrics of `TextField`. For suggestions under the field see `Autocomplete`; for a full-screen search, `showSearch`. | [search-field.md](components/search-field.md) |
| Search View | `showSearch` opens a search and returns what was chosen: a page with a back button and a focused field on a phone, a palette on the command dialog's surface on a desktop. The builder is called with the query once typing has paused. For a fixed set of actions filtered in memory, use `Command`. | [search-view.md](components/search-view.md) |
| Segmented Control | Picks one of a few values that are all in view: a filled strip with a raised thumb on the chosen segment. It is controlled with `value` and `onChanged`, and announced as a group of radio buttons. To show one of several views, use `Tabs` or a `TabBar`, which look the same and mean something else; where none or several can be on, use a `ToggleGroup`. | [segmented-control.md](components/segmented-control.md) |
| Select | Displays a list of options for the user to pick from, triggered by a button. Give `value` to hold the choice yourself or `initialValue` to let the select keep it; `Select.multiple` holds `values`. The searchable and multiple variants open a bottom sheet on a phone. `SelectFormField` and `SelectMultipleFormField` put a select in a form. | [select.md](components/select.md) |
| Selection Area | Makes the text under it selectable as one selection across widgets. A mouse drags and right-clicks for Copy; a touch screen long-presses and gets the handles, the `TextSelectionToolbar` and the `TextMagnifier` that text fields use. | [selection-area.md](components/selection-area.md) |
| Sheet | A panel attached to an edge of the page. showSheet presents one over a barrier; a Sheet placed in the tree stays beside the content. It rests at detents, follows a finger, and takes its drag from the list inside it. | [sheet.md](components/sheet.md) |
| Sidebar | A composable, collapsible side navigation panel. Collapses to an icon rail or off-canvas, floats or insets, and becomes a modal sheet under the mobile breakpoint. ⌘B toggles it. | [sidebar.md](components/sidebar.md) |
| Skeleton | A placeholder to show while content is loading. | [skeleton.md](components/skeleton.md) |
| Slider | An input where the user selects a value from within a given range. Give `value` to hold it yourself or `initialValue` to let the slider keep it; `RangeSlider` has a thumb per value. `SliderFormField` puts a slider in a form. | [slider.md](components/slider.md) |
| Sliver App Bar | An app bar that lives in the scroll view: it can carry a large title that collapses into the toolbar, scroll away with the page, or come back when the reader turns round. Make it the first sliver of the `CustomScrollView` in a `Scaffold`'s body and give the scaffold no `appBar`. It follows the scroll at paint time — scrolling builds and lays out nothing in it. | [sliver-app-bar.md](components/sliver-app-bar.md) |
| Spinner | An animated loading indicator. | [spinner.md](components/spinner.md) |
| Stepper | A sequence of numbered steps with the current one opened: a checkout, a sign-up, a set-up wizard. Steps before the current one show as completed, and the line between two steps fills as the first of them is completed. On a desktop the steps run across the top; on a phone they run down the page and the current step opens under its title. | [stepper.md](components/stepper.md) |
| Streaming Text | Text that grows while it is on screen, such as the reply of a language model arriving token by token. `StreamingText` reveals what arrives a character at a time at an even pace, each piece fading in, instead of popping in a chunk at a time. Feed it a string that keeps getting longer, a `Stream<String>` of chunks, or a `StreamingTextController`. When the text is complete it becomes a plain `Text`. | [streaming-text.md](components/streaming-text.md) |
| Surface | The popover and menu chrome as a widget, for floating UI finesse has no component for, and a popover anchored to any rectangle. | [surface.md](components/surface.md) |
| Swipe Actions | A row with actions behind it, uncovered by swiping it sideways: archive or delete a message, mark a notification read. | [swipe-actions.md](components/swipe-actions.md) |
| Switch | A control that allows the user to toggle between checked and not checked. | [switch.md](components/switch.md) |
| Tab Bar | The list of tabs, in two looks: text tabs with a line under the selected one, and a filled strip with a raised pill. `TabBar` reports which tab was chosen through `value` and `onChanged`; a `TabBarView` shows the matching page, and `Tabs` is the two put together. To pick a value rather than show a view, use a `SegmentedControl`. | [tab-bar.md](components/tab-bar.md) |
| Table | A responsive table component with header and footer rows. | [table.md](components/table.md) |
| Tabs | Sections of content shown one at a time: a `TabBar` with the s `content` under it. Controlled with `value` and "
      "content can be swiped to the next tabs selection "
       | [tabs.md](components/tabs.md) |
| Tag Field | A field that holds a list of tags: what is typed becomes a tag on Enter or a separator, and each tag can be removed again. It is controlled: `values` and `onChanged`. | [tag-field.md](components/tag-field.md) |
| Text Field | A single-line text field. `TextField` is the control; `TextFormField` is the same field inside a `FinesseForm`. | [text-field.md](components/text-field.md) |
| Textarea | A multi-line text input, optionally user-resizable. | [textarea.md](components/textarea.md) |
| Time Field | A time typed into small number fields: hours, minutes and, optionally, seconds, with a day period on the 12-hour clock. It is the inline, keyboard-first way to enter a time; `TimePicker` is the button that opens one in a popover, or wheels on a phone. `TimeFormField` puts it in a form. | [time-field.md](components/time-field.md) |
| Time Picker | A button that shows a time and opens a way to change it: a `TimeField` in a popover on a desktop, wheels in a bottom sheet on a phone. It is the counterpart of `DatePicker`. `presentation` forces either one, `TimeWheelPicker` is the wheels on their own, and `TimePickerFormField` puts the picker in a form. | [time-picker.md](components/time-picker.md) |
| Timeline | A vertical sequence of entries joined by a line: work experience, an activity log, the steps of an order. | [timeline.md](components/timeline.md) |
| Toast | A short message that floats over the app and leaves by itself. `FinesseApp` installs one `Toaster` above the navigator; `Toaster.of(context)` shows, replaces and dismisses `Toast`s in it. On a desktop the stack sits in the bottom end corner and a toast has a close button on hover; on a phone a toast spans the bottom of the page and is swiped away, down or sideways. | [toast.md](components/toast.md) |
| Toggle | A two-state button that can be either on or off. | [toggle.md](components/toggle.md) |
| Toggle Group | A set of two-state buttons that can be toggled on or off. The group is controlled: it shows `values` and reports a tap through `onChanged`; `initialValues` instead makes a group that keeps its own selection. With `gap: 0` the items are joined into one bar, as in a `ButtonGroup`, and `ToggleGroupFormField` puts a group in a `FinesseForm`. | [toggle-group.md](components/toggle-group.md) |
| Toolbar | A bar of actions along the bottom of a screen: what can be done with what is showing. It has the surface of a whose bottom bar floats it is a glass pill, and otherwise it spans the bottom edge. | [toolbar.md](components/toolbar.md) |
| Tooltip | A popup that displays information related to an element on hover or focus. | [tooltip.md](components/tooltip.md) |
| Wheel Picker | A wheel of rows, one of which rests under a lens: the way a phone chooses from a short, ordered list. It scrolls with momentum and settles on a row, ticks under a finger, moves a row per notch of a mouse wheel and follows the arrow keys. `TimePicker` and `DatePicker` open wheels in a sheet on a phone. | [wheel-picker.md](components/wheel-picker.md) |

Each component page shows the actual example source bundled with the example app, so it cannot drift from the code that runs. They are generated by `dart run scripts/generate_skills.dart`; do not edit them by hand.

Which one to reach for:

- App structure: [Scaffold](components/scaffold.md), [App Bar](components/app-bar.md), [Navigation Bar](components/navigation-bar.md), [Page Container](components/page-container.md), [Sidebar](components/sidebar.md).
- Rows and lists: [List Tile](components/list-tile.md), [Timeline](components/timeline.md), [Table](components/table.md), [Data Table](components/data-table.md).
- Small pieces: [Chip](components/chip.md) (filters and tags), [Badge](components/badge.md) (a label in the flow), [Indicator Badge](components/indicator-badge.md) (a count or dot pinned to a corner), [Avatar Group](components/avatar-group.md), [Icon Tile](components/icon-tile.md).
- Tabs: [Tabs](components/tabs.md) is the segmented control that can own its content; [Tab Bar](components/tab-bar.md) is the underline row that only reports the selection.
- Surfaces: [Card](components/card.md), [Glass](components/glass.md) (frosted, over photos or scrolling content), [Surface](components/surface.md) (popover and menu chrome).
- A control of your own: [Pressable](components/pressable.md) with `FocusRing`.

## Basic setup

A complete counter app with light and dark theme support, in the default theme:

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseApp(
      // StyleTokens.finesse on TealColorScheme, light and dark.
      theme: ThemeData(),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppBar(title: Text('Counter')),
      body: PageContainer(
        child: FinesseColumn(
          gap: GapSize.lg,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have pushed the button this many times:',
              style: theme.textTheme.muted,
            ),
            Text('$_counter', style: theme.textTheme.h1),
            Button(
              leading: const Icon(PhosphorIconsRegular.plus),
              onPressed: () => setState(() => _counter++),
              child: const Text('Add one'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## What the package exports besides its own widgets

`package:finesse/finesse.dart` re-exports the parts of a few libraries that its own signatures depend on, so callers do not need a second dependency just to pass an argument `finesse` asks for.

- Phosphor icons are not a dependency: the six icon fonts are bundled in `finesse` itself and the constants (`PhosphorIconsRegular`, `PhosphorIconsBold`, `PhosphorIconsFill`, `PhosphorIconsLight`, `PhosphorIconsThin`, `PhosphorIconsDuotone`) and `PhosphorDuotoneIcon` are part of the package. Do not add `phosphor_flutter` or `lucide_icons_flutter`.
- [flutter_animate](https://pub.dev/packages/flutter_animate): the `effects:` parameter on `Popover`, `Select`, `Accordion`, `Menubar`, and similar components takes a list of its effects. The effect classes (`FadeEffect`, `ScaleEffect`, ...) are exported; its `Effect` base class is exported under the name `AnimEffect`.
- [two_dimensional_scrollables](https://pub.dev/packages/two_dimensional_scrollables): `FinesseTable` builds on `TableView`, so `FinesseTableCell` extends its `TableViewCell` and the span types are exported.
- [intl](https://pub.dev/packages/intl): only `DateFormat` and `NumberFormat`, used by the calendar, date picker, and pagination widgets.

Text fonts are not bundled: text uses the platform font until a `TextTheme` names one. See [typography.md](guides/typography.md).
