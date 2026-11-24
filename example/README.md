# finesse docs site

The source of <https://vlidholt.github.io/finesse/>: Strand, a social network
built with `finesse`'s default look; the component browser with the docs for
every component; and a theme editor that restyles both live.

For a minimal app, see [example.md](example.md).

## Running it

```bash
cd example
flutter pub get
flutter run -d chrome
```

It also runs on macOS, Windows, Linux, iOS and Android.

- **Fonts.** The theme editor loads its fonts from Google Fonts at runtime
  (`google_fonts`). On macOS the app needs network access. Flutter does not
  commit `macos/`, so after `flutter create --platforms=macos .` add
  `com.apple.security.network.client` to both
  `macos/Runner/DebugProfile.entitlements` and
  `macos/Runner/Release.entitlements`.
- **Driving the app from tools.** `test_driver/app.dart` enables the Flutter
  Driver extension:

  ```bash
  flutter run -t test_driver/app.dart
  ```

  Doc previews contain spinners that animate forever, so turn frame
  syncing off (`set_frame_sync: false`) before sending driver commands.

## Layout

| Path | Contents |
| --- | --- |
| `lib/main.dart` | Entry point and the app-wide theme, built from the editor's configuration. |
| `lib/common/` | The app shell (which docks the theme editor beside the page and switches between Strand and the component library), the app-wide state, and the theme editor. |
| `lib/strand/` | Strand, the social network the default theme was designed for: its shell (`strand_shell.dart`), screens, shared widgets and data. The app opens here. |
| `assets/strand/` | Strand's images, exported from the design files. |
| `lib/docs/` | The docs pages, their registry, and one runnable file per example under `examples/`. Each example is also bundled as an asset, so the code shown is the code that runs. |
| `lib/screens/` | The component-library browser, reached from Strand's avatar menu. |
