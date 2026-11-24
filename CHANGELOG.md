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
  `TealColorScheme`: 10-point controls, 18-point translucent cards, bars and
  menus of frosted glass, soft tinted shadows. Pass `style: StyleTokens.nova` and
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
  select's list, the command palette, tooltips and toasts are translucent
  over a blurred backdrop (`StyleTokens.popoverOpacity` and
  `tooltipOpacity`); they stay solid in `nova`, `maia` and `lyra`.
  `ThemeData.menuTranslucent` is now three-state: null follows the style,
  true is shadcn's 70% finish and false keeps menus solid. A tooltip's arrow
  is part of the bubble's outline. A toast is a popover surface in every
  style: it takes the scheme's `popover` and `popoverForeground` colours,
  not `background` and `foreground`.
- **Menu highlights are a wash in the default style.** The highlighted row
  of a menu, a `Select` and the `Command` palette is tinted with the menu's
  own foreground (`StyleTokens.menuHighlightOpacity`, 6% on a light menu and
  9% on a dark one) and its text and icons keep their colour. `nova`, `maia`
  and `lyra` keep the accent fill.
- **`ThemeData.menuAccent` changes menus only.** `MenuAccent.bold` fills the
  highlighted row of a menu with the primary colour and leaves the colour
  scheme alone. In shad it rewrote the scheme's accent pair, which also
  recoloured everything else drawn with the accent: selected chips and
  cards, sidebar rows, icon tiles. `DefaultThemeVariant` takes `menuAccent`.
- **Motion comes from the theme.** Durations, curves and effects that the
  built-in themes used to set — `PopoverTheme.effects` and `reverseDuration`,
  `TooltipTheme.effects`, `DialogTheme.animateIn` and `animateOut`, and the
  `duration`/`curve` of the switch, checkbox, radio, accordion and
  collapsible themes — are null, and the components animate from the
  `Motion` tokens instead (see "Added"). Setting any of them still wins. A
  `duration` on `Switch`, `Checkbox` or `Radio` is the duration of its
  spring. `Tooltip.duration` and `TooltipTheme.duration` are removed: a
  tooltip's entrance is as long as its `effects` and its exit takes
  `reverseDuration`.
- **Controls respond to a press.** Buttons, toggles, cards, list tiles and
  anything built on `Pressable` scale slightly while pressed and fade
  between their state colours. `Button.raw` does not scale unless given
  `pressScale`; `pressScale: 1` switches it off anywhere. Menu rows, select
  options and command items are the exception: their highlight changes at
  once.
- **A selection travels instead of jumping.** The selected `Tab` no longer
  paints its own fill and shadow, and a menubar trigger no longer paints its
  own highlight: the list paints one indicator that moves between them.
- **A `Tabs` strip is as wide as its tabs** unless `expandTabs` is set,
  also in a parent that stretches it, where the strip's background used to
  be pulled out to the full width. `tabBarAlignment` places the strip in the
  width there is, and a `Tabs` without panels is as small as its strip. A
  tab's text label is one line and ends in an ellipsis when its tab is too
  narrow for it.
- **Popovers and the keyboard focus.** A popover gives the focus back when
  it is closed, not when its exit animation has finished, and its child and
  its content are one focus traversal group, the child first.
  `Popover.focusNode` and `DatePicker.focusNode`, which did nothing, are
  removed; a `focusNode` given to `DatePickerFormField` or
  `DateRangePickerFormField` is the trigger button's.
  `RadioGroupFormField.focusNode` and `TimePickerFormField.focusNode` are
  removed too. See `Popover.requestFocus` under "Added".
- **Table rows are lighter.** Row hover is a faint wash and a selected row
  is tinted (`TableTheme.rowHoverColor`, `rowSelectedColor`, `footerColor`,
  `footerHoverColor`); `DataTable` now fills its selected rows.
- **Smaller changes in behaviour.** A tooltip fades out instead of
  vanishing. `FinessePageRoute` slides as well as fades. `Skeleton` shimmers
  in the default style and holds still under reduced motion. `FocusRing`
  and `IndicatorBadge` keep the same tree shape whether shown or hidden. The
  legacy `Toaster` applies `animateIn`/`animateOut` to the toast, not to
  the box that aligns it. A custom `ThemeVariant` has to implement
  `boardTheme()`, `chatListTheme()`, `streamingTextTheme()` and
  `phosphorIconTheme()`, and `TextTheme.custom` requires a `caption` style.
- **Themes switch instead of interpolating, and cards do not blur.**
  `FinesseApp` applies a new theme in one build and cross-fades the previous
  frame out over it (`CrossFadeTheme`); `AnimatedTheme` remains for an
  explicit lerp. `StyleTokens.finesse` no longer blurs behind cards — they
  stay translucent — because a backdrop filter per card is paid on every
  frame; opt in with `StyleTokens.finesse.copyWith(cardBlur: true)` or
  `CardTheme(blur: …)`. `Card` and a scrollable `PageContainer` each add a
  `RepaintBoundary`, `AnimatedFill` and `AnimatedColorBuilder` take a colour
  that changed with the theme at once, and `TypingIndicator` paints its dots.

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
  grow from their anchor; tabs, tab bars, navigation bars, toggle groups and
  the menubar have one travelling indicator; switches, checkboxes,
  accordions, progress bars, toasts, sheets and badges move on springs. The
  building blocks are public: `MotionSpring`, `SpringController`,
  `SpringBuilder`, `SpringSize`, `PressScale`, `MovingIndicator` and
  `MovingIndicatorTarget`, `Entrance`, `EntranceEffect`, `EntranceProgress`,
  `MotionOrigin`, `PopIn`, `PopOnChange`, `ExpandReveal`, `ContentSwitch`,
  `AnimatedFill` and `AnimatedColorBuilder`.
- **Board.** `Board`, `BoardColumn`, `BoardMove`, `BoardController` and
  `BoardDragHandle`: a kanban board whose cards are dragged to reorder them
  and to move them between columns. Columns build lazily and scroll on their
  own, the board auto-scrolls while a card is held near an edge and snaps
  column by column on a phone, a column can limit or refuse what it takes,
  and every move can also be made from the keyboard or by assistive
  technology. An item keeps its state and its keyboard focus when it
  changes column, and a lifted card is drawn above the board's own page,
  under anything opened over it. `BoardTheme`, `ThemeData.boardTheme`.
- **Chat.** `ChatList` is a lazily built conversation anchored to its
  newest message: a new message opens its height on a spring, the list
  follows while the reader is at the end and holds still once they have
  scrolled back, with a count of what arrived and a way back
  (`ChatListController`, `ChatListTheme`). `StreamingText` reveals text that
  is still arriving — a string that grows, a stream of chunks or a
  `StreamingTextController` — at an even pace, without splitting an emoji,
  and becomes a plain `Text` when it is complete (`StreamingTextTheme`).
  `ChatBubble` follows its content's size on a spring
  (`ChatBubble.animateSize`, `ChatBubbleTheme.sizeSpring`).
- **Icons that keep their weight when small.** `PhosphorIcon` is an `Icon`
  that draws a regular Phosphor icon smaller than 24 with a slightly
  thicker line, so that a 16-point icon does not look thin beside a
  24-point one: 1.25 pixels at 16 where the font alone gives 1. It needs no
  other font. `PhosphorIconTheme` (`referenceSize`, `strength`),
  `ThemeData.phosphorIconTheme`, and the style tokens `iconOpticalSize` and
  `iconOpticalStrength`; a strength of 0 switches it off.
- **Popovers that leave the focus where it is.** `Popover.requestFocus`,
  also on `ContextMenu`, `ContextMenuRegion`, `DropdownMenu`, `DatePicker`
  and `showPopover`. With false the caret stays in the field the popover
  hangs under, Tab moves on into the popover's content and Escape closes it
  from either.
- **Glass that fades correctly.** `BackdropSurface`, `BackdropFade`,
  `BackdropFadeHost` and `FinesseAnimate.fadeThroughBackdrop` fade a blurred
  surface inside its filter; `Dialog.filter`, `Tooltip.filter` and
  `Command.surfaceFilter` take one.
- **Smaller additions.** `TextTheme.caption` for fine print,
  `DismissShortcut` (Escape closes something of yours without taking the
  key from the dialog around it), `Pressable.pressScale`,
  `Button.pressScale` and `transitionDuration`, `Toast.enterEffects`,
  `exitEffects` and `filter`, `ToastTheme.filter`, `Skeleton.shimmer`,
  `FinesseTable.rowSelected`, `Portal.onShown`,
  `BottomNavigationBarTheme.rimColor` and `shadows`, and style tokens
  `tableHoverOpacity`, `tableSelectionTinted`, `menuHighlightOpacity`,
  `floatingShadowDark` and, for the floating bottom bar,
  `bottomNavigationOpacity`, `bottomNavigationLift`,
  `bottomNavigationBorderOpacity` and `bottomNavigationRimOpacity` (each
  with a `Dark` twin).
- **Performance building blocks.** `CrossFadeTheme`, `ThemeChange` and
  `Glass(frosted: false)` (tint, border and shadow without a backdrop
  filter). An app no longer bundles the Phosphor weights it does not use
  whole: every icon font is subset to the glyphs in use.

### Fixed

Problems inherited from shad:

- A popover, menu, select list, date picker or tooltip stayed on screen
  when its anchor was hidden: in an `IndexedStack` child that is not
  showing, a hidden `Visibility`, an `Offstage`, under an `Opacity` of zero
  or on a kept-alive page.
- On the web, an outer shadow was painted behind the whole element instead
  of only outside it, and showed through any translucent fill as a grey
  wash.
- On the web, the arrow keys did not move through the rows of a menu or the
  options of a select.
- A failed validation on an OTP, radio-group, time-picker or date-picker
  form field gave the keyboard focus to a node no widget owned: the focus
  left the UI, and "FocusNode used after disposed" followed later. It now
  goes to the field's first control.
- The Escape that closed a popover, tooltip or select was reported to the
  platform as unhandled, and a closed popover inside a shown tooltip kept
  Escape from closing the tooltip.
- A label was cut off at a larger text size in tabs, small buttons and
  toggles. Their style height is now a minimum once the text scale is above
  1; at a scale of 1 nothing changes.
- Toasts in a `Sonner` had their shadow clipped off.
- A `Dialog` on a narrow screen, an open `Tooltip` and a `FinesseApp` given
  no theme derived the whole theme again on every build, and the page,
  dialog and `showPopover` routes set their transition up again on every
  tick of it.
- Hover and selection fills flashed darker midway, because colours of
  different opacity were blended channel by channel.
- Table hover and footer rows came out far too dark on a scheme whose
  `muted` is translucent, and `FinesseTable.list` never repainted its hover.
- A dialog's barrier blur popped in at the end of the transition.
- `SelectOption.hoveredBackgroundColor` was ignored.
- A controlled `ToggleGroup` called `setState` during build.
- A tooltip re-hovered while it was leaving disappeared anyway.
- Scrolling a `PageContainer` repainted the whole page on every frame, and a
  switch of theme rebuilt the app on every frame of its transition.
- `FinesseMaterial` derived its Material theme on every rebuild.
