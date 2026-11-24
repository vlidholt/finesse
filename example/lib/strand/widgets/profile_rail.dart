import 'package:example/strand/data.dart';
import 'package:example/strand/data/profile_data.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/profile_common.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The rail's cards are padded a notch under the theme's card padding.
const _railPadding = EdgeInsets.all(profileRoomyGap);

// The rail's rows are set a size under a `ListTile`'s own (a 15/20 title
// over a 13/18 subtitle), and the package has no dense tile. These are the
// rows' styles, in one place. The rail only exists in the desktop layout,
// where the theme's body style is the designs' 14/20.

/// The title of a setting or a person: 14/20, semibold.
TextStyle _rowTitleStyle(ThemeData theme) =>
    theme.textTheme.p.copyWith(fontWeight: FontWeight.w600);

/// The name of a group: 14/18, medium.
TextStyle _groupTitleStyle(ThemeData theme) =>
    theme.textTheme.p.copyWith(height: 18 / 14, fontWeight: FontWeight.w500);

/// "Profile language" and "Public profile and URL".
class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget setting(String title, String value, String editLabel) => ListTile(
      padding: EdgeInsets.zero,
      crossAxisAlignment: CrossAxisAlignment.start,
      titleStyle: _rowTitleStyle(theme),
      title: Text(title),
      subtitle: Text(value),
      trailing: ProfileHeaderAction(
        icon: PhosphorIconsRegular.pencilSimple,
        label: editLabel,
      ),
    );

    return Card(
      padding: _railPadding,
      rowMainAxisSize: MainAxisSize.max,
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: profileSnugGap,
        children: [
          setting('Profile language', ProfileData.language, 'Edit language'),
          const Divider.horizontal(),
          setting('Public profile and URL', ProfileData.publicUrl, 'Edit URL'),
        ],
      ),
    );
  }
}

/// "People also viewed": four people, each with a Follow, Message or
/// Connect button.
class ProfilePeopleCard extends StatelessWidget {
  const ProfilePeopleCard({
    required this.done,
    required this.onAction,
    super.key,
  });

  /// The people whose Follow or Connect button has been pressed.
  final Set<Person> done;

  /// Called with the row whose button was pressed.
  final ValueChanged<ProfileSuggestion> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ProfileSection(
      title: 'People also viewed',
      padding: _railPadding,
      child: FinesseColumn(
        gap: GapSize.lg,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final suggestion in ProfileData.suggestions)
            ListTile(
              padding: EdgeInsets.zero,
              crossAxisAlignment: CrossAxisAlignment.start,
              leading: PersonAvatar(
                suggestion.person,
                size: profileMarkSize,
              ),
              titleStyle: _rowTitleStyle(theme),
              title: Text(suggestion.person.name),
              subtitle: Text(suggestion.person.headline),
              subtitleMaxLines: 2,
              trailing: _ActionButton(
                suggestion.action,
                done: done.contains(suggestion.person),
                onPressed: () => onAction(suggestion),
              ),
            ),
        ],
      ),
    );
  }
}

/// The pill beside a suggested person.
class _ActionButton extends StatelessWidget {
  const _ActionButton(
    this.action, {
    required this.done,
    required this.onPressed,
  });

  final SuggestionAction action;
  final bool done;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (action) {
      SuggestionAction.follow =>
        done ? PhosphorIconsRegular.check : PhosphorIconsRegular.plus,
      SuggestionAction.message => PhosphorIconsRegular.paperPlaneTilt,
      SuggestionAction.connect =>
        done ? PhosphorIconsRegular.clock : PhosphorIconsRegular.userPlus,
    };
    return Button.raw(
      // Pressed, it fills in: "Following", "Pending".
      variant: done ? ButtonVariant.secondary : ButtonVariant.outline,
      size: ButtonSize.sm,
      // A pill, where the style's text buttons are rounded rectangles.
      decoration: theme.buttonDecoration(radius: theme.radii.full),
      textStyle: theme.textTheme.small,
      leading: Icon(icon),
      onPressed: onPressed,
      child: Text(done ? action.doneLabel : action.label),
    );
  }
}

/// "Your groups".
class ProfileGroupsCard extends StatelessWidget {
  const ProfileGroupsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ProfileSection(
      title: 'Your groups',
      padding: _railPadding,
      child: FinesseColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final group in ProfileData.groups)
            ListTile(
              padding: EdgeInsets.zero,
              // A step under a `ListTile`'s own gap.
              gap: profileTightGap,
              leading: ProfileLogo(
                group.logo,
                label: '${group.name} logo',
                size: 36,
                radius: theme.radius,
              ),
              titleStyle: _groupTitleStyle(theme),
              title: Text(group.name),
              subtitleStyle: profileCaptionStyle(theme),
              subtitle: Text(group.members),
            ),
        ],
      ),
    );
  }
}
