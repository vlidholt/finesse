# Liquid Glass

On iOS and macOS — natively and in a browser — una draws its navigation
chrome, floating surfaces and lens controls with Apple's Liquid Glass,
through the `liquid_glass_widgets` package. Everywhere else it draws its
own frosted glass. App code does not change: the same widgets switch
material.

## What app code does about it: nothing

Liquid Glass is a material, not a layout. The metrics of a phone screen are
the same frosted or liquid, and every component that switches decides for
itself at build time. So:

- **Do not branch on the platform.** No `Platform.isIOS`,
  `defaultTargetPlatform`, `kIsWeb` or `LiquidGlass.isActive` in a screen
  to pick a widget, a padding or a colour. Write the una widget and the
  theme decides. (The Demo app, which runs on all of them, has none.)
- **Do not build glass yourself** for chrome: use `AppBar`,
  `BottomNavigationBar`, `Toolbar`, `Glass`, `Surface`, `showSheet`,
  `showDialog`. A hand-made `BackdropFilter` stays frosted on iOS and
  looks wrong beside the real glass.
- **Leave bar buttons without a variant** (`IconButton(icon: ...)`), so a
  bar can put them on a glass capsule; see
  [app-structure.md](app-structure.md).
- **Let content scroll under the bars.** Use the `Scaffold` and a
  `PageContainer`/`ListView`, which inset by the bars' heights; the glass
  only looks like glass with the page moving beneath it.
- **Never wrap glass in `Opacity`** or a `FadeTransition`; the shader
  does not survive an opacity layer any better than a blur.

To decide for the app or for one kind of component, set the theme:

```dart
// The whole app: always (preview it anywhere), never, or auto (default).
ThemeData(liquidGlass: const LiquidGlassTheme(mode: LiquidGlassMode.always));

// One component kind, over the theme's mode: a frosted app bar in a
// Liquid Glass app, Liquid Glass on a desktop's top bar.
ThemeData(
  appBarTheme: const AppBarTheme(liquidGlass: LiquidGlassMode.never),
  sheetTheme: const SheetTheme(liquidGlass: LiquidGlassMode.always),
);
```

Build those themes once, beside the app's other themes, never in a
`build`.

## Setup

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.initialize(); // loads the shaders before the first frame
  runApp(const MyApp());
}
```

Without `initialize()` the first glass surfaces come in a frame or two late.
If the shaders fail to load, una falls back to frosted glass for the
life of the app. Never call it in a widget test.

## The switch

```dart
ThemeData(
  liquidGlass: const LiquidGlassTheme(
    mode: LiquidGlassMode.auto, // auto (default) | always | never
    style: GlassStyle.ios27,    // or GlassStyle.ios26
    quality: null,              // GlassQuality.premium / standard / minimal
    adaptiveQuality: false,
    light: GlassThemeSettings(blur: 8), // any of the package's settings
  ),
)
```

- `auto` is Liquid Glass when `defaultTargetPlatform` is iOS or macOS —
  Flutter web reports the browser's platform, so Safari on an iPhone or a
  Mac counts.
- Every component that switches has a nullable `liquidGlass` on its
  component theme that wins over the theme's mode:
  `AppBarTheme`, `BottomNavigationBarTheme` (also `Toolbar`),
  `NavigationRailTheme`, `FloatingActionButtonTheme`, `GlassTheme`,
  `PopoverTheme` (popovers, menus, select lists, `Surface`), `CommandTheme`,
  `DialogTheme`, `SheetTheme`, `ToastTheme`, `SwitchTheme`, `SliderTheme`,
  `TabsTheme` (`SegmentedControl`).
- Under Increase Contrast (`MediaQuery.highContrastOf`) una draws
  frosted glass unless `respectSystemAccessibility: false`.
- The glass is tinted from the scheme's `bar` colour
  (`tintFromColorScheme: false` keeps the package's neutral tint).

## What switches

| una | On Liquid Glass |
| --- | --- |
| `AppBar` (phone and tablet) | No fill, no hairline; the content under it is blurred more the nearer the top and faded into the page, a little past the bar. A leading button and the actions sit on glass capsules; a logo or title stands bare. The capsule does not clip, so a badge on a button hangs over its edge; the buttons on it are round. Write buttons in a bar with no variant (`IconButton(icon: …)`) and the bar picks the look: plain on glass, ghost on a solid or frosted bar, outline over a picture. A desktop top bar stays solid unless `AppBarTheme(liquidGlass: LiquidGlassMode.always)`. |
| `BottomNavigationBar` (floating, with a selection) | The package's `GlassTabBar.bottom`: a lens slides between tabs; `action` floats beside the tabs on its own capsule. |
| `Toolbar` and a docked bottom bar | No slab: the page under them blurred and faded into the page colour from the bottom up, the controls standing on it (without shader filters, solid with a hairline). A floating `Toolbar` is a glass capsule. |
| `NavigationRail` | Glass material, una layout. |
| `Glass` (frosted, no custom `color`) | Glass material. Scrims and `frosted: false` stay. |
| `DropdownMenu`, a root `ContextMenu` (phone and tablet) | Morphs out of its trigger on a spring (the package's `GlassPopover`), driven by its `PopoverController`. Desktop, right-click, long-press and submenus stay una popovers. |
| `Popover`, menus, `Select` list, `Surface`, `Command` in a dialog, `Dialog`, `Sheet`, toasts | Glass material, una layout and behaviour; the entrance fade drives the glass's visibility. A popover with an arrow stays frosted. |
| `Switch`, `Slider`, `SegmentedControl` | The package's `GlassSwitch`, `GlassSlider`, `GlassSegmentedControl` (lens under the finger). A slider with a value bubble always shown or division marks, and a segmented control with no selection or with a non-`Text` label and no `semanticLabel`, stay una's. |
| `Tooltip`, cards, list tiles, fields, content buttons | Unchanged. |

## Sizes

`StyleTokens.fluidMobile` uses Liquid Glass's metrics (app bar 44, tab bar
64, switch 58 × 26, slider thumb 28, popover and dialog radius 24), so a
phone layout is the same frosted or liquid. Desktop (macOS included) keeps
una's sizes.

## Platforms

The full material needs Impeller's shader filters (iOS, macOS, Android).
On the web and Skia the package draws its `standard` tier by itself (blur,
rim, highlights, no refraction). There a top bar that would be Liquid Glass
is solid instead (the bar colour, opaque, with its hairline; no scroll edge
and no capsules; a `SliverAppBar.large` keeps its toolbar filled and its
picture starts below it: the package's graduated blur would be uniform, ending on a
line, and one built from backdrop filters shows bands and costs every frame
of a scroll), una drops the presets' invisible 0.6 blur so it costs
no backdrop pass, and makes overlays legible: a stronger blur, a whitened body and
una's hairline edge (`LiquidGlassSettings` `blur`, `whitenStrength`,
`edgeAbsorption`; the package's `frost`, which iOS uses for that, is
Impeller-only). `LiquidGlass.initialize()` also keeps the package's progress
messages out of the console. Tests run as
Android, so `auto` is frosted; set `debugDefaultTargetPlatformOverride =
TargetPlatform.iOS` to exercise the Liquid Glass path.
