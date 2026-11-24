import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

const _frame = Duration(milliseconds: 16);

/// The paragraph a [StreamingText] paints through while it is revealing.
final _paragraph = find.byWidgetPredicate(
  (widget) => '${widget.runtimeType}' == '_StreamingParagraph',
);

/// What the paragraph says about itself: how many code units show, how
/// many have finished fading in, and how opaque the caret is.
({int revealed, int solid, int length, double caret}) _state(
  WidgetTester tester,
) {
  final properties = tester
      .renderObject(_paragraph)
      .toDiagnosticsNode()
      .getProperties();
  T read<T>(String name) =>
      properties.firstWhere((p) => p.name == name).value! as T;
  return (
    revealed: read<int>('revealed'),
    solid: read<int>('solid'),
    length: read<int>('length'),
    caret: read<double>('caret'),
  );
}

/// Where each grapheme cluster of [text] ends.
Set<int> _boundaries(String text) {
  final ends = <int>{0};
  var offset = 0;
  for (final cluster in text.characters) {
    offset += cluster.length;
    ends.add(offset);
  }
  return ends;
}

/// A [StreamingText] over a string the test replaces.
class _Host extends StatefulWidget {
  const _Host({
    this.text = '',
    this.streaming = true,
    this.width = 300,
    this.placeholder,
    this.onRevealed,
    super.key,
  });

  final String text;
  final bool streaming;
  final double width;
  final Widget? placeholder;
  final VoidCallback? onRevealed;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late String text = widget.text;
  late bool streaming = widget.streaming;

  void update({String? text, bool? streaming}) => setState(() {
    this.text = text ?? this.text;
    this.streaming = streaming ?? this.streaming;
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: SizedBox(
        width: widget.width,
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: StreamingText(
            text,
            streaming: streaming,
            placeholder: widget.placeholder,
            onRevealed: widget.onRevealed,
          ),
        ),
      ),
    );
  }
}

_HostState _host(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host));

Size _size(WidgetTester tester) => tester.getSize(find.byType(StreamingText));

void main() {
  group('StreamingTextTheme', () {
    test('is fed by the variant and compares by value', () {
      final theme = ThemeData().streamingTextTheme;
      expect(theme.revealRate, 90);
      expect(theme.catchUpDuration, const Duration(milliseconds: 280));
      expect(theme.showCaret, isTrue);
      // The motion knobs are left to be resolved from `Motion.of`.
      expect(theme.fadeDuration, isNull);
      expect(theme.rise, isNull);
      expect(ThemeData().streamingTextTheme, theme);
      expect(
        ThemeData(
          streamingTextTheme: const StreamingTextTheme(revealRate: 40),
        ).streamingTextTheme.revealRate,
        40,
      );
    });
  });

  group('StreamingText', () {
    testWidgets('text that is there when it is built is not revealed', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(text: 'Hello there'));
      final state = _state(tester);
      expect(state.revealed, 11);
      expect(state.solid, 11);
    });

    testWidgets('finished text is a plain Text and animates nothing', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(text: 'Hello there', streaming: false),
      );
      expect(_paragraph, findsNothing);
      expect(find.text('Hello there'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpAndSettle();
    });

    testWidgets('new text is revealed monotonically and ends complete', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host());
      _host(tester).update(text: 'The quick brown fox');
      await tester.pump();

      var last = 0;
      var lastWidth = 0.0;
      final seen = <int>{};
      for (var i = 0; i < 120; i++) {
        await tester.pump(_frame);
        final state = _state(tester);
        expect(state.revealed, greaterThanOrEqualTo(last));
        expect(state.solid, lessThanOrEqualTo(state.revealed));
        expect(_size(tester).width, greaterThanOrEqualTo(lastWidth));
        last = state.revealed;
        lastWidth = _size(tester).width;
        seen.add(last);
      }
      expect(last, 19);
      expect(_state(tester).solid, 19);
      // A character at a time, not a chunk at once.
      expect(seen.length, greaterThan(8));
    });

    testWidgets('the box grows with what is revealed: wider, then taller', (
      tester,
    ) async {
      // The test font is a 15-point square a glyph: 10 fit in 150.
      await pumpFinesse(tester, const _Host(width: 150));
      const text = 'aaaa bbbb cccc dddd eeee ffff';
      _host(tester).update(text: text);
      await tester.pump();

      final heights = <double>[];
      var lastHeight = 0.0;
      var widestAtOneLine = 0.0;
      for (var i = 0; i < 150; i++) {
        await tester.pump(_frame);
        final size = _size(tester);
        expect(size.height, greaterThanOrEqualTo(lastHeight));
        if (heights.isEmpty || heights.last != size.height) {
          heights.add(size.height);
        }
        if (heights.length == 1) widestAtOneLine = size.width;
        lastHeight = size.height;
      }
      // One line, then a second, then a third: never the whole height at
      // once.
      expect(heights.length, 3);
      expect(widestAtOneLine, greaterThan(100));
      _host(tester).update(streaming: false);
      await tester.pumpAndSettle();
      expect(_size(tester), tester.getSize(find.text(text)));
    });

    testWidgets('lines already showing stay as they are when more arrives', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(width: 150));
      // Arrives in three pieces, each a line of its own.
      const pieces = ['aaaa bbbb ', 'cccc dddd ', 'eeee'];
      final text = StringBuffer();
      final heights = <double>[];
      var lastWidth = 0.0;
      for (final piece in pieces) {
        text.write(piece);
        _host(tester).update(text: '$text');
        for (var i = 0; i < 60; i++) {
          await tester.pump(_frame);
          final size = tester.renderObject<RenderBox>(_paragraph).size;
          // The first line never gets shorter for what comes after it.
          expect(size.width, greaterThanOrEqualTo(lastWidth));
          lastWidth = size.width;
        }
        heights.add(tester.renderObject<RenderBox>(_paragraph).size.height);
      }
      expect(heights[1], heights[0] * 2);
      expect(heights[2], heights[0] * 3);
    });

    testWidgets('a burst is caught up with quickly, and evenly', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(width: 600));
      final burst = List.filled(400, 'word').join(' ');
      expect(burst.length, 1999);
      _host(tester).update(text: burst);
      await tester.pump();

      var frames = 0;
      var last = 0;
      var largestStep = 0;
      while (_state(tester).revealed < burst.length) {
        await tester.pump(_frame);
        final revealed = _state(tester).revealed;
        expect(revealed, greaterThanOrEqualTo(last));
        if (revealed - last > largestStep) largestStep = revealed - last;
        last = revealed;
        frames++;
        expect(frames, lessThan(400), reason: 'never caught up');
      }
      // At the base rate it would take over twenty seconds.
      expect(frames * 16, lessThan(4000));
      // And it is not dumped in one frame either.
      expect(largestStep, lessThan(burst.length ~/ 4));
    });

    testWidgets('an uneven stream is shown at an even pace', (tester) async {
      await pumpFinesse(tester, const _Host(width: 600));
      // 12 characters every 96 ms: 125 characters a second, in lumps.
      final text = StringBuffer();
      final steps = <int>[];
      var last = 0;
      for (var chunk = 0; chunk < 30; chunk++) {
        text.write('abcdefghijk ');
        _host(tester).update(text: '$text');
        for (var i = 0; i < 6; i++) {
          await tester.pump(_frame);
          final revealed = _state(tester).revealed;
          if (chunk >= 10) steps.add(revealed - last);
          last = revealed;
        }
      }
      // Once it has found its pace every frame shows a little: no frame
      // without progress and none with a whole chunk.
      expect(steps.where((step) => step == 0), isEmpty);
      expect(steps.reduce((a, b) => a > b ? a : b), lessThan(8));
      // And it keeps up: never more than about a chunk and a half behind.
      expect(text.length - last, lessThan(40));
    });

    testWidgets('completing reveals the rest, removes the caret and settles', (
      tester,
    ) async {
      var revealed = 0;
      await pumpFinesse(tester, _Host(onRevealed: () => revealed++));
      _host(tester).update(text: 'Nearly there');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 48));
      expect(_state(tester).revealed, lessThan(12));
      expect(_state(tester).caret, greaterThan(0));

      _host(tester).update(streaming: false);
      await tester.pumpAndSettle();
      expect(revealed, 1);
      expect(_paragraph, findsNothing);
      expect(find.text('Nearly there'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('the caret shows only while more is expected', (tester) async {
      await pumpFinesse(tester, const _Host(text: 'Thinking'));
      expect(_state(tester).caret, greaterThan(0));
      // It breathes, so a stream that is open keeps a frame scheduled.
      final seen = <double>{};
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        final caret = _state(tester).caret;
        expect(caret, inInclusiveRange(.3, 1.0));
        seen.add((caret * 100).round() / 100);
      }
      expect(seen.length, greaterThan(5));
      expect(tester.binding.hasScheduledFrame, isTrue);

      _host(tester).update(streaming: false);
      await tester.pumpAndSettle();
      expect(_paragraph, findsNothing);
    });

    testWidgets('showCaret: false paints none and lets an open stream rest', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: StreamingText('Waiting', streaming: true, showCaret: false),
        ),
      );
      expect(_state(tester).caret, 0);
      await tester.pumpAndSettle();
    });

    testWidgets('never splits a surrogate pair cut by a chunk boundary', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(width: 600));
      const grin = '\u{1F600}';
      // The first chunk ends in the middle of the emoji.
      _host(tester).update(text: 'ok ${grin.substring(0, 1)}');
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        expect(_state(tester).revealed, lessThanOrEqualTo(3));
      }
      expect(_state(tester).revealed, 3);

      _host(tester).update(text: 'ok $grin');
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        expect(_state(tester).revealed, isIn([3, 5]));
      }
      expect(_state(tester).revealed, 5);
    });

    testWidgets('reveals whole grapheme clusters, whatever the chunks', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(width: 600));
      // A family joined by zero-width joiners, a flag, a skin tone, a
      // letter with a combining accent, Devanagari and Arabic.
      const full =
          'A \u{1F468}‍\u{1F469}‍\u{1F467} B '
          '\u{1F1F8}\u{1F1EA} \u{1F44D}\u{1F3FD} é '
          'क्ष مرحبا end';
      var last = 0;
      // Fed three code units at a time, which cuts through all of them.
      for (var end = 3; end < full.length + 3; end += 3) {
        final text = full.substring(0, end.clamp(0, full.length));
        _host(tester).update(text: text);
        final boundaries = _boundaries(text);
        for (var i = 0; i < 8; i++) {
          await tester.pump(_frame);
          final state = _state(tester);
          expect(
            boundaries,
            contains(state.revealed),
            reason: 'revealed ${state.revealed} of ${text.codeUnits}',
          );
          expect(boundaries, contains(state.solid));
          expect(state.revealed, greaterThanOrEqualTo(last));
          last = state.revealed;
        }
      }
      _host(tester).update(streaming: false);
      await tester.pumpAndSettle();
      expect(find.text(full), findsOneWidget);
    });

    testWidgets('holds back a joiner and half a flag until they complete', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(width: 600));
      // Ends on a joiner: the man waits for whoever he is joined to.
      _host(tester).update(text: 'x\u{1F468}‍');
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
      }
      expect(_state(tester).revealed, 1);
      // Half a flag.
      _host(tester).update(text: 'x\u{1F468}‍\u{1F469} \u{1F1F8}');
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
      }
      expect(_state(tester).revealed, 'x\u{1F468}‍\u{1F469} '.length);
      // When nothing more is coming, what is there is shown.
      _host(tester).update(streaming: false);
      await tester.pumpAndSettle();
      expect(find.text('x\u{1F468}‍\u{1F469} \u{1F1F8}'), findsOneWidget);
    });

    testWidgets('text that is not a continuation keeps the common part', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(text: 'Hello world'));
      expect(_state(tester).revealed, 11);
      _host(tester).update(text: 'Hello there, friend');
      await tester.pump();
      // "Hello " is still showing; the rest is revealed again.
      expect(_state(tester).revealed, 6);
      for (var i = 0; i < 100; i++) {
        await tester.pump(_frame);
      }
      expect(_state(tester).revealed, 19);
    });

    testWidgets('finished text that is edited is simply replaced', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(text: 'First draft', streaming: false),
      );
      _host(tester).update(text: 'Second draft');
      await tester.pump();
      expect(find.text('Second draft'), findsOneWidget);
      expect(_paragraph, findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('lays out exactly as the Text it becomes', (tester) async {
      const text =
          'A reply long enough to wrap over several lines of a narrow '
          'bubble, with a second sentence after it.';
      for (final direction in TextDirection.values) {
        await pumpFinesse(
          tester,
          _Host(key: ValueKey(direction), text: text, width: 220),
          textDirection: direction,
        );
        expect(_paragraph, findsOneWidget);
        final streaming = tester.getRect(find.byType(StreamingText));
        _host(tester).update(streaming: false);
        await tester.pumpAndSettle();
        expect(_paragraph, findsNothing);
        expect(tester.getRect(find.byType(StreamingText)), streaming);
        expect(tester.getRect(find.text(text)), streaming);
      }
    });

    testWidgets('follows the ambient text style, scale and direction', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 10, height: 1),
            child: Align(
              alignment: Alignment.topLeft,
              child: StreamingText('abcd', streaming: true),
            ),
          ),
        ),
      );
      expect(_size(tester), const Size(80, 20));
    });

    testWidgets('right-to-left text grows from the right edge of its box', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(width: 300),
        textDirection: TextDirection.rtl,
      );
      _host(tester).update(text: 'مرحبا بك');
      await tester.pump();
      var lastWidth = 0.0;
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        final rect = tester.getRect(find.byType(StreamingText));
        // Pinned to the start edge of its parent, which is the right.
        expect(rect.right, 1280);
        expect(rect.width, greaterThanOrEqualTo(lastWidth));
        lastWidth = rect.width;
      }
      expect(lastWidth, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('assistive technology reads all of it, not what is revealed', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, const _Host());
      _host(tester).update(text: 'The whole answer');
      await tester.pump();
      await tester.pump(_frame);
      expect(_state(tester).revealed, lessThan(16));
      expect(find.bySemanticsLabel('The whole answer'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('announces the text once, when it completes', (tester) async {
      final handle = tester.ensureSemantics();
      final announcements = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
            message,
          ) async {
            final map = (message as Map).cast<String, dynamic>();
            if (map['type'] == 'announce') {
              announcements.add((map['data'] as Map)['message'] as String);
            }
            return null;
          });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<dynamic>(
              SystemChannels.accessibility,
              null,
            ),
      );

      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(supportsAnnounce: true),
          child: _Host(),
        ),
      );
      _host(tester).update(text: 'One');
      await tester.pump(_frame);
      _host(tester).update(text: 'One two');
      await tester.pump(_frame);
      expect(announcements, isEmpty);
      _host(tester).update(streaming: false);
      await tester.pumpAndSettle();
      expect(announcements, ['One two']);
      handle.dispose();
    });

    testWidgets('a placeholder shows until the first text, then gives way', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(placeholder: TypingIndicator()),
      );
      expect(find.byType(TypingIndicator), findsOneWidget);
      expect(_paragraph, findsNothing);
      final indicator = tester.state(find.byType(TypingIndicator));

      _host(tester).update(text: 'Here it is');
      await tester.pump();
      await tester.pump(_frame);
      await tester.pump(_frame);
      // Both for a moment: the dots fade out over the first characters,
      // and they are the same dots, not new ones.
      expect(_paragraph, findsOneWidget);
      expect(find.byType(TypingIndicator), findsOneWidget);
      expect(tester.state(find.byType(TypingIndicator)), same(indicator));
      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(TypingIndicator),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, inExclusiveRange(0, 1));

      for (var i = 0; i < 20; i++) {
        await tester.pump(_frame);
      }
      expect(find.byType(TypingIndicator), findsNothing);
      _host(tester).update(streaming: false);
      await tester.pumpAndSettle();
      expect(find.text('Here it is'), findsOneWidget);
    });

    testWidgets('the spans of StreamingText.rich are revealed as text is', (
      tester,
    ) async {
      InlineSpan span(String tail) => TextSpan(
        children: [
          const TextSpan(text: 'Plain and '),
          TextSpan(
            text: tail,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      );
      var tail = 'bo';
      var streaming = true;
      late StateSetter rebuild;
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return StreamingText.rich(span(tail), streaming: streaming);
            },
          ),
        ),
      );
      expect(_state(tester).revealed, 12);
      rebuild(() => tail = 'bold text');
      await tester.pump();
      var last = 12;
      for (var i = 0; i < 80; i++) {
        await tester.pump(_frame);
        expect(_state(tester).revealed, greaterThanOrEqualTo(last));
        last = _state(tester).revealed;
      }
      expect(last, 19);
      rebuild(() => streaming = false);
      await tester.pumpAndSettle();
      expect(find.text('Plain and bold text', findRichText: true), findsOne);
    });
  });

  group('reduced motion', () {
    testWidgets('each chunk appears at once, with a short fade', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: _Host(),
        ),
      );
      _host(tester).update(text: 'All of this at once');
      await tester.pump();
      expect(_state(tester).revealed, 19);
      // Fading in, not there yet.
      expect(_state(tester).solid, 0);
      for (var i = 0; i < 12; i++) {
        await tester.pump(_frame);
      }
      expect(_state(tester).solid, 19);
      // And the caret holds still: nothing is left to animate.
      await tester.pumpAndSettle();
      expect(_state(tester).caret, 1);
    });

    testWidgets('Motion.none shows it in the same frame', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(),
        theme: ThemeData(motion: Motion.none),
      );
      _host(tester).update(text: 'Instantly');
      await tester.pump();
      expect(_state(tester).revealed, 9);
      expect(_state(tester).solid, 9);
      expect(tester.binding.hasScheduledFrame, isFalse);
      _host(tester).update(streaming: false);
      await tester.pump();
      expect(find.text('Instantly'), findsOneWidget);
      expect(_paragraph, findsNothing);
    });
  });

  group('StreamingText.stream', () {
    testWidgets('adds each chunk, skips empty ones and finishes on done', (
      tester,
    ) async {
      final chunks = StreamController<String>();
      var revealed = 0;
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: StreamingText.stream(
            chunks.stream,
            onRevealed: () => revealed++,
          ),
        ),
      );
      chunks.add('Hello');
      await tester.pump();
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
      }
      expect(_state(tester).revealed, 5);

      chunks.add('');
      await tester.pump();
      expect(_state(tester).length, 5);

      chunks.add(', world');
      await tester.pump();
      // Not awaited: the done event is only delivered by the next pump.
      unawaited(chunks.close());
      await tester.pumpAndSettle();
      expect(find.text('Hello, world'), findsOneWidget);
      expect(revealed, 1);
    });

    testWidgets('an error keeps what arrived and leaves it finished', (
      tester,
    ) async {
      final chunks = StreamController<String>();
      Object? reported;
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: StreamingText.stream(
            chunks.stream,
            onError: (error, _) => reported = error,
          ),
        ),
      );
      chunks.add('Half an ans');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      chunks.addError(StateError('connection lost'));
      await tester.pumpAndSettle();

      expect(reported, isA<StateError>());
      expect(find.text('Half an ans'), findsOneWidget);
      expect(_paragraph, findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancels its subscription with the widget', (tester) async {
      var cancelled = false;
      final chunks = StreamController<String>(
        onCancel: () => cancelled = true,
      );
      await pumpFinesse(tester, StreamingText.stream(chunks.stream));
      expect(chunks.hasListener, isTrue);
      await tester.pumpWidget(const SizedBox());
      expect(cancelled, isTrue);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('a different stream starts the text over', (tester) async {
      final first = StreamController<String>();
      final second = StreamController<String>();
      var stream = first.stream;
      late StateSetter rebuild;
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return StreamingText.stream(stream);
            },
          ),
        ),
      );
      first.add('Old');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      rebuild(() => stream = second.stream);
      await tester.pump();
      expect(first.hasListener, isFalse);
      second.add('New');
      unawaited(second.close());
      await tester.pumpAndSettle();
      expect(find.text('New'), findsOneWidget);
    });
  });

  group('StreamingTextController', () {
    test('appends, completes, and reports through its listeners', () {
      final controller = StreamingTextController();
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);

      controller.append('One');
      controller.append('');
      controller.append(' two');
      expect(controller.text, 'One two');
      expect(notified, 2);
      expect(controller.isDone, isFalse);

      controller.complete();
      controller.complete();
      expect(controller.isDone, isTrue);
      expect(notified, 3);

      controller.reset('Again');
      expect(controller.text, 'Again');
      expect(controller.isDone, isFalse);
    });

    test('addStream follows a stream and never throws', () async {
      final controller = StreamingTextController();
      addTearDown(controller.dispose);
      await controller.addStream(Stream.fromIterable(['a', 'b', 'c']));
      expect(controller.text, 'abc');
      expect(controller.isDone, isTrue);
      expect(controller.error, isNull);

      controller.reset();
      await controller.addStream(
        Stream<String>.multi((sink) {
          sink
            ..add('x')
            ..addError(const FormatException('bad token'))
            ..add('never');
        }),
      );
      expect(controller.text, 'x');
      expect(controller.isDone, isTrue);
      expect(controller.error, isA<FormatException>());
    });

    test('stop cancels the stream and leaves the text complete', () async {
      final controller = StreamingTextController();
      addTearDown(controller.dispose);
      final chunks = StreamController<String>();
      final finished = controller.addStream(chunks.stream);
      chunks.add('Half');
      await Future<void>.delayed(Duration.zero);
      expect(controller.isListening, isTrue);

      controller.stop();
      await finished;
      expect(chunks.hasListener, isFalse);
      expect(controller.text, 'Half');
      expect(controller.isDone, isTrue);
      expect(controller.isListening, isFalse);
      await chunks.close();
    });

    testWidgets('a widget follows it, and stopping settles cleanly', (
      tester,
    ) async {
      final controller = StreamingTextController();
      addTearDown(controller.dispose);
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: StreamingText.controller(controller),
        ),
      );
      controller.append('A long answer that is cut ');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 64));
      final partly = _state(tester).revealed;
      expect(partly, inExclusiveRange(0, 26));

      // "Stop generating": what has arrived is still shown in full.
      controller.stop();
      await tester.pumpAndSettle();
      expect(_paragraph, findsNothing);
      expect(find.text('A long answer that is cut '), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('keeps the text when its widget is rebuilt from nothing', (
      tester,
    ) async {
      final controller = StreamingTextController(text: 'Kept')..append(' on');
      addTearDown(controller.dispose);
      await pumpFinesse(tester, StreamingText.controller(controller));
      await tester.pumpWidget(const SizedBox());
      await pumpFinesse(tester, StreamingText.controller(controller));
      // Built with it: shown, not revealed again.
      expect(_state(tester).revealed, 7);
    });
  });

  testWidgets('describes its reveal for the inspector', (tester) async {
    await pumpFinesse(tester, const _Host(text: 'abc'));
    final node = tester.renderObject(_paragraph).toDiagnosticsNode();
    expect(
      node.getProperties().map((p) => p.name),
      containsAll(<String>['revealed', 'solid', 'length', 'caret']),
    );
    expect(node.toStringDeep(minLevel: DiagnosticLevel.info), isNotEmpty);
  });
}
