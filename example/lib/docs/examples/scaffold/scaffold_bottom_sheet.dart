import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A persistent sheet: a mini player that stays over the end of the page
/// without blocking it. The list is inset for it and scrolls beneath.
class ScaffoldBottomSheetExample extends StatefulWidget {
  const ScaffoldBottomSheetExample({super.key});

  @override
  State<ScaffoldBottomSheetExample> createState() =>
      _ScaffoldBottomSheetExampleState();
}

class _ScaffoldBottomSheetExampleState
    extends State<ScaffoldBottomSheetExample> {
  static const _tracks = [
    'Slow Tide',
    'Paper Lanterns',
    'Northbound',
    'Glass Hours',
    'Low Sun',
    'Harbour Lights',
    'Second Wind',
    'Afterglow',
  ];

  int _playing = 0;
  bool _paused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Evening')),
        bottomSheet: Padding(
          padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
          child: Glass(
            level: GlassLevel.strong,
            borderRadius: theme.radii.xl,
            shadows: theme.style.floatingShadow,
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
            child: Row(
              spacing: theme.layoutTheme.gap(GapSize.md),
              children: [
                const IconTile(
                  icon: PhosphorIcon(PhosphorIconsRegular.musicNotes),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_tracks[_playing], style: theme.textTheme.small),
                      Text('Nora Vale', style: theme.textTheme.caption),
                    ],
                  ),
                ),
                IconButton.ghost(
                  icon: PhosphorIcon(
                    _paused ? PhosphorIconsFill.play : PhosphorIconsFill.pause,
                  ),
                  semanticLabel: _paused ? 'Play' : 'Pause',
                  onPressed: () => setState(() => _paused = !_paused),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          children: [
            for (final (index, track) in _tracks.indexed)
              ListTile(
                title: Text(track),
                subtitle: const Text('Nora Vale'),
                selected: index == _playing,
                onTap: () => setState(() => _playing = index),
              ),
          ],
        ),
      ),
    );
  }
}
