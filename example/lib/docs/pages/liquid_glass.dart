import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/liquid_glass/liquid_glass_bars.dart';
import 'package:example/docs/examples/liquid_glass/liquid_glass_controls.dart';

final liquidGlassDoc = ComponentDoc(
  slug: 'liquid_glass',
  title: 'Liquid Glass',
  description:
      "On iOS and macOS una draws its bars, its floating surfaces and its "
      "lens controls with Apple's Liquid Glass, through the "
      '`liquid_glass_widgets` package, and its own frosted glass everywhere '
      'else. Nothing in your code changes: the same widgets switch material.',
  body: (context) => DocProse(
    children: [
      const DocParagraph(
        'Liquid Glass bends and lights what is behind it instead of only '
        'blurring it. una uses it where Apple does: for the layer that '
        'floats over the content. Cards, list rows, fields and the buttons '
        'in your content stay as they are on every platform.',
      ),
      DocExample(
        slug: 'liquid_glass',
        example: ComponentExample(
          id: 'liquid_glass_controls',
          title: 'One switch for the material',
          description:
              '`ThemeData(liquidGlass: LiquidGlassTheme(mode: ...))`. '
              '`auto`, the default, is Liquid Glass on iOS and macOS — in a '
              'browser too — and frosted glass elsewhere; `always` and '
              '`never` decide for every platform.',
          minPreviewHeight: 420,
          builder: (_) => const LiquidGlassControlsExample(),
        ),
      ),
      const DocSection(
        title: 'What switches',
        children: [
          DocParagraph(
            'Navigation chrome: on a phone or a tablet, `AppBar` (no fill '
            'and no edge of its own: the page that scrolls under it is '
            'blurred more the nearer the top and faded into the page '
            'colour; a leading button and the actions on glass capsules, a '
            'logo bare). A desktop\'s top bar stays solid. The floating '
            '`BottomNavigationBar` and `NavigationScaffold`\'s bottom bar, '
            '`Toolbar`, `NavigationRail` and a glass `FloatingActionButton`. '
            'Floating surfaces: popovers, menus, a select\'s list, '
            '`Command` in a dialog, `Dialog`, `Sheet`, toasts and `Glass`. '
            'Lens controls, which are flat at rest and become a lens under '
            'the finger: `Switch`, `Slider` and `SegmentedControl`. '
            'Tooltips stay frosted: neither iOS nor macOS draws them in '
            'glass.',
          ),
          DocParagraph(
            'On a phone or a tablet a `DropdownMenu` morphs out of the button '
            'that opens it on a spring, and gathers back into it when it '
            'closes: the package\'s own menu, opened and closed by the '
            'una `PopoverController`. A desktop menu, a right-click or '
            'long-press menu and a submenu are una popovers on glass.',
          ),
          DocParagraph(
            'Each of those has a `liquidGlass` field on its component theme '
            'that decides for it alone, over the theme: '
            '`ThemeData(appBarTheme: AppBarTheme(liquidGlass: '
            'LiquidGlassMode.never))` keeps a frosted app bar in a Liquid '
            'Glass app.',
          ),
        ],
      ),
      DocExample(
        slug: 'liquid_glass',
        example: ComponentExample(
          id: 'liquid_glass_bars',
          title: 'The bars',
          description:
              'Scroll the list. The bottom bar\'s `action` floats beside '
              'the tabs on its own capsule — iOS 26\'s split bar — where a '
              'frosted bar puts it between them.',
          minPreviewHeight: 560,
          builder: (_) => const LiquidGlassBarsExample(),
        ),
      ),
      const DocSection(
        title: 'Setting it up',
        children: [
          DocParagraph(
            'Load the shaders before the first frame with '
            '`await LiquidGlass.initialize()` in `main()`, after '
            '`WidgetsFlutterBinding.ensureInitialized()`. Without it the '
            'first glass surfaces come in a frame or two late, and the '
            'package\'s progress messages reach the console. If the '
            'shaders fail to load, una draws its frosted glass instead '
            'for the life of the app.',
          ),
          DocParagraph(
            'The glass is tinted from your colour scheme\'s bar colour. '
            '`LiquidGlassTheme` passes the rest on to the package: `style` '
            '(`GlassStyle.ios27`, the default, or `ios26`), `quality` '
            '(`premium`, `standard` or `minimal`), `adaptiveQuality`, and '
            '`light` and `dark` `GlassThemeSettings` for any of its '
            'material settings — thickness, blur, refraction, light, rim.',
          ),
        ],
      ),
      const DocSection(
        title: 'Sizes',
        children: [
          DocParagraph(
            'The phone metrics of the `una` style are Liquid Glass\'s: '
            'a 44-point app bar, a 64-point tab bar, a 58 × 26 switch, '
            'popovers and dialogs with 24-point corners. A screen is laid '
            'out the same whether it is frosted or liquid, so switching '
            'material moves nothing. Desktop sizes, macOS included, are '
            'una\'s own.',
          ),
        ],
      ),
      const DocSection(
        title: 'Where it falls back',
        children: [
          DocParagraph(
            'The full material — refraction, chromatic edges, frost — needs '
            'Impeller\'s shader filters, which iOS, macOS and Android have. '
            'On the web and under Skia the package draws a lighter version '
            'of the same glass by itself: blur, rim and highlights without '
            'refraction, and a uniform blur where the top edge would be '
            'graduated. There a phone\'s top bar is solid instead: the bar '
            'colour with its hairline, no blur and no capsules. una '
            'gives menus, popovers and '
            'dialogs a stronger blur, a lighter body and a hairline edge, '
            'so they read over a white page and a busy one. When the system '
            'asks for more contrast, una '
            'draws its frosted glass instead '
            '(`LiquidGlassTheme.respectSystemAccessibility`).',
          ),
          DocParagraph(
            'To preview Liquid Glass anywhere, set the theme editor\'s '
            'Liquid Glass to On (`LiquidGlassMode.always`). Every component '
            'switches as it would on an iPhone, but a browser on any '
            'system, Windows and Linux draw the package\'s lighter tier: no '
            'refraction or chromatic edges. Android on Impeller draws the '
            'full material.',
          ),
          DocParagraph(
            'In widget tests `auto` resolves to frosted glass, because '
            'tests run as Android; set `debugDefaultTargetPlatformOverride` '
            'to `TargetPlatform.iOS` to test the Liquid Glass path. Do not '
            'call `LiquidGlass.initialize()` in a test.',
          ),
        ],
      ),
    ],
  ),
);
