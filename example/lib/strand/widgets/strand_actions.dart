import 'dart:async';

import 'package:example/strand/data.dart';
import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/data/network_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/screens/search_screen.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/profile_common.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/settings_links.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The small answers Strand gives to everything the designs drew but did
/// not design a destination for: a story, an article, "Send", "Share",
/// "Call", a footer link.
///
/// Each is the lightest thing that is still a real response — a dialog
/// with the content in it, a toast that says what happened (with "Undo"
/// where there is something to undo), or a trip to the screen that owns
/// the subject. None of them is a dead end.

/// Opens the search page on [query].
void openSearch(BuildContext context, String query) {
  context.pushFullScreen<void>((context) => SearchScreen(initialQuery: query));
}

/// Copies [url] to the clipboard and says so.
void copyLink(
  BuildContext context,
  String url, {
  String title = 'Link copied',
}) {
  // No clipboard in a widget test or on a locked-down browser: the toast
  // still names the link.
  unawaited(
    Clipboard.setData(ClipboardData(text: url)).catchError((Object _) {}),
  );
  showStrandToast(context, title, description: url);
}

/// Shows [story] the way a story is looked at: the photograph, whose it
/// is, and a field to reply.
Future<void> showStoryViewer(BuildContext context, Story story) {
  return showDialog<void>(
    context: context,
    builder: (context) => _StoryViewer(story),
  );
}

class _StoryViewer extends StatelessWidget {
  const _StoryViewer(this.story);

  final Story story;

  static const _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final person = story.person;
    final radius = theme.radii.xl2;
    return Dialog(
      padding: EdgeInsets.zero,
      borderRadius: radius,
      constraints: const BoxConstraints(maxWidth: 380),
      // The profile's round glass button: white on a dark scrim, where the
      // dialog's own would be dark on the photograph.
      closeIcon: ProfileCoverButton(
        icon: PhosphorIconsRegular.x,
        semanticLabel: 'Close',
        onPressed: () => Navigator.of(context).pop(),
      ),
      semanticLabel: '${person.name}’s story',
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: 9 / 14,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                story.image,
                fit: BoxFit.cover,
                semanticLabel: '${person.name}’s story',
              ),
              // Scrims, so the white text reads on any photograph.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x8009090B),
                      Color(0x0009090B),
                      Color(0x0009090B),
                      Color(0x9909090B),
                    ],
                    stops: [0, .28, .6, 1],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(theme.gap(GapSize.lg)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        PersonAvatar(
                          person,
                          size: theme.avatarSm,
                          ringColor: _white,
                          ringWidth: 1.5,
                        ),
                        const Gap.sm(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                person.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.small.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _white,
                                ),
                              ),
                              Text(
                                person.headline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.caption.copyWith(
                                  color: const Color(0xD9FFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Room for the close button.
                        Gap.raw(theme.avatarMd),
                      ],
                    ),
                    const Spacer(),
                    Button(
                      leading: const PhosphorIcon(
                        PhosphorIconsRegular.paperPlaneTilt,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showStrandToast(
                          context,
                          'Reply sent to ${person.firstName}',
                        );
                      },
                      child: Text('Reply to ${person.firstName}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows an article as a reader's preview: its picture, where it is from,
/// its title and how it opens.
Future<void> showArticlePreview(
  BuildContext context, {
  required String image,
  required String source,
  required String title,
  String? summary,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      return Dialog(
        constraints: const BoxConstraints(maxWidth: 520),
        semanticLabel: title,
        actions: [
          Button.outline(
            leading: const PhosphorIcon(PhosphorIconsRegular.bookmarkSimple),
            onPressed: () {
              Navigator.of(context).pop();
              showStrandToast(
                context,
                'Saved for later',
                description: title,
              );
            },
            child: const Text('Save'),
          ),
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: theme.radii.lg,
              child: AspectRatio(
                aspectRatio: 16 / 8,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const Gap.lg(),
            Text(
              theme.style.overline.applyCase(source),
              style: theme.style.overline.apply(theme.textTheme.caption),
            ),
            const Gap.xs(),
            Text(
              title,
              style: theme.textTheme.h3.copyWith(color: scheme.foreground),
            ),
            const Gap.sm(),
            Text(
              summary ??
                  'Fewer announcements, clearer landmarks and no surprise '
                      'motion: three changes that came up in almost every '
                      'session. The notes cover what was tried, what was '
                      'dropped, and the interview guide the team is happy '
                      'for you to reuse.',
              style: theme.textTheme.p.copyWith(color: scheme.foregroundSubtle),
            ),
          ],
        ),
      );
    },
  );
}

/// Opens "Send to": a few connections, each with a "Send" pill that turns
/// to "Sent". [what] names the thing being sent: "this post", "this job".
Future<void> showSendDialog(BuildContext context, {required String what}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _SendDialog(what: what),
  );
}

class _SendDialog extends StatefulWidget {
  const _SendDialog({required this.what});

  final String what;

  @override
  State<_SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends State<_SendDialog> {
  final _sent = <Person>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      constraints: const BoxConstraints(maxWidth: 440),
      title: const Text('Send to'),
      description: Text('Share ${widget.what} in a message.'),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
      child: FinesseColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in NetworkData.connections.reversed.take(4))
            Row(
              children: [
                PersonAvatar(entry.person, showOnline: entry.person.online),
                const Gap.md(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PersonName(
                        entry.person,
                        style: theme.textTheme.p.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                      Text(
                        entry.person.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                const Gap.sm(),
                StrandPillButton(
                  label: 'Send',
                  icon: PhosphorIconsRegular.paperPlaneTilt,
                  done: _sent.contains(entry.person),
                  doneLabel: 'Sent',
                  doneIcon: PhosphorIconsRegular.check,
                  onPressed: _sent.contains(entry.person)
                      ? null
                      : () => setState(() => _sent.add(entry.person)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Asks for a line or two of text — a comment, a job's title — and returns
/// it, or null if the dialog was cancelled or left blank.
Future<String?> showWriteDialog(
  BuildContext context, {
  required String title,
  required String placeholder,
  required String submit,
  String? description,
  bool multiline = true,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _WriteDialog(
      title: title,
      description: description,
      placeholder: placeholder,
      submit: submit,
      multiline: multiline,
    ),
  );
}

class _WriteDialog extends StatefulWidget {
  const _WriteDialog({
    required this.title,
    required this.placeholder,
    required this.submit,
    required this.multiline,
    this.description,
  });

  final String title;
  final String? description;
  final String placeholder;
  final String submit;
  final bool multiline;

  @override
  State<_WriteDialog> createState() => _WriteDialogState();
}

class _WriteDialogState extends State<_WriteDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      title: Text(widget.title),
      description: widget.description == null
          ? null
          : Text(widget.description!),
      actions: [
        Button.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Button(
          enabled: _controller.text.trim().isNotEmpty,
          onPressed: _submit,
          child: Text(widget.submit),
        ),
      ],
      child: widget.multiline
          ? Textarea(
              controller: _controller,
              autofocus: true,
              placeholder: Text(widget.placeholder),
            )
          : TextField(
              controller: _controller,
              autofocus: true,
              placeholder: Text(widget.placeholder),
              onSubmitted: (_) => _submit(),
            ),
    );
  }
}

/// Opens a comment box for a post that shows none in the feed, and says
/// that the comment was posted.
Future<void> showCommentDialog(BuildContext context, Person author) async {
  final comment = await showWriteDialog(
    context,
    title: 'Comment on ${author.firstName}’s post',
    placeholder: 'Add a comment…',
    submit: 'Post comment',
  );
  if (comment != null && context.mounted) {
    showStrandToast(context, 'Comment posted', description: comment);
  }
}

/// Says that the post was reposted, with "Undo".
void repostWithToast(BuildContext context, Person author) {
  showStrandToast(
    context,
    'Reposted to your network',
    description: '${author.firstName}’s post is now on your profile.',
    actionLabel: 'Undo',
    onAction: () {},
  );
}

/// The honest answer to "attach": Strand is a mock and cannot reach the
/// device's files or photographs.
void showNothingToAttach(BuildContext context) {
  showStrandToast(
    context,
    'Nothing to attach',
    description: 'This demo cannot open your files or photos.',
  );
}

/// Starts a call in the only way a mock can: it rings, and can be ended.
void startCall(BuildContext context, String name, {bool video = false}) {
  showStrandToast(
    context,
    video ? 'Video calling $name…' : 'Calling $name…',
    description: 'Ringing',
    actionLabel: 'End call',
    onAction: () {},
  );
}

/// What a link in the home feed's footer leads to. "Privacy" and
/// "Accessibility" have a page of Settings each; the rest say what Strand
/// is, and offer the way to what it is a demo of.
void openFooterLink(BuildContext context, String link) {
  switch (link) {
    case 'Privacy':
      openSettings(context, SettingsSection.privacy);
    case 'Accessibility':
      openSettings(context, SettingsSection.appearance);
    default:
      unawaited(
        showDialog<void>(
          context: context,
          builder: (dialogContext) => Dialog(
            title: Text(link == 'About' ? 'About Strand' : link),
            description: const Text(
              'Strand is a fictional professional network. It exists to '
              'show finesse, the Flutter component library every screen '
              'here is built from: the people, companies, jobs and posts '
              'are invented, and nothing you do is sent anywhere.',
            ),
            actions: [
              Button.outline(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
              Button(
                leading: const PhosphorIcon(PhosphorIconsRegular.squaresFour),
                onPressed: () {
                  // With the dialog's own context, not the caller's: the
                  // footer this was opened from is in a rail that drops
                  // away when the window narrows, and may be gone by now.
                  dialogContext.openComponentLibrary();
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Browse components'),
              ),
            ],
          ),
        ),
      );
  }
}
