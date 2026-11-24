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
  `SelectOption`. Components with no Flutter counterpart keep shadcn's name
  (`Select`, `Sheet`, `Sonner`, `Popover`, `Textarea`).
- **No deprecation shims.** The fork is pre-1.0; a rename is a changelog
  entry under "Breaking changes", not a `@Deprecated` typedef.
- **The default look** is `StyleTokens.finesse` on `TealColorScheme`, measured
  from the Strand designs (four screens, desktop and mobile, light and dark)
  that `example/lib/strand/` replicates. `nova`, `maia` and `lyra` are the
  shadcn styles that remain; `neutral`, `zinc` and `stone` the base palettes.
  `reference/ui/` (below) is still the source of truth for those three.
- **Icons are Phosphor**, vendored into this package (see "Fonts" below) and
  exported from the barrel: `PhosphorIconsRegular`, `PhosphorIconsFill`,
  `PhosphorIconsBold`, `Light`, `Thin` and `Duotone`.

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
dimension only when the design is deliberately off-scale.

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
`Backdrop`.

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
  `p`, `list` and `large`. Reading the raw input here once made a style change
  resize components but leave every font size alone.
- `ThemeData` records the caller's raw factory arguments (`_inputs`,
  `@ignore`d by the generator) and its hand-written `copyWith` re-runs the
  factory from them, so `copyWith(radius:/colorScheme:/style:/...)` re-derives
  every component theme. The generated mixin's `copyWith` is shadowed; its
  generated `merge` and `lerp` still go through the factory. **Adding a
  factory parameter means adding it to `_ThemeInputs` and `copyWith`
  too** — `test/src/theme/theme_data_copy_with_test.dart` catches the common
  ones.
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
  `foreground/10` row highlights) and `menuAccent` (bold = the scheme's
  accent pair is rewritten with its primary pair *before* derivation). The
  example editor passes these through; it no longer derives menu colours
  itself.

### Theme equality is load-bearing

The generator compares `List` fields by identity. Every theme class with a
list field overrides `==`/`hashCode` to compare them by value and defer to the
generated `==` for the rest (see the comment in any of them, e.g.
`PopoverTheme`). A new list field needs adding to that override.
`flutter_animate` `Effect`s have no `==`, so effects lists only compare equal
when they are const.


`AnimatedTheme` is an `ImplicitlyAnimatedWidget`: if `ThemeData !=` the
previous one, it starts a 200 ms lerp across ~54 component themes on every
rebuild. Anything that breaks value equality — a method tear-off in `==`, a
non-const `Widget` in a theme field, a `List` compared by identity — silently
costs a full re-animation per frame. `test/src/theme/theme_data_equality_test.dart`
locks the chain; add to it rather than trusting a local check.

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
  boxes there. That is expected.
- To update: see `fonts/phosphor/README.md`.

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
  (icons, shortcuts) following the foreground.
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
- **`Scaffold` measures its bars** after layout and insets its body by the
  result; the first frame uses `AppBar.heightOf` /
  `BottomNavigationBar.heightOf`, exact for those two widgets. `AppBar` and
  `TabBar` add their hairline to their height (a 64-point bar is 65 tall),
  as CSS does with a content-box header.
- **`Pressable` takes hover from a `MouseRegion`**, not from
  `FocusableActionDetector`'s highlight callback, which only fires in the
  traditional highlight mode. A `semanticLabel` excludes the *content's*
  semantics only — excluding at the outer `Semantics` also dropped the tap
  and focus actions, so a labelled region could be read but not activated.

- **CSS heights are border-box; `Container` adds its decoration's border as
  padding around the child** (`DecoratedBox` does not — the menubar strip
  relied on one and came out 2px short). A height constraint applied *inside*
  a `Decorator` comes out `2 × border` too tall — that made outline
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
  (`localToGlobal` from the arrow) looks simpler and is wrong: the entrance
  `ScaleEffect` wraps the arrow, so the measurement moves while the tooltip
  animates in.
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
- `Button` centres its label (`TextAlign.center` in its DefaultTextStyle).
  Anything button-based that should read as a row — menu items — must merge
  `TextAlign.start` back in below the button.
- `FinesseBorder.merge` takes the other's `radius` **and** `offset`
  unconditionally. An override that sets only the radius silently drops the
  offset — which collapses a focus ring onto the element's own border.
- `OutwardBorderPainter` inflates the rect by `offset` and strokes *inside*
  it, so `offset == width` puts the stroke flush against the element. That is
  how the shadcn ring's "no gap" is reproduced.
- A `Positioned` child does not contribute to a `Stack`'s size. The slider's
  thumb is positioned, so the slider has to reserve `max(track, thumb)` itself
  or it lays out at track height and paints over its neighbours.
- A widget with no intrinsic height stretches when its parent hands down tight
  constraints. `Kbd` takes an explicit height and an `Align(heightFactor: 1)`
  so a key cap stays key-shaped inside a button's row.
- Fixed-size boxes around text (OTP slots) must multiply by
  `MediaQuery.textScalerOf(context).scale(1)` or the glyph is clipped.
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
- **Escape must not be bound unconditionally.** A `CallbackShortcuts` for
  Escape consumes the key even while its overlay is closed, so the enclosing
  dialog never closes. Use `DismissShortcut` (`lib/src/utils/`), whose
  action reports itself disabled — and the key unhandled — while inactive.
- **Each root context menu has its own tap-region group**, shared with its
  submenus (`ContextMenuState.tapRegionGroupId`). A single global group
  made a tap on another menu's trigger count as inside, so the open menu
  never closed.
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
  still compile) skips pixel comparison elsewhere — macOS differs by several percent on these small
  images — and makes `--update-goldens` a no-op there, so macOS pixels can
  never be committed. `SHAD_COMPARE_GOLDENS=1` forces comparison;
  `SHAD_SKIP_GOLDENS=1` skips it on Linux too (the minimum-Flutter CI job).
- Prefer asserting resolved *theme values* over pixels. For anything with modes
  (menu colour × finish × accent × brightness) walk the whole matrix in one test
  and assert luminance contrast — that found a real collision (light + inverted
  + bold puts a near-black primary on a near-black surface) that reasoning about
  cases had missed twice.
- `pumpAndSettle` hangs on anything with `Skeleton` or `Spinner`; pump
  fixed frames instead.
- Popover contents are wrapped in `IgnorePointer` during the entrance
  animation — pump ~12 × 50 ms before tapping an option, and pick options near
  the top of the list, since ones below the scroll fold are found but not
  tappable.
- Example tests set `GoogleFonts.config.allowRuntimeFetching = false`; the
  resulting log lines are noise, not failures.

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
- `test/readme_snippet_test.dart` and `example/test/example_md_test.dart` hold
  verbatim copies of the README and `example/example.md` snippets and check
  they still match.
- Releases: bump `pubspec.yaml` + `CHANGELOG.md` on main; after tests pass
  `create-release.yaml` tags `v<version>`, and `publish.yaml` publishes that
  tag to pub.dev (OIDC).
- Verify with: `flutter analyze` and `flutter test` at the root, then the same
  in `example/`. The example consumes the
  package through the public barrel, so it catches export breakage that the
  root analyzer does not. There is no separate `playground/` app any more —
  it was a standalone Flutter web project superseded by the example app's own
  `PlaygroundScreen` and removed with its Firebase hosting config.
- `example/macos/` is gitignored, so changes there (e.g. the
  `com.apple.security.network.client` entitlement that `google_fonts` needs)
  will not commit.

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
  surfaces as a misleading `mouse_tracker` assertion. `openMobile` and `open`
  are independent, as in the reference. Growing past the breakpoint pops the
  sheet (post-frame, from `didChangeDependencies`), matching the reference
  unmounting its mobile branch.
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

- `strand_shell.dart` is a `NavigationScaffold`; `navigation.dart` has
  `StrandDestination`, `context.goTo(...)` and
  `context.pushFullScreen(builder)`. `data.dart` and `assets.dart` hold the
  people, companies and image paths shared by the screens (images are in
  `example/assets/strand/`, taken from the design files).
- One screen per destination: `screens/<x>_screen.dart`, its pieces in
  `widgets/<x>_*.dart`, its content in `data/<x>_data.dart`, its tests in
  `example/test/strand_<x>_screen_test.dart`. Network and Notifications have
  no design and show `placeholder_screen.dart`.
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
  `LayoutBuilder`'s width so 800–1200px windows degrade gracefully; gaps
  and radii on the theme's scale use `Gap.md()` / `GapSize` /
  `theme.radii`; an off-scale number that recurs gets one named constant in
  the screen's own `*_metrics.dart` or common file (`jobsSnugGap = 14`), not
  a new theme token.
- **Text and icons drawn straight on a surface use `scheme.tint`**, never
  `accentForeground`. The two are the same teal in the default scheme, but
  `accentForeground` is the ink *on an accent fill* (a selected chip, a
  highlighted menu row), and a bold menu accent rewrites the accent pair
  with the primary pair — which made every link and stat number near-white
  on a white card under the Press preset.
- **Reading the designs.** In the design HTML, `<span>`/`<div>` are
  content-box and `<button>` is border-box: a `h:30` span with a 1px border
  renders 32 tall, which is why skill chips are 32. A header of `h:64` with
  a bottom border is 65 — `AppBar` and `TabBar` add their hairline to their
  height for the same reason.
- **Glass over a photograph needs an isolated backdrop.** A backdrop filter
  samples everything behind it within the blur radius, so a label on a dark
  photo picks up the pale page around the card and turns grey; CSS only
  samples under the element. Story cards and post media therefore clip
  themselves with `Clip.antiAliasWithSaveLayer`.
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
  `example/fonts/`), highlighted by `syntax_highlight`, whose grammar loads
  in `main()` via `CodeHighlighter.ensureInitialized()` **before** `runApp`.
- `skills/finesse-overview/components/*.md` are generated from the docs
  pages by `dart run scripts/generate_skills.dart`, whose `_slugs` list is
  hard-coded and which only reads single-quoted string literals.
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
  themes, or `AnimatedTheme` re-animates every frame.
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
  panel opens. Builders and text themes are cached per family (closure
  identity is part of theme equality). In `testWidgets` a font load only
  ends at its timeout, so font and preset tests pump past it.
- `google_fonts` is an example-only dependency. The package itself has no
  font dependency.
