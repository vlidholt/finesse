import 'package:flutter/widgets.dart';
import 'package:una/una.dart';
import 'package:url_launcher/url_launcher.dart';

/// An app built with the package, published on its own page.
class _Demo {
  const _Demo(this.name, this.slug);

  final String name;
  final String slug;

  String get icon => 'assets/images/demo_$slug.png';
  Uri get url => Uri.parse('https://vlidholt.github.io/una_$slug/');
}

const _demos = [
  _Demo('Una Social', 'social'),
  _Demo('Una Cowork', 'cowork'),
  _Demo('Una Banking', 'banking'),
  _Demo('Una Dating', 'dating'),
];

/// "Demos" beside the logo: a menu of the apps made with the package, each
/// opening its own page.
class DemosMenu extends StatelessWidget {
  const DemosMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      constraints: const BoxConstraints(minWidth: 220),
      items: [
        const MenuLabel(child: Text('Apps built with una')),
        for (final demo in _demos)
          MenuItem(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(demo.icon, width: 20, height: 20),
            ),
            trailing: const PhosphorIcon(PhosphorIconsRegular.arrowUpRight),
            onPressed: () => launchUrl(demo.url, webOnlyWindowName: '_blank'),
            child: Text(demo.name),
          ),
      ],
      builder: (context, controller, _) => Button.ghost(
        size: ButtonSize.sm,
        onPressed: controller.toggle,
        trailing: const PhosphorIcon(PhosphorIconsRegular.caretDown),
        child: const Text('Demos'),
      ),
    );
  }
}
