import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The same screen twice: una's filled bar, and the bar on Liquid Glass —
/// no fill, its buttons on capsules of glass, the page under it blurred
/// and faded into the page colour once it has scrolled there. The photo
/// starts under the bar; scroll either list to bring the rows under it.
class AppBarLiquidGlassExample extends StatelessWidget {
  const AppBarLiquidGlassExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        _Screen(label: 'Filled', liquidGlass: LiquidGlassMode.never),
        // `always` asks for the glass on every platform. In a browser its
        // soft edge is then una's own shader over a snapshot of the page.
        _Screen(label: 'Liquid Glass', liquidGlass: LiquidGlassMode.always),
      ],
    );
  }
}

class _Screen extends StatelessWidget {
  const _Screen({required this.label, required this.liquidGlass});

  final String label;
  final LiquidGlassMode liquidGlass;

  static const _places = [
    ('Reine', 'A fishing village under the peaks'),
    ('Hamnøy', 'Red cabins on the water'),
    ('Sakrisøy', 'A yellow harbour and its bridges'),
    ('Nusfjord', 'One of the oldest fishing villages'),
    ('Henningsvær', 'A football pitch on the rocks'),
    ('Kvalvika', 'A beach behind the ridge'),
    ('Ryten', 'The view down onto Kvalvika'),
    ('Haukland', 'White sand and turquoise water'),
    ('Uttakleiv', 'Round stones and the midnight sun'),
    ('Eggum', 'An old radar station by the sea'),
    ('Unstad', 'Surf under the mountains'),
    ('Å', 'The road ends at the last letter'),
    ('Moskenes', 'The ferry to Bodø'),
    ('Fredvang', 'Two bridges to the beaches'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Text(label, style: theme.textTheme.small),
        PhoneFrame(
          height: 520,
          child: Scaffold(
            appBar: AppBar(
              liquidGlass: liquidGlass,
              title: const Text('Lofoten'),
              leading: BackButton(onPressed: () {}),
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.heart),
                  semanticLabel: 'Save',
                  onPressed: () {},
                ),
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.shareNetwork),
                  semanticLabel: 'Share',
                  onPressed: () {},
                ),
              ],
            ),
            // No padding of its own: the photo starts under the bar, and
            // the rows scroll up under it.
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                Image.asset(
                  'assets/images/photo_alpine_lake.jpg',
                  height: 260,
                  fit: BoxFit.cover,
                ),
                for (final (name, line) in _places)
                  ListTile(
                    title: Text(name),
                    subtitle: Text(line),
                    showChevron: true,
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
