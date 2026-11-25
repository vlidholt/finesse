# Working notes for `finesse`

Things that are true about this repo and are expensive to rediscover. Written
for whoever (or whatever) picks the work up next.

## The fork

`finesse` is a fork of `shad` 1.0.2 (a Flutter port of shadcn/ui). The shadcn
lineage still explains most of the code — tokens are named after Tailwind
classes, three of the four styles are shadcn's — but the package now has its
own default look and its own rules.

- **Naming.** No `Shad` prefix: `Button`, `Card`, `Theme`, `ThemeData`. A
  name that would clash with Flutter's *widgets* layer (or Dart core) keeps a
  `Finesse` prefix — `FinesseApp`, `FinesseRow`, `FinesseColumn`,
  `FinessePadding`, `FinesseForm`, `FinesseFormField`, `FinesseTable`,
  `FinesseBorder`, `FinesseBorderSide`, `FinesseDecoration`,
  `FinesseGestureDetector`, `FinesseRadioGroup`,
  `FinessePageRoute`, `FinesseLocalizations`, `FinesseMaterial`. A clash with
  *Material* only (`Card`, `Switch`, `Dialog`, `Tooltip`, `Scaffold`,
  `AppBar`, `ListTile`, `Chip`) is fine: the package is Material-free, and a
  file that imports both hides one side. Before adding a public name, check
  it against `package:flutter/widgets.dart`.
- **Flutter's own types where one exists.** Interaction state is
  `WidgetState` and `WidgetStatesController`, not an enum of ours;
  `WidgetStatesController.update` mutates its set in place, so a listener
  that needs to know what changed keeps its own copy of the last value.
- **Flutter vocabulary where it exists.** `TextField`/`TextFormField` (was
  Input), `OtpField`, `Divider` (was Separator), `ProgressBar`,
  `SelectOption`, `MenuItem` (was ContextMenuItem), `Toaster`/`Toast` (was
  Sonner), and the widgets added since with Flutter's names and shapes
  (`Scaffold`, `SliverAppBar`, `NavigationRail`, `TabBarView`,
  `RefreshIndicator`, `ReorderableListView`, `ExpansionTile`, `Stepper`,
  `SelectionArea`, `Autocomplete`). Components with no Flutter counterpart
  keep shadcn's name (`Select`, `Sheet`, `Popover`, `Textarea`, `Command`).
  A name Flutter's widgets layer already has is not used even with another
  shape: `ReorderableList`, `Banner`, `MenuController`, `RadioGroup`,
  `Form`, `FormField`, `Table`, `DraggableScrollableSheet`.
- **One API vocabulary**, which new code follows and old code was brought
  into line with:
  - A value control is **controlled**: `value` + `onChanged`. One that can
    sensibly hold its own state also takes `initialValue`, never both; a
    non-null `value` is controlled, null means the widget's own state. A
    `controller` exists only where there is more to do than hold the value
    (open and close, scroll, text editing).
  - Choosing from a set: the unnamed constructor holds one value (`value`,
    `initialValue`, `onChanged`) and `.multiple` a set (`values`,
    `initialValues`, `onValuesChanged`) — `Select`, `Calendar`,
    `ToggleGroup`, `ChipGroup`, and their form fields are two classes
    (`SelectFormField`/`SelectMultipleFormField`, and so on). A widget
    with only a list value keeps `onChanged` (`RangeSlider.values`,
    `TagField`). `allowDeselection` says whether the selection may become
    empty, on pickers too (`DatePicker`, `TimePicker`, from their themes).
    **A null callback disables the control** — `Button`, `IconButton`,
    `Toggle`, `Chip`, `ToggleGroup`, `ChipGroup`, `FinesseRadioGroup`,
    `Select` (unless it has an `onTap`), `SegmentedControl`, the pickers.
  - Open state is `open`, `initiallyOpen`, `onOpenChanged`; every
    controller has `isOpen`, `open()`, `close()`, `toggle()`,
    `setOpen(bool)`.
  - `onPressed` on buttons and button-like controls (`Chip`, `MenuItem`,
    `SwipeAction`); `onTap` on rows, tiles, cards and fields; `onSelected`
    for picking from a list; `onChanged` for values.
  - Slots: `leading`/`trailing`; `icon` only where the icon is the content;
    `title` + `subtitle` on tiles, `title` + `description` on surfaces,
    `label` + `description` on controls; `child` for the one content.
  - `enabled`, never `disabled`; `semanticLabel`, `mouseCursor`, `onHover`;
    `borderRadius` for a `BorderRadius` (a name ending in `Radius` is a
    number, a `Radius` or a `RadiusToken`; `ThemeData.radius` is the token
    and keeps its name). Icons are `Widget`s, with no `*IconData` twin; an
    icon in a component theme is a **const** widget (theme equality),
    drawn through `IconTheme.merge`.
  - The unnamed constructor takes `variant:`; named constructors are
    shortcuts. There is no `.raw`.
  - No `effects:`, `duration:`, `curve:` or `textDirection:` parameters.
    Motion comes from `Motion.of(context)` and direction from
    `Directionality`; a caller who wants something else re-themes or wraps
    the subtree.
- **No deprecation shims.** The fork is pre-1.0; a rename is a changelog
  entry under "Changed from shad", not a `@Deprecated` typedef.
- **The default look** is `StyleTokens.finesse` on `TealColorScheme`, measured
  from the Strand designs (four screens, desktop and mobile, light and dark)
  that `example/lib/strand/` replicates. `nova`, `maia` and `lyra` are the
  shadcn styles that remain; `neutral`, `zinc` and `stone` the base palettes.
  `reference/ui/` (below) is still the source of truth for those three.
- **Icons are Phosphor**, vendored into this package (see "Fonts" below) and
  exported from the barrel: `PhosphorIconsRegular`, `PhosphorIconsFill`,
  `PhosphorIconsBold`, `Light`, `Thin` and `Duotone`. `PhosphorIcon` is an
  `Icon` that keeps a small regular icon's line from thinning (see "Optical
  weight" below).

### Form factors

Every `StyleTokens` has a second set of metrics for a phone: `style.mobile`
if it defines one (`finesse` → `finesseMobile`), otherwise derived by
`forFormFactor` (controls ≥ 44, body 15, page margins 16). The **variant**
owns the choice: `DefaultThemeVariant(style:, formFactor:)` keeps the style it
was given as `baseStyle` and exposes the resolved one as `style`, so every
component theme — and a theme lerp, which carries the variant — follows.
`FinesseApp` calls `theme.withFormFactor(...)` from the window width (below
`breakpoints.md`), cached per theme in an `Expando`. Never read the window
width in a component to pick a size; read the theme.

Layout that *rearranges* on a phone uses `FormFactorBuilder` or
`Theme.of(context).formFactor`. Layout that only *resizes* uses the gap scale
(`Gap.md()`, `FinesseRow(gap: GapSize.lg)`), `PageContainer` and widget
defaults, all of which read `ThemeData.layoutTheme`. Demo screens hard-code a
dimension only for a picture (see the Strand rules below).

### Glass

Translucency is a *style* property, not a colour-scheme one: schemes hold the
solid `card`/`bar` colours and the style holds `cardOpacity`, `barOpacity`,
`glassOpacity` (each with a dark override), `glassBlur` and
`glassSaturation`. `Backdrop` (`lib/src/utils/backdrop.dart`) is the one place
that builds the filter — blur composed with CSS's saturate matrix, cached per
value pair — and it returns its child untouched when there is nothing to
filter, so an opaque style pays for no layer. A backdrop filter has to be
clipped, and the clip would cut off the surface's own shadow, so `Glass`,
`Card` and the bars paint shadows from a `DecoratedBox` *outside* the
`Backdrop` — a foreground one, painted **after** the surface. A backdrop
filter samples whatever was painted before it within its blur radius, so a
shadow painted first is blurred back into the glass as a grey wash;
`BackdropSurface` orders its shadow the same way.
`test/src/components/glass_shadow_test.dart` rasterises each floating surface
with and without its shadow and requires every pixel inside the shape to be
the same (`glass_shadow_web_test.dart` repeats it in Chrome).

### Floating surfaces are glass too

`popoverOpacity` and `tooltipOpacity` (each with a dark override) do for
popovers, menus, a select's list, the command palette and tooltips what
`barOpacity` does for the bars: below 1 the surface is its colour at that
opacity over the style's glass filter. They are below 1 in `finesse` and 1
in `nova`, `maia` and `lyra`. `ThemeData.menuTranslucent` is three-state on
top of that — null follows the style, true is shadcn's 70% finish with a
`foreground/10` highlight, false keeps menus solid — and
`test/src/theme/glass_contrast_test.dart` walks every combination over the
page, black and white.

Toasts are popover surfaces as well: glass in `finesse`, `popover` and
`popoverForeground` in the shadcn styles (`ToastTheme.filter`). The
`Toaster` stack (`RenderToastStack`) clips each toast to its slot in paint,
with room for the shadow's reach; a plain `ClipRect` cut every toast's
shadow off.

- **A backdrop filter does not survive under an opacity layer on every
  renderer** (the filter samples the layer it is in, which is empty while it
  fades; the engine folds the opacity into the filter only for some layer
  trees, and the web does not at all). So an overlay's entrance fade is not
  an `Opacity` around glass. `OverlayEntrance` (`lib/src/utils/entrance.dart`,
  internal) offers its fade through a `BackdropFadeHost`, and a
  `BackdropSurface` with a filter claims it — it fades its tint, content and
  shadow *inside* the filter and fades the filter's own result
  (`Backdrop.faded`), so the whole is still a linear cross-fade; with no
  glass below, the host fades the child itself. `Popover`, `Tooltip`, the
  dialog route and the text-selection toolbar play their entrance through
  it; `Surface`/`SurfacePainter`, the tooltip, `Command`, `Dialog` and
  `Sheet` paint through `BackdropSurface`. An effect that composites its
  child into a layer of its own (blur, tint, shader) would hide the
  backdrop while it runs. Only the **outermost** surface under a host is
  offered the fade — a `BackdropSurface` wraps its content in
  `BackdropFade.none` — or glass inside a solid dialog claims the dialog's
  fade and the dialog pops in at full opacity.
  `test/src/utils/backdrop_fade_test.dart` locks it.
- A tooltip's bubble and arrow are **one path**, filled in one stroke and
  clipped as one, so a translucent tint is not doubled where they overlap.
- An entrance's exit is not its entrance reversed: `EntranceProgress` leaves
  in a straight line from wherever it was, its turning points kept per
  parent animation in an `Expando`, so a rebuilt transition keeps them.

### Motion

One vocabulary, `Motion` (`lib/src/theme/motion.dart`), lives on the style
(`StyleTokens.motion`: `lively` for `finesse`, `calm` for the shadcn styles,
`none` to switch it off) and `ThemeData(motion:)` overrides it; it is not a
`BaseTheme` field. Components read it with `Motion.of(context)` — never
`theme.motion` — which returns the reduced form under
`MediaQuery.disableAnimationsOf`. **No component takes `effects`,
`duration`, `curve` or a reverse duration**, and no component theme holds
an entrance: the package does not depend on `flutter_animate`. The few
motion knobs left on themes (`ButtonTheme.pressScale`,
`transitionDuration`, `pressAnimationDuration`, `ToggleTheme`'s) are
nullable and resolved at build (`theme.xTheme.knob ?? motion.token`), **not
baked by the variant**. A spring's duration is the token's: a caller who
wants other motion passes `ThemeData(motion:)` to the subtree.

The tokens have roles: `snappy` for touch response and selection
indicators, `smooth` for surfaces (sheets, panels, collapses), `bouncy` for
small delights (a check, a badge), `fast`/`normal` on `standard` for colour
and opacity, `exit` for leaving; `overlayScale` and `overlayTravel` shape an
overlay's entrance. Under `reduced`, movement becomes a fade and
scroll-linked effects stay.

Movement and scale ride `MotionSpring`s through `SpringController` /
`SpringBuilder`, so an interruption keeps its velocity; state fills fade
through `AnimatedFill` / `AnimatedColorBuilder`. The primitives are in
`lib/src/utils/` (`spring.dart`, `spring_size.dart`, `moving_indicator.dart`,
`entrance.dart`, `pop_in.dart`, `expand_reveal.dart`, `content_switch.dart`,
`motion_color.dart`) and are exported, except the overlays' own
`EntranceSpec` and `OverlayEntrance` (hidden in the barrel). An app
animates its own content in and out with `Entrance`. `AnimatedFill` reads
its own duration and curve from `Motion.of` (`fast` on `standard`: instant
under `Motion.none`, still a short fade under reduced motion) — do not pass
`motion.fast` to it; it needs a `Theme` above it only when one of the two is
left null. `Motion` compares a `Cubic` by its four numbers, so one written
in a `build` is fine; any other curve has to be a constant.

- **A click is down and up within one frame**, so a builder never sees
  `pressed`. `PressScale` takes a tap count (`taps:`) and pulses on it;
  `Pressable` owns that (`pressScale:`), and a widget that also wraps
  `PressScale` inside a `Pressable` builder scales twice. A `Button` scales
  as its variant's `ButtonTheme.pressScale` says; one used as a row or a
  custom control passes `style: const ButtonTheme(pressScale: 1)`.
- **A selection that travels cannot be the item's own fill.** Tabs, the tab
  bar, toggle groups, navigation destinations and menubar triggers mark a
  `MovingIndicatorTarget` and their list paints one `MovingIndicator`. It
  resolves its target at paint time (a tab is a relayout boundary), so it
  must sit inside the scroll view with no `RepaintBoundary` between it and
  its targets.
- **A menu's highlight does not travel.** Menu rows, select options and
  command items had the glide and lost it: the highlight follows the pointer
  and the arrow keys row by row, there or not, with no fade and no glide. It
  is the row's own fill again (a menu row is a `Button` whose `style` has
  `transitionDuration: Duration.zero`). In `finesse` the fill is a wash of
  the menu's foreground (`StyleTokens.menuHighlightOpacity`/`Dark`, .06/.09)
  under text that keeps its colour — an opaque accent fill is a bright slab
  on glass. A style without the token keeps shadcn's accent fill, and a
  bold menu accent fills the row with the primary either way.
- **Overlays grow from their anchor.** `Portal` publishes a `MotionOrigin`
  (corrected for the fallback side and the screen-edge shift) and an
  overlay plays `EntranceSpec.of(Motion.of(context))` — a value, compared
  by its numbers (a `Cubic` by its four), so nothing has to be cached to
  tell whether it changed. A menu that takes over from its neighbour (the
  next menubar menu, the next tooltip) plays `EntranceSpec.fade` instead,
  as a second full entrance reads as a flicker. The exit is `Motion.fast`.
  The entrance starts at `Portal.onShown`, not at `open()`: the report comes
  after the frame that first builds the overlay, for every kind of anchor.
  It runs on a controller whose duration is set by the `OverlayEntrance`
  *inside* the overlay, so one started before that widget existed ran on
  the controller's previous duration
  (`test/src/raw_components/portal_shown_test.dart`).
- A wrapper that appears only mid-animation re-parents its child and drops
  its state, so the primitives keep one tree shape (an identity `Transform`
  costs no layer): `PopIn` keeps its `Opacity` and `ClipRect` for the whole
  entrance, and `Tabs` builds its `Align` whether or not the tabs expand. A
  widget that pops *out* keeps drawing what it showed — `IndicatorBadge`
  remembers its last count while it leaves.
- **`buildTransitions` runs on every tick** of the route's animation and of
  the secondary one, for the page and for the one it covers, each time
  around a new `child`. A `CurvedAnimation` made there leaks a listener per
  tick, and a stateful transition built there starts over sixty times a
  second. What depends only on the route is kept with the route
  (`FinessePageRoute._animations`, `_AnchoredPopoverRoute._animations`,
  `DialogRoute._blurLayer`); the page is moved in paint (`_PageShift`); and
  a dialog's entrance is made once per direction, with the content
  reaching it through `_RouteChild`/`_RouteChildSlot`
  (`test/src/page_route_motion_test.dart`).
- A dialog route's transition duration is its entrance's
  (`EntranceSpec.duration`, the spring's settle time);
  `MotionSpring.settleDuration` is about 1.2 × the perceptual duration on
  purpose. Do not lengthen it.
- A `CurvedAnimation` created in `build` leaks a listener; use
  `controller.drive(CurveTween(...))`.
- **A fade around a whole page is a fade around glass.** `DestinationStack`
  (Strand's shell) and the example's `PageSwitch`
  (`example/lib/common/page_switch.dart`, the section and docs-page
  switch) slide the incoming page and fade a cover of the page colour *out*
  over it, never from fully opaque (a blank first frame reads as a flash).
  They paint one child, so the switch is incoming-only.
- The navigator keeps a new `PageRoute` offstage for its first frame, so
  default finders miss it until the second pump.

## The reference checkout

`reference/ui/` is a clone of [shadcn-ui/ui](https://github.com/shadcn-ui/ui).
It is gitignored — it is ~150 MB and not ours to vendor — but it is the source
of truth for every visual decision in the `nova`, `maia` and `lyra` styles and
in every component the `finesse` style inherits unchanged.

**Look values up there. Do not guess at colours, paddings, radii or type.**
Several rounds of this project's history were spent fixing values that were
guessed rather than read.

| What | Where |
| --- | --- |
| Per-style component CSS (we keep `nova`, `maia`, `lyra`) | `apps/v4/registry/styles/style-{vega,nova,maia,lyra,mira,luma,sera,rhea}.css` |
| Base colour palettes, OKLCH, light + dark | `apps/v4/registry/themes.ts` |
| The app's own tokens | `apps/v4/app/globals.css` |
| Component sources | `apps/v4/registry/new-york-v4/ui/*.tsx` |
| The `/create` theme editor we mirror | `apps/v4/app/(app)/(create)/` |
| Its individual pickers | `apps/v4/app/(app)/(create)/components/*.tsx` |

The style CSS files are ~1670 lines each of `.cn-<component> { @apply ... }`
blocks. To compare a component across all eight styles, parse the blocks and
diff them — **243 of the 407 classes differ between styles**, so eyeballing one
file tells you very little.

Tailwind conversions used throughout:

- Spacing: 1 unit = 4px. `px-2.5` is 10, `h-9` is 36, `p-[3px]` is a literal 3.
- Type: `text-xs` 12/16, `text-sm` 14/20, `text-base` 16/24, `text-lg` 18/28.
- Leading: `none` 1, `snug` 1.375, `normal` 1.5, `relaxed` 1.625.
- Tracking is in ems: `wide` .025, `wider` .05, `widest` .1 — multiply by the
  font size to get Flutter's logical-pixel `letterSpacing`.
- `ring-N` is a box-shadow at zero offset, so a ring has **no gap** between it
  and the element.
- OKLCH → sRGB needs a real conversion (Oklab matrices + the sRGB transfer
  function); there is a converter in this project's history, and the values it
  produces are pinned by `test/src/theme/color_scheme/shadcn_tokens_test.dart`.

## Theme architecture

The flow is: `ThemeData` factory → a `ThemeVariant` → per-component
themes. Understanding this order prevents most theming bugs.

- A **variant** is constructed from a colour scheme, a radius, a text theme, a
  `StyleTokens` and a `Spacing`, and **bakes all of them** into the
  component themes it returns. Change one of its inputs and the variant has to
  be rebuilt — `ThemeVariant.rebuild(...)` exists for exactly that, and the
  factory calls it when a caller passes both a variant and a different radius,
  scheme or text theme. Where the caller gives no explicit value, the variant's
  own wins, so the two can never disagree.
- `ThemeData.textTheme` comes from `variant.textTheme()`, **not** from the
  merged input. That is what applies the style's text roles to `small`, `muted`,
  `caption`, `p`, `list` and `large`. Reading the raw input here once made a
  style change resize components but leave every font size alone.
- `TextTheme.caption` is the fine print a size under `muted` (counts,
  timestamps, sources; 12/16 in `finesse`): the `caption` role's size, line
  height and tracking, in the muted colour, at the text theme's own regular
  weight. The role's medium weight is for the components that label things
  with it (badges, navigation items); metadata set in it stops receding.
  `TextTheme.custom` requires it
  (`test/src/theme/text_theme/caption_style_test.dart`).
- `ThemeData` records the caller's raw factory arguments (`_inputs`,
  `@ignore`d by the generator) and its hand-written `copyWith` re-runs the
  factory from them, so `copyWith(radius:/colorScheme:/style:/...)` re-derives
  every component theme. The generated mixin's `copyWith` is shadowed; its
  generated `merge` and `lerp` still go through the factory. **Adding a
  factory parameter means adding it to `_ThemeInputs` and `copyWith`
  too** — `test/src/theme/theme_data_copy_with_test.dart` catches the common
  ones.
- **Never call `ThemeData.copyWith` in a `build`.** It re-runs the factory —
  every component theme derived again — and hands `Theme` a new object, so
  its dependents compare some seventy component themes to learn nothing
  changed. A widget that re-themes its subtree derives that theme once per
  ambient theme: a top-level `Expando<ThemeData>` keyed by the ambient
  `ThemeData` (`expandedActionsThemeOf` in
  `lib/src/utils/expanded_actions_theme.dart`, shared by dialogs and sheets;
  `_contentThemeOf` in `tooltip.dart`; the board's `_itemThemeOf`; the
  Strand shell's rail theme); `FinesseApp`'s fallback themes are static.
  `test/src/components/derived_theme_identity_test.dart` holds it. Under an
  `AnimatedTheme` (not `FinesseApp`, which switches themes) the board's
  item theme is still derived per lerped `ThemeData`.
- **A theme override reaches every descendant.** The widened-buttons theme
  a narrow dialog or sheet puts around its actions widened every `Button`
  below it, including one inside a `Row` (which then has no width to
  give); it goes around each action except a horizontal `Flex`, and a
  sheet puts it around each `Button` action only
  (`dialog_tiny_actions_test.dart`).
- With no `brightness`, `ThemeData` takes it from the scheme's
  background luminance.
- There are **two variants**, but no longer two copies:
  `DefaultThemeNoSecondaryBorderVariant` subclasses
  `DefaultThemeVariant` and overrides only the focus treatment (a 2px
  inner `focusedBorder` recolour plus `focusReserve` insets, instead of the
  outward ring). Fix things in the parent; only touch the subclass when the
  change is about focus geometry.
- Menu appearance is a **theme-level** feature: `ThemeData` takes
  `menuColorScheme` (shadcn's "Inverted" — pass the dark counterpart scheme;
  the reference toggles the `dark` class on menu surfaces, so in dark mode
  inverted is a no-op), `menuTranslucent` (`popover/70` + backdrop blur,
  `foreground/10` row highlights) and `menuAccent` (bold = a highlighted row
  filled with the menu palette's primary pair). The example editor passes
  these through; it no longer derives menu colours itself.
- **`menuAccent` is carried by the variant, and the colour scheme is never
  rewritten.** shadcn implements "bold" by pointing `--accent` at
  `--primary`, and this package did the same before derivation. But here
  the accent is far more than a menu colour — the wash of a selected card,
  chip or list tile, an incoming chat bubble, an icon tile, the bottom bar's
  selected tab — and all of them turned into primary-coloured slabs. Now
  `DefaultThemeVariant.menuAccent` (`rebuild(menuAccent:)`) is read in one
  place, `menuItemHighlight`/`menuItemHighlightForeground`, and
  `test/src/theme/menu_accent_test.dart` walks palette × style ×
  brightness × accent. The `MenuAccent` enum lives in `themes/base.dart`.

### Theme equality is load-bearing

The generator compares `List` fields by identity. Every theme class with a
list field overrides `==`/`hashCode` to compare them by value and defer to the
generated `==` for the rest (see the comment in any of them, e.g.
`PopoverTheme`). A new list field needs adding to that override.

A `ThemeData` that is `!=` the previous one is a new theme to everything
that reads it: under `FinesseApp`'s `CrossFadeTheme` every dependent
rebuilds and a cross-fade starts, and under an `AnimatedTheme` a 200 ms
lerp across ~70 component themes starts. Anything that breaks value
equality — a method tear-off in `==`, a non-const `Widget` in a theme field
(a theme's icon, `ResizableTheme.handleIcon`), a `List` compared by
identity, a closure made per build (a font builder) — silently costs that
on every rebuild. `test/src/theme/theme_data_equality_test.dart` locks the
chain; add to it rather than trusting a local check.

## The token system

- `Radii` — the `none/sm/md/lg/xl/2xl/4xl/full` scale, derived from
  `ThemeData.radius` (which is the **md** step). At the default 8: 6, 8, 10,
  14, 16, 32.
- `StyleTokens` — a style as measured fields (shadcn's 67, plus the fork's
  glass, layout, navigation, chip and form-factor tokens):
  radii per surface class, ring width/opacity, border opacities, control and
  field metrics, selection-control dimensions, surface padding, shadows, and
  six `TextRole`s (`title`, `label`, `body`, `caption`, `overline`, `field`).
- `Spacing` — the `--spacing` unit (4px default).
- **Metrics shadcn writes in spacing units** (`h-9`, `px-2.5`) are stored in the
  pixels they render at the default step and are passed through the variant's
  `scaled()` so they follow `spacing.step`. **Bracketed literals**
  (`h-[18.4px]`, `rounded-[4px]`, `p-[3px]`) are not scaled. Keep that
  distinction when adding a token.
- `uppercase` on a text role is **not** applied automatically: `TextStyle` has
  no text-transform, and every Finesse component takes a caller's widget rather
  than a string. `role.applyCase(text)` is the escape hatch.
- **Icon sizes inside buttons are a token, not the caller's problem.**
  `.cn-button` carries `[&_svg:not([class*='size-'])]:size-4`, so the button
  hands 16 down through its `IconTheme`; without that Flutter's
  `IconThemeData.fallback()` renders every icon at **24**, which is what made
  toolbars look wrong and forced `size: 16` on call sites everywhere. The
  `:not` is the reason it is only a default — an `Icon` with its own `size`
  still wins. Text buttons and icon buttons are sized *separately*
  (`buttonIconSize{,Sm,Lg}` vs `iconButtonIconSize{,Sm,Lg}`): the reference's
  `.cn-button-size-icon-sm` keeps 16 where `.cn-button-size-sm` drops to 14.
  Only `mira` follows the step all the way down and only `sera` has a
  `size-3.5` base; `ButtonSizesTheme` carries `iconSm`/`iconLg` slots so
  an icon button never borrows a text button's metrics.

## Fonts

finesse bundles **no text fonts**: `TextTheme`'s default `family` is null (the
platform font). Nothing under `lib/` may name a `packages/finesse/` asset (CI
greps for it). `OtpField` uses tabular figures, not a mono face — the
reference's slots are not `font-mono`. The example loads every text font
through `google_fonts`.

### Icons are vendored

The Phosphor icon fonts **are** bundled, in `fonts/phosphor/` (six weights,
~3 MB, declared under `flutter: fonts:` in `pubspec.yaml`), with the Dart
constants in `lib/src/icons/phosphor_icons_*.dart` (`PhosphorIconsRegular`,
`Bold`, `Fill`, `Light`, `Thin`, `Duotone`; 1512 icons each). They are copied
unchanged from `phosphor_flutter` 2.1.0, and the constants are generated from
its code points. Why not depend on that package: it declares its icons as
instances of a class that *extends `IconData`*, which Flutter made final in
3.47, so it no longer compiles — and the analyzer does not report errors
inside a dependency, so the first symptom is every `flutter test` failing to
load. Ours are plain `const IconData(code, fontFamily:, fontPackage:
'finesse')`, which also keeps icon tree-shaking working.

- A duotone icon is two glyphs, so `PhosphorIconsDuotone.x` is a
  `PhosphorDuotoneIconData`, drawn by `PhosphorDuotoneIcon`, not an `Icon`.
  Two of them (`cellSignalNone`, `wifiNone`) have no fill layer.
- Unlike `phosphor_flutter`, the constants do not set `matchTextDirection`:
  mirroring every icon in RTL flips checkmarks and logos. Components that
  need a directional chevron pick one themselves.
- **Licence.** Phosphor is MIT. The notice ships three ways and all three
  must stay: `fonts/phosphor/LICENSE` (verbatim, next to the files), a second
  section in the root `LICENSE`, and a header in each generated Dart file.
  The root `LICENSE` uses Flutter's multi-licence format — sections separated
  by a line of exactly 80 hyphens, each starting with the component name and
  a blank line — because that file is what Flutter's licence collector puts
  on an app's licence page; with more than one section, a section *without*
  a name header has its first paragraph swallowed as the name.
- Inside this package's own tests the families are registered without the
  `packages/finesse/` prefix, and tests load no fonts anyway, so icons are
  boxes there. That is expected (the stroke tests below load the regular
  font themselves).
- To update: see `fonts/phosphor/README.md`.

### Optical weight

The regular weight draws its line a sixteenth of the icon's size — 1.5 at
24, 1 at 16, 0.75 at 12 — so a small icon looks thin beside a large one.
`PhosphorIcon` (`lib/src/icons/phosphor_icon.dart`) is an `Icon` subclass
that, for a `PhosphorIconsRegular` glyph smaller than
`PhosphorIconTheme.referenceSize`, fills the glyph and strokes a same-colour,
round-joined outline over it: `strength × (reference − size) / 16` more
line, so 1.25 at 16 and 1.125 at 12. The style sets both (`iconOpticalSize`
24, `iconOpticalStrength` 0.5; 0 switches it off). Every other icon — another
weight, another font, at or above the reference — is a plain `Icon`.

- **Do not swap fonts by size instead.** That was built first (bold below
  18, light from 28) and thrown away: bold is a 1.5× step, so a 16-point
  icon came out visibly heavier than an 18-point one; the tables mapping
  each regular glyph to its twins keep three fonts whole in a release build
  (+1.4 MB on the web); and an `IconData` built at run time instead of
  looked up in a const table fails the release build's icon tree-shaker.
- The outline overlaps the fill by half its width. Painted in a translucent
  colour or with a blend mode the overlap would be blended twice — a darker
  rim inside every edge — so then both are painted opaque inside one
  `saveLayer` that carries the alpha and the blend mode.
- The glyph is a leaf render object (`ThickenedGlyph`) built by
  `PhosphorIcon.build`, so there is one `Icon` in the tree and no `RichText`
  under a thickened icon. `find.byIcon` finds it once; `find.byType(Icon)`
  matches the exact type and does not — use `find.bySubtype<Icon>()`.
- `test/src/icons/phosphor_icon_stroke_test.dart` measures the painted line
  with the real font at 32 device pixels per logical pixel: at a screen's
  own density the platform fattens a small glyph and the figures differ per
  machine. `phosphor_icon_stroke_web_test.dart` runs it again in Chrome,
  where a browser test has no asset bundle and draws all text in the test
  font: it uses a five-glyph subset embedded in `phosphor_subset_font.dart`
  and sets `ui_web.TestEnvironment` to let real fonts through. Not checked
  on Impeller.

## Colour tokens (v4)

- Fields, checkboxes, radios and OTP slots outline with `--input`; cards,
  popovers, dialogs, menus and toasts with a wash of their own foreground
  (`ring-foreground/10`). Not `--border`. The soft styles vary it per surface
  *and* per brightness — `luma`/`rhea` are `/5` light `/10` dark, `sera` is
  `/5` on cards but `/10` on menus — which is why the tokens carry
  light/dark pairs for card, surface and dialog opacities.
- The `/create` styles changed the button variants from classic shadcn:
  ghost/outline hover with `bg-muted` + `text-foreground` (not accent),
  destructive is a soft `/10` tint, secondary hover is a 5% foreground mix,
  and command items highlight with `bg-muted`. Menu items still use
  `focus:bg-accent focus:text-accent-foreground` — with **every descendant**
  (icons, shortcuts) following the foreground. (`finesse` washes the row
  instead; see "A menu's highlight does not travel" under Motion.)
- **Dark `--border` and `--input` are translucent whites** (10% and 15%). This
  matters: an opaque grey hairline disappears against a card of the same value.
- The dark card and popover are a step lighter than the page.
- Overlays are `bg-black/10` with `backdrop-blur-xs` in both modes — the blur is
  what lets the tint stay that light.
- The base palettes are `teal` (the default, measured from the Strand
  designs), and `neutral`, `stone` and `zinc`, generated from `themes.ts`.
  shadcn's v3 palettes and the other bases were dropped in the fork;
  `AccentScheme` recolours any base. `applyAccentScheme` also sets the
  **tint**: the accent's primary is tuned as a button fill and is often too
  dim to draw on a dark page, so the tint is the step of the accent's ramp
  nearest the primary's lightness that reaches 4.5:1 on page and card.
- The optional scheme tokens — `tint`, `foregroundSubtle`, `success`,
  `successMuted`, `warning`, `borderStrong`, `accentBorder`, `bar` — each
  fall back to an existing token, so a hand-written scheme keeps working.
  `ColorScheme.lerp` lerps a token set on only one side against the other
  side's *fallback*, not against null, or it fades in from transparent.

## Flutter gotchas hit in this codebase

- **A per-weight font has one family name per weight, and the family has to
  change with the weight.** `google_fonts` registers `Geist_regular`,
  `Geist_500`, `Geist_700`…; a style that keeps `Geist_800` while its weight
  becomes 700 is drawn from the 800 file, and nothing warns. Three places
  lost the link and each rendered the wrong face for a long time:
  `BuilderTextStyle.copyWith` returned a plain `TextStyle`, so only the
  *first* copy re-resolved the family; `TextTheme.merge` (which `ThemeData`
  runs on every text theme) merged builder styles into plain ones; and the
  `fallback()` extension built a new `TextStyle`. All three now keep the
  style a `BuilderTextStyle`, and
  `test/src/theme/text_theme/per_weight_family_test.dart` walks every style,
  form factor and component text style with a fake per-weight font. In app
  code the rule is: **never write `TextStyle(fontWeight: …)` on its own for
  a span or an override — copy a theme style**
  (`theme.textTheme.p.copyWith(fontWeight: FontWeight.w600)`), which
  resolves the face. A test font hides all of this, since it has one face.
- **`StyleTokens.copyWith` reaches the phone metrics** only for fields the
  phone had in common with the desktop (lists by value); a field `mobile`
  sets on purpose keeps its value, and an explicit `mobile:` is used as
  given. Before that, customising the default style silently did nothing
  on a phone.
- **The three shadcn styles carry an app type scale** (`display`,
  `headline`, `subtitle`, `small`) like `finesse` does. Without one,
  `Theme.of(context).textTheme` is shadcn's *prose* scale — a 16-point `p`,
  an 18-point `large` — and a screen written against it comes out a size too
  big under that style. A style that names none of the four keeps the prose
  scale (`FixtureStyles.vega` in the tests).
- `AppBar` and `TabBar` add their hairline to their height (a 64-point bar
  is 65 tall), as CSS does with a content-box header. The bar's toolbar
  height (`appBarToolbarHeight`) is a floor that grows to one title line
  once scaled text needs it, and `AppBar.heightOf` reports that.
- **`Color.lerp` between colours of different alpha flashes.** It lerps
  red, green, blue and alpha separately, so halfway from an opaque white to
  teal's 4% `muted` wash it paints a half-opaque mid-grey, far darker than
  either end — every hover on a chip dipped through it, and so does any
  `AnimatedContainer` fading from `Color(0x00000000)`. State fills go
  through `AnimatedFill` (`lib/src/raw_components/pressable.dart`), which
  cross-fades (premultiplied). The related trap is `withValues(alpha: .5)`:
  it *replaces* the alpha, so "half of muted" has to be `muted.a * .5` —
  the table hover was a 50% wash of the foreground until it was.
  `test/src/raw_components/interaction_flash_test.dart` reads the screen
  frame by frame (`test/frame_sampler.dart`).
- **`FocusRing` is the same widget shown or hidden.** Returning the child
  bare while hidden re-parented it whenever focus came or went, which
  re-created its state and snapped its implicit animations.
- **An overlay is not painted where its anchor is, and nothing says "this
  subtree is hidden" in one place.** Hide the anchor's part of the tree and
  a menu left open sits over whatever replaced it. `AnchorStage`
  (`lib/src/utils/anchor_stage.dart`) therefore asks three times.
  `TickerMode`: disabled under a covered route. `Visibility.of`: false in
  the hidden children of an `IndexedStack`, which keeps their tickers
  *running* — `TickerMode` alone misses the commonest case. And whether the
  anchor is painted at all, by walking `paintsChild` up the render tree
  after each frame while the overlay is open: an `Offstage`, an `Opacity`
  of zero and a kept-alive page tell their descendants nothing. The first
  two are dependencies and act in the frame that hides the anchor; the
  third is a frame late.
  `Popover` and `Tooltip` build nothing in the overlay while off stage (the
  portal takes its overlay down a frame after it is told to) and finish a
  close at once; the board asks the first two itself. An anchor scrolled
  out of view is still on stage.
  `test/src/components/overlay_off_stage_test.dart` walks every way of
  hiding against every overlay (with `popover_ticker_mode_test.dart`).
- **A cancelled `TickerFuture` never completes.** `await
  controller.reverse()` does not return if anything else takes the
  controller over — an entrance restarting it, effects that change length
  mid-exit — and whatever came after the `await` (closing the tooltip)
  never happens. `await controller.reverse().orCancel` inside a
  `try`/`on TickerCanceled`, then decide again (`Tooltip._leave`,
  `test/src/components/tooltip_lifecycle_test.dart`).
- **CSS heights are border-box; `Container` adds its decoration's border as
  padding around the child** (`DecoratedBox` does not — the menubar strip
  relied on one and came out 2px short). A height constraint applied *inside*
  a `Decorator` (`lib/src/components/decorator.dart`; `InputDecorator` is
  beside it, `FinesseDecoration` in `lib/src/theme/components/decorator.dart`)
  comes out `2 × border` too tall — that made outline
  buttons and toggles 2px taller than their borderless variants and every
  control 4px taller in the no-secondary-border variant (focus reserve).
  Size constraints go *outside* the decorator;
  `test/src/components/control_heights_test.dart` locks input, select
  trigger, buttons, toggles, date/time picker, OTP slots, the menubar and
  the calendar's geometry (cell size, nav buttons, caption dropdowns —
  `calendarCellSize`/`calendarCellRadius`/`calendarPadding`/
  `calendarCaptionHeight` tokens) to the style values in both variants.
  Calendar tests use single-glyph captions and small day text: the test
  font's em-wide glyphs wrap or overflow inside cells that fit real fonts
  comfortably. Related: the select trigger's `py-2`
  never acts in the reference (its height is pinned by `data-[size]:h-*`),
  so there is no `selectPaddingY` token — only `selectPaddingX` and
  `SelectTheme.minHeight`. The time picker has no reference counterpart;
  its fields deliberately borrow the input's text role, decoration and
  height rather than carrying their own metrics.
- **Alignment goes outside the decorator as well.** `Tabs` placed its
  `w-fit` strip with an `Align` *inside* its `Decorator`, so in a parent
  that stretches it the decoration was pulled out to the full width and
  only the tabs were placed. The `Align` is around the decoration now,
  `heightFactor: 1`, and `widthFactor: 1` when the `Tabs` has no panels, so
  a list on its own is as small as its strip wherever its parent lets it
  be. A tab's text label is one line with an ellipsis in a `Flexible`, so
  an expanded tab in a narrow strip truncates instead of overflowing its
  row; a `Tab.child` that is itself a `Flexible` is left alone (two around
  one child is an error). `test/src/components/tabs_list_test.dart`.
- **`Border` requires colour-uniform sides to paint a radius**, and
  `BorderSide.none` carries opaque black. `FinesseBorderSide.toBorderSide()`
  therefore keeps its colour at zero width. Any component that draws only some
  of its sides (the OTP strip) depends on this.
- **There is no z-index in a `Row`.** shadcn's focused OTP slot uses `z-10` to
  let its ring overlap its neighbours; in Flutter the next sibling paints over
  the ring's edge instead. The ring is still drawn *outside* the slot (slots
  are transparent, so only their hairlines cross it); don't move it inside —
  that reads as a different control from every other field.
- **The portal's overlay is nudged after it is anchored, and anything drawn
  against the anchor has to follow.** `PositionDelegate` runs Flutter's
  `positionDependentBox`, which clamps the overlay into the viewport at layout
  time — so a tooltip near the window edge is slid inward while its arrow, a
  `Center` inside the bubble, stayed put and pointed at empty space. The
  portal now computes the same placement in `_calculatePosition` (through
  `PositionDelegate.positionFor`, so the two cannot drift apart) and
  publishes the displacement as `PortalPlacement.shift`; the arrow
  subtracts it, clamped to keep the bubble's corner radius plus its own
  half-diagonal clear of each end. Doing this at *paint* time instead
  (`localToGlobal` from the arrow) looks simpler and is wrong: the
  entrance's scale wraps the arrow, so the measurement moves while the
  tooltip animates in. `showPopover`'s route does the same as a portal —
  lays the popover out once unseen, then publishes a `PortalPlacement` — so
  its `SurfaceArrow` reads the placement exactly as it would under one.
- **The portal moves an overlay only when it does not fit**, and then keeps
  the theme's `gap(GapSize.sm)` clear of the screen edge
  (`PositionDelegate.clearOfEdges`, also for the unseen measuring layout):
  a menu under a trigger at the edge stays in line with its trigger.
- **`GlobalAnchor.offset` is global**, and the portal converts it with the
  overlay's own `globalToLocal` (`buildGlobalPosition`), so a menu at a
  point opens under the pointer inside a nested navigator that does not
  start at the window's corner. `FinesseGestureDetector` reports true
  global positions; it used to "correct" them to be overlay-local (shad
  #319), which put every such menu, and a slider in a docked navigator, in
  the wrong place. Feed `openAt`, `showMenu` and `showPopover(anchorRect:)`
  global coordinates (`portal_placement_test.dart`).
- **CSS clips outer box-shadows to outside the border box, and Flutter cannot
  express that with a `BoxShadow`.** `BlurStyle.normal` paints the shadow
  behind the whole box, which shows through any transparent or translucent
  fill as a grey wash; `BlurStyle.outer` cuts the hole out of
  `rect.shift(offset).inflate(spreadRadius)` — the *shadow's* rectangle, not
  the element's — so with any offset or spread the shadow disappears next to
  the element and then restarts with a hard edge a few pixels out. A
  `shadow-lg` dialog lost the 7px directly beneath it that way. Outer shadows
  therefore go through `ShadowDecoration` (`lib/src/utils/shadow.dart`),
  which blurs normally and clips to the region outside the wrapped
  decoration's own `getClipPath`. **Never put an outward shadow in a
  `BoxDecoration.boxShadow` here** — use `ShadowDecoration.box(...)`, which
  takes the same arguments. `test/src/utils/shadow_test.dart` locks the
  profile (monotone falloff, nothing inside the element, a crisp hairline for
  the spread-only shadows used as outlines) by rasterising and sampling; it
  flips `debugDisableShadows` off, which flutter_test otherwise leaves on.
  Tests that introspect a component's fill or border go through
  `test/decoration_finders.dart` to look past the wrapper.
- **On the web `Path.combine` returns its first operand unchanged.** The
  clip above was `Path.combine(PathOperation.difference, bounds, shape)`, so
  in a browser it never cut its hole and every outer shadow was painted
  behind the whole element: the grey, "dirty" look of every translucent
  card, bar, menu, dialog and sheet on the web, and of none of them in a
  test. Do not use `Path.combine` in paint code. A hole is an even-odd path
  (`_clipOutside` in `shadow.dart`), cut **one contour at a time** —
  even-odd counts an overlap twice, so a tooltip's bubble and arrow cut out
  together would leave their overlap in. A union is two contours wound the
  same way and filled non-zero (the tooltip's outline). The shadow tests
  now also run in a browser: `test/src/utils/shadow_web_test.dart` and
  `test/src/components/glass_shadow_web_test.dart`. CI runs every
  `*_web_test.dart` with `--platform chrome`; the VM suite skips them
  (`@TestOn('browser')`).
- `Button` centres its label (`TextAlign.center` in its DefaultTextStyle).
  Anything button-based that should read as a row — menu items — must merge
  `TextAlign.start` back in below the button.
- `FinesseBorder.merge` takes the other's `borderRadius` and `offset` only
  where the other sets them. Taking both unconditionally once made an
  override that set only the radius drop the offset, which collapsed a
  focus ring onto the element's own border; keep the two null-aware. The
  `FinesseRoundedSuperellipseBorder` branch builds a new border, so it has
  to carry `offset` and `padding` itself (`border_merge_test.dart`).
- `OutwardBorderPainter` inflates the rect by `offset` and strokes *inside*
  it, so `offset == width` puts the stroke flush against the element. That is
  how the shadcn ring's "no gap" is reproduced.
- A `Positioned` child does not contribute to a `Stack`'s size. The slider's
  thumb is positioned, so the slider has to reserve `max(track, thumb)` itself
  or it lays out at track height and paints over its neighbours.
- A widget with no intrinsic height stretches when its parent hands down tight
  constraints. `Kbd` takes an explicit height and an `Align(heightFactor: 1)`
  so a key cap stays key-shaped inside a button's row.
- **A style height is a floor, not a size, once text is scaled.** `h-9` is
  the height at the platform's own text size; the label scales and the box
  did not, so a tab lost its label at 1.3× and a small button at 1.6×.
  `Button` (and so `Tab` and menu rows), `Toggle`, `Chip` and `TabBar`
  constrain `minHeight: h, maxHeight: textScaledMaxHeight(context, h)`
  (`lib/src/utils/text_scaled_height.dart`): exactly `h` at a scale of 1 or
  less, so the heights that line controls up on a row are untouched, and
  above 1 the control grows only when its content needs the room — which
  means nothing inside may expand to the height it is offered. Only a box
  that is fixed in *both* directions around a glyph (an OTP slot, a
  time-field part, a calendar cell and its caption row) multiplies its side
  by `max(1, MediaQuery.textScalerOf(context).scale(1))`.
  `control_heights_test.dart` walks scales from .85 to 3, the calendar
  through every style, form factor and focus variant.
- **Padding derived to fill a fixed height leaves no room for anything
  else inside it.** A style with a tab height pads the label to fill it
  exactly; the no-secondary-border variant's focus reserve is inside that
  height too, so the label was laid out in a line's height less the reserve
  and lost its descenders. The variant takes the reserve out of the padding.
- Vertical centring in a fixed-height field is governed by the **content
  column's `mainAxisAlignment`**, not by an inner `Align`.
- State-dependent text colour must be resolved where the state is known. A
  `DefaultTextStyle` inside a builder's captured `child` cannot see hover.
- **Anchors take a fallback chain** (`AnchorAuto.fallback`, recursively);
  the portal keeps the candidate that overflows the screen least, then
  shifts. Submenus and `DropdownMenu` rely on it to flip horizontally.
  `GlobalAnchor.followerAnchor` picks the overlay point placed at the
  global offset; context menus use `topStart` (corner at the pointer).
- `Textarea` has its own theme; it previously read `TextFieldTheme` for
  padding and alignment, which made every textarea-specific value dead.
- **A loop that only ever `await`s a synchronously-completed future never
  returns to the event loop.** Dart drains the *whole* microtask queue before
  taking the next event, so such a loop freezes the app outright: no frames,
  no pointer input, and no response to a window resize (the resize path is
  `scheduleForcedFrame`, which still needs an event-loop turn). This is not
  hypothetical — `Select`'s hover-to-scroll chevrons hit it. A second
  `animateTo` on a `ScrollPosition` calls `beginActivity`, which disposes the
  previous activity, and `DrivenScrollActivity.dispose` completes its
  completer **synchronously**; two loops therefore cancel each other in an
  unbroken microtask chain, and because the offset only advances on a frame
  that never comes, neither exit condition is ever met. Any driver loop here
  needs a re-entrancy guard *and* a real yield (`Future.delayed(Duration.zero)`)
  per iteration. `test/src/components/select_auto_scroll_test.dart` locks the
  guard. On web this reads as a browser bug, which is how it went unnoticed.
- **An early or late key handler, a `HardwareKeyboard` handler, or
  anything else that reacts to a system event, asks whether its widget is
  shown and on top when the event arrives: `isShownOnTop(context)`
  (`lib/src/utils/route_on_top.dart`, exported) — `TickerMode`,
  `Visibility.of` and `isInTopRoute`, which checks every navigator up
  without a dependency.** `ModalRoute.isCurrent` answers for one navigator
  only: a page in a nested navigator stays current under a dialog pushed
  on the root one. The page route's back gestures, the hover card, the
  navigation menu's Escape and the sidebar's ⌘B/Ctrl+B all go through it;
  there is no second copy.
- **Escape must not be bound unconditionally.** A `CallbackShortcuts` for
  Escape consumes the key even while its overlay is closed, so the enclosing
  dialog never closes. Use `DismissShortcut` (`lib/src/utils/`, exported),
  which leaves the key unhandled while inactive. It is a `Focus(onKeyEvent:)`
  on the focus chain, not a `Shortcuts` + `Actions` pair: an action is
  looked up from the focused widget by its intent's type, so the *nearest*
  one answers for every `Shortcuts` on the way up, and an inactive inner
  `DismissShortcut` shadowed the active one around it (a closed popover
  inside a shown tooltip). `isActive` is asked once, *before* `onDismiss`:
  asked afterwards it answers for the next press, and the Escape that closed
  the overlay is reported unhandled (the platform beeps, a browser leaves
  full screen). Nested, one press closes one layer, innermost first
  (`test/src/components/escape_propagation_test.dart`).
- **A focused text field consumes Escape**, whether or not it has a use for
  it, so a handler that waits for the keys nobody wanted never hears it.
  Wrap the `DismissShortcut` directly around the widget that holds the
  focus. Where the focus is not in your subtree at all —
  `showPopover(requestFocus: false)`, whose route is above the one with the
  focus — the route listens with
  `FocusManager.instance.addEarlyKeyEventHandler`, and stands back when the
  focus is inside the popover so its own bindings act first.
- **Focus and popovers.** `Popover.requestFocus` (also on `ContextMenu`,
  `ContextMenuRegion`, `DropdownMenu`, `DatePicker`, `DateRangePicker`,
  `TimePicker` and `showPopover`; not on `Select` or the menubar) says whether the popover takes the focus when
  it opens. True traps Tab in a `FocusScope`; false leaves the caret where
  it is and makes the popover's controls the Tab stops after its child.
  Either way child and overlay are one `FocusTraversalGroup` under an
  `OrderedTraversalPolicy`, child first: reading order would put a popover
  that opened *above* its anchor before it, and the group is there in both
  modes so the child keeps its place in the tree when the flag changes.
  The overlay is built below the portal, so in the focus tree it is a
  descendant of what surrounds the child and one `DismissShortcut` hears
  Escape from both. The focus goes back at `close()`, in a microtask, not
  when the exit has played: whatever closed the popover may have asked for
  the focus itself. A text field gives up the focus on a click outside *its*
  tap region, so a field that keeps the caret under a popover takes the
  popover's `groupId` (`test/src/components/popover_focus_test.dart`).
- **`FocusScopeNode.requestFocus(node)` adopts a node no widget owns.** An
  unattached node is reparented under the route's scope, where it becomes a
  primary focus that no key event or traversal can reach and that outlives
  its own disposal ("FocusNode used after disposed", much later). A form
  field made of several controls (OTP, radio group, time picker) hands its
  node to none of them, so `FinesseFormFieldState.focus()` asks the node
  only when `node.context != null` and otherwise the first focusable control
  in *element* order — a `FocusNode`'s children are in the order they were
  attached, which a rebuild shuffles
  (`test/src/components/form_focus_test.dart`).
- **On the web the default shortcuts scroll with the arrow keys**; on every
  other platform they move the focus. A list that left its arrows to the
  defaults — a menu, a select's options — could be opened from the keyboard
  in a browser and then not walked. `ArrowKeyFocus`
  (`lib/src/utils/arrow_key_focus.dart`, internal) binds them to
  directional focus around such a list; a text field inside keeps its own.
  `menu_arrow_keys_test.dart` runs on the VM with the web's shortcut map,
  `menu_arrow_keys_web_test.dart` in Chrome. Not checked on the web: the
  menubar's left/right and the command palette.
- **Each root context menu has its own tap-region group**, shared with its
  submenus (`_ContextMenuState.tapRegionGroupId`). A single global group
  made a tap on another menu's trigger count as inside, so the open menu
  never closed. A popover opened from inside another joins its group by
  itself; the plumbing that used to be public (`areaGroupId`,
  `useSameGroupIdForChild`, `onHoverArea`, the tap callbacks) is on
  `Popover.internal` and `ContextMenu.internal`.
- **Escape in a submenu closes one layer.** The row whose submenu was
  dismissed remembers it (`_submenuDismissed`) until the pointer or the
  focus leaves the row or the arrow into the submenu is pressed; otherwise
  the still-highlighted row opens the submenu again at once and Escape
  seems to take three presses (`submenu_escape_test.dart`).
- **Menu roles go only inside a menu.** Flutter asserts that a
  `SemanticsRole.menuItem` has a `menu` or `menuBar` ancestor and that a
  menu is not empty, so the roles are applied inside a `_MenuLevel` only;
  a `MenuItem` built outside a menu has none
  (`menu_semantics_test.dart`).
- **Dialog routes follow the app theme live** unless opened from a locally
  re-themed subtree; capturing `Theme.of(context)` at push time froze open
  dialogs and sheets in the old theme across a light/dark switch.
- **Private field promotion is per library.** Two classes in one file with a
  same-named private field, one of them non-final, disable promotion of both
  (`TimeOfDay._period` broke when the controller gained a `_period`).
- `calendar.dart` used to contain a literal NUL byte in a cache key, which
  made `grep` treat it as binary and silently skip it. It is `\u0000` now;
  keep NULs escaped.
- **A fully transparent `ColoredBox` still hit-tests as opaque** (it extends
  `RenderProxyBoxWithHitTestBehavior` with `behavior: opaque`). The dialog
  route's full-screen barrier-blur layer uses one to give its
  `BackdropFilter` extent, and without an `IgnorePointer` it silently ate
  every outside tap — barrier dismissal was dead for all dialogs and sheets
  and nobody noticed, because dialogs have close buttons.

## Testing

- **Every golden is `await expectLater(...)`.** `matchesGoldenFile` is
  asynchronous; inside a plain `expect` a mismatch is never reported, which is
  how 52 of 58 goldens went stale unnoticed until 1.0.
  `test/goldens_are_awaited_test.dart` fails on an unawaited one.
- **Goldens are Linux-only.** They are generated by the `update-goldens`
  workflow (`gh workflow run update-goldens.yml --ref <branch>`, then
  `gh run download <id> -n updated-goldens` and copy `test/` over) and
  compared only on Linux: `test/flutter_test_config.dart` (through
  `golden_config_io.dart`, behind a conditional import so the Chrome tests
  still compile) skips pixel comparison elsewhere — macOS differs by
  several percent on these small images — and makes `--update-goldens` a
  no-op there, so macOS pixels can never be committed.
  `SHAD_COMPARE_GOLDENS=1` forces comparison; `SHAD_SKIP_GOLDENS=1` skips
  it on Linux too (the minimum-Flutter CI job).
- Prefer asserting resolved *theme values* over pixels. For anything with modes
  (menu colour × finish × accent × brightness) walk the whole matrix in one test
  and assert luminance contrast — that found a real collision (light + inverted
  + bold puts a near-black primary on a near-black surface) that reasoning about
  cases had missed twice.
- **A `FocusableActionDetector` only learns of the highlight mode from a
  change notification**, and in a test a mouse that is merely *connected*
  changes what `FocusManager.highlightMode` returns without sending one. A
  test that mixes mouse and Tab calls `useTraditionalHighlights()` first.
- `pumpAndSettle` hangs on anything with `Skeleton` or `Spinner`; pump
  fixed frames instead. A `StreamingText` settles only once nothing is
  streaming: its caret breathes for as long as more text is expected.
- A popover's entrance starts after the frame that first builds its overlay
  (`Portal.onShown`) — a frame or two after `open()`; an auto anchor is
  first laid out unseen to be measured, the only time the overlay ignores
  pointers — and takes about 290 ms; the exit takes `Motion.fast`. The
  content takes taps from its first visible frame, but under a scale
  transform, so pump ~12 × 50 ms before tapping an option, and pick options
  near the top of the list, since ones below the scroll fold are found but
  not tappable. A popover that took the focus gives it back at `close()`,
  not when the exit has played.
- **An overflow is reported once per render object.** A test that checks
  "nothing overflows" at several window sizes or text scales pumps a fresh
  tree for each (`pumpWidget(const SizedBox.shrink())` in between); pumped
  over the same tree, every size after the first passes whatever it does.
- **Under the fake clock, do not `await` the `close()` of a
  `StreamController` a mounted widget listens to**: the done event is only
  delivered by the next pump, the future never completes and the test hangs
  instead of failing. `unawaited(chunks.close())`, then pump. A stand-in
  stream is a `StreamController` driven by `Timer`s that `onCancel` cancels
  (`example/lib/strand/widgets/messages_assistant.dart`), not an `async*`
  around `Future.delayed`, whose pending delay outlives the listener.
- A controller started between two frames moves on the *second* pump: pump
  once before a timed pump when sampling an animation. A test that reads a
  colour or ring right after a state change pumps the fade (200 ms) or the
  spring (400 ms) first.
- An overlay's element hangs under its anchor, so when the anchor is off
  stage a default finder calls a menu that is still on screen "gone"; such
  tests use `skipOffstage: false`. A board's lifted copy hangs under the
  board in the same way.
- Example tests set `GoogleFonts.config.allowRuntimeFetching = false`; the
  resulting log lines are noise, not failures.
- **Tests run as Android by default**, so every scrollable has the stretch
  overscroll's aligned `Transform` around it: a finder for "a `Transform`
  with an alignment", or a measurement right after an overscroll drag,
  finds that first.
- `tester.tap` is a touch (haptics, press-as-hover) unless given
  `kind: PointerDeviceKind.mouse`. `FinesseApp` picks the phone form factor
  from the narrow default test window unless `formFactor:` is passed. One
  `pump(Duration(seconds: 5))` advances one frame, not five seconds of
  frames. `find.text` also matches what is typed in a text field.
- A widget test that opens a `Calendar` under a non-default locale first
  runs `await tester.runAsync(() => initializeDateFormatting('en_GB'))`;
  `DateFormat.localeExists` throws while no symbols are loaded.
- **A render harness restores `FlutterError.onError` in a `finally`**: a
  step that throws (a mouse `tapAt` followed by `createGesture` on the same
  device asserts) otherwise leaves it replaced and the test hangs instead
  of failing.
- Docs pages are long and the sidebar listing them longer: an example test
  scrolls before it taps (`Scrollable.ensureVisible(element, alignment:
  .5)`, `openPage` in `example/test/app_shell_test.dart`). A page added
  above another pushes it below the fold.
- A modal sheet is the whole route, so `find.byType(Sheet)` is the page;
  with one detent its handle has no "Resize" semantics (find it by
  `'${w.runtimeType}' == '_SheetHandle'`).

## Build and CI

- Component themes are generated: `dart run build_runner build
  --delete-conflicting-outputs` after touching anything under
  `lib/src/theme/**`. The generated `*.g.theme.dart` files are committed.
- i18n uses slang's **legacy** builder — regenerate with `dart run slang`, not
  `build_runner`. Only `lib/src/i18n/en.i18n.yaml` needs editing; other locales
  inherit from English.
- **Nothing under `lib/` may import `material.dart`, `cupertino.dart` or the
  package's own barrel** — `lib/material.dart` (the opt-in interop library)
  is the only exemption, and both `.github/workflows/check-imports.yaml` and
  `test/src/material_interop_test.dart` enforce it. Flutter is moving
  Material and Cupertino out of the SDK into `material_ui`/`cupertino_ui`;
  since 1.0.1 the core does not touch them at all. `FinesseApp` therefore has
  its own `ThemeMode`, `FinessePageRoute` and `Scrollbar`-based scroll
  behaviour, and `DefaultStyles` sets the root icon theme and selection
  colours that a Material `Theme` used to. Material widgets in an app need
  a `FinesseMaterial` (theme + transparent `Material` + localizations); the
  example wraps its whole app in one. This is why `Spinner` is a
  `CustomPainter` rather than a wrapped `CircularProgressIndicator`.
- **The public surface is pinned.** `test/public_api_test.dart` compares
  every name `lib/finesse.dart` exports with `test/public_api.txt`. A new
  public name, or one that goes away, means rerunning with
  `FINESSE_UPDATE_PUBLIC_API=1 flutter test test/public_api_test.dart` and
  reading the diff before committing it. A type used only in its own file
  is private; one used across `lib/` but not meant for apps is hidden in
  the barrel's `show`/`hide` clauses or marked `@internal` (`EntranceSpec`,
  `OverlayEntrance`, `SurfacePainter`, `PickerHost`, `RenderToastStack`,
  `MouseAreaSurface`). A few are hidden rather than private because tests
  reach them through `src/` imports (`SelectState`, `PanelInfo`,
  `ResizeResult`); every `*FormFieldState` is private, and a test reaches
  one as a `FinesseFormFieldState<F, T>`.
- `test/readme_snippet_test.dart` and `example/test/example_md_test.dart` hold
  verbatim copies of the README and `example/example.md` snippets and check
  they still match.
- Releases are manual: bump `pubspec.yaml` + `CHANGELOG.md` on main. The
  workflows shad used to tag a release, post it to Discord and publish to
  pub.dev (`create-release.yaml`, `publish.yaml`) were removed with the fork;
  nothing tags or publishes on its own.
- Verify with: `flutter analyze` and `flutter test` at the root, then the same
  in `example/` (`--timeout 120s`: the example suite has slow tests), then
  `find test -name '*_web_test.dart' | xargs flutter test --platform
  chrome`, `dart format --set-exit-if-changed lib test example/lib
  example/test` and `flutter pub publish --dry-run`. The example consumes
  the package through the public barrel, so it catches export breakage that
  the root analyzer does not. There is no separate `playground/` app any
  more; the example app replaced it.
- **The Flutter floor is 3.50.** Before depending on a recent widgets-layer
  API (`SemanticsRole`, `flagsCollection`, `Matrix4.translateByDouble`,
  `RawMenuAnchor`, `Expansible`) check that it exists there; the
  minimum-Flutter CI job fails otherwise.
- `example/macos/` is gitignored, so changes there (e.g. the
  `com.apple.security.network.client` entitlement that `google_fonts` needs)
  will not commit.

## Performance

What a frame costs on the web is counted by
`example/test/perf_structure_test.dart` (backdrop filters, save layers, builds
and paints per scroll frame, at rest and across a theme switch, per Strand
screen at both sizes) and timed in a browser with
`flutter build web --release -t test_driver/perf.dart` and
`await finessePerf.scroll(1200, 2)` in the console. The Browser pane must be
*showing*: a hidden pane runs animation at 1 Hz. `FrameTiming.raster` on the
web ends when commands reach the GPU, so GPU-bound work does not show in it.

- **A clip the size of a shadow is the most expensive thing here.** Skia has
  no analytic form for "everything outside this rounded box" as one path: on
  the web it rasterises a mask on the CPU and uploads it again on every frame
  the surface moves. `paintOuterShadows` (`lib/src/utils/shadow.dart`) clips
  by the bounding rectangle (`ClipOp.difference`, no mask) plus four corner
  slivers, and not at all under an opaque fill; other shapes (a tooltip with
  its arrow) keep the per-contour even-odd clip. Do not replace it with one
  `clipPath`; `shadow_test.dart` counts and measures the clips.
- **Cards do not blur.** `cardBlur` is false in every style: a card lies on
  the flat page and a backdrop filter per card is paid every frame. Cards stay
  translucent. Bars, popovers, menus, tooltips, toasts and floating `Glass`
  are the glass. Glass inside scrolling content or on a flat fill is
  `Glass(frosted: false)`; a label on a photograph is a plain scrim, not an
  isolated backdrop (that was a save layer and a filter per card). A theme
  opts in with `StyleTokens.finesse.copyWith(cardBlur: true)` or
  `CardTheme(blur: …)`; the example's Frost preset does. The navigation
  rail is the same case: it lies beside the page on a flat fill, so it is
  translucent but not frosted by default, and `NavigationRailTheme(blur:)`
  opts in.
- **A scrolling page is a layer, and so is a card.** `PageContainer` and
  `Card` each add a `RepaintBoundary`: a scroll paints nothing, and an
  animation on the page repaints the page's own few boxes. A hand-rolled
  `SingleChildScrollView` page needs the boundary itself. A real feed is a
  lazy list.
- **A theme is switched, not interpolated.** `FinesseApp` uses
  `CrossFadeTheme` (`lib/src/theme/cross_fade_theme.dart`): one build under
  the new theme, the previous frame faded out over it as a picture, timed
  from the frame after the rebuild. `AnimatedTheme` rebuilt the app on every
  frame of the lerp. Because of that, an implicit animation must not chase a
  theme change: `AnimatedColorBuilder` and `AnimatedFill` jump when the theme
  did (`ThemeChange`), and `FinesseMaterial` does not animate its text style.
  Theme equality is still load-bearing: an unequal theme per build is a full
  rebuild per build.
- **Something that never stops is painted, not built**, in a layer of its own
  (`TypingIndicator`). Nothing may be built or scheduled on a screen at rest.
- **Never `GoogleFonts.getFont(name)` or `asMap()`**: either keeps all 1,700
  families in the app (8.5 MB of JavaScript). Name the method
  (`GoogleFonts.inter`); `EditorFont.builder` is a tear-off per font.
- **An icon font with no glyph in use is bundled whole**, not shrunk to
  nothing. `PhosphorFontAnchor` (`lib/src/icons/phosphor_font_anchor.dart`),
  under every `Theme`, names one glyph of each family — each in an expression
  at the call site; a constant list and parameter defaults are both invisible
  to the tool. A seventh family needs adding there
  (`phosphor_font_anchor_test.dart` compares with the pubspec). Verified on
  the web only.
- `--wasm` was measured and not adopted: without cross-origin isolation,
  which GitHub Pages cannot provide, skwasm rasterises on the main thread and
  a frame costs the same.
- **A pinned bar is its own layer.** `SliverAppBar`'s box is a
  `RepaintBoundary`; without it a collapsed bar repainted its toolbar on
  every scroll frame (the phone Profile went from fewer than 4 paints per
  frame to 16), and `perf_structure_test.dart` holds the page to fewer
  than 4.

## Pressing: `Pressable`, buttons, gestures

- **One primitive.** Everything pressed — `Button`, `IconButton`,
  `Toggle`, `FloatingActionButton`, `Chip`, `ListTile`, `Card(onTap:)`,
  the bars' destinations — is a `Pressable`: press scale, hover from a
  `MouseRegion`, a focus ring that shows only when it should, state fills
  through `AnimatedFill`, and Enter/Space activation. A button's look is
  its variant's `ButtonTheme` with the caller's `style:` (a `ButtonTheme`,
  a `ToggleTheme` for a toggle, a `ContextMenuTheme` for a `MenuItem`)
  merged over it; there are no colour, size or decoration parameters on
  the widgets themselves. `Card`, `Dialog` and `Sheet` are styled the same
  way (`style: CardTheme(...)`, even for a card's `padding` or a dialog's
  `constraints`); what they show and how they behave stay parameters.
- **A `Button` or `IconButton` with no `onPressed`, no `onLongPress` and
  not `loading` is disabled** — dimmed by `ThemeData.disabledOpacity`, no
  Tab stop, no hover, no click cursor — as a `Toggle`, `Chip`, `ListTile`
  or FAB with no callback is. A control that must stay a Tab stop with
  nothing to do (the current page of a `Pagination`, which keeps
  `aria-current`) passes a no-op callback.
- **Rarer gestures are a `FinesseGestureDetector` around the control**
  (double tap, secondary tap, tap down, long-press phases, pan). The
  control keeps its own tap, so a second `onTap`/`onTapDown` there loses
  the arena and its `onTapDown` fires only after about 100 ms; use a
  `Listener` to hear every pointer-down. A menu row's `onTapDown` is such
  a `Listener`: the row's tap comes on pointer-up, by which time a tap
  outside has already closed the menu. `FinesseGestureDetector` also
  stands a press in for hover on a device with none (a finger that comes
  down hovers the detector until it lifts); select options, command
  items, the accordion and the sidebar rely on it. It is a fixed rule
  there — `HoverStrategies` is gone.
- **`Pressable(semanticContainer: true)`** makes the region one node:
  `Button`, `IconButton`, `Toggle` and the FAB pass it, so the text beside
  a button is not merged into its name. The default stays false, so a
  `MergeSemantics` around a tile and its control, or a `Semantics` adding
  custom actions to a row, still reaches it. A loading button is announced
  with the value "Loading" and as disabled (Flutter has no busy flag). A
  `semanticLabel` excludes the *content's* semantics only — excluding at
  the outer `Semantics` also dropped the tap and focus actions, so a
  labelled region could be read but not activated.
- **Hover comes from a `MouseRegion`**, not from
  `FocusableActionDetector`'s highlight callback, which only fires in the
  traditional highlight mode.
- **`Pressable(enabled: true)` with no callbacks** keeps the region
  focusable and hoverable and announces it as not pressable: that is how
  a loading button keeps the focus. `disabled` and `selected` reach an
  external `statesController` a frame late, after the build, because its
  listeners may be anywhere in the tree.
- **On the web, Enter and numpad Enter are `ButtonActivateIntent` and
  Space is `ActivateIntent`**; nothing under `lib/` answered the first, so
  rows did not activate on Enter in Chrome. `Pressable` answers both, and
  `lib/src/utils/activation_keys.dart` is shared by everything else that
  activates (checkbox, radio, switch, accordion trigger);
  `test/src/raw_components/keyboard_activation_test.dart` and its web twin.
- `Disabled` excludes the focus as well as pointers, and keeps both of its
  wrappers in the tree either way.
- A file importing both Material and finesse hides one `ButtonTheme`.

## Haptics

Every tick goes through `Haptics` (`lib/src/utils/haptics.dart`):
`Haptics.selection(context)` for a selection changing under the finger (a
wheel row, a slider stop, a segment, a detent) and
`Haptics.impact(context, HapticImpact.medium)` for something that
happened once (picked up, dropped, armed). Nothing else under `lib/` calls
`HapticFeedback`. It fires on Android and iOS only, `ThemeData(haptics:
false)` switches it off for a subtree, and it is silent under `flutter
test` unless `Haptics.debugEnabledInTests` is set (and put back). It does
not look at the pointer: a control also driven by a mouse or a keyboard
ticks only for a finger's changes, as the board and the wheel do.

## Screen structure

- **`Scaffold` lays its bars over the body** and gives the body a
  `MediaQuery` whose padding includes them, so a translucent bar shows the
  page beneath it and a `ListView`, `SafeArea` or `PageContainer` insets
  itself. Every slot is measured in the layout it is placed in
  (`CustomMultiChildLayout`, the insets riding to the body on
  `_BodyConstraints`), so a bar of any height is exact from the first frame;
  nothing may replace that constraints object between the delegate and the
  body. With `resizeToAvoidBottomInset` the body ends at the keyboard and
  sees no `viewInsets` of its own; footer, bottom sheet and FAB ride up.
- **`OverlayInsets`** is how floating things clear the bars: a scaffold
  reports, while it is on stage and only for the screen edges it reaches,
  how much of each edge its bars cover, counted from the screen edge (the
  reader subtracts the safe area or keyboard). The `Toaster` is itself an
  `OverlayInsetsScope`, so a toast clears the floating bottom bar; it
  follows the bottom inset only.
- **A drawer's place is linear in the route's animation value.**
  `animateWith` ends *completed* even when it heads to 0, so a closing
  drawer uses `animateBack`. The edge-drag preview is drawn in the
  navigator's overlay, not as a route: pushing a route cancels every
  pointer that is down, the dragging finger included, so the route is
  pushed once the finger lets go and starts where the preview was
  (`scaffold_drawer.dart`).
- The FAB travels when its corner moves (a footer appears, the bar goes)
  and follows rigidly when the window or the keyboard is moving it, or
  when it grows from its corner.
- **A scroll-driven bar is written at layout and read at paint**
  (`AppBarSurfaceBehavior.whenScrolled`, `SliverAppBar`): its listeners are
  render objects, never builders. A header's semantics merge into the
  bar's container unless the heading is a container itself.
- An `AppBar` with no `leading` shows the back, close or menu button that
  applies (`automaticallyImplyLeading`), and with no `actions` over a
  scaffold that has an `endDrawer` the button that opens it
  (`automaticallyImplyActions`, `impliedActions()` in `app_bar_layout.dart`).
- **A `ListView` with no padding strips the vertical `MediaQuery` padding**
  for its children, so a widget inside that needs the bars' insets reads
  them at `Scrollable.maybeOf(context, axis:)`'s context. `TextField`'s
  default `scrollPadding` does (20 plus the top and bottom padding there),
  so a focused field stops above a footer.
- **`Transform.scale` in a test:** `getMaxScaleOnAxis` reads 1; read
  `storage[0]`.

### Routes, tabs, navigation

- **`FinessePageRoute`'s back gesture drives the route's own controller.**
  The iOS swipe is a 20-point strip, the outermost widget of the page; the
  transition is drawn differently per phase (`_phase`). Android's
  predictive back does not go through `TransitionRoute.handle*BackGesture`:
  the route has its own `_pullController` and sets its first overlay entry
  non-opaque while the page below shows. A lone drag recognizer wins the
  arena at pointer-down, so its `onStart` fires on a tap. The swipe owns
  the edge whenever the route can pop; a drawer's edge drag only when it
  cannot, and `SwipeActions` leaves the first 20 points to it then.
  `backGesture: false` turns it off (on iOS in a browser it coexists with
  Safari's history swipe).
- **`FinesseScrollBehavior` stretches on Android** (see "Testing" for what
  that does to finders).
- **One tab list.** `TabBar<T>` (value-based, underline or segmented),
  `Tabs<T>` (a tab bar over content) and `SegmentedControl<T>` all build
  the internal `TabList` (`tab_list.dart`). `Tab`
  is a data class, not a widget. The list is one Tab stop — only the
  selected tab takes the focus, the others `skipTraversal` — and the arrows
  move the selection. `SemanticsRole.tabBar` throws if a direct child is
  not a tab, so a tooltip or label goes inside the tab's `MergeSemantics`.
  A `Tabs` or `TabBar` controlled by `value` selects a tab only once the
  parent's value names it, and **with a `value` and no `onChanged` (nor a
  `controller`) it is inert**: its tabs are drawn disabled.
- **`TabPages` is not a `PageView`**: one render object with the hidden
  pages off stage, the drag divisor a page plus its gutter. A page's
  builder context sits under the `TickerMode`/`Visibility` (a `Builder`),
  and `swipePosition` is nulled in `dispose` only if non-null.
  `TabsController<T>` is shared by a `TabBar` and a `TabBarView`.
- `NavigationScaffold(layout:)` places a top bar, a bottom bar or a
  `NavigationRail`; in the rail layout the rail is part of the scaffold's
  body and reads the `MediaQuery` under it. `BottomBarSurface` is the one
  surface of the bottom bar and `Toolbar`.
- `ListDetailLayout` on a phone is a nested `Navigator` under a
  `NavigatorPopHandler(enabled: detail != null)`.

## Overlays, sheets and pickers

- **One controller.** `PopoverController` drives popovers, context menus,
  tooltips and hover cards: `isOpen`, `open()`, `close()`, `toggle()`,
  `setOpen`, and `openAt(Offset)` for a global point (`position` is it,
  null at the widget's own anchor). There is no `TooltipController` or
  context-menu controller.
- **A sheet's presence is its route's animation.** `_SheetRoute` has a
  pass-through transition and the `Sheet` places itself; a dismissing drag
  drives the route's controller. That controller is created with
  `AnimationBehavior.preserve`: the default runs twenty times faster under
  reduced motion, and the durations given are already the reduced ones.
  Size between detents is a separate `SpringController`, and `_goTo` has
  to unsettle it before changing the index. A drag that starts in the
  content is handed between sheet and scroll in the scroll position
  (`_SheetScrollPosition.applyUserOffset`/`goBallistic`), the pointer kind
  taken from the drag's details. `SheetDetent.content` is measured by
  laying the child out twice. `Sheet` is const, so its constructor's
  asserts may not read `detents.length`. `showSheet`'s `builder` returns
  the `Sheet` (it may wrap it); `start`/`end` resolve against the opener's
  `Directionality`; the route's page gets loose constraints.
- **Pickers change presentation by form factor in one place**, the
  internal `PickerHost` (`picker.dart`): a popover on a desktop, a sheet on
  a phone (`PickerPresentation` overrides it). Its sheet route is captured
  inside the builder, and the builder runs again while the sheet leaves, so
  a "showing" flag guards it. A picker's sheet is a `PickerSheet`: the
  choices as its child, Cancel/Clear/Done as one row in `Sheet.actions`.
  `autofocus` inside a `Popover(requestFocus: true)` never fires (the
  scope already has focus), hence `PickerFocusOnOpen`.
- **Picker triggers are fields.** `DatePicker`, `DateRangePicker` and
  `TimePicker` look like a text field by default — its decoration, padding,
  height outside the decorator, value or placeholder text, focus ring — as
  one button semantics node that opens from the keyboard; `variant:` (or
  `DatePickerTheme`/`TimePickerTheme.buttonVariant`) makes the trigger that
  button instead, and `size` applies to the button look only. A `Select`'s
  value takes the text field's style in the foreground colour, its
  placeholder the field's placeholder style.
- **The wheel paints and does not lay out.** `RenderWheel` listens to the
  `ViewportOffset` and paints rows with a quantised alpha edge fade.
  `Scrollable` keeps the physics object it was first given, so the row
  extent goes through a holder. Anything laid out around the current value
  slides under the finger: `DateWheelPicker` anchors its rows to the date
  it started from.
- A notifier changed in `didUpdateWidget` must not have listeners in
  another route (`_Selection.replaceDuringBuild` in `select.dart`).
- `Align(widthFactor:)` without `heightFactor: 1` grows to its parent's
  height; a `FittedBox(fit: BoxFit.scaleDown)` around a fixed-width
  `SizedBox` is how the calendar's month and the wheel group shrink.
- A key handler has to be **above** the node with the focus: a
  `Focus(onKeyEvent:, canRequestFocus: false, skipTraversal: true)` around
  the `FocusableActionDetector` or field.
- A `Semantics` with increase/decrease actions needs both `value` and
  `increasedValue`/`decreasedValue`.
- **A labelled part of a composite field is one node.** `DateField` and
  `TimeField` wrap each part in `MergeSemantics`; a `Semantics(label:)`
  above a `TextField` merges into the parent instead and leaves the text
  field unnamed. `DateField` borrows `TimeFieldTheme`; its parts size to
  their placeholder letters ("MM", "TT", "JJJJ") as well as their digits,
  and the digits stay left-to-right in RTL while `leading`/`trailing` swap
  ends.
- `SemanticsRole.alert` and `status` may not be combined with
  `liveRegion: true`.

## Text input

- A list under a field keeps the focus in the field:
  `Popover(requestFocus: false)` sharing the field's `groupId`, rows under
  `ExcludeFocus`, a highlighted index driven by the arrows, the highlight
  following the pointer on `onHover`, not `onEnter` (`Autocomplete`).
- A text field's semantics node does not merge into an enclosing
  `Semantics`.
- `TextSelectionControls.getHandleSize` is told neither the handle type nor
  a context. A magnifier samples everything painted before it, so its
  shadow is a foreground `ShadowDecoration` painted after the lens. The
  selection toolbar's height is asked for outside its surface.
  `SelectedContent` is not exported by `widgets.dart`; `selection_area.dart`
  re-exports it.
- `Autocomplete.debounce` applies only to a builder that returns a future.
  `SearchField` clears on Escape and never unfocuses; pass
  `clearOnEscape: false` where Escape belongs to a panel.
- `TagField`'s `Wrap` sits in `Align(heightFactor: 1)` so it fills a
  bounded width: a form field's column hands down loose constraints.

## Lists and rows

- **A section's hairline is painted by the row**, from layout offsets
  (`ListDividerAnchor`, parent-data offsets, not `getTransformTo`).
- A `ListTile` inside a `ListSectionScope` is different: section padding
  and minimum height, a square highlight, a press that darkens, an inset
  focus ring; disabled dims its colours, never an `Opacity`.
  `ExpansionTile` re-scopes its heading and rows so the press fills meet
  the card's corners. `SliverListSection` is the lazy one (`LicensePage`).
- **The control tiles draw the real control** under `ExcludeSemantics`,
  `ExcludeFocus` and `IgnorePointer`; the tile is the one control. Tests
  tap the title. A `RadioListTile` takes only its `value`: like a `Radio`
  it is a choice of the `FinesseRadioGroup` around it (and asserts there
  is one). The group takes a `child` (a `ListSection` of `RadioListTile`s)
  as well as `items`, since its vertical `Wrap` hands its items an
  unbounded width.
- A swipe recognizer must refuse the directions it has no use for
  (`SwipeActions` overrides `hasSufficientGlobalDistanceToAccept` with the
  signed distance), or it takes every vertical scroll. A trackpad pan is
  not a pointer-down (`onPointerPanZoomStart`, `RefreshIndicator`).
- `PageView.onPageChanged` fires for every page passed. An internal key
  is a private enum value, never a plain `ValueKey('row')`, which an app's
  own key can equal.
- **`ReorderableListView` is a `Board` over one bare column**, a `part` of
  the board library (`board.dart` → `reorderable_list_view.dart`), so it
  lifts, tilts, makes way and lands on the board's springs and theme. Fix
  shared behaviour in `board_state.dart`; the list overrides it through
  hooks (`_ringsFocus`, `_moreItemActions`, its announcements).
  `.builder` needs `itemId`. Its `onReorder(from, to)` counts `to` after
  removal, like `BoardMove.toIndex`.

## Toasts, button groups, the stepper

- **One `Toaster` around the navigator** (`FinesseApp` puts it inside its
  `builder`, so what the builder inherits the toasts inherit).
  `Toaster.of(context).show(Toast(...))` returns an id for `update`,
  `dismiss`, `dismissAll`. The stack is laid out once and every movement —
  stacking, expanding, entrance, exit, swipe — is a paint-time transform
  from springs (`RenderToastStack`). A toast past `maxVisible` is not
  painted, hit-tested or in the semantics tree. Removal happens from the
  fade controller's status listener, and an exit uses `animateBack`.
  Each toast's box is 8 larger for the corner close button.
- Toasts are outside every route's focus scope: F6 (`Toaster.shortcut`)
  moves the focus to them, and leaving gives it back with
  `unfocus(disposition: UnfocusDisposition.previouslyFocusedChild)`. The
  pan recognizer eats its slop (36 on touch), so the 48-point swipe
  threshold is measured after it. A status icon is moved towards the ink
  until it reaches 3:1 (`_toastIconColor`). `ToasterTheme.width` must stay
  finite (a `lerpDouble` of infinities is NaN). Never `await
  toaster.dismiss()` in a widget test.
- **Button groups.** `ButtonGroupScope.join` squares the inner corners of
  all six borders, and a non-first child's leading side is width 0 with
  that width added to the border's padding: neighbours must not overlap,
  or a translucent hairline doubles. The first control built under a
  child claims its place, and the focused child is painted last. A
  control replaced by one of another type is still mounted (deactivated)
  while its successor builds, so `Element.mounted` cannot tell a stale
  claim from a live one: `ButtonGroupScope` frees a claim in its
  element's `removeDependent`, which `Element.deactivate` calls.
- `Button(loading:)` wraps the label only once it has been loading
  (`_hasLoaded`), so the label is not re-parented each time loading ends.
- `Stepper` draws two half-lines per connector on one spring, and builds
  only the current step's content, plus the closing one as an inert
  picture.

## The data table

`FinesseTable` is the grid; `DataTable` adds sorting, filtering, paging and
selection over a `DataTableController<T>`. `DataTableController.remote(
pageSize:, onPageRequested:, ...)` serves rows it does not hold: the
callback gets a `DataTablePageRequest` (page, size, sort, query, offset) and
returns a `DataTablePage` (`rows`, optional `rowCount`). The count arrives
with the page, never through a setter, so an answer overtaken by a newer
request is dropped together with its count. The first page is asked for
when the first listener attaches, not at construction, and a source that
answers synchronously during a build is applied after the frame. While a
page loads, skeleton rows stand in with one "Loading rows" announcement;
a failure shows a message and "Try again" (`errorBuilder`). `rows=` and
`filter=` assert on a remote controller (`data_table_remote_test.dart`).

## The board

`Board` (`lib/src/components/board*.dart`) is controlled: it reports a
`BoardMove` and flies the card to wherever the next build puts it, so a
parent that refuses, sorts or applies late is still animated correctly.
`BoardMove.toIndex` is counted after removal (apply is remove-then-insert).

- One `Ticker` in `_BoardState` drives everything — neighbour shifts, lifted
  copies, auto-scroll, the slot fading in — and stops when all of it is at
  rest, also mid-drag. Springs are stepped with the closed-form oscillator,
  so a critically damped one never overshoots however long the frame.
- Neighbours make way by a paint-only translation in `_RenderBoardSlot`;
  nothing is laid out while a slot opens. The drop index compares the card's
  centre with the middle of the span each neighbour covers above and below
  the slot, so it depends on the pointer alone and never flickers.
- A list change is animated by FLIP resolved **in paint**: `didUpdateWidget`
  records where each mounted item is drawn and marks it for repaint, and the
  slot's `paint` works out the offset that keeps it there. A post-frame
  callback would be one frame late (a jump); paint may not call
  `markNeedsPaint`, so it writes the field directly.
- After a drop that moved something, the shift targets are **not** reset
  until the frame after `onMove`; resetting them first sends every neighbour
  the wrong way for one frame. For the same reason a flying card does not
  land in the tick before the parent has rebuilt (`holdFrames`).
- Recognizers are owned by the board, not the item, so a drag survives its
  item scrolling out of a lazy list; the dragged or focused slot is also
  kept alive. A kept-alive sliver child has a **zero** paint transform and
  its `SliverMultiBoxAdaptorParentData` sits a few wrappers above the slot,
  so `_box` walks up to find `keptAlive` — reading its position otherwise
  yields NaN and a semantics assertion.
- `MultiDragGestureRecognizer` accepts on pointer-down when nothing else is
  in the arena; `_SlopPointerState` keeps the starter and waits for the slop
  anyway, or a click lifts the card. The mouse slop equals the pan slop on
  purpose: the board's listener is deepest, so at the same distance it beats
  a `SelectionArea` around it (the docs pages).
- **Lifted copies are overlay children of the board**, built by one
  `OverlayPortal` (`_ProxyLayer`), not overlay entries. They are painted
  right above the board's own route — under a dialog or a page opened over
  it, where an entry in the root overlay stayed frozen on top — and inherit
  what the board inherits. The layer excludes focus, selection and
  semantics: a copy is a picture. The portal may not be shown, hidden or
  rebuilt while the tree is building or being laid out, so `_syncPortal`
  defers to post-frame, and a card the parent moved to another column by
  itself is still hidden at once (`_pendingFlights`) and takes off after
  the frame.
- **Nothing is set in motion off stage.** `_onStage` is `TickerMode` enabled
  *and* `Visibility.of` (a hidden `IndexedStack` child keeps its tickers).
  Going off stage, and the app going to the background, calls `_settle()`:
  the held item is put back, flights end, shifts are zeroed and the drag's
  end is reported. A copy left in the air would hang over whatever is shown
  instead and finish its flight long after the drop.
- **Slot and item are separate widgets.** `_BoardSlot` is the list's child
  (keep-alive, shift, FLIP); `_BoardItem` is built inside it under a
  board-owned `GlobalKey` per id (`_itemKey(id)`), so an item that changes
  column is re-parented with its state and its keyboard focus. There is no
  refocusing step, and none should come back.
- `_RenderProxy` is a repaint boundary whose layer *is* the transform: a
  new position updates that layer and paints nothing again. Do not wrap the
  copy in anything that changes with its state, or it repaints every frame
  of a drag.
- A slot created wanting to be kept alive can only tell the list after the
  frame; until then `_wishPending` keeps `updateKeepAlive()` from
  withdrawing the wish, which `AutomaticKeepAlive` asserts on.
- An item whose copy is in the air is not a Tab stop. A traversal key in an
  item that a lazy list keeps alive off screen first scrolls it into view
  (`_showItem`): a kept-alive child has no position, and the focus
  traversal's own scroll-to-reveal throws.
- `canMove`, `canAccept` and `limit` are the app's code and a pointer
  reports many times a frame: they are asked when the target changes, after
  a rebuild and once more at the drop, not on every event. A drop the rules
  no longer allow is not reported.
- A `Card` inside a board is themed through a `Theme` override cached per
  `ThemeData` in an `Expando` (`ThemeData.copyWith` re-runs the factory).
- The landing pop is one spring given a push found by bisection so the scale
  reaches `landScale` and comes back once (`_Spring.kickThrough`); a bouncy
  spring alone moves a 3% lift by a fraction of a pixel.
- It needs bounded width and height (it throws a `FlutterError` that says
  so); `shrinkWrap: true` makes columns as tall as their items and
  auto-scrolls the enclosing vertical scrollable instead.
- Tests: find a column with
  `'${w.runtimeType}'.startsWith('_BoardColumnView')`; never
  `await controller.showColumn()` in a widget test (it completes only as
  frames are pumped); layout tests need a real font, as elsewhere.
  `board_regression_test.dart` holds what review found (state that must
  survive a change around it, moves that must be refused, copies that must
  not outlive their moment) and
  `board_fuzz_test.dart` runs seeded random sessions (drags, keys, lists
  changed underneath, the board hidden, covered and backgrounded) that fail
  on any exception, on a copy left over at rest and on a board that never
  rests — keep every seed that finds something.

## The chat list and streaming text

`ChatList<T>` (`lib/src/components/chat_list.dart`) is controlled: the
parent owns `messages`, oldest first, and `idOf` gives each a stable
identity. `StreamingText` (`streaming_text.dart`) reveals text that is still
arriving. `SpringSize` (`lib/src/utils/spring_size.dart`) is the
spring-driven `AnimatedSize` both lean on; `ChatBubble` follows its content
through one (`animateSize`, `ChatBubbleTheme.sizeSpring`).

- The list is a **reversed `CustomScrollView` over one custom sliver**:
  offset zero is the newest message, so at the end new and growing content
  pushes the rest up without any scrolling.
- **A message arrives and leaves as an animated extent.**
  `_ChatListTransition` opens its height (`Align(heightFactor:)` on a
  `SpringController`) while it fades and grows from the corner its tail is
  in, so the messages above glide instead of jumping; a removed message
  stays built, with `ChatListItem.isLeaving`, until its height is gone. The
  wrappers are the same moving or at rest, so a message keeps its state.
- `_RenderChatSliverList` subclasses `RenderSliverList` for three things a
  plain one cannot do. **Hold still:** once the reader has scrolled back it
  remembers the topmost child in view and, when a layout moves that child,
  answers with a `scrollOffsetCorrection` in the same layout — scroll
  anchoring, with no frame that shows the jump. **Pin the end:** a lazy
  list only guesses the height of what it has not built, and on finding
  the guess wrong it moves the scroll offset rather than what is on
  screen; at offset zero that is backwards, so the correction is not
  passed on and the list is laid out again until it starts at its start.
  **`ChatListAlignment.top`:** a reversed list that does not fill its
  viewport sits at the bottom, so the sliver claims the rest and paints
  its children that much higher.
- The jump-to-latest button listens to `ScrollMetricsNotification`:
  content that grows under a viewport nobody is scrolling changes the
  metrics without a scroll notification.
- `SpringSize` never animates the first layout, a change of the
  *constraints* (a window resize is followed rigidly) or a change within
  `rigidDistance` on an axis. The last is how text that widens a few pixels
  a frame is kept from being smoothed twice while a new line still takes
  the spring.
- `StreamingText` **lays out all the text that has arrived, sizes itself to
  the revealed part and paints through clips.** A line already showing is
  never broken differently by what is revealed after it, and a frame of the
  reveal costs no text layout. The reveal counts grapheme clusters. The
  engine refuses a string with half a surrogate pair, and a chunk boundary
  can leave one: a trailing high surrogate is held back and any other
  orphan replaced (`_wellFormed`). Complete and fully revealed, it becomes a
  plain `Text` in the same style, selectable and free. It has no `maxLines`
  or `softWrap`.
- Tests: an entering message has no height in its first frames, so finders
  need `skipOffstage: false`; the extent of a lazy list is a guess until
  its far end is built, so reaching the start takes
  `jumpTo(maxScrollExtent)` more than once; see "Testing" for streams under
  the fake clock.
- Known limits: an entering message fades through an `Opacity` layer, which
  glass inside it does not survive on every renderer (see "Floating
  surfaces are glass too"); a word being revealed at the end of a line can
  hop to the next when more text arrives; a message inserted above a typing
  bubble shows a flat bottom edge for a frame or two; a scroll offset far
  back in a lazy list is an estimate.

## The sidebar component

- `SidebarScaffold` owns the responsive behaviour; `Sidebar` carries
  the configuration (`side`/`variant`/`collapsible`) and renders the panel.
  Descendants read `SidebarScope.of(context)` for the collapsed state —
  that is how menu buttons shrink to squares and sub-menus vanish in the
  icon rail.
- **Both collapse modes keep content laid out at the expanded width** inside
  an `OverflowBox` and let the animated container clip it — that is what CSS
  `overflow-hidden` does, and it is why a header that is a plain `Row` (logo +
  gap + label) truncates instead of throwing a RenderFlex overflow. Offcanvas
  anchors the box to the inner edge so the panel slides off; the icon rail
  anchors it to the start.
- Because the parent no longer narrows, the icon rail's square is the menu
  button's own doing: it animates an explicit width to `collapsedWidth −
  group padding` (48−16 = 32 = `px(8)+icon(16)+px(8)`) inside an
  `Align(start, heightFactor: 1)`. Every fixed-width part of its row — the
  icon-label gap, the trailing badge — animates to zero on the *same*
  timeline, because anything that disappears instantly (or stays fixed) makes
  the row's minimum width overflow mid-animation in one direction or the
  other.
- The mobile sheet is imperative: the scaffold listens to the controller and
  pushes/pops a `Sheet` with `scrollable: false` — the sheet's own scroll
  view hands the sidebar's `Expanded` column unbounded height, and the crash
  surfaces as a misleading `mouse_tracker` assertion. `isMobileOpen`
  (`openMobile()`/`closeMobile()`) and `isOpen` (`open()`/`close()`) are
  independent, as in the reference. Growing past the breakpoint pops the
  sheet (post-frame, from `didChangeDependencies`), matching the reference
  unmounting its mobile branch.
- A `Sidebar` with no `SidebarScaffold` above it hosts its own
  `SidebarScope`, so it can be a `Scaffold.drawer`.
- **The drawer route outlives the scaffold's State**, and its builder re-runs
  on every MediaQuery change — so `_showMobileSheet` captures everything the
  builder needs (controller, sidebar, collapsed width) instead of reading
  `this.widget`/`this.context`, which are gone after unmount. The route
  itself is captured via `ModalRoute.of` in the builder: closing goes through
  it (`pop` when current, `removeRoute` when covered — never a blind
  `Navigator.pop`), and `dispose` removes an orphaned drawer post-frame.
- `SidebarScaffold.borderRadius` clips the whole scaffold; it exists for
  embedding in rounded containers (the docs demos), where the sidebar's
  square surface would otherwise cover the host's corners.
- Sidebar metrics vary per style through `sidebarItemHeight`/`Sm`/`Lg` and
  `sidebarItemPaddingX`/`sidebarSubItemPaddingX` tokens; radius reuses
  `itemRadius`, the group label reuses the `overline` role, button text the
  `body` role. The floating/inset surface radius is the popover radius capped
  at the 2xl step (`_sidebarSurfaceRadius`), which matches all styles within
  2px without a dedicated token.

## The example app

`example/` is three things under one `AppShell` (`common/app_shell.dart`):
**Strand**, a social-network demo that replicates the reference designs and
is what the app opens on; the **component library** (docs browser); and the
**theme editor**, a panel docked beside whichever of the two is showing.
App-wide state — section, theme mode, text direction, the editor's
configuration and whether its panel is open — is solidart signals behind
disco providers in `common/app_state.dart`, provided above `FinesseApp`.

### Strand (`example/lib/strand/`)

- `strand_shell.dart` is a `NavigationScaffold` over a `DestinationStack`;
  on a desktop narrower than 1024 (`StrandShell.topBarFrom`) the
  destinations leave the top bar for a `NavigationRail`, and choosing the
  destination already showing scrolls it to the top. Pushed pages use the
  app bar's implied `BackButton`. `navigation.dart` has
  `StrandDestination`, `context.goTo(...)` and
  `context.pushFullScreen(builder)`. `data.dart` and `assets.dart` hold the
  people, companies and image paths shared by the screens (images are in
  `example/assets/strand/`, taken from the design files).
- One screen per destination: `screens/<x>_screen.dart`, its pieces in
  `widgets/<x>_*.dart`, its content in `data/<x>_data.dart`, its tests in
  `example/test/strand_<x>_screen_test.dart`. Home, Jobs, Messages and
  Profile come from the designs. Network, Notifications, Search and Settings
  were never drawn; they are built from the designed screens' pieces and
  rules (`widgets/strand_pieces.dart` has the shared page header, section
  heading, pill button, mark and date tile). Settings and Search are pushed
  routes. Jobs has a second view, "My applications", a `Board`
  (`widgets/jobs_board*.dart`, `jobsViewProvider`,
  `context.openApplications()`), and Easy Apply is a three-step `Stepper`
  in a dialog. Messages is a `ListDetailLayout`; a thread is a `ChatList`;
  the conversation pinned first, "Strand Assistant", streams its replies
  into a `StreamingText`, and the send button is a stop button while one
  arrives. The screens use the package's own widgets for what the designs
  imply (`RefreshIndicator`, `SwipeActions` with the same actions in a
  context menu for a mouse, `Carousel`, `HoverCard`, `showActionSheet`,
  `SegmentedControl`, `TagField`, picker sheets and wheels on a phone,
  `ListSection` rows, `Button(loading:)`, toast variants).
- **State more than one place shows is in the `StrandSession`**
  (`session.dart`, `context.strand`, provided beside
  `strandDestinationProvider`): `notifications`, `messages`, `network`,
  `search` (recent searches), `settings`, and `jobs` with `applications` —
  the Jobs screen's two sides, its summary tiles and the "Saved items" sheet
  count the same saved jobs. A screen's own state stays in the screen
  (`HomeFeedModel`).
  - `session.messages` is the one `MessagesController`: a reply goes on
    arriving after the user has left the Messages screen. The shell's badge
    is its `unreadCount` (a `ValueListenable`; requests are not counted),
    a reply landing in a thread nobody is looking at (`threadVisible`) is
    unread, and `session.badges` announces a change in either badge number
    and nothing else. How the other side answers is injected
    (`MessagesReplies`, `widgets/messages_assistant.dart`).
  - The session reports every listing to `ApplicationsController.track`
    whenever anything about the Jobs screen changes, so `track` acts only
    on a listing whose saved or applied state *changed*. Re-syncing from
    the full state undid whatever the user had done on the board since.
  - A test that pumps a screen alone adds `strandSessionProvider` to its
    providers, or wraps it in `StrandSessionHost`
    (`test/strand_support.dart`) to decide who answers a message and when;
    disco disposes an overridden value with the provider's own `dispose`,
    so the session's timers die with the test's tree.
- **What the user typed must not live in a `State` that a layout change
  rebuilds.** The desktop and phone feeds are different widgets, and a
  resize or the docked editor swaps one for the other: a half-written
  comment is in `HomeFeedModel.draftFor(post)`; the selected settings page
  is held by a `GlobalKey` and moves between the two arrangements with its
  state; and its field grid is one `Wrap` either way (`_FieldGrid`), so the
  field being typed in keeps its focus when the column count changes.
- **A control named by a visible label is one semantic node**
  (`MergeSemantics`, or `ExcludeSemantics` on the label the control
  repeats). `announced(tester, text)` in `test/strand_support.dart` returns
  what a screen reader stops on; a labelled control must come out of it
  once.
- **Nothing in Strand is a dead end.** A control with no designed
  destination gets the lightest real response from
  `widgets/strand_actions.dart` / `strand_previews.dart`: a preview dialog,
  a toast with Undo, or a trip to the screen that owns the subject.
  `grep "onPressed: () {}"` under `lib/strand` should stay empty.
- **From a pushed page, navigate with `context.leaveTo(destination)`**,
  which pops the page first; `goTo` would switch the shell underneath it.
  Call it with the page's context, not a dialog's.
- **A panel with no barrier lives and dies with the focus.** The desktop
  search panel (`widgets/search_bar.dart`) is a `Popover(requestFocus:
  false)`, not a route, so nothing but the focus says whether it is in use.
  Field and panel sit under a `Focus` that cannot take the focus itself and
  whose `onFocusChange(false)` closes the panel — Tab away, a click
  elsewhere, a result opening a dialog. The popover makes them one
  traversal group, and the field takes the popover's `groupId`, so a click
  on the panel neither closes it nor takes the caret. It opens from `onTap`
  as well as on a focus gain: after a tap outside on a touch screen the
  field still has the focus.
- **A global shortcut asks the package's `isInTopRoute(context)`, not
  `ModalRoute.isCurrent`** (the search bar). Strand's pages are in the
  navigator `AppShell` hosts, and a dialog is pushed on the *root* one, so
  a page's own route stays current under every dialog; a
  `HardwareKeyboard` handler hears keys wherever the focus is and would
  reach through the barrier. The search shortcut is one modifier per
  platform and no other with it (`SearchField.isSearchShortcut`): ⌘K on
  Apple platforms, Ctrl+K elsewhere — Ctrl+K deletes to the end of the line
  in every macOS text field, and AltGr reports itself as Ctrl+Alt on
  Windows.
- Search wants every word of the query; a canned query (a trending topic)
  is mapped to words the data contains, and
  `strand_search_screen_test.dart` checks every suggested search finds
  something.
- A test finder for a tappable row's inner `Semantics` label finds nothing:
  `Pressable` merges it into the row's node. Find the widget instead. To
  focus a chip of a `ChipGroup`, go through `Chip.focusNode`: `Focus.of`
  finds the group's non-focusable wrapper. `completeEasyApply` in
  `test/strand_support.dart` walks the application stepper.
- **A screen is built inside the shell's `Scaffold`**, so its `MediaQuery`
  padding already includes the bars; a `PageContainer(scrollable: true)`
  clears them and lets content scroll underneath. A view that needs the
  whole phone screen (a conversation, a job's detail) is a *pushed route*
  with its own `Scaffold` + `AppBar`; `AppShell` hosts a nested `Navigator`
  so such a route covers Strand's bars but not the docked editor.
- **The form factor follows the page's width, not the window's**
  (`AppShell.formFactorFor`), so docking the editor beside a narrow window
  gives Strand the phone layout. The editor can also pin it; pinned Mobile
  on a wide page is shown in a centred 390×844 frame.
- **Layout rules the screens follow** (keep to them when adding one): sizes
  come from the theme, never from `if (mobile)`; branch on the form factor
  only where the design *rearranges*; decide how many columns fit from a
  `LayoutBuilder`'s width so 800–1200px windows degrade gracefully.
- **Strand takes every size from the theme, and a test holds it to that.**
  Text is a `Theme.of(context).textTheme` style (`h1`, `h3`, `h4`, `large`,
  `p`, `small`, `muted`, `caption`), copied for a weight or colour, never
  given a `fontSize`; gaps are `Gap.md()` / `GapSize` / `theme.gap(...)`;
  radii are `theme.radii`; and the sizes the package has no token for come
  from `widgets/strand_metrics.dart`, an extension on `ThemeData` that
  derives them from one — avatar steps `avatarXs`…`avatarXl` from the
  theme's avatar, `iconBeside(style)` for a glyph set in a line of text,
  `cardInsets` for a surface laid out like a card. A design value between
  two steps was snapped to the nearer one on purpose (gaps of 6, 10, 14 and
  18 became 4, 8, 12 and 16); do not reintroduce named off-scale constants
  (the old `*_metrics.dart` files are gone).
  `example/test/strand_theme_coverage_test.dart` builds every screen but
  Messages under the default theme and under one whose type, gap, radius,
  avatar and glyph sizes all differ, and fails — with file and line — on
  any size a Strand source file hands to a widget that is the same in
  both. A size that is meant to be a literal (a photograph's height, the
  logo, the story rail) goes in its `_exempt` map with the reason. A
  `Divider` between sections of a card passes `margin: EdgeInsets.zero`:
  the shadcn styles give dividers a 16-point margin of their own. A tab
  strip that fills a phone's width uses `StrandTabLabel`, which shrinks the
  label to fit where a `Tab`'s own text would end in an ellipsis.
- **Text and icons drawn straight on a surface use `scheme.tint`**, never
  `accentForeground`. The two are the same teal in the default scheme, but
  `accentForeground` is the ink *on an accent fill* (a selected chip, a
  highlighted menu row) and need not read on a card.
- **Reading the designs.** In the design HTML, `<span>`/`<div>` are
  content-box and `<button>` is border-box: a `h:30` span with a 1px border
  renders 32 tall, which is why skill chips are 32. A header of `h:64` with
  a bottom border is 65 — `AppBar` and `TabBar` add their hairline to their
  height for the same reason.
- **A label on a photograph is a plain scrim, not glass.** A backdrop
  filter samples everything behind it within the blur radius, so a frosted
  label on a dark photo picks up the pale page around the card and turns
  grey (CSS samples only under the element), and isolating each card with
  `Clip.antiAliasWithSaveLayer` cost a save layer and a filter per card.
  A story's name sits on a scrim with no filter (`home_stories.dart`).
- **A row of chips choosing one of several** is a
  `ChipGroup(value:, allowDeselection: false, wrap: false)`, which
  fades at the edge it scrolls beyond; an action held at the start or end
  of the row ("All filters", "Filters") is `ChipGroup.leading`/`trailing`,
  outside the choices and the scroll view, with Tab stops of its own (it
  needs a bounded width). A bar that scrolls out to the screen edge (Jobs
  and Home on the phone) needs the page to keep only its vertical margins,
  every other child taking the side margins itself.
- **A toast's action that navigates captures a `NavigatorState` and the
  signals at show time** (`applicationsOpener`), never a `BuildContext`:
  the page that showed it may be gone by the time it is tapped.
- **Verifying a screen without running the app:** render it to PNG from a
  test (`RepaintBoundary.toImage` inside `tester.runAsync`, Phosphor fonts
  loaded from `fonts/phosphor/` as `packages/finesse/PhosphorRegular` etc.,
  a system TTF as the body font, `debugDisableShadows = false`, every
  `AssetImage` precached) and compare with the design. flutter_test's own
  font is an em-wide box per glyph and overflows labels that fit any real
  font, so screen and docs tests load the example's bundled JetBrains Mono.

### The component library

`screens/components_screen.dart` (a `SidebarScaffold` listing
`docs/registry.dart`) → `docs/docs.dart` (the reusable page widgets).

- **The code shown is the code that runs.** Each example is one standalone
  widget file under `lib/docs/examples/<slug>/<id>.dart`, bundled as an
  *asset* (one pubspec entry per directory — asset dirs are non-recursive)
  and loaded with `rootBundle` by `CodeBlock.asset`. Adding an example means:
  widget file + `ComponentExample` in `docs/pages/<slug>.dart` + the pubspec
  entry if the directory is new. Guide pages embed examples in their prose
  with `DocExample` instead. `example/test/docs_new_pages_test.dart` builds
  every page at desktop and phone width and checks every example file is
  registered, bundled and on disk.
- Slugs, example ids and directory names use the widget's current name
  (`text_field`, not `input`); a half-renamed page shows "Missing source
  asset" in its Code tab.
- Code blocks are always dark, in JetBrains Mono (vendored in
  `example/fonts/` and named in one place, `CodeStyle` in
  `common/code_style.dart`, which the docs and the editor's exported
  snippet share), highlighted by `syntax_highlight`, whose grammar loads
  in `main()` via `CodeHighlighter.ensureInitialized()` **before** `runApp`.
- `skills/finesse-overview/components/*.md` are generated from the docs
  pages by `dart run scripts/generate_skills.dart`. It takes the component
  pages from `componentDocs` in `docs/registry.dart` (each found by its
  `final xDoc = ComponentDoc(` declaration), deletes pages that left the
  registry, and requires every guide page in the registry to have an
  entry in its `guidePages` map naming the hand-written guide that covers
  it. It also fails on a `.md` link that goes nowhere and on a component
  page `SKILL.md` does not link. `--check` changes nothing and exits 1
  when a page is stale, and `test/scripts/generate_skills_test.dart` runs
  it, so **changing a docs page's text without regenerating fails the
  root suite**, as does adding a guide page without a `guidePages` entry.
- `example/test_driver/app.dart` wraps `main()` in
  `enableFlutterDriverExtension()`; run with
  `flutter run -t test_driver/app.dart` to drive the app from tooling
  (screenshots, taps). Driver commands hang until
  `set_frame_sync: false` because doc previews contain forever-animating
  spinners.

### The theme editor (`example/lib/common/theme_editor/`)

- **The editor themes the whole app, not a preview pane.** The configuration
  lives in `themeConfigProvider` and `FinesseApp`'s `theme`, `darkTheme`,
  form factor and text scale are all built from it.
- **Presets** (`presets.dart`): Strand is `const ThemeEditorConfig()` and
  must build to exactly the package default `ThemeData` with Geist — a test
  holds that. Choosing a preset loads its fonts first; any later change to
  the look shows "Custom". Form factor and text scale are *preview* settings
  and survive a preset change.
- Style overrides (glass, layout, bottom bar) are applied as
  `baseStyle.copyWith(...)`. `StyleTokens.copyWith` carries an override to
  the phone metrics only where they equalled the desktop ones; page margin
  and card padding differ per form factor, so the editor scales each
  separately and passes `mobile:` explicitly. Derived styles are cached per
  configuration: building the same configuration twice must give `==`
  themes, or every rebuild of the shell is a theme change (see "Theme
  equality is load-bearing").
- Choices of two or three are `ThemeSegments` (a `SegmentedControl` row);
  the panel's sliders are the package `Slider` with a value bubble while
  dragging, so `picker.dart` imports no Material.
- `customizer_panel.dart` is the panel; `app_shell.dart` docks it beside the
  page (`ThemeCustomizerPanel.width`) and lets it cover the viewport below
  700px, where a docked panel leaves nothing usable.
- The page is **always** the first child of the shell's `Stack` and `Row`,
  and the panel is added after it. Building the page conditionally instead
  reshaped the element above `ComponentsScreen` and threw its `State` away,
  so opening the editor bounced you back to the first component — which
  reads as "the editor does nothing to this page".
- The customizer panel is **fixed dark chrome** (pinned to `StyleTokens.nova`)
  at an unscaled text size, not part of the theme being edited — a panel
  that follows the configuration becomes unreadable while editing a light,
  menu-inverted or 1.6×-scaled theme.
- Anything the app adds on top of the generated theme has to be passed
  *into* `ThemeEditorConfig.build()` — `customTextStyles` is how `main.dart`
  keeps its `myCustomStyle` example alive, since the editor owns the whole
  `TextTheme`.
- The shell reads its signals in the `SignalBuilder` body, **not** inside the
  `LayoutBuilder` below it: that callback runs during layout, outside the
  scope solidart tracks, so a read in there never subscribes and the panel
  never opens.
- Menu colours are derived from the **menu's own opaque surface**, never from
  the page's `--accent`, which vanishes on an inverted or translucent menu.
- Fonts all come from `google_fonts` at runtime. `EditorFont.load()` fetches
  the weights the text roles use; `main()` awaits the default font before
  `runApp`, and a font is applied only after it has loaded, so text reflows
  once, not twice. Picker rows resolve their preview font in their own
  `build`, so a font is fetched when its row scrolls into view, not when the
  panel opens. Each `EditorFont` names its `GoogleFonts` method as a
  tear-off (`builder`), and text themes and previews are cached per family
  (closure identity is part of theme equality). In `testWidgets` a font
  load only ends at its timeout, so font and preset tests pump past it.
- `google_fonts` is an example-only dependency. The package itself has no
  font dependency.
