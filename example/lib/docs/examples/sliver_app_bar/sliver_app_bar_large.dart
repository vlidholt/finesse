import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A large title. Scroll: it slides under the toolbar, the same title fades
/// in small, and the bar takes its surface. Pull down at the top and the
/// title grows a little.
class SliverAppBarLargeExample extends StatelessWidget {
  const SliverAppBarLargeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        // No `appBar`: the bar is the first sliver of the page.
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar.large(
              title: const Text('Library'),
              subtitle: const Text('128 albums'),
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.plus),
                  semanticLabel: 'Add',
                  onPressed: () {},
                ),
              ],
            ),
            SliverList.builder(
              itemCount: 30,
              itemBuilder: (context, index) => ListTile(
                leading: const IconTile(
                  icon: PhosphorIcon(PhosphorIconsRegular.vinylRecord),
                ),
                title: Text('Album ${index + 1}'),
                subtitle: const Text('12 songs'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
