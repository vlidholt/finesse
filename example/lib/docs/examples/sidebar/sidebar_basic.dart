import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SidebarBasicExample extends StatefulWidget {
  const SidebarBasicExample({super.key});

  @override
  State<SidebarBasicExample> createState() => _SidebarBasicExampleState();
}

class _SidebarBasicExampleState extends State<SidebarBasicExample> {
  String selected = 'Home';

  SidebarMenuButton item(String label, IconData icon) {
    return SidebarMenuButton(
      leading: PhosphorIcon(icon),
      selected: selected == label,
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
                  child: PhosphorIcon(
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
              leading: const PhosphorIcon(PhosphorIconsRegular.userCircle),
              trailing: const PhosphorIcon(PhosphorIconsRegular.caretUpDown),
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
