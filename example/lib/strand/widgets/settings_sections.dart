import 'package:example/common/app_state.dart';
import 'package:example/strand/data.dart';
import 'package:example/strand/data/profile_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

/// The cards of one page of Settings.
///
/// Each page is a column of cards; each card a heading, a line about it and
/// its controls — the package's own `TextField`, `Select`, `Switch`,
/// `Checkbox`, `FinesseRadioGroup`, `Slider` and `Tabs`, with nothing
/// restyled.
class SettingsSectionView extends StatelessWidget {
  const SettingsSectionView({
    required this.section,
    required this.settings,
    super.key,
  });

  final SettingsSection section;
  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      gap: GapSize.lg,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: switch (section) {
        SettingsSection.account => [
          _ProfileCard(settings: settings),
          _SecurityCard(settings: settings),
        ],
        SettingsSection.privacy => [
          _VisibilityCard(settings: settings),
          _ActivityCard(settings: settings),
          _MessagesCard(settings: settings),
        ],
        SettingsSection.notifications => [
          _PauseCard(settings: settings),
          _TopicsCard(settings: settings),
          _JobMatchCard(settings: settings),
        ],
        SettingsSection.appearance => [
          const _ThemeCard(),
          _DisplayCard(settings: settings),
        ],
      },
    );
  }
}

/// A card of Settings: a heading, a muted line under it, then [child].
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      rowMainAxisSize: MainAxisSize.max,
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Semantics(header: true, child: Text(title)),
      description: Text(description),
      child: child,
    );
  }
}

/// A preference on one line: what it is, a sentence about it, and its
/// control at the end.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.trailing,
    this.detail,
    this.leading,
    this.trailingIsLabelled = false,
  });

  final String title;
  final String? detail;
  final Widget? leading;
  final Widget trailing;

  /// Whether [trailing] carries [title] as its own semantic label — a group
  /// of tabs named "Mode". The visible title is then left out of the
  /// semantics, or a screen reader would say it twice.
  final bool trailingIsLabelled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        if (leading case final leading?) ...[leading, const Gap.md()],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                excluding: trailingIsLabelled,
                child: Text(
                  title,
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w500,
                    color: scheme.foreground,
                  ),
                ),
              ),
              if (detail case final detail?)
                Text(
                  detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted,
                ),
            ],
          ),
        ),
        const Gap.lg(),
        trailing,
      ],
    );
  }
}

/// A switch with its label and sentence: a [_SettingRow] ending in a
/// `Switch`, read to assistive technology as one control.
///
/// The row is merged into one semantic node — the title and the sentence
/// become the switch's label — rather than the switch being given the
/// title as a label of its own, which left the visible title in the tree
/// to be read a second time.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: _SettingRow(
        title: title,
        detail: detail,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

/// A labelled form field: the label over the control.
///
/// The control carries the label in its semantics, so the visible text is
/// left out of them: one node per field, not a label and then a field of
/// the same name.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
        const Gap.xs(),
        Semantics(label: label, child: child),
      ],
    );
  }
}

/// Lays [children] out two across where there is room, and in one column
/// where there is not.
///
/// One `Wrap` either way, with the children's width worked out from the
/// room: every field stays the same child of the same parent when the
/// number of columns changes, so the one being typed in keeps its focus
/// through a resize.
class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.children});

  final List<Widget> children;

  /// The least a field is wide before the grid drops to one column.
  static const _minFieldWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    final gap = Theme.of(context).layoutTheme.gap(GapSize.lg);
    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxWidth;
        final two = room >= _minFieldWidth * 2 + gap;
        // Rounded down, so that two of them and the gap never come to a
        // hair more than the room and wrap.
        final width = two ? ((room - gap) / 2).floorToDouble() : room;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

/// The rule between two rows of a settings card.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => Divider.horizontal(
    margin: EdgeInsets.symmetric(
      vertical: Theme.of(context).gap(GapSize.md),
    ),
  );
}

// Account.

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({required this.settings});

  final SettingsController settings;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  late final _name = TextEditingController(text: widget.settings.name);
  late final _headline = TextEditingController(
    text: widget.settings.headline,
  );
  late final _email = TextEditingController(text: widget.settings.email);
  late String _language = widget.settings.language;

  SettingsController get _settings => widget.settings;

  bool get _dirty =>
      _name.text != _settings.name ||
      _headline.text != _settings.headline ||
      _email.text != _settings.email ||
      _language != _settings.language;

  @override
  void initState() {
    super.initState();
    for (final controller in [_name, _headline, _email]) {
      controller.addListener(_onEdited);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _headline.dispose();
    _email.dispose();
    super.dispose();
  }

  void _onEdited() => setState(() {});

  void _save() {
    _settings.update(() {
      _settings
        ..name = _name.text
        ..headline = _headline.text
        ..email = _email.text
        ..language = _language;
    });
    showStrandToast(context, 'Your changes are saved');
  }

  void _discard() {
    _name.text = _settings.name;
    _headline.text = _settings.headline;
    _email.text = _settings.email;
    setState(() => _language = _settings.language);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SettingsCard(
      title: 'Profile',
      description: 'How you appear across Strand.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingRow(
            leading: PersonAvatar(People.me, size: theme.avatarLg),
            title: _settings.name,
            detail: ProfileData.currentRole,
            trailing: Button.outline(
              size: ButtonSize.sm,
              onPressed: () => context.leaveTo(StrandDestination.profile),
              child: const Text('View profile'),
            ),
          ),
          const _RowDivider(),
          _FieldGrid(
            children: [
              _Field(
                label: 'Name',
                child: TextField(controller: _name),
              ),
              _Field(
                label: 'Email',
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              _Field(
                label: 'Headline',
                child: TextField(controller: _headline),
              ),
              _Field(
                label: 'Language',
                child: Select<String>(
                  // Rebuilt when "Discard" puts the saved language back.
                  key: ValueKey(_language),
                  initialValue: _language,
                  minWidth: double.infinity,
                  options: [
                    for (final language in SettingsController.languages)
                      SelectOption(value: language, child: Text(language)),
                  ],
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (value) {
                    if (value != null) setState(() => _language = value);
                  },
                ),
              ),
            ],
          ),
          const Gap.xl(),
          // A wrap: in a narrow card at a large text size the two buttons
          // stack rather than overflow.
          Wrap(
            alignment: WrapAlignment.end,
            spacing: theme.gap(GapSize.sm),
            runSpacing: theme.gap(GapSize.sm),
            children: [
              Button.outline(
                enabled: _dirty,
                onPressed: _discard,
                child: const Text('Discard'),
              ),
              Button(
                enabled: _dirty,
                onPressed: _save,
                child: const Text('Save changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Sign-in and security',
      description: 'Keep your account yours.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SwitchRow(
            title: 'Two-step verification',
            detail: 'Ask for a code from your phone when you sign in',
            value: settings.twoStep,
            onChanged: (value) =>
                settings.update(() => settings.twoStep = value),
          ),
          const _RowDivider(),
          _SettingRow(
            title: 'Password',
            detail: 'Last changed in August',
            trailing: Button.outline(
              size: ButtonSize.sm,
              onPressed: () => showStrandToast(
                context,
                'Check your inbox',
                description:
                    'We sent a link to ${settings.email} to set a new '
                    'password.',
              ),
              child: const Text('Change'),
            ),
          ),
          const _RowDivider(),
          const _SettingRow(
            leading: IconTile(icon: PhosphorIcon(PhosphorIconsRegular.laptop)),
            title: 'MacBook Pro · Copenhagen',
            detail: 'This device · Active now',
            trailing: Badge.secondary(child: Text('Current')),
          ),
          const Gap.md(),
          _SettingRow(
            leading: const IconTile(
              icon: PhosphorIcon(PhosphorIconsRegular.deviceMobile),
            ),
            title: 'iPhone · Copenhagen',
            detail: 'Strand for iOS · Active 2 hours ago',
            trailing: Button.ghost(
              size: ButtonSize.sm,
              onPressed: () => showStrandToast(
                context,
                'Signed out of iPhone',
                description: 'That device will need your password again.',
              ),
              child: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}

// Privacy.

class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Profile visibility',
      description: 'Who can open your profile and find it in search.',
      child: FinesseRadioGroup<ProfileVisibility>(
        initialValue: settings.visibility,
        // Two-line options want more air than the group's 4.
        spacing: Theme.of(context).layoutTheme.gap(GapSize.md),
        onChanged: (value) {
          if (value != null) settings.update(() => settings.visibility = value);
        },
        items: [
          for (final option in ProfileVisibility.values)
            Radio(
              value: option,
              label: Text(option.label),
              sublabel: Text(option.detail),
            ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Activity',
      description: 'What other people can tell about what you do here.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SwitchRow(
            title: 'Show when you are active',
            detail: 'The dot on your portrait in Messages',
            value: settings.showOnline,
            onChanged: (value) =>
                settings.update(() => settings.showOnline = value),
          ),
          const _RowDivider(),
          _SwitchRow(
            title: 'Read receipts',
            detail: 'Let people see when you have read their message',
            value: settings.readReceipts,
            onChanged: (value) =>
                settings.update(() => settings.readReceipts = value),
          ),
          const _RowDivider(),
          _SwitchRow(
            title: 'Share profile views',
            detail: 'Show your name when you look at someone’s profile',
            value: settings.shareProfileViews,
            onChanged: (value) =>
                settings.update(() => settings.shareProfileViews = value),
          ),
          const _RowDivider(),
          _SwitchRow(
            title: 'Open to work, recruiters only',
            detail: 'Hide the status from people at Halcyon',
            value: settings.openToRecruitersOnly,
            onChanged: (value) =>
                settings.update(() => settings.openToRecruitersOnly = value),
          ),
        ],
      ),
    );
  }
}

class _MessagesCard extends StatelessWidget {
  const _MessagesCard({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Messages',
      description: 'Everyone else lands in your message requests.',
      child: _FieldGrid(
        children: [
          _Field(
            label: 'Who can message you',
            child: Select<MessagePolicy>(
              initialValue: settings.messages,
              minWidth: double.infinity,
              options: [
                for (final policy in MessagePolicy.values)
                  SelectOption(value: policy, child: Text(policy.label)),
              ],
              selectedOptionBuilder: (context, value) => Text(
                value.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onChanged: (value) {
                if (value != null) {
                  settings.update(() => settings.messages = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Notifications.

class _PauseCard extends StatelessWidget {
  const _PauseCard({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return Card(
      rowMainAxisSize: MainAxisSize.max,
      // One control to a screen reader, as a [_SwitchRow] is.
      child: MergeSemantics(
        child: _SettingRow(
          leading: IconTile(
            icon: PhosphorIcon(
              settings.pauseAll
                  ? PhosphorIconsRegular.bellSimpleSlash
                  : PhosphorIconsRegular.bellSimpleRinging,
            ),
          ),
          title: 'Pause all notifications',
          detail: settings.pauseAll
              ? 'Paused. Nothing new will reach you until you switch this '
                    'off.'
              : 'Take a break without changing what you are told about.',
          trailing: Switch(
            value: settings.pauseAll,
            onChanged: (value) =>
                settings.update(() => settings.pauseAll = value),
          ),
        ),
      ),
    );
  }
}

class _TopicsCard extends StatelessWidget {
  const _TopicsCard({required this.settings});

  final SettingsController settings;

  /// The width of a channel's column: a checkbox under a short heading.
  static const _columnWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final width = _columnWidth * scale;
    final heading = theme.textTheme.caption.copyWith(
      fontWeight: FontWeight.w600,
    );

    Widget box(
      Set<NotificationTopic> channel,
      String name,
      NotificationTopic t,
    ) {
      return SizedBox(
        width: width,
        child: Center(
          child: Semantics(
            label: '${t.label}, $name',
            child: Checkbox(
              value: channel.contains(t),
              enabled: !settings.pauseAll,
              onChanged: (_) => settings.toggle(channel, t),
            ),
          ),
        ),
      );
    }

    return _SettingsCard(
      title: 'What you are told about',
      description: 'Choose a channel for each kind of activity.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Activity', style: heading)),
              for (final name in const ['Push', 'Email'])
                SizedBox(
                  width: width,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: heading,
                  ),
                ),
            ],
          ),
          for (final topic in NotificationTopic.values) ...[
            const _RowDivider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic.label,
                        style: theme.textTheme.p.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                      Text(topic.detail, style: theme.textTheme.muted),
                    ],
                  ),
                ),
                box(settings.push, 'push', topic),
                box(settings.emailed, 'email', topic),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _JobMatchCard extends StatelessWidget {
  const _JobMatchCard({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final percent = (settings.jobMatch * 100).round();
    return _SettingsCard(
      title: 'Job matches and email',
      description: 'Fewer, better emails.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Only tell me about roles that match at least',
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w500,
                    color: scheme.foreground,
                  ),
                ),
              ),
              const Gap.md(),
              Text(
                '$percent%',
                style: theme.textTheme.large.copyWith(color: scheme.tint),
              ),
            ],
          ),
          const Gap.md(),
          Semantics(
            label: 'Least match for a job notification',
            child: Slider(
              initialValue: settings.jobMatch * 100,
              min: 50,
              max: 100,
              divisions: 10,
              showDivisionMarks: false,
              onChanged: (value) =>
                  settings.update(() => settings.jobMatch = value / 100),
            ),
          ),
          const Gap.xs(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50%, more roles', style: theme.textTheme.caption),
              Text('100%, exact fits', style: theme.textTheme.caption),
            ],
          ),
          const _RowDivider(),
          _FieldGrid(
            children: [
              _Field(
                label: 'Summary email',
                child: Select<DigestFrequency>(
                  initialValue: settings.digest,
                  minWidth: double.infinity,
                  options: [
                    for (final option in DigestFrequency.values)
                      SelectOption(value: option, child: Text(option.label)),
                  ],
                  selectedOptionBuilder: (context, value) => Text(
                    value.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      settings.update(() => settings.digest = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Appearance.

/// Light or dark, and the text size: the two settings on this page that are
/// real. They write to the app's own state, so the whole app follows, the
/// theme editor shows the same values, and a change made in the editor
/// shows here.
class _ThemeCard extends StatefulWidget {
  const _ThemeCard();

  /// The range of the text-size slider. The theme editor's goes further.
  static const _minScale = .85;
  static const _maxScale = 1.3;

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  /// The slider's thumb. The text scale is the theme editor's too, which
  /// can change it while this card is showing; a slider given only an
  /// initial value would leave its thumb where it was, under a label that
  /// says something else.
  final _scale = SliderController(initialValue: 1);

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SignalBuilder(
      builder: (context, _) {
        final mode = themeModeProvider.of(context);
        final config = themeConfigProvider.of(context);
        final editorOpen = themeEditorOpenProvider.of(context).value;
        final scale = config.value.textScale;
        // The thumb follows the setting, as far as this slider's shorter
        // range goes. A drag here writes the value it rounds to, so the
        // two never pull against each other.
        final thumb = scale.clamp(_ThemeCard._minScale, _ThemeCard._maxScale);
        if ((_scale.value - thumb).abs() > .001) _scale.value = thumb;

        return _SettingsCard(
          title: 'Theme',
          description: 'These two change the whole app, right away.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingRow(
                title: 'Mode',
                detail: 'Light for the day, dark for the evening',
                trailingIsLabelled: true,
                trailing: Semantics(
                  label: 'Mode',
                  container: true,
                  child: Tabs<ThemeMode>(
                    value: mode.value,
                    onChanged: (value) => mode.value = value,
                    tabs: const [
                      Tab(
                        value: ThemeMode.light,
                        leading: PhosphorIcon(PhosphorIconsRegular.sun),
                        child: Text('Light'),
                      ),
                      Tab(
                        value: ThemeMode.dark,
                        leading: PhosphorIcon(PhosphorIconsRegular.moon),
                        child: Text('Dark'),
                      ),
                    ],
                  ),
                ),
              ),
              const _RowDivider(),
              Row(
                children: [
                  Expanded(
                    // The slider below is labelled with the same words.
                    child: ExcludeSemantics(
                      child: Text(
                        'Text size',
                        style: theme.textTheme.p.copyWith(
                          fontWeight: FontWeight.w500,
                          color: scheme.foreground,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${(scale * 100).round()}%',
                    style: theme.textTheme.large.copyWith(color: scheme.tint),
                  ),
                ],
              ),
              const Gap.md(),
              Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.textAa,
                    // A small letter and a large one: the slider's two ends.
                    size: theme.iconBeside(theme.textTheme.caption),
                    color: scheme.mutedForeground,
                  ),
                  const Gap.md(),
                  Expanded(
                    child: Semantics(
                      label: 'Text size',
                      child: Slider(
                        controller: _scale,
                        min: _ThemeCard._minScale,
                        max: _ThemeCard._maxScale,
                        divisions: 9,
                        showDivisionMarks: false,
                        onChanged: (value) {
                          // Rounded, so that 100% is exactly the default
                          // and the theme editor shows no change.
                          final rounded = (value * 20).round() / 20;
                          config.value = config.value.copyWith(
                            textScale: rounded,
                          );
                        },
                      ),
                    ),
                  ),
                  const Gap.md(),
                  PhosphorIcon(
                    PhosphorIconsRegular.textAa,
                    size: theme.iconBeside(theme.textTheme.h3),
                    color: scheme.mutedForeground,
                  ),
                ],
              ),
              const _RowDivider(),
              _SettingRow(
                title: 'Theme editor',
                detail: 'Restyle everything: colours, type, radii, glass',
                trailing: Button.outline(
                  size: ButtonSize.sm,
                  leading: const PhosphorIcon(PhosphorIconsRegular.paintBrush),
                  onPressed: context.toggleThemeEditor,
                  child: Text(editorOpen ? 'Close' : 'Open'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DisplayCard extends StatelessWidget {
  const _DisplayCard({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Feed and motion',
      description: 'How the home feed behaves.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SwitchRow(
            title: 'Reduce motion',
            detail: 'Fade where things would slide or scale',
            value: settings.reduceMotion,
            onChanged: (value) =>
                settings.update(() => settings.reduceMotion = value),
          ),
          const _RowDivider(),
          _SwitchRow(
            title: 'Compact feed',
            detail: 'Shorter posts, smaller pictures',
            value: settings.compactFeed,
            onChanged: (value) =>
                settings.update(() => settings.compactFeed = value),
          ),
          const _RowDivider(),
          _FieldGrid(
            children: [
              _Field(
                label: 'Play videos automatically',
                child: Select<Autoplay>(
                  initialValue: settings.autoplay,
                  minWidth: double.infinity,
                  options: [
                    for (final option in Autoplay.values)
                      SelectOption(value: option, child: Text(option.label)),
                  ],
                  selectedOptionBuilder: (context, value) => Text(value.label),
                  onChanged: (value) {
                    if (value != null) {
                      settings.update(() => settings.autoplay = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
