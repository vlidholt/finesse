import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A picture behind the large title. It moves at half the page's speed,
/// fades as the bar collapses, and grows when the page is pulled down. The
/// page colour is brought up behind the title, so the title reads on any
/// picture in either brightness.
class SliverAppBarBackgroundExample extends StatelessWidget {
  const SliverAppBarBackgroundExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar.large(
              title: const Text('Lofoten'),
              subtitle: const Text('Seven days above the Arctic Circle'),
              expandedHeight: 220,
              background: const _Sky(),
              leading: BackButton(onPressed: () {}),
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.shareNetwork),
                  semanticLabel: 'Share',
                  onPressed: () {},
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.lg)),
              sliver: SliverList.separated(
                itemCount: 7,
                separatorBuilder: (_, _) => const Gap.md(),
                itemBuilder: (context, index) => Card(
                  title: Text('Day ${index + 1}'),
                  description: const Text('Reine to Hamnøy'),
                  child: Text(
                    'Up before the light for the ridge above the harbour, '
                    'then the long road north along the water.',
                    style: theme.textTheme.small,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stand-in for a photograph: any widget works here, an `Image` above
/// all.
class _Sky extends StatelessWidget {
  const _Sky();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1f4e6b), Color(0xff4f9aa8), Color(0xfff2b880)],
        ),
      ),
    );
  }
}
