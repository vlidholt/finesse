import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/motion/motion_entrance.dart';
import 'package:example/docs/examples/motion/motion_indicator.dart';
import 'package:example/docs/examples/motion/motion_press.dart';
import 'package:example/docs/examples/motion/motion_spring.dart';
import 'package:example/docs/examples/motion/motion_tokens.dart';

final motionDoc = ComponentDoc(
  slug: 'motion',
  title: 'Motion',
  description:
      'How things move. A style carries one motion vocabulary, a `Motion`: '
      'three durations, three curves and three springs that every component '
      'animates with. A handful of small widgets, the ones the components '
      'are built from, put it to work in your own.',
  body: (context) => DocProse(
    children: [
      const DocParagraph(
        'Anything that moves or scales rides a spring, a `MotionSpring`, '
        'described by how long it takes and how much it bounces. A spring '
        'keeps its velocity when its target changes, so a transition that '
        'is interrupted turns around where it is instead of jumping or '
        'starting again. Fades and colour changes use the short durations '
        'and curves. Read the vocabulary with `Motion.of(context)`: it '
        'returns the theme\'s motion, with the movement taken out when the '
        'platform asks for reduced motion.',
      ),
      DocExample(
        slug: 'motion',
        example: ComponentExample(
          id: 'motion_tokens',
          title: 'One vocabulary for everything',
          description:
              '`StyleTokens.fluid` moves with `Motion.lively`; the shadcn '
              'styles with the quieter `Motion.calm`. Pass `motion:` to '
              '`ThemeData` to replace it, or `Motion.none` to switch every '
              'transition off.',
          minPreviewHeight: 260,
          builder: (_) => const MotionTokensExample(),
        ),
      ),
      const DocSection(
        title: 'The tokens',
        children: [
          DocParagraph(
            '`fast`, `normal` and `slow` time fades and colour changes, '
            'with the curves `standard` (a change in place), `emphasized` '
            '(something arriving) and `exit` (something leaving). `snappy` '
            'is the spring of touch response and of selection indicators, '
            '`smooth` the spring of surfaces such as sheets and accordions, '
            'and `bouncy` the spring of small things: a switch thumb, a '
            'check mark, a badge. `pressScale` and `surfacePressScale` say '
            'how far a pressed control and a pressed card shrink, and '
            '`indicatorStretch` how far a travelling selection stretches. '
            'Change any of them with `Motion.lively.copyWith(...)`.',
          ),
          DocParagraph(
            'A component theme can still say otherwise. `TabsTheme` has an '
            '`indicatorSpring`, `ButtonTheme` a `pressScale` and a '
            '`transitionDuration`, `ProgressBarTheme` a `spring`. Left '
            'null, they follow the tokens.',
          ),
        ],
      ),
      DocExample(
        slug: 'motion',
        example: ComponentExample(
          id: 'motion_spring',
          title: 'SpringBuilder',
          description:
              'The spring-driven counterpart of `TweenAnimationBuilder`: '
              'the number handed to the builder follows `value`. Tap again '
              'before it arrives. For several values, or to hand the '
              'animation to a render object, use a `SpringController`.',
          builder: (_) => const MotionSpringExample(),
        ),
      ),
      DocExample(
        slug: 'motion',
        example: ComponentExample(
          id: 'motion_press',
          title: 'Press response and PopOnChange',
          description:
              'The touch response of a button. A `Pressable` has it built '
              'in — `pressScale` sets how far, and 1 switches it off — and '
              '`PressScale` gives it to a control built on something else. '
              'It is a paint-time transform: the control keeps its size '
              'and its place.',
          builder: (_) => const MotionPressExample(),
        ),
      ),
      DocExample(
        slug: 'motion',
        example: ComponentExample(
          id: 'motion_indicator',
          title: 'MovingIndicator',
          description:
              'The travelling selection of `Tabs`, `TabBar`, `ToggleGroup`, '
              'the navigation bars and the menubar. (The highlighted row '
              'of a menu, a `Select` or a `Command` does not travel: it '
              'follows the pointer and the arrow keys at once.) The '
              'indicator is painted, not laid out, so nothing is rebuilt '
              'while it moves.',
          builder: (_) => const MotionIndicatorExample(),
        ),
      ),
      DocExample(
        slug: 'motion',
        example: ComponentExample(
          id: 'motion_entrance',
          title: 'Entrance and PopIn',
          description:
              'For content that appears in response to the user. Wrap an '
              '`Alert` or an `Empty` in an `Entrance` where it should '
              'arrive; on their own they are simply there, so a page of '
              'them does not animate when it opens.',
          minPreviewHeight: 240,
          builder: (_) => const MotionEntranceExample(),
        ),
      ),
      const DocSection(
        title: 'Overlays and pages',
        children: [
          DocParagraph(
            'A `Popover`, a menu, a `Select` list, a date picker, a '
            '`Tooltip` and a `Dialog` all arrive the same way: a fade with a '
            'little growth out of the edge that faces what opened them — '
            '`overlayScale` and `overlayTravel` on the `snappy` spring — and '
            'they leave over `fast`, sooner than they came. The portal '
            'publishes that edge as a `MotionOrigin`, which the entrance '
            'reads. No component takes a duration, a curve or a list of '
            'effects of its own: to move something differently, give its '
            'subtree another `Motion` with `ThemeData(motion:)`, and '
            '`Motion.none` to show it at once. A menu of a `Menubar` or a '
            'tooltip that takes over from its neighbour only fades.',
          ),
          DocParagraph(
            '`UnaPageRoute` brings a page in on the same tokens: from '
            'the end side on a phone, a few pixels up on a desktop. For a '
            'transition of your own, `EntranceProgress` turns a route\'s '
            '`animation` into a spring on the way in and a straight line '
            'on the way out, without a jump when a page is popped while it '
            'is still arriving.',
          ),
        ],
      ),
      const DocSection(
        title: 'Reduced motion',
        children: [
          DocParagraph(
            'When `MediaQuery.disableAnimationsOf(context)` is true, '
            '`Motion.of(context)` returns the reduced vocabulary: springs '
            'arrive at once, nothing scales, stretches or travels, and what '
            'is left is a short plain fade. Every component and every '
            'widget on this page goes through it, so there is nothing to '
            'do per screen. A `Skeleton` stops shimmering altogether.',
          ),
        ],
      ),
    ],
  ),
);
