import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggle and badge icon sizes follow the style', () {
    ThemeData of(StyleTokens style) => ThemeData(style: style);
    // `.cn-toggle` `size-4`, sera `size-3.5`.
    expect(of(StyleTokens.vega).toggleTheme.iconSize, 16);
    expect(of(StyleTokens.sera).toggleTheme.iconSize, 14);
    expect(of(StyleTokens.vega).outlineToggleTheme.iconSize, 16);
    // `.cn-badge` `[&>svg]:size-3`, mira `size-2.5`.
    expect(of(StyleTokens.vega).primaryBadgeTheme.iconSize, 12);
    expect(of(StyleTokens.mira).primaryBadgeTheme.iconSize, 10);
    expect(of(StyleTokens.vega).outlineBadgeTheme.iconSize, 12);
  });

  testWidgets('a badge hands its icon size down', (tester) async {
    await tester.pumpWidget(
      FinesseApp(
        theme: ThemeData(style: StyleTokens.mira),
        home: const Center(
          child: Badge(child: Icon(IconData(0x41))),
        ),
      ),
    );
    final icon = find.byType(Icon);
    expect(IconTheme.of(tester.element(icon)).size, 10);
  });
}
