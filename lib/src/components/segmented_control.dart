import 'package:finesse/src/components/tab_list.dart';
import 'package:finesse/src/liquid_glass/controls.dart';
import 'package:finesse/src/liquid_glass/liquid_glass.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// One choice of a [SegmentedControl].
///
/// It has a [label], an [icon] or both. An icon on its own needs a
/// [semanticLabel], and is helped by a [tooltip].
@immutable
class Segment<T> {
  /// Creates a segment that stands for [value].
  const Segment({
    required this.value,
    this.label,
    this.icon,
    this.enabled = true,
    this.tooltip,
    this.semanticLabel,
  }) : assert(
         label != null || icon != null,
         'A segment needs a label or an icon.',
       );

  /// What the control's value is when this segment is chosen.
  final T value;

  /// The text of the segment, usually a [Text]. One line; in a segment too
  /// narrow for it, it ends in an ellipsis.
  final Widget? label;

  /// An icon, before the [label] or on its own.
  final Widget? icon;

  /// Whether this segment can be chosen.
  final bool enabled;

  /// Shown when the pointer rests on the segment.
  final String? tooltip;

  /// Read by a screen reader in place of the [label].
  final String? semanticLabel;
}

/// Picks one of a few values that are all in view: a unit, a density,
/// light or dark.
///
/// ```dart
/// SegmentedControl<ThemeMode>(
///   value: mode,
///   onChanged: (value) => setState(() => mode = value),
///   segments: const [
///     Segment(value: ThemeMode.light, label: Text('Light')),
///     Segment(value: ThemeMode.dark, label: Text('Dark')),
///     Segment(value: ThemeMode.system, label: Text('System')),
///   ],
/// )
/// ```
///
/// A filled strip with a raised thumb on the chosen segment. The thumb is
/// one shape: it slides to the segment that was chosen on the theme's
/// `Motion.snappy`, stretching a little on the way, and with reduced motion
/// it is simply there. On a touch screen a finger dragged along the strip
/// takes the thumb with it, as the system's control does.
///
/// It is as wide as its segments unless [expand] is set; a height comes
/// from the style and grows with the text scale.
///
/// The control is one stop for the Tab key, on the chosen segment; the
/// arrow keys, Home and End change the value. A screen reader is told it is
/// a group of radio buttons — name the group with a `Semantics` label
/// around it, or the `label` of a form field.
///
/// It has the look of a `TabBar` with `TabBarVariant.segmented`, and they
/// are styled by the same `TabsTheme`. The difference is what they mean: a
/// tab bar shows one of several views, this picks a value. Where none or
/// several can be on — bold, italic, underline — use a `ToggleGroup`.
class SegmentedControl<T> extends StatelessWidget {
  /// Creates a segmented control.
  const SegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.expand = false,
    this.enabled = true,
    super.key,
  });

  /// The choices, in order.
  final List<Segment<T>> segments;

  /// The chosen value. With a value no segment has, none is chosen and the
  /// thumb fades out.
  final T? value;

  /// Called with the value of the segment the user chose. Null makes the
  /// control inert, as [enabled] set to false does.
  final ValueChanged<T>? onChanged;

  /// Whether the segments share the width there is. By default the control
  /// is as wide as its segments.
  final bool expand;

  /// Whether the value can be changed.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final onChanged = enabled ? this.onChanged : null;
    final selected = segments.indexWhere((segment) => segment.value == value);
    final theme = Theme.of(context);
    // The glass control needs a selection and segments it can name: a label
    // is a `Text`, or the segment has a semantic label. Anything else stays
    // finesse's own.
    String? labelOf(Segment<T> segment) => switch (segment.label) {
      null => null,
      final Text text when text.data != null => text.data,
      _ => segment.semanticLabel ?? '',
    };
    if (selected >= 0 &&
        segments.every((s) => labelOf(s) != '') &&
        LiquidGlass.isActive(context, theme.tabsTheme.liquidGlass)) {
      return LiquidGlassSegmentedControl(
        segments: [
          for (final segment in segments)
            LiquidGlassSegment(
              label: labelOf(segment),
              icon: segment.icon,
              enabled: segment.enabled,
              tooltip: segment.tooltip,
              semanticLabel: segment.semanticLabel,
            ),
        ],
        selectedIndex: selected,
        onSelected: onChanged == null
            ? null
            : (index) => onChanged(segments[index].value),
        height: theme.style.tabHeight ?? 32,
        expand: expand,
      );
    }
    return TabList(
      items: [
        for (final segment in segments)
          TabListItem(
            leading: segment.label == null ? null : segment.icon,
            enabled: segment.enabled,
            tooltip: segment.tooltip,
            semanticLabel: segment.semanticLabel,
            child: segment.label ?? segment.icon!,
          ),
      ],
      selectedIndex: selected < 0 ? null : selected,
      onSelected: onChanged == null
          ? null
          : (index) => onChanged(segments[index].value),
      variant: TabBarVariant.segmented,
      expand: expand,
      radioGroup: true,
      slide: true,
    );
  }
}
