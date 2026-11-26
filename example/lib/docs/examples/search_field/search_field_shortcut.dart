import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SearchFieldShortcutExample extends StatelessWidget {
  const SearchFieldShortcutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: SearchField(
        // ⌘K on an Apple platform, Ctrl K elsewhere. Listen for the chord
        // with `SearchField.isSearchShortcut` where the app wants it.
        trailing: Kbd(SearchField.shortcutLabel),
      ),
    );
  }
}
