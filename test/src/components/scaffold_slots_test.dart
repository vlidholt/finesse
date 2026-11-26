import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

const _body = Key('body');
const _footer = Key('footer');
const _sheet = Key('sheet');
const _banner = Key('banner');
const _fab = Key('fab');
const _bar = Key('bar');

void main() {
  /// Pumps [scaffold] on a phone under a status bar, a home indicator and,
  /// with [keyboard], a software keyboard.
  Future<void> pump(
    WidgetTester tester,
    Widget scaffold, {
    FormFactor formFactor = FormFactor.mobile,
    TextDirection textDirection = TextDirection.ltr,
    double keyboard = 0,
    EdgeInsets padding = const EdgeInsets.only(top: 44, bottom: 34),
    bool disableAnimations = false,
    ThemeData? theme,
  }) {
    return pumpUna(
      tester,
      MediaQuery(
        data: MediaQueryData(
          size: kSurfaceSizes[formFactor]!,
          // As the platform reports it: the home indicator's inset gives
          // way to the keyboard's.
          padding: keyboard > 0 ? padding.copyWith(bottom: 0) : padding,
          viewPadding: padding,
          viewInsets: EdgeInsets.only(bottom: keyboard),
          disableAnimations: disableAnimations,
        ),
        child: scaffold,
      ),
      formFactor: formFactor,
      textDirection: textDirection,
      theme: theme,
    );
  }

  /// A page that records the `MediaQuery` it is given.
  Widget probe(void Function(MediaQueryData) record) => Builder(
    builder: (context) {
      record(MediaQuery.of(context));
      return const SizedBox.expand(key: _body);
    },
  );

  Widget box(Key key, double height, {double? width}) =>
      SizedBox(key: key, height: height, width: width);

  Rect rect(WidgetTester tester, Key key) => tester.getRect(find.byKey(key));

  group('slots', () {
    testWidgets('every slot is laid over the page, and the page is told how '
        'far each reaches in — on the first frame', (tester) async {
      final seen = <MediaQueryData>[];
      await pump(
        tester,
        Scaffold(
          appBar: const AppBar(title: Text('Inbox')),
          banner: box(_banner, 40),
          bottomNavigationBar: box(_bar, 80),
          footer: box(_footer, 56),
          bottomSheet: box(_sheet, 120),
          floatingActionButton: box(_fab, 56, width: 56),
          body: probe(seen.add),
        ),
      );
      final appBar = tester.getRect(find.byType(AppBar));
      // Top to bottom: app bar, banner; bottom to top: bar, footer, sheet.
      expect(appBar.top, 0);
      expect(rect(tester, _banner).top, appBar.bottom);
      expect(rect(tester, _bar).bottom, 844);
      expect(rect(tester, _footer).bottom, 844 - 80);
      expect(rect(tester, _sheet).bottom, 844 - 80 - 56);
      // The page is full size, under all of them.
      expect(rect(tester, _body), const Rect.fromLTWH(0, 0, 390, 844));
      // Nothing was guessed: the first build already had the insets.
      expect(seen.first.padding.top, appBar.height + 40);
      expect(seen.first.padding.bottom, 80 + 56 + 120);
      expect(seen.last.padding, seen.first.padding);
      // The button floats one page margin from the side and from the
      // topmost thing at the bottom.
      final margin =
          themeOf(
            tester,
            find.byType(Scaffold),
          ).layoutTheme.pagePadding!.horizontal /
          2;
      final fab = rect(tester, _fab);
      expect(fab.right, 390 - margin);
      expect(fab.bottom, 844 - 80 - 56 - 120 - margin);
    });

    testWidgets('a slot on the bottom edge is given the safe area; one with '
        'another below it is not', (tester) async {
      EdgeInsets? footer;
      EdgeInsets? sheet;
      Widget reader(void Function(EdgeInsets) record) => Builder(
        builder: (context) {
          record(MediaQuery.paddingOf(context));
          return const SizedBox(height: 50);
        },
      );
      await pump(
        tester,
        Scaffold(
          footer: reader((p) => footer = p),
          bottomSheet: reader((p) => sheet = p),
          body: const SizedBox.expand(),
        ),
      );
      expect(footer!.bottom, 34);
      expect(sheet!.bottom, 0);
      // Neither is at the top.
      expect(footer!.top, 0);

      await pump(
        tester,
        Scaffold(
          bottomNavigationBar: box(_bar, 80),
          footer: reader((p) => footer = p),
          body: const SizedBox.expand(),
        ),
      );
      expect(footer!.bottom, 0);
    });

    testWidgets('with nothing at the bottom the page keeps clear of the '
        'safe area itself, and so does the button', (tester) async {
      final seen = <MediaQueryData>[];
      await pump(
        tester,
        Scaffold(
          floatingActionButton: box(_fab, 56, width: 56),
          body: probe(seen.add),
        ),
      );
      expect(seen.last.padding, const EdgeInsets.only(top: 44, bottom: 34));
      expect(rect(tester, _fab).bottom, 844 - 34 - 16);
    });

    testWidgets('the button sits at the start, the centre or the end, '
        'mirrored in a right-to-left language', (tester) async {
      for (final direction in TextDirection.values) {
        for (final location in FloatingActionButtonLocation.values) {
          await pump(
            tester,
            Scaffold(
              floatingActionButton: box(_fab, 56, width: 56),
              floatingActionButtonLocation: location,
              body: const SizedBox.expand(),
            ),
            textDirection: direction,
          );
          final fab = rect(tester, _fab);
          final onLeft = switch (location) {
            FloatingActionButtonLocation.start =>
              direction == TextDirection.ltr,
            FloatingActionButtonLocation.end => direction == TextDirection.rtl,
            FloatingActionButtonLocation.center => null,
          };
          final reason = '$direction $location';
          if (onLeft == null) {
            expect(fab.center.dx, 195, reason: reason);
          } else if (onLeft) {
            expect(fab.left, 16, reason: reason);
          } else {
            expect(fab.right, 390 - 16, reason: reason);
          }
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    });

    testWidgets('a banner under no app bar starts below the status bar', (
      tester,
    ) async {
      final seen = <MediaQueryData>[];
      await pump(
        tester,
        Scaffold(banner: box(_banner, 40), body: probe(seen.add)),
      );
      expect(rect(tester, _banner).top, 44);
      expect(seen.last.padding.top, 44 + 40);
    });

    testWidgets('the height overrides replace what was measured', (
      tester,
    ) async {
      final seen = <MediaQueryData>[];
      await pump(
        tester,
        Scaffold(
          appBar: const AppBar(title: Text('Inbox')),
          appBarHeight: 10,
          bottomNavigationBar: box(_bar, 80),
          bottomNavigationBarHeight: 20,
          body: probe(seen.add),
        ),
      );
      expect(seen.last.padding.top, 10);
      expect(seen.last.padding.bottom, 20);
    });

    testWidgets('works without a navigator or an app above it', (tester) async {
      await tester.pumpWidget(
        Theme(
          data: ThemeData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(400, 600)),
              child: Scaffold(
                appBar: const AppBar(title: Text('Bare')),
                footer: box(_footer, 40),
                body: const SizedBox.expand(key: _body),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Bare'), findsOneWidget);
    });
  });

  group('the keyboard', () {
    testWidgets('the page ends at the keyboard and sees no inset of its '
        'own; the footer, the sheet and the button ride above it; the '
        'bottom bar stays under it', (tester) async {
      final seen = <MediaQueryData>[];
      Widget scaffold() => Scaffold(
        bottomNavigationBar: box(_bar, 80),
        footer: box(_footer, 56),
        bottomSheet: box(_sheet, 100),
        floatingActionButton: box(_fab, 56, width: 56),
        body: probe(seen.add),
      );
      await pump(tester, scaffold(), keyboard: 300);
      expect(rect(tester, _body), const Rect.fromLTWH(0, 0, 390, 544));
      expect(seen.last.viewInsets.bottom, 0);
      // The bar is covered by the keyboard; only the footer and the sheet
      // lie over the page's end.
      expect(seen.last.padding.bottom, 56 + 100);
      expect(rect(tester, _bar).bottom, 844);
      expect(rect(tester, _footer).bottom, 544);
      expect(rect(tester, _sheet).bottom, 544 - 56);
      expect(rect(tester, _fab).bottom, 544 - 56 - 100 - 16);
    });

    testWidgets('everything follows the keyboard frame by frame, with no '
        'animation of its own', (tester) async {
      for (final keyboard in [0.0, 40.0, 120.0, 300.0, 120.0, 0.0]) {
        await pump(
          tester,
          Scaffold(
            bottomNavigationBar: box(_bar, 80),
            footer: box(_footer, 56),
            floatingActionButton: box(_fab, 56, width: 56),
            body: const SizedBox.expand(key: _body),
          ),
          keyboard: keyboard,
        );
        // The bar is 80 tall: a keyboard shorter than that is behind it.
        final floor = keyboard > 80 ? keyboard : 80;
        expect(rect(tester, _footer).bottom, 844 - floor, reason: '$keyboard');
        expect(
          rect(tester, _fab).bottom,
          844 - floor - 56 - 16,
          reason: '$keyboard',
        );
        expect(rect(tester, _body).bottom, 844 - keyboard);
        expect(tester.binding.hasScheduledFrame, isFalse);
      }
    });

    testWidgets('a focused field at the end of the page is scrolled above '
        'the keyboard and the footer that rides on it', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      Widget scaffold() => Scaffold(
        footer: box(_footer, 56),
        body: Builder(
          builder: (context) => ListView(
            children: [
              const SizedBox(height: 900),
              TextField(focusNode: focus, placeholder: const Text('Reply')),
            ],
          ),
        ),
      );
      await pump(tester, scaffold());
      focus.requestFocus();
      await pump(tester, scaffold(), keyboard: 300);
      await tester.pump(const Duration(milliseconds: 400));
      final field = tester.getRect(find.byType(TextField));
      // Above the keyboard, and above the footer too: the footer lies over
      // the end of the viewport, and the field's scroll padding takes in
      // the inset the scaffold tells its page about.
      expect(rect(tester, _footer).top, 844 - 300 - 56);
      expect(field.bottom, lessThanOrEqualTo(844 - 300 - 56));
      expect(field.top, greaterThan(0));
    });

    testWidgets('resizeToAvoidBottomInset: false leaves everything where it '
        'is and hands the inset on', (tester) async {
      final seen = <MediaQueryData>[];
      await pump(
        tester,
        Scaffold(
          resizeToAvoidBottomInset: false,
          footer: box(_footer, 56),
          body: probe(seen.add),
        ),
        keyboard: 300,
      );
      expect(rect(tester, _body).bottom, 844);
      expect(rect(tester, _footer).bottom, 844);
      expect(seen.last.viewInsets.bottom, 300);
    });

    testWidgets('a nested scaffold does not take the keyboard off twice', (
      tester,
    ) async {
      await pump(
        tester,
        Scaffold(
          body: Scaffold(
            footer: box(_footer, 56),
            body: const SizedBox.expand(key: _body),
          ),
        ),
        keyboard: 300,
      );
      expect(rect(tester, _body).bottom, 544);
      expect(rect(tester, _footer).bottom, 544);
    });
  });

  group('the banner', () {
    Widget app(Widget scaffold, {bool reduce = false}) => UnaApp(
      formFactor: FormFactor.mobile,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          padding: const EdgeInsets.only(top: 44, bottom: 34),
          disableAnimations: reduce,
        ),
        child: scaffold,
      ),
    );

    testWidgets('opens and closes on the surface spring, the page following '
        'it, and goes on showing what it had while it closes', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final seen = <MediaQueryData>[];
      Widget scaffold({required bool banner}) => Scaffold(
        banner: banner ? box(_banner, 40) : null,
        body: probe(seen.add),
      );
      await tester.pumpWidget(app(scaffold(banner: false)));
      await settle(tester);
      expect(seen.last.padding.top, 44);

      await tester.pumpWidget(app(scaffold(banner: true)));
      final opening = <double>[];
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        opening.add(seen.last.padding.top);
      }
      expect(opening.first, lessThan(44 + 40));
      expect(opening.last, 44 + 40);
      for (var i = 1; i < opening.length; i++) {
        expect(opening[i], greaterThanOrEqualTo(opening[i - 1]));
      }
      expect(tester.binding.hasScheduledFrame, isFalse);

      await tester.pumpWidget(app(scaffold(banner: false)));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 48));
      // Half-way out it is still the banner that is leaving.
      expect(find.byKey(_banner), findsOneWidget);
      expect(seen.last.padding.top, inExclusiveRange(44, 44 + 40));
      await tester.pumpAndSettle();
      expect(find.byKey(_banner), findsNothing);
      expect(seen.last.padding.top, 44);
    });

    testWidgets('with reduced motion it is simply there or not', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final seen = <MediaQueryData>[];
      for (final banner in [false, true, false]) {
        await tester.pumpWidget(
          app(
            Scaffold(
              banner: banner ? box(_banner, 40) : null,
              body: probe(seen.add),
            ),
            reduce: true,
          ),
        );
        await tester.pump();
        expect(seen.last.padding.top, 44 + (banner ? 40 : 0));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byKey(_banner), banner ? findsOneWidget : findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
      }
    });
  });

  group('the floating action button', () {
    Widget app(Widget scaffold, {bool reduce = false, ThemeData? theme}) =>
        UnaApp(
          formFactor: FormFactor.mobile,
          theme: theme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              disableAnimations: reduce,
            ),
            child: scaffold,
          ),
        );

    Widget scaffold({
      bool footer = false,
      Widget? fab = const SizedBox(key: _fab, width: 56, height: 56),
      FloatingActionButtonLocation location = FloatingActionButtonLocation.end,
    }) => Scaffold(
      footer: footer ? box(_footer, 80) : null,
      floatingActionButton: fab,
      floatingActionButtonLocation: location,
      body: const SizedBox.expand(),
    );

    testWidgets('travels on the surface spring when what is under it '
        'changes: monotone, and settled where it belongs', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(scaffold()));
      await settle(tester);
      expect(rect(tester, _fab).bottom, 844 - 16);

      await tester.pumpWidget(app(scaffold(footer: true)));
      // The frame that moved its place shows it where it was.
      expect(rect(tester, _fab).bottom, 844 - 16);
      final bottoms = <double>[];
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        bottoms.add(rect(tester, _fab).bottom);
      }
      for (var i = 1; i < bottoms.length; i++) {
        expect(bottoms[i], lessThanOrEqualTo(bottoms[i - 1] + .01));
      }
      expect(bottoms[3], inExclusiveRange(844 - 80 - 16, 844 - 16));
      expect(bottoms.last, 844 - 80 - 16);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('turned around mid-way it goes back from where it is', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(scaffold()));
      await settle(tester);
      await tester.pumpWidget(app(scaffold(footer: true)));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final mid = rect(tester, _fab).bottom;
      expect(mid, inExclusiveRange(844 - 80 - 16, 844 - 16));

      await tester.pumpWidget(app(scaffold()));
      // No jump on the frame that turns it around.
      expect(rect(tester, _fab).bottom, closeTo(mid, .01));
      await tester.pumpAndSettle();
      expect(rect(tester, _fab).bottom, 844 - 16);
    });

    testWidgets('moves across when its location changes', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(scaffold()));
      await settle(tester);
      await tester.pumpWidget(
        app(scaffold(location: FloatingActionButtonLocation.start)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 64));
      expect(rect(tester, _fab).left, inExclusiveRange(16, 390 - 16 - 56));
      await tester.pumpAndSettle();
      expect(rect(tester, _fab).left, 16);
    });

    testWidgets('with reduced motion, and with motion off, it is simply '
        'in its new place', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      for (final (reduce, theme) in [
        (true, null),
        (false, ThemeData(motion: Motion.none)),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          app(scaffold(), reduce: reduce, theme: theme),
        );
        await settle(tester);
        await tester.pumpWidget(
          app(scaffold(footer: true), reduce: reduce, theme: theme),
        );
        expect(rect(tester, _fab).bottom, 844 - 80 - 16);
        await tester.pump();
        expect(tester.binding.hasScheduledFrame, isFalse);
      }
    });

    testWidgets('a window being resized is followed rigidly', (tester) async {
      await pump(tester, scaffold());
      tester.view.physicalSize = const Size(390, 700);
      await tester.pumpWidget(
        UnaApp(
          formFactor: FormFactor.mobile,
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 700)),
            child: scaffold(),
          ),
        ),
      );
      expect(rect(tester, _fab).bottom, 700 - 16);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('pops in when it appears and out when it goes, and a button '
        'with another key replaces it by popping out first', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      double scaleOf(Key key) {
        final transform = tester.widget<Transform>(
          find.ancestor(of: find.byKey(key), matching: find.byType(Transform)),
        );
        return transform.transform.storage[0];
      }

      // There from the start: no entrance.
      await tester.pumpWidget(app(scaffold()));
      expect(scaleOf(_fab), 1);

      await tester.pumpWidget(app(scaffold(fab: null)));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 48));
      // Still drawn while it leaves, and no longer in the way.
      expect(scaleOf(_fab), lessThan(1));
      expect(
        tester
            .widgetList<IgnorePointer>(
              find.ancestor(
                of: find.byKey(_fab),
                matching: find.byType(IgnorePointer),
              ),
            )
            .first
            .ignoring,
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_fab), findsNothing);

      await tester.pumpWidget(app(scaffold()));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 32));
      expect(scaleOf(_fab), lessThan(1));
      await tester.pumpAndSettle();
      expect(scaleOf(_fab), 1);

      const other = Key('other');
      await tester.pumpWidget(
        app(scaffold(fab: const SizedBox(key: other, width: 56, height: 56))),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byKey(_fab), findsOneWidget);
      expect(find.byKey(other), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byKey(_fab), findsNothing);
      expect(scaleOf(other), 1);
    });
  });

  group('the status bar', () {
    SystemUiOverlayStyle? styleAt(WidgetTester tester, Offset point) {
      return tester.binding.renderViews.first.debugLayer!
          .find<SystemUiOverlayStyle>(point);
    }

    testWidgets('is transparent, with icons that read on the page', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await pump(
          tester,
          const Scaffold(body: SizedBox.expand()),
          theme: ThemeData(brightness: brightness),
        );
        final style = styleAt(tester, const Offset(195, 10))!;
        final icons = brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light;
        expect(style.statusBarColor, const Color(0x00000000));
        expect(style.statusBarIconBrightness, icons, reason: '$brightness');
        // iOS is told the brightness of the bar, not of its icons.
        expect(style.statusBarBrightness, brightness);
        expect(style.systemNavigationBarColor, const Color(0x00000000));
        expect(style.systemNavigationBarIconBrightness, icons);
        // The same at the bottom of the screen, for the navigation bar.
        expect(styleAt(tester, const Offset(195, 840)), style);
      }
    });

    testWidgets('follows the page colour it is given', (tester) async {
      await pump(
        tester,
        const Scaffold(
          backgroundColor: Color(0xff101010),
          body: SizedBox.expand(),
        ),
      );
      expect(
        styleAt(tester, const Offset(195, 10))!.statusBarIconBrightness,
        Brightness.light,
      );
    });

    testWidgets('systemOverlayStyle overrides it', (tester) async {
      await pump(
        tester,
        const Scaffold(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          body: SizedBox.expand(),
        ),
      );
      expect(
        styleAt(tester, const Offset(195, 10)),
        SystemUiOverlayStyle.light,
      );
    });
  });

  group('order', () {
    testWidgets('Tab goes down the screen — app bar, banner, page, button, '
        'footer, bottom bar — although the bars are painted last', (
      tester,
    ) async {
      Widget stop(String name) => Focus(
        debugLabel: name,
        child: Builder(
          builder: (context) => SizedBox(
            width: 40,
            height: 40,
            child: Text(Focus.of(context).hasFocus ? '$name*' : name),
          ),
        ),
      );
      await pump(
        tester,
        Scaffold(
          appBar: AppBar(title: stop('bar')),
          banner: stop('banner'),
          bottomNavigationBar: stop('bottom'),
          footer: stop('footer'),
          floatingActionButton: stop('fab'),
          // At the very bottom of the page, under the bars.
          body: Align(alignment: Alignment.bottomLeft, child: stop('page')),
        ),
      );
      final order = <String>[];
      for (var i = 0; i < 6; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        order.add(FocusManager.instance.primaryFocus!.debugLabel!);
      }
      expect(order, ['bar', 'banner', 'page', 'fab', 'footer', 'bottom']);
    });

    testWidgets('assistive technology reads the slots in the same order', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const Scaffold(
          appBar: AppBar(title: Text('bar')),
          banner: Text('banner'),
          bottomNavigationBar: Text('bottom'),
          footer: Text('footer'),
          floatingActionButton: Text('fab'),
          body: Align(alignment: Alignment.bottomLeft, child: Text('page')),
        ),
      );
      final labels = <String>[];
      void visit(SemanticsNode node) {
        if (node.label.isNotEmpty) labels.add(node.label);
        node
            .debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder)
            .forEach(visit);
      }

      visit(tester.getSemantics(find.byType(Scaffold)));
      expect(labels, ['bar', 'banner', 'page', 'fab', 'footer', 'bottom']);
      handle.dispose();
    });
  });

  group('OverlayInsets', () {
    testWidgets('the scaffold reports what covers the top and the bottom of '
        'the screen, the keyboard and the button included', (tester) async {
      OverlayInsets? insets;
      Widget app({double keyboard = 0, bool fab = true}) => UnaApp(
        formFactor: FormFactor.mobile,
        builder: (context, child) => OverlayInsetsScope(
          child: Builder(
            builder: (context) {
              insets = OverlayInsets.maybeOf(context);
              return child!;
            },
          ),
        ),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: Scaffold(
            appBar: const AppBar(title: Text('Inbox')),
            bottomNavigationBar: box(_bar, 80),
            footer: box(_footer, 56),
            floatingActionButton: fab ? box(_fab, 56, width: 56) : null,
            body: const SizedBox.expand(),
          ),
        ),
      );
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await tester.pump();
      final bar = tester.getSize(find.byType(AppBar)).height;
      expect(
        insets!.insets,
        EdgeInsets.only(top: bar, bottom: 80 + 56 + 16 + 56),
      );

      var changes = 0;
      insets!.addListener(() => changes++);
      await tester.pumpWidget(app(keyboard: 300));
      await tester.pump();
      expect(insets!.insets.bottom, 300 + 56 + 16 + 56);
      expect(changes, 1);

      await tester.pumpWidget(app(keyboard: 300, fab: false));
      await tester.pumpAndSettle();
      expect(insets!.insets.bottom, 300 + 56);

      // Gone with the scaffold.
      await tester.pumpWidget(
        UnaApp(
          builder: (context, child) => OverlayInsetsScope(
            child: Builder(
              builder: (context) {
                insets = OverlayInsets.maybeOf(context);
                return child!;
              },
            ),
          ),
          home: const SizedBox.expand(),
        ),
      );
      await tester.pump();
      expect(insets!.insets, EdgeInsets.zero);
    });

    testWidgets('a scaffold that does not reach the screen edge, or is '
        'under another page, reports nothing', (tester) async {
      OverlayInsets? insets;
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        UnaApp(
          navigatorKey: navigator,
          builder: (context, child) => OverlayInsetsScope(
            child: Builder(
              builder: (context) {
                insets = OverlayInsets.maybeOf(context);
                return child!;
              },
            ),
          ),
          home: Scaffold(
            footer: box(_footer, 56),
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Scaffold(
                  footer: box(_sheet, 200),
                  body: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // Only the outer one's footer: the inner scaffold is a box in the
      // middle of the page.
      expect(insets!.insets, const EdgeInsets.only(bottom: 56));

      navigator.currentState!.push(
        UnaPageRoute<void>(builder: (_) => const SizedBox.expand()),
      );
      await tester.pumpAndSettle();
      expect(insets!.insets, EdgeInsets.zero);

      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(insets!.insets, const EdgeInsets.only(bottom: 56));
    });

    testWidgets('a scaffold in a hidden tab of an IndexedStack reports '
        'nothing', (tester) async {
      OverlayInsets? insets;
      Widget app(int index) => UnaApp(
        builder: (context, child) => OverlayInsetsScope(
          child: Builder(
            builder: (context) {
              insets = OverlayInsets.maybeOf(context);
              return child!;
            },
          ),
        ),
        // A hidden child of an IndexedStack keeps its tickers running.
        home: IndexedStack(
          index: index,
          children: [
            Scaffold(footer: box(_footer, 56), body: const SizedBox.expand()),
            const SizedBox.expand(),
          ],
        ),
      );
      await tester.pumpWidget(app(0));
      await tester.pump();
      expect(insets!.insets, const EdgeInsets.only(bottom: 56));
      await tester.pumpWidget(app(1));
      await tester.pump();
      expect(insets!.insets, EdgeInsets.zero);
      await tester.pumpWidget(app(0));
      await tester.pump();
      expect(insets!.insets, const EdgeInsets.only(bottom: 56));
    });

    test('the registry keeps the largest report on each edge', () {
      final insets = OverlayInsets();
      var changes = 0;
      insets.addListener(() => changes++);
      final a = Object();
      final b = Object();
      insets.report(a, const EdgeInsets.only(bottom: 80));
      insets.report(b, const EdgeInsets.only(top: 60, bottom: 40));
      expect(insets.insets, const EdgeInsets.only(top: 60, bottom: 80));
      expect(changes, 2);
      // The same again says nothing.
      insets.report(a, const EdgeInsets.only(bottom: 80));
      expect(changes, 2);
      insets.remove(a);
      expect(insets.insets, const EdgeInsets.only(top: 60, bottom: 40));
      insets.remove(b);
      insets.remove(b);
      expect(insets.insets, EdgeInsets.zero);
      expect(changes, 4);
      insets.dispose();
    });

    testWidgets('watch rebuilds its caller; without a scope it is zero', (
      tester,
    ) async {
      EdgeInsets? seen;
      OverlayInsets? insets;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            seen = OverlayInsets.watch(context);
            return const SizedBox();
          },
        ),
      );
      expect(seen, EdgeInsets.zero);
      await tester.pumpWidget(
        OverlayInsetsScope(
          child: Builder(
            builder: (context) {
              insets = OverlayInsets.maybeOf(context);
              seen = OverlayInsets.watch(context);
              return const SizedBox();
            },
          ),
        ),
      );
      insets!.report(Object(), const EdgeInsets.only(bottom: 12));
      await tester.pump();
      expect(seen, const EdgeInsets.only(bottom: 12));
    });
  });
}
