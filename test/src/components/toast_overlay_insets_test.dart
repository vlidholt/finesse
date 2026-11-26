import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// The toaster and the screens under it: a `Scaffold` says what it has put
/// at the bottom of the screen, and the toasts sit above it.
void main() {
  const phone = Size(390, 800);
  const stays = Duration.zero;

  final navigator = GlobalKey<NavigatorState>();
  late BuildContext host;

  Future<void> pumpApp(
    WidgetTester tester, {
    required Widget home,
    Size size = phone,
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets viewInsets = EdgeInsets.zero,
    ThemeData? theme,
    Widget Function(Widget child)? around,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UnaApp(
        navigatorKey: navigator,
        theme: theme,
        darkTheme: theme,
        builder: (context, child) {
          final page = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: padding,
              viewPadding: padding,
              viewInsets: viewInsets,
            ),
            child: child!,
          );
          return around == null ? page : around(page);
        },
        home: Builder(
          builder: (context) {
            host = context;
            return home;
          },
        ),
      ),
    );
    // A scaffold reports what it covers once its first frame is over.
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Rect rectOf(WidgetTester tester, String title) => tester.getRect(
    find.ancestor(of: find.text(title), matching: find.byType(Toast)),
  );

  double gapOf(BuildContext context) =>
      Theme.of(context).toasterTheme.padding!.resolve(TextDirection.ltr).bottom;

  Widget bar([double height = 72]) => SizedBox(
    key: const Key('bar'),
    height: height,
    width: double.infinity,
  );

  testWidgets('a toast sits above the bottom bar of the screen under it', (
    tester,
  ) async {
    await pumpApp(
      tester,
      home: Scaffold(
        bottomNavigationBar: bar(),
        body: const SizedBox.expand(),
      ),
    );
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    final top = tester.getRect(find.byKey(const Key('bar'))).top;
    expect(top, 800 - 72);
    expect(rectOf(tester, 'Hi').bottom, moreOrLessEquals(top - gapOf(host)));
  });

  testWidgets("above the theme's floating bottom bar, with the home "
      'indicator under it counted once', (tester) async {
    await pumpApp(
      tester,
      padding: const EdgeInsets.only(bottom: 34),
      home: const Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          floating: true,
          selectedIndex: 0,
          destinations: [
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.user),
              label: 'Profile',
            ),
          ],
        ),
        body: SizedBox.expand(),
      ),
    );
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    final barBox = tester.getRect(find.byType(BottomNavigationBar));
    expect(barBox.bottom, 800);
    expect(barBox.height, greaterThan(34));
    expect(
      rectOf(tester, 'Hi').bottom,
      moreOrLessEquals(barBox.top - gapOf(host)),
    );
  });

  testWidgets('above a footer and a floating action button too', (
    tester,
  ) async {
    await pumpApp(
      tester,
      home: Scaffold(
        footer: bar(56),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          semanticLabel: 'Compose',
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
        body: const SizedBox.expand(),
      ),
    );
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    final button = tester.getRect(find.byType(FloatingActionButton));
    expect(button.bottom, lessThan(800 - 56));
    expect(
      rectOf(tester, 'Hi').bottom,
      lessThanOrEqualTo(button.top - gapOf(host) + .01),
    );
  });

  testWidgets('a screen with nothing at the bottom changes nothing', (
    tester,
  ) async {
    await pumpApp(
      tester,
      padding: const EdgeInsets.only(bottom: 34),
      home: const Scaffold(body: SizedBox.expand()),
    );
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    expect(
      rectOf(tester, 'Hi').bottom,
      moreOrLessEquals(800 - 34 - gapOf(host)),
    );
  });

  testWidgets('the keyboard is not counted twice', (tester) async {
    await pumpApp(
      tester,
      viewInsets: const EdgeInsets.only(bottom: 300),
      home: Scaffold(
        bottomNavigationBar: bar(),
        body: const SizedBox.expand(),
      ),
    );
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    // The keyboard covers the bar: the toast is above the keyboard.
    expect(
      rectOf(tester, 'Hi').bottom,
      moreOrLessEquals(800 - 300 - gapOf(host)),
    );
  });

  testWidgets('a footer that rides on the keyboard is cleared with it', (
    tester,
  ) async {
    await pumpApp(
      tester,
      viewInsets: const EdgeInsets.only(bottom: 300),
      home: Scaffold(footer: bar(56), body: const SizedBox.expand()),
    );
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    final top = tester.getRect(find.byKey(const Key('bar'))).top;
    expect(top, 800 - 300 - 56);
    expect(rectOf(tester, 'Hi').bottom, moreOrLessEquals(top - gapOf(host)));
  });

  testWidgets('a page pushed over the bar lets the toast down, and going '
      'back lifts it again, without a jump either way', (tester) async {
    await pumpApp(
      tester,
      home: Scaffold(
        bottomNavigationBar: bar(),
        body: const SizedBox.expand(),
      ),
    );
    final gap = gapOf(host);
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    expect(rectOf(tester, 'Hi').bottom, moreOrLessEquals(800 - 72 - gap));

    Future<void> glidesTo(double target, {required bool down}) async {
      var last = rectOf(tester, 'Hi').bottom;
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final now = rectOf(tester, 'Hi').bottom;
        if (down) {
          expect(now, greaterThanOrEqualTo(last - .01));
        } else {
          expect(now, lessThanOrEqualTo(last + .01));
        }
        expect((now - last).abs(), lessThan(30));
        last = now;
      }
      expect(last, moreOrLessEquals(target, epsilon: .1));
    }

    navigator.currentState!.push(
      UnaPageRoute<void>(
        builder: (context) => const Scaffold(body: SizedBox.expand()),
      ),
    );
    await tester.pump();
    await glidesTo(800 - gap, down: true);

    navigator.currentState!.pop();
    await tester.pump();
    await glidesTo(800 - 72 - gap, down: false);
  });

  testWidgets('ToasterState.insets and the report: the larger wins', (
    tester,
  ) async {
    await pumpApp(
      tester,
      home: Scaffold(
        bottomNavigationBar: bar(),
        body: const SizedBox.expand(),
      ),
    );
    final toaster = Toaster.of(host);
    final gap = gapOf(host);
    toaster.show(const Toast(title: Text('Hi'), duration: stays));
    toaster.insets = const EdgeInsets.only(bottom: 40);
    await settle(tester);
    expect(toaster.insets.bottom, 40);
    expect(rectOf(tester, 'Hi').bottom, moreOrLessEquals(800 - 72 - gap));
    toaster.insets = const EdgeInsets.only(bottom: 120);
    await settle(tester);
    expect(rectOf(tester, 'Hi').bottom, moreOrLessEquals(800 - 120 - gap));
    toaster.insets = EdgeInsets.zero;
    await settle(tester);
    expect(rectOf(tester, 'Hi').bottom, moreOrLessEquals(800 - 72 - gap));
  });

  testWidgets('a stack at the top stays over the app bar', (tester) async {
    await pumpApp(
      tester,
      theme: ThemeData().copyWith(
        toasterTheme: const ToasterTheme(alignment: Alignment.topCenter),
      ),
      home: Scaffold(
        appBar: const AppBar(title: Text('Inbox')),
        bottomNavigationBar: bar(),
        body: const SizedBox.expand(),
      ),
    );
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    final padding = Theme.of(
      host,
    ).toasterTheme.padding!.resolve(TextDirection.ltr);
    expect(rectOf(tester, 'Hi').top, moreOrLessEquals(padding.top));
  });

  testWidgets('a scope above the toaster is the one it reads, so the app '
      'and the toaster agree', (tester) async {
    OverlayInsets? outer;
    await pumpApp(
      tester,
      around: (child) => OverlayInsetsScope(
        child: Builder(
          builder: (context) {
            outer = OverlayInsets.maybeOf(context);
            return child;
          },
        ),
      ),
      home: Scaffold(
        bottomNavigationBar: bar(),
        body: const SizedBox.expand(),
      ),
    );
    expect(outer, isNotNull);
    expect(outer!.insets.bottom, 72);
    expect(OverlayInsets.maybeOf(host), same(outer));
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    expect(
      rectOf(tester, 'Hi').bottom,
      moreOrLessEquals(800 - 72 - gapOf(host)),
    );
  });

  testWidgets('the page keeps its state when the first toast arrives', (
    tester,
  ) async {
    var builds = 0;
    await pumpApp(
      tester,
      home: Scaffold(
        bottomNavigationBar: bar(),
        body: StatefulBuilder(
          builder: (context, setState) {
            builds++;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    final before = builds;
    final state = tester.state(find.byType(Scaffold));
    Toaster.of(host).show(const Toast(title: Text('Hi'), duration: stays));
    await settle(tester);
    expect(tester.state(find.byType(Scaffold)), same(state));
    // Moving the stack is the toaster's business: the page is not rebuilt.
    expect(builds, before);
  });

  group('OverlayInsetsScope', () {
    testWidgets('collects into a registry it is given, and leaves it to '
        'its owner', (tester) async {
      final insets = OverlayInsets();
      addTearDown(insets.dispose);
      OverlayInsets? seen;
      await tester.pumpWidget(
        OverlayInsetsScope(
          insets: insets,
          child: Builder(
            builder: (context) {
              seen = OverlayInsets.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen, same(insets));
      await tester.pumpWidget(const SizedBox());
      // Still usable: the scope did not dispose of it.
      insets.report(seen!, const EdgeInsets.only(bottom: 8));
      expect(insets.insets.bottom, 8);
    });
  });
}
