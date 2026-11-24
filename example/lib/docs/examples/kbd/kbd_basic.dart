import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class KbdBasicExample extends StatelessWidget {
  const KbdBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Kbd('K'),
        Kbd.group(['⌘', 'K']),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Press '),
            Kbd.group(['Ctrl', 'Shift', 'P']),
            Text(' to open the palette'),
          ],
        ),
      ],
    );
  }
}
