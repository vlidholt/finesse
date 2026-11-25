import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/button/button_gestures.dart';
import 'package:example/docs/examples/button/button_icon.dart';
import 'package:example/docs/examples/button/button_loading.dart';
import 'package:example/docs/examples/button/button_sizes.dart';
import 'package:example/docs/examples/button/button_style.dart';
import 'package:example/docs/examples/button/button_variants.dart';

final buttonDoc = ComponentDoc(
  slug: 'button',
  title: 'Button',
  description:
      'A label that does something when pressed. Six variants share one '
      'small API: pick the one matching the action\'s weight, and say '
      'anything else about its look with one `style` object. A button that '
      'holds only an icon is an `IconButton`.',
  examples: [
    ComponentExample(
      id: 'button_variants',
      title: 'Variants',
      description:
          'Primary for the main action, secondary and outline for '
          'everything else, destructive for irreversible actions, ghost for '
          'toolbars, and link for inline navigation. Pass `variant:` or use '
          'the named constructors.',
      builder: (_) => const ButtonVariantsExample(),
    ),
    ComponentExample(
      id: 'button_sizes',
      title: 'Sizes',
      builder: (_) => const ButtonSizesExample(),
    ),
    ComponentExample(
      id: 'button_icon',
      title: 'With icon',
      description: 'Use leading and trailing to place icons around the label.',
      builder: (_) => const ButtonIconExample(),
    ),
    ComponentExample(
      id: 'button_loading',
      title: 'Loading',
      description:
          '`loading: true` shows a spinner in the place of the leading '
          'widget, or over the label when there is none, without changing '
          'the size of the button. A loading button ignores presses, keeps '
          'the focus and is announced as busy; it is not dimmed like a '
          'disabled one.',
      builder: (_) => const ButtonLoadingExample(),
    ),
    ComponentExample(
      id: 'button_style',
      title: 'Restyling one button',
      description:
          'How a button looks comes from its variant\'s `ButtonTheme` in '
          'the theme. `style` takes the same object for one button and is '
          'merged over the variant\'s, so it only says what is different: '
          'colours for each state, padding, width and height, the '
          'decoration, the text style, the icon size. '
          '`theme.buttonDecoration(radius:)` reshapes a button and its '
          'focus ring together.',
      builder: (_) => const ButtonStyleExample(),
    ),
    ComponentExample(
      id: 'button_gestures',
      title: 'Other gestures',
      description:
          'A button answers a press, a long press and the keyboard. For a '
          'double tap, a secondary tap or anything rarer, put a '
          '`FinesseGestureDetector` around it: the button keeps its press.',
      builder: (_) => const ButtonGesturesExample(),
    ),
  ],
);
