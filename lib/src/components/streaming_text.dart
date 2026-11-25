import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Holds text that arrives a piece at a time, for a [StreamingText].
///
/// Feed it by hand with [append] and [complete], or hand it a stream of
/// chunks with [addStream]:
///
/// ```dart
/// final reply = StreamingTextController();
///
/// void ask(String prompt) {
///   reply.reset();
///   reply.addStream(model.generate(prompt));
/// }
///
/// // In build:
/// StreamingText.controller(reply)
/// ```
///
/// It keeps the whole text, so the widget showing it can be scrolled out of
/// a lazy list and built again without losing anything. Dispose it when it
/// is no longer needed.
class StreamingTextController extends ChangeNotifier {
  /// Creates a controller holding [text]. With [done] set, no more text is
  /// expected.
  StreamingTextController({String text = '', bool done = false})
    : _text = text,
      _done = done;

  String _text;
  bool _done;
  Object? _error;
  StackTrace? _stackTrace;
  StreamSubscription<String>? _subscription;
  Completer<void>? _streamDone;

  /// Everything that has arrived so far.
  String get text => _text;

  /// Replaces the text. A value that starts with the current text is
  /// revealed as an addition to it; anything else is shown as it is.
  set text(String value) {
    if (value == _text) return;
    _text = value;
    notifyListeners();
  }

  /// Whether no more text is expected: [complete] or [stop] was called, or
  /// the stream given to [addStream] ended.
  bool get isDone => _done;

  /// Whether a stream given to [addStream] is still being listened to.
  bool get isListening => _subscription != null;

  /// The error the stream given to [addStream] ended with, if it did.
  Object? get error => _error;

  /// The stack trace that came with [error].
  StackTrace? get stackTrace => _stackTrace;

  /// Adds [chunk] to the end of the text. An empty chunk changes nothing.
  void append(String chunk) {
    if (chunk.isEmpty) return;
    _text += chunk;
    notifyListeners();
  }

  /// Says that the text is complete. What has not been revealed yet still
  /// is, and then the caret leaves.
  void complete() {
    if (_done) return;
    _done = true;
    notifyListeners();
  }

  /// Appends every chunk of [chunks] as it arrives, and completes when the
  /// stream does.
  ///
  /// A stream that ends with an error leaves the text that arrived before
  /// it, records the error in [error] and completes as well: the returned
  /// future never throws. A stream being listened to already is cancelled
  /// first.
  Future<void> addStream(Stream<String> chunks) {
    _cancelSubscription();
    final finished = Completer<void>();
    _streamDone = finished;
    final wasDone = _done;
    _done = false;
    _error = null;
    _stackTrace = null;

    void finish() {
      _subscription = null;
      _streamDone = null;
      _done = true;
      notifyListeners();
      if (!finished.isCompleted) finished.complete();
    }

    _subscription = chunks.listen(
      append,
      onError: (Object error, StackTrace stackTrace) {
        _error = error;
        _stackTrace = stackTrace;
        unawaited(_subscription?.cancel());
        finish();
      },
      onDone: finish,
    );
    if (wasDone) notifyListeners();
    return finished.future;
  }

  /// Stops listening to the stream given to [addStream], if there is one,
  /// and completes with the text that has arrived.
  ///
  /// This is what a "stop generating" button calls: the text showing stays,
  /// and it is left in the same finished state as a stream that ended by
  /// itself.
  void stop() {
    _cancelSubscription();
    complete();
  }

  /// Starts over with [text], expecting more: clears [error] and [isDone]
  /// and stops listening to any stream.
  void reset([String text = '']) {
    _cancelSubscription();
    _text = text;
    _done = false;
    _error = null;
    _stackTrace = null;
    notifyListeners();
  }

  void _cancelSubscription() {
    final subscription = _subscription;
    final finished = _streamDone;
    _subscription = null;
    _streamDone = null;
    if (subscription != null) unawaited(subscription.cancel());
    if (finished != null && !finished.isCompleted) finished.complete();
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}

/// Text that grows while it is on screen — the reply of a language model
/// arriving token by token — and is revealed smoothly rather than popping
/// in a chunk at a time.
///
/// There are three ways to feed it, for the three shapes a caller's data
/// comes in:
///
/// ```dart
/// // A string the parent keeps replacing with a longer one.
/// StreamingText(reply.text, streaming: !reply.finished)
///
/// // A stream of chunks, each a piece to add to the end.
/// StreamingText.stream(model.generate(prompt))
///
/// // A controller, when the text has to outlive the widget.
/// StreamingText.controller(controller)
/// ```
///
/// What arrives is not shown at once. The text is revealed a character at a
/// time at an even pace that speeds up the further behind it is, so a
/// stream that stutters reads as a steady flow and a burst of two thousand
/// characters still takes only a moment; each newly revealed piece fades in,
/// rising a little. The box grows with what is revealed — wider until it
/// reaches the available width, then taller, a line at a time — and lines
/// already showing are never laid out differently by what is revealed
/// after them. A soft caret marks the end while more is expected.
///
/// The reveal never splits a grapheme cluster: an emoji made of several
/// code points, a letter and its combining accent, or a surrogate pair cut
/// in two by a chunk boundary appears whole or not yet.
///
/// When the text is complete and fully revealed the widget becomes a plain
/// `Text` with the same layout, so it can be selected under a
/// `SelectionArea` and costs nothing more than one. Text that is complete
/// when the widget is first built is shown as it is, with no animation.
///
/// Assistive technology always reads the whole text that has arrived, not
/// the part revealed so far, and when it completes it is announced once,
/// politely, rather than token by token; see [announce].
///
/// With reduced motion each chunk appears as it arrives, with a short fade;
/// with motion switched off, at once.
///
/// {@template finesse.StreamingText.markdown}
/// It lays out plain text in one style, or the spans of
/// [StreamingText.rich]. For Markdown, split what has arrived into blocks:
/// render the blocks that are complete with your Markdown widget, and give
/// the last, unfinished one to a [StreamingText] (or to
/// [StreamingText.rich], with the inline styles resolved to spans). The
/// reveal carries on across a rebuild as long as the new text starts with
/// the old.
/// {@endtemplate}
///
/// See also:
///
///  * `ChatBubble`, which follows the growing text on a spring.
///  * `ChatList`, which keeps the newest message in view while it grows.
class StreamingText extends StatefulWidget {
  /// Shows [data], a string that the parent replaces with a longer one as
  /// more arrives.
  ///
  /// Set [streaming] to false when the text is complete: the caret leaves
  /// once the rest has been revealed.
  const StreamingText(
    String this.data, {
    required this.streaming,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.semanticLabel,
    this.placeholder,
    this.showCaret,
    this.caretColor,
    this.announce = true,
    this.onRevealed,
    super.key,
  }) : textSpan = null,
       stream = null,
       controller = null,
       initialData = '',
       onError = null;

  /// Shows [textSpan], which the parent replaces as more arrives: the tail
  /// of a Markdown reply with its inline styles, say.
  ///
  /// The reveal follows the span's plain text, so the styles may be
  /// arranged differently from one build to the next. Widget spans are not
  /// supported.
  const StreamingText.rich(
    InlineSpan this.textSpan, {
    required this.streaming,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.semanticLabel,
    this.placeholder,
    this.showCaret,
    this.caretColor,
    this.announce = true,
    this.onRevealed,
    super.key,
  }) : data = null,
       stream = null,
       controller = null,
       initialData = '',
       onError = null;

  /// Shows the chunks of [stream] as they arrive, each added to the end of
  /// the text, starting from [initialData].
  ///
  /// The stream is listened to for as long as the widget is in the tree,
  /// and is cancelled with it; a different stream starts the text over. A
  /// stream that ends with an error keeps the text that arrived and calls
  /// [onError]. In a lazy list, where the widget may be built again, keep
  /// the text in a [StreamingTextController] instead.
  const StreamingText.stream(
    Stream<String> this.stream, {
    this.initialData = '',
    this.onError,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.semanticLabel,
    this.placeholder,
    this.showCaret,
    this.caretColor,
    this.announce = true,
    this.onRevealed,
    super.key,
  }) : data = null,
       textSpan = null,
       controller = null,
       streaming = true;

  /// Shows the text of [controller], following it as it changes.
  const StreamingText.controller(
    StreamingTextController this.controller, {
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.semanticLabel,
    this.placeholder,
    this.showCaret,
    this.caretColor,
    this.announce = true,
    this.onRevealed,
    super.key,
  }) : data = null,
       textSpan = null,
       stream = null,
       initialData = '',
       onError = null,
       streaming = true;

  /// The text so far, for the default constructor.
  final String? data;

  /// The spans so far, for [StreamingText.rich].
  final InlineSpan? textSpan;

  /// The chunks, for [StreamingText.stream].
  final Stream<String>? stream;

  /// The controller, for [StreamingText.controller].
  final StreamingTextController? controller;

  /// The text [StreamingText.stream] starts from.
  final String initialData;

  /// Called when the stream of [StreamingText.stream] ends with an error.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Whether more text is expected. Ignored by [StreamingText.stream] and
  /// [StreamingText.controller], which know for themselves.
  final bool streaming;

  /// The text's style, merged with the ambient `DefaultTextStyle` as a
  /// `Text`'s is.
  final TextStyle? style;

  /// See `Text.strutStyle`.
  final StrutStyle? strutStyle;

  /// How the lines are aligned. Defaults to the ambient text alignment.
  final TextAlign? textAlign;

  /// The direction of the text. Defaults to the ambient `Directionality`.
  final TextDirection? textDirection;

  /// See `Text.locale`.
  final Locale? locale;

  /// How the font size is scaled. Defaults to the ambient text scaler.
  final TextScaler? textScaler;

  /// See `Text.textWidthBasis`.
  final TextWidthBasis? textWidthBasis;

  /// See `Text.textHeightBehavior`.
  final ui.TextHeightBehavior? textHeightBehavior;

  /// What assistive technology reads instead of the text.
  final String? semanticLabel;

  /// What is shown while nothing has arrived yet and more is expected: a
  /// `TypingIndicator`, usually. It gives way to the first text with a
  /// short fade.
  final Widget? placeholder;

  /// Whether a soft caret marks the end of the text while more is
  /// expected. Defaults to the theme's.
  final bool? showCaret;

  /// The colour of the caret. Defaults to the theme's, then to the text's
  /// own colour, softened.
  final Color? caretColor;

  /// Whether the complete text is announced, politely, to assistive
  /// technology when it stops streaming.
  final bool announce;

  /// Called when the text is complete and all of it is showing.
  final VoidCallback? onRevealed;

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

/// A piece of text that is still fading in, counted in grapheme clusters.
class _Chunk {
  _Chunk(this.start, this.end, this.born);

  final int start;
  int end;

  /// When it was revealed, on the state's own clock, in seconds.
  final double born;
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  final _reveal = _Reveal();
  final _placeholderKey = GlobalKey();

  // Created with the first thing to animate: text that is complete when it
  // is built never needs one.
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;

  /// Seconds of animation so far; the ticker's own clock restarts.
  double _clock = 0;

  StreamingTextController? _own;
  StreamingTextController? _listening;

  String _plain = '';
  bool _streaming = false;

  /// [_plain] as it can be laid out: the engine refuses a string with half
  /// a surrogate pair in it, and a chunk boundary can leave one at the end.
  String get _display {
    final cached = _displayCache;
    if (cached != null) return cached;
    var text = _plain;
    if (text.isNotEmpty) {
      final last = text.codeUnitAt(text.length - 1);
      if (last >= 0xD800 && last <= 0xDBFF) {
        text = text.substring(0, text.length - 1);
      }
    }
    return _displayCache = _wellFormed(text);
  }

  /// [text] with every surrogate that has lost its other half replaced by
  /// the replacement character.
  static String _wellFormed(String text) {
    StringBuffer? fixed;
    var copied = 0;
    for (var i = 0; i < text.length; i++) {
      final unit = text.codeUnitAt(i);
      if (unit < 0xD800 || unit > 0xDFFF) continue;
      if (unit <= 0xDBFF && i + 1 < text.length) {
        final next = text.codeUnitAt(i + 1);
        if (next >= 0xDC00 && next <= 0xDFFF) {
          i++;
          continue;
        }
      }
      fixed ??= StringBuffer();
      fixed
        ..write(text.substring(copied, i))
        ..write('\uFFFD');
      copied = i + 1;
    }
    if (fixed == null) return text;
    fixed.write(text.substring(copied));
    return fixed.toString();
  }

  String? _displayCache;

  /// Where each grapheme cluster of [_plain] ends, in UTF-16 code units.
  final _ends = <int>[];

  /// How many clusters are showing, and how many of those have finished
  /// fading in. [_progress] is the same count before rounding down.
  int _shown = 0;
  int _solid = 0;
  double _progress = 0;
  final _chunks = <_Chunk>[];

  double _caret = 0;
  double _caretPhase = 0;
  double _placeholderOpacity = 0;
  bool _finished = false;
  bool _initialized = false;

  // Resolved from the theme in `didChangeDependencies`; the ticker and the
  // controller's listener run outside build.
  Motion _motion = Motion.calm;
  double _rate = 90;
  double _catchUp = .28;
  double _fade = .2;
  double _rise = 0;
  bool _showCaret = true;
  double _pulse = 1.2;

  StreamingTextController? get _source => widget.controller ?? _own;

  String get _currentText {
    final source = _source;
    if (source != null) return source.text;
    return widget.data ?? widget.textSpan!.toPlainText();
  }

  bool get _currentlyStreaming => _source?.isDone == false || _sourceless;

  bool get _sourceless => _source == null && widget.streaming;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  void _attach() {
    final stream = widget.stream;
    if (stream != null) {
      final own = _own = StreamingTextController(text: widget.initialData);
      own.addStream(stream).whenComplete(() {
        final error = own.error;
        if (mounted && identical(_own, own) && error != null) {
          widget.onError?.call(error, own.stackTrace ?? StackTrace.empty);
        }
      });
    }
    _listening = _source?..addListener(_onSource);
  }

  void _detach() {
    _listening?.removeListener(_onSource);
    _listening = null;
    _own?.dispose();
    _own = null;
  }

  void _onSource() {
    if (!mounted) return;
    // The paragraph takes its text from build.
    setState(_sync);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context).streamingTextTheme;
    final motion = _motion = Motion.of(context);
    _rate = theme.revealRate ?? 90;
    _catchUp = _seconds(
      theme.catchUpDuration ?? const Duration(milliseconds: 280),
    );
    _fade = _seconds(
      motion.reduced ? motion.fast : theme.fadeDuration ?? motion.normal,
    );
    _rise = motion.reduced ? 0 : theme.rise ?? motion.overlayTravel / 2;
    _showCaret = widget.showCaret ?? theme.showCaret ?? true;
    _pulse = motion.reduced
        ? 0
        : _seconds(theme.caretPulse ?? const Duration(milliseconds: 1200));
    if (!_initialized) {
      _initialized = true;
      _start();
    } else {
      _sync();
    }
  }

  @override
  void didUpdateWidget(StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.stream, oldWidget.stream) ||
        !identical(widget.controller, oldWidget.controller)) {
      _detach();
      _attach();
      _start();
      return;
    }
    _showCaret =
        widget.showCaret ??
        Theme.of(context).streamingTextTheme.showCaret ??
        true;
    _sync();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _detach();
    _reveal.dispose();
    super.dispose();
  }

  static double _seconds(Duration duration) =>
      duration.inMicroseconds / Duration.microsecondsPerSecond;

  /// Takes the text as it is now, without revealing it: what is there when
  /// the widget is built is not an arrival.
  void _start() {
    _plain = _currentText;
    _displayCache = null;
    _streaming = _currentlyStreaming;
    _ends.clear();
    _segment(0);
    _chunks.clear();
    _shown = _solid = _available;
    _progress = _shown.toDouble();
    _caret = _streaming && _showCaret ? 1 : 0;
    _caretPhase = 0;
    _placeholderOpacity = 0;
    _finished = !_streaming;
    _placeholderShowing = _showsPlaceholder;
    _publish();
    _wake();
  }

  /// Adds the cluster boundaries of [_plain] from the code unit [from] on.
  void _segment(int from) {
    final range = CharacterRange.at(_plain, from, from);
    final length = _plain.length;
    while (range.moveNext()) {
      _ends.add(length - range.stringAfterLength);
    }
  }

  /// How many clusters may be shown. While more is expected, a tail that
  /// the next chunk would complete is held back: half of a surrogate pair,
  /// an emoji whose joiner is waiting for the one after it, the first half
  /// of a flag.
  int get _available {
    var count = _ends.length;
    if (!_streaming || count == 0) return count;
    int unitBefore(int index) => _plain.codeUnitAt(_ends[index] - 1);
    final last = unitBefore(count - 1);
    if (last >= 0xD800 && last <= 0xDBFF) count--;
    if (count > 0 && unitBefore(count - 1) == 0x200D) count--;
    if (count > 0) {
      final end = _ends[count - 1];
      final start = count > 1 ? _ends[count - 2] : 0;
      if (end - start == 2) {
        final high = _plain.codeUnitAt(start);
        final low = _plain.codeUnitAt(start + 1);
        if (high >= 0xD800 && high <= 0xDBFF) {
          final point = 0x10000 + ((high - 0xD800) << 10) + (low - 0xDC00);
          if (point >= 0x1F1E6 && point <= 0x1F1FF) count--;
        }
      }
    }
    return count;
  }

  int _offsetOf(int count) => count <= 0 ? 0 : _ends[count - 1];

  /// Brings the state up to date with the widget or the controller.
  void _sync() {
    final text = _currentText;
    final wasStreaming = _streaming;
    _streaming = _currentlyStreaming;
    if (text != _plain) {
      final old = _plain;
      _plain = text;
      _displayCache = null;
      if (text.startsWith(old)) {
        // Only the last cluster can be changed by what follows it — and
        // the one before, when the last was half a surrogate pair: what
        // it turns out to be decides whether the two belong together.
        final halved =
            old.isNotEmpty &&
            old.codeUnitAt(old.length - 1) >= 0xD800 &&
            old.codeUnitAt(old.length - 1) <= 0xDBFF;
        if (_ends.isNotEmpty) _ends.removeLast();
        if (halved && _ends.isNotEmpty) _ends.removeLast();
        _segment(_ends.isEmpty ? 0 : _ends.last);
      } else {
        // Not a continuation. Keep what the two have in common showing.
        var common = 0;
        final limit = math.min(old.length, text.length);
        while (common < limit &&
            old.codeUnitAt(common) == text.codeUnitAt(common)) {
          common++;
        }
        _ends.clear();
        _segment(0);
        var kept = 0;
        while (kept < _ends.length && kept < _shown && _ends[kept] <= common) {
          kept++;
        }
        _shown = kept;
        _progress = kept.toDouble();
        _solid = math.min(_solid, kept);
        _chunks
          ..removeWhere((chunk) => chunk.start >= kept)
          ..forEach((chunk) => chunk.end = math.min(chunk.end, kept));
        // Finished text that was edited is simply the new text.
        if (!_streaming) _revealAll(fade: false);
      }
    }
    final available = _available;
    if (_shown > available) {
      // A cluster that was showing is waiting for its other half again.
      _shown = available;
      _progress = math.min(_progress, available.toDouble());
      _solid = math.min(_solid, available);
    }
    if (_motion.reduced && _shown < available) _revealAll(fade: _fade > 0);
    if (_fade <= 0) {
      _chunks.clear();
      _solid = _shown;
    }
    if (_motion.fast <= Duration.zero) {
      // No motion at all: nothing is left for a later frame.
      _caret = _streaming && _showCaret ? 1 : 0;
      _placeholderOpacity = 0;
    }
    if (_finished && (_streaming || _shown < _ends.length)) _finished = false;
    if (wasStreaming && !_streaming) _announce();
    _updatePlaceholder();
    _publish();
    _wake();
  }

  void _revealAll({required bool fade}) {
    final available = _available;
    if (fade && available > _shown) {
      _chunks.add(_Chunk(_shown, available, _clock));
    } else if (!fade) {
      _chunks.clear();
      _solid = available;
    }
    _shown = available;
    _progress = available.toDouble();
  }

  void _announce() {
    if (!widget.announce || !mounted) return;
    if (!SemanticsBinding.instance.semanticsEnabled) return;
    if (!MediaQuery.supportsAnnounceOf(context)) return;
    final message = widget.semanticLabel ?? _display;
    if (message.isEmpty) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        widget.textDirection ?? Directionality.of(context),
      ),
    );
  }

  // Not behind the placeholder, which has a life of its own.
  bool get _caretBreathes =>
      _streaming && _showCaret && _pulse > 0 && !_showsPlaceholder;

  bool get _showsPlaceholder =>
      widget.placeholder != null && _streaming && _shown == 0;

  /// Whether a frame would change anything.
  bool get _busy {
    final caretTarget = _streaming && _showCaret ? 1.0 : 0.0;
    return _shown < _available ||
        _chunks.isNotEmpty ||
        _caret != caretTarget ||
        _caretBreathes ||
        _placeholderOpacity > 0;
  }

  void _wake() {
    if (_busy) {
      final ticker = _ticker ??= createTicker(_onTick);
      if (!ticker.isActive) {
        _lastElapsed = Duration.zero;
        ticker.start();
      }
    } else {
      _settle();
    }
  }

  /// Nothing left to animate: stop, and if the text is complete become a
  /// plain `Text`.
  void _settle() {
    if (_ticker?.isActive ?? false) _ticker!.stop();
    if (_streaming || _finished || _shown < _ends.length) return;
    _finished = true;
    final building =
        SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks;
    final onRevealed = widget.onRevealed;
    if (building) {
      // Build reads the flag directly; the callback may not run inside it.
      if (onRevealed != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) => onRevealed());
      }
    } else {
      setState(() {});
      onRevealed?.call();
    }
  }

  void _onTick(Duration elapsed) {
    // Long gaps — a hidden tab, a muted ticker — are not played back.
    final dt = math.min(_seconds(elapsed - _lastElapsed), .1);
    _lastElapsed = elapsed;
    _clock += dt;

    final available = _available;
    final revealing = _progress < available;
    if (revealing) {
      final backlog = available - _progress;
      final speed = math.max(_rate, backlog / math.max(_catchUp, 1e-3));
      _progress = math.min(available.toDouble(), _progress + speed * dt);
      final count = _progress >= available - 1e-6
          ? available
          : _progress.floor();
      if (count > _shown) {
        final last = _chunks.isEmpty ? null : _chunks.last;
        // A fade a frame is more layers than the eye can tell apart.
        if (last != null && _clock - last.born < _fade / 6) {
          last.end = count;
        } else {
          _chunks.add(_Chunk(_shown, count, _clock));
        }
        _shown = count;
      }
    }
    while (_chunks.isNotEmpty && _clock - _chunks.first.born >= _fade) {
      _solid = _chunks.removeAt(0).end;
    }
    if (_chunks.isEmpty) _solid = _shown;

    final fast = _seconds(_motion.fast);
    final step = fast <= 0 ? 1.0 : dt / fast;
    final caretTarget = _streaming && _showCaret ? 1.0 : 0.0;
    _caret = _caret < caretTarget
        ? math.min(caretTarget, _caret + step)
        : math.max(caretTarget, _caret - step);
    // Steady while text is flowing; it breathes while it waits.
    _caretPhase = revealing || !_caretBreathes ? 0 : _caretPhase + dt / _pulse;
    final placeholderBefore = _placeholderOpacity;
    final hadPlaceholder = _placeholderShowing;
    if (!_updatePlaceholder() && _placeholderOpacity > 0) {
      _placeholderOpacity = math.max(0, _placeholderOpacity - step);
    }
    if (hadPlaceholder != _placeholderShowing ||
        placeholderBefore != _placeholderOpacity) {
      setState(() {});
    }
    _publish();
    if (!_busy) _settle();
  }

  bool _placeholderShowing = false;

  /// Notes whether the placeholder is showing, and starts its fade when it
  /// has just stopped: the first text is there, or none is coming. Returns
  /// whether the fade was started.
  bool _updatePlaceholder() {
    final was = _placeholderShowing;
    final shows = _placeholderShowing = _showsPlaceholder;
    if (!was || shows) return false;
    _placeholderOpacity = _motion.fast <= Duration.zero ? 0 : 1;
    return true;
  }

  /// Hands the reveal to the paragraph, in code units.
  void _publish() {
    final curve = _motion.standard;
    _reveal
      ..offset = _offsetOf(_shown)
      ..solid = _offsetOf(_solid)
      ..chunks = [
        for (final chunk in _chunks)
          if (chunk.end > chunk.start)
            () {
              final t = _fade <= 0
                  ? 1.0
                  : ((_clock - chunk.born) / _fade).clamp(0.0, 1.0);
              final opacity = curve.transform(t);
              return _RevealChunk(
                _offsetOf(chunk.start),
                _offsetOf(chunk.end),
                opacity,
                _rise * (1 - opacity),
              );
            }(),
      ]
      // Not beside the placeholder while that is still fading out.
      ..caret =
          _caret *
          (1 - _placeholderOpacity) *
          (.4 + .6 * (.5 + .5 * math.cos(2 * math.pi * _caretPhase)))
      ..notify();
  }

  @override
  Widget build(BuildContext context) {
    final defaults = DefaultTextStyle.of(context);
    final textAlign = widget.textAlign ?? defaults.textAlign ?? TextAlign.start;
    final textWidthBasis = widget.textWidthBasis ?? defaults.textWidthBasis;
    final textHeightBehavior =
        widget.textHeightBehavior ??
        defaults.textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);
    final span = widget.textSpan;
    assert(
      span == null || !_hasPlaceholderSpan(span),
      'StreamingText.rich does not support widget spans.',
    );
    final data = span == null ? _display : null;

    if (_finished) {
      // The same layout, and selectable under a `SelectionArea`.
      return span == null
          ? Text(
              data!,
              style: widget.style,
              strutStyle: widget.strutStyle,
              textAlign: textAlign,
              textDirection: widget.textDirection,
              locale: widget.locale,
              textScaler: widget.textScaler,
              textWidthBasis: textWidthBasis,
              textHeightBehavior: textHeightBehavior,
              semanticsLabel: widget.semanticLabel,
            )
          : Text.rich(
              span,
              style: widget.style,
              strutStyle: widget.strutStyle,
              textAlign: textAlign,
              textDirection: widget.textDirection,
              locale: widget.locale,
              textScaler: widget.textScaler,
              textWidthBasis: textWidthBasis,
              textHeightBehavior: textHeightBehavior,
              semanticsLabel: widget.semanticLabel,
            );
    }

    // What `Text` does with its style, so the two lay out alike.
    var style = widget.style;
    if (style == null || style.inherit) {
      style = defaults.style.merge(widget.style);
    }
    if (MediaQuery.boldTextOf(context)) {
      style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    final theme = Theme.of(context).streamingTextTheme;
    final caretColor =
        widget.caretColor ??
        theme.caretColor ??
        () {
          final color = style!.color ?? const Color(0xFF000000);
          return color.withValues(alpha: color.a * .55);
        }();

    final placeholder = widget.placeholder;
    Widget? keyedPlaceholder;
    if (placeholder != null && (_showsPlaceholder || _placeholderOpacity > 0)) {
      keyedPlaceholder = KeyedSubtree(key: _placeholderKey, child: placeholder);
    }
    if (_showsPlaceholder) return keyedPlaceholder!;

    final paragraph = _StreamingParagraph(
      text: TextSpan(
        style: style,
        text: data,
        children: span == null ? null : [span],
      ),
      plainLength: span == null ? _display.length : _plain.length,
      textAlign: textAlign,
      textDirection: widget.textDirection ?? Directionality.of(context),
      locale: widget.locale ?? Localizations.maybeLocaleOf(context),
      strutStyle: widget.strutStyle,
      textScaler: widget.textScaler ?? MediaQuery.textScalerOf(context),
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      semanticsLabel: widget.semanticLabel ?? _display,
      reveal: _reveal,
      caretColor: caretColor,
      caretWidth: theme.caretWidth ?? 2,
      caretGap: theme.caretGap ?? 2,
    );
    if (keyedPlaceholder == null) return paragraph;
    // Not positioned: while it fades the box is no smaller than it was, so
    // a bubble around it grows into the text instead of shrinking first.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        paragraph,
        IgnorePointer(
          child: ExcludeSemantics(
            child: Opacity(
              opacity: _placeholderOpacity,
              child: keyedPlaceholder,
            ),
          ),
        ),
      ],
    );
  }

  static bool _hasPlaceholderSpan(InlineSpan span) {
    var found = false;
    span.visitChildren((child) {
      if (child is PlaceholderSpan) found = true;
      return !found;
    });
    return found;
  }
}

/// One piece of text that is fading in, in UTF-16 code units.
@immutable
class _RevealChunk {
  const _RevealChunk(this.start, this.end, this.opacity, this.dy);

  final int start;
  final int end;
  final double opacity;

  /// How far below its place the piece is painted.
  final double dy;
}

/// How much of the text shows, handed from the state to the paragraph
/// without a rebuild.
class _Reveal extends ChangeNotifier {
  /// The end of what is showing, and of what has finished fading in.
  int offset = 0;
  int solid = 0;
  List<_RevealChunk> chunks = const [];

  /// The caret's opacity.
  double caret = 0;

  void notify() => notifyListeners();
}

class _StreamingParagraph extends LeafRenderObjectWidget {
  const _StreamingParagraph({
    required this.text,
    required this.plainLength,
    required this.textAlign,
    required this.textDirection,
    required this.locale,
    required this.strutStyle,
    required this.textScaler,
    required this.textWidthBasis,
    required this.textHeightBehavior,
    required this.semanticsLabel,
    required this.reveal,
    required this.caretColor,
    required this.caretWidth,
    required this.caretGap,
  });

  final InlineSpan text;
  final int plainLength;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextScaler textScaler;
  final TextWidthBasis textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final String semanticsLabel;
  final _Reveal reveal;
  final Color caretColor;
  final double caretWidth;
  final double caretGap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderStreamingParagraph(
        text: text,
        plainLength: plainLength,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        strutStyle: strutStyle,
        textScaler: textScaler,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        semanticsLabel: semanticsLabel,
        reveal: reveal,
        caretColor: caretColor,
        caretWidth: caretWidth,
        caretGap: caretGap,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderStreamingParagraph renderObject,
  ) {
    renderObject
      ..setText(text, plainLength)
      ..textAlign = textAlign
      ..textDirection = textDirection
      ..locale = locale
      ..strutStyle = strutStyle
      ..textScaler = textScaler
      ..textWidthBasis = textWidthBasis
      ..textHeightBehavior = textHeightBehavior
      ..semanticsLabel = semanticsLabel
      ..reveal = reveal
      ..caretColor = caretColor
      ..caretWidth = caretWidth
      ..caretGap = caretGap;
  }
}

/// Lays out all the text that has arrived, once per arrival, and then shows
/// only the part that has been revealed: its size is the box around that
/// part, and it paints the paragraph through a clip.
///
/// Laying out the whole text is what keeps a revealed line from being
/// broken differently later, and revealing by clip is what keeps a frame of
/// the reveal from costing a text layout.
class _RenderStreamingParagraph extends RenderBox {
  _RenderStreamingParagraph({
    required InlineSpan text,
    required int plainLength,
    required TextAlign textAlign,
    required TextDirection textDirection,
    required Locale? locale,
    required StrutStyle? strutStyle,
    required TextScaler textScaler,
    required TextWidthBasis textWidthBasis,
    required ui.TextHeightBehavior? textHeightBehavior,
    required String semanticsLabel,
    required _Reveal reveal,
    required Color caretColor,
    required double caretWidth,
    required double caretGap,
  }) : _plainLength = plainLength,
       _semanticsLabel = semanticsLabel,
       _reveal = reveal,
       _caretColor = caretColor,
       _caretWidth = caretWidth,
       _caretGap = caretGap,
       _painter = TextPainter(
         text: text,
         textAlign: textAlign,
         textDirection: textDirection,
         locale: locale,
         strutStyle: strutStyle,
         textScaler: textScaler,
         textWidthBasis: textWidthBasis,
         textHeightBehavior: textHeightBehavior,
       );

  final TextPainter _painter;
  int _plainLength;
  bool _textDirty = true;
  double? _laidOutMin;
  double? _laidOutMax;

  /// The box around the revealed text, in the paragraph's coordinates.
  Rect _visible = Rect.zero;

  void setText(InlineSpan value, int plainLength) {
    _plainLength = plainLength;
    switch (_painter.text!.compareTo(value)) {
      case RenderComparison.identical:
        return;
      case RenderComparison.metadata:
        _painter.text = value;
        markNeedsSemanticsUpdate();
      case RenderComparison.paint:
        _painter.text = value;
        markNeedsPaint();
        markNeedsSemanticsUpdate();
      case RenderComparison.layout:
        _painter.text = value;
        _textChanged();
    }
  }

  void _textChanged() {
    _textDirty = true;
    markNeedsLayout();
  }

  TextAlign get textAlign => _painter.textAlign;
  set textAlign(TextAlign value) {
    if (_painter.textAlign == value) return;
    _painter.textAlign = value;
    _textChanged();
  }

  TextDirection get textDirection => _painter.textDirection!;
  set textDirection(TextDirection value) {
    if (_painter.textDirection == value) return;
    _painter.textDirection = value;
    _textChanged();
    markNeedsSemanticsUpdate();
  }

  Locale? get locale => _painter.locale;
  set locale(Locale? value) {
    if (_painter.locale == value) return;
    _painter.locale = value;
    _textChanged();
  }

  StrutStyle? get strutStyle => _painter.strutStyle;
  set strutStyle(StrutStyle? value) {
    if (_painter.strutStyle == value) return;
    _painter.strutStyle = value;
    _textChanged();
  }

  TextScaler get textScaler => _painter.textScaler;
  set textScaler(TextScaler value) {
    if (_painter.textScaler == value) return;
    _painter.textScaler = value;
    _textChanged();
  }

  TextWidthBasis get textWidthBasis => _painter.textWidthBasis;
  set textWidthBasis(TextWidthBasis value) {
    if (_painter.textWidthBasis == value) return;
    _painter.textWidthBasis = value;
    _textChanged();
  }

  ui.TextHeightBehavior? get textHeightBehavior => _painter.textHeightBehavior;
  set textHeightBehavior(ui.TextHeightBehavior? value) {
    if (_painter.textHeightBehavior == value) return;
    _painter.textHeightBehavior = value;
    _textChanged();
  }

  String _semanticsLabel;
  String get semanticsLabel => _semanticsLabel;
  set semanticsLabel(String value) {
    if (_semanticsLabel == value) return;
    _semanticsLabel = value;
    markNeedsSemanticsUpdate();
  }

  _Reveal _reveal;
  _Reveal get reveal => _reveal;
  set reveal(_Reveal value) {
    if (identical(_reveal, value)) return;
    if (attached) _reveal.removeListener(_onReveal);
    _reveal = value;
    if (attached) _reveal.addListener(_onReveal);
    markNeedsLayout();
  }

  Color _caretColor;
  Color get caretColor => _caretColor;
  set caretColor(Color value) {
    if (_caretColor == value) return;
    _caretColor = value;
    markNeedsPaint();
  }

  double _caretWidth;
  double get caretWidth => _caretWidth;
  set caretWidth(double value) {
    if (_caretWidth == value) return;
    _caretWidth = value;
    markNeedsPaint();
  }

  double _caretGap;
  double get caretGap => _caretGap;
  set caretGap(double value) {
    if (_caretGap == value) return;
    _caretGap = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _reveal.addListener(_onReveal);
  }

  @override
  void detach() {
    _reveal.removeListener(_onReveal);
    super.detach();
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  void _onReveal() {
    if (_textDirty || !hasSize) {
      markNeedsLayout();
      return;
    }
    // Most frames of a reveal leave the box as it is: the middle of a line
    // once the first is full. Those only need painting.
    if (_measure() != _visible) {
      markNeedsLayout();
    } else {
      markNeedsPaint();
    }
  }

  int get _revealed => math.min(_reveal.offset, _plainLength);

  /// The box around the first [_revealed] code units.
  Rect _measure() {
    final revealed = _revealed;
    if (revealed >= _plainLength) return Offset.zero & _painter.size;
    final width = _painter.width;
    if (revealed <= 0) {
      const start = TextPosition(offset: 0);
      final caret = _painter.getOffsetForCaret(start, Rect.zero);
      final x = caret.dx.clamp(0.0, width);
      return Rect.fromLTWH(
        x,
        0,
        0,
        _painter.getFullHeightForCaret(start, Rect.zero),
      );
    }
    final line = _lineStart(revealed);
    Rect? current;
    for (final box in _painter.getBoxesForSelection(
      TextSelection(baseOffset: line, extentOffset: revealed),
      boxHeightStyle: ui.BoxHeightStyle.max,
    )) {
      final rect = box.toRect();
      current = current?.expandToInclude(rect) ?? rect;
    }
    if (current == null) {
      // A line of nothing but its break.
      final position = TextPosition(offset: revealed);
      final caret = _painter.getOffsetForCaret(position, Rect.zero);
      current = Rect.fromLTWH(
        caret.dx,
        caret.dy,
        0,
        _painter.getFullHeightForCaret(position, Rect.zero),
      );
    }
    var left = current.left;
    var right = current.right;
    // The lines above are showing in full. One that was wrapped means the
    // text is wider than the box, and the box is as wide as it gets.
    final fills = _painter.textWidthBasis == TextWidthBasis.parent;
    for (final metrics in _painter.computeLineMetrics()) {
      if (metrics.baseline > current.top) break;
      if (fills && !metrics.hardBreak) {
        left = 0;
        right = width;
        break;
      }
      left = math.min(left, metrics.left);
      right = math.max(right, metrics.left + metrics.width);
    }
    // A space that hangs past the end of a wrapped line is not width.
    left = left.clamp(0.0, width);
    right = right.clamp(left, width);
    return Rect.fromLTRB(left, 0, right, current.bottom);
  }

  void _layoutText(BoxConstraints constraints) {
    if (!_textDirty &&
        _laidOutMin == constraints.minWidth &&
        _laidOutMax == constraints.maxWidth) {
      return;
    }
    _painter.layout(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
    );
    _textDirty = false;
    _laidOutMin = constraints.minWidth;
    _laidOutMax = constraints.maxWidth;
  }

  @override
  void performLayout() {
    _layoutText(constraints);
    _visible = _measure();
    size = constraints.constrain(_visible.size);
  }

  TextPainter _scratch() => TextPainter(
    text: _painter.text,
    textAlign: _painter.textAlign,
    textDirection: _painter.textDirection,
    locale: _painter.locale,
    strutStyle: _painter.strutStyle,
    textScaler: _painter.textScaler,
    textWidthBasis: _painter.textWidthBasis,
    textHeightBehavior: _painter.textHeightBehavior,
  );

  T _withScratch<T>(double maxWidth, T Function(TextPainter painter) read) {
    final painter = _scratch()..layout(maxWidth: maxWidth);
    final result = read(painter);
    painter.dispose();
    return result;
  }

  // Intrinsic sizes are those of the whole text: what the box grows into.
  @override
  double computeMinIntrinsicWidth(double height) =>
      _withScratch(double.infinity, (painter) => painter.minIntrinsicWidth);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _withScratch(double.infinity, (painter) => painter.maxIntrinsicWidth);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _withScratch(width, (painter) => painter.height);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final painter = _scratch()
      ..layout(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    final size = constraints.constrain(painter.size);
    painter.dispose();
    return size;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      _painter.computeDistanceToActualBaseline(baseline);

  @override
  bool hitTestSelf(Offset position) => true;

  /// Where the line that the code unit before [offset] is on starts.
  int _lineStart(int offset) {
    final line = _painter.getLineBoundary(TextPosition(offset: offset - 1));
    return line.isValid ? line.start.clamp(0, offset) : 0;
  }

  /// The lines above the one [end] is on, and that line up to [end].
  Path _leadingRegion(int end) {
    final line = _lineStart(end);
    final path = Path();
    double? top;
    for (final box in _painter.getBoxesForSelection(
      TextSelection(baseOffset: line, extentOffset: end),
      boxHeightStyle: ui.BoxHeightStyle.max,
    )) {
      path.addRect(box.toRect());
      top = top == null ? box.top : math.min(top, box.top);
    }
    top ??= _painter.getOffsetForCaret(TextPosition(offset: end), Rect.zero).dy;
    if (line > 0) {
      const far = 1e6;
      path.addRect(Rect.fromLTRB(-far, -far, far, top));
    }
    return path;
  }

  Path _rangeRegion(int start, int end) {
    final path = Path();
    for (final box in _painter.getBoxesForSelection(
      TextSelection(baseOffset: start, extentOffset: end),
      boxHeightStyle: ui.BoxHeightStyle.max,
    )) {
      path.addRect(box.toRect());
    }
    return path;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final origin = offset - Offset(_visible.left, 0);
    final revealed = _revealed;
    final solid = math.min(_reveal.solid, revealed);

    if (solid >= _plainLength) {
      _painter.paint(canvas, origin);
    } else {
      // The clips are not anti-aliased: two neighbouring pieces then share
      // every pixel between them exactly, with no seam.
      if (solid > 0) {
        canvas
          ..save()
          ..clipPath(_leadingRegion(solid).shift(origin), doAntiAlias: false);
        _painter.paint(canvas, origin);
        canvas.restore();
      }
      for (final chunk in _reveal.chunks) {
        final start = math.max(chunk.start, solid);
        final end = math.min(chunk.end, revealed);
        if (end <= start || chunk.opacity <= 0) continue;
        final region = _rangeRegion(start, end).shift(origin);
        final bounds = region.getBounds();
        if (bounds.isEmpty) continue;
        canvas
          ..saveLayer(
            bounds.inflate(1).expandToInclude(bounds.translate(0, chunk.dy)),
            Paint()..color = Color.fromRGBO(0, 0, 0, chunk.opacity),
          )
          ..translate(0, chunk.dy)
          ..clipPath(region, doAntiAlias: false);
        _painter.paint(canvas, origin);
        canvas.restore();
      }
    }

    final caret = _reveal.caret;
    if (caret <= 0 || _caretWidth <= 0) return;
    final position = TextPosition(
      offset: revealed,
      affinity: TextAffinity.upstream,
    );
    final at = _painter.getOffsetForCaret(position, Rect.zero);
    final height = _painter.getFullHeightForCaret(position, Rect.zero);
    final rtl = textDirection == TextDirection.rtl;
    final rect = Rect.fromLTWH(
      rtl ? at.dx - _caretGap - _caretWidth : at.dx + _caretGap,
      at.dy + height * .12,
      _caretWidth,
      height * .76,
    ).shift(origin);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(_caretWidth / 2)),
      Paint()..color = _caretColor.withValues(alpha: _caretColor.a * caret),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('revealed', _revealed))
      ..add(IntProperty('solid', math.min(_reveal.solid, _revealed)))
      ..add(IntProperty('length', _plainLength))
      ..add(DoubleProperty('caret', _reveal.caret));
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    // The whole text that has arrived, not the part revealed so far.
    config
      ..label = _semanticsLabel
      ..textDirection = textDirection;
  }
}
