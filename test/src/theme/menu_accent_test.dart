import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// `ThemeData.menuAccent` is a *menu* option.
///
/// It used to be applied as shadcn applies it — the scheme's accent pair
/// rewritten with its primary pair before anything was derived — and in
/// this package the accent is far more than a menu colour: it is the soft
/// wash of a selected card, chip or list tile, an incoming chat bubble, an
/// icon tile, the selected tab of the bottom bar. Under a bold menu accent
/// all of those turned into primary-coloured slabs with dark ink on them.
/// The choice is carried by the variant now and read only where menu
/// colours are derived.
void main() {
  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + .05) / (lo + .05);
  }

  Color over(Color color, Color backdrop) => Color.alphaBlend(color, backdrop);

  const palettes = <String, (ColorScheme light, ColorScheme dark)>{
    'blue': (BlueColorScheme.light(), BlueColorScheme.dark()),
    'neutral': (NeutralColorScheme.light(), NeutralColorScheme.dark()),
    'zinc': (ZincColorScheme.light(), ZincColorScheme.dark()),
    'stone': (StoneColorScheme.light(), StoneColorScheme.dark()),
  };
  const styles = [
    StyleTokens.una,
    StyleTokens.nova,
    StyleTokens.maia,
    StyleTokens.lyra,
  ];

  /// Every menu option, in every style, palette and brightness.
  void forEveryMode(
    void Function(
      String where, {
      required ThemeData theme,
      required ThemeData subtle,
      required ColorScheme menuScheme,
      required MenuAccent accent,
      required bool? translucent,
      required bool inverted,
    })
    body,
  ) {
    for (final style in styles) {
      for (final MapEntry(key: name, value: pair) in palettes.entries) {
        for (final brightness in Brightness.values) {
          final dark = brightness == Brightness.dark;
          final scheme = dark ? pair.$2 : pair.$1;
          final other = dark ? pair.$1 : pair.$2;
          for (final translucent in [null, true, false]) {
            for (final inverted in [false, true]) {
              ThemeData build(MenuAccent accent) => ThemeData(
                colorScheme: scheme,
                style: style,
                menuAccent: accent,
                menuTranslucent: translucent,
                menuColorScheme: inverted ? other : null,
              );
              final subtle = build(MenuAccent.subtle);
              for (final accent in MenuAccent.values) {
                body(
                  '${style.name} $name ${brightness.name} ${accent.name} '
                  'translucent=$translucent inverted=$inverted',
                  theme: accent == MenuAccent.subtle ? subtle : build(accent),
                  subtle: subtle,
                  menuScheme: inverted ? other : scheme,
                  accent: accent,
                  translucent: translucent,
                  inverted: inverted,
                );
              }
            }
          }
        }
      }
    }
  }

  test('in every mode a menu has a visible, legible highlight', () {
    forEveryMode((
      where, {
      required theme,
      required subtle,
      required menuScheme,
      required accent,
      required translucent,
      required inverted,
    }) {
      final menu = theme.contextMenuTheme;
      final option = theme.selectOptionTheme;
      final page = theme.colorScheme.background;
      final surface = over(menu.decoration!.color!, page);
      final fill = menu.selectedBackgroundColor!;
      final highlight = over(fill, surface);
      final ink = menu.selectedTextStyle!.color!;

      // A resting row reads.
      expect(
        contrast(menu.textStyle!.color!, surface),
        greaterThanOrEqualTo(4.5),
        reason: 'resting row: $where',
      );
      // The highlighted row's text reads on its highlight. shadcn's 70%
      // finish, on a menu of the other brightness than the page it is
      // over, is held to large-text contrast: half of what is behind the
      // text is then the wrong page.
      expect(
        contrast(ink, highlight),
        greaterThanOrEqualTo(translucent == true && inverted ? 3 : 4.5),
        reason: 'highlighted row: $where',
      );

      // The highlight is told from the surface: a wash by its fill, a
      // filled row by its fill and by its text changing colour with it.
      final washed = fill.a < 1;
      expect(
        contrast(highlight, surface),
        greaterThan(washed || accent == MenuAccent.subtle ? 1.08 : 1.4),
        reason: 'highlight invisible: $where',
      );

      // Bold is a filled row in the *menu* palette's primary pair — except
      // under shadcn's translucent finish, which washes whatever the
      // accent.
      if (accent == MenuAccent.bold && translucent != true) {
        expect(fill, menuScheme.primary, reason: where);
        expect(ink, menuScheme.primaryForeground, reason: where);
        expect(ink, isNot(menu.textStyle!.color), reason: where);
        expect(
          fill,
          isNot(subtle.contextMenuTheme.selectedBackgroundColor),
          reason: 'bold changes nothing: $where',
        );
      } else if (translucent == true) {
        expect(fill, menuScheme.foreground.withValues(alpha: .1));
        expect(fill, subtle.contextMenuTheme.selectedBackgroundColor);
      }

      // A select's options use the same pair as a menu's rows, icons
      // included, so a menu cannot change colour halfway down.
      expect(option.hoveredBackgroundColor, fill, reason: where);
      expect(option.selectedTextStyle!.color, ink, reason: where);
      expect(option.selectedHoveredIconColor, ink, reason: where);
      expect(menu.selectedTrailingTextStyle!.color, isNotNull);
      expect(
        contrast(menu.selectedTrailingTextStyle!.color!, highlight),
        greaterThanOrEqualTo(3),
        reason: 'highlighted shortcut: $where',
      );
    });
  });

  test('in every mode, what is not a menu keeps the soft accent', () {
    forEveryMode((
      where, {
      required theme,
      required subtle,
      required menuScheme,
      required accent,
      required translucent,
      required inverted,
    }) {
      final scheme = theme.colorScheme;
      // The scheme an app reads is the one it gave.
      expect(scheme, subtle.colorScheme, reason: where);
      expect(scheme.accent, isNot(scheme.primary), reason: where);

      // An incoming chat bubble.
      final chat = theme.chatBubbleTheme;
      expect(chat, subtle.chatBubbleTheme, reason: where);
      expect(
        contrast(
          chat.incomingForegroundColor!,
          over(chat.incomingColor!, scheme.background),
        ),
        greaterThanOrEqualTo(4.5),
        reason: 'chat bubble: $where',
      );

      // A selected card, which reads the scheme itself.
      expect(theme.cardTheme, subtle.cardTheme, reason: where);
      expect(
        contrast(scheme.cardForeground, over(scheme.accent, scheme.card)),
        greaterThanOrEqualTo(4.5),
        reason: 'selected card: $where',
      );

      // An icon tile: the tint on the accent.
      final tile = theme.iconTileTheme;
      expect(tile, subtle.iconTileTheme, reason: where);
      expect(tile.backgroundColor, scheme.accent, reason: where);
      expect(
        contrast(tile.foregroundColor!, over(scheme.accent, scheme.card)),
        greaterThanOrEqualTo(4.5),
        reason: 'icon tile: $where',
      );

      // A selected chip.
      final chip = theme.chipTheme;
      expect(chip, subtle.chipTheme, reason: where);
      expect(chip.selectedBackgroundColor, scheme.accent, reason: where);
      expect(
        contrast(
          chip.selectedForegroundColor!,
          over(chip.selectedBackgroundColor!, scheme.card),
        ),
        greaterThanOrEqualTo(4.5),
        reason: 'selected chip: $where',
      );

      // And the rest of what draws with the accent.
      expect(theme.listTileTheme, subtle.listTileTheme, reason: where);
      expect(
        theme.bottomNavigationBarTheme,
        subtle.bottomNavigationBarTheme,
        reason: where,
      );
      expect(theme.navigationBarTheme, subtle.navigationBarTheme);
      expect(theme.sidebarTheme, subtle.sidebarTheme, reason: where);
      expect(theme.toggleTheme, subtle.toggleTheme, reason: where);
      expect(theme.calendarTheme, subtle.calendarTheme, reason: where);
      expect(theme.tabsTheme, subtle.tabsTheme, reason: where);
      expect(
        theme.defaultKeyboardToolbarTheme,
        subtle.defaultKeyboardToolbarTheme,
        reason: where,
      );
      // The menubar's strip is not a menu row either: its triggers
      // highlight with the muted surface.
      expect(theme.menubarTheme, subtle.menubarTheme, reason: where);
    });
  });

  test('the command palette highlights as before: a wash in a style that '
      'washes, muted otherwise and under a bold accent', () {
    for (final style in styles) {
      for (final brightness in Brightness.values) {
        final subtle = ThemeData(brightness: brightness, style: style);
        final bold = ThemeData(
          brightness: brightness,
          style: style,
          menuAccent: MenuAccent.bold,
        );
        final scheme = subtle.colorScheme;
        final wash = brightness == Brightness.dark
            ? style.menuHighlightOpacityDark ?? style.menuHighlightOpacity
            : style.menuHighlightOpacity;
        expect(
          subtle.commandTheme.itemSelectedBackgroundColor,
          wash == null
              ? scheme.muted
              : scheme.foreground.withValues(alpha: wash),
          reason: '${style.name} $brightness',
        );
        expect(bold.commandTheme.itemSelectedBackgroundColor, scheme.muted);
        expect(
          bold.commandTheme.itemSelectedForegroundColor,
          scheme.foreground,
        );
      }
    }
  });

  group('the choice is part of the theme', () {
    test('by value: equal when equal, different when not, and nothing but '
        'the menus differs', () {
      for (final secondary in [false, true]) {
        ThemeData build(MenuAccent? accent) => ThemeData(
          menuAccent: accent,
          style: StyleTokens.nova,
          disableSecondaryBorder: secondary,
        );
        final bold = build(MenuAccent.bold);
        expect(bold, build(MenuAccent.bold));
        expect(bold.hashCode, build(MenuAccent.bold).hashCode);
        expect(bold, isNot(build(MenuAccent.subtle)));
        // Null is subtle.
        expect(build(null), build(MenuAccent.subtle));
        expect(bold.colorScheme, build(null).colorScheme);
        expect(
          (bold.variant as DefaultThemeVariant).menuAccent,
          MenuAccent.bold,
        );
        expect(
          bold.variant,
          isNot(build(MenuAccent.subtle).variant),
        );
      }
    });

    test('copyWith sets it, and keeps it through an unrelated copy', () {
      final subtle = ThemeData(style: StyleTokens.nova);
      final bold = subtle.copyWith(menuAccent: MenuAccent.bold);
      final primary = subtle.colorScheme.primary;
      expect(bold, ThemeData(style: StyleTokens.nova, menuAccent: .bold));
      expect(bold.contextMenuTheme.selectedBackgroundColor, primary);

      // Through a copy that rebuilds the variant, one that does not, a
      // change of form factor and a change of style.
      for (final copy in [
        bold.copyWith(radius: BorderRadius.circular(2)),
        bold.copyWith(disabledOpacity: .3),
        bold.copyWith(),
        bold.withFormFactor(FormFactor.mobile),
        bold.copyWith(style: StyleTokens.maia),
        bold.copyWith(disableSecondaryBorder: true),
        bold.copyWith(menuTranslucent: false),
      ]) {
        expect(copy.contextMenuTheme.selectedBackgroundColor, primary);
        expect(copy.selectOptionTheme.hoveredBackgroundColor, primary);
        expect(copy.colorScheme.accent, subtle.colorScheme.accent);
      }
      // A new scheme: the new scheme's primary, and its own accent kept.
      const zinc = ZincColorScheme.dark();
      final recoloured = bold.copyWith(colorScheme: zinc);
      expect(recoloured.contextMenuTheme.selectedBackgroundColor, zinc.primary);
      expect(recoloured.colorScheme, zinc);

      // And back.
      final back = bold.copyWith(menuAccent: MenuAccent.subtle);
      expect(back, subtle);
      expect(
        back.contextMenuTheme.selectedBackgroundColor,
        subtle.colorScheme.accent,
      );
    });

    test('a variant carries it: through rebuild, and into a theme built '
        'from the variant', () {
      for (final variant in [
        DefaultThemeVariant(
          colorScheme: const NeutralColorScheme.light(),
          radius: BorderRadius.circular(8),
          effectiveTextTheme: DefaultThemeVariant.defaultTextTheme,
          style: StyleTokens.nova,
          menuAccent: MenuAccent.bold,
        ),
        DefaultThemeNoSecondaryBorderVariant(
          colorScheme: const NeutralColorScheme.light(),
          radius: BorderRadius.circular(8),
          effectiveTextTheme: DefaultThemeVariant.defaultTextTheme,
          style: StyleTokens.nova,
          menuAccent: MenuAccent.bold,
        ),
      ]) {
        const primary = NeutralColorScheme.light();
        expect(variant.menuItemHighlight, primary.primary);
        expect(variant.menuItemHighlightForeground, primary.primaryForeground);

        final rebuilt = variant.rebuild(radius: BorderRadius.circular(2));
        expect(rebuilt.runtimeType, variant.runtimeType);
        expect(rebuilt.menuAccent, MenuAccent.bold);
        expect(
          variant.rebuild(menuAccent: MenuAccent.subtle).menuItemHighlight,
          primary.accent,
        );
        expect(variant.rebuild(), variant);
        expect(
          variant.rebuild(menuAccent: MenuAccent.subtle),
          isNot(variant),
        );

        // A theme built around the variant keeps its choice, unless it is
        // given another.
        final theme = ThemeData(variant: variant);
        expect(theme.variant, same(variant));
        expect(
          theme.contextMenuTheme.selectedBackgroundColor,
          primary.primary,
        );
        final other = ThemeData(
          variant: variant,
          menuAccent: MenuAccent.subtle,
        );
        expect(
          other.contextMenuTheme.selectedBackgroundColor,
          primary.accent,
        );
        expect(other.variant.runtimeType, variant.runtimeType);
      }
    });

    test('a lerp carries it with the variant, and never mixes a scheme', () {
      final subtle = ThemeData(style: StyleTokens.nova);
      final bold = ThemeData(style: StyleTokens.nova, menuAccent: .bold);
      final scheme = subtle.colorScheme;
      for (final t in [0.0, .25, .75, 1.0]) {
        final mixed = ThemeData.lerp(subtle, bold, t)!;
        // Not part-way to the primary: the two schemes are the same one.
        expect(mixed.colorScheme.accent, scheme.accent, reason: 't=$t');
        expect(mixed.chatBubbleTheme, subtle.chatBubbleTheme, reason: 't=$t');
        expect(
          (mixed.variant as DefaultThemeVariant).menuAccent,
          t < .5 ? MenuAccent.subtle : MenuAccent.bold,
        );
      }
      expect(ThemeData.lerp(subtle, bold, 0), subtle);
      expect(ThemeData.lerp(subtle, bold, 1), bold);
      // Between two schemes, a bold theme's menus follow the scheme being
      // mixed.
      final dark = ThemeData(
        style: StyleTokens.nova,
        brightness: Brightness.dark,
        menuAccent: MenuAccent.bold,
      );
      final half = ThemeData.lerp(bold, dark, .5)!;
      expect(
        half.contextMenuTheme.selectedBackgroundColor,
        half.colorScheme.primary,
      );
    });
  });

  testWidgets('drawn: with a bold menu accent a bubble, a selected card, an '
      'icon tile, a selected chip and a selected list tile are painted '
      'exactly as without it', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 520);
    addTearDown(tester.view.reset);
    // Shadows on, as on a device.
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
    final boundary = GlobalKey();

    Future<Uint8List> paint(ThemeData theme) async {
      await tester.pumpWidget(
        UnaApp(
          theme: theme,
          home: RepaintBoundary(
            key: boundary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const ChatBubble(child: Text('Incoming')),
                  const Card(
                    selected: true,
                    child: SizedBox(width: 200, child: Text('Selected card')),
                  ),
                  const IconTile(icon: Icon(PhosphorIconsRegular.star)),
                  Chip(
                    label: const Text('Chip'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  SizedBox(
                    width: 240,
                    child: ListTile(
                      title: const Text('List tile'),
                      selected: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // Past the theme's own cross-fade.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      late Uint8List bytes;
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage();
        bytes = (await image.toByteData())!.buffer.asUint8List();
        image.dispose();
      });
      return bytes;
    }

    int count(Uint8List bytes, Color color) {
      final r = (color.r * 255).round();
      final g = (color.g * 255).round();
      final b = (color.b * 255).round();
      var n = 0;
      for (var i = 0; i < bytes.length; i += 4) {
        if (bytes[i] == r && bytes[i + 1] == g && bytes[i + 2] == b) n++;
      }
      return n;
    }

    for (final brightness in Brightness.values) {
      final subtleTheme = ThemeData(brightness: brightness);
      final scheme = subtleTheme.colorScheme;
      final subtle = await paint(subtleTheme);
      final bold = await paint(
        ThemeData(brightness: brightness, menuAccent: MenuAccent.bold),
      );
      // The sample does draw with the accent — an opaque one in the light
      // scheme, where it can be counted —
      if (brightness == Brightness.light) {
        expect(count(subtle, scheme.accent), greaterThan(8000));
      }
      // …and not a pixel of it differs.
      expect(listEquals(bold, subtle), isTrue, reason: '$brightness');
    }
  });
}
