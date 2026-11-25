# Empty

A placeholder for an empty state: icon, title, description, and actions.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class EmptyBasicExample extends StatelessWidget {
  const EmptyBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      width: 400,
      height: 320,
      columnMainAxisSize: MainAxisSize.max,
      child: Empty(
        icon: const PhosphorIcon(PhosphorIconsRegular.tray),
        title: const Text('No messages'),
        description: const Text('Messages you receive will show up here.'),
        actions: [
          Button.outline(
            onPressed: () {},
            child: const Text('Refresh'),
          ),
          Button(
            onPressed: () {},
            child: const Text('Compose'),
          ),
        ],
      ),
    );
  }
}
```

## Loading, failed and empty

The three states a page shows in place of its content are each an `Empty`: a `Spinner` as the icon while it loads, a way to try again when it failed, a way forward when there is nothing yet.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

enum _State { loading, failed, empty }

/// The three states a page shows instead of its content — loading, failed
/// and empty — as one `Empty` each, faded from one to the next by a
/// `ContentSwitch`.
class EmptyStatesExample extends StatefulWidget {
  const EmptyStatesExample({super.key});

  @override
  State<EmptyStatesExample> createState() => _EmptyStatesExampleState();
}

class _EmptyStatesExampleState extends State<EmptyStatesExample> {
  _State _state = _State.loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: FinesseColumn(
        mainAxisSize: MainAxisSize.min,
        gap: GapSize.lg,
        children: [
          SegmentedControl<_State>(
            value: _state,
            onChanged: (state) => setState(() => _state = state),
            segments: const [
              Segment(value: _State.loading, label: Text('Loading')),
              Segment(value: _State.failed, label: Text('Failed')),
              Segment(value: _State.empty, label: Text('Empty')),
            ],
          ),
          SizedBox(
            height: 320,
            child: ContentSwitch(
              value: _state,
              direction: 0,
              child: switch (_state) {
                _State.loading => const Empty(
                  key: ValueKey(_State.loading),
                  icon: Spinner(),
                  title: Text('Loading your saved jobs'),
                ),
                _State.failed => Empty(
                  key: const ValueKey(_State.failed),
                  icon: const PhosphorIcon(PhosphorIconsRegular.cloudX),
                  title: const Text('Could not load your saved jobs'),
                  description: const Text(
                    'Check your connection and try again.',
                  ),
                  actions: [
                    Button.outline(
                      onPressed: () => setState(() => _state = _State.loading),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
                _State.empty => Empty(
                  key: const ValueKey(_State.empty),
                  icon: const PhosphorIcon(PhosphorIconsRegular.bookmarkSimple),
                  title: const Text('No saved jobs'),
                  description: const Text(
                    'Save a job to find it here later.',
                  ),
                  actions: [
                    Button(onPressed: () {}, child: const Text('Browse jobs')),
                  ],
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
```
