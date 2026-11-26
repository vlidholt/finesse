import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A drawer. The app bar shows the menu button by itself; on a touch
/// screen the drawer can also be dragged in from the start edge, and it
/// closes on the scrim, with Escape, with the system back gesture or by
/// dragging it away.
class ScaffoldDrawerExample extends StatefulWidget {
  const ScaffoldDrawerExample({super.key});

  @override
  State<ScaffoldDrawerExample> createState() => _ScaffoldDrawerExampleState();
}

class _ScaffoldDrawerExampleState extends State<ScaffoldDrawerExample> {
  static const _folders = [
    (PhosphorIconsRegular.tray, 'Inbox'),
    (PhosphorIconsRegular.star, 'Starred'),
    (PhosphorIconsRegular.paperPlaneTilt, 'Sent'),
    (PhosphorIconsRegular.archive, 'Archive'),
  ];

  final _scaffold = GlobalKey<ScaffoldState>();
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(title: Text(_folders[_selected].$2)),
        drawer: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
            children: [
              Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
                child: Text('Mail', style: theme.textTheme.h4),
              ),
              for (final (index, (icon, label)) in _folders.indexed)
                ListTile(
                  leading: PhosphorIcon(icon),
                  title: Text(label),
                  selected: index == _selected,
                  onTap: () {
                    setState(() => _selected = index);
                    _scaffold.currentState?.closeDrawer();
                  },
                ),
            ],
          ),
        ),
        body: Center(
          child: Text(
            'Nothing in ${_folders[_selected].$2.toLowerCase()}',
            style: theme.textTheme.muted,
          ),
        ),
      ),
    );
  }
}
