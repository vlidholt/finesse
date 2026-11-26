# Sliver App Bar

An app bar that lives in the scroll view: it can carry a large title that collapses into the toolbar, scroll away with the page, or come back when the reader turns round. Make it the first sliver of the `CustomScrollView` in a `Scaffold`'s body and give the scaffold no `appBar`. It follows the scroll at paint time — scrolling builds and lays out nothing in it.

## Large title

`SliverAppBar.large` sets the title large under the toolbar, at the page margin. As the page scrolls the large title slides under the toolbar, the same title fades in small and the bar takes its fill, hairline and blur. With bouncing physics, pulling down grows the expanded area and the title a little (`stretch`). The style comes from `AppBarTheme.largeTitleStyle`.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
```

## With a search field

`bottom` stays when the title has gone: a search field, a `TabBar`, filter chips. The bar is measured, so it can be any height.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A search field in `bottom`. It stays under the toolbar when the large
/// title has gone, inside the bar's surface.
class SliverAppBarBottomExample extends StatefulWidget {
  const SliverAppBarBottomExample({super.key});

  @override
  State<SliverAppBarBottomExample> createState() =>
      _SliverAppBarBottomExampleState();
}

class _SliverAppBarBottomExampleState extends State<SliverAppBarBottomExample> {
  static const _people = [
    'Aisha Rahman',
    'Claire Dubois',
    'Elena Petrova',
    'Freya Holm',
    'Irina Volkova',
    'Julian Reyes',
    'Mateo Alvarez',
    'Mei Tanaka',
    'Noor Haddad',
    'Omar Rahimi',
    'Rafael Cruz',
    'Sara Lindqvist',
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final margin = theme.layoutTheme.gap(GapSize.lg);
    final matches = [
      for (final person in _people)
        if (person.toLowerCase().contains(_query.toLowerCase())) person,
    ];
    return PhoneFrame(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Contacts'),
              bottom: Padding(
                padding: EdgeInsets.fromLTRB(
                  margin,
                  0,
                  margin,
                  theme.layoutTheme.gap(GapSize.md),
                ),
                // Cancel slides in beside the field while it has the
                // focus, as in a search bar on iOS.
                child: SearchField(
                  showCancel: true,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) => ListTile(
                leading: Avatar('', fallback: Text(matches[index][0])),
                title: Text(matches[index]),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## With a picture

`background` fills the expanded area behind the title and the toolbar. It lags behind the page, fades as the bar collapses and grows when the page is pulled down. `expandedHeight` gives it room. With reduced motion it neither lags nor grows.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
```

## Floating

The plain constructor looks like an `AppBar`. `pinned`, the default, keeps it at the top. Unpinned it scrolls away, and with `floating` it returns as soon as the page moves the other way, wherever the page is.

```dart
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
```
