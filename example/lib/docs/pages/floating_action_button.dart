import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/floating_action_button/floating_action_button_basic.dart';
import 'package:example/docs/examples/floating_action_button/floating_action_button_extended.dart';
import 'package:example/docs/examples/floating_action_button/floating_action_button_menu.dart';
import 'package:example/docs/examples/floating_action_button/floating_action_button_sizes.dart';
import 'package:flutter/widgets.dart';

final floatingActionButtonDoc = ComponentDoc(
  slug: 'floating_action_button',
  title: 'Floating Action Button',
  description:
      'A button that floats over the page for the screen\'s main action: '
      'compose, add, start. A pill with a label, a circle without. Give it '
      'to a `Scaffold`, which keeps it clear of the bars and the keyboard.',
  examples: [
    ComponentExample(
      id: 'floating_action_button_basic',
      title: 'Variants',
      description:
          '`primary` is the one thing to do on this screen. `secondary` '
          'does not shout. `glass` is the same material as the floating '
          'bottom bar, for a button over photographs or a map. All three '
          'carry the bar\'s shadow.',
      minPreviewHeight: 300,
      builder: (_) => const FloatingActionButtonBasicExample(),
    ),
    ComponentExample(
      id: 'floating_action_button_sizes',
      title: 'Sizes',
      description:
          '`small`, `regular` and `large` come from the theme and follow '
          'the form factor: 40, 48 and 64 on a desktop; 44, 56 and 72 on a '
          'phone.',
      builder: (_) => const FloatingActionButtonSizesExample(),
    ),
    ComponentExample(
      id: 'floating_action_button_extended',
      title: 'Collapsing the label',
      description:
          '`extended: false` collapses the button to its icon on the '
          'theme\'s surface spring; the label is still what a screen '
          'reader says. Here it follows the scroll direction. The scaffold '
          'keeps the button on its corner while it changes width.',
      minPreviewHeight: 520,
      padding: const EdgeInsets.all(24),
      builder: (_) => const FloatingActionButtonExtendedExample(),
    ),
    ComponentExample(
      id: 'floating_action_button_menu',
      title: 'A menu of actions',
      description:
          'There is no separate speed-dial widget: wrap the button in a '
          '`DropdownMenu` and anchor the menu above it.',
      minPreviewHeight: 300,
      builder: (_) => const FloatingActionButtonMenuExample(),
    ),
  ],
);
