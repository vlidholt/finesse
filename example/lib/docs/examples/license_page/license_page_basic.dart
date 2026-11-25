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
        applicationName: 'Strand',
        applicationVersion: '2.4.0',
        applicationIcon: const PhosphorIcon(PhosphorIconsFill.circlesThree),
        applicationLegalese: '© 2026 Strand Labs',
      ),
      child: const Text('Open source licenses'),
    );
  }
}
