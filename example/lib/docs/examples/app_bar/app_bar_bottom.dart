import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A tab bar in `bottom`: a second row inside the bar's surface, above its
/// hairline. The page is inset for the whole bar.
class AppBarBottomExample extends StatefulWidget {
  const AppBarBottomExample({super.key});

  @override
  State<AppBarBottomExample> createState() => _AppBarBottomExampleState();
}

class _AppBarBottomExampleState extends State<AppBarBottomExample> {
  static const _tabs = ['Albums', 'Artists', 'Songs'];

  String _tab = _tabs.first;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 420,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          actions: [
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
              semanticLabel: 'Search',
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            // The bar draws the hairline under both rows.
            showBorder: false,
            tabs: [for (final tab in _tabs) Tab(value: tab, child: Text(tab))],
            value: _tab,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
        ),
        body: ListView(
          children: [
            for (var i = 1; i <= 12; i++) ListTile(title: Text('$_tab $i')),
          ],
        ),
      ),
    );
  }
}
