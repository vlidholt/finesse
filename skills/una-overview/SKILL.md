---
name: una-overview
description: How to build Flutter apps with una, a Material-free design system (a fork of shad, the Flutter port of shadcn/ui) whose widgets follow one ThemeData, four styles and a desktop and a phone form factor. Use when writing, reviewing or debugging Flutter code that imports package:una, or that uses UnaApp, Scaffold, AppBar, NavigationScaffold, Button, Card, TextField, Select, Popover, Sheet, Toaster, ListTile, Board, ChatList, PhosphorIcon or other una widgets; when theming a una app; or when looking up a una component's API and examples.
---

# una: a design system for Flutter

`una` is a complete design system as plain Flutter widgets, themed by
one `ThemeData`. It began as a fork of `shad` (the Flutter port of
shadcn/ui), so many components and three of its four styles come from
shadcn, but it has its own default look, app-structure widgets (scaffolds,
bars, navigation, sheets, pickers, lists) and a theme that knows whether
it is on a desktop or a phone.

- **No Material, no Cupertino.** One import, `package:una/una.dart`,
  next to `package:flutter/widgets.dart`. Material widgets can be mixed in
  through `package:una/material.dart` ([theming.md](guides/theming.md)).
- **Four styles**: `StyleTokens.una` (the default: soft teal glass,
  lively motion), and shadcn's `nova`, `maia` and `lyra`
  ([styles.md](guides/styles.md)).
- **Two form factors**: below the `md` breakpoint (768) the same widgets
  get phone metrics (44-point controls, 15-point body text, 16-point
  margins) and present themselves as a phone expects (bottom sheets,
  bottom bars). See [form-factors.md](guides/form-factors.md).
- **Phosphor icons are bundled**: `PhosphorIconsRegular`, `Fill`, `Bold`,
  `Light`, `Thin`, `Duotone` ([icons.md](guides/icons.md)).

## A complete app

```dart
import 'package:una/una.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaApp(
      theme: ThemeData(), // StyleTokens.una on TealColorScheme
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
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppBar(title: Text('Counter')),
      body: PageContainer(
        child: UnaColumn(
          gap: GapSize.lg,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have pressed the button', style: theme.textTheme.muted),
            Text('$_count', style: theme.textTheme.h1),
            Button(
              leading: const PhosphorIcon(PhosphorIconsRegular.plus),
              onPressed: () {
                setState(() => _count++);
                Toaster.of(context).show(Toast(title: Text('Now $_count')));
              },
              child: const Text('Add one'),
            ),
          ],
        ),
      ),
    );
  }
}
```

`UnaApp` installs the theme, localizations, the navigator
(`UnaPageRoute` transitions), the toaster and the overlay layer. A
screen is a `Scaffold` with an `AppBar`; its content is a `PageContainer`
(page margins, maximum width) laid out with the gap scale. An app with
several sections uses `NavigationScaffold`
([app-structure.md](guides/app-structure.md)).

## Rules to follow when writing una code

**Names**

- No prefix: `Button`, `Card`, `Theme`, `ThemeData`, `Scaffold`, `AppBar`,
  `ListTile`, `Chip`, `Switch`, `Dialog`, `Tooltip`. A name that would
  clash with Flutter's widgets layer has a `Una` prefix: `UnaApp`,
  `UnaRow`, `UnaColumn`, `UnaPadding`, `UnaForm`,
  `UnaFormField`, `UnaTable`, `UnaRadioGroup`,
  `UnaBorder`, `UnaDecoration`, `UnaGestureDetector`,
  `UnaPageRoute`, `UnaLocalizations`, `UnaMaterial`.
- Flutter's vocabulary where it exists: `TextField`/`TextFormField` (not
  Input), `Divider` (not Separator), `ProgressBar`, `SelectOption`,
  `OtpField`. Components with no Flutter counterpart keep shadcn's name:
  `Select`, `Sheet`, `Popover`, `Textarea`, `Command`.
- None of these exist: `Shad*`, `ShadApp`, `LucideIcons`, `Sonner`,
  `Button.raw` (or any `.raw`), `ButtonSize.icon`, `TooltipController`,
  `HoverStrategies`, `EntranceEffect`, the `vega`/`mira`/`luma`/`sera`/
  `rhea` styles, slate/gray/blue colour schemes, `flutter_animate`
  effects.

**Values and callbacks**

- Value controls are controlled: `value` + `onChanged`; a control that can
  hold its own state takes `initialValue` instead, never both. A
  `controller` exists only for more than the value (open/close, scroll,
  text editing). See [forms.md](guides/forms.md).
- Open state is `open`, `initiallyOpen`, `onOpenChanged`; controllers have
  `isOpen`, `open()`, `close()`, `toggle()`, `setOpen(bool)`. One
  `PopoverController` drives popovers, menus, tooltips and selects.
- `onPressed` on buttons and button-like controls; `onTap` on rows, cards
  and text fields; `onSelected` for picking from a list; `onChanged` for a
  value.
- Slots: `leading`/`trailing`; `title` + `subtitle` on tiles; `title` +
  `description` on surfaces (card, dialog, sheet, toast, alert); `label` +
  `description` on controls; `child` for the one content widget. Icons
  are widgets, never `IconData` parameters.
- `enabled` (not `disabled`), `semanticLabel`, `borderRadius` for a
  `BorderRadius`, `mouseCursor`. No `textDirection` parameters: wrap in a
  `Directionality` and write `start`/`end`.
- The unnamed constructor takes `variant:`; named constructors are
  shortcuts (`Button.outline`, `Badge.secondary`, `Dialog.alert`).
- A button's look is one `style:` object (`ButtonTheme`, `ToggleTheme`
  for `Toggle`), merged over its variant's theme, not colour or size
  parameters ([building-blocks.md](guides/building-blocks.md)).

**Look and size come from the theme**

- Never hard-code a control height, text size, page margin or the gap
  between components. Space between components is a `GapSize` (`xs`,
  `sm`, `md`, `lg`, `xl`): `UnaColumn(gap: GapSize.lg)`,
  `const Gap.md()`. Text is a `theme.textTheme` role, copied for a weight
  or colour (`theme.textTheme.p.copyWith(fontWeight: FontWeight.w600)`),
  never a bare `TextStyle(fontWeight:)`. Radii are `theme.radii`.
- `UnaPadding` takes spacing steps, not pixels, and has only `.all`,
  `.symmetric`, `.only` and `.directional`
  ([layout.md](guides/layout.md)).
- Never read the window width to pick a size. Branch on
  `Theme.of(context).formFactor` (or `FormFactorBuilder`) only where the
  layout *rearranges*.
- Icons: `PhosphorIcon(PhosphorIconsRegular.x)`, with no `size` inside a
  component (the component hands the size down); `PhosphorIconsFill.x` for
  the selected state. An icon-only control needs a `semanticLabel`.
- Panels are `Card`, `Surface` or `Glass` ([surfaces.md](guides/surfaces.md)),
  never a `Container` with a colour and a shadow. Outer shadows go through
  `ShadowDecoration.box`, not `BoxDecoration.boxShadow`. Text and icons
  drawn straight on a surface in the brand colour use `scheme.tint`.

**Motion, haptics, strings**

- Read motion with `Motion.of(context)` (never `theme.motion`); it honours
  reduced motion. No widget takes `effects:` or animation durations
  ([motion.md](guides/motion.md)).
- Fade state colours with `AnimatedFill`, not `AnimatedContainer`.
- Haptics go through `Haptics.selection(context)` /
  `Haptics.impact(context, HapticImpact.medium)`, never `HapticFeedback`.
- The package's strings come from `UnaLocalizations.of(context)`.

**Performance** ([performance.md](guides/performance.md))

- Few backdrop filters: `Glass(frosted: false)` inside scrolling content.
  A feed is a lazy list. Build themes once; no `ThemeData(...)` or
  `copyWith` in a hot `build`. Never `GoogleFonts.getFont` or
  `GoogleFonts.asMap`.

## Guides

| Guide | Covers |
| --- | --- |
| [installation.md](guides/installation.md) | Adding the package, `UnaApp`, localizations, a first screen. |
| [app-structure.md](guides/app-structure.md) | `Scaffold` slots and insets, `AppBar`, `SliverAppBar`, `NavigationScaffold`, destinations, drawers, routes and back gestures, tabs. |
| [form-factors.md](guides/form-factors.md) | Desktop and phone metrics, how the form factor is chosen, `FormFactorBuilder`, `withFormFactor`, breakpoints. |
| [layout.md](guides/layout.md) | The gap scale, `UnaRow`/`UnaColumn`, `Gap`, `PageContainer`, `UnaPadding`, spacing steps. |
| [theming.md](guides/theming.md) | Colour schemes, accents, component themes, radius, menus, focus rings, Material interop. |
| [styles.md](guides/styles.md) | The four styles, custom styles, translucency tokens, spacing. |
| [typography.md](guides/typography.md) | Text roles, weights, fonts, Google Fonts, custom styles. |
| [icons.md](guides/icons.md) | Phosphor classes, `PhosphorIcon` and optical weight, selected states, duotone, sizing. |
| [surfaces.md](guides/surfaces.md) | `Card`, `Surface`, `Glass`, `Backdrop`, `ShadowDecoration`: when each. |
| [liquid-glass.md](guides/liquid-glass.md) | Liquid Glass on iOS and macOS: `LiquidGlassTheme`, what switches, sizes, fallbacks. |
| [overlays.md](guides/overlays.md) | Popovers, anchors, menus, tooltips, dialogs, sheets and detents, action sheets, toasts, command palette, `Portal`. |
| [lists.md](guides/lists.md) | `ListTile`, sections, lazy lists, reordering, swipe actions, pull to refresh, tables. |
| [forms.md](guides/forms.md) | Controlled values, pickers, `UnaForm` and every `*FormField`. |
| [board-and-chat.md](guides/board-and-chat.md) | `Board`, `ChatList`, `ChatBubble`, `StreamingText`. |
| [motion.md](guides/motion.md) | The `Motion` tokens, what already moves, springs and the motion primitives. |
| [building-blocks.md](guides/building-blocks.md) | Restyling buttons, `Pressable`, `FocusRing`, `AnimatedFill`, focus helpers, haptics. |
| [accessibility.md](guides/accessibility.md) | Semantics, keyboard, text scale, right to left, reduced motion. |
| [performance.md](guides/performance.md) | The rules that keep an app cheap per frame. |

## Components by job

Each page under `components/` is generated from the example app's docs:
a description, then every example's real source. Regenerate with
`dart run scripts/generate_skills.dart`; do not edit them by hand.

**Screens and navigation**

- [Scaffold](components/scaffold.md): the frame of a screen; also
  `NavigationScaffold` and `DestinationStack`.
- [App Bar](components/app-bar.md), [Sliver App
  Bar](components/sliver-app-bar.md):
  the bar over a page; the one that scrolls and collapses.
- [Navigation Bar](components/navigation-bar.md) (top and bottom),
  [Navigation Rail](components/navigation-rail.md),
  [Navigation Menu](components/navigation-menu.md) (site-style links),
  [Sidebar](components/sidebar.md).
- [Toolbar](components/toolbar.md): actions along the bottom.
  [Floating Action Button](components/floating-action-button.md).
  [Back Button](components/back-button.md) (and `CloseButton`).
- [Page Route](components/page-route.md): `UnaPageRoute`, back
  gestures. [List Detail Layout](components/list-detail-layout.md).
  [Page Container](components/page-container.md): page margins.
- [Tabs](components/tabs.md), [Tab Bar](components/tab-bar.md):
  sections shown one at a time.
- [Breadcrumb](components/breadcrumb.md),
  [Pagination](components/pagination.md),
  [Stepper](components/stepper.md): where you are.
- [Resizable](components/resizable.md) panels,
  [Scroll Area](components/scroll-area.md).

**Actions**

- [Button](components/button.md), [Icon Button](components/icon-button.md),
  [Button Group](components/button-group.md).
- [Toggle](components/toggle.md), [Toggle Group](components/toggle-group.md),
  [Chip](components/chip.md) (filters, choices, tags; `ChipGroup`).
- [Pressable](components/pressable.md): a control of your own.
  [Kbd](components/kbd.md): a key cap.

**Text input**

- [Text Field](components/text-field.md), [Textarea](components/textarea.md),
  [Search Field](components/search-field.md),
  [Autocomplete](components/autocomplete.md).
- [Number Field](components/number-field.md),
  [OTP Field](components/otp-field.md), [Tag Field](components/tag-field.md).
- [Keyboard Toolbar](components/keyboard-toolbar.md),
  [Selection Area](components/selection-area.md).

**Choosing a value**

- [Checkbox](components/checkbox.md), [Switch](components/switch.md),
  [Radio Group](components/radio-group.md),
  [Segmented Control](components/segmented-control.md).
- [Select](components/select.md), [Slider](components/slider.md),
  [Rating](components/rating.md), [Color Picker](components/color-picker.md).
- Dates and times: [Calendar](components/calendar.md),
  [Date Picker](components/date-picker.md),
  [Date Field](components/date-field.md),
  [Time Picker](components/time-picker.md),
  [Time Field](components/time-field.md),
  [Wheel Picker](components/wheel-picker.md).

**Overlays**

- [Popover](components/popover.md), [Dropdown
  Menu](components/dropdown-menu.md),
  [Context Menu](components/context-menu.md), [Menubar](components/menubar.md).
- [Tooltip](components/tooltip.md), [Hover Card](components/hover-card.md).
- [Dialog](components/dialog.md), [Sheet](components/sheet.md),
  [Action Sheet](components/action-sheet.md).
- [Toast](components/toast.md), [Command](components/command.md),
  [Search View](components/search-view.md).

**Lists and data**

- [List Tile](components/list-tile.md), [List
  Section](components/list-section.md),
  [Expansion Tile](components/expansion-tile.md).
- [Reorderable List View](components/reorderable-list-view.md),
  [Swipe Actions](components/swipe-actions.md),
  [Refresh Indicator](components/refresh-indicator.md).
- [Table](components/table.md) (`UnaTable`, the grid),
  [Data Table](components/data-table.md) (sorting, selection, paging,
  remote rows).
- [Board](components/board.md): kanban columns.
  [Timeline](components/timeline.md).
- [Carousel](components/carousel.md),
  [Page Indicator](components/page-indicator.md).

**Conversation**

- [Chat List](components/chat-list.md), [Chat
  Bubble](components/chat-bubble.md),
  [Streaming Text](components/streaming-text.md).

**Surfaces and content**

- [Card](components/card.md), [Surface](components/surface.md),
  [Glass](components/glass.md) (and when to use each).
- [Accordion](components/accordion.md),
  [Collapsible](components/collapsible.md),
  [Divider](components/divider.md).
- [Avatar](components/avatar.md), [Avatar Group](components/avatar-group.md),
  [Badge](components/badge.md) (a static label),
  [Indicator Badge](components/indicator-badge.md) (a count on a corner),
  [Icon Tile](components/icon-tile.md) (and `StatTile`).
- [Alert](components/alert.md), [Empty](components/empty.md) (empty,
  loading and error states), [License Page](components/license-page.md).

**Progress and loading**

- [Progress Bar](components/progress-bar.md),
  [Progress Ring](components/progress-ring.md),
  [Spinner](components/spinner.md), [Skeleton](components/skeleton.md).

## Testing una widgets

- Wrap a widget under test in a `UnaApp` (or a `Theme` with a
  `ThemeData`). A narrow test window gives the phone form factor; pass
  `formFactor:` to pin one.
- `pumpAndSettle` never returns while a `Spinner` or `Skeleton` is on
  screen, or while `StreamingText` is still streaming: pump fixed frames.
  After a state change, pump the fade (200 ms) or the spring (400 ms)
  before reading a colour or position.
- An overlay's entrance starts a frame or two after it opens and takes
  about 300 ms; pump before tapping inside it.
- `find.byType(Icon)` does not find a `PhosphorIcon`; use
  `find.byIcon(...)` or `find.bySubtype<Icon>()`.
- Haptics are silent in tests unless `Haptics.debugEnabledInTests` is set.

## What the package exports besides its own widgets

- The Phosphor constants and `PhosphorIcon` / `PhosphorDuotoneIcon`: the
  fonts are bundled in una. Do not add `phosphor_flutter` or
  `lucide_icons_flutter`.
- From
  [two_dimensional_scrollables](https://pub.dev/packages/two_dimensional_scrollables):
  the span and cell types `UnaTable` builds on (`TableSpan`,
  `TableViewCell`, `TableVicinity`, ...).
- From [intl](https://pub.dev/packages/intl): `DateFormat` and
  `NumberFormat`, used by the calendar, date pickers and pagination.

Text fonts are not bundled: text uses the platform font until a
`TextTheme` names one ([typography.md](guides/typography.md)).
