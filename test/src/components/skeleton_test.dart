import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  group('Skeleton', () {
    Widget wrap(Widget child) => UnaApp(home: Center(child: child));

    testWidgets('renders at the requested size', (tester) async {
      await tester.pumpWidget(
        wrap(const Skeleton(width: 200, height: 16, animate: false)),
      );
      final size = tester.getSize(find.byType(Skeleton));
      expect(size, const Size(200, 16));
    });

    testWidgets('reads its color from the theme', (tester) async {
      await tester.pumpWidget(
        UnaApp(
          theme: ThemeData(
            colorScheme: const NeutralColorScheme.light(),
            brightness: Brightness.light,
            skeletonTheme: const SkeletonTheme(
              color: Color(0xFF123456),
              animate: false,
            ),
          ),
          home: const Center(child: Skeleton(width: 10, height: 10)),
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(Skeleton),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (box.decoration as BoxDecoration).color,
        const Color(0xFF123456),
      );
    });

    testWidgets('is hidden from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const Skeleton(width: 10, height: 10, animate: false)),
      );
      expect(find.byType(ExcludeSemantics), findsWidgets);
      handle.dispose();
    });
  });
}
