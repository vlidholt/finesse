import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// A success, a warning and a failure are told apart at a glance: each
/// washes the toast in its colour, not only its icon. And the icon belongs
/// to the title: it is centred on the title's line, not on the title and
/// the description together.
void main() {
  const styles = [
    StyleTokens.fluid,
    StyleTokens.crisp,
    StyleTokens.pebble,
    StyleTokens.sharp,
  ];

  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + .05) / (lo + .05);
  }

  Future<void> pump(
    WidgetTester tester,
    Widget toast, {
    ThemeData? theme,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      UnaApp(
        theme: theme,
        darkTheme: theme,
        home: Center(child: toast),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The fill the toast's surface is painted with.
  Color fillOf(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(Toast),
            matching: find.byWidgetPredicate(
              (w) => w is DecoratedBox && w.decoration is ShadowDecoration,
            ),
          )
          .first,
    );
    final decoration =
        (box.decoration as ShadowDecoration).decoration as BoxDecoration;
    return decoration.color!;
  }

  test('every style washes a status toast, and its title still reads', () {
    for (final style in styles) {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(style: style, brightness: brightness);
        final toast = theme.toastTheme;
        final opacity = toast.statusTintOpacity!;
        expect(opacity, greaterThan(0), reason: '$style $brightness');
        final scheme = theme.colorScheme;
        final surface = toast.backgroundColor!;
        final ink = toast.titleStyle!.color!;
        for (final status in [
          scheme.success,
          scheme.warning,
          scheme.destructive,
        ]) {
          final tinted = Color.alphaBlend(
            status.withValues(alpha: status.a * opacity),
            surface,
          );
          for (final below in [
            scheme.background,
            const Color(0xff000000),
            const Color(0xffffffff),
          ]) {
            final plain = contrast(ink, Color.alphaBlend(surface, below));
            final washed = contrast(ink, Color.alphaBlend(tinted, below));
            // The wash costs the title little, and never its legibility
            // where the plain toast had it.
            expect(
              washed,
              greaterThanOrEqualTo(plain >= 4.5 ? 4.5 : plain * .85),
              reason: '$style $brightness over $below',
            );
          }
        }
      }
    }
  });

  testWidgets('each status has a surface of its own', (tester) async {
    for (final brightness in Brightness.values) {
      final theme = ThemeData(brightness: brightness);
      final fills = <ToastVariant, Color>{};
      for (final variant in [
        ToastVariant.neutral,
        ToastVariant.success,
        ToastVariant.warning,
        ToastVariant.destructive,
      ]) {
        await pump(
          tester,
          Toast(variant: variant, title: const Text('Saved')),
          theme: theme,
        );
        fills[variant] = fillOf(tester);
      }
      expect(fills.values.toSet(), hasLength(4), reason: '$brightness');
    }
  });

  testWidgets('the icon is centred on the title, not on the whole text', (
    tester,
  ) async {
    await pump(
      tester,
      const SizedBox(
        width: 320,
        child: Toast(
          variant: ToastVariant.success,
          title: Text('Invitation sent'),
          description: Text(
            'Ada will get an email with a link to the workspace, and you '
            'will hear when she joins. It expires in a week.',
          ),
        ),
      ),
    );
    final icon = tester.getRect(find.byType(PhosphorIcon));
    final title = tester.getRect(find.text('Invitation sent'));
    expect(icon.center.dy, moreOrLessEquals(title.center.dy, epsilon: .5));
  });
}
