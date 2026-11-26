import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The sections of the editor's "All settings", in the order they show.
enum StyleFieldGroup {
  layout('Page and spacing'),
  type('Type'),
  glass('Glass and surfaces'),
  focusMotion('Focus and motion'),
  buttons('Buttons'),
  fields('Fields'),
  controls('Checkboxes, switches and sliders'),
  surfaces('Cards, dialogs and popovers'),
  menus('Menus and command'),
  navigation('Bars, tabs and navigation'),
  content('Lists, chips and content');

  const StyleFieldGroup(this.label);

  final String label;
}

/// The control that edits a field.
enum StyleFieldKind {
  /// A length or a count: a number field.
  number,

  /// An opacity or a strength between 0 and 1: a slider.
  fraction,

  /// A switch.
  toggle,

  /// A step of the radius scale.
  radius,

  /// A surface fill.
  fill,

  /// A shadow, from Tailwind's scale.
  shadow,

  /// A text role: size, line height, weight, tracking, case.
  textRole,

  /// The style's motion.
  motion,
}

/// One `StyleTokens` field: what it is, how to read and write it, and how
/// to write a value of it as Dart.
///
/// The table of every field is generated (`style_fields.g.dart`).
@immutable
class StyleField {
  const StyleField({
    required this.name,
    required this.group,
    required this.kind,
    required this.doc,
    required this.read,
    required this.write,
    this.nullable = false,
  });

  final String name;
  final StyleFieldGroup group;
  final StyleFieldKind kind;

  /// The first sentence of the field's documentation.
  final String doc;

  /// Whether the field may be null, which means "follow another field"
  /// (a dark value following the light one).
  final bool nullable;

  final Object? Function(StyleTokens tokens) read;
  final StyleTokens Function(StyleTokens tokens, Object value) write;

  /// The name in words: `buttonHeightSm` is "Button height sm".
  String get label {
    final words = name
        .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .toLowerCase();
    return words[0].toUpperCase() + words.substring(1);
  }

  /// The slider's range for a [StyleFieldKind.fraction], or the number
  /// field's for a [StyleFieldKind.number].
  ({double min, double max, double step}) get range => switch (kind) {
    StyleFieldKind.fraction => (min: 0, max: 1, step: .01),
    _ when name == 'glassSaturation' => (min: 0, max: 3, step: .05),
    _ when name.endsWith('Scale') => (min: .5, max: 2, step: .05),
    _ when name == 'pageMaxWidth' => (min: 320, max: 2400, step: 8),
    _ => (min: 0, max: 400, step: name.contains('Offset') ? .5 : 1),
  };

  /// [value] as the Dart expression that writes it in a `copyWith`.
  String toSource(Object value) => switch (value) {
    final double v => _number(v),
    final bool v => '$v',
    final RadiusToken v => 'RadiusToken.${v.name}',
    final SurfaceFill v => 'SurfaceFill.${v.name}',
    final List<BoxShadow> v => shadowName(v) ?? '[/* custom shadow */]',
    final TextRole v => textRoleSource(v),
    final Motion v => 'Motion.${motionName(v) ?? 'calm'}',
    _ => '$value',
  };

  /// Tailwind's shadows by name, as the editor offers them.
  static const shadows = <String, List<BoxShadow>>{
    'none': Shadows.none,
    'xs': Shadows.xs,
    'sm': Shadows.sm,
    'regular': Shadows.regular,
    'md': Shadows.md,
    'lg': Shadows.lg,
    'xl': Shadows.xl,
    'xl2': Shadows.xl2,
  };

  /// The motions a style can take, by name.
  static const motions = <String, Motion>{
    'lively': Motion.lively,
    'calm': Motion.calm,
    'none': Motion.none,
  };

  /// `Shadows.x` for one of Tailwind's shadows, or null for any other.
  static String? shadowName(List<BoxShadow> shadow) {
    for (final MapEntry(:key, :value) in shadows.entries) {
      if (listEquals(value, shadow)) return 'Shadows.$key';
    }
    return null;
  }

  /// The name of a [Motion] preset, or null for a motion of its own.
  static String? motionName(Motion motion) {
    for (final MapEntry(:key, :value) in motions.entries) {
      if (value == motion) return key;
    }
    return null;
  }

  static String textRoleSource(TextRole role) => [
    'TextRole(fontSize: ${_number(role.fontSize)}',
    if (role.height case final h?) 'height: ${_number(h)}',
    if (role.fontWeight case final w?) 'fontWeight: FontWeight.w${w.value}',
    if (role.letterSpacing case final s?) 'letterSpacing: ${_number(s)}',
    if (role.uppercase) 'uppercase: true',
  ].join(', ').replaceFirst(RegExp(r'$'), ')');
}

/// `1` rather than `1.0`, and no binary-fraction noise.
String _number(double value) {
  final rounded = double.parse(value.toStringAsFixed(3));
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

/// The `StyleTokens` fields set by hand for one token set, by field name.
///
/// A value type: two configurations with the same edits are equal, so a
/// rebuild with nothing changed is not a theme change.
@immutable
class StyleEdits {
  const StyleEdits([this.values = const {}]);

  final Map<String, Object> values;

  bool get isEmpty => values.isEmpty;

  Object? operator [](String name) => values[name];

  StyleEdits withValue(String name, Object? value) {
    final next = {...values};
    if (value == null) {
      next.remove(name);
    } else {
      next[name] = value;
    }
    return StyleEdits(Map.unmodifiable(next));
  }

  /// [tokens] with these fields set, in the order the table lists them.
  StyleTokens apply(StyleTokens tokens, List<StyleField> fields) {
    var result = tokens;
    for (final field in fields) {
      final value = values[field.name];
      if (value != null) result = field.write(result, value);
    }
    return result;
  }

  static bool _same(Object? a, Object? b) =>
      a is List && b is List ? listEquals(a, b) : a == b;

  @override
  bool operator ==(Object other) {
    if (other is! StyleEdits || other.values.length != values.length) {
      return false;
    }
    for (final MapEntry(:key, :value) in values.entries) {
      if (!other.values.containsKey(key) || !_same(other.values[key], value)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered([
    for (final MapEntry(:key, :value) in values.entries)
      Object.hash(key, value is List ? Object.hashAll(value) : value),
  ]);
}
