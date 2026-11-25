import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `centerTitle` puts the title in the centre of the bar — not of the space
/// the buttons leave — the way a pushed page is titled on iOS.
class AppBarCenterTitleExample extends StatelessWidget {
  const AppBarCenterTitleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 260,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: BackButton(onPressed: () {}),
          title: const Text('Notifications'),
          actions: [
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.gear),
              semanticLabel: 'Settings',
              onPressed: () {},
            ),
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.checks),
              semanticLabel: 'Mark all as read',
              onPressed: () {},
            ),
          ],
        ),
        body: Center(
          child: Text(
            'You are all caught up',
            style: Theme.of(context).textTheme.muted,
          ),
        ),
      ),
    );
  }
}
