import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../fixture_styles.dart';

void main() {
  test('toggle and badge icon sizes follow the style', () {
    ThemeData of(StyleTokens style) => ThemeData(style: style);
    // `.cn-toggle` `size-4`, sera `size-3.5`.
    expect(of(FixtureStyles.vega).toggleTheme.iconSize, 16);
    expect(of(FixtureStyles.sera).toggleTheme.iconSize, 14);
    expect(of(FixtureStyles.vega).outlineToggleTheme.iconSize, 16);
    // `.cn-badge` `[&>svg]:size-3`, mira `size-2.5`.
    expect(of(FixtureStyles.vega).primaryBadgeTheme.iconSize, 12);
    expect(of(FixtureStyles.mira).primaryBadgeTheme.iconSize, 10);
    expect(of(FixtureStyles.vega).outlineBadgeTheme.iconSize, 12);
    // The shipped shadcn styles keep the base sizes; una draws both a
    // step larger.
    for (final style in [
      StyleTokens.crisp,
      StyleTokens.pebble,
      StyleTokens.sharp,
    ]) {
      expect(of(style).toggleTheme.iconSize, 16, reason: style.name);
      expect(of(style).primaryBadgeTheme.iconSize, 12, reason: style.name);
    }
    expect(of(StyleTokens.fluid).toggleTheme.iconSize, 18);
    expect(of(StyleTokens.fluid).primaryBadgeTheme.iconSize, 14);
  });

  testWidgets('a badge hands its icon size down', (tester) async {
    await tester.pumpWidget(
      UnaApp(
        theme: ThemeData(style: FixtureStyles.mira),
        home: const Center(
          child: Badge(child: Icon(IconData(0x41))),
        ),
      ),
    );
    final icon = find.byType(Icon);
    expect(IconTheme.of(tester.element(icon)).size, 10);
  });
}
