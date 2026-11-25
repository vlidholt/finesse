# License Page

A page that lists the licences of the software the app is built from. It reads them from the `LicenseRegistry` of Flutter, where the build registers the `LICENSE` file of every package, groups them by package, and opens each package on a page of its own.

## Default

`showLicensePage` pushes the page on the nearest navigator. The name, version, icon and small print of the app show above the list, each only when given; the name falls back to the title of the app. `LicensePage` is the page itself, for a destination of your own.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class LicensePageBasicExample extends StatelessWidget {
  const LicensePageBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      leading: const PhosphorIcon(PhosphorIconsRegular.scroll),
      // Pushes a page that lists every package the app is built from,
      // read from Flutter's LicenseRegistry.
      onPressed: () => showLicensePage(
        context: context,
        applicationName: 'Demo',
        applicationVersion: '2.4.0',
        applicationIcon: const PhosphorIcon(PhosphorIconsFill.circlesThree),
        applicationLegalese: '© 2026 Demo Labs',
      ),
      child: const Text('Open source licenses'),
    );
  }
}
```
