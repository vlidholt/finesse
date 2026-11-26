# Common mistakes

Each of these compiles, runs and looks nearly right, which is why they
survive. Check a screen against the list before calling it done.

## Imports and names

| Wrong | Right |
| --- | --- |
| `import 'package:flutter/material.dart';` in a una app | `package:flutter/widgets.dart` + `package:una/una.dart`. Material widgets only through `package:una/material.dart` and `UnaMaterial` ([theming.md](theming.md)). |
| `MaterialApp`, `Scaffold` from Material, `Icons.home` | `UnaApp`, una's `Scaffold`, `PhosphorIcon(PhosphorIconsRegular.house)` |
| `StyleTokens.una`, `.nova`, `.maia`, `.lyra`, `unaMobile` | `StyleTokens.fluid`, `.crisp`, `.pebble`, `.sharp`, `fluidMobile` |
| `TealColorScheme`, `ZincColorScheme`, `NeutralColorScheme`, `StoneColorScheme`, `BlueColorScheme` | `OceanColorScheme` (default), `GraphiteColorScheme`, `ForestColorScheme`, `IrisColorScheme`, `EmberColorScheme`, `RoseColorScheme` |
| `scheme.applyAccentScheme(AccentScheme.violetLight)` | `scheme.applyAccent(const Color(0xFF7C3AED))` |
| `Shad*`, `LucideIcons`, `Button.raw`, `ButtonSize.icon`, `TooltipController`, `effects:` | none of these exist ([SKILL.md](../SKILL.md)) |
| `Row`/`Column`/`Form`/`Table` where una's is meant | `UnaRow`, `UnaColumn`, `UnaForm`, `UnaTable` (plain `Row` and `Column` are fine when you want Flutter's) |

## Spacing and size

| Wrong | Right |
| --- | --- |
| `SizedBox(height: 16)` between two cards | `UnaColumn(gap: GapSize.lg)` or `const Gap.lg()` |
| `Padding(padding: EdgeInsets.all(24), child: page)` | `PageContainer(child: page)`: margins per form factor, maximum width, safe area |
| `EdgeInsets.only(top: 64)` to clear the app bar | nothing: the `Scaffold` puts the bars' heights in the body's `MediaQuery` padding, which `PageContainer` and `ListView` add |
| `Padding` inside a `Card` | the card already pads; change it with `Card(style: CardTheme(padding: ...))` |
| `if (MediaQuery.sizeOf(context).width < 600) ... height: 44` | leave the height to the widget; branch with `FormFactorBuilder` only to rearrange |
| `Text(..., style: TextStyle(fontSize: 18))` | a role: `theme.textTheme.large` |
| `PhosphorIcon(..., size: 16)` inside a `Button` | no `size`: the button hands it down |
| `BorderRadius.circular(12)` | `theme.radii.lg` |
| `Divider()` between sections of a card | `const Divider(margin: EdgeInsets.zero)` |
| `theme.gap(GapSize.md)` | `theme.layoutTheme.gap(GapSize.md)` (ThemeData has no `gap`) |

## Colour and type

| Wrong | Right |
| --- | --- |
| `Color(0xFF2563EB)` in a screen | a scheme token; your own colours in `ColorScheme.custom` |
| `scheme.primary` for a link, a selected icon, a progress fill | `scheme.tint`: `primary` is a fill under `primaryForeground` text and may not read as ink |
| `scheme.accentForeground` for brand-coloured text on a card | `scheme.tint`; `accentForeground` is the ink on an `accent` wash |
| `Colors.grey`, `foreground.withValues(alpha: .6)` for secondary text | `textTheme.muted` / `caption`, or `scheme.mutedForeground`; `foregroundSubtle` for one step louder |
| `TextStyle(fontWeight: FontWeight.w600)` on its own | `theme.textTheme.p.copyWith(fontWeight: FontWeight.w600)`: a per-weight font only resolves the face from a theme style |
| `muted.withValues(alpha: .5)` for "half of muted" | `muted.withValues(alpha: muted.a * .5)`: `withValues(alpha:)` replaces the alpha |
| Changing only the light scheme | change both palettes, or dark mode keeps the stock colours |

## Bars and structure

| Wrong | Right |
| --- | --- |
| `IconButton.ghost(...)` in an `AppBar`'s actions | `IconButton(...)`: the bar picks ghost, an outline disc over a picture, or plain on a Liquid Glass capsule |
| A hand-built back button in `leading` | nothing: the bar implies back, close or menu |
| A `Scaffold` inside each destination of a `NavigationScaffold` | page content only; full-screen views are pushed routes with their own `Scaffold` |
| `MaterialPageRoute`, `PageRouteBuilder` | `UnaPageRoute` (back gestures, the theme's motion) |
| Two layouts for list and detail, switched by width | `ListDetailLayout` |
| A `Row` of `IconButton`s as a bottom bar | `BottomNavigationBar` (destinations) or `Toolbar` (actions) |
| A `Container` with a colour, a radius and a `boxShadow` as a panel | `Card`, `Surface` or `Glass` ([surfaces.md](surfaces.md)) |
| `if (Platform.isIOS)` to pick glass, padding or a widget | nothing: the theme and the components decide ([liquid-glass.md](liquid-glass.md)) |

## Glass, motion and performance

| Wrong | Right |
| --- | --- |
| `Opacity`, `FadeTransition`, `AnimatedOpacity` around `Glass`, a bar or a surface | let the overlay fade itself; for your own content use `Entrance` |
| A frosted `Glass` per list row or card | `Glass(frosted: false)` inside scrolling content |
| A `BackdropFilter` for a label on a photo | a plain scrim: `Glass(frosted: false, color: ...)` or a gradient |
| `BoxDecoration(boxShadow: ...)` on a translucent surface | `ShadowDecoration.box(...)` |
| `AnimatedContainer` to fade a fill between states | `AnimatedFill` |
| `duration: const Duration(milliseconds: 300)` in an animation of your own | `Motion.of(context).normal` / `.snappy` / `.smooth` |
| `Theme.of(context).motion` | `Motion.of(context)` (honours reduced motion) |
| `ThemeData(...)` or `theme.copyWith(...)` in a `build` | build themes once; a subtree's re-themed copy is cached per ambient theme (an `Expando<ThemeData>`) |
| `CurvedAnimation(parent: controller, ...)` in `build` | `controller.drive(CurveTween(curve: ...))` |
| `GoogleFonts.getFont(name)`, `GoogleFonts.asMap()` | `TextTheme.fromGoogleFont(GoogleFonts.geist)` |
| `SingleChildScrollView` + `Column` for a feed | `ListView.builder` / slivers |
| `HapticFeedback.selectionClick()` | `Haptics.selection(context)` |

## Behaviour

| Wrong | Right |
| --- | --- |
| `value:` and `initialValue:` both on a control | one: `value` + `onChanged` (controlled) or `initialValue` |
| `onPressed: null` to show a button "inactive" while busy | `loading: true` keeps it focusable and announced; `null` disables it |
| `onPressed: () {}` on a button with nowhere to go | give it a real response: a sheet, a dialog, a toast |
| An icon-only button without `semanticLabel` | always label it |
| `CallbackShortcuts` for Escape | `DismissShortcut(isActive:, onDismiss:)` |
| `ModalRoute.of(context)!.isCurrent` in a key handler | `isShownOnTop(context)` |

See also: [recipes.md](recipes.md), [performance.md](performance.md).
