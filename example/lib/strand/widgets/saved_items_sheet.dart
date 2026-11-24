import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/data/profile_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Opens "Saved items": the posts, articles and jobs the user has
/// bookmarked, in a sheet — from the end edge on a desktop, from the bottom
/// on a phone.
///
/// What the home feed's "Saved items" shortcut and the avatar menu lead to.
/// A row closes the sheet and goes to where the item lives.
Future<void> showSavedItems(BuildContext context) async {
  final mobile = Theme.of(context).formFactor == FormFactor.mobile;
  final destination = await showSheet<StrandDestination>(
    context: context,
    side: mobile ? SheetSide.bottom : SheetSide.right,
    builder: (context) => const _SavedItemsSheet(),
  );
  if (destination != null && context.mounted) context.leaveTo(destination);
}

class _SavedItemsSheet extends StatelessWidget {
  const _SavedItemsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mobile = theme.formFactor == FormFactor.mobile;
    const post = HomeData.calmWriteUp;
    const talk = HomeData.configNordics;
    final article = ProfileData.featured.last;

    Widget row({
      required Widget leading,
      required String title,
      required String detail,
      required String saved,
      required StrandDestination destination,
    }) => ListTile(
      onTap: () => Navigator.of(context).pop(destination),
      crossAxisAlignment: CrossAxisAlignment.start,
      leading: leading,
      titleStyle: theme.textTheme.p.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.foreground,
      ),
      titleMaxLines: 2,
      title: Text(title),
      subtitle: Text(detail),
      trailing: Text(saved, style: homeFinePrint(theme)),
    );

    Widget heading(String text) => Padding(
      padding: EdgeInsets.fromLTRB(
        theme.layoutTheme.gap(GapSize.md),
        theme.layoutTheme.gap(GapSize.lg),
        theme.layoutTheme.gap(GapSize.md),
        homeTightGap,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: homeFinePrint(theme).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );

    return Sheet(
      title: const Text('Saved items'),
      description: const Text('Only you can see what you save.'),
      constraints: mobile ? null : const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading('Jobs · ${JobsData.savedJobs.value}'),
          for (final (job, saved) in [
            (JobsData.birchline, 'Sun'),
            (JobsData.orbital, 'Nov 18'),
          ])
            row(
              leading: StrandMark(
                asset: job.company.logo,
                label: job.company.name,
              ),
              title: job.title,
              detail: '${job.company.name} · ${job.location}',
              saved: saved,
              destination: StrandDestination.jobs,
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.layoutTheme.gap(GapSize.md),
              vertical: homeTightGap,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: HomeTextLink(
                'See all ${JobsData.savedJobs.value} saved jobs',
                onPressed: () =>
                    Navigator.of(context).pop(StrandDestination.jobs),
                style: theme.textTheme.small.copyWith(color: scheme.tint),
              ),
            ),
          ),
          heading('Posts and articles · 3'),
          row(
            leading: PersonAvatar(post.author, size: 44),
            title: post.link?.title ?? post.compactBody,
            detail: '${post.author.name} · ${post.age}',
            saved: 'Today',
            destination: StrandDestination.home,
          ),
          row(
            leading: PersonAvatar(talk.author, size: 44),
            title: talk.event?.title ?? talk.compactBody,
            detail: '${talk.author.name} · ${talk.age}',
            saved: 'Mon',
            destination: StrandDestination.home,
          ),
          row(
            leading: const IconTile(
              icon: Icon(PhosphorIconsRegular.article),
              size: 44,
            ),
            title: article.title,
            detail: 'By you · ${article.meta}',
            saved: 'Nov 12',
            destination: StrandDestination.profile,
          ),
        ],
      ),
    );
  }
}
