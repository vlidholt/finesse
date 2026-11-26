import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:una/src/components/control_size.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/text_field.dart';
import 'package:una/src/icons/phosphor_icon.dart';
import 'package:una/src/icons/phosphor_icons_regular.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/form_factor.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/content_switch.dart';
import 'package:una/src/utils/haptics.dart';

/// How a [NumberField] presents itself.
enum NumberFieldVariant {
  /// A text field the number is typed into, with buttons that step it: a
  /// pair of stacked carets at the end on a desktop, a minus at the start
  /// and a plus at the end on a phone.
  field,

  /// A compact pill — minus, the value, plus — with no typing: a quantity
  /// in a cart, a guest count.
  stepper,
}

/// A field for a number: typed, or stepped up and down.
///
/// It is controlled: [value] is what it shows and [onChanged] reports what
/// the user wants it to be.
///
/// ```dart
/// NumberField(
///   value: guests,
///   min: 1,
///   max: 12,
///   onChanged: (value) => setState(() => guests = value?.toInt() ?? 1),
/// )
/// ```
///
/// ## Stepping
///
/// The buttons, and the arrow keys while the field has the focus, change
/// the value by [step]; Shift with an arrow, Page Up and Page Down by
/// [largeStep]; Home and End go to [min] and [max]. A button held down
/// repeats, faster the longer it is held, and stops at a bound. On a touch
/// screen every step is a light tick of haptic feedback.
///
/// ## Typing
///
/// What is typed is reported as soon as it is a number within the bounds;
/// when the field loses the focus, or on Enter, the text is clamped to
/// [min] and [max], rounded to [decimalDigits] and written out again. An
/// emptied field reports null.
///
/// [format] writes and reads the number in a locale's way — a currency, a
/// percentage, grouped thousands:
///
/// ```dart
/// NumberField(
///   value: price,
///   decimalDigits: 2,
///   step: .5,
///   format: NumberFormat.simpleCurrency(locale: 'en_US'),
///   onChanged: (value) => setState(() => price = value),
/// )
/// ```
///
/// To assistive technology the control is adjustable, with its formatted
/// value: the stepper as one node, the field as a node that steps around
/// the text field that is typed in. The buttons are not separate stops.
class NumberField extends StatefulWidget {
  /// Creates a number field.
  const NumberField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.largeStep,
    this.decimalDigits = 0,
    this.format,
    this.variant = NumberFieldVariant.field,
    this.placeholder,
    this.leading,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.decoration,
    this.onSubmitted,
    this.semanticLabel,
    this.size = ControlSize.regular,
  }) : assert(step > 0, 'The step has to be positive.'),
       assert(decimalDigits >= 0, 'A number has no fewer than 0 decimals.'),
       assert(
         min == null || max == null || min <= max,
         'min cannot be greater than max.',
       );

  /// Creates a [NumberFieldVariant.stepper]: a compact pill of a minus, the
  /// value and a plus, with no typing.
  const NumberField.stepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.largeStep,
    this.decimalDigits = 0,
    this.format,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.decoration,
    this.semanticLabel,
    this.size = ControlSize.regular,
  }) : variant = NumberFieldVariant.stepper,
       placeholder = null,
       leading = null,
       readOnly = false,
       onSubmitted = null,
       assert(step > 0, 'The step has to be positive.'),
       assert(decimalDigits >= 0, 'A number has no fewer than 0 decimals.'),
       assert(
         min == null || max == null || min <= max,
         'min cannot be greater than max.',
       );

  /// The number shown; null is an empty field.
  final num? value;

  /// Called with the number the user typed or stepped to, and with null
  /// when the field was emptied. With [decimalDigits] of 0 it is an `int`.
  ///
  /// Null disables the field.
  final ValueChanged<num?>? onChanged;

  /// The least the value may be. Null is no lower bound.
  final num? min;

  /// The most the value may be. Null is no upper bound.
  final num? max;

  /// How much one step changes the value.
  final num step;

  /// How much Shift with an arrow key, Page Up and Page Down change the
  /// value. Defaults to ten times [step].
  final num? largeStep;

  /// How many decimals the value keeps. With 0 it is a whole number.
  final int decimalDigits;

  /// Writes the number, and reads it back from what was typed. Defaults to
  /// plain digits with [decimalDigits] decimals.
  final NumberFormat? format;

  /// Whether the number is typed into a field or only stepped.
  final NumberFieldVariant variant;

  /// Shown while the field is empty.
  final Widget? placeholder;

  /// A widget at the start of the field: a unit, a currency sign.
  final Widget? leading;

  /// Whether the field can be used.
  final bool enabled;

  /// Whether the value can be read, selected and copied but not changed.
  final bool readOnly;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  /// The focus node of the field. One is created when null.
  final FocusNode? focusNode;

  /// Merged over the theme's text field decoration.
  final UnaDecoration? decoration;

  /// Called with the value after Enter committed it.
  final ValueChanged<num?>? onSubmitted;

  /// What assistive technology calls the field.
  final String? semanticLabel;

  /// How large the field is drawn. [ControlSize.sm] is a small button's
  /// height with its text a size down, for a dense panel, and puts the
  /// minus and the plus at the two ends on every form factor, so the value
  /// keeps its room between them.
  final ControlSize size;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final _controller = TextEditingController(text: _write(widget.value));
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  final _repeater = _Repeater();

  /// Whether the stepper shows a focus ring: the focus, by keyboard.
  bool _showFocus = false;

  bool get _enabled => widget.enabled && widget.onChanged != null;
  bool get _editable => _enabled && !widget.readOnly;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
    if (!_editable) _repeater.stop();
    // A rebuild is the parent's word, whether or not the value changed: a
    // parent that refused the last step is asked for it again.
    _known = widget.value;
    // The parent's value wins — except while it only echoes what is being
    // typed: writing "1" back over "1." would eat the point.
    final typing =
        _focusNode.hasFocus && _read(_controller.text) == widget.value;
    if (!typing && _write(widget.value) != _controller.text) {
      _setText(_write(widget.value));
    }
  }

  @override
  void dispose() {
    _repeater.stop();
    (widget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
    _ownFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  // --- Numbers and text --------------------------------------------------

  String _write(num? value) {
    if (value == null) return '';
    final format = widget.format;
    if (format != null) return format.format(value);
    return value.toStringAsFixed(widget.decimalDigits);
  }

  /// The number [text] stands for, or null when it is not one.
  num? _read(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final format = widget.format;
    num? parsed;
    if (format != null) {
      try {
        parsed = format.parse(trimmed);
      } on FormatException {
        parsed = null;
      }
    }
    // A decimal comma is a decimal point to anyone who types one.
    parsed ??= num.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null || parsed.isNaN || parsed.isInfinite) return null;
    return _round(parsed);
  }

  /// [value] at the field's precision: a whole number with no decimals.
  num _round(num value) {
    if (widget.decimalDigits == 0) return value.round();
    return double.parse(value.toStringAsFixed(widget.decimalDigits));
  }

  num _clamp(num value) {
    final min = widget.min;
    final max = widget.max;
    if (min != null && value < min) return _round(min);
    if (max != null && value > max) return _round(max);
    return value;
  }

  bool _inBounds(num value) =>
      (widget.min == null || value >= widget.min!) &&
      (widget.max == null || value <= widget.max!);

  void _setText(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// What the field stands at: the text when it is a number, and
  /// otherwise the value last given or reported — which may be ahead of
  /// the parent's, when steps come faster than it rebuilds.
  num? get _current => widget.variant == NumberFieldVariant.field
      ? _read(_controller.text) ?? _known
      : _known;

  // --- Typing ------------------------------------------------------------

  /// The value the parent last gave or was last told: nothing is reported
  /// twice in a row.
  late num? _known = widget.value;

  void _report(num? value) {
    if (value == _known) return;
    _known = value;
    widget.onChanged?.call(value);
  }

  void _onTyped(String text) {
    if (text.trim().isEmpty) {
      _report(null);
      return;
    }
    final value = _read(text);
    // On the way to a number in bounds — "1" towards "15" — nothing is
    // reported; leaving the field settles it.
    if (value != null && _inBounds(value)) _report(value);
  }

  /// Settles what was typed: clamps it, writes it out and reports it.
  num? _commit() {
    final typed = _read(_controller.text);
    final num? value;
    if (_controller.text.trim().isEmpty) {
      value = null;
    } else if (typed == null) {
      // Not a number: back to what the field stood at.
      value = widget.value;
    } else {
      value = _clamp(typed);
    }
    _setText(_write(value));
    _report(value);
    // A parent that did not take the value keeps the last word.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _focusNode.hasFocus) return;
      if (_write(widget.value) != _controller.text) {
        _setText(_write(widget.value));
      }
    });
    return value;
  }

  void _onFocusChanged() {
    if (widget.variant != NumberFieldVariant.field) return;
    if (!_focusNode.hasFocus && _editable) _commit();
  }

  // --- Stepping ----------------------------------------------------------

  bool _canStep(int direction) {
    if (!_editable) return false;
    final current = _current;
    if (current == null) return true;
    return direction > 0
        ? widget.max == null || current < widget.max!
        : widget.min == null || current > widget.min!;
  }

  /// Moves the value by [by] and says whether it moved.
  bool _stepBy(num by, {bool touch = false}) {
    if (!_editable || by == 0) return false;
    final current = _current;
    // From nothing, the first step lands on the nearest bound to zero.
    final next = current == null ? _clamp(0) : _clamp(_round(current + by));
    if (next == current) return false;
    return _moveTo(next, touch: touch);
  }

  bool _moveTo(num value, {bool touch = false}) {
    if (!_editable) return false;
    final next = _clamp(_round(value));
    if (next == _current && _controller.text == _write(next)) return false;
    if (widget.variant == NumberFieldVariant.field) _setText(_write(next));
    if (touch) Haptics.selection(context);
    _report(next);
    return true;
  }

  num get _largeStep => widget.largeStep ?? widget.step * 10;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !_editable) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final large = HardwareKeyboard.instance.isShiftPressed;
    final stepper = widget.variant == NumberFieldVariant.stepper;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    num? by;
    if (key == LogicalKeyboardKey.arrowUp) {
      by = large ? _largeStep : widget.step;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      by = -(large ? _largeStep : widget.step);
    } else if (key == LogicalKeyboardKey.pageUp) {
      by = _largeStep;
    } else if (key == LogicalKeyboardKey.pageDown) {
      by = -_largeStep;
    } else if (stepper && key == LogicalKeyboardKey.arrowRight) {
      // In a field the horizontal arrows are the caret's.
      by = (rtl ? -1 : 1) * (large ? _largeStep : widget.step);
    } else if (stepper && key == LogicalKeyboardKey.arrowLeft) {
      by = (rtl ? 1 : -1) * (large ? _largeStep : widget.step);
    } else if (key == LogicalKeyboardKey.home && widget.min != null) {
      _moveTo(widget.min!);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.end && widget.max != null) {
      _moveTo(widget.max!);
      return KeyEventResult.handled;
    }
    if (by == null) return KeyEventResult.ignored;
    _stepBy(by);
    return KeyEventResult.handled;
  }

  void _press(int direction, PointerDownEvent event) {
    final touch = event.kind == PointerDeviceKind.touch;
    _repeater.start(
      () => mounted && _stepBy(direction * widget.step, touch: touch),
    );
  }

  // --- Building ----------------------------------------------------------

  List<TextInputFormatter> get _formatters {
    // A format reads what it wrote: a currency sign, grouping, a percent.
    if (widget.format != null) return const [];
    final negative = widget.min == null || widget.min! < 0;
    final decimals = widget.decimalDigits > 0;
    final sign = negative ? '-?' : '';
    final fraction = decimals ? r'([.,]\d*)?' : '';
    final pattern = RegExp(
      '^$sign'
      r'\d*'
      '$fraction'
      r'$',
    );
    return [
      TextInputFormatter.withFunction(
        (oldValue, newValue) =>
            pattern.hasMatch(newValue.text) ? newValue : oldValue,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _current;
    final metrics = ControlMetrics.of(theme, widget.size);
    final height =
        metrics?.height ?? theme.textFieldTheme.constraints?.minHeight ?? 36;

    Widget segment(int direction, IconData icon, _SegmentShape shape) {
      return _Segment(
        icon: icon,
        iconSize: metrics?.iconSize ?? 14,
        shape: shape,
        enabled: _canStep(direction),
        onDown: (event) => _press(direction, event),
        onUp: _repeater.stop,
      );
    }

    final Widget field;
    if (widget.variant == NumberFieldVariant.stepper) {
      field = _buildStepper(context, height, segment);
    } else {
      field = _buildField(context, height, segment);
    }

    final step = widget.step;
    return Semantics(
      label: widget.semanticLabel,
      enabled: _enabled,
      // An adjustable node has to say what it stands at. Around a text
      // field that makes two nodes — this one to step, the field inside it
      // to type in — since a text field's node does not merge into another.
      value: _write(current),
      increasedValue: current != null && _canStep(1)
          ? _write(_clamp(_round(current + step)))
          : null,
      decreasedValue: current != null && _canStep(-1)
          ? _write(_clamp(_round(current - step)))
          : null,
      onIncrease: _canStep(1) ? () => _stepBy(step) : null,
      onDecrease: _canStep(-1) ? () => _stepBy(-step) : null,
      child: field,
    );
  }

  Widget _buildField(
    BuildContext context,
    double height,
    Widget Function(int, IconData, _SegmentShape) segment,
  ) {
    final theme = Theme.of(context);
    final metrics = ControlMetrics.of(theme, widget.size);
    // A minus at the start and a plus at the end: on a phone, and wherever
    // the field is small, where stacked carets are too fine to hit.
    final mobile = theme.formFactor == FormFactor.mobile || metrics != null;
    final direction = Directionality.of(context);
    final base = metrics != null
        ? EdgeInsets.symmetric(horizontal: metrics.paddingX)
        : (theme.textFieldTheme.padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
              .resolve(direction);
    final border = theme.textFieldTheme.decoration?.border;
    final borderWidth = border?.top?.width ?? 1;
    final radius = (border?.borderRadius ?? theme.radius).resolve(direction);
    // On a phone the buttons are touch targets as wide as the field is
    // tall; on a desktop a slim column of two carets.
    final extent = mobile ? height : (height * 2 / 3).roundToDouble();
    final showButtons = !widget.readOnly;

    final ltr = direction == TextDirection.ltr;
    // Between two buttons the value is centred and the hairlines frame it,
    // so it keeps only a sliver of the field's own inset.
    const between = 4.0;
    final padding = EdgeInsetsDirectional.only(
      start: mobile && showButtons
          ? extent + between
          : (ltr ? base.left : base.right),
      end: !showButtons
          ? (ltr ? base.right : base.left)
          : extent + (mobile ? between : (ltr ? base.right : base.left) / 2),
      top: base.top,
      bottom: base.bottom,
    );

    final stack = Stack(
      children: [
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _onKey,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            enabled: _enabled,
            readOnly: widget.readOnly,
            decoration: widget.decoration,
            padding: padding,
            placeholder: widget.placeholder,
            leading: widget.leading,
            textAlign: mobile ? TextAlign.center : TextAlign.start,
            placeholderAlignment: mobile ? Alignment.center : null,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.decimalDigits > 0,
              signed: widget.min == null || widget.min! < 0,
            ),
            inputFormatters: _formatters,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: _onTyped,
            onSubmitted: (_) => widget.onSubmitted?.call(_commit()),
            // Digits of one width: the text does not jiggle as it steps.
            style: (metrics?.textStyle ?? const TextStyle()).copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        if (showButtons) ...[
          if (mobile)
            PositionedDirectional(
              start: borderWidth,
              top: borderWidth,
              bottom: borderWidth,
              width: extent - borderWidth,
              child: _dimmed(
                child: segment(
                  -1,
                  PhosphorIconsRegular.minus,
                  _SegmentShape.start(radius, borderWidth, direction),
                ),
              ),
            ),
          PositionedDirectional(
            end: borderWidth,
            top: borderWidth,
            bottom: borderWidth,
            width: extent - borderWidth,
            child: _dimmed(
              child: mobile
                  ? segment(
                      1,
                      PhosphorIconsRegular.plus,
                      _SegmentShape.end(radius, borderWidth, direction),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: segment(
                            1,
                            PhosphorIconsRegular.caretUp,
                            _SegmentShape.end(
                              radius,
                              borderWidth,
                              direction,
                              bottom: false,
                            ),
                          ),
                        ),
                        // The hairline between the two halves.
                        SizedBox(
                          height: 1,
                          child: ColoredBox(color: theme.colorScheme.input),
                        ),
                        Expanded(
                          child: segment(
                            -1,
                            PhosphorIconsRegular.caretDown,
                            _SegmentShape.end(
                              radius,
                              borderWidth,
                              direction,
                              top: false,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
    // A small field is held to its height; the text field inside would
    // otherwise keep the theme's taller one.
    return metrics == null ? stack : SizedBox(height: height, child: stack);
  }

  /// The buttons are the field's: they dim with it, and assistive
  /// technology steps through the field itself.
  Widget _dimmed({required Widget child}) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: _enabled ? 1 : Theme.of(context).disabledOpacity,
        child: child,
      ),
    );
  }

  Widget _buildStepper(
    BuildContext context,
    double height,
    Widget Function(int, IconData, _SegmentShape) segment,
  ) {
    final theme = Theme.of(context);
    final direction = Directionality.of(context);
    final decoration =
        (theme.textFieldTheme.decoration ?? const UnaDecoration()).merge(
          widget.decoration,
        );
    final border = decoration.border;
    final borderWidth = border?.top?.width ?? 1;
    final radius = (border?.borderRadius ?? theme.radius).resolve(direction);
    final metrics = ControlMetrics.of(theme, widget.size);
    final textStyle =
        (metrics?.textStyle ??
                theme.textTheme.muted.merge(theme.textFieldTheme.style))
            .copyWith(
              color: theme.colorScheme.foreground,
              fontFeatures: const [FontFeature.tabularFigures()],
            );
    final value = widget.value;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    final content = Opacity(
      opacity: _enabled ? 1 : theme.disabledOpacity,
      child: ConstrainedBox(
        // The height is the field's, border included.
        constraints: BoxConstraints(
          minHeight: height,
          maxHeight: metrics == null ? double.infinity : height,
        ),
        child: Decorator(
          decoration: decoration,
          focused: _showFocus,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: height - borderWidth,
                  child: segment(
                    -1,
                    PhosphorIconsRegular.minus,
                    _SegmentShape.start(radius, borderWidth, direction),
                  ),
                ),
                ConstrainedBox(
                  // Room for a few digits, so the pill does not change
                  // width from 9 to 10.
                  constraints: BoxConstraints(
                    minWidth: (textStyle.fontSize ?? 14) * 2.5 * scale,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      widthFactor: 1,
                      child: ContentSwitch(
                        value: value ?? 0,
                        axis: Axis.vertical,
                        child: Text(
                          _write(value),
                          style: textStyle,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: height - borderWidth,
                  child: segment(
                    1,
                    PhosphorIconsRegular.plus,
                    _SegmentShape.end(radius, borderWidth, direction),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Above the node that takes the focus: a key event travels up from it.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: _enabled,
        onShowFocusHighlight: (value) {
          if (value != _showFocus) setState(() => _showFocus = value);
        },
        child: ExcludeSemantics(child: content),
      ),
    );
  }
}

/// Steps once at once, then again and again while the button is held:
/// after a pause, and faster the longer the hold.
class _Repeater {
  Timer? _timer;
  int _ticks = 0;

  static const _delay = Duration(milliseconds: 400);
  static const _slowest = 110.0;
  static const _fastest = 30.0;

  /// Calls [step] now and keeps calling it until it returns false or
  /// [stop] is called.
  void start(bool Function() step) {
    stop();
    if (!step()) return;
    _ticks = 0;
    _timer = Timer(_delay, () => _tick(step));
  }

  void _tick(bool Function() step) {
    if (!step()) {
      stop();
      return;
    }
    _ticks++;
    final interval = math.max(_fastest, _slowest * math.pow(.88, _ticks));
    _timer = Timer(
      Duration(milliseconds: interval.round()),
      () => _tick(step),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

/// The corners of a step button, which fills its end of the field to the
/// inside of the field's border.
class _SegmentShape {
  const _SegmentShape(this.borderRadius, this.divider);

  /// The button at the start of the field.
  factory _SegmentShape.start(
    BorderRadius field,
    double borderWidth,
    TextDirection direction,
  ) {
    final ltr = direction == TextDirection.ltr;
    final top = _inner(ltr ? field.topLeft : field.topRight, borderWidth);
    final bottom = _inner(
      ltr ? field.bottomLeft : field.bottomRight,
      borderWidth,
    );
    return _SegmentShape(
      BorderRadiusDirectional.only(
        topStart: top,
        bottomStart: bottom,
      ).resolve(direction),
      AlignmentDirectional.centerEnd.resolve(direction),
    );
  }

  /// The button at the end of the field, or one half of it.
  factory _SegmentShape.end(
    BorderRadius field,
    double borderWidth,
    TextDirection direction, {
    bool top = true,
    bool bottom = true,
  }) {
    final ltr = direction == TextDirection.ltr;
    return _SegmentShape(
      BorderRadiusDirectional.only(
        topEnd: top
            ? _inner(ltr ? field.topRight : field.topLeft, borderWidth)
            : Radius.zero,
        bottomEnd: bottom
            ? _inner(ltr ? field.bottomRight : field.bottomLeft, borderWidth)
            : Radius.zero,
      ).resolve(direction),
      AlignmentDirectional.centerStart.resolve(direction),
    );
  }

  static Radius _inner(Radius outer, double borderWidth) => Radius.elliptical(
    math.max(0, outer.x - borderWidth),
    math.max(0, outer.y - borderWidth),
  );

  final BorderRadius borderRadius;

  /// The side the hairline that parts the button from the value is on.
  final Alignment divider;
}

/// One step button: an icon on a fill that answers the pointer, with a
/// hairline on the side that faces the value.
class _Segment extends StatefulWidget {
  const _Segment({
    required this.icon,
    required this.iconSize,
    required this.shape,
    required this.enabled,
    required this.onDown,
    required this.onUp,
  });

  final IconData icon;
  final double iconSize;
  final _SegmentShape shape;
  final bool enabled;
  final ValueChanged<PointerDownEvent> onDown;
  final VoidCallback onUp;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  void didUpdateWidget(_Segment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _pressed) _pressed = false;
  }

  void _release() {
    widget.onUp();
    if (_pressed && mounted) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lit = widget.enabled && (_hovered || _pressed);
    final wash = colors.foreground;
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) {
        if (mounted) setState(() => _hovered = false);
      },
      // A listener, not a tap: the step is taken on the way down and
      // repeated for as long as the pointer stays down.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: widget.enabled
            ? (event) {
                if (event.buttons != kPrimaryButton &&
                    event.kind == PointerDeviceKind.mouse) {
                  return;
                }
                setState(() => _pressed = true);
                widget.onDown(event);
              }
            : null,
        onPointerUp: (_) => _release(),
        onPointerCancel: (_) => _release(),
        child: AnimatedFill(
          color: wash.withValues(
            alpha: _pressed && widget.enabled
                ? .1
                : lit
                ? .06
                : 0,
          ),
          borderWidth: 0,
          borderRadius: widget.shape.borderRadius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: widget.shape.divider,
                  child: SizedBox(
                    width: 1,
                    height: double.infinity,
                    child: ColoredBox(color: colors.input),
                  ),
                ),
              ),
              Opacity(
                opacity: widget.enabled ? 1 : .35,
                child: PhosphorIcon(
                  widget.icon,
                  size: widget.iconSize,
                  color: lit ? colors.foreground : colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
