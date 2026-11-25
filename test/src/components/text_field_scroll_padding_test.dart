import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where a focused field comes to rest in a scrolling page: clear of what
/// lies over the page's ends.
void main() {
  Future<void> pumpApp(
    WidgetTester tester,
    Widget home, {
    EdgeInsets padding = EdgeInsets.zero,
    double keyboard = 0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinesseApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: padding,
            viewPadding: padding,
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
        home: home,
      ),
    );
  }

  EdgeInsets paddingOf(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).scrollPadding;

  testWidgets('with nothing over the page it is 20 on every side', (
    tester,
  ) async {
    await pumpApp(tester, const Center(child: TextField()));
    expect(paddingOf(tester), const EdgeInsets.all(20));
  });

  testWidgets('it takes in the safe area at the top and the bottom', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const Center(child: TextField()),
      padding: const EdgeInsets.only(top: 47, bottom: 34, left: 9),
    );
    expect(paddingOf(tester), const EdgeInsets.fromLTRB(20, 67, 20, 54));
  });

  testWidgets("under a Scaffold it takes in the bars' and the footer's "
      'height, and follows them', (tester) async {
    Widget scaffold({required double footer}) => Scaffold(
      appBarHeight: 60,
      appBar: const SizedBox(height: 60, width: double.infinity),
      bottomNavigationBar: const SizedBox(height: 80, width: double.infinity),
      footer: SizedBox(height: footer, width: double.infinity),
      body: const Center(child: TextField()),
    );
    await pumpApp(tester, scaffold(footer: 56));
    expect(paddingOf(tester), const EdgeInsets.fromLTRB(20, 80, 20, 156));
    await pumpApp(tester, scaffold(footer: 0));
    await tester.pump();
    expect(paddingOf(tester), const EdgeInsets.fromLTRB(20, 80, 20, 100));
  });

  testWidgets('in a list, which keeps the padding from its children, it '
      'is what the list itself is told — and follows it', (tester) async {
    Widget scaffold({required double footer}) => Scaffold(
      bottomNavigationBar: const SizedBox(height: 80, width: double.infinity),
      footer: SizedBox(height: footer, width: double.infinity),
      body: Builder(
        // A list with no padding of its own takes the page's.
        builder: (context) => ListView(children: const [TextField()]),
      ),
    );
    await pumpApp(tester, scaffold(footer: 56));
    // The list's children are told of no padding at the top or the bottom.
    expect(
      MediaQuery.paddingOf(tester.element(find.byType(TextField))).bottom,
      0,
    );
    expect(paddingOf(tester), const EdgeInsets.fromLTRB(20, 20, 20, 156));
    await pumpApp(tester, scaffold(footer: 0));
    await tester.pump();
    expect(paddingOf(tester), const EdgeInsets.fromLTRB(20, 20, 20, 100));
  });

  testWidgets('a scrollPadding that is given is used as it is', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const Center(child: TextField(scrollPadding: EdgeInsets.all(4))),
      padding: const EdgeInsets.only(top: 47, bottom: 34),
    );
    expect(paddingOf(tester), const EdgeInsets.all(4));
  });

  testWidgets('Textarea and TextFormField do the same', (tester) async {
    for (final field in <Widget>[
      const Textarea(),
      TextFormField(),
      TextFormField.password(),
      const TextField.password(),
    ]) {
      await pumpApp(
        tester,
        Center(child: field),
        padding: const EdgeInsets.only(bottom: 34),
      );
      expect(
        paddingOf(tester),
        const EdgeInsets.fromLTRB(20, 20, 20, 54),
        reason: '${field.runtimeType}',
      );
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('a field that takes the focus under a translucent app bar '
      'is scrolled out from under it', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    // Scrolled so that the field lies under the bar.
    final controller = ScrollController(initialScrollOffset: 290);
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      Scaffold(
        appBar: const AppBar(title: Text('Edit')),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              const SizedBox(height: 300),
              TextField(focusNode: focus),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );
    final bar = tester.getRect(find.byType(AppBar));
    expect(tester.getRect(find.byType(TextField)).top, lessThan(bar.bottom));
    focus.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    final field = tester.getRect(find.byType(TextField));
    expect(field.top, greaterThanOrEqualTo(bar.bottom));
  });
}
