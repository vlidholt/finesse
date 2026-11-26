import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The two buttons. Pressed, each pops the page it is on; here they are
/// given an `onPressed` instead, because the docs page is not theirs to
/// close.
class BackButtonBasicExample extends StatelessWidget {
  const BackButtonBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        BackButton(onPressed: () {}),
        CloseButton(onPressed: () {}),
      ],
    );
  }
}
