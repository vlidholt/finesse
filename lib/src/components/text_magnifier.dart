import 'dart:async';

import 'package:finesse/src/components/text_selection.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The loupe shown above the finger while the caret or a selection handle
/// is dragged on a touch screen, so the text under the finger can be read.
///
/// A fully rounded capsule with a hairline and the style's floating shadow,
/// showing the line being edited a little enlarged. It follows the finger
/// along the line, stays on screen, and glides — rather than jumps — when
/// the drag moves to another line.
///
/// `TextField`, `Textarea` and `SelectionArea` use
/// [TextMagnifier.adaptiveConfiguration] by default, which shows it on iOS
/// and Android and nothing on a desktop. Size, magnification and colours
/// come from `ThemeData.textSelectionTheme`.
///
/// To switch it off for one field:
///
/// ```dart
/// TextField(magnifierConfiguration: TextMagnifierConfiguration.disabled)
/// ```
class TextMagnifier extends StatefulWidget {
  /// Creates a magnifier that follows [magnifierInfo], which the text field
  /// updates as the drag moves.
  const TextMagnifier({required this.magnifierInfo, super.key});

  /// A configuration that shows a [TextMagnifier] where text is edited by
  /// touch — iOS, Android and Fuchsia — and no magnifier elsewhere.
  static final TextMagnifierConfiguration adaptiveConfiguration =
      TextMagnifierConfiguration(
        // The handle is under the finger; in the lens it would cover the
        // text it points at.
        shouldDisplayHandlesInMagnifier: false,
        magnifierBuilder: (context, controller, magnifierInfo) {
          if (!FinesseTextSelectionControls.usesTouchSelection) return null;
          return TextMagnifier(magnifierInfo: magnifierInfo);
        },
      );

  /// Where the drag is, and the line and field it is in.
  final ValueNotifier<MagnifierInfo> magnifierInfo;

  /// The gap between the bottom of the lens and the line it magnifies.
  static const _gapAboveLine = 12.0;

  @override
  State<TextMagnifier> createState() => _TextMagnifierState();
}

class _TextMagnifierState extends State<TextMagnifier> {
  /// Null until the first placement, which is never animated.
  Offset? _position;
  Offset _focalShift = Offset.zero;

  /// Set while the lens glides to another line.
  Timer? _gliding;

  Size _size = const Size(88, 48);
  double _scale = 1.25;

  @override
  void initState() {
    super.initState();
    widget.magnifierInfo.addListener(_place);
  }

  @override
  void didUpdateWidget(TextMagnifier oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.magnifierInfo != widget.magnifierInfo) {
      oldWidget.magnifierInfo.removeListener(_place);
      widget.magnifierInfo.addListener(_place);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selection = Theme.of(context).textSelectionTheme;
    _size = selection.magnifierSize ?? _size;
    _scale = selection.magnifierScale ?? _scale;
    _place();
  }

  @override
  void dispose() {
    widget.magnifierInfo.removeListener(_place);
    _gliding?.cancel();
    super.dispose();
  }

  Duration get _glide {
    final motion = Motion.of(context);
    // A hop between two lines: short enough to keep up with the finger.
    return motion.reduced || motion.fast == Duration.zero
        ? Duration.zero
        : const Duration(milliseconds: 70);
  }

  void _place() {
    final info = widget.magnifierInfo.value;
    final screen = Offset.zero & MediaQuery.sizeOf(context);
    if (screen.width < _size.width || screen.height < _size.height) return;

    // Along the line with the finger, and no further than the line's ends.
    final x = clampDouble(
      info.globalGesturePosition.dx,
      info.currentLineBoundaries.left,
      info.currentLineBoundaries.right,
    );
    // Centred over that point, its bottom a gap above the line.
    final natural =
        Offset(
          x - _size.width / 2,
          info.caretRect.top - TextMagnifier._gapAboveLine - _size.height,
        ) &
        _size;
    final placed = MagnifierController.shiftWithinBounds(
      rect: natural,
      bounds: screen,
    );

    // The lens shows what is under its focal point. Keep that on the line
    // being edited, and inside the field: a lens pushed in from the screen's
    // edge, or one at the end of a short field, would otherwise show
    // whatever lies beside it.
    final halfSpan = _size.width / 2 / _scale;
    final field = info.fieldBounds;
    final focalX = field.width < halfSpan * 2
        ? field.center.dx
        : clampDouble(
            placed.center.dx,
            field.left + halfSpan,
            field.right - halfSpan,
          );
    final shift = Offset(
      focalX - placed.center.dx,
      info.caretRect.center.dy - placed.center.dy,
    );

    final previous = _position;
    final glide = _glide;
    if (previous != null &&
        placed.top != previous.dy &&
        glide > Duration.zero) {
      _gliding?.cancel();
      _gliding = Timer(glide, () {
        if (mounted) setState(() => _gliding = null);
      });
    }
    setState(() {
      _position = placed.topLeft;
      _focalShift = shift;
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = _position;
    if (position == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final selection = theme.textSelectionTheme;
    final radius =
        selection.magnifierBorderRadius ??
        const BorderRadius.all(Radius.circular(9999));
    final shadows = selection.magnifierShadows ?? const <BoxShadow>[];
    final shape = RoundedRectangleBorder(borderRadius: radius);

    Widget lens = RawMagnifier(
      size: _size,
      magnificationScale: _scale,
      focalPointOffset: _focalShift,
      decoration: MagnifierDecoration(shape: shape),
      // Drawn over the magnified picture, never in it.
      child: DecoratedBox(
        decoration: ShapeDecoration(
          // A breath of the page colour, so the lens reads as a surface
          // over text of any colour.
          color: theme.colorScheme.background.withValues(alpha: .08),
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: selection.magnifierBorderColor ?? theme.colorScheme.border,
            ),
          ),
        ),
      ),
    );
    if (shadows.isNotEmpty) {
      // The lens samples everything painted before it, so the shadow is
      // painted after it — and outside its shape only, as every outer
      // shadow here is.
      lens = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShadowDecoration.box(
          borderRadius: radius,
          shadows: shadows,
        ),
        child: lens,
      );
    }

    return AnimatedPositioned(
      left: position.dx,
      top: position.dy,
      duration: _gliding != null ? _glide : Duration.zero,
      child: IgnorePointer(child: lens),
    );
  }
}
