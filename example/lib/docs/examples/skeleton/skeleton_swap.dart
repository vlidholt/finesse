import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A placeholder stands in for exactly the row that replaces it, so the
/// page does not jump when the content arrives.
class SkeletonSwapExample extends StatefulWidget {
  const SkeletonSwapExample({super.key});

  @override
  State<SkeletonSwapExample> createState() => _SkeletonSwapExampleState();
}

class _SkeletonSwapExampleState extends State<SkeletonSwapExample> {
  var _loaded = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          SwitchListTile(
            value: _loaded,
            onChanged: (value) => setState(() => _loaded = value),
            title: const Text('Loaded'),
          ),
          if (_loaded)
            const ListTile(
              leading: Avatar(
                'assets/images/avatar_mei_tanaka.jpg',
                fallback: Text('MT'),
              ),
              title: Text('Mei Tanaka'),
              subtitle: Text('Shared three photos with you'),
            )
          else
            const SkeletonListTile(),
        ],
      ),
    );
  }
}
