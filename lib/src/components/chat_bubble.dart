import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

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
    return Align(
      alignment: outgoing
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: bubble.maxWidthFactor ?? .78,
        alignment: outgoing
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Align(
          alignment: outgoing
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            padding:
                padding ??
                bubble.padding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color:
                  color ??
                  (outgoing
                      ? bubble.outgoingColor ?? theme.colorScheme.tint
                      : bubble.incomingColor ?? theme.colorScheme.accent),
              borderRadius: radius,
              border: border,
            ),
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
    );
  }
}

/// Three pulsing dots: someone is typing.
///
/// Put it in an incoming [ChatBubble]. The animation stops while the widget
/// is off screen or animations are disabled.
class TypingIndicator extends StatefulWidget {
  /// Creates a typing indicator.
  const TypingIndicator({this.color, this.dotSize = 6, super.key});

  /// The dots' colour. Defaults to the theme's muted foreground.
  final Color? color;

  /// The diameter of each dot.
  final double dotSize;

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
    return Semantics(
      label: 'Typing',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: widget.dotSize * .6,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: color.a * _opacity(i)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Each dot peaks a sixth of a cycle after the one before it.
  double _opacity(int index) {
    final phase = (_controller.value - index / 6) % 1;
    final wave = phase < .5 ? phase * 2 : (1 - phase) * 2;
    return .35 + .65 * Curves.easeInOut.transform(wave);
  }
}
