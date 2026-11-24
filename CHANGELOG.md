## 0.1.0

The first release of `finesse`, a fork of [`shad`](https://pub.dev/packages/shad)
1.0.2.

### Changed from shad

- **The `Shad` prefix is gone.** `ShadButton` is `Button`, `ShadTheme.of` is
  `Theme.of`, `ShadThemeData` is `ThemeData`. Names that would clash with
  Flutter's widgets layer keep a `Finesse` prefix: `FinesseApp`,
  `FinesseRow`, `FinesseColumn`, `FinessePadding`, `FinesseForm`,
  `FinesseFormField`, `FinesseTable`, `FinesseBorder`, `FinesseDecoration`,
  `FinesseGestureDetector`, `FinesseRadioGroup`, `FinessePageRoute`,
  `FinesseMaterial` and a few more.
- **Flutter names where they exist.** `ShadInput` is `TextField`,
  `ShadInputFormField` is `TextFormField`, `ShadInputOTP` is `OtpField`,
  `ShadSeparator` is `Divider`, `ShadProgress` is `ProgressBar` and
  `ShadOption` is `SelectOption`. Their themes follow
  (`ThemeData.textFieldTheme`, `dividerTheme`, `progressBarTheme`, …).
- **Everything `@Deprecated` in shad 1.0 is removed**, along with its
  data-driven fixes.
- **Flutter's `WidgetState`, not a state enum of our own.** `ShadState` and
  `ShadStatesController` are gone. Every `statesController` parameter
  (`Button`, `IconButton`, `Toggle`, `Tab`, `MenubarItem`, `DatePicker` and
  the date picker form fields) takes Flutter's `WidgetStatesController`, and
  the states are `WidgetState.hovered`, `pressed`, `focused` and `disabled`,
  the same vocabulary `Pressable`, `Chip`, `ListTile` and the navigation
  bars already use. One difference in behaviour: `WidgetStatesController`
  changes its `value` set in place before it notifies, where
  `ShadStatesController` assigned a new set, so a listener that compares
  against the previous states has to keep its own copy of them.
- **`ShadAppType.shadcn` is `FinesseAppType.standard`**, the app
  `FinesseApp.new` and `FinesseApp.router` build.
- **`ColorScheme.applyAccent` moves the tint as well as the primary.** With
  a colour that reads against both the background and the card (a contrast
  of at least 4.5:1), `tint` becomes that colour, `tintForeground` its
  foreground and `accentBorder` the tint at 32%. Before, a scheme that names
  its own tint, as the default `TealColorScheme` does, kept teal icons,
  links and progress bars under a re-coloured primary. A colour too faint
  for that leaves the three alone: a scheme without a tint of its own still
  follows the new primary, and one with a tint keeps it.
- **A new default look.** `ThemeData()` is the `finesse` style on the
  `TealColorScheme`: 10-point controls, 18-point translucent cards over a
  blurred backdrop, soft tinted shadows. Pass `style: StyleTokens.nova` and
  `colorScheme: const NeutralColorScheme.light()` for the classic shadcn/ui
  look.
- **Fewer built-in presets.** The styles are `finesse`, `nova`, `maia` and
  `lyra`; the base colour schemes are `teal`, `neutral`, `zinc` and `stone`.
  `AccentScheme` still recolours any of them, and every token a preset sets
  can be set on its own through `StyleTokens.copyWith`.
- **Icons are Phosphor**, not Lucide, and they ship in the package: all
  six weights (`PhosphorIconsRegular`, `Bold`, `Fill`, `Light`, `Thin` and
  `PhosphorIconsDuotone` with `PhosphorDuotoneIcon`) with no extra
  dependency. The fonts are MIT licensed; the notice is in `LICENSE` and
  reaches an app's licence page automatically.
- **Dialogs have no close button by default.** Pass `closeIconData` or
  `closeIcon`, or set one on `primaryDialogTheme`, to get it back. Sheets
  keep theirs. A tap on the barrier and Escape still dismiss.
- **Floating surfaces are glass in the default style.** Popovers, menus, a
  select's list, the command palette and tooltips are translucent over a
  blurred backdrop (`StyleTokens.popoverOpacity` and `tooltipOpacity`); they
  stay solid in `nova`, `maia` and `lyra`. `ThemeData.menuTranslucent` is now
  three-state: null follows the style, true is shadcn's 70% finish and false
  keeps menus solid. A tooltip's arrow is part of the bubble's outline.
- **Motion comes from the theme.** Durations, curves and effects that the
  built-in themes used to set — `PopoverTheme.effects` and `reverseDuration`,
  `TooltipTheme.effects` and `duration`, `DialogTheme.animateIn` and
  `animateOut`, and the `duration`/`curve` of the switch, checkbox, radio,
  accordion and collapsible themes — are null, and the components animate
  from the `Motion` tokens instead (see "Added"). Setting any of them still
  wins. A `duration` on `Switch`, `Checkbox` or `Radio` is the duration of
  its spring.
- **Controls respond to a press.** Buttons, toggles, cards, list tiles and
  anything built on `Pressable` scale slightly while pressed and fade
  between their state colours. `Button.raw` does not scale unless given
  `pressScale`; `pressScale: 1` switches it off anywhere.
- **A selection travels instead of jumping.** The selected `Tab` no longer
  paints its own fill and shadow, and menu rows, `Select` options, `Command`
  items and menubar triggers no longer paint their own highlight: the list
  paints one indicator that moves between them.
- **Table rows are lighter.** Row hover is a faint wash and a selected row
  is tinted (`TableTheme.rowHoverColor`, `rowSelectedColor`, `footerColor`,
  `footerHoverColor`); `DataTable` now fills its selected rows.
- **Smaller changes in behaviour.** A tooltip fades out instead of
  vanishing. `FinessePageRoute` slides as well as fades. `Skeleton` shimmers
  in the default style and holds still under reduced motion. `FocusRing`
  and `IndicatorBadge` keep the same tree shape whether shown or hidden. The
  legacy `Toaster` applies `animateIn`/`animateOut` to the toast, not to
  the box that aligns it. A custom `ThemeVariant` has to implement
  `boardTheme()`.

### Added

- **Form factors.** Every style carries metrics for a desktop and for a
  phone. `FinesseApp` picks between them from the window width (or
  `formFactor:` pins one), so the same widgets get 44-point touch targets,
  15-point body text and tighter page margins on a narrow screen.
  `ThemeData.formFactor`, `ThemeData.withFormFactor`, `FormFactorBuilder`.
- **Glass.** `Glass`, `Backdrop`, and style tokens for blur, saturation and
  the opacity of cards, bars and glass surfaces. A translucent `Card` blurs
  what is behind it when the style asks for it.
- **App structure.** `Scaffold`, `AppBar`, `NavigationBar` for the top of a
  wide screen, a floating `BottomNavigationBar` for a phone, and
  `NavigationScaffold`, which switches between the two.
- **Layout from the theme.** A named gap scale (`GapSize`, `Gap.md()`,
  `FinesseRow(gap: GapSize.lg)`), `PageContainer` for page margins and
  maximum width, and `ThemeData.layoutTheme`.
- **New widgets.** `Chip`, `ListTile`, `TabBar`, `ChatBubble`,
  `TypingIndicator`, `IndicatorBadge`, `AvatarGroup`, `IconTile`,
  `StatTile`, `Timeline`, `Pressable` and `FocusRing`.
- **Colour tokens.** `ColorScheme.tint`, `tintForeground`,
  `foregroundSubtle`, `success`, `successMuted`, `warning`, `borderStrong`,
  `accentBorder` and `bar`, each with a fallback so existing schemes keep
  working.
- **A configurable radius scale.** `RadiusScale` and `StyleTokens.radius`.
- **Motion.** One vocabulary of durations, curves and springs, `Motion`,
  on the style (`StyleTokens.motion`: `Motion.lively` in the default style,
  `Motion.calm` in the shadcn ones, `Motion.none` to switch it off) and
  overridable with `ThemeData(motion:)`. `Motion.of(context)` honours the
  platform's reduced-motion setting. Menus, popovers, tooltips and dialogs
  grow from their anchor; tabs, navigation bars, toggle groups and menu
  highlights have one travelling indicator; switches, checkboxes, accordions,
  progress bars, toasts, sheets and badges move on springs. The building
  blocks are public: `MotionSpring`, `SpringController`, `SpringBuilder`,
  `PressScale`, `MovingIndicator` and `MovingIndicatorTarget`, `Entrance`,
  `EntranceEffect`, `EntranceProgress`, `MotionOrigin`, `PopIn`,
  `PopOnChange`, `ExpandReveal`, `ContentSwitch`, `AnimatedFill` and
  `AnimatedColorBuilder`.
- **Board.** `Board`, `BoardColumn`, `BoardMove`, `BoardController` and
  `BoardDragHandle`: a kanban board whose cards are dragged to reorder them
  and to move them between columns. Columns build lazily and scroll on their
  own, the board auto-scrolls while a card is held near an edge and snaps
  column by column on a phone, a column can limit or refuse what it takes,
  and every move can also be made from the keyboard or by assistive
  technology. `BoardTheme`, `ThemeData.boardTheme`.
- **Glass that fades correctly.** `BackdropSurface`, `BackdropFade`,
  `BackdropFadeHost` and `FinesseAnimate.fadeThroughBackdrop` fade a blurred
  surface inside its filter; `Dialog.filter`, `Tooltip.filter` and
  `Command.surfaceFilter` take one.
- **Smaller additions.** `Pressable.pressScale`, `Button.pressScale`,
  `Toast.enterEffects` and `exitEffects`, `Skeleton.shimmer`,
  `FinesseTable.rowSelected`, `Portal.onShown`, and style tokens
  `tableHoverOpacity` and `tableSelectionTinted`.

### Fixed

Problems inherited from shad:

- A menu or tooltip stayed on screen when the part of the app holding its
  anchor went inactive (an `IndexedStack` child that is not showing).
- Hover and selection fills flashed darker midway, because colours of
  different opacity were blended channel by channel.
- Table hover and footer rows came out far too dark on a scheme whose
  `muted` is translucent, and `FinesseTable.list` never repainted its hover.
- A dialog's barrier blur popped in at the end of the transition.
- `SelectOption.hoveredBackgroundColor` was ignored.
- A controlled `ToggleGroup` called `setState` during build.
- A tooltip re-hovered while it was leaving disappeared anyway.
