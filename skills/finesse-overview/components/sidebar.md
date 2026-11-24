# Sidebar

A composable, collapsible side navigation panel. Collapses to an icon rail or off-canvas, floats or insets, and becomes a modal sheet under the mobile breakpoint. ⌘B toggles it.

## Icon rail

With collapsible: icon the sidebar shrinks to a rail of icons. Menu buttons show their label as a tooltip, and with rail: true the inner edge becomes a grab rail — click it to toggle. This docs app itself runs on SidebarScaffold.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SidebarBasicExample extends StatefulWidget {
  const SidebarBasicExample({super.key});

  @override
  State<SidebarBasicExample> createState() => _SidebarBasicExampleState();
}

class _SidebarBasicExampleState extends State<SidebarBasicExample> {
  String selected = 'Home';

  SidebarMenuButton item(String label, IconData icon) {
    return SidebarMenuButton(
      leading: Icon(icon),
      isActive: selected == label,
      tooltip: label,
      onPressed: () => setState(() => selected = label),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 700,
      height: 420,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.lg,
        ),
        child: SidebarScaffold(
          borderRadius: theme.radii.lg,
          sidebar: Sidebar(
            collapsible: SidebarCollapsible.icon,
            // The inner edge highlights under the pointer and toggles the
            // sidebar on click.
            rail: true,
            header: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: theme.radii.md,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.stack,
                    size: 16,
                    color: theme.colorScheme.primaryForeground,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Acme Inc',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: theme.textTheme.small,
                  ),
                ),
              ],
            ),
            footer: SidebarMenuButton(
              leading: const Icon(PhosphorIconsRegular.userCircle),
              trailing: const Icon(PhosphorIconsRegular.caretUpDown),
              tooltip: 'Account',
              onPressed: () {},
              child: const Text('Noor Haddad'),
            ),
            children: [
              SidebarGroup(
                label: const Text('Platform'),
                children: [
                  SidebarMenu(
                    children: [
                      item('Home', PhosphorIconsRegular.house),
                      item('Inbox', PhosphorIconsRegular.tray),
                      item('Calendar', PhosphorIconsRegular.calendarBlank),
                    ],
                  ),
                ],
              ),
              SidebarGroup(
                label: const Text('Settings'),
                children: [
                  SidebarMenu(
                    children: [
                      item('Profile', PhosphorIconsRegular.user),
                      item('Billing', PhosphorIconsRegular.creditCard),
                    ],
                  ),
                ],
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const SidebarTrigger(),
                    const SizedBox(width: 8),
                    Text(selected, style: theme.textTheme.small),
                  ],
                ),
              ),
              const Expanded(
                child: Center(child: Text('Content area')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Floating, with sub-menus

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SidebarSubmenuExample extends StatefulWidget {
  const SidebarSubmenuExample({super.key});

  @override
  State<SidebarSubmenuExample> createState() => _SidebarSubmenuExampleState();
}

class _SidebarSubmenuExampleState extends State<SidebarSubmenuExample> {
  String selected = 'Installation';

  static const _sections = {
    'Getting Started': ['Installation', 'Project Structure'],
    'Building Your Application': ['Routing', 'Data Fetching', 'Rendering'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 700,
      height: 420,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.lg,
        ),
        child: SidebarScaffold(
          borderRadius: theme.radii.lg,
          sidebar: Sidebar(
            variant: SidebarVariant.floating,
            children: [
              SidebarGroup(
                label: const Text('Documentation'),
                children: [
                  SidebarMenu(
                    children: [
                      for (final entry in _sections.entries) ...[
                        SidebarMenuButton(
                          leading: const Icon(PhosphorIconsRegular.bookOpen),
                          onPressed: () {},
                          child: Text(entry.key),
                        ),
                        SidebarMenuSub(
                          children: [
                            for (final page in entry.value)
                              SidebarMenuSubButton(
                                isActive: selected == page,
                                onPressed: () =>
                                    setState(() => selected = page),
                                child: Text(page),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          child: Center(child: Text(selected)),
        ),
      ),
    );
  }
}
```

