import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/haptics.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A row of stars that shows a rating, and takes one when it is given
/// [onChanged].
///
/// ```dart
/// Rating(
///   value: _stars,
///   onChanged: (value) => setState(() => _stars = value),
/// )
/// ```
///
/// Without [onChanged] it is read-only and shows [value] exactly: 4.3
/// fills the fifth star by a third. With it a tap or a drag across the
/// stars rates — whole stars, or halves with [allowHalf] — a mouse previews
/// the rating under it, the arrow keys adjust it, and to assistive
/// technology it is a slider.
class Rating extends StatefulWidget {
  /// Creates a rating.
  const Rating({
    required this.value,
    this.onChanged,
    this.count = 5,
    this.allowHalf = false,
    this.icon,
    this.selectedIcon,
    this.size,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    super.key,
  }) : assert(count > 0, 'A rating has at least one star.');

  /// The rating, from 0 to [count].
  final double value;

  /// Called with the new rating. Null makes the rating read-only.
  final ValueChanged<double>? onChanged;

  /// The number of stars.
  final int count;

  /// Whether half a star can be given.
  final bool allowHalf;

  /// The icon of an empty star. Defaults to a star's outline.
  final Widget? icon;

  /// The icon of a full star. Defaults to a filled star.
  final Widget? selectedIcon;

  /// The size of a star. Defaults to 20, and 24 on a phone.
  final double? size;

  /// The colour of the full stars. Defaults to the scheme's tint.
  final Color? color;

  /// The focus node of the rating.
  final FocusNode? focusNode;

  /// Whether the rating takes the focus when it first appears.
  final bool autofocus;

  /// What is being rated, for assistive technology.
  final String? semanticLabel;

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  /// The rating under the mouse, shown in place of the value.
  double? _preview;
  bool _focused = false;
  bool _touch = false;

  /// How often each star has been chosen: a star pops when its count
  /// changes.
  late var _pops = List.filled(widget.count, 0);

  bool get _interactive => widget.onChanged != null;

  double get _step => widget.allowHalf ? .5 : 1;

  @override
  void didUpdateWidget(Rating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _pops = List.filled(widget.count, 0);
    }
  }

  void _set(double value, {bool pop = true}) {
    final next = value.clamp(0, widget.count).toDouble();
    if (next == widget.value) return;
    if (pop && next > 0) _pops[next.ceil() - 1]++;
    if (_touch) Haptics.selection(context);
    widget.onChanged?.call(next);
  }

  /// The rating a pointer at [dx] along a row [width] wide stands for.
  double _valueAt(double dx, double width) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final along = (rtl ? width - dx : dx) / width * widget.count;
    final snapped = widget.allowHalf
        ? (along * 2).ceil() / 2
        : along.ceilToDouble();
    return snapped.clamp(0, widget.count).toDouble();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_interactive || event is KeyUpEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    _touch = false;
    if (key == LogicalKeyboardKey.arrowUp ||
        key ==
            (rtl
                ? LogicalKeyboardKey.arrowLeft
                : LogicalKeyboardKey.arrowRight)) {
      _set(widget.value + _step);
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key ==
            (rtl
                ? LogicalKeyboardKey.arrowRight
                : LogicalKeyboardKey.arrowLeft)) {
      _set(widget.value - _step);
    } else if (key == LogicalKeyboardKey.home) {
      _set(0);
    } else if (key == LogicalKeyboardKey.end) {
      _set(widget.count.toDouble());
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  String _format(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mobile = theme.formFactor == FormFactor.mobile;
    final size = widget.size ?? (mobile ? 24 : 20);
    // A star's slot: the star and the room that makes it a target.
    final slot = size + (mobile ? 12 : 6);
    final height = _interactive && mobile ? 44.0 : slot;
    final color = widget.color ?? scheme.tint;
    final shown = _preview ?? widget.value;
    final l = FinesseLocalizations.of(context);

    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.count; i++)
          SizedBox(
            width: slot,
            height: height,
            child: Center(
              child: PopOnChange(
                value: _pops[i],
                child: _Star(
                  fill: (shown - i).clamp(0, 1).toDouble(),
                  size: size,
                  color: color,
                  emptyColor: scheme.mutedForeground.withValues(
                    alpha: scheme.mutedForeground.a * .45,
                  ),
                  icon: widget.icon,
                  selectedIcon: widget.selectedIcon,
                ),
              ),
            ),
          ),
      ],
    );

    final value = l.rating.value(
      value: _format(widget.value),
      count: widget.count,
    );
    if (!_interactive) {
      return Semantics(
        label: widget.semanticLabel,
        value: value,
        readOnly: true,
        child: ExcludeSemantics(child: stars),
      );
    }

    final width = slot * widget.count;
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: value,
      increasedValue: widget.value < widget.count
          ? l.rating.value(
              value: _format(
                (widget.value + _step).clamp(0, widget.count).toDouble(),
              ),
              count: widget.count,
            )
          : null,
      decreasedValue: widget.value > 0
          ? l.rating.value(
              value: _format(
                (widget.value - _step).clamp(0, widget.count).toDouble(),
              ),
              count: widget.count,
            )
          : null,
      onIncrease: widget.value < widget.count
          ? () => _set(widget.value + _step)
          : null,
      onDecrease: widget.value > 0 ? () => _set(widget.value - _step) : null,
      // Keys bubble up from the node that has the focus, so the handler is
      // above it.
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: FocusableActionDetector(
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (value) {
            if (_focused != value) setState(() => _focused = value);
          },
          child: MouseRegion(
            onHover: (event) {
              final preview = _valueAt(event.localPosition.dx, width);
              if (preview != _preview) setState(() => _preview = preview);
            },
            onExit: (_) {
              if (_preview != null) setState(() => _preview = null);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _touch = details.kind == PointerDeviceKind.touch,
              onTapUp: (details) =>
                  _set(_valueAt(details.localPosition.dx, width)),
              onHorizontalDragStart: (details) =>
                  _touch = details.kind == PointerDeviceKind.touch,
              // A drag scrubs through the stars; only the one it ends on
              // pops.
              onHorizontalDragUpdate: (details) => _set(
                _valueAt(details.localPosition.dx, width),
                pop: false,
              ),
              onHorizontalDragEnd: (_) {
                if (widget.value > 0) {
                  setState(() => _pops[widget.value.ceil() - 1]++);
                }
              },
              child: FocusRing(
                visible: _focused,
                borderRadius: theme.radii.md,
                child: ExcludeSemantics(child: stars),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One star: the empty icon, with the full one over the part of it that
/// is filled.
class _Star extends StatelessWidget {
  const _Star({
    required this.fill,
    required this.size,
    required this.color,
    required this.emptyColor,
    required this.icon,
    required this.selectedIcon,
  });

  final double fill;
  final double size;
  final Color color;
  final Color emptyColor;
  final Widget? icon;
  final Widget? selectedIcon;

  @override
  Widget build(BuildContext context) {
    final empty = IconTheme.merge(
      data: IconThemeData(size: size, color: emptyColor),
      child: icon ?? const PhosphorIcon(PhosphorIconsRegular.star),
    );
    if (fill <= 0) return empty;
    final full = IconTheme.merge(
      data: IconThemeData(size: size, color: color),
      child: selectedIcon ?? const PhosphorIcon(PhosphorIconsFill.star),
    );
    if (fill >= 1) return full;
    return Stack(
      children: [
        empty,
        ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: fill,
            // Without it the box would be as tall as its parent allows,
            // and the two stars would part.
            heightFactor: 1,
            child: full,
          ),
        ),
      ],
    );
  }
}
