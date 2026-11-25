import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A floating action button. It keeps a page margin from the corner and
/// from whatever is at the bottom: add the footer and it travels up; move
/// it and it travels across; remove it and it pops out.
class ScaffoldFloatingActionButtonExample extends StatefulWidget {
  const ScaffoldFloatingActionButtonExample({super.key});

  @override
  State<ScaffoldFloatingActionButtonExample> createState() =>
      _ScaffoldFloatingActionButtonExampleState();
}

class _ScaffoldFloatingActionButtonExampleState
    extends State<ScaffoldFloatingActionButtonExample> {
  var _location = FloatingActionButtonLocation.end;
  bool _footer = false;
  bool _button = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Notes')),
        floatingActionButtonLocation: _location,
        floatingActionButton: _button
            ? FloatingActionButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.plus),
                label: const Text('New note'),
                onPressed: () {},
              )
            : null,
        footer: _footer
            ? Glass(
                frosted: false,
                borderRadius: BorderRadius.zero,
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
                child: Text('3 notes selected', style: theme.textTheme.small),
              )
            : null,
        body: PageContainer(
          scrollable: true,
          child: FinesseColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            gap: GapSize.md,
            children: [
              Text('Location', style: theme.textTheme.small),
              Wrap(
                spacing: theme.layoutTheme.gap(GapSize.sm),
                runSpacing: theme.layoutTheme.gap(GapSize.sm),
                children: [
                  for (final location in FloatingActionButtonLocation.values)
                    Chip(
                      label: Text(location.name),
                      selected: location == _location,
                      onSelected: (_) => setState(() => _location = location),
                    ),
                ],
              ),
              Switch(
                value: _footer,
                onChanged: (value) => setState(() => _footer = value),
                label: const Text('Footer'),
              ),
              Switch(
                value: _button,
                onChanged: (value) => setState(() => _button = value),
                label: const Text('Button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
