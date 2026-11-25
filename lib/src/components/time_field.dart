import 'package:finesse/src/components/select.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Whether a [TimeOfDay] is before or after noon.
enum DayPeriod {
  /// Ante meridiem: before noon.
  am,

  /// Post meridiem: after noon.
  pm,
}

/// A time of day: an hour, a minute and a second, with no date and no time
/// zone.
@immutable
class TimeOfDay implements Comparable<TimeOfDay> {
  /// Creates a time of day.
  ///
  /// [hour] is from 0 to 23, [minute] and [second] from 0 to 59.
  const TimeOfDay({required this.hour, required this.minute, this.second = 0})
    : assert(hour >= 0 && hour < hoursPerDay, 'hour must be 0 to 23'),
      assert(minute >= 0 && minute < minutesPerHour, 'minute must be 0 to 59'),
      assert(
        second >= 0 && second < secondsPerMinute,
        'second must be 0 to 59',
      );

  /// The time of day of [time], in its own time zone.
  TimeOfDay.fromDateTime(DateTime time)
    : hour = time.hour,
      minute = time.minute,
      second = time.second;

  /// The time of day [seconds] seconds after midnight, wrapped to one day.
  factory TimeOfDay.fromSeconds(int seconds) {
    final s = seconds % (hoursPerDay * 3600);
    return TimeOfDay(hour: s ~/ 3600, minute: s % 3600 ~/ 60, second: s % 60);
  }

  /// The time of day it is now, in the local time zone.
  TimeOfDay.now() : this.fromDateTime(DateTime.now());

  /// The hour, on the 24-hour clock: 0 to 23.
  final int hour;

  /// The minute: 0 to 59.
  final int minute;

  /// The second: 0 to 59.
  final int second;

  /// The number of hours in one day, 24.
  static const int hoursPerDay = 24;

  /// The number of hours in one [DayPeriod], 12.
  static const int hoursPerPeriod = 12;

  /// The number of minutes in one hour, 60.
  static const int minutesPerHour = 60;

  /// The number of seconds in one minute, 60.
  static const int secondsPerMinute = 60;

  /// Whether this time is before or after noon.
  DayPeriod get period => hour < hoursPerPeriod ? DayPeriod.am : DayPeriod.pm;

  /// The hour on the 12-hour clock: 12, then 1 to 11.
  int get hourOfPeriod {
    final h = hour % hoursPerPeriod;
    return h == 0 ? hoursPerPeriod : h;
  }

  /// The seconds since midnight.
  int get inSeconds => hour * 3600 + minute * 60 + second;

  /// Whether this time is earlier in the day than [other].
  bool isBefore(TimeOfDay other) => compareTo(other) < 0;

  /// Whether this time is later in the day than [other].
  bool isAfter(TimeOfDay other) => compareTo(other) > 0;

  /// This time, or the nearer of [min] and [max] when it lies outside them.
  TimeOfDay clamp(TimeOfDay? min, TimeOfDay? max) {
    if (min != null && isBefore(min)) return min;
    if (max != null && isAfter(max)) return max;
    return this;
  }

  /// This time with its hour moved into [period], the hour of the period
  /// kept: 3 pm in the morning is 3 am.
  TimeOfDay withPeriod(DayPeriod period) => copyWith(
    hour: hour % hoursPerPeriod + (period == DayPeriod.pm ? 12 : 0),
  );

  /// Returns a copy with the given fields replaced.
  TimeOfDay copyWith({int? hour, int? minute, int? second}) {
    return TimeOfDay(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  @override
  int compareTo(TimeOfDay other) => inSeconds.compareTo(other.inSeconds);

  @override
  bool operator ==(Object other) {
    return other is TimeOfDay &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() {
    String two(int value) => value.toString().padLeft(2, '0');
    return '$TimeOfDay(${two(hour)}:${two(minute)}:${two(second)})';
  }
}

/// Whether times are written on the 24-hour clock at [context].
///
/// True when the platform asks for it (`MediaQuery.alwaysUse24HourFormat`),
/// and otherwise by the locale: the 12-hour clock with a day period is used
/// for English outside the United Kingdom and Ireland and for a handful of
/// other languages, the 24-hour clock everywhere else.
bool uses24HourFormat(BuildContext context) {
  if (MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false) return true;
  final locale = Localizations.maybeLocaleOf(context);
  if (locale == null) return true;
  const twelveHourLanguages = {'ar', 'bn', 'hi', 'ko', 'ur'};
  if (twelveHourLanguages.contains(locale.languageCode)) return false;
  if (locale.languageCode == 'en') {
    return const {'GB', 'IE'}.contains(locale.countryCode);
  }
  return true;
}

/// A time typed into two or three small fields — hours, minutes and,
/// optionally, seconds — with a day period beside them on the 12-hour clock.
///
/// ```dart
/// TimeField(
///   value: _alarm,
///   onChanged: (time) => setState(() => _alarm = time),
/// )
/// ```
///
/// It is the inline, keyboard-first way to enter a time; `TimePicker` is
/// the button that opens one of these in a popover, or wheels in a sheet on
/// a phone.
///
/// [onChanged] is called once every field that shows holds a number, and
/// again on each change after that. Give [value] to hold the time yourself,
/// or [initialValue] to let the field keep it. Because the fields can be
/// half filled, a [value] is only written into them when it changes.
class TimeField extends StatefulWidget {
  /// Creates a time field.
  const TimeField({
    this.value,
    this.initialValue,
    this.onChanged,
    this.use24HourFormat,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = false,
    this.showLabels = true,
    this.min,
    this.max,
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
       ),
       assert(
         showHours || showMinutes || showSeconds,
         'A time field shows at least one of hours, minutes and seconds.',
       );

  /// The time the field shows. Writing a new one replaces what is typed.
  final TimeOfDay? value;

  /// The time the field starts with when it keeps its own state.
  final TimeOfDay? initialValue;

  /// Called with the time once every field that shows is filled, and on
  /// each change after that.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Whether the hours run from 0 to 23, with no day period. Defaults to
  /// what [uses24HourFormat] says for the platform and the locale.
  final bool? use24HourFormat;

  /// Whether the hours field shows.
  final bool showHours;

  /// Whether the minutes field shows.
  final bool showMinutes;

  /// Whether the seconds field shows.
  final bool showSeconds;

  /// Whether each field has its name above it.
  final bool showLabels;

  /// The earliest time that can be entered. An earlier one is moved to it
  /// when the focus leaves the field.
  final TimeOfDay? min;

  /// The latest time that can be entered. A later one is moved to it when
  /// the focus leaves the field.
  final TimeOfDay? max;

  /// A widget before the fields.
  final Widget? leading;

  /// A widget after the fields.
  final Widget? trailing;

  /// The decoration of each field, merged over the theme's.
  final FinesseDecoration? decoration;

  /// Whether the time can be edited.
  final bool enabled;

  /// The focus node of the first field.
  final FocusNode? focusNode;

  /// Whether the first field takes the focus when it first appears.
  final bool autofocus;

  /// {@macro KeyboardToolbar.toolbarBuilder}
  final WidgetBuilder? keyboardToolbarBuilder;

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  final _hour = _TimeTextController(max: 23);
  final _minute = _TimeTextController();
  final _second = _TimeTextController();
  DayPeriod? _period;

  /// The last complete time: what was reported, or given by the parent.
  TimeOfDay? _time;
  bool? _twentyFour;

  FocusNode? _ownFirstNode;
  final _minuteNode = FocusNode(debugLabel: 'TimeField minutes');
  final _secondNode = FocusNode(debugLabel: 'TimeField seconds');
  final _periodNode = FocusNode(debugLabel: 'TimeField period');

  /// The node of the first field: the one a form focuses.
  FocusNode get _firstNode =>
      widget.focusNode ??
      (_ownFirstNode ??= FocusNode(debugLabel: 'TimeField'));

  @override
  void initState() {
    super.initState();
    _time = widget.value ?? widget.initialValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final twentyFour = widget.use24HourFormat ?? uses24HourFormat(context);
    if (twentyFour != _twentyFour) {
      _twentyFour = twentyFour;
      _hour.max = twentyFour ? 23 : 12;
      _write(_time);
    }
  }

  @override
  void didUpdateWidget(TimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.use24HourFormat != oldWidget.use24HourFormat) {
      final twentyFour = widget.use24HourFormat ?? uses24HourFormat(context);
      if (twentyFour != _twentyFour) {
        _twentyFour = twentyFour;
        _hour.max = twentyFour ? 23 : 12;
        _write(_time);
      }
    }
    if (widget.value != oldWidget.value && widget.value != _time) {
      _time = widget.value;
      _write(_time);
    }
  }

  @override
  void dispose() {
    _hour.dispose();
    _minute.dispose();
    _second.dispose();
    _ownFirstNode?.dispose();
    _minuteNode.dispose();
    _secondNode.dispose();
    _periodNode.dispose();
    super.dispose();
  }

  /// Puts [time] into the fields.
  void _write(TimeOfDay? time) {
    String two(int value) => value.toString().padLeft(2, '0');
    if (time == null) {
      _hour.text = '';
      _minute.text = '';
      _second.text = '';
      _period = null;
      return;
    }
    _hour.text = two(_twentyFour! ? time.hour : time.hourOfPeriod);
    _minute.text = two(time.minute);
    _second.text = two(time.second);
    _period = time.period;
  }

  /// The time the fields spell, or null while one that shows is empty.
  TimeOfDay? _read() {
    final hour = int.tryParse(_hour.text);
    final minute = int.tryParse(_minute.text);
    final second = int.tryParse(_second.text);
    if (widget.showHours && hour == null) return null;
    if (widget.showMinutes && minute == null) return null;
    if (widget.showSeconds && second == null) return null;
    var effectiveHour = hour ?? _time?.hour ?? 0;
    if (widget.showHours && !_twentyFour!) {
      final period = _period;
      if (period == null) return null;
      effectiveHour =
          effectiveHour % TimeOfDay.hoursPerPeriod +
          (period == DayPeriod.pm ? TimeOfDay.hoursPerPeriod : 0);
    }
    return TimeOfDay(
      hour: effectiveHour,
      // A field that does not show keeps what the time had.
      minute: widget.showMinutes ? minute! : _time?.minute ?? 0,
      second: widget.showSeconds ? second! : _time?.second ?? 0,
    );
  }

  void _changed() {
    final time = _read();
    if (time == null || time == _time) return;
    _time = time;
    widget.onChanged?.call(time);
  }

  /// When the focus leaves: a time outside [TimeField.min] and
  /// [TimeField.max] is moved inside, and single digits are padded.
  void _onFocusChange(bool focused) {
    if (focused) return;
    final time = _read();
    if (time == null) return;
    final clamped = time.clamp(widget.min, widget.max);
    setState(() => _write(clamped));
    if (clamped != _time) {
      _time = clamped;
      widget.onChanged?.call(clamped);
    }
  }

  /// The nodes of the controls that show, in order. The first goes to
  /// whichever field comes first: it is the one a form focuses.
  List<FocusNode> get _order {
    final units = [
      widget.showHours,
      widget.showMinutes,
      widget.showSeconds,
    ].where((shown) => shown).length;
    return [
      ...[_firstNode, _minuteNode, _secondNode].take(units),
      if (widget.showHours && !_twentyFour!) _periodNode,
    ];
  }

  void _focusAfter(FocusNode node) {
    final order = _order;
    final index = order.indexOf(node);
    if (index >= 0 && index + 1 < order.length) {
      order[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final field = theme.timeFieldTheme;
    final l = FinesseLocalizations.of(context);
    final twentyFour = _twentyFour!;

    final style = theme.textTheme.muted
        .copyWith(color: theme.colorScheme.foreground)
        .merge(field.style);
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
    final jump = field.jumpToNextFieldWhenFilled ?? true;
    final gap = field.gap ?? 4;
    final nodes = _order;

    Widget unit({
      required String label,
      required _TimeTextController controller,
      required FocusNode node,
      required bool last,
    }) {
      return _TimeUnitField(
        label: widget.showLabels ? Text(label) : null,
        semanticLabel: label,
        controller: controller,
        focusNode: node,
        autofocus: widget.autofocus && identical(node, nodes.first),
        gap: gap,
        style: style,
        labelStyle: labelStyle,
        placeholderStyle: placeholderStyle,
        width: field.fieldWidth ?? 48,
        padding:
            field.fieldPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: decoration,
        enabled: widget.enabled,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        keyboardToolbarBuilder: widget.keyboardToolbarBuilder,
        onChanged: (text) {
          _changed();
          if (text.length == 2 && jump) _focusAfter(node);
        },
      );
    }

    final showPeriod = widget.showHours && !twentyFour;
    var slot = 0;
    // Beside the fields, not beside their names: centred on a field's
    // height at the foot of the row.
    Widget besideFields(Widget child) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.style.inputHeight),
      child: Align(widthFactor: 1, child: child),
    );
    final children = <Widget>[
      if (widget.leading case final leading?) besideFields(leading),
      if (widget.showHours)
        unit(
          label: l.timePicker.hours,
          controller: _hour,
          node: nodes[slot++],
          last: !widget.showMinutes && !widget.showSeconds && !showPeriod,
        ),
      if (widget.showMinutes)
        unit(
          label: l.timePicker.minutes,
          controller: _minute,
          node: nodes[slot++],
          last: !widget.showSeconds && !showPeriod,
        ),
      if (widget.showSeconds)
        unit(
          label: l.timePicker.seconds,
          controller: _second,
          node: nodes[slot++],
          last: !showPeriod,
        ),
      if (showPeriod)
        MergeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showLabels) ...[
                DefaultTextStyle(
                  style: labelStyle,
                  child: Text(l.timePicker.period),
                ),
                SizedBox(height: gap),
              ],
              SizedBox(
                height: field.periodHeight ?? 36,
                child: Select<DayPeriod>(
                  // Rebuilt when a new time is written from outside: the
                  // select holds its own value.
                  key: ValueKey(_period),
                  focusNode: _periodNode,
                  minWidth: field.periodMinWidth ?? 65,
                  placeholder: Text(
                    l.timePicker.periodPlaceholder,
                    style: theme.textTheme.muted,
                  ),
                  initialValue: _period,
                  decoration:
                      (field.periodDecoration ?? const FinesseDecoration())
                          .merge(
                            widget.decoration,
                          ),
                  enabled: widget.enabled,
                  options: [
                    SelectOption(
                      value: DayPeriod.am,
                      child: Text(l.timePicker.am),
                    ),
                    SelectOption(
                      value: DayPeriod.pm,
                      child: Text(l.timePicker.pm),
                    ),
                  ],
                  selectedOptionBuilder: (context, value) => Text(
                    value == DayPeriod.am ? l.timePicker.am : l.timePicker.pm,
                  ),
                  onChanged: (value) {
                    _period = value;
                    _changed();
                  },
                ),
              ),
            ],
          ),
        ),
      if (widget.trailing case final trailing?) besideFields(trailing),
    ];

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChange,
      child: Wrap(
        direction: field.axis ?? Axis.horizontal,
        spacing: field.spacing ?? 8,
        runSpacing: field.runSpacing ?? 4,
        alignment: field.alignment ?? WrapAlignment.center,
        runAlignment: field.runAlignment ?? WrapAlignment.center,
        // The fields stand on one line, whatever is above them.
        crossAxisAlignment: field.crossAxisAlignment ?? WrapCrossAlignment.end,
        // Hours, then minutes, then seconds, whichever way text runs.
        textDirection: TextDirection.ltr,
        children: children,
      ),
    );
  }
}

/// One of a [TimeField]'s number fields, under its name.
class _TimeUnitField extends StatelessWidget {
  const _TimeUnitField({
    required this.controller,
    required this.focusNode,
    required this.semanticLabel,
    required this.gap,
    required this.style,
    required this.labelStyle,
    required this.placeholderStyle,
    required this.width,
    required this.padding,
    required this.decoration,
    required this.enabled,
    required this.onChanged,
    required this.textInputAction,
    this.label,
    this.autofocus = false,
    this.keyboardToolbarBuilder,
  });

  final Widget? label;
  final String semanticLabel;
  final _TimeTextController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final double gap;
  final TextStyle style;
  final TextStyle labelStyle;
  final TextStyle placeholderStyle;
  final double width;
  final EdgeInsetsGeometry padding;
  final FinesseDecoration decoration;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final TextInputAction textInputAction;
  final WidgetBuilder? keyboardToolbarBuilder;

  @override
  Widget build(BuildContext context) {
    // A fixed box around two digits: like an OTP slot it has to grow with
    // the text scale or the glyphs are clipped.
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // One node per field, named by its label: a screen reader stops on
    // "Hours" once, not on a label and then a nameless text field.
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            DefaultTextStyle(style: labelStyle, child: label!),
            SizedBox(height: gap),
          ],
          SizedBox(
            width: width * textScale,
            child: Semantics(
              label: label == null ? semanticLabel : null,
              child: TextField(
                enabled: enabled,
                focusNode: focusNode,
                autofocus: autofocus,
                style: style,
                placeholderStyle: placeholderStyle,
                controller: controller,
                decoration: decoration,
                placeholder: const Text('00'),
                // The digits sit in the middle of the fixed box, like an OTP
                // slot.
                textAlign: TextAlign.center,
                placeholderAlignment: Alignment.center,
                keyboardType: TextInputType.number,
                textInputAction: textInputAction,
                maxLength: 2,
                showCursor: false,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                padding: padding,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                keyboardToolbarBuilder: keyboardToolbarBuilder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The text of one number field: at most two digits, held between 0 and
/// [max], shown with a leading zero.
class _TimeTextController extends TextEditingController {
  _TimeTextController({this.max = 59});

  /// The largest number the field takes.
  int max;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final number = int.tryParse(value.text);
    if (number == null) return const TextSpan();
    return TextSpan(
      style: style,
      children: [
        if (value.text.length == 1) const TextSpan(text: '0'),
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

  /// A third digit typed into a full field starts a new number; anything
  /// that is not a number empties the field; a number over [max] is [max].
  String _adjust(String text) {
    var adjusted = text;
    if (adjusted.length == 3) adjusted = adjusted.substring(2);
    final number = int.tryParse(adjusted);
    if (number == null) return '';
    if (number > max) return max.toString();
    return adjusted;
  }
}
