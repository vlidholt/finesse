import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_backdrop.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_disabled.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_focusable.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_form_factor_builder.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_haptics.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_overlay_insets.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_pressable.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_roving_focus.dart';
import 'package:example/docs/examples/building_blocks/building_blocks_shadow_decoration.dart';

const _slug = 'building_blocks';

final buildingBlocksDoc = ComponentDoc(
  slug: _slug,
  title: 'Building Blocks',
  description:
      'The pieces the components are made of, exported for the control the '
      'library does not have: press and focus behaviour, the glass filter, '
      'shadows, haptics, and the two things a layout asks the theme and the '
      'screen.',
  body: (context) => DocProse(
    children: [
      const DocParagraph(
        'Reach for a component first. A `Chip`, a `ListTile` or a `Card` '
        'with `onTap` already behaves, looks and animates like the rest of '
        'the system. When none fits, build on these instead of on a bare '
        '`GestureDetector` and a `BoxDecoration`: they are where press '
        'feedback, focus rings, reduced motion, right-to-left and the '
        'theme are handled once.',
      ),
      DocTable(
        columns: const ['Building block', 'What it gives you'],
        rows: const [
          [
            '`Pressable`',
            'Tap, long press, keyboard activation, hover, focus, cursor, '
                'button semantics and the press scale, as a set of '
                '`WidgetState`s for a builder.',
          ],
          [
            '`Disabled`',
            'A subtree that takes no input, is dimmed and is skipped by '
                'Tab.',
          ],
          [
            '`Focusable`',
            'A focus node that rebuilds a builder when the focus comes '
                'or goes.',
          ],
          [
            '`RovingFocus`',
            'One Tab stop for a collection, with arrow keys, Home, End and '
                'type-to-select moving a highlight inside it.',
          ],
          [
            '`Backdrop`',
            'The blur and saturation behind glass, clipped, and free when '
                'there is nothing to filter.',
          ],
          [
            '`ShadowDecoration`',
            'A box shadow that stays outside its box, so a translucent '
                'fill is not washed grey.',
          ],
          [
            '`Haptics`',
            'A tick or a tap on a phone, silent on the desktop, the web '
                'and wherever the theme switches it off.',
          ],
          [
            '`OverlayInsets`',
            'How much of each screen edge the bars, footers and keyboard '
                'cover, for whatever floats above every screen.',
          ],
          [
            '`FormFactorBuilder`',
            'One layout for a phone and one for a desktop, chosen by the '
                'theme.',
          ],
        ],
      ),
      const DocSection(
        title: 'Pressable',
        children: [
          DocParagraph(
            '`Pressable` is the behaviour underneath the chips, list tiles, '
            'tabs and navigation bars. It paints nothing. It reports '
            '`WidgetState.hovered`, `pressed`, `focused`, `selected` and '
            '`disabled` to its `builder`, shrinks its content a little '
            'while it is held (the theme\'s `Motion.pressScale`; pass '
            '`pressScale: 1` for a row that should stay put), and is '
            'disabled when it has neither `onPressed` nor `onLongPress`.',
          ),
          DocParagraph(
            'Two companions draw the states. `AnimatedFill` cross-fades a '
            'fill and an outline the way two overlapping layers would, '
            'which a plain colour lerp between different alphas does not. '
            '`FocusRing` paints the theme\'s ring outside its child without '
            'taking space; keep it in the tree and switch `visible`, so '
            'the child keeps its state when the focus moves.',
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_pressable',
          title: 'A control of your own',
          description:
              'A like button: `selected` makes it a toggle for assistive '
              'technology, the builder picks a fill per state. Tab to it '
              'and press Space.',
          minPreviewHeight: 160,
          builder: (_) => const BuildingBlocksPressableExample(),
        ),
      ),
      const DocSection(
        title: 'Disabled',
        children: [
          DocParagraph(
            'Most controls take `enabled`. `Disabled` is for the group: '
            'a form section waiting on a switch, a toolbar while a save is '
            'in flight. While `enabled` is false the subtree absorbs '
            'pointers, is excluded from focus traversal and is drawn at '
            '`ThemeData.disabledOpacity` (or `disabledOpacity`). '
            '`showForbiddenCursor` adds the not-allowed cursor.',
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_disabled',
          title: 'A locked group',
          minPreviewHeight: 280,
          builder: (_) => const BuildingBlocksDisabledExample(),
        ),
      ),
      const DocSection(
        title: 'Focusable',
        children: [
          DocParagraph(
            '`Focusable` is a `Focus` with a `builder(context, focused, '
            'child)`. Use it for something that takes the keyboard without '
            'being a button: a meter, a canvas, a custom editor. '
            '`onKeyEvent` handles the keys while it has the focus, and '
            '`child` is passed through so the part that does not depend on '
            'the focus is built once. For anything that is pressed, use '
            '`Pressable`, which includes this.',
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_focusable',
          title: 'Keys while focused',
          description:
              'Tab to a meter; Up and Down change its level. Tab moves on '
              'to the next one.',
          minPreviewHeight: 200,
          builder: (_) => const BuildingBlocksFocusableExample(),
        ),
      ),
      const DocSection(
        title: 'RovingFocus',
        children: [
          DocParagraph(
            'A toolbar of twelve buttons should not take twelve presses of '
            'Tab to cross. `RovingFocus` makes a collection one Tab stop: '
            'the arrow keys (mirrored in a right-to-left layout), Home and '
            'End move a highlight held by a `RovingFocusController`, Enter '
            'or Space call `onActivate`, and `typeaheadLabelAt` lets a '
            'typed letter jump to an item. It interprets keys and nothing '
            'else: drawing the highlight is the caller\'s part. The command '
            'palette is built on it.',
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_roving_focus',
          title: 'One Tab stop',
          description:
              'Click a size or Tab into the row, then use the arrow keys '
              'and Enter. Typing "L" jumps to Large.',
          minPreviewHeight: 160,
          builder: (_) => const BuildingBlocksRovingFocusExample(),
        ),
      ),
      const DocSection(
        title: 'Backdrop',
        children: [
          DocParagraph(
            '`Backdrop` builds the filter behind every glass surface: a '
            'Gaussian blur (the same number CSS takes in '
            '`backdrop-filter: blur()`) composed with a saturation, clipped '
            'to `borderRadius`. With a blur of 0 and a saturation of 1 it '
            'returns its child untouched, so an opaque style pays for no '
            'layer. Use `Glass` when you want the theme\'s tint, hairline '
            'and opacity with it; use `Backdrop` when the tint is your own.',
          ),
          DocBullets(
            items: [
              'A backdrop filter is a compositing layer that is paid for on '
                  'every frame something moves behind it. A handful on '
                  'screen is fine; one per row of a list is not.',
              'Paint a shadow outside the `Backdrop` and after it. A '
                  'filter samples whatever was painted before it, so a '
                  'shadow drawn first is blurred back into the glass.',
              'Do not fade glass with an `Opacity` around it: the filter '
                  'samples an empty layer while it fades. `Popover`, '
                  '`Tooltip` and dialogs fade their glass from the inside.',
            ],
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_backdrop',
          title: 'A filter and a tint',
          minPreviewHeight: 340,
          builder: (_) => const BuildingBlocksBackdropExample(),
        ),
      ),
      const DocSection(
        title: 'ShadowDecoration',
        children: [
          DocParagraph(
            'CSS clips a box shadow to the outside of its box. Flutter\'s '
            '`BoxDecoration.boxShadow` paints it behind the whole box, '
            'which nobody notices under an opaque fill and which turns a '
            'translucent one grey. `ShadowDecoration.box` takes the '
            'arguments of a `BoxDecoration`, with `shadows` in place of '
            '`boxShadow`, and paints the shadow outside the shape only. '
            'Every surface in the package draws its shadow this way; '
            '`Glass`, `Card` and `Surface` do it for you.',
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_shadow_decoration',
          title: 'The same shadow, twice',
          minPreviewHeight: 240,
          builder: (_) => const BuildingBlocksShadowDecorationExample(),
        ),
      ),
      const DocSection(
        title: 'Haptics',
        children: [
          DocParagraph(
            'The controls that tick on a phone, the wheel, a slider\'s '
            'stops and ends, a switch, a segment under a sliding finger, '
            'the board, all ask through `Haptics`. Call it from your own '
            'controls and they follow the same three rules: only Android '
            'and iOS tick, never the web or the desktop; '
            '`ThemeData(haptics: false)` silences everything below that '
            'theme; and a widget test hears nothing unless it sets '
            '`Haptics.debugEnabledInTests`.',
          ),
          CodeBlock(
            code: '''
// A value changing under the finger.
Haptics.selection(context);

// Something that happened once: put down (light, the default),
// picked up or armed (medium).
Haptics.impact(context);
Haptics.impact(context, HapticImpact.medium);

// Off for the whole app.
FinesseApp(theme: ThemeData(haptics: false), home: const Home());''',
          ),
          DocParagraph(
            '`Haptics` does not know what kind of pointer caused a change. '
            'A control that a mouse or the keyboard can also drive asks '
            'only for a finger\'s changes: remember the `PointerDeviceKind` '
            'of the drag and call it when that was `touch`.',
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_haptics',
          title: 'Ticks and taps',
          description:
              'Open this page on a phone to feel them. The switch re-themes '
              'the group with `haptics: false`.',
          minPreviewHeight: 220,
          builder: (_) => const BuildingBlocksHapticsExample(),
        ),
      ),
      const DocSection(
        title: 'OverlayInsets',
        children: [
          DocParagraph(
            'A `Scaffold` reports what it puts at the edges of the screen: '
            'its bars, footer, floating action button and the keyboard '
            'under it. An `OverlayInsetsScope` collects the reports, and '
            'whatever floats over every screen reads them to stay clear. '
            'The `Toaster` in `FinesseApp` is a scope and a reader already, '
            'which is how a toast rises above a bottom bar. You need a '
            'scope of your own only for something else that floats: a '
            'mini player, an offline banner, a chat bubble.',
          ),
          DocBullets(
            items: [
              '`OverlayInsets.watch(context)` returns the insets and '
                  'rebuilds when they change.',
              '`OverlayInsets.maybeOf(context)` returns the registry '
                  'without subscribing; it is a `Listenable`.',
              'A widget that covers an edge itself calls `report(owner, '
                  'insets)` after the frame and `remove(owner)` when it '
                  'goes.',
            ],
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_overlay_insets',
          title: 'Staying clear of the footer',
          minPreviewHeight: 480,
          builder: (_) => const BuildingBlocksOverlayInsetsExample(),
        ),
      ),
      const DocSection(
        title: 'FormFactorBuilder',
        children: [
          DocParagraph(
            'Sizes follow the form factor by themselves, through the '
            'component themes and the gap scale. `FormFactorBuilder` is '
            'for the screen that is arranged differently on a phone: a '
            'list beside its detail on a desktop, one after the other on a '
            'phone. It reads `Theme.of(context).formFactor`, never the '
            'window width, so it follows a pinned form factor and a '
            're-themed subtree. See Form Factors for where the value comes '
            'from.',
          ),
        ],
      ),
      DocExample(
        slug: _slug,
        example: ComponentExample(
          id: 'building_blocks_form_factor_builder',
          title: 'Two arrangements',
          minPreviewHeight: 320,
          builder: (_) => const BuildingBlocksFormFactorBuilderExample(),
        ),
      ),
    ],
  ),
);
