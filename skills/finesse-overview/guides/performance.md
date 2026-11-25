# Performance rules for app code

The components are built to cost nothing at rest and little per scroll
frame, on the web as well as on devices. These are the rules that keep an
app on top of them that way. Each is a mistake that has been made and
measured.

## Glass and shadows

- **Few backdrop filters.** Every frosted `Glass`, bar, popover and menu is
  a backdrop filter, repainted whenever what is behind it moves. Bars,
  overlays and a little floating chrome are fine. Never one per row or per
  card: inside scrolling content use `Glass(frosted: false)`; over a
  photograph use a plain scrim.
- **Cards do not blur** in any built-in style. Turning `cardBlur` on pays a
  filter per card per frame.
- **Outer shadows go through `ShadowDecoration.box`**, never
  `BoxDecoration.boxShadow`; it is both correct on translucent fills and
  cheap to clip.
- **No `Opacity` around glass**: it breaks the blur on some renderers and
  adds a layer.

## Scrolling

- **A feed is a lazy list.** `ListView.builder`, `SliverListSection.builder`,
  `ReorderableListView.builder`, `ChatList`; `PageContainer(scrollable:
  true)` is for a page of a few cards.
- **A scrolling page is a layer.** `PageContainer(scrollable: true)` and
  every `Card` already add a `RepaintBoundary`, so scrolling repaints
  nothing. A hand-rolled `SingleChildScrollView` page needs one around its
  content.
- **Something that never stops is painted, not rebuilt**, in a layer of
  its own (`Spinner`, `TypingIndicator`). Nothing may rebuild or schedule
  frames on a screen at rest.

## Themes

- **Build themes once.** A theme compares by value, and `FinesseApp`
  switches themes with one rebuild and a cross-fade. A theme that is
  unequal to the last one (a new closure in it, a new text theme builder,
  a non-constant curve) rebuilds and re-fades the app on every build.
- **No `ThemeData` factory or `copyWith` in a hot `build`.** Each call
  re-derives some seventy component themes. A subtree that needs a
  re-themed copy derives it once per ambient theme and keeps it.
- `Motion` compares a `Cubic` by its numbers; any other custom curve must
  be a constant.

## Animation

- **No `CurvedAnimation` in `build`**: it leaks a listener per rebuild.
  Use `controller.drive(CurveTween(curve: ...))`.
- Prefer the springs and primitives (`SpringBuilder`, `AnimatedFill`,
  `MovingIndicator`): they animate in paint where they can.

## Fonts and icons

- **Never `GoogleFonts.getFont(name)` or `GoogleFonts.asMap()`** in a web
  app: either keeps every one of Google's families in the build. Name the
  font's method (`GoogleFonts.inter`).
- **Icon constants are `const IconData`.** Never build an `IconData` at
  run time: the release build's icon tree-shaker fails on it. Unused
  Phosphor weights are shrunk to almost nothing in a build; nothing to do.

See also: [surfaces.md](surfaces.md), [motion.md](motion.md),
[typography.md](typography.md).
