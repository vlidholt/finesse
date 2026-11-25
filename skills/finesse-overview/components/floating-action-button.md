# Floating Action Button

A button that floats over the page for the screen's main action: compose, add, start. A pill with a label, a circle without. Give it to a `Scaffold`, which keeps it clear of the bars and the keyboard.

## Variants

`primary` is the one thing to do on this screen. `secondary` does not shout. `glass` is the same material as the floating bottom bar, for a button over photographs or a map. All three carry the bar's shadow.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The three variants, each with a label and without. Without a label the
/// button needs a `semanticLabel`.
class FloatingActionButtonBasicExample extends StatelessWidget {
  const FloatingActionButtonBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        for (final variant in FloatingActionButtonVariant.values)
          FinesseRow(
            mainAxisSize: MainAxisSize.min,
            gap: GapSize.lg,
            children: [
              FloatingActionButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
                label: const Text('Compose'),
                variant: variant,
                onPressed: () {},
              ),
              FloatingActionButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
                semanticLabel: 'Compose',
                variant: variant,
                onPressed: () {},
              ),
            ],
          ),
      ],
    );
  }
}
```

## Sizes

`small`, `regular` and `large` come from the theme and follow the form factor: 40, 48 and 64 on a desktop; 44, 56 and 72 on a phone.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Small, regular and large. Each is larger on a phone, where the button is
/// a touch target first.
class FloatingActionButtonSizesExample extends StatelessWidget {
  const FloatingActionButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        for (final size in FloatingActionButtonSize.values)
          FloatingActionButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.plus),
            semanticLabel: 'Add',
            size: size,
            onPressed: () {},
          ),
      ],
    );
  }
}
```

## Collapsing the label

`extended: false` collapses the button to its icon on the theme's surface spring; the label is still what a screen reader says. Here it follows the scroll direction. The scaffold keeps the button on its corner while it changes width.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';

/// `extended: !scrolledDown`. The label gives the content room while it is
/// being read and comes back when the reader turns round.
class FloatingActionButtonExtendedExample extends StatefulWidget {
  const FloatingActionButtonExtendedExample({super.key});

  @override
  State<FloatingActionButtonExtendedExample> createState() =>
      _FloatingActionButtonExtendedExampleState();
}

class _FloatingActionButtonExtendedExampleState
    extends State<FloatingActionButtonExtendedExample> {
  bool _extended = true;

  bool _onScroll(UserScrollNotification notification) {
    final extended = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _extended,
    };
    if (extended != _extended) setState(() => _extended = extended);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 460,
      child: Scaffold(
        appBar: const AppBar(title: Text('Inbox')),
        floatingActionButton: FloatingActionButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
          label: const Text('Compose'),
          extended: _extended,
          onPressed: () {},
        ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: _onScroll,
          child: ListView(
            children: [
              for (var i = 1; i <= 24; i++)
                ListTile(
                  title: Text('Message $i'),
                  subtitle: const Text('Scroll down, then back up'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## A menu of actions

There is no separate speed-dial widget: wrap the button in a `DropdownMenu` and anchor the menu above it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A menu of actions is a `DropdownMenu` anchored above the button.
class FloatingActionButtonMenuExample extends StatelessWidget {
  const FloatingActionButtonMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = Theme.of(context).layoutTheme.gap(GapSize.sm);
    return DropdownMenu(
      // The menu's bottom end corner on the button's top end corner.
      anchor: Anchor(
        childAlignment: AlignmentDirectional.topEnd,
        overlayAlignment: AlignmentDirectional.bottomEnd,
        offset: Offset(0, -gap),
      ),
      constraints: const BoxConstraints(minWidth: 200),
      items: const [
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.notePencil),
          child: Text('Post'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.image),
          child: Text('Photo'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.chartBar),
          child: Text('Poll'),
        ),
      ],
      builder: (context, controller, _) => FloatingActionButton(
        icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        label: const Text('Create'),
        onPressed: controller.toggle,
      ),
    );
  }
}
```

