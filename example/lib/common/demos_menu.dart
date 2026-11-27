import 'package:flutter/widgets.dart';
import 'package:una/una.dart';
import 'package:url_launcher/url_launcher.dart';

/// An app built with the package, published on its own page.
class _Demo {
  const _Demo(this.name, this.line, this.slug);

  final String name;
  final String line;
  final String slug;

  String get icon => 'assets/images/demo_$slug.png';
  Uri get url => Uri.parse('https://vlidholt.github.io/una_$slug/');
}

const _demos = [
  _Demo('Una Social', 'A feed, stories and chat', 'social'),
  _Demo('Una Cowork', 'Team boards you drag cards across', 'cowork'),
  _Demo('Una Banking', 'Cards, accounts and payments', 'banking'),
  _Demo('Una Dating', 'Swipe, match and talk', 'dating'),
];

/// "Demos" beside the logo: a menu of the apps made with the package, each
/// opening its own page.
class DemosMenu extends StatelessWidget {
  const DemosMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownMenu(
      constraints: const BoxConstraints(minWidth: 260),
      items: [
        const MenuLabel(child: Text('Apps built with una')),
        for (final demo in _demos)
          MenuItem(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset(demo.icon, width: 28, height: 28),
            ),
            trailing: const PhosphorIcon(PhosphorIconsRegular.arrowUpRight),
            onPressed: () => launchUrl(demo.url, webOnlyWindowName: '_blank'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(demo.name),
                Text(demo.line, style: theme.textTheme.caption),
              ],
            ),
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
