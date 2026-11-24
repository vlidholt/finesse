import 'package:example/strand/widgets/user_menu.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

// TODO(strand): built by the profile screen agent. This file is a stub;
// replace its body and keep the class name, which `strand_shell.dart` builds.
//
// Keep a `UserMenu` on the page: on a phone the shell shows no app bar over
// the profile (the design's cover photo runs to the top of the screen), so
// this screen's "More options" button is how the component library and the
// theme editor are reached from Strand.

/// The Profile destination of the Strand shell.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PageContainer(
      scrollable: true,
      child: FinesseColumn(
        gap: GapSize.sm,
        // Stretch: a PageContainer centres a child narrower than the page.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FinesseRow(
            gap: GapSize.sm,
            children: [
              Expanded(child: Text('Profile', style: theme.textTheme.h3)),
              UserMenu(
                showProfile: false,
                builder: (context, controller, _) => IconButton.ghost(
                  icon: const Icon(PhosphorIconsRegular.dotsThree),
                  semanticLabel: 'More options',
                  onPressed: controller.toggle,
                ),
              ),
            ],
          ),
          Text(
            'This screen has not been built yet.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
