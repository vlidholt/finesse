import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

import '../frames.dart';
import '../harness.dart';
import 'common.dart';

/// The size of the form-factor image.
const formFactorsSize = Size(1600, 1030);

/// One screen, built once, in a desktop window and on a phone.
class FormFactorsScene extends StatelessWidget {
  /// Creates the image.
  const FormFactorsScene({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = imageTheme();
    const caption = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: Color(0xFF4A5B5A),
    );
    return Aurora(
      base: const Color(0xFFF1F5F4),
      glows: const [
        (Color(0xFFBFE6DF), Alignment.topLeft, .5),
        (Color(0xFFD8DEFF), Alignment(1.1, .2), .45),
        (Color(0xFFFFE3D2), Alignment(-.3, 1.3), .35),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 48, 56, 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DesktopWindow(
                    theme: theme,
                    title: 'Settings',
                    size: const Size(1026, 650),
                    child: const SettingsScreen(),
                  ),
                  const SizedBox(height: 22),
                  const SceneLabel('Desktop'),
                  const SizedBox(height: 2),
                  const Text(
                    '36-point controls, 14-point text, a top navigation bar',
                    style: caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhoneFrame(theme: theme, child: const SettingsScreen()),
                const SizedBox(height: 22),
                const SceneLabel('Phone'),
                const SizedBox(height: 2),
                const Text(
                  '44-point controls, 15-point text, a floating tab bar',
                  style: caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A settings screen. The same widget in both frames: only the theme's
/// form factor differs.
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overline = theme.style.overline;
    final mobile = theme.formFactor == FormFactor.mobile;

    final profile = Card(
      child: Row(
        children: [
          const PersonAvatar(0, size: 48),
          const Gap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  people[0].name,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('maya@orbit.example', style: theme.textTheme.muted),
              ],
            ),
          ),
          Button.outline(onPressed: () {}, child: const Text('Edit')),
        ],
      ),
    );

    final account = ListSection(
      header: Text(overline.applyCase('Account')),
      children: [
        ListTile(
          leading: const PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
          title: const Text('Email'),
          value: const Text('Verified'),
          showChevron: true,
          onTap: () {},
        ),
        ListTile(
          leading: const PhosphorIcon(PhosphorIconsRegular.password),
          title: const Text('Password'),
          showChevron: true,
          onTap: () {},
        ),
        SwitchListTile(
          secondary: const PhosphorIcon(PhosphorIconsRegular.shieldCheck),
          title: const Text('Two-factor'),
          value: true,
          onChanged: (_) {},
        ),
      ],
    );

    final preferences = ListSection(
      header: Text(overline.applyCase('Preferences')),
      children: [
        ListTile(
          leading: const PhosphorIcon(PhosphorIconsRegular.globe),
          title: const Text('Language'),
          value: const Text('English'),
          showChevron: true,
          onTap: () {},
        ),
        SwitchListTile(
          secondary: const PhosphorIcon(PhosphorIconsRegular.bell),
          title: const Text('Notifications'),
          value: true,
          onChanged: (_) {},
        ),
        SwitchListTile(
          secondary: const PhosphorIcon(PhosphorIconsRegular.moon),
          title: const Text('Dark mode'),
          value: false,
          onChanged: (_) {},
        ),
      ],
    );

    final devices = ListSection(
      header: Text(overline.applyCase('Signed in on')),
      children: [
        const ListTile(
          leading: PhosphorIcon(PhosphorIconsRegular.laptop),
          title: Text('MacBook Pro'),
          subtitle: Text('This device'),
          trailing: Badge.secondary(child: Text('Active')),
        ),
        ListTile(
          leading: const PhosphorIcon(PhosphorIconsRegular.deviceMobile),
          title: const Text('iPhone'),
          subtitle: const Text('2 hours ago'),
          showChevron: true,
          onTap: () {},
        ),
      ],
    );

    final body = PageContainer(
      scrollable: true,
      child: FinesseColumn(
        gap: GapSize.lg,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!mobile) Text('Settings', style: theme.textTheme.h3),
          profile,
          // Rearranged on a desktop, stacked on a phone; every size comes
          // from the theme either way.
          if (mobile) ...[
            account,
            preferences,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: account),
                const Gap.lg(),
                Expanded(child: preferences),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: Text('Theme', style: theme.textTheme.small),
              ),
              SegmentedControl<String>(
                value: 'auto',
                onChanged: (_) {},
                segments: const [
                  Segment(value: 'light', label: Text('Light')),
                  Segment(value: 'dark', label: Text('Dark')),
                  Segment(value: 'auto', label: Text('Auto')),
                ],
              ),
            ],
          ),
          devices,
        ],
      ),
    );

    return NavigationScaffold(
      selectedIndex: 3,
      onDestinationSelected: (_) {},
      leading: const LogoMark(size: 28),
      title: const Text('Orbit'),
      actions: [
        IconButton.ghost(
          icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
          onPressed: () {},
        ),
        const PersonAvatar(0, size: 28),
      ],
      mobileActions: [
        IconButton.ghost(
          icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
          onPressed: () {},
        ),
      ],
      destinations: const [
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.house),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
          label: 'Home',
        ),
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.kanban),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.kanban),
          label: 'Projects',
        ),
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
          label: 'Inbox',
          badgeCount: 3,
        ),
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.gear),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.gear),
          label: 'Settings',
        ),
      ],
      body: body,
    );
  }
}
