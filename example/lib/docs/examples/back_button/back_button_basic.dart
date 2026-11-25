import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The two buttons. Pressed, each pops the page it is on; here they are
/// given an `onPressed` instead, because the docs page is not theirs to
/// close.
class BackButtonBasicExample extends StatelessWidget {
  const BackButtonBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        BackButton(onPressed: () {}),
        CloseButton(onPressed: () {}),
      ],
    );
  }
}
