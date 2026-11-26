import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

import '../harness.dart';
import 'common.dart';

/// The size of the component gallery.
const componentsSize = Size(1440, 820);

/// A gallery of components, laid out as a bento of small scenes.
class ComponentsScene extends StatelessWidget {
  /// Creates the gallery in [brightness].
  const ComponentsScene({required this.brightness, super.key});

  /// Light or dark.
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Panel(
      theme: imageTheme(brightness: brightness),
      child: const Padding(
        padding: EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Column([_SignUp(), _Display(), _Notice()])),
            SizedBox(width: 20),
            Expanded(child: _Column([_Stay(), _Filters()])),
            SizedBox(width: 20),
            Expanded(
              child: _Column([_Settings(), _Buttons(), _Format(), _Pages()]),
            ),
            SizedBox(width: 20),
            Expanded(
              child: _Column([
                _Verify(),
                _Goal(),
                _Toasts(),
                _Invite(),
                _Loading(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return UnaColumn(
      gap: GapSize.lg,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _SignUp extends StatelessWidget {
  const _SignUp();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      title: const Text('Create an account'),
      description: const Text('Enter your email to get started.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Label('Email'),
          const TextField(
            initialValue: 'maya@orbit.example',
            leading: PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
          ),
          const Gap.md(),
          const _Label('Password'),
          const TextField(
            initialValue: 'correct horse',
            obscureText: true,
            leading: PhosphorIcon(PhosphorIconsRegular.lockSimple),
            trailing: PhosphorIcon(PhosphorIconsRegular.eye),
          ),
          const Gap.md(),
          Checkbox(
            value: true,
            onChanged: (_) {},
            label: const Text('Send me product updates'),
          ),
          const Gap.lg(),
          Button(onPressed: () {}, child: const Text('Create account')),
          const Gap.sm(),
          Button.outline(
            onPressed: () {},
            leading: const PhosphorIcon(PhosphorIconsRegular.key),
            child: const Text('Continue with a passkey'),
          ),
          const Gap.md(),
          Center(
            child: Text(
              'Already have an account? Sign in',
              style: theme.textTheme.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      title: const Text('Appearance'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedControl<String>(
            value: 'dark',
            onChanged: (_) {},
            segments: const [
              Segment(
                value: 'light',
                icon: PhosphorIcon(PhosphorIconsRegular.sun),
                label: Text('Light'),
              ),
              Segment(
                value: 'dark',
                icon: PhosphorIcon(PhosphorIconsRegular.moon),
                label: Text('Dark'),
              ),
              Segment(
                value: 'system',
                icon: PhosphorIcon(PhosphorIconsRegular.desktop),
                label: Text('Auto'),
              ),
            ],
          ),
          const Gap.lg(),
          Row(
            children: [
              Text('Text size', style: theme.textTheme.small),
              const Spacer(),
              Text('110%', style: theme.textTheme.muted),
            ],
          ),
          const Gap.sm(),
          const Slider(initialValue: 62, max: 100),
        ],
      ),
    );
  }
}

class _Stay extends StatelessWidget {
  const _Stay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      title: const Text('Book a stay'),
      description: const Text('Three nights in June'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Calendar.range(
              initialMonth: DateTime(2025, 6),
              range: DateTimeRange(
                start: DateTime(2025, 6, 12),
                end: DateTime(2025, 6, 15),
              ),
              onRangeChanged: (_) {},
            ),
          ),
          const Gap.md(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r'$540', style: theme.textTheme.large),
                    Text('3 nights, 2 guests', style: theme.textTheme.caption),
                  ],
                ),
              ),
              Button(onPressed: () {}, child: const Text('Reserve')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      title: const Text('Your review'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Rating(value: 4, onChanged: (_) {}),
              const Gap.sm(),
              Text('Very good', style: theme.textTheme.muted),
            ],
          ),
          const Gap.lg(),
          ChipGroup<String>.multiple(
            values: const {'Quiet', 'Great view'},
            onValuesChanged: (_) {},
            showCheckmark: true,
            items: const [
              ChipGroupItem(value: 'Quiet', label: Text('Quiet')),
              ChipGroupItem(value: 'Great view', label: Text('Great view')),
              ChipGroupItem(value: 'Clean', label: Text('Clean')),
              ChipGroupItem(value: 'Friendly', label: Text('Friendly')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) {
    final overline = Theme.of(context).style.overline;
    return ListSection(
      header: Text(overline.applyCase('Notifications')),
      footer: const Text('Mentions are always delivered.'),
      children: [
        SwitchListTile(
          secondary: const PhosphorIcon(PhosphorIconsRegular.bell),
          title: const Text('Push notifications'),
          value: true,
          onChanged: (_) {},
        ),
        SwitchListTile(
          secondary: const PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
          title: const Text('Weekly digest'),
          subtitle: const Text('Every Monday morning'),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          leading: const PhosphorIcon(PhosphorIconsRegular.speakerHigh),
          title: const Text('Sound'),
          value: const Text('Chime'),
          showChevron: true,
          onTap: () {},
        ),
        ListTile(
          leading: const PhosphorIcon(PhosphorIconsRegular.moonStars),
          title: const Text('Quiet hours'),
          value: const Text('22:00'),
          showChevron: true,
          onTap: () {},
        ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      title: const Text('Share document'),
      description: const Text('Anyone with the link can view.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(
                  initialValue: 'orbit.example/d/8f2k',
                  readOnly: true,
                ),
              ),
              const Gap.sm(),
              IconButton.outline(
                icon: const PhosphorIcon(PhosphorIconsRegular.copy),
                onPressed: () {},
              ),
            ],
          ),
          const Gap.lg(),
          Text('People with access', style: theme.textTheme.small),
          const Gap.sm(),
          for (final (i, access) in const [(0, 'Owner'), (3, 'Can edit')])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  PersonAvatar(i, size: 32),
                  const Gap.sm(),
                  Expanded(
                    child: Text(
                      people[i].name,
                      style: theme.textTheme.small,
                    ),
                  ),
                  Text(access, style: theme.textTheme.muted),
                ],
              ),
            ),
          const Gap.md(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Button.secondary(onPressed: () {}, child: const Text('Cancel')),
              Button(
                onPressed: () {},
                leading: const PhosphorIcon(PhosphorIconsRegular.shareFat),
                child: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Verify extends StatelessWidget {
  const _Verify();

  @override
  Widget build(BuildContext context) {
    return Card(
      title: const Text('Check your inbox'),
      description: const Text('We sent a code to maya@orbit.example.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: OtpField(
              maxLength: 6,
              initialValue: '4281',
              children: [
                OtpFieldGroup(
                  children: [OtpFieldSlot(), OtpFieldSlot(), OtpFieldSlot()],
                ),
                PhosphorIcon(PhosphorIconsRegular.dotOutline),
                OtpFieldGroup(
                  children: [OtpFieldSlot(), OtpFieldSlot(), OtpFieldSlot()],
                ),
              ],
            ),
          ),
          const Gap.lg(),
          Button(onPressed: () {}, child: const Text('Verify')),
        ],
      ),
    );
  }
}

class _Goal extends StatelessWidget {
  const _Goal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Row(
        children: [
          ProgressRing(
            value: .72,
            size: 88,
            strokeWidth: 8,
            sweepAngle: math.pi * 1.5,
            child: Text(
              '72%',
              style: theme.textTheme.large.copyWith(
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
          const Gap.lg(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly goal', style: theme.textTheme.small),
                const SizedBox(height: 2),
                Text('18 of 25 tasks', style: theme.textTheme.muted),
                const Gap.sm(),
                Badge.secondary(
                  backgroundColor: theme.colorScheme.successMuted,
                  foregroundColor: theme.colorScheme.success,
                  child: const Text('On track'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toasts extends StatelessWidget {
  const _Toasts();

  @override
  Widget build(BuildContext context) {
    return UnaColumn(
      gap: GapSize.sm,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Toast(
          variant: ToastVariant.success,
          title: Text('Changes saved'),
          description: Text('Your profile is up to date.'),
        ),
        Toast(
          title: const Text('Message archived'),
          action: Button.outline(
            size: ButtonSize.sm,
            onPressed: () {},
            child: const Text('Undo'),
          ),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return const Alert(
      icon: PhosphorIcon(PhosphorIconsRegular.info),
      title: Text('Update available'),
      description: Text('Version 2.4 adds offline mode.'),
    );
  }
}

class _Format extends StatelessWidget {
  const _Format();

  @override
  Widget build(BuildContext context) {
    return Card(
      style: const CardTheme(padding: EdgeInsets.all(12)),
      child: Row(
        children: [
          ToggleGroup<String>.multiple(
            values: const {'bold', 'italic'},
            variant: ToggleVariant.outline,
            onValuesChanged: (_) {},
            items: const [
              ToggleGroupItem(
                value: 'bold',
                child: PhosphorIcon(PhosphorIconsRegular.textB),
              ),
              ToggleGroupItem(
                value: 'italic',
                child: PhosphorIcon(PhosphorIconsRegular.textItalic),
              ),
              ToggleGroupItem(
                value: 'underline',
                child: PhosphorIcon(PhosphorIconsRegular.textUnderline),
              ),
            ],
          ),
          const Spacer(),
          IconButton.ghost(
            icon: const PhosphorIcon(PhosphorIconsRegular.link),
            onPressed: () {},
          ),
          IconButton.ghost(
            icon: const PhosphorIcon(PhosphorIconsRegular.image),
            onPressed: () {},
          ),
          IconButton.ghost(
            icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Row(
        children: [
          Skeleton.circle(size: 40, animate: false),
          Gap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 160, height: 12),
                SizedBox(height: 10),
                Skeleton(width: 110, height: 12),
              ],
            ),
          ),
          Spinner(size: 18),
        ],
      ),
    );
  }
}

class _Pages extends StatelessWidget {
  const _Pages();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pagination(page: 2, pageCount: 3, onPageChanged: (_) {}),
    );
  }
}

class _Invite extends StatelessWidget {
  const _Invite();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Row(
        children: [
          AvatarGroup(
            size: 32,
            overlap: 6,
            children: [for (var i = 0; i < 5; i++) PersonAvatar(i, size: 32)],
          ),
          const Gap.sm(),
          Expanded(child: Text('+3 more', style: theme.textTheme.muted)),
          Button.outline(
            size: ButtonSize.sm,
            onPressed: () {},
            leading: const PhosphorIcon(PhosphorIconsRegular.userPlus),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}
