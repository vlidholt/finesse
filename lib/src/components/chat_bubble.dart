import 'package:flutter/widgets.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/spring_size.dart';

/// Which side of a conversation a [ChatBubble] belongs to.
enum ChatBubbleDirection {
  /// A message someone else sent: start-aligned, in the soft incoming fill.
  incoming,

  /// A message the user sent: end-aligned, in the theme's tint.
  outgoing,
}

/// One message in a conversation.
///
/// ```dart
/// ChatBubble(
///   direction: ChatBubbleDirection.outgoing,
///   child: const Text('Sending the deck now.'),
/// )
/// ```
///
/// The corner nearest the sender — bottom-start for an incoming message,
/// bottom-end for an outgoing one — is squared off into a tail. Set
/// [showTail] to false for all but the last bubble of a run. A bubble never
/// grows wider than the theme's fraction of the available width, so long
/// messages wrap and short ones hug their text; it aligns itself to its side.
///
/// When the message in it changes size — an edit, a `TypingIndicator` giving
/// way to the reply, a `StreamingText` reaching a new line — the bubble
/// follows on a spring instead of jumping, its tail corner staying where it
/// is. Nothing animates on first build or when the window is resized; set
/// [animateSize] to false to switch it off.
class ChatBubble extends StatelessWidget {
  /// Creates a chat bubble.
  const ChatBubble({
    required this.child,
    this.direction = ChatBubbleDirection.incoming,
    this.showTail = true,
    this.color,
    this.foregroundColor,
    this.padding,
    this.border,
    this.maxWidth,
    this.animateSize = true,
    super.key,
  });

  /// The message, usually a [Text].
  final Widget child;

  /// Which side of the conversation the bubble is on.
  final ChatBubbleDirection direction;

  /// Whether the corner nearest the sender is squared into a tail.
  final bool showTail;

  /// The bubble's fill. Defaults to the theme's for [direction].
  final Color? color;

  /// The text colour. Defaults to the theme's for [direction].
  final Color? foregroundColor;

  /// Padding around the message.
  final EdgeInsetsGeometry? padding;

  /// A border around the bubble, for attachments drawn on the card colour.
  final BoxBorder? border;

  /// The widest the bubble grows, in logical pixels. Defaults to the theme's
  /// fraction of the available width.
  final double? maxWidth;

  /// Whether the bubble follows a change in its content's size on the
  /// theme's `sizeSpring` rather than at once.
  final bool animateSize;

  // A step of the bubble's size no larger than this is followed at once:
  // text revealed a character at a time is already smooth, and a spring
  // behind it would only lag. A new line is more than this.
  static const _rigidStep = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubble = theme.chatBubbleTheme;
    final outgoing = direction == ChatBubbleDirection.outgoing;
    final round = Radius.circular(bubble.radius ?? 18);
    final tail = showTail ? Radius.circular(bubble.tailRadius ?? 6) : round;
    final radius = BorderRadiusDirectional.only(
      topStart: round,
      topEnd: round,
      bottomStart: outgoing ? round : tail,
      bottomEnd: outgoing ? tail : round,
    );
    final foreground =
        foregroundColor ??
        (outgoing
            ? bubble.outgoingForegroundColor ?? theme.colorScheme.tintForeground
            : bubble.incomingForegroundColor ?? theme.colorScheme.foreground);
    final alignment = outgoing
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart;
    final factor = bubble.maxWidthFactor ?? .78;
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: alignment,
        // Hug the message's height even inside a parent of fixed height.
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                maxWidth ??
                (constraints.hasBoundedWidth
                    ? constraints.maxWidth * factor
                    : double.infinity),
          ),
          // The fill is outside the animated box and the padding inside it,
          // so the bubble is drawn at the size it has on the way.
          child: Container(
            decoration: BoxDecoration(
              color:
                  color ??
                  (outgoing
                      ? bubble.outgoingColor ?? theme.colorScheme.tint
                      : bubble.incomingColor ?? theme.colorScheme.accent),
              borderRadius: radius,
              border: border,
            ),
            child: SpringSize(
              enabled: animateSize,
              spring: bubble.sizeSpring,
              borderRadius: radius,
              rigidDistance: MediaQuery.textScalerOf(context).scale(_rigidStep),
              child: Padding(
                padding:
                    padding ??
                    bubble.padding ??
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: DefaultTextStyle.merge(
                  style: (bubble.textStyle ?? theme.textTheme.p).copyWith(
                    color: foreground,
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(color: foreground),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three pulsing dots: someone is typing.
///
/// Put it in an incoming [ChatBubble]. The animation stops while the widget
/// is off screen or animations are disabled.
class TypingIndicator extends StatefulWidget {
  /// Creates a typing indicator.
  const TypingIndicator({
    this.color,
    this.dotSize = 6,
    this.semanticLabel,
    super.key,
  });

  /// The dots' colour. Defaults to the theme's muted foreground.
  final Color? color;

  /// The diameter of each dot.
  final double dotSize;

  /// What assistive technology reads for the indicator, ideally naming who
  /// is typing. Defaults to the localised "Typing".
  final String? semanticLabel;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.mutedForeground;
    final dot = widget.dotSize;
    return Semantics(
      label: widget.semanticLabel ?? UnaLocalizations.of(context).chat.typing,
      // The dots never stop while somebody is typing, so a frame of them
      // has to cost next to nothing: they are painted, not built, and in a
      // layer of their own, so the bubble around them is not painted again
      // sixty times a second.
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(dot * 3 + dot * _gap * 2, dot),
          painter: _TypingDotsPainter(
            progress: _controller,
            color: color,
            dotSize: dot,
          ),
        ),
      ),
    );
  }
}

/// The space between two dots, in dot sizes.
const _gap = .6;

class _TypingDotsPainter extends CustomPainter {
  _TypingDotsPainter({
    required this.progress,
    required this.color,
    required this.dotSize,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final double dotSize;

  /// Each dot peaks a sixth of a cycle after the one before it.
  double _opacity(int index) {
    final phase = (progress.value - index / 6) % 1;
    final wave = phase < .5 ? phase * 2 : (1 - phase) * 2;
    return .35 + .65 * Curves.easeInOut.transform(wave);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = dotSize / 2;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(radius + i * dotSize * (1 + _gap), radius),
        radius,
        Paint()..color = color.withValues(alpha: color.a * _opacity(i)),
      );
    }
  }

  @override
  bool shouldRepaint(_TypingDotsPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dotSize != dotSize ||
      !identical(oldDelegate.progress, progress);
}
