import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
                          leading: const PhosphorIcon(
                            PhosphorIconsRegular.bookOpen,
                          ),
                          onPressed: () {},
                          child: Text(entry.key),
                        ),
                        SidebarMenuSub(
                          children: [
                            for (final page in entry.value)
                              SidebarMenuSubButton(
                                selected: selected == page,
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
