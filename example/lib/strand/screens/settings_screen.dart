import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/settings_sections.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Strand's settings: a full-screen route the avatar menu's "Settings"
/// opens (`openSettings`), with four pages — Account, Privacy,
/// Notifications and Appearance.
///
/// * **Wide** — the pages as rows in a card beside the selected page's
///   cards.
/// * **Narrow, and a phone** — the pages as a strip of chips over them.
///
/// Light or dark, the text size and the theme editor button on the
/// Appearance page are real and drive the whole app. Everything else is a
/// mock preference held by the session's `SettingsController`, so the page
/// reads the same when it is opened again; nothing is persisted. It is
/// built from the package's form controls as they come.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Capped narrower than the app's pages: forms read badly across 1280.
  static const _maxWidth = 1040.0;
  static const _railWidth = 260.0;

  /// The content width from which the pages are a rail beside the cards.
  static const _railFrom = 760.0;

  static const _icons = {
    SettingsSection.account: PhosphorIconsRegular.userCircle,
    SettingsSection.privacy: PhosphorIconsRegular.lockSimple,
    SettingsSection.notifications: PhosphorIconsRegular.bell,
    SettingsSection.appearance: PhosphorIconsRegular.palette,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.strand.settings;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton.ghost(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          semanticLabel: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings'),
      ),
      body: PageContainer(
        scrollable: true,
        maxWidth: _maxWidth,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) {
              void select(SettingsSection section) =>
                  settings.update(() => settings.section = section);

              final page = SettingsSectionView(
                // A page's fields keep no state from another page's.
                key: ValueKey(settings.section),
                section: settings.section,
                settings: settings,
              );

              if (constraints.maxWidth >= _railFrom) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.layoutTheme.gap(GapSize.xl),
                  children: [
                    SizedBox(
                      width: _railWidth,
                      child: _SectionRail(
                        selected: settings.section,
                        onSelected: select,
                      ),
                    ),
                    Expanded(child: page),
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: homeLooseGap,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: homeTightGap,
                      children: [
                        for (final section in SettingsSection.values)
                          Chip(
                            leading: Icon(_icons[section]),
                            label: Text(section.label),
                            selected: section == settings.section,
                            onSelected: (_) => select(section),
                          ),
                      ],
                    ),
                  ),
                  page,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The pages as rows in a card: the Network screen's "Manage my network".
class _SectionRail extends StatelessWidget {
  const _SectionRail({required this.selected, required this.onSelected});

  final SettingsSection selected;
  final ValueChanged<SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in SettingsSection.values)
            Semantics(
              selected: section == selected,
              child: Button.raw(
                variant: section == selected
                    ? ButtonVariant.secondary
                    : ButtonVariant.ghost,
                // The home profile card's shortcut row.
                height: 38,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: homeSnugGap),
                gap: homeSnugGap,
                iconSize: 20,
                mainAxisAlignment: MainAxisAlignment.start,
                foregroundColor: section == selected
                    ? scheme.tint
                    : scheme.foregroundSubtle,
                leading: Icon(SettingsScreen._icons[section]),
                onPressed: () => onSelected(section),
                child: Expanded(
                  child: Text(
                    section.label,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
