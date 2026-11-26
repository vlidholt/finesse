import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A plain bar that is not pinned. It scrolls away with the page; with
/// `floating` it comes back the moment the page is scrolled the other way,
/// and settles fully in or out when the scrolling stops.
class SliverAppBarFloatingExample extends StatelessWidget {
  const SliverAppBarFloatingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              title: const Text('Feed'),
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.bell),
                  semanticLabel: 'Notifications',
                  onPressed: () {},
                ),
              ],
            ),
            SliverList.builder(
              itemCount: 40,
              itemBuilder: (context, index) => ListTile(
                title: Text('Post ${index + 1}'),
                subtitle: const Text('Scroll down, then a little back up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
