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
