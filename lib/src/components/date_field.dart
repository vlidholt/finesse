import 'dart:math' as math;

import 'package:finesse/src/components/date_picker.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

/// One part of a date, as a [DateField] shows it.
enum _Part { day, month, year }

/// A date typed into three small fields — day, month and year, in the
/// order the locale writes them — with a button beside them that opens a
/// calendar.
///
/// ```dart
/// DateField(
///   value: _birthday,
///   max: DateTime.now(),
///   onChanged: (date) => setState(() => _birthday = date),
/// )
/// ```
///
/// It is the keyboard-first way to enter a date someone knows by heart — a
/// birthday, an expiry date — where paging a calendar back thirty years is
/// the slow way; `DatePicker` is the button that shows a calendar or
/// wheels. It is the sibling of `TimeField`, and takes its look from the
/// same theme (`TimeFieldTheme`): each field has a text field's text,
/// outline, fill and height.
///
/// Typing fills a field and moves on to the next once it is full, or once
/// no further digit could follow (a 4 is a whole month). The up and down
/// arrows step the field that has the focus, wrapping at its ends; left
/// and right move between the fields. A two-digit year is taken for the
/// century it most likely means. When the focus leaves, a day the month
/// does not have is moved to its last day, and a date outside [min] and
/// [max] is moved inside.
///
/// [onChanged] is called with the date once all three fields spell one,
/// and with null when a field of a complete date is emptied again. Give
/// [value] to hold the date yourself, or [initialValue] to let the field
/// keep it. Because the fields can be half filled, a [value] is only
/// written into them when it changes.
class DateField extends StatefulWidget {
  /// Creates a date field.
  const DateField({
    this.value,
    this.initialValue,
    this.onChanged,
    this.min,
    this.max,
    this.showLabels = true,
    this.showCalendarButton = true,
    this.presentation = PickerPresentation.auto,
    this.leading,
    this.trailing,
    this.decoration,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.keyboardToolbarBuilder,
    super.key,
  }) : assert(
         value == null || initialValue == null,
         'Give value to control the field or initialValue to seed it, not '
         'both.',
       );

  /// The date the field shows. Writing a new one replaces what is typed.
  final DateTime? value;

  /// The date the field starts with when it keeps its own state.
  final DateTime? initialValue;

  /// Called with the date once every field is filled, on each change after
  /// that, and with null when the fields stop spelling a date.
  final ValueChanged<DateTime?>? onChanged;

  /// The earliest date that can be entered. An earlier one is moved to it
  /// when the focus leaves the field.
  final DateTime? min;

  /// The latest date that can be entered. A later one is moved to it when
  /// the focus leaves the field.
  final DateTime? max;

  /// Whether each field has its name above it.
  final bool showLabels;

  /// Whether a button after the fields opens a calendar to pick the date
  /// from: a popover on a desktop, a sheet on a phone (see [presentation]).
  final bool showCalendarButton;

  /// How the calendar of the button is presented.
  final PickerPresentation presentation;

  /// A widget before the fields.
  final Widget? leading;

  /// A widget after the fields and the calendar button.
  final Widget? trailing;

  /// The decoration of each field, merged over the theme's.
  final FinesseDecoration? decoration;

  /// Whether the date can be edited.
  final bool enabled;

  /// The focus node of the first field.
  final FocusNode? focusNode;

  /// Whether the first field takes the focus when it first appears.
  final bool autofocus;

  /// {@macro KeyboardToolbar.toolbarBuilder}
  final WidgetBuilder? keyboardToolbarBuilder;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  final _controllers = {
    _Part.day: _PartController(digits: 2, max: 31),
    _Part.month: _PartController(digits: 2, max: 12),
    _Part.year: _PartController(digits: 4, max: 9999),
  };

  /// The last complete date: what was reported, or given by the parent.
  DateTime? _date;

  /// The parts in the order the locale writes them.
  List<_Part> _order = const [_Part.day, _Part.month, _Part.year];

  FocusNode? _ownFirstNode;
  final _secondNode = FocusNode(debugLabel: 'DateField second');
  final _thirdNode = FocusNode(debugLabel: 'DateField third');

  /// The node of the first field: the one a form focuses.
  FocusNode get _firstNode =>
      widget.focusNode ??
      (_ownFirstNode ??= FocusNode(debugLabel: 'DateField'));

  List<FocusNode> get _nodes => [_firstNode, _secondNode, _thirdNode];

  static DateTime? _dateOnly(DateTime? date) =>
      date == null ? null : DateTime(date.year, date.month, date.day);

  @override
  void initState() {
    super.initState();
    _date = _dateOnly(widget.value ?? widget.initialValue);
    _write(_date);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _order = _localeOrder(Localizations.maybeLocaleOf(context));
  }

  @override
  void didUpdateWidget(DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = _dateOnly(widget.value);
    if (value != _dateOnly(oldWidget.value) && value != _date) {
      _date = value;
      _write(value);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _ownFirstNode?.dispose();
    _secondNode.dispose();
    _thirdNode.dispose();
    super.dispose();
  }

  /// Day, month and year in the order [locale] writes a numeric date.
  static List<_Part> _localeOrder(Locale? locale) {
    var pattern = 'd/M/y';
    if (locale != null) {
      // Asking about a locale throws while no date symbols are loaded.
      try {
        final tag = locale.toLanguageTag().replaceAll('-', '_');
        final known = DateFormat.localeExists(tag)
            ? tag
            : DateFormat.localeExists(locale.languageCode)
            ? locale.languageCode
            : null;
        if (known != null) {
          pattern = DateFormat.yMd(known).pattern ?? pattern;
        } else if (locale.languageCode == 'en' &&
            const {'US', null}.contains(locale.countryCode)) {
          pattern = 'M/d/y';
        }
      } on Object {
        if (locale.languageCode == 'en' &&
            const {'US', null}.contains(locale.countryCode)) {
          pattern = 'M/d/y';
        }
      }
    }
    final parts = [
      (pattern.indexOf('d'), _Part.day),
      (pattern.indexOf('M'), _Part.month),
      (pattern.indexOf('y'), _Part.year),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final (_, part) in parts) part];
  }

  static int _daysIn(int year, int month) => DateTime(year, month + 1, 0).day;

  int? _number(_Part part) => int.tryParse(_controllers[part]!.text);

  /// Puts [date] into the fields.
  void _write(DateTime? date) {
    _controllers[_Part.day]!.text = date == null ? '' : '${date.day}';
    _controllers[_Part.month]!.text = date == null ? '' : '${date.month}';
    _controllers[_Part.year]!.text = date == null ? '' : '${date.year}';
  }

  /// The date the fields spell, or null while one is empty or they spell
  /// none: the 31st of a month with thirty days, a year still being typed.
  DateTime? _read() {
    final day = _number(_Part.day);
    final month = _number(_Part.month);
    final year = _number(_Part.year);
    if (day == null || month == null || year == null) return null;
    if (day < 1 || month < 1 || year < 1000) return null;
    if (day > _daysIn(year, month)) return null;
    return DateTime(year, month, day);
  }

  void _changed() {
    final date = _read();
    if (date == _date) return;
    _date = date;
    widget.onChanged?.call(date);
  }

  DateTime _clamp(DateTime date) {
    final min = _dateOnly(widget.min);
    final max = _dateOnly(widget.max);
    if (min != null && date.isBefore(min)) return min;
    if (max != null && date.isAfter(max)) return max;
    return date;
  }

  /// The century a year of one or two digits most likely means: this one,
  /// unless that is more than twenty years ahead.
  static int _fullYear(int year) {
    if (year >= 100) return year;
    final now = DateTime.now().year;
    final guess = now - now % 100 + year;
    return guess > now + 20 ? guess - 100 : guess;
  }

  /// When the focus leaves: what was typed is made a date if it nearly is
  /// one, and a date outside [DateField.min] and [DateField.max] is moved
  /// inside.
  void _onFocusChange(bool focused) {
    if (focused) return;
    var day = _number(_Part.day);
    var month = _number(_Part.month);
    var year = _number(_Part.year);
    if (day == null || month == null || year == null) return;
    year = _fullYear(year);
    month = month.clamp(1, 12);
    day = day.clamp(1, _daysIn(year, month));
    final date = _clamp(DateTime(year, month, day));
    setState(() => _write(date));
    if (date != _date) {
      _date = date;
      widget.onChanged?.call(date);
    }
  }

  void _focusAt(int index) {
    if (index >= 0 && index < _nodes.length) _nodes[index].requestFocus();
  }

  /// Moves on once [part] can take no further digit.
  void _advanceIfFull(_Part part, String text, int index) {
    final jump = Theme.of(context).timeFieldTheme.jumpToNextFieldWhenFilled;
    if (!(jump ?? true) || text.isEmpty) return;
    final number = int.tryParse(text);
    final full = switch (part) {
      // A 4 cannot start a day, nor a 2 a month.
      _Part.day => text.length == 2 || (number != null && number > 3),
      _Part.month => text.length == 2 || (number != null && number > 1),
      _Part.year => text.length == 4,
    };
    if (full) _focusAt(index + 1);
  }

  /// Steps [part] by [by], wrapping at its ends. An empty field starts
  /// from today.
  void _step(_Part part, int by) {
    final today = DateTime.now();
    final year = _number(_Part.year);
    final month = _number(_Part.month);
    final current = _number(part);
    final int next;
    switch (part) {
      case _Part.day:
        final days = year != null && month != null && month >= 1 && month <= 12
            ? _daysIn(_fullYear(year), month)
            : 31;
        next = current == null ? today.day : (current - 1 + by) % days + 1;
      case _Part.month:
        next = current == null ? today.month : (current - 1 + by) % 12 + 1;
      case _Part.year:
        next = current == null
            ? today.year
            : (_fullYear(current) + by).clamp(1, 9999);
    }
    _controllers[part]!.text = '$next';
    _changed();
  }

  /// How wide [text] is set in [style].
  static double _textWidth(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width.ceilToDouble();
  }

  KeyEventResult _onKey(_Part part, int index, KeyEvent event) {
    if (event is KeyUpEvent || !widget.enabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _step(part, 1);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _step(part, -1);
    } else if (key == LogicalKeyboardKey.arrowLeft && index > 0) {
      _focusAt(index - 1);
    } else if (key == LogicalKeyboardKey.arrowRight && index < 2) {
      _focusAt(index + 1);
    } else if (key == LogicalKeyboardKey.backspace &&
        _controllers[part]!.text.isEmpty &&
        index > 0) {
      // Backspace in an empty field goes on deleting in the one before.
      _focusAt(index - 1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _picked(DateTime? date) {
    final picked = _dateOnly(date);
    setState(() => _write(picked));
    if (picked != _date) {
      _date = picked;
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final field = theme.timeFieldTheme;
    final l = FinesseLocalizations.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final textScale = textScaler.scale(1);

    final style = theme.textTheme.muted
        .copyWith(color: theme.colorScheme.foreground)
        .merge(field.style)
        // Digits of one width: a date does not shift as it is typed.
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final labelStyle = theme.textTheme.small
        .copyWith(fontSize: 12)
        .merge(field.labelStyle)
        .fallback(color: theme.colorScheme.foreground);
    final placeholderStyle = theme.textTheme.muted.merge(
      field.placeholderStyle,
    );
    // Like TextField: the theme's field decoration is the whole base, so a
    // style whose fields underline keeps underlining here.
    final decoration = (field.fieldDecoration ?? const FinesseDecoration())
        .merge(widget.decoration);
    final gap = field.gap ?? 4;
    final width = field.fieldWidth ?? 48;
    final padding =
        field.fieldPadding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final nodes = _nodes;

    String labelOf(_Part part) => switch (part) {
      _Part.day => l.datePicker.day,
      _Part.month => l.datePicker.month,
      _Part.year => l.datePicker.year,
    };
    // The part's initial, as dates are noted: DD MM YYYY, TT MM JJJJ,
    // JJ MM AAAA.
    String hintOf(_Part part) =>
        labelOf(part).characters.first.toUpperCase() *
        (part == _Part.year ? 4 : 2);
    double hintWidth(_Part part) =>
        _textWidth(hintOf(part), placeholderStyle, textScaler) +
        padding.horizontal +
        (decoration.border?.left?.width ?? 0) +
        (decoration.border?.right?.width ?? 0);
    // A fixed box around its digits: like an OTP slot it has to grow with
    // the text scale or the glyphs are clipped. A year has twice the digits
    // of a day; letters can be wider than digits, and a day and a month
    // are as wide as each other.
    final shortWidth = math.max(
      width * textScale,
      math.max(hintWidth(_Part.day), hintWidth(_Part.month)),
    );
    final yearWidth = math.max(width * 1.5 * textScale, hintWidth(_Part.year));

    Widget part(int index) {
      final part = _order[index];
      final label = labelOf(part);
      final hint = hintOf(part);
      final node = nodes[index];
      final boxWidth = part == _Part.year ? yearWidth : shortWidth;
      // One node per field, named by its label: a screen reader stops on
      // "Day" once, not on a label and then a nameless text field.
      return MergeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLabels) ...[
              DefaultTextStyle(style: labelStyle, child: Text(label)),
              SizedBox(height: gap),
            ],
            SizedBox(
              width: boxWidth,
              child: Semantics(
                label: widget.showLabels ? null : label,
                // The arrows are heard above the field, which would keep
                // them for moving its caret.
                child: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  onKeyEvent: (_, event) => _onKey(part, index, event),
                  child: TextField(
                    enabled: widget.enabled,
                    focusNode: node,
                    autofocus: widget.autofocus && index == 0,
                    style: style,
                    placeholderStyle: placeholderStyle,
                    controller: _controllers[part],
                    decoration: decoration,
                    placeholder: Text(hint),
                    textAlign: TextAlign.center,
                    placeholderAlignment: Alignment.center,
                    keyboardType: TextInputType.number,
                    textInputAction: index == 2
                        ? TextInputAction.done
                        : TextInputAction.next,
                    showCursor: false,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    padding: padding,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (text) {
                      _changed();
                      _advanceIfFull(part, text, index);
                    },
                    keyboardToolbarBuilder: widget.keyboardToolbarBuilder,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Beside the fields, not beside their names: centred on a field's
    // height at the foot of the row.
    Widget besideFields(Widget child) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.style.inputHeight),
      child: Align(widthFactor: 1, child: child),
    );
    final before = [
      if (widget.leading case final leading?) besideFields(leading),
    ];
    final after = [
      if (widget.showCalendarButton)
        DatePicker(
          value: _date,
          onChanged: widget.enabled ? _picked : null,
          min: widget.min,
          max: widget.max,
          presentation: widget.presentation,
          enabled: widget.enabled,
          triggerBuilder: (context, value, toggle) => IconButton.ghost(
            icon: const PhosphorIcon(PhosphorIconsRegular.calendarBlank),
            semanticLabel: l.datePicker.selectDate,
            onPressed: widget.enabled ? toggle : null,
          ),
        ),
      if (widget.trailing case final trailing?) besideFields(trailing),
    ];
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChange,
      child: Wrap(
        spacing: field.spacing ?? 8,
        runSpacing: field.runSpacing ?? 4,
        // The fields stand on one line, whatever is above them.
        crossAxisAlignment: WrapCrossAlignment.end,
        // The fields in the locale's own order, whichever way its text
        // runs: a date in digits is read from its first part to its last.
        // What is beside them still goes at the start and the end.
        textDirection: TextDirection.ltr,
        children: [
          ...rtl ? after.reversed : before,
          for (var i = 0; i < 3; i++) part(i),
          ...rtl ? before.reversed : after,
        ],
      ),
    );
  }
}

/// The text of one part of the date: digits only, at most [digits] of
/// them, held under [max]. A day and a month show with a leading zero.
class _PartController extends TextEditingController {
  _PartController({required this.digits, required this.max});

  final int digits;
  final int max;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (int.tryParse(value.text) == null) return const TextSpan();
    return TextSpan(
      style: style,
      children: [
        if (digits == 2 && value.text.length == 1) const TextSpan(text: '0'),
        TextSpan(text: text),
      ],
    );
  }

  @override
  set text(String newText) {
    value = value.copyWith(
      text: _adjust(newText),
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  @override
  set value(TextEditingValue newValue) {
    final text = _adjust(newValue.text);
    super.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// A digit typed into a full field starts a new number; anything that is
  /// not a number empties the field; a number over [max] is [max].
  String _adjust(String text) {
    var adjusted = text;
    if (adjusted.length > digits) adjusted = adjusted.substring(digits);
    final number = int.tryParse(adjusted);
    if (number == null) return '';
    if (number > max) return max.toString();
    return adjusted;
  }
}
