import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

void main() {
  /// The bubble's own box.
  Finder bubbleBox([Finder? bubble]) => find.descendant(
    of: bubble ?? find.byType(ChatBubble),
    matching: find.byType(Container),
  );

  BoxDecoration decorationOf(WidgetTester tester, [Finder? bubble]) =>
      tester.widget<Container>(bubbleBox(bubble)).decoration! as BoxDecoration;

  Widget conversation(List<Widget> bubbles, {double width = 400}) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        child: Column(mainAxisSize: MainAxisSize.min, children: bubbles),
      ),
    );
  }

  group('ChatBubbleTheme', () {
    test('is fed by the style and the scheme', () {
      final light = ThemeData();
      final dark = ThemeData(brightness: Brightness.dark);
      final bubble = light.chatBubbleTheme;

      expect(bubble.radius, 18);
      expect(bubble.tailRadius, 6);
      expect(
        bubble.padding,
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      );
      expect(bubble.textStyle!.fontSize, 15);
      expect(bubble.textStyle!.height, closeTo(22 / 15, 1e-9));
      expect(bubble.maxWidthFactor, .78);
      // Outgoing is the tint in both modes.
      expect(bubble.outgoingColor, light.colorScheme.tint);
      expect(bubble.outgoingForegroundColor, light.colorScheme.tintForeground);
      expect(dark.chatBubbleTheme.outgoingColor, dark.colorScheme.tint);
      // Incoming is the pale accent in the light; in the dark the accent is
      // a saturated wash, so the neutral fill is used instead.
      expect(bubble.incomingColor, light.colorScheme.accent);
      expect(
        dark.chatBubbleTheme.incomingColor,
        dark.colorScheme.secondary.withValues(
          alpha: dark.colorScheme.secondary.a * .8,
        ),
      );
      expect(bubble.incomingForegroundColor, light.colorScheme.foreground);
    });

    test('the two sides of a conversation never share a fill', () {
      for (final brightness in Brightness.values) {
        final bubble = ThemeData(brightness: brightness).chatBubbleTheme;
        expect(bubble.incomingColor, isNot(bubble.outgoingColor));
      }
    });
  });

  group('ChatBubble layout', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ChatBubble(child: Text('Hi')),
            ChatBubble(
              direction: ChatBubbleDirection.outgoing,
              child: Text('Hello there, how is the deck coming along today?'),
            ),
            ChatBubble(showTail: false, child: Text('One')),
            ChatBubble(child: TypingIndicator()),
          ],
        ),
      );
    });

    testWidgets('incoming aligns to the start, outgoing to the end', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpUna(
          tester,
          conversation(const [
            ChatBubble(key: Key('in'), child: Text('Hi')),
            ChatBubble(
              key: Key('out'),
              direction: ChatBubbleDirection.outgoing,
              child: Text('Yo'),
            ),
          ]),
          textDirection: direction,
        );
        final column = tester.getRect(find.byType(Column));
        final incoming = tester.getRect(
          bubbleBox(find.byKey(const Key('in'))),
        );
        final outgoing = tester.getRect(
          bubbleBox(find.byKey(const Key('out'))),
        );

        if (direction == TextDirection.ltr) {
          expect(incoming.left, column.left);
          expect(outgoing.right, column.right);
        } else {
          expect(incoming.right, column.right);
          expect(outgoing.left, column.left);
        }
        // One under the other.
        expect(outgoing.top, incoming.bottom);
      }
    });

    testWidgets('a short message hugs its text', (tester) async {
      await pumpUna(
        tester,
        conversation(const [ChatBubble(child: Text('Hi'))]),
      );
      final text = tester.getSize(find.text('Hi'));
      final box = tester.getSize(bubbleBox());
      // 14 horizontal and 10 vertical padding.
      expect(box.width, text.width + 28);
      expect(box.height, text.height + 20);
      // 15px text on a 22px line.
      expect(text.height, 22);
    });

    testWidgets("a long message wraps at the theme's share of the width", (
      tester,
    ) async {
      for (final direction in ChatBubbleDirection.values) {
        await pumpUna(
          tester,
          conversation([
            ChatBubble(
              direction: direction,
              child: const Text(
                'A long message that has to wrap on to several lines because '
                'it is far wider than the bubble is allowed to grow',
              ),
            ),
          ]),
        );
        expect(tester.takeException(), isNull);
        final box = tester.getSize(bubbleBox());
        // 78% of 400.
        expect(box.width, lessThanOrEqualTo(312));
        expect(box.width, greaterThan(250));
        expect(box.height, greaterThan(22 * 2));
      }
    });

    testWidgets('the width cap follows a theme override', (tester) async {
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(
            child: Text(
              'A long message that has to wrap on to several lines because '
              'it is far wider than the bubble is allowed to grow',
            ),
          ),
        ]),
        theme: ThemeData(
          chatBubbleTheme: const ChatBubbleTheme(maxWidthFactor: .5),
        ),
      );
      expect(tester.getSize(bubbleBox()).width, lessThanOrEqualTo(200));
    });

    testWidgets('maxWidth caps the bubble in logical pixels, in place of the '
        "theme's share of the width", (tester) async {
      const message = Text(
        'A long message that has to wrap on to several lines because '
        'it is far wider than the bubble is allowed to grow',
      );
      // Narrower than the theme's 78% of 400…
      await pumpUna(
        tester,
        conversation(const [ChatBubble(maxWidth: 180, child: message)]),
      );
      expect(tester.takeException(), isNull);
      final narrow = tester.getSize(bubbleBox());
      expect(narrow.width, lessThanOrEqualTo(180));
      expect(narrow.width, greaterThan(120));

      // …and wider than it.
      await pumpUna(
        tester,
        conversation(const [ChatBubble(maxWidth: 380, child: message)]),
      );
      final wide = tester.getSize(bubbleBox());
      expect(wide.width, greaterThan(312));
      expect(wide.width, lessThanOrEqualTo(380));
      expect(wide.height, lessThan(narrow.height));

      // It wins over a theme override too.
      await pumpUna(
        tester,
        conversation(const [ChatBubble(maxWidth: 380, child: message)]),
        theme: ThemeData(
          chatBubbleTheme: const ChatBubbleTheme(maxWidthFactor: .3),
        ),
      );
      expect(tester.getSize(bubbleBox()).width, greaterThan(312));
    });

    testWidgets('maxWidth is a cap, not a width', (tester) async {
      // A short message still hugs its text…
      await pumpUna(
        tester,
        conversation(const [ChatBubble(maxWidth: 300, child: Text('Hi'))]),
      );
      expect(
        tester.getSize(bubbleBox()).width,
        tester.getSize(find.text('Hi')).width + 28,
      );

      // …and a cap wider than the conversation cannot push the bubble out
      // of it.
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(
            maxWidth: 1000,
            child: Text(
              'A long message that has to wrap on to several lines because '
              'it is far wider than the bubble is allowed to grow',
            ),
          ),
        ]),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(bubbleBox()).width, lessThanOrEqualTo(400));
      expect(tester.getSize(bubbleBox()).width, greaterThan(312));
    });

    testWidgets('lays out with unbounded width: the bubble is as wide as its '
        'message', (tester) async {
      for (final direction in ChatBubbleDirection.values) {
        await pumpUna(
          tester,
          Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ChatBubble(
                direction: direction,
                child: const SizedBox(width: 500, height: 30),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: direction.name);
        // No share of an infinite width to take: the content sets it.
        expect(tester.getSize(bubbleBox()), const Size(528, 50));
        expect(tester.getSize(find.byType(ChatBubble)), const Size(528, 50));
      }
    });

    testWidgets('maxWidth still caps a bubble laid out with unbounded width', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ChatBubble(
              maxWidth: 200,
              child: Text(
                'A long message that has to wrap on to several lines because '
                'it is far wider than the bubble is allowed to grow',
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final box = tester.getSize(bubbleBox());
      expect(box.width, lessThanOrEqualTo(200));
      expect(box.height, greaterThan(22 * 2));
    });

    testWidgets('hugs its message in a parent of fixed height', (tester) async {
      for (final direction in ChatBubbleDirection.values) {
        await pumpUna(
          tester,
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 400,
              height: 300,
              child: ChatBubble(direction: direction, child: const Text('Hi')),
            ),
          ),
        );
        final text = tester.getSize(find.text('Hi'));
        final box = tester.getRect(bubbleBox());
        // The fill is the message plus its padding, not a 300-tall slab.
        expect(box.height, text.height + 20, reason: direction.name);
        expect(box.width, text.width + 28, reason: direction.name);
        // It keeps its side.
        final parent = tester.getRect(find.byType(ChatBubble));
        expect(
          direction == ChatBubbleDirection.outgoing ? box.right : box.left,
          direction == ChatBubbleDirection.outgoing
              ? parent.right
              : parent.left,
        );
      }
    });

    testWidgets('hugs its message in a row that stretches its children', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 400,
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 40),
                Expanded(child: ChatBubble(child: Text('Hi'))),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(bubbleBox()).height,
        tester.getSize(find.text('Hi')).height + 20,
      );
    });

    testWidgets('in a column it is exactly as tall as its box', (tester) async {
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(child: Text('Hi')),
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Text('Hello'),
          ),
        ]),
      );
      for (final bubble in find.byType(ChatBubble).evaluate()) {
        final box = find.descendant(
          of: find.byWidget(bubble.widget),
          matching: find.byType(Container),
        );
        expect(bubble.size!.height, tester.getSize(box).height);
        // And spans the conversation, so it can align itself to a side.
        expect(bubble.size!.width, 400);
      }
    });

    testWidgets('padding can be set per bubble', (tester) async {
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(
            padding: EdgeInsets.all(2),
            child: SizedBox(width: 50, height: 30),
          ),
        ]),
      );
      expect(tester.getSize(bubbleBox()), const Size(54, 34));
    });

    testWidgets('holds content that is not text', (tester) async {
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: SizedBox(width: 120, height: 80),
          ),
        ]),
      );
      expect(tester.getSize(bubbleBox()), const Size(148, 100));
    });
  });

  group('ChatBubble shape', () {
    BorderRadius radiusOf(WidgetTester tester, TextDirection direction) =>
        decorationOf(tester).borderRadius!.resolve(direction);

    testWidgets('an incoming bubble has its tail at the bottom start', (
      tester,
    ) async {
      await pumpUna(
        tester,
        conversation(const [ChatBubble(child: Text('Hi'))]),
      );
      final radius = radiusOf(tester, TextDirection.ltr);
      expect(radius.topLeft, const Radius.circular(18));
      expect(radius.topRight, const Radius.circular(18));
      expect(radius.bottomRight, const Radius.circular(18));
      expect(radius.bottomLeft, const Radius.circular(6));
    });

    testWidgets('an outgoing bubble has its tail at the bottom end', (
      tester,
    ) async {
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Text('Hi'),
          ),
        ]),
      );
      final radius = radiusOf(tester, TextDirection.ltr);
      expect(radius.topLeft, const Radius.circular(18));
      expect(radius.topRight, const Radius.circular(18));
      expect(radius.bottomLeft, const Radius.circular(18));
      expect(radius.bottomRight, const Radius.circular(6));
    });

    testWidgets('the tails swap sides in a right-to-left conversation', (
      tester,
    ) async {
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(key: Key('in'), child: Text('Hi')),
          ChatBubble(
            key: Key('out'),
            direction: ChatBubbleDirection.outgoing,
            child: Text('Yo'),
          ),
        ]),
        textDirection: TextDirection.rtl,
      );
      final incoming = decorationOf(
        tester,
        find.byKey(const Key('in')),
      ).borderRadius!.resolve(TextDirection.rtl);
      final outgoing = decorationOf(
        tester,
        find.byKey(const Key('out')),
      ).borderRadius!.resolve(TextDirection.rtl);
      // Start is the right-hand side now.
      expect(incoming.bottomRight, const Radius.circular(6));
      expect(incoming.bottomLeft, const Radius.circular(18));
      expect(outgoing.bottomLeft, const Radius.circular(6));
      expect(outgoing.bottomRight, const Radius.circular(18));
    });

    testWidgets('showTail: false rounds every corner', (tester) async {
      for (final direction in ChatBubbleDirection.values) {
        await pumpUna(
          tester,
          conversation([
            ChatBubble(
              direction: direction,
              showTail: false,
              child: const Text('Hi'),
            ),
          ]),
        );
        expect(
          radiusOf(tester, TextDirection.ltr),
          const BorderRadius.all(Radius.circular(18)),
        );
      }
    });

    testWidgets('radius and tail follow the theme', (tester) async {
      await pumpUna(
        tester,
        conversation(const [ChatBubble(child: Text('Hi'))]),
        theme: ThemeData(
          chatBubbleTheme: const ChatBubbleTheme(radius: 12, tailRadius: 2),
        ),
      );
      final radius = radiusOf(tester, TextDirection.ltr);
      expect(radius.topLeft, const Radius.circular(12));
      expect(radius.bottomLeft, const Radius.circular(2));
    });
  });

  group('ChatBubble colours', () {
    testWidgets('each direction takes its fill and text colour from the '
        'theme', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpUna(
          tester,
          conversation(const [
            ChatBubble(key: Key('in'), child: Text('In')),
            ChatBubble(
              key: Key('out'),
              direction: ChatBubbleDirection.outgoing,
              child: Text('Out'),
            ),
          ]),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.byKey(const Key('in')));
        final bubble = theme.chatBubbleTheme;

        expect(
          decorationOf(tester, find.byKey(const Key('in'))).color,
          bubble.incomingColor,
          reason: '$brightness',
        );
        expect(
          decorationOf(tester, find.byKey(const Key('out'))).color,
          theme.colorScheme.tint,
          reason: '$brightness',
        );
        expect(
          DefaultTextStyle.of(tester.element(find.text('In'))).style.color,
          theme.colorScheme.foreground,
        );
        expect(
          DefaultTextStyle.of(tester.element(find.text('Out'))).style.color,
          theme.colorScheme.tintForeground,
        );
      }
    });

    testWidgets('the direction changes the resolved colours', (tester) async {
      Future<(Color?, Color?)> resolve(ChatBubbleDirection direction) async {
        await pumpUna(
          tester,
          conversation([
            ChatBubble(direction: direction, child: const Text('Hi')),
          ]),
        );
        return (
          decorationOf(tester).color,
          DefaultTextStyle.of(tester.element(find.text('Hi'))).style.color,
        );
      }

      final incoming = await resolve(ChatBubbleDirection.incoming);
      final outgoing = await resolve(ChatBubbleDirection.outgoing);
      expect(outgoing.$1, isNot(incoming.$1));
      expect(outgoing.$2, isNot(incoming.$2));
    });

    testWidgets('the message is set in the bubble text style', (tester) async {
      await pumpUna(
        tester,
        conversation(const [ChatBubble(child: Text('Hi'))]),
      );
      final style = DefaultTextStyle.of(tester.element(find.text('Hi'))).style;
      expect(style.fontSize, 15);
      expect(style.height, closeTo(22 / 15, 1e-9));
    });

    testWidgets('icons inside follow the text colour', (tester) async {
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Icon(PhosphorIconsRegular.check),
          ),
        ]),
      );
      final theme = themeOf(tester, find.byType(ChatBubble));
      expect(
        IconTheme.of(tester.element(find.byType(Icon))).color,
        theme.colorScheme.tintForeground,
      );
    });

    testWidgets('color, foregroundColor and border override the theme', (
      tester,
    ) async {
      const fill = Color(0xff102030);
      const text = Color(0xffa0b0c0);
      final border = Border.all(color: const Color(0xff405060), width: 2);
      await pumpUna(
        tester,
        conversation([
          ChatBubble(
            color: fill,
            foregroundColor: text,
            border: border,
            child: const Text('Hi'),
          ),
        ]),
      );
      final decoration = decorationOf(tester);
      expect(decoration.color, fill);
      expect(decoration.border, border);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Hi'))).style.color,
        text,
      );
      // The border is inside the bubble's box, around the padding.
      final label = tester.getSize(find.text('Hi'));
      expect(tester.getSize(bubbleBox()).width, label.width + 28 + 4);
    });
  });

  group('ChatBubble size', () {
    late StateSetter rebuild;
    var text = 'Short';
    var typing = false;
    var animate = true;

    setUp(() {
      text = 'Short';
      typing = false;
      animate = true;
    });

    Widget host(ChatBubbleDirection direction) => Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 300,
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return ChatBubble(
              direction: direction,
              animateSize: animate,
              child: typing ? const TypingIndicator() : Text(text),
            );
          },
        ),
      ),
    );

    Rect box(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(ChatBubble),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );

    const long =
        'A message long enough to wrap over two or three lines of the '
        'bubble it is in.';

    testWidgets('follows its content on a spring, tail corner in place', (
      tester,
    ) async {
      for (final direction in ChatBubbleDirection.values) {
        text = 'Short';
        await pumpUna(tester, host(direction));
        final before = box(tester);
        rebuild(() => text = long);
        await tester.pump();
        // Nothing has jumped in the frame the message changed.
        expect(box(tester), before);

        var last = before;
        var frames = 0;
        while (tester.binding.hasScheduledFrame) {
          await tester.pump(const Duration(milliseconds: 16));
          final rect = box(tester);
          expect(rect.width, greaterThanOrEqualTo(last.width - 1e-6));
          expect(rect.height, greaterThanOrEqualTo(last.height - 1e-6));
          // The bubble stays against its side, and under its top edge.
          expect(rect.top, before.top);
          if (direction == ChatBubbleDirection.outgoing) {
            expect(rect.right, closeTo(before.right, 1e-6));
          } else {
            expect(rect.left, before.left);
          }
          last = rect;
          expect(++frames, lessThan(120));
        }
        expect(frames, greaterThan(6), reason: direction.name);
        expect(last.height, greaterThan(before.height * 2));
        // Exactly the size it would have been built at.
        expect(last.size, tester.getSize(find.byType(SpringSize)));
      }
    });

    testWidgets('a typing indicator gives way to the reply without a jump', (
      tester,
    ) async {
      typing = true;
      await pumpUna(tester, host(ChatBubbleDirection.incoming));
      final dots = box(tester);
      rebuild(() {
        typing = false;
        text = long;
      });
      await tester.pump();
      expect(box(tester), dots);
      var largest = 0.0;
      var last = dots;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final rect = box(tester);
        final step = (rect.height - last.height).abs();
        if (step > largest) largest = step;
        last = rect;
      }
      expect(last.height, greaterThan(dots.height));
      expect(largest, lessThan((last.height - dots.height) / 3));
    });

    testWidgets('animateSize: false and reduced motion change at once', (
      tester,
    ) async {
      animate = false;
      await pumpUna(tester, host(ChatBubbleDirection.incoming));
      final before = box(tester);
      rebuild(() => text = long);
      await tester.pump();
      expect(box(tester).height, greaterThan(before.height * 2));

      animate = true;
      text = 'Short';
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: host(ChatBubbleDirection.incoming),
        ),
      );
      rebuild(() => text = long);
      await tester.pump();
      expect(box(tester).height, greaterThan(before.height * 2));
    });

    testWidgets('a resized window is followed rigidly', (tester) async {
      text = long;
      var width = 300.0;
      await pumpUna(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                width: width,
                child: const ChatBubble(child: Text(long)),
              );
            },
          ),
        ),
      );
      final wide = box(tester);
      rebuild(() => width = 180);
      await tester.pump();
      expect(box(tester).height, greaterThan(wide.height));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    test('sizeSpring is left to the motion unless a theme sets it', () {
      expect(ThemeData().chatBubbleTheme.sizeSpring, isNull);
      const spring = MotionSpring(duration: Duration(milliseconds: 500));
      expect(
        ThemeData(
          chatBubbleTheme: const ChatBubbleTheme(sizeSpring: spring),
        ).chatBubbleTheme.sizeSpring,
        spring,
      );
    });
  });

  group('TypingIndicator', () {
    // The dots are painted, not built: a frame of them rebuilds nothing.
    // Their colours, as painted now.
    List<Color> dots(WidgetTester tester) {
      final paint = tester.renderObject(
        find.descendant(
          of: find.byType(TypingIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      final canvas = TestRecordingCanvas();
      paint.paint(TestRecordingPaintingContext(canvas), Offset.zero);
      return [
        for (final call in canvas.invocations)
          if (call.invocation.memberName == #drawCircle)
            (call.invocation.positionalArguments[2] as Paint).color,
      ];
    }

    testWidgets('is three round dots in the muted foreground', (tester) async {
      await pumpUna(tester, const Center(child: TypingIndicator()));
      final theme = themeOf(tester, find.byType(TypingIndicator));

      expect(dots(tester), hasLength(3));
      for (final dot in dots(tester)) {
        // A `Paint` keeps its colour in 32-bit floats.
        expect(
          dot.withValues(alpha: 1),
          isSameColorAs(theme.colorScheme.mutedForeground.withValues(alpha: 1)),
        );
      }
      // Three 6px dots with 3.6px between them.
      final size = tester.getSize(find.byType(TypingIndicator));
      expect(size.height, 6);
      expect(size.width, closeTo(6 * 3 + 3.6 * 2, 1e-6));
    });

    testWidgets('dotSize and colour can be set', (tester) async {
      const colour = Color(0xff336699);
      await pumpUna(
        tester,
        const Center(child: TypingIndicator(dotSize: 10, color: colour)),
      );
      final size = tester.getSize(find.byType(TypingIndicator));
      expect(size.height, 10);
      expect(size.width, closeTo(10 * 3 + 6 * 2, 1e-6));
      expect(dots(tester), hasLength(3));
      for (final dot in dots(tester)) {
        expect(dot.withValues(alpha: 1), isSameColorAs(colour));
      }
    });

    testWidgets('the dots pulse one after another, never fully fading', (
      tester,
    ) async {
      await pumpUna(tester, const Center(child: TypingIndicator()));

      // Fixed frames across one 1.2s cycle: `pumpAndSettle` would never
      // return.
      final frames = <List<double>>[];
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        frames.add([for (final dot in dots(tester)) dot.a]);
      }
      final muted = themeOf(
        tester,
        find.byType(TypingIndicator),
      ).colorScheme.mutedForeground.a;

      for (var dot = 0; dot < 3; dot++) {
        final values = [for (final frame in frames) frame[dot]];
        final low = values.reduce((a, b) => a < b ? a : b);
        final high = values.reduce((a, b) => a > b ? a : b);
        // It moves…
        expect(high - low, greaterThan(.3), reason: 'dot $dot');
        // …between about 35% and full strength.
        expect(low, greaterThanOrEqualTo(.35 * muted - 1e-6));
        expect(high, lessThanOrEqualTo(muted + 1e-6));
      }
      // And the three are out of phase: no frame has them all equal.
      expect(
        frames.any((f) => (f[0] - f[1]).abs() > .05),
        isTrue,
      );
      expect(
        frames.any((f) => (f[1] - f[2]).abs() > .05),
        isTrue,
      );
      // The size never changes, so nothing around it reflows.
      expect(tester.getSize(find.byType(TypingIndicator)).height, 6);
    });

    testWidgets('a frame of it builds nothing and paints only the dots', (
      tester,
    ) async {
      // It runs for as long as somebody is typing; a bubble that was
      // rebuilt and painted again on each of those frames would be the
      // most expensive thing on an idle screen.
      await pumpUna(
        tester,
        const Center(
          child: ChatBubble(child: TypingIndicator()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      var builds = 0;
      final painted = <String>[];
      debugOnRebuildDirtyWidget = (element, builtOnce) => builds++;
      debugOnProfilePaint = (object) {
        if (object.isRepaintBoundary && !object.debugNeedsPaint) return;
        painted.add('${object.runtimeType}');
      };
      addTearDown(() {
        debugOnRebuildDirtyWidget = null;
        debugOnProfilePaint = null;
      });
      await tester.pump(const Duration(milliseconds: 100));
      debugOnRebuildDirtyWidget = null;
      debugOnProfilePaint = null;

      expect(builds, 0);
      expect(painted, ['RenderCustomPaint']);
    });

    testWidgets('keeps a frame scheduled while it animates', (tester) async {
      await pumpUna(tester, const Center(child: TypingIndicator()));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('stands still when animations are disabled', (tester) async {
      await pumpUna(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: TypingIndicator()),
        ),
      );
      final before = [for (final dot in dots(tester)) dot.a];
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect([for (final dot in dots(tester)) dot.a], before);
      // Nothing left ticking.
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(dots(tester), hasLength(3));
    });

    testWidgets('starts again when animations are re-enabled', (tester) async {
      Widget build({required bool disabled}) => MediaQuery(
        data: MediaQueryData(disableAnimations: disabled),
        child: const Center(child: TypingIndicator()),
      );
      await pumpUna(tester, build(disabled: true));
      await pumpUna(tester, build(disabled: false));
      final before = [for (final dot in dots(tester)) dot.a];
      await tester.pump(const Duration(milliseconds: 200));
      expect([for (final dot in dots(tester)) dot.a], isNot(before));
    });

    testWidgets('is announced as typing', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, const Center(child: TypingIndicator()));
      expect(find.bySemanticsLabel('Typing'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('semanticLabel replaces what is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Center(child: TypingIndicator(semanticLabel: 'Omar is typing')),
      );
      expect(find.bySemanticsLabel('Omar is typing'), findsOneWidget);
      expect(find.bySemanticsLabel('Typing'), findsNothing);
      expect(const TypingIndicator().semanticLabel, 'Typing');
      // The label is still there half a cycle later: it is not rebuilt
      // away by the animation.
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.bySemanticsLabel('Omar is typing'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the label is read for the bubble it sits in', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        conversation(const [
          ChatBubble(child: TypingIndicator(semanticLabel: 'Omar is typing')),
        ]),
      );
      expect(find.bySemanticsLabel('Omar is typing'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('stops ticking when it leaves the tree', (tester) async {
      await pumpUna(tester, const Center(child: TypingIndicator()));
      await tester.pump(const Duration(milliseconds: 100));

      await pumpUna(tester, const SizedBox.shrink());
      // A leaked ticker would fail the test on teardown; this makes the
      // intent explicit.
      expect(find.byType(TypingIndicator), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('sits in an incoming bubble', (tester) async {
      await pumpUna(
        tester,
        conversation(const [ChatBubble(child: TypingIndicator())]),
      );
      expect(tester.takeException(), isNull);
      // `.first`: the dots are containers too.
      final box = tester.getSize(bubbleBox().first);
      expect(box.height, 26);
      expect(box.width, closeTo(6 * 3 + 3.6 * 2 + 28, 1e-6));
    });
  });
}
