import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonGesturesExample extends StatefulWidget {
  const ButtonGesturesExample({super.key});

  @override
  State<ButtonGesturesExample> createState() => _ButtonGesturesExampleState();
}

class _ButtonGesturesExampleState extends State<ButtonGesturesExample> {
  String last = 'Nothing yet';

  void _say(String what) => setState(() => last = what);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        // The button answers a press and a long press; the detector around
        // it adds what a button has no callback for.
        FinesseGestureDetector(
          onDoubleTap: () => _say('Double tap'),
          onSecondaryTapDown: (_) => _say('Secondary tap'),
          child: Button.outline(
            onPressed: () => _say('Pressed'),
            onLongPress: () => _say('Long press'),
            leading: const PhosphorIcon(PhosphorIconsRegular.image),
            child: const Text('Photo'),
          ),
        ),
        Text(last, style: theme.textTheme.muted),
      ],
    );
  }
}
