import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// With `AppBarSurfaceBehavior.whenScrolled` the bar is bare while the page
/// is at its top. Scroll: its fill, hairline and blur fade in as content
/// goes under it.
class AppBarScrolledExample extends StatelessWidget {
  const AppBarScrolledExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      height: 420,
      child: Scaffold(
        appBar: const AppBar(
          title: Text('Journal'),
          surfaceBehavior: AppBarSurfaceBehavior.whenScrolled,
        ),
        body: PageContainer(
          scrollable: true,
          child: UnaColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            gap: GapSize.md,
            children: [
              for (final day in const ['Monday', 'Tuesday', 'Wednesday'])
                Card(
                  title: Text(day),
                  description: const Text('Three entries'),
                  child: Text(
                    'Walked the long way round the harbour before work. '
                    'The light was low and everything was quiet.',
                    style: theme.textTheme.small,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
