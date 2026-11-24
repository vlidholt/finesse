import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Things that appear in answer to something. `Entrance` brings its child in
/// with a fade, a little growth and a few pixels of travel, and takes it out
/// faster than it came; `PopIn` is the smaller, bouncier version for a mark
/// or a dot. Neither changes the layout: the alert's space is always there.
class MotionEntranceExample extends StatefulWidget {
  const MotionEntranceExample({super.key});

  @override
  State<MotionEntranceExample> createState() => _MotionEntranceExampleState();
}

class _MotionEntranceExampleState extends State<MotionEntranceExample> {
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Entrance(
            visible: saved,
            appear: false,
            // It grows out of the edge nearest the button that caused it.
            origin: Alignment.bottomCenter,
            child: const Alert(
              icon: PhosphorIcon(PhosphorIconsRegular.checkCircle),
              title: Text('Saved'),
              description: Text('Your changes are stored.'),
            ),
          ),
          Button(
            onPressed: () => setState(() => saved = !saved),
            trailing: PopIn(
              visible: saved,
              wipe: true,
              child: PhosphorIcon(
                PhosphorIconsBold.check,
                size: 16,
                color: scheme.primaryForeground,
              ),
            ),
            child: Text(saved ? 'Saved' : 'Save'),
          ),
        ],
      ),
    );
  }
}
