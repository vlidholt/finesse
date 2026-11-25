## 0.1.0

The first release of `finesse`, a fork of
[`shad`](https://pub.dev/packages/shad) 1.0.2. This entry describes the
package as it is, compared with shad.

### Changed from shad

#### Names and vocabulary

- **The `Shad` prefix is gone.** `ShadButton` is `Button`, `ShadTheme.of` is
  `Theme.of`, `ShadThemeData` is `ThemeData`. Names that would clash with
  Flutter's widgets layer keep a `Finesse` prefix: `FinesseApp`,
  `FinesseRow`, `FinesseColumn`, `FinessePadding`, `FinesseForm`,
  `FinesseFormField`, `FinesseTable`, `FinesseBorder`, `FinesseDecoration`,
  `FinesseGestureDetector`, `FinesseRadioGroup`, `FinessePageRoute`,
  `FinesseMaterial` and a few more.
- **Flutter names where they exist.** `ShadInput` is `TextField`,
  `ShadInputFormField` is `TextFormField`, `ShadInputOTP` is `OtpField`,
  `ShadSeparator` is `Divider`, `ShadProgress` is `ProgressBar`,
  `ShadOption` is `SelectOption` and `ShadContextMenuItem` is `MenuItem`
  (`MenuItemVariant`), beside the new `MenuCheckboxItem`, `MenuRadioItem`,
  `MenuLabel`, `MenuDivider` and `MenuShortcut`. Their themes follow
  (`ThemeData.textFieldTheme`, `dividerTheme`, `progressBarTheme`, …).
- **Everything `@Deprecated` in shad 1.0 is removed**, along with its
  data-driven fixes. There are no deprecation shims for the renames below.
- **Flutter's `WidgetState`, not a state enum of our own.** `ShadState` and
  `ShadStatesController` are gone. `Button`, `IconButton` and `Toggle` take
  Flutter's `WidgetStatesController`, and the states are
  `WidgetState.hovered`, `pressed`, `focused`, `disabled` and `selected`,
  the vocabulary every pressable widget uses. `WidgetStatesController`
  changes its `value` set in place before it notifies, where
  `ShadStatesController` assigned a new set, so a listener that compares
  against the previous states keeps its own copy of them.
- **`ShadAppType.shadcn` is `FinesseAppType.standard`**, the app
  `FinesseApp.new` and `FinesseApp.router` build.
- **No `.raw` constructors.** `Button`, `IconButton`, `Badge`, `Toggle`,
  `Dialog`, `Alert`, `FinesseTableCell` and `MenuItem` take `variant:` on
  their unnamed constructor; the named ones (`Button.outline`,
  `Badge.secondary`, `Dialog.alert`, `MenuItem.inset`, …) are shortcuts.
  `Select()` takes `SelectVariant.primary` or `.search` and
  `Select.multiple()` takes `.multiple` or `.multipleWithSearch`; the select
  form fields follow. `Divider()` is the horizontal line (`Divider.vertical()`
  stays).
- **A `BorderRadius` is `borderRadius`**: on `Card`, `Dialog`, `Divider`,
  `Menubar`, `SelectOption`, `Skeleton`, `Sheet`, their themes, the themes
  of `Chip`, `Glass`, `IconTile`, `ListSection`, `ListTile`, the bottom
  navigation bar and the floating action button, and on `FinesseBorder`.
  Named corners follow (`Command.itemBorderRadius`,
  `OtpFieldSlot.firstBorderRadius`, `CalendarTheme.dayButtonBorderRadius`,
  `SheetTheme.dragHandleBorderRadius`, `SidebarTheme.menuButtonBorderRadius`
  and the rest). `ThemeData.radius`, the design token, keeps its name.
- **`cursor` is `mouseCursor`** (`Button`, `IconButton`, `Pressable`,
  `FinesseGestureDetector`, their themes, `MenubarTheme.buttonMouseCursor`,
  `TabsTheme.tabMouseCursor`) and `onHoverChange` is `onHover`.
- **Open state has one vocabulary.** `Popover`, `ContextMenu` and
  `ContextMenuRegion` take `open:` (was `visible:`); `onOpenChange` is
  `onOpenChanged`; `SidebarScaffold.defaultOpen` is `initiallyOpen`.
  Controllers have `isOpen`, `open()`, `close()`, `toggle()` and
  `setOpen(bool)`: `PopoverController.show`/`hide` are `open`/`close`, and
  `CollapsibleController` and `SidebarController` lose their settable
  `open` (`SidebarController.openMobile` is `isMobileOpen`, with
  `openMobile()`, `closeMobile()` and `setMobileOpen(bool)`).
- **`onTap`, not `onPressed`**, on `Card`, `TextField`, `Textarea`, `Select`
  and their form fields; the text fields' `onPressedAlwaysCalled` and
  `onPressedOutside` are `onTapAlwaysCalled` and `onTapOutside`.
- **Icons are widgets.** `AccordionItem.iconData`,
  `ResizablePanelGroup.handleIconData` and `Dialog.closeIconData` are gone;
  `AccordionTheme.icon`, `ResizableTheme.handleIcon` and
  `CalendarTheme.backNavigationButtonIcon`/`forwardNavigationButtonIcon`
  are const widgets. The calendar's carets follow the text direction when
  the theme gives none.
- **No `textDirection` parameters** on `Alert`, `Breadcrumb`, `Button`,
  `ResizablePanelGroup`, `RovingFocus` or the button, menubar and resizable
  themes, and no `SelectOption.direction`: wrap in a `Directionality`.
- **Smaller renames.** `Popover(popover:)` is `Popover(builder:)`.
  `Command.onItemSelected` is `onSelected`.
  `ProgressBar.semanticsLabel`/`semanticsValue` and
  `StreamingText.semanticsLabel` are `semanticLabel`/`semanticValue`; a
  determinate bar announces its percentage by default, as a `ProgressRing`
  does. `ProgressBar.backgroundColor` and `minHeight` are `trackColor` and
  `height` (the bar's height, not a floor), also on `ProgressBarTheme`.
  `SidebarMenuButton.isActive` and `SidebarMenuSubButton.isActive` are
  `selected`. `Calendar.hideNavigation`/`hideWeekdayNames` are
  `showNavigation`/`showWeekdayNames` (default true), also on
  `CalendarTheme`. `Disabled(disabled:)` is `Disabled(enabled:)`, inverted.
  `sublabel` is `description` and `direction` is
  `controlAffinity` (`ControlAffinity`) on checkboxes, radios and switches.
- **A smaller public surface.** The barrel no longer exports state classes
  (`AccordionState`, `CollapsibleState`, `ContextMenuState`, `CommandState`,
  `OtpFieldState`, `SelectState`, every `*FormFieldState`), render objects
  or plumbing (`SurfacePainter`, `MouseAreaSurface`, `PopoverTapGroups`,
  `DefaultResizeGrip`, `PanelInfo`, `ResizeResult`,
  `IndeterminateProgressBar`, `DeterminateProgressBar`; use
  `ProgressBar`). The exported names are pinned by a test.

#### Look and theme

- **A new default look.** `ThemeData()` is the `finesse` style on the
  `TealColorScheme`: 10-point controls, 18-point translucent cards, bars and
  menus of frosted glass, soft tinted shadows. Pass `style: StyleTokens.nova`
  and `colorScheme: const NeutralColorScheme.light()` for the classic
  shadcn/ui look.
- **Fewer built-in presets.** The styles are `finesse`, `nova`, `maia` and
  `lyra`; the base colour schemes are `teal`, `neutral`, `zinc` and `stone`.
  `AccentScheme` still recolours any of them, and every token a preset sets
  can be set on its own through `StyleTokens.copyWith`.
- **`ColorScheme.applyAccent` moves the tint as well as the primary.** With
  a colour that reads against both the background and the card (a contrast
  of at least 4.5:1), `tint` becomes that colour, `tintForeground` its
  foreground and `accentBorder` the tint at 32%. A colour too faint for
  that leaves the three alone.
- **Icons are Phosphor**, not Lucide, and they ship in the package: all six
  weights (`PhosphorIconsRegular`, `Bold`, `Fill`, `Light`, `Thin` and
  `PhosphorIconsDuotone` with `PhosphorDuotoneIcon`) with no extra
  dependency. The fonts are MIT licensed; the notice is in `LICENSE` and
  reaches an app's licence page automatically. The components draw their
  icons with `PhosphorIcon`: in a test, `find.byType(Icon)` does not find
  them (use `find.bySubtype<Icon>()`), and a thickened icon has no
  `RichText` beneath it.
- **Floating surfaces are glass in the default style.** Popovers, menus, a
  select's list, the command palette, tooltips and toasts are translucent
  over a blurred backdrop (`StyleTokens.popoverOpacity` and
  `tooltipOpacity`); they stay solid in `nova`, `maia` and `lyra`.
  `ThemeData.menuTranslucent` is three-state: null follows the style, true
  is shadcn's 70% finish and false keeps menus solid. A tooltip's arrow is
  part of the bubble's outline. A toast is a popover surface in every
  style: it takes the scheme's `popover` and `popoverForeground` colours.
- **Cards do not blur.** They stay translucent, but a backdrop filter per
  card is paid on every frame; opt in with
  `StyleTokens.finesse.copyWith(cardBlur: true)` or `CardTheme(blur: …)`.
- **Menu highlights are a wash in the default style.** The highlighted row
  of a menu, a `Select` and the `Command` palette is tinted with the menu's
  own foreground (`StyleTokens.menuHighlightOpacity`, 6% on a light menu and
  9% on a dark one) and its text and icons keep their colour. `nova`,
  `maia` and `lyra` keep the accent fill.
- **`ThemeData.menuAccent` changes menus only.** `MenuAccent.bold` fills
  the highlighted row of a menu with the primary colour and leaves the
  colour scheme alone; in shad it rewrote the scheme's accent pair, which
  also recoloured selected chips, cards, sidebar rows and icon tiles.
- **Table rows are lighter.** Row hover is a faint wash and a selected row
  is tinted (`TableTheme.rowHoverColor`, `rowSelectedColor`, `footerColor`,
  `footerHoverColor`); `DataTable` fills its selected rows.
- **Themes switch instead of interpolating.** `FinesseApp` applies a new
  theme in one build and cross-fades the previous frame out over it
  (`CrossFadeTheme`); `AnimatedTheme` remains for an explicit lerp.
- **A custom `ThemeVariant`** has to implement a method for every component
  theme, the new ones included, and `TextTheme.custom` requires a `caption`
  style.

#### Motion

- **Motion comes from the theme, and `flutter_animate` is gone.** No
  component takes `effects`, `duration`, `curve` or a reverse duration, and
  no theme holds an entrance: removed are `effects` on `Popover`,
  `ContextMenu`, `ContextMenuRegion`, `Select`, `AccordionItem`
  (`iconEffects` too) and their themes; `reverseDuration` and
  `popoverReverseDuration` on the overlays and their themes;
  `duration`/`curve` on the accordion, collapsible, checkbox, radio and
  switch and their themes; `showDialog(animateIn:, animateOut:, variant:)`
  and `DialogTheme.animateIn`/`animateOut`; `Toast` and `Toaster` motion
  parameters; and `EntranceEffect`, `SizeEffect`, `PaddingEffect`,
  `AnimEffect` and the `flutter_animate` re-export. Overlays grow from
  their anchor and leave in `Motion.fast`; set `ThemeData(motion:)` on a
  subtree for different motion, `Motion.none` for none.
- **Controls respond to a press.** Buttons, toggles, cards, list tiles and
  anything built on `Pressable` scale slightly while pressed and fade
  between their state colours; `ButtonTheme(pressScale: 1)` switches it off
  for one button. Menu rows, select options and command items are the
  exception: their highlight changes at once.
- **A selection travels instead of jumping.** The selected tab no longer
  paints its own fill and shadow, and a menubar trigger no longer paints
  its own highlight: the list paints one indicator that moves between them.
- **Smaller changes in behaviour.** A tooltip fades out instead of
  vanishing. `FinessePageRoute` slides as well as fades. `Skeleton`
  shimmers in the default style and holds still under reduced motion.
  `FocusRing` and `IndicatorBadge` keep the same tree shape whether shown
  or hidden.

#### Buttons and pressing

- **`Button`, `IconButton` and `Toggle` are built on `Pressable`** and take
  one `style` (a `ButtonTheme`, or a `ToggleTheme` for a toggle, merged
  over the variant's) in place of some thirty colour, size and decoration
  parameters (`width`, `height`, `padding`, `gap`, `iconSize`, the
  background and foreground colours per state, `decoration`, `shadows`,
  `gradient`, `textStyle`, `pressScale`, …). A `MenuItem`, a row that is a
  button, likewise takes one `style` (a `ContextMenuTheme`, merged over
  the theme's) in place of `padding`, `insetPadding`, `leadingPadding`,
  `trailingPadding`, `height`, `buttonVariant`, `decoration`, the text
  styles, the background colours, `anchor`, `showDelay`, `constraints` and
  `subMenuPadding`. A `Card` takes one `style` (a `CardTheme`) in place of
  `padding`, `width`, `height`, `backgroundColor`, `borderRadius`,
  `border`, `shadows`, `clipBehavior`, `gap`, `sectionGap`, `titleStyle`,
  `descriptionStyle` and the six `row*`/`column*` alignment and size
  parameters. `Dialog` and `Sheet` take a `style` (a `DialogTheme`, a
  `SheetTheme`) for their size, padding, gaps, fill, filter, border,
  corners, shadows, text styles and alignment, the layout of a dialog's
  actions and where the close button sits; what they show and how they
  behave (`scrollable`, `useSafeArea`, the `*Pinned` flags, detents,
  dragging, the close button itself) stay parameters. `DialogTheme` gains
  `filter`.
- **Rarer gestures are not button parameters.** Double tap, secondary tap,
  tap down and the long-press phases are a `FinesseGestureDetector` around
  the button. `hoverStrategies` and `longPressDuration` are gone from
  buttons, tabs, the menubar and the tooltip, and `HoverStrategies`,
  `HoverStrategy` and `ThemeData.hoverStrategies` with them: a press
  standing in for hover on a touch screen is built into
  `FinesseGestureDetector`, and the tooltip has its own long press.
  `Button.canRequestFocus` is gone (pass a `focusNode`, or `ExcludeFocus`).
- **`ButtonSize.icon` is removed**: use `IconButton`, sized from the
  theme's square sizes for `sm`, `regular` and `lg`.
- **`Badge` is a static pill.** `onPressed`, `enabled`,
  `hoverBackgroundColor` and `mouseCursor` are removed from it and from
  `BadgeTheme`; a pressable pill is a `Chip`. `shape` is `borderRadius`
  (null is a pill), on `Badge` and `BadgeTheme`, and the theme's outline
  is `BadgeTheme.borderColor`.
- **`FinesseGestureDetector` reports true global positions.** It used to
  rewrite `globalPosition` to be overlay-local inside a nested navigator
  (the shad #319 workaround); `GlobalAnchor.offset` is global as
  documented, and the portal converts it.

#### Overlays

- **One `PopoverController`** drives popovers, context menus, tooltips and
  hover cards; `TooltipController` and `FinesseContextMenuController` are
  gone (`openAt(Offset)` replaces `showAt`).
- **Tap-region plumbing is internal.** `Popover.areaGroupId` and
  `useSameGroupIdForChild`, the context menus' `groupId`, `onHoverArea`
  and `onTapOutside`/`Inside`/`UpInside`/`UpOutside`, and `groupId` on
  `Select`, `Calendar` and `TimeField` are gone: a popover opened inside
  another joins its tap region by itself. `Popover.groupId` stays, for a
  text field that keeps its focus through a tap on the popover.
- **Dialogs have no close button by default.** Pass
  `showCloseButton: true` (with `closeIcon` for another glyph, or
  `closeButton` to replace the whole button), or set it on the dialog
  theme. Sheets keep theirs. A tap on the barrier and Escape still dismiss.
  What the close button does instead of popping is `onDismissed`, on
  `Dialog` and `Sheet` alike, the name `Alert` and `Toast` use for being
  dismissed.
  On a phone a dialog's actions stack full-width from the form factor;
  `expandActionsWhenTiny` and `removeBorderRadiusWhenTiny` are gone.
- **Popovers and the keyboard focus.** A popover gives the focus back when
  it is closed, not when its exit has finished, and its child and its
  content are one focus traversal group, the child first.
  `Popover.focusNode` is removed; `DatePicker.focusNode` is the trigger's.
- **A tooltip's arrow sits on the edge that faces its trigger** by default.
- **One toast system.** `ShadSonner`, `ShadToaster` and their scopes,
  states and themes are one `Toaster` that `FinesseApp` provides:
  `Toaster.of(context).show(Toast(...))` returns an id for `update`,
  `dismiss` and `dismissAll`. `Toast` takes `title`, `description`,
  `leading`, `action`, `variant` (`ToastVariant.neutral`, `success`,
  `warning`, `destructive`, `loading`), `duration`, `dismissible` and
  `onDismissed`; `Toast.destructive` and `Toast.raw` are gone, and
  `ThemeData.toastTheme`/`toasterTheme` replace `primaryToastTheme`,
  `destructiveToastTheme` and `sonnerTheme`.
- **Sheets rest on detents.** `Sheet` takes `detents` (`SheetDetent.content`,
  `medium`, `large`, `full`, `fraction`, `height`) and a `SheetController`
  that moves between them, and can be dragged from its content; the old
  sizing, snapping, animation and alignment parameters (`expandable`,
  `initialSize`, `minSize`, `maxSize`, `snap*`, `isScrollControlled`,
  `animationController`, `dragHandleBuilder`, `onSizeChanged`, …) are
  gone. `showSheet` takes `dismissible` (was `isDismissible`) and a
  `builder` that returns the `Sheet`; `closeIcon: SizedBox.shrink()` is
  `showCloseButton: false`. `MenubarItem` takes only `child`, `items`,
  `leading`, `trailing`, `enabled` and `focusNode`.

#### Inputs and pickers

- **Value controls are controlled.** `value` + `onChanged`, or
  `initialValue` for a widget that holds its own state: `Slider` and
  `RangeSlider` (their controllers are gone; `Slider.label` is
  `semanticLabel`), `FinesseRadioGroup` (`RadioController` is gone),
  `ToggleGroup` (`ToggleGroupController` is gone), `Select`
  (`SelectController` is gone, `popoverController` is `controller`),
  `Calendar` (`selected` is `value`, `.range` takes `range`,
  `fromMonth`/`toMonth` are `min`/`max`), `DatePicker` (`selected` is
  `value`) and `OtpField` (`onChanged` reports the user's edits only).
- **One value, or a set.** The unnamed constructor of `Select`,
  `Calendar`, `ToggleGroup` and `ChipGroup` holds one value (`value`,
  `initialValue`, `onChanged`) and `.multiple` a set (`values`,
  `initialValues`, `onValuesChanged`): `Select.multiple` reports through
  `onValuesChanged`, and a single `ToggleGroup` takes a `T?`, not a set of
  at most one; `Accordion.multiple` takes `initialValues`. `ToggleGroup`
  takes `items` (was `children`) and `variant` (was `toggleVariant`);
  `ToggleGroupVariant` is gone. Whether the selection may become empty is
  `allowDeselection` everywhere, on
  `TimePicker` (from `TimePickerTheme.allowDeselection`, true in every
  style, so a time can be cleared by default) as on `DatePicker`; in a
  `Select.multiple` it keeps the last option rather than every one.
- **A null callback disables a control.** A `ToggleGroup`, a
  `FinesseRadioGroup` or a `Select` with no callback (a select with an
  `onTap` excepted) is drawn disabled
  and takes no input, as a `Toggle`, a `Chip` or a `SegmentedControl` is.
- **Pickers.** The inline time picker is `TimeField` (`TimeFieldTheme`,
  `TimeFormField`); `TimePicker` is now a trigger that opens it in a
  popover, or wheels in a sheet on a phone, and `TimePickerFormField` is
  that picker's field. `DatePicker.range` is `DateRangePicker`.
  `TimePickerController`, `TimePickerField`, `TimePickerVariant`,
  `DatePicker.raw` and `DatePickerVariant` are gone, as are the
  parameters the date picker forwarded to its button and calendar;
  `closeOnSelection` defaults to true and `DatePickerTheme` has eight
  fields. `TimeOfDay` has no `period` argument and its `second` is
  optional. The calendar's styling moved to `CalendarTheme`.
- **Picker triggers are fields.** `DatePicker`, `DateRangePicker` and
  `TimePicker` look like a text field by default; `variant:` (or the
  theme's `buttonVariant`, now null by default) makes them a button.
- **Text fields on a touch screen** have selection handles, a horizontal
  toolbar and a magnifier by default: `magnifierConfiguration` null is
  `TextMagnifier.adaptiveConfiguration`, `selectionControls` null is
  `FinesseTextSelectionControls.adaptive`, and
  `TextFieldState.defaultContextMenuBuilder` returns the horizontal toolbar
  on iOS and Android.
- **Tabs are value-based.** `TabBar<T>` takes `tabs: [Tab(value:, child:)]`,
  `value` and `onChanged`, in an underline or a segmented look; `Tab` is a
  data class, not a widget (its forwarded button parameters are gone).
  `Tabs<T>` is a tab bar over swipeable content, and lost `tabsGap`,
  `dragStartBehavior`, `physics`, `padding`, `decoration`,
  `tabBarConstraints` and `contentConstraints`. `TabsController.selected`
  is `value`. A tab bar is one Tab stop; the arrows move the selection. A
  segmented strip is as wide as its tabs unless `expandTabs` is set, and
  `tabAlignment` places it — on `TabBar`, `Tabs` and `TabsTheme` alike
  (`TabsTheme.tabBarAlignment` is `tabAlignment`); `showBorder` drops the
  hairline under an underline bar on both. A tab's label ends in an
  ellipsis when its tab is too narrow.

### Added

#### App and screen structure

- **Form factors.** Every style carries metrics for a desktop and for a
  phone. `FinesseApp` picks between them from the window width (or
  `formFactor:` pins one), so the same widgets get 44-point touch targets,
  15-point body text and tighter page margins on a narrow screen.
  `ThemeData.formFactor`, `ThemeData.withFormFactor`, `FormFactorBuilder`.
- **Layout from the theme.** A named gap scale (`GapSize`, `Gap.md()`,
  `FinesseRow(gap: GapSize.lg)`), `PageContainer` for page margins and
  maximum width, and `ThemeData.layoutTheme`.
- `Scaffold`: `appBar`, `body`, `bottomNavigationBar`, `footer`,
  `bottomSheet`, `banner`, `floatingActionButton`
  (`FloatingActionButtonLocation`), `drawer` and `endDrawer` with an edge
  drag, `resizeToAvoidBottomInset`, `systemOverlayStyle`,
  `Scaffold.of`/`ScaffoldState`. The bars lie over the body, which is
  inset by their measured heights from the first frame.
- `AppBar` (`bottom`, `centerTitle`, `surfaceBehavior`, an implied back,
  close or menu button and an implied end-drawer button) and
  `SliverAppBar` / `SliverAppBar.large`, a collapsing bar with a large
  title. `BackButton`, `CloseButton`.
- `FloatingActionButton` (primary, secondary or glass; small, regular or
  large; `extended`) and `FloatingActionButtonTheme`.
- `Toolbar`, `ListDetailLayout` (a list beside its detail, or a nested
  navigator on a phone) and `OverlayInsets`/`OverlayInsetsScope`, which
  tell floating things how much of each screen edge the bars cover.

#### Navigation

- `NavigationBar` for the top of a wide screen, a floating
  `BottomNavigationBar` for a phone (`showLabels`), `NavigationRail`
  (`NavigationRailTheme`) and `NavigationScaffold`, which places them by
  `layout` (`NavigationLayout.auto`, `bottomBar`, `topBar`, `rail`).
  `NavigationDestination.showInRail`.
- `DestinationStack`: the destinations' pages, each built on first visit
  and kept alive.
- `NavigationMenu`, `NavigationMenuItem`, `NavigationMenuLink`,
  `NavigationMenuTheme`: a site navigation bar with panels.
- `TabBar`, `Tab`, `TabBarView` (swipeable pages keyed by value),
  `TabsController` (shared by a bar and its view, with `swipePosition`),
  `SegmentedControl`, `Segment`, `SegmentedControlFormField`.
- Back gestures on `FinessePageRoute`: the iOS edge swipe and Android's
  predictive back preview (`backGesture`), and `FinessePage` for the
  pages API. `FinesseScrollBehavior` stretches on Android.

#### Overlays and sheets

- `Sheet` on detents, from any edge, as a route (`showSheet`) or inline
  (`Scaffold.bottomSheet`), with a drag handle; `Sheet.closeButton`.
- `ActionSheet`, `showActionSheet`, `ActionSheetAction`, `ActionSheetTheme`.
- Menu rows: `MenuCheckboxItem`, `MenuRadioGroup`/`MenuRadioItem`,
  `MenuLabel`, `MenuDivider`, `MenuShortcut`, `MenuItem.shortcut` and
  `value`, and `showMenu` at a point or under a rectangle. Menus carry
  semantics roles (`menu`, `menuItem`, `menuItemCheckbox`,
  `menuItemRadio`, `menuBar`).
- `Popover(showArrow:)` and `SurfaceArrow`, `HoverCard`,
  `showPopover(showArrow:)`, `Surface(arrow:)`,
  `PopoverController.openAt`.
- `Popover.requestFocus`, also on `ContextMenu`, `ContextMenuRegion`,
  `DropdownMenu`, `DatePicker`, `DateRangePicker`, `TimePicker` and
  `showPopover`: with false the caret
  stays in the field the popover hangs under, Tab moves on into the
  popover and Escape closes it from either.
- The `Toaster`: toasts stack, expand on hover, pause while hovered,
  swipe away, have a close button and a status variant, clear the bars
  (`ToasterState.insets`), and F6 moves the focus to them. `ToasterTheme`.
- `Dialog.filter`, `Tooltip.filter`, `Command.surfaceFilter`,
  `ToastTheme.filter`.

#### Inputs and pickers

- `TextField(clearable:, onCleared:, revealable:, showCounter:)`,
  `TextField.password`, `TextFormField.password`, `TextFieldState.clear()`,
  `Textarea(showCounter:)`.
- `SearchField` (`isSearchShortcut`, `shortcutLabel`, `clearOnEscape`),
  `showSearch` with `SearchViewBuilder`, `Autocomplete`, `NumberField`
  (`NumberField.stepper`, `NumberFieldVariant`), `TagField`.
- Text selection on touch: `FinesseTextSelectionControls`
  (`finesseTextSelectionControls`), `TextSelectionToolbar`,
  `TextSelectionToolbarButton`, `TextMagnifier`, `SelectionArea`,
  `TextSelectionTheme`, `TextFieldTheme.useSystemContextMenu`.
- `DateField`: typed day, month and year in the locale's order, with a
  calendar button.
- `WheelPicker` (`WheelPicker.builder`, `WheelPickerItem`,
  `WheelPickerGroup`, `WheelPickerTheme`), `TimeWheelPicker`,
  `DateWheelPicker`, `formatTimeOfDay`, `uses24HourFormat`.
- Pickers open in a sheet on a phone (`PickerPresentation`): `DatePicker`
  and `DateRangePicker` with a full-width calendar or wheels, `TimePicker`
  with wheels, and a searchable or multiple `Select`. `SelectOption.label`.
- `Slider` and `RangeSlider` value indicators (`SliderValueIndicator`),
  `Checkbox(tristate:)`, `FinesseRadioGroup(child:)`, `RadioGroupScope`.
- `Chip` (`onDeleted`, `showCheckmark`, `enabled`) and `ChipGroup`
  (`ChipGroupItem`; one, or several with `ChipGroup.multiple`, wrapping or
  scrolling, with `leading` and `trailing` actions).
- `Rating`, `ColorPicker`, `ColorPickerButton`, `colorToHex`,
  `colorFromHex`.
- `OtpField(value:, initialValue:, onCompleted:, autofillHints:)`: a paste
  or autofill spreads from the slot it lands in.
- Form fields for the new controls: `AutocompleteFormField`,
  `ChipGroupFormField` and `ChipGroupMultipleFormField`,
  `ColorPickerFormField`, `DateFormField`, `NumberFormField`,
  `RangeSliderFormField`, `RatingFormField`, `SegmentedControlFormField`,
  `SliderFormField`, `TagFormField`, `TimeFormField`, and
  `ToggleGroupFormField` and `ToggleGroupMultipleFormField`.

#### Lists and data

- `ListTile` (`value`, `showChevron`, `onLongPress`, `enabled`,
  `destructive`), `ListSection` (card or plain) and the lazy
  `SliverListSection`, `SwitchListTile`, `CheckboxListTile` (tristate),
  `RadioListTile` (one choice of the `FinesseRadioGroup` around it, as a
  `Radio` is), and `ExpansionTile`.
- `SwipeActions` (`fullSwipe`, `onRemoved`) with `SwipeAction`s,
  `RefreshIndicator`, `Carousel` (`CarouselController`), `PageIndicator`.
- `ReorderableListView`, `ReorderableListView.builder(itemId:)`,
  `SliverReorderableListView` and `ReorderableDragHandle`, on the board's
  springs: a row lifts and lands, the others make way, and every move can
  be made from the keyboard or by assistive technology.
- **Board.** `Board`, `BoardColumn`, `BoardMove`, `BoardController` and
  `BoardDragHandle`: a kanban board whose cards are dragged to reorder them
  and to move them between columns. Columns build lazily and scroll on their
  own, the board auto-scrolls while a card is held near an edge and snaps
  column by column on a phone, a column can limit or refuse what it takes,
  and every move can also be made from the keyboard or by assistive
  technology. An item keeps its state and its keyboard focus when it
  changes column. `BoardTheme`.
- **Chat.** `ChatList` is a lazily built conversation anchored to its
  newest message: a new message opens its height on a spring, the list
  follows while the reader is at the end and holds still once they have
  scrolled back, with a count of what arrived and a way back
  (`ChatListController`, `ChatListTheme`). `StreamingText` reveals text that
  is still arriving — a string that grows, a stream of chunks or a
  `StreamingTextController` — at an even pace, without splitting an emoji,
  and becomes a plain `Text` when it is complete (`StreamingTextTheme`).
  `ChatBubble` (following its content's size on a spring) and
  `TypingIndicator`.
- `DataTableController.remote` serves rows the table does not hold:
  sorting, paging and a query go to the source (`DataTablePageRequest`)
  and come back as a `DataTablePage`, with skeleton rows while a page
  loads and `DataTable.errorBuilder` for a failure.
  `DataTableColumn(sortable: true)` sorts at the source.
- `ResizableController.sizes`, `setSizes` and `reset`.
- `AvatarGroup`, `IconTile`, `StatTile`, `Timeline`, `IndicatorBadge`.

#### Buttons and feedback

- `Button(loading:, semanticLabel:)`, `IconButton(loading:, tooltip:)`,
  `Toggle(onHover:, mouseCursor:)`, `ButtonTheme.iconSize` and `padding`,
  `ToggleTheme.width`.
- `ButtonGroup`, `ButtonGroupSeparator`, `ButtonGroupText`,
  `ButtonGroupScope`: joined buttons and toggles.
- `Pressable` and `FocusRing`, the press, hover, focus and fill of every
  pressable widget, for an app's own controls (`enabled`, `selected`,
  `toggled`, `statesController`, `onHover`, `onFocusChange`,
  `semanticContainer`, `pressScale`).
- `Stepper`, `Step`, `StepState`, `StepperControls`, `StepperTheme`.
- `AlertVariant.success`, `warning` and `info`, and `Alert(onDismissed:)`.
- `ProgressRing`, which takes its colours and its spring from the
  `ProgressBarTheme`; `Skeleton.shimmer`.
- `LicensePage` and `showLicensePage`.

#### Motion

- `Motion`: one vocabulary of durations, curves and springs on the style
  (`StyleTokens.motion`: `Motion.lively` in the default style,
  `Motion.calm` in the shadcn ones, `Motion.none` to switch it off),
  overridable with `ThemeData(motion:)`. `Motion.of(context)` honours the
  platform's reduced-motion setting. Menus, popovers, tooltips and dialogs
  grow from their anchor; tabs, tab bars, navigation bars, toggle groups
  and the menubar have one travelling indicator; switches, checkboxes,
  accordions, progress bars, toasts, sheets and badges move on springs.
- The building blocks: `MotionSpring`, `SpringController`, `SpringBuilder`,
  `SpringSize`, `PressScale`, `MovingIndicator` and
  `MovingIndicatorTarget`, `Entrance`, `EntranceProgress`, `MotionOrigin`,
  `PopIn`, `PopOnChange`, `ExpandReveal`, `ContentSwitch`, `AnimatedFill`,
  `AnimatedColorBuilder`, `MotionColorTween` and `lerpColorThroughAlpha`.

#### Surfaces, icons and utilities

- **Glass.** `Glass` (`frosted: false` for a tint without a filter),
  `Backdrop`, and style tokens for blur, saturation and the opacity of
  cards, bars and glass surfaces. `BackdropSurface`, `BackdropFade`,
  `BackdropFadeHost` and `BackdropFadeHandle` fade a blurred surface inside
  its filter.
- **Colour tokens.** `ColorScheme.tint`, `tintForeground`,
  `foregroundSubtle`, `success`, `successMuted`, `warning`, `borderStrong`,
  `accentBorder` and `bar`, each with a fallback so existing schemes keep
  working.
- **A configurable radius scale.** `RadiusScale` and `StyleTokens.radius`.
- **Icons that keep their weight when small.** `PhosphorIcon` is an `Icon`
  that draws a regular Phosphor icon smaller than 24 with a slightly
  thicker line: 1.25 pixels at 16 where the font alone gives 1.
  `PhosphorIconTheme` (`referenceSize`, `strength`),
  `ThemeData.phosphorIconTheme`, and the style tokens `iconOpticalSize` and
  `iconOpticalStrength`; a strength of 0 switches it off. An app bundles
  only the glyphs it uses, of each weight.
- **Haptics.** `Haptics.selection` and `Haptics.impact` (`HapticImpact`)
  tick on Android and iOS; the board and reorderable list, slider, wheel,
  rating, number field, tab bars and segmented control, swipe actions,
  refresh indicator, sheet detents, switch, checkbox and long-press
  context menus use them.
  `ThemeData(haptics: false)` switches them off.
- `CrossFadeTheme` and `ThemeChange`; `TextTheme.caption` for fine print;
  `DismissShortcut` (Escape closes something of yours without taking the
  key from the dialog around it); `FinesseTable.rowSelected`;
  `Portal.onShown`; `BottomNavigationBarTheme.rimColor` and `shadows`.
- Style tokens `tableHoverOpacity`, `tableSelectionTinted`,
  `menuHighlightOpacity`, `floatingShadowDark`, `fabSize` (`Sm`, `Lg`)
  and, for the floating bottom bar, `bottomNavigationOpacity`,
  `bottomNavigationLift`, `bottomNavigationBorderOpacity` and
  `bottomNavigationRimOpacity` (each with a `Dark` twin).
- `FinesseLocalizations` strings for every new widget, in English; the
  other 81 locales fall back to it.

### Fixed

Problems inherited from shad:

- A popover, menu, select list, date picker or tooltip stayed on screen
  when its anchor was hidden: in an `IndexedStack` child that is not
  showing, a hidden `Visibility`, an `Offstage`, under an `Opacity` of zero
  or on a kept-alive page.
- A context menu at a point, `showMenu` and `showPopover(anchorRect:)`
  opened in the wrong place inside a nested navigator that does not start
  at the window's corner.
- An overlay moved in to stay on screen touched the screen's edge; it
  keeps a small gap now, and one that fits is not moved.
- Escape in a submenu took three presses to close it; one press closes one
  layer.
- On the web, Enter did not activate a focused button, checkbox, radio,
  switch or accordion trigger, and the arrow keys did not move through the
  rows of a menu or the options of a select.
- On the web, an outer shadow was painted behind the whole element instead
  of only outside it, and showed through any translucent fill as a grey
  wash.
- A failed validation on an OTP, radio-group, time-picker or date-picker
  form field gave the keyboard focus to a node no widget owned: the focus
  left the UI, and "FocusNode used after disposed" followed later. It now
  goes to the field's first control.
- The Escape that closed a popover, tooltip or select was reported to the
  platform as unhandled, and a closed popover inside a shown tooltip kept
  Escape from closing the tooltip.
- A label was cut off at a larger text size in tabs, small buttons and
  toggles; their style height is now a minimum once the text scale is
  above 1. Calendar cells grow with the text scale, and a month wider than
  the room is scaled down.
- The calendar's header did not mirror in a right-to-left locale.
- A calendar or date picker whose value was set to null from outside kept
  its selection, and a picker trigger's long label overflowed.
- A button was not one semantics node (the text beside it joined its
  name), and an icon button with a `semanticLabel` could not be pressed by
  a screen reader.
- A dialog's actions in a `Wrap` did not fill its width on a phone.
- A sheet's barrier did not lighten as the sheet was dragged away.
- A `ContextMenu` open from its first build did not take the keyboard
  focus.
- Toasts had their shadow clipped off.
- A `Dialog` on a narrow screen, an open `Tooltip` and a `FinesseApp` given
  no theme derived the whole theme again on every build, and the page,
  dialog and `showPopover` routes set their transition up again on every
  tick of it.
- Hover and selection fills flashed darker midway, because colours of
  different opacity were blended channel by channel.
- Table hover and footer rows came out far too dark on a scheme whose
  `muted` is translucent, `FinesseTable.list` never repainted its hover,
  and the `DataTable` selection count was not localized.
- A dialog's barrier blur popped in at the end of the transition.
- `SelectOption.hoveredBackgroundColor` was ignored.
- A controlled `ToggleGroup` called `setState` during build.
- A tooltip re-hovered while it was leaving disappeared anyway.
- Scrolling a `PageContainer` repainted the whole page on every frame, a
  switch of theme rebuilt the app on every frame of its transition, and a
  `Spinner` rebuilt on every frame instead of painting.
- `FinesseMaterial` derived its Material theme on every rebuild.
