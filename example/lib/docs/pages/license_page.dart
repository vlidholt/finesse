import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/license_page/license_page_basic.dart';

final licensePageDoc = ComponentDoc(
  slug: 'license_page',
  title: 'License Page',
  description:
      'A page that lists the licences of the software the app is built '
      'from. It reads them from the `LicenseRegistry` of Flutter, where the '
      'build registers the `LICENSE` file of every package, groups them by '
      'package, and opens each package on a page of its own.',
  examples: [
    ComponentExample(
      id: 'license_page_basic',
      title: 'Default',
      description:
          '`showLicensePage` pushes the page on the nearest navigator. The '
          'name, version, icon and small print of the app show above the '
          'list, each only when given; the name falls back to the title of '
          'the app. `LicensePage` is the page itself, for a destination of '
          'your own.',
      builder: (_) => const LicensePageBasicExample(),
    ),
  ],
);
