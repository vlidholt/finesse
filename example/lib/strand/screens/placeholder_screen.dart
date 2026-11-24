import 'package:example/strand/navigation.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The page behind a destination the Strand designs do not cover — Network
/// and Notifications. It says so, and points at the rest of the example app.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, required this.icon, super.key});

  /// The destination's name.
  final String title;

  /// The destination's icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      alignment: Alignment.center,
      child: Empty(
        icon: Icon(icon),
        title: Text(title),
        description: Text(
          '$title is not part of the Strand designs, so there is nothing to '
          'show here. The component library and the theme editor are one tap '
          'away.',
        ),
        actions: [
          Button(
            leading: const Icon(PhosphorIconsRegular.squaresFour),
            onPressed: context.openComponentLibrary,
            child: const Text('Browse components'),
          ),
          Button.outline(
            leading: const Icon(PhosphorIconsRegular.paintBrush),
            onPressed: context.toggleThemeEditor,
            child: const Text('Open theme editor'),
          ),
        ],
      ),
    );
  }
}
