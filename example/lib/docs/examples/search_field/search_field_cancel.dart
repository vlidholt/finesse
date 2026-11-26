import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SearchFieldCancelExample extends StatelessWidget {
  const SearchFieldCancelExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      // The phone pattern: focus the field and "Cancel" slides in beside
      // it. It clears the field and puts the keyboard away.
      child: const SearchField(
        placeholder: Text('Search messages'),
        showCancel: true,
      ),
    );
  }
}
