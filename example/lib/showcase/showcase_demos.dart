import 'package:example/showcase/showcase_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';
import 'package:url_launcher/url_launcher.dart';

/// An app built with the package, published on its own page.
class _Demo {
  const _Demo(this.name, this.slug, this.description);

  final String name;
  final String slug;

  /// What the app is, in a few words.
  final String description;

  String get icon => 'assets/images/demo_$slug.png';
  Uri get url => Uri.parse('https://vlidholt.github.io/una_$slug/');
}

const _demos = [
  _Demo('Una Social', 'social', 'A feed, stories, groups and a messenger'),
  _Demo('Una Cowork', 'cowork', 'Team boards with cards you drag'),
  _Demo('Una Banking', 'banking', 'Accounts, cards, payments and savings'),
  _Demo('Una Dating', 'dating', 'Profiles to swipe, matches and chat'),
];

/// The apps made with the package, beside the header: one row each, its
/// icon on the left and its name and what it is on the right, opening the
/// app in a new tab. A plain list, not cards: the rows highlight as they
/// are pointed at.
class ShowcaseDemos extends StatelessWidget {
  const ShowcaseDemos({super.key});

  /// The rows' own inset, which the heading takes too so that its text
  /// lines up with the icons.
  static const _inset = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: _inset),
          child: Semantics(
            header: true,
            child: Text(
              'Interactive examples',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
        ),
        const Gap.xs(),
        for (final demo in _demos) _DemoTile(demo: demo),
      ],
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.demo});

  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      padding: const EdgeInsets.symmetric(
        horizontal: ShowcaseDemos._inset,
        vertical: 8,
      ),
      gap: 12,
      borderRadius: theme.radii.xl,
      onTap: () => launchUrl(demo.url, webOnlyWindowName: '_blank'),
      leading: ClipRRect(
        borderRadius: theme.radii.lg,
        child: Image.asset(demo.icon, width: 40, height: 40),
      ),
      title: Text(demo.name),
      titleStyle: theme.textTheme.small.copyWith(
        color: scheme.foreground,
        fontWeight: FontWeight.w600,
      ),
      subtitle: Text(demo.description),
      subtitleStyle: theme.textTheme.caption,
      trailing: Semantics(
        label: 'Opens in a new tab',
        child: PhosphorIcon(
          PhosphorIconsRegular.arrowUpRight,
          size: 16,
          color: scheme.mutedForeground,
        ),
      ),
    );
  }
}

/// The page's header and the demos beside it: the text two columns wide
/// and the list of demos in the third on a desktop, the list under the
/// text on narrower pages.
class ShowcaseHeader extends StatelessWidget {
  const ShowcaseHeader({
    required this.columns,
    required this.text,
    super.key,
  });

  final ShowcaseColumns columns;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    if (columns.count >= 3) {
      return ShowcaseSpanRow(
        columns: columns,
        spans: const [2, 1],
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [text, const ShowcaseDemos()],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        text,
        const Gap.xl(),
        const ShowcaseDemos(),
      ],
    );
  }
}
