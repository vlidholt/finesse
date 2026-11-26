import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `floating: false` docks the bar along the bottom edge, whatever the
/// style says. `leading` stands apart at the start, and `alignment` places
/// the actions in the width that is left.
class ToolbarDockedExample extends StatefulWidget {
  const ToolbarDockedExample({super.key});

  @override
  State<ToolbarDockedExample> createState() => _ToolbarDockedExampleState();
}

class _ToolbarDockedExampleState extends State<ToolbarDockedExample> {
  final formats = <String>{'bold'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl2,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.lg)),
            child: Text(
              'Select some text to format it.',
              style: theme.textTheme.muted,
            ),
          ),
          // No screen under the bar here, so no safe area to keep clear
          // of.
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: Toolbar(
              floating: false,
              alignment: MainAxisAlignment.end,
              leading: Text('${formats.length} on'),
              children: [
                for (final (name, icon) in const [
                  ('bold', PhosphorIconsRegular.textB),
                  ('italic', PhosphorIconsRegular.textItalic),
                  ('underline', PhosphorIconsRegular.textUnderline),
                  ('link', PhosphorIconsRegular.link),
                ])
                  Toggle(
                    value: formats.contains(name),
                    onChanged: (on) => setState(
                      () => on ? formats.add(name) : formats.remove(name),
                    ),
                    child: PhosphorIcon(icon, semanticLabel: name),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
