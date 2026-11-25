import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:finesse/src/utils/separated_iterable.dart';
import 'package:finesse/src/utils/text_editing_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A zero-width space. An empty slot holds it, so that a backspace in an
/// empty slot still changes the text and can move focus to the previous
/// slot.
const kInvisibleCharCode = '​';

/// A one-time password field: one box per character, with the focus moving
/// from slot to slot as the code is typed, pasted or filled in by the
/// platform.
///
/// The value is a string of [maxLength] characters in which a space stands
/// for an empty slot, so a code typed out of order keeps its positions.
/// Like the other fields it is **controlled** when given a [value] — it
/// shows that value, reports edits through [onChanged] and waits to be given
/// the new one — and holds its own state when [value] is null, starting
/// from [initialValue]:
///
/// ```dart
/// OtpField(
///   maxLength: 6,
///   value: _code,
///   onChanged: (code) => setState(() => _code = code),
///   children: const [
///     OtpFieldGroup(
///       children: [OtpFieldSlot(), OtpFieldSlot(), OtpFieldSlot()],
///     ),
///     OtpFieldGroup(
///       children: [OtpFieldSlot(), OtpFieldSlot(), OtpFieldSlot()],
///     ),
///   ],
/// )
/// ```
///
/// Setting the value to `''` from outside clears every slot.
class OtpField extends StatefulWidget {
  /// Creates a one-time password field of [maxLength] slots, laid out by
  /// [children].
  const OtpField({
    super.key,
    required this.maxLength,
    required this.children,
    this.value,
    this.initialValue,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.gap,
    this.jumpToNextWhenFilled = true,
    this.inputFormatters,
    this.keyboardType,
    this.autofillHints = const [AutofillHints.oneTimeCode],
  }) : assert(
         value == null || initialValue == null,
         'Give an OtpField a value (controlled) or an initialValue '
         '(uncontrolled), not both.',
       );

  /// {@template OtpField.maxLength}
  /// The number of characters in the code, and of slots among [children].
  /// {@endtemplate}
  final int maxLength;

  /// {@template OtpField.value}
  /// The code to show, which makes the field controlled: an edit is
  /// reported through [onChanged] and shown once it is handed back here.
  /// Shorter than [maxLength], the remaining slots are empty; a space is an
  /// empty slot. Null lets the field hold its own value.
  /// {@endtemplate}
  final String? value;

  /// {@template OtpField.initialValue}
  /// The code an uncontrolled field starts with. To skip a slot, pass a
  /// space in its place. May not be combined with [value].
  /// {@endtemplate}
  final String? initialValue;

  /// {@template OtpField.onChanged}
  /// Called when the user changes the code, with all [maxLength]
  /// characters: a space stands for an empty slot. A pasted or autofilled
  /// code is reported once, not slot by slot, and a value set from outside
  /// is not reported at all.
  /// {@endtemplate}
  final ValueChanged<String>? onChanged;

  /// {@template OtpField.onCompleted}
  /// Called with the code when the user fills the last empty slot.
  /// {@endtemplate}
  final ValueChanged<String>? onCompleted;

  /// {@template OtpField.enabled}
  /// Whether the input is enabled, defaults to true
  /// {@endtemplate}
  final bool enabled;

  /// {@template OtpField.gap}
  /// The gap between each slot, defaults to 8
  /// {@endtemplate}
  final double? gap;

  /// {@template OtpField.children}
  /// The layout of the field: [OtpFieldGroup]s of [OtpFieldSlot]s, with any
  /// separators between them. Always laid out left to right, as a code is
  /// read, whatever the text direction.
  /// {@endtemplate}
  final List<Widget> children;

  /// {@template OtpField.jumpToNextWhenFilled}
  /// Whether to jump to the next slot when the current slot is filled,
  /// defaults to true
  /// {@endtemplate}
  final bool jumpToNextWhenFilled;

  /// {@template OtpField.inputFormatters}
  /// The input formatters for the input of each slot, unless overridden in the
  /// slot
  /// {@endtemplate}
  final List<TextInputFormatter>? inputFormatters;

  /// {@template OtpField.keyboardType}
  /// The keyboard type for the input of each slot, unless overridden in the
  /// slot
  /// {@endtemplate}
  final TextInputType? keyboardType;

  /// {@template OtpField.autofillHints}
  /// What the platform may fill the slots with. Defaults to
  /// [AutofillHints.oneTimeCode], which is what offers the code from a text
  /// message above the keyboard; the whole code lands in the focused slot
  /// and is spread over the slots like a paste. Pass an empty list to opt
  /// out.
  /// {@endtemplate}
  final Iterable<String> autofillHints;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

/// The state of an [OtpField].
///
/// Its slots and groups register with it to share the value and to move
/// focus between slots.
class _OtpFieldState extends State<OtpField> {
  /// The focus node and controller of each registered slot, in order.
  final registeredOTPs =
      <({FocusNode focusNode, TextEditingController controller})>[];

  /// Per-slot listeners, kept so a slot can be dropped when it unmounts.
  final _slotListeners = <TextEditingController, VoidCallback>{};

  /// The focus ring of the currently focused slot, painted by the strip.
  ///
  /// shadcn lifts the active slot with `z-10` so its ring overlaps the
  /// neighbouring slots; Flutter paints siblings in order, so a slot that
  /// painted its own outward ring would get the next sibling's hairlines
  /// drawn across it. The focused slot therefore publishes its ring here and
  /// [_OtpFieldRingOverlay] paints it after every slot.
  final _focusedRing = ValueNotifier<_OtpFieldRingSpec?>(null);

  // ignore: use_setters_to_change_properties, reads as _hideRing's pair
  void _showRing(_OtpFieldRingSpec? spec) {
    _focusedRing.value = spec;
  }

  void _hideRing(BuildContext slotContext) {
    // Only the owner may clear: when focus moves between slots the loser's
    // notification can arrive after the winner's.
    if (identical(_focusedRing.value?.slotContext, slotContext)) {
      _focusedRing.value = null;
    }
  }

  /// The character in each slot; an empty slot holds an empty string.
  late final values = List<String>.filled(widget.maxLength, '');

  /// The code the slots show, padded with spaces to [OtpField.maxLength]:
  /// what was last reported, or last taken from outside.
  late String _shown;

  /// While true the slots are being written as a whole — a value from
  /// outside, a paste — and their listeners record without reporting.
  bool _silent = false;

  bool _syncScheduled = false;

  /// The number of registered [OtpFieldGroup]s.
  int groups = 0;

  bool get _controlled => widget.value != null;

  String _pad(String? value) {
    final padded = (value ?? '').padRight(widget.maxLength);
    return padded.length > widget.maxLength
        ? padded.substring(0, widget.maxLength)
        : padded;
  }

  @override
  void initState() {
    super.initState();
    _shown = _pad(widget.value ?? widget.initialValue);
  }

  @override
  void dispose() {
    // Slots are unmounted before the strip's own dispose runs, so the
    // notifier is no longer listened to nor written at this point.
    _focusedRing.dispose();
    super.dispose();
  }

  /// Registers a slot and returns its index. The slot takes its character
  /// from the field's value.
  int registerSlot({
    required FocusNode focusNode,
    required TextEditingController controller,
  }) {
    registeredOTPs.add((focusNode: focusNode, controller: controller));

    final index = registeredOTPs.length - 1;

    if (index < _shown.length) {
      if (controller.text == kInvisibleCharCode && _shown[index] != ' ') {
        controller.text = _shown[index];
      }
      // A slot can come with a character of its own.
      values[index] = _characterOf(controller);
    }

    listenToSlot(index);
    return index;
  }

  /// Drops a slot that has unmounted.
  ///
  /// Registration is otherwise append-only, so a strip whose slots remount —
  /// re-keyed, reordered, rebuilt behind an [AnimatedSwitcher] — grows past
  /// [OtpField.maxLength] and then writes out of range in [listenToSlot].
  void unregisterSlot(TextEditingController controller) {
    final listener = _slotListeners.remove(controller);
    if (listener != null) controller.removeListener(listener);
    registeredOTPs.removeWhere(
      (slot) => identical(slot.controller, controller),
    );
  }

  @override
  void didUpdateWidget(covariant OtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Whatever the parent now says is shown: the value it accepted, the one
    // it kept after refusing an edit, or one it set by itself.
    if (_controlled && _pad(widget.value) != _shown) _scheduleSync();
  }

  /// Registers a group and returns its index; the pair of [unregisterGroup].
  int registerGroup() {
    groups++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    return groups - 1;
  }

  /// Drops a group that has unmounted; the pair of [registerGroup].
  void unregisterGroup() {
    if (groups > 0) groups--;
  }

  static String _characterOf(TextEditingController controller) {
    final text = controller.text.replaceAll(kInvisibleCharCode, '');
    if (text.isEmpty || text.trim().isEmpty) return '';
    return text.characters.last;
  }

  /// Starts copying the text of the slot at [index] into [values], and
  /// reporting the change.
  void listenToSlot(int index) {
    final slot = registeredOTPs[index];

    void listener() {
      // Resolved per notification rather than captured: unregistering an
      // earlier slot shifts every later one down.
      final currentIndex = registeredOTPs.indexWhere(
        (s) => identical(s.controller, slot.controller),
      );
      if (currentIndex < 0 || currentIndex >= values.length) return;
      // Anything but an empty slot or a single character is an edit in
      // flight — a key beside the placeholder, a pasted code, a character
      // the formatters may refuse — which the slot settles before anything
      // is recorded: see [settle].
      final text = slot.controller.text;
      final settled =
          text == kInvisibleCharCode ||
          (!text.contains(kInvisibleCharCode) && text.characters.length == 1);
      if (!settled) return;
      values[currentIndex] = _characterOf(slot.controller);
      if (!_silent) _report();
    }

    _slotListeners[slot.controller] = listener;
    slot.controller.addListener(listener);
  }

  /// Called by a slot once it has settled an edit: reads every slot again
  /// and reports. The listeners alone miss an edit that left a slot's text
  /// as it was.
  void settle() {
    for (var i = 0; i < registeredOTPs.length && i < values.length; i++) {
      values[i] = _characterOf(registeredOTPs[i].controller);
    }
    if (!_silent) _report();
  }

  /// Tells the parent what the slots now hold, if that is news.
  void _report() {
    final whole = values.map((value) => value.isEmpty ? ' ' : value).join();
    if (whole == _shown) return;
    final completed = _shown.contains(' ') && !whole.contains(' ');
    _shown = whole;
    widget.onChanged?.call(whole);
    if (completed) widget.onCompleted?.call(whole);
    // A controlled field shows what it is given. The parent usually hands
    // the reported value straight back; if it keeps the old one, the slots
    // go back to it after this frame.
    if (_controlled) _scheduleSync();
  }

  /// After the frame, writes the controlled value into the slots unless
  /// they show it already.
  ///
  /// Not during the build that brings the value: a text field told to
  /// change while its parent is building marks widgets outside that build
  /// dirty (its selection overlay), which the framework refuses.
  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        _syncScheduled = false;
        if (!mounted || !_controlled) return;
        final wanted = _pad(widget.value);
        if (wanted != _shown) _show(wanted);
      })
      ..ensureVisualUpdate();
  }

  /// Writes [padded] into the slots without reporting it.
  void _show(String padded) {
    _silent = true;
    for (var i = 0; i < registeredOTPs.length && i < padded.length; i++) {
      final text = padded[i] == ' ' ? kInvisibleCharCode : padded[i];
      final controller = registeredOTPs[i].controller;
      if (controller.text != text) controller.text = text;
    }
    _silent = false;
    _shown = padded;
  }

  /// Focuses the slot at [index], and empties it when [clear] is true.
  ///
  /// Does nothing when [OtpField.jumpToNextWhenFilled] is false.
  void jumpToSlot(int index, {bool clear = false}) {
    if (!widget.jumpToNextWhenFilled) return;
    if (index >= 0 && index < registeredOTPs.length) {
      final nextSlot = registeredOTPs[index];
      nextSlot.focusNode.requestFocus();
      if (clear) nextSlot.controller.text = kInvisibleCharCode;
    }
  }

  /// Moves focus to the slot after the focused one.
  void jumpToNextSlot() {
    final focusedSlotIndex = registeredOTPs.indexWhere(
      (slot) => slot.focusNode.hasFocus,
    );
    if (focusedSlotIndex == registeredOTPs.length - 1) return;
    jumpToSlot(focusedSlotIndex + 1);
  }

  /// Moves focus to the slot before the focused one, and empties it when
  /// [clear] is true.
  void jumpToPreviousSlot({bool clear = false}) {
    final focusedSlotIndex = registeredOTPs.indexWhere(
      (slot) => slot.focusNode.hasFocus,
    );
    if (focusedSlotIndex == 0) return;
    jumpToSlot(focusedSlotIndex - 1, clear: clear);
  }

  /// Writes [code] into the slots, one character each, starting at the slot
  /// at [from], and moves the focus to the last slot written: what a paste
  /// or an autofilled code does. Characters past the last slot are dropped.
  /// Reported once.
  void spread(String code, {required int from}) {
    final characters = code.characters.toList();
    var last = from;
    _silent = true;
    for (var i = 0; i < characters.length; i++) {
      final index = from + i;
      if (index >= registeredOTPs.length) break;
      registeredOTPs[index].controller.text = characters[i];
      last = index;
    }
    _silent = false;
    _report();
    jumpToSlot(last);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGap = widget.gap ?? 8;
    return Provider(
      data: this,
      child: Disabled(
        disabled: !widget.enabled,
        child: _OtpFieldRingOverlay(
          ring: _focusedRing,
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisSize: MainAxisSize.min,
            children: widget.children.separatedBy(
              SizedBox(width: effectiveGap),
            ),
          ),
        ),
      ),
      notifyUpdate: (_) => true,
    );
  }
}

/// A run of [OtpFieldSlot]s in a [OtpField], drawn as one joined
/// strip. shadcn's `InputOTPGroup`.
class OtpFieldGroup extends StatefulWidget {
  /// Creates a group of [children].
  const OtpFieldGroup({
    super.key,
    required this.children,
  });

  /// The slots in the group, usually [OtpFieldSlot]s.
  final List<Widget> children;

  @override
  State<OtpFieldGroup> createState() => _OtpFieldGroupState();
}

class _OtpFieldGroupState extends State<OtpFieldGroup> {
  late final otpProvider = context.read<_OtpFieldState>();

  @override
  void initState() {
    super.initState();
    otpProvider.registerGroup();
  }

  @override
  void dispose() {
    otpProvider.unregisterGroup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: widget.children,
    );
  }
}

/// A box for one character of a [OtpField]. shadcn's `InputOTPSlot`.
class OtpFieldSlot extends StatefulWidget {
  /// Creates a slot. It must be inside a [OtpField].
  const OtpFieldSlot({
    super.key,
    this.focusNode,
    this.controller,
    this.inputFormatters,
    this.keyboardType,
    this.style,
    this.width,
    this.height,
    this.padding,
    this.decoration,
    this.firstBorderRadius,
    this.lastBorderRadius,
    this.singleBorderRadius,
    this.middleBorderRadius,
    this.initialValue,
    this.textInputAction,
    this.keyboardToolbarBuilder,
  });

  /// {@template OtpFieldSlot.focusNode}
  /// The focus node for the input of the slot
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template OtpFieldSlot.controller}
  /// The controller for the input of the slot
  /// {@endtemplate}
  final FinesseTextEditingController? controller;

  /// {@template OtpFieldSlot.inputFormatters}
  /// The input formatters for the input of the slot
  /// {@endtemplate}
  final List<TextInputFormatter>? inputFormatters;

  /// {@template OtpFieldSlot.keyboardType}
  /// The keyboard type for the input of the slot
  /// {@endtemplate}
  final TextInputType? keyboardType;

  /// {@template OtpFieldSlot.style}
  /// The style for the input of the slot, defaults to
  /// ```dart
  /// textTheme.muted.copyWith(
  ///   color: theme.colorScheme.foreground,
  ///   fontFeatures: const [FontFeature.tabularFigures()],
  /// )
  /// ```
  /// Tabular figures keep every digit the same width without a monospace
  /// font, as the reference's slots do.
  /// {@endtemplate}
  final TextStyle? style;

  /// {@template OtpFieldSlot.width}
  /// The width of the slot, defaults to 40
  /// {@endtemplate}
  final double? width;

  /// {@template OtpFieldSlot.height}
  /// The height of the slot, defaults to 40
  /// {@endtemplate}
  final double? height;

  /// {@template OtpFieldSlot.padding}
  /// The padding of the slot, defaults to [EdgeInsets.zero].
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template OtpFieldSlot.decoration}
  /// The decoration of the slot
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template OtpFieldSlot.firstBorderRadius}
  /// The radius applied to the first slot of each group
  /// {@endtemplate}
  final BorderRadius? firstBorderRadius;

  /// {@template OtpFieldSlot.lastBorderRadius}
  /// The radius applied to the last slot of each group
  /// {@endtemplate}
  final BorderRadius? lastBorderRadius;

  /// {@template OtpFieldSlot.singleBorderRadius}
  /// The radius applied to the single slot of each group.
  /// Used only if the group has only one slot
  /// {@endtemplate}
  final BorderRadius? singleBorderRadius;

  /// {@template OtpFieldSlot.middleBorderRadius}
  /// The radius applied to the middle slots of each group.
  /// If there are 4 slots in a group, the middle slots are the 2nd and 3rd
  /// {@endtemplate}
  final BorderRadius? middleBorderRadius;

  /// {@template OtpFieldSlot.initialValue}
  /// The initial value of the slot.
  /// {@endtemplate}
  final String? initialValue;

  /// {@template OtpFieldSlot.textInputAction}
  /// The text input action for the slot, defaults to null
  /// {@endtemplate}
  final TextInputAction? textInputAction;

  /// {@macro KeyboardToolbar.toolbarBuilder}
  final WidgetBuilder? keyboardToolbarBuilder;

  @override
  State<OtpFieldSlot> createState() => _OtpFieldSlotState();
}

class _OtpFieldSlotState extends State<OtpFieldSlot> {
  late final otpProvider = context.read<_OtpFieldState>();

  /// Grows each rounded corner of [radius] by [delta], leaving square
  /// corners square — what keeps an outward ring concentric with a box that
  /// is only rounded on some corners, like the ends of the OTP strip.
  static BorderRadius _inflateCorners(BorderRadius radius, double delta) {
    Radius inflate(Radius corner) => corner == Radius.zero
        ? Radius.zero
        : Radius.elliptical(corner.x + delta, corner.y + delta);
    return BorderRadius.only(
      topLeft: inflate(radius.topLeft),
      topRight: inflate(radius.topRight),
      bottomLeft: inflate(radius.bottomLeft),
      bottomRight: inflate(radius.bottomRight),
    );
  }

  FocusNode? _focusNode;
  FocusNode get focusNode => widget.focusNode ?? _focusNode!;
  FinesseTextEditingController? _controller;
  FinesseTextEditingController get controller =>
      widget.controller ?? _controller!;
  late final int index;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode(
        onKeyEvent: (node, event) {
          // Handle the arrow keys
          if (event is KeyUpEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            otpProvider.jumpToPreviousSlot();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            otpProvider.jumpToNextSlot();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      );
    }
    if (widget.controller == null) {
      _controller = FinesseTextEditingController();
    }

    controller.text = widget.initialValue ?? kInvisibleCharCode;
    index = otpProvider.registerSlot(
      focusNode: focusNode,
      controller: controller,
    );
    focusNode.addListener(_syncRing);
  }

  /// The ring the strip should paint over the neighbours while this slot is
  /// focused; computed in [build], null when the decorator paints it itself.
  _OtpFieldRingSpec? _ringSpec;

  void _syncRing() {
    if (focusNode.hasFocus) {
      otpProvider._showRing(_ringSpec);
    } else {
      otpProvider._hideRing(context);
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_syncRing);
    otpProvider
      .._hideRing(context)
      ..unregisterSlot(controller);
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watching the OTP provider for changes
    final otpProvider = context.watch<_OtpFieldState>();

    final defaultStyle =
        widget.style ??
        theme.otpFieldTheme.style ??
        theme.textTheme.muted.copyWith(
          color: theme.colorScheme.foreground,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    final firstRadius =
        widget.firstBorderRadius ??
        theme.otpFieldTheme.firstBorderRadius ??
        BorderRadius.only(
          topLeft: theme.radius.topLeft,
          bottomLeft: theme.radius.bottomLeft,
        );

    final lastRadius =
        widget.lastBorderRadius ??
        theme.otpFieldTheme.lastBorderRadius ??
        BorderRadius.only(
          topRight: theme.radius.topRight,
          bottomRight: theme.radius.bottomRight,
        );

    final singleRadius =
        widget.singleBorderRadius ??
        theme.otpFieldTheme.singleBorderRadius ??
        theme.radius;

    final middleRadius =
        widget.middleBorderRadius ??
        theme.otpFieldTheme.middleBorderRadius ??
        BorderRadius.zero;

    final lastIndexForGroup = otpProvider.widget.maxLength / otpProvider.groups;
    final isLastInGroup = (index + 1) % lastIndexForGroup == 0;

    final isFirstInGroup = index % lastIndexForGroup == 0;

    final BorderRadius effectiveRadius;

    if (isFirstInGroup && isLastInGroup) {
      // Radius on all the sides
      effectiveRadius = singleRadius;
    } else {
      if (isFirstInGroup) {
        // only first side radius
        effectiveRadius = firstRadius;
      } else if (isLastInGroup) {
        // only last side radius
        effectiveRadius = lastRadius;
      } else {
        // middle radius
        effectiveRadius = middleRadius;
      }
    }
    final effectiveInputFormatters =
        widget.inputFormatters ?? otpProvider.widget.inputFormatters ?? [];

    final effectiveKeyboardType =
        widget.keyboardType ?? otpProvider.widget.keyboardType;

    // Zero by default, *not* TextField's field padding: 12px on each side of
    // a 36px slot leaves less than a glyph's width for the text, which
    // clipped it and dragged it off-centre.
    final effectivePadding =
        widget.padding ?? theme.otpFieldTheme.padding ?? EdgeInsets.zero;

    // A slot is a fixed box around a single glyph, so it has to grow with the
    // text scale or the digit is clipped.
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final effectiveWidth =
        (widget.width ?? theme.otpFieldTheme.width ?? 40.0) * textScale;
    final effectiveHeight =
        (widget.height ?? theme.otpFieldTheme.height ?? 40.0) * textScale;

    // A focused slot is treated like any other focused field: the border
    // takes the ring colour and the ring itself sits outside it, at the
    // theme's width and opacity. It used to be an opaque 2px border with no
    // ring at all, which read as a different component.
    final defaultDecoration = FinesseDecoration(
      focusedBorder: FinesseBorder.all(color: theme.colorScheme.ring, width: 1),
      border: FinesseBorder(
        top: FinesseBorderSide(color: theme.colorScheme.border, width: 1),
        bottom: FinesseBorderSide(color: theme.colorScheme.border, width: 1),
        right: FinesseBorderSide(color: theme.colorScheme.border, width: 1),
        padding: const EdgeInsets.all(1),
      ),
    );
    final mergedDecoration = defaultDecoration
        .merge(theme.otpFieldTheme.decoration)
        .merge(widget.decoration);

    final effectiveDecoration = mergedDecoration.merge(
      FinesseDecoration(
        border: FinesseBorder(
          borderRadius: effectiveRadius,
          // Same colour whether or not it is drawn: `Border` requires
          // colour-uniform sides before it will paint a radius, and only the
          // ends of the strip are rounded.
          left: FinesseBorderSide(
            color: theme.colorScheme.input,
            width: isFirstInGroup ? 1 : 0,
          ),
        ),
        focusedBorder: FinesseBorder(borderRadius: effectiveRadius),
        // Outside the slot, flush against it, like every other field
        // (`data-[active=true]:ring-3`).
        //
        // The ring is painted on a rect inflated by the ring width, so each
        // *rounded* corner grows by the same amount to stay concentric with
        // the slot's — keeping the slot's radius left a gap at the corners.
        // Square corners stay square. The offset is restated because
        // `FinesseBorder.merge` takes the other's radius *and* offset
        // unconditionally: supplying only the radius here would silently
        // collapse the ring onto the slot's own border.
        secondaryFocusedBorder: FinesseBorder(
          borderRadius: _inflateCorners(effectiveRadius, theme.style.ringWidth),
          offset: theme.style.ringWidth,
        ),
      ),
    );

    // Resolve the ring the decorator would paint for the focused slot —
    // the same merge chain TextField and Decorator apply.
    final textDirection = Directionality.of(context);
    final resolvedDecoration = theme.decoration.merge(
      (theme.textFieldTheme.decoration ?? const FinesseDecoration()).merge(
        effectiveDecoration,
      ),
    );
    final disableSecondaryBorder =
        resolvedDecoration.disableSecondaryBorder ??
        theme.disableSecondaryBorder;
    final hasError = resolvedDecoration.hasError ?? false;
    var ringBorder = resolvedDecoration.secondaryFocusedBorder;
    if ((resolvedDecoration.fallbackToBorder ?? true) && ringBorder == null) {
      ringBorder = resolvedDecoration.secondaryBorder;
    }

    // shadcn lifts the active slot with `z-10` so its ring overlaps the
    // neighbours; Flutter paints siblings in order, so a ring painted by the
    // slot's own decorator gets the next slot's hairlines drawn across it.
    // Instead the ring is published to the strip, which paints it above every
    // slot. The decorator keeps painting it itself in the cases the strip
    // does not reproduce: error rings, and a secondary border that carries
    // layout (a `padding`).
    final liftRing =
        !disableSecondaryBorder &&
        !hasError &&
        ringBorder != null &&
        ringBorder.hasBorder &&
        ringBorder.padding == null;

    _ringSpec = liftRing
        ? _OtpFieldRingSpec(
            slotContext: context,
            border: ringBorder.toBorder(),
            radius:
                ringBorder.borderRadius?.resolve(textDirection) ??
                BorderRadius.zero,
            offset: ringBorder.offset ?? 0,
            textDirection: textDirection,
          )
        : null;
    // Keep a published ring in step with theme changes while focused; the
    // notifier ignores value-equal updates.
    if (focusNode.hasFocus) {
      otpProvider._showRing(_ringSpec);
    }

    final inputDecoration = liftRing
        ? effectiveDecoration.merge(
            const FinesseDecoration(disableSecondaryBorder: true),
          )
        : effectiveDecoration;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        decoration: inputDecoration,
        textAlign: TextAlign.center,
        // RenderEditable reserves `cursorWidth + 1` at the right edge of the
        // line for the caret (regardless of text direction), so centred text
        // sits half of that left of centre — visible in a slot this narrow.
        // Reserving the same amount on the left recentres the glyph on the
        // slot's midline.
        inputPadding: EdgeInsets.only(
          left: (theme.textFieldTheme.cursorWidth ?? 2.0) + 1,
        ),
        textInputAction: widget.textInputAction,
        onChanged: (v) {
          // sanitize the text and format it
          var sanitizedV = v.replaceAll(kInvisibleCharCode, '');
          final result = TextEditingValue(text: sanitizedV);
          final formattedValue = effectiveInputFormatters
              .fold<TextEditingValue>(
                result,
                (TextEditingValue newValue, TextInputFormatter formatter) =>
                    formatter.formatEditUpdate(result, newValue),
              );

          final hasBeenFormatted = formattedValue.text != sanitizedV;
          sanitizedV = formattedValue.text;

          final previousText = controller.previousValue?.text ?? '';
          // In a slot that already held a character, what counts is what
          // was added to it, before or after.
          final held = previousText.replaceAll(kInvisibleCharCode, '');
          if (held.isNotEmpty && sanitizedV.length > held.length) {
            if (sanitizedV.startsWith(held)) {
              sanitizedV = sanitizedV.substring(held.length);
            } else if (sanitizedV.endsWith(held)) {
              sanitizedV = sanitizedV.substring(
                0,
                sanitizedV.length - held.length,
              );
            }
          }

          if (sanitizedV.characters.length > 1) {
            // A pasted or autofilled code. A whole one starts at the first
            // slot wherever the caret was; a shorter one where it was put.
            final whole =
                sanitizedV.characters.length >= otpProvider.widget.maxLength;
            otpProvider.spread(sanitizedV, from: whole ? 0 : index);
          } else {
            if (sanitizedV.isEmpty) {
              controller.text = kInvisibleCharCode;
              // Jump to the previous slot only if the formatter was not
              // applied
              if (!hasBeenFormatted) {
                otpProvider.jumpToPreviousSlot(
                  clear: previousText == kInvisibleCharCode,
                );
              }
            } else {
              controller.value = controller.value.copyWith(
                text: sanitizedV,
                selection: TextSelection.collapsed(offset: sanitizedV.length),
                composing: TextRange.empty,
              );
              otpProvider.jumpToNextSlot();
            }
            otpProvider.settle();
          }
        },
        autofillHints: otpProvider.widget.autofillHints,
        maxLength: otpProvider.widget.maxLength + 1,
        maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
        padding: effectivePadding,
        style: defaultStyle,
        keyboardType: effectiveKeyboardType,
        keyboardToolbarBuilder: widget.keyboardToolbarBuilder,
      ),
    );
  }
}

/// What the strip needs to paint a focused slot's ring: where (the slot's
/// element, resolved to a [RenderBox] at paint time, so the ring follows the
/// slot through relayouts) and how (the resolved outward border).
@immutable
class _OtpFieldRingSpec {
  const _OtpFieldRingSpec({
    required this.slotContext,
    required this.border,
    required this.radius,
    required this.offset,
    required this.textDirection,
  });

  final BuildContext slotContext;
  final Border border;
  final BorderRadius radius;
  final double offset;
  final TextDirection textDirection;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _OtpFieldRingSpec &&
        identical(other.slotContext, slotContext) &&
        other.border == border &&
        other.radius == radius &&
        other.offset == offset &&
        other.textDirection == textDirection;
  }

  @override
  int get hashCode =>
      Object.hash(slotContext, border, radius, offset, textDirection);
}

/// Paints the focused slot's ring after (and therefore above) every slot.
///
/// This is the strip's stand-in for shadcn's `z-10` on the active slot: the
/// ring overlaps the neighbouring slots, and painting it from the slot itself
/// would let the next sibling draw its hairlines across it.
class _OtpFieldRingOverlay extends SingleChildRenderObjectWidget {
  const _OtpFieldRingOverlay({required this.ring, super.child});

  final ValueListenable<_OtpFieldRingSpec?> ring;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderOtpFieldRingOverlay(ring);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderOtpFieldRingOverlay renderObject,
  ) {
    renderObject.ring = ring;
  }
}

class _RenderOtpFieldRingOverlay extends RenderProxyBox {
  _RenderOtpFieldRingOverlay(this._ring);

  ValueListenable<_OtpFieldRingSpec?> _ring;
  ValueListenable<_OtpFieldRingSpec?> get ring => _ring;
  set ring(ValueListenable<_OtpFieldRingSpec?> value) {
    if (identical(value, _ring)) return;
    if (attached) _ring.removeListener(markNeedsPaint);
    _ring = value;
    if (attached) _ring.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _ring.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _ring.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final spec = _ring.value;
    if (spec == null) return;
    final slotBox = spec.slotContext.findRenderObject();
    if (slotBox is! RenderBox || !slotBox.attached || !slotBox.hasSize) return;
    final origin = MatrixUtils.transformPoint(
      slotBox.getTransformTo(this),
      Offset.zero,
    );
    // Same geometry as OutwardBorderPainter: the rect is inflated by the
    // ring's offset and the border strokes inside it, flush with the slot.
    spec.border.paint(
      context.canvas,
      ((origin + offset) & slotBox.size).inflate(spec.offset),
      borderRadius: spec.radius,
      textDirection: spec.textDirection,
    );
  }
}
