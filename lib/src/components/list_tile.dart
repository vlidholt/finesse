import 'package:finesse/src/components/list_section.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A row with a leading widget, a title, a subtitle and a trailing widget:
/// a conversation, a person to follow, a shared file, a settings entry.
///
/// ```dart
/// ListTile(
///   leading: const Avatar('assets/omar.jpg'),
///   title: const Text('Omar Rahimi'),
///   subtitle: const Text('Design lead at Birchline'),
///   trailing: Button.outline(onPressed: _follow, child: const Text('Follow')),
///   onTap: _openProfile,
/// )
/// ```
///
/// The title and subtitle each truncate to [titleMaxLines] and
/// [subtitleMaxLines]. With an [onTap] the row highlights under the pointer
/// and takes keyboard focus; [selected] gives it the theme's accent fill.
///
/// A settings entry names its current choice with [value] and points onward
/// with [showChevron]:
///
/// ```dart
/// ListTile(
///   title: const Text('Language'),
///   value: const Text('English'),
///   showChevron: true,
///   onTap: _pickLanguage,
/// )
/// ```
///
/// Inside a `ListSection` the tile takes the section's padding and least
/// height, highlights edge to edge — the section's card clips it — and
/// darkens under a press instead of scaling.
class ListTile extends StatelessWidget {
  /// Creates a list tile.
  const ListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.value,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.destructive = false,
    this.padding,
    this.gap,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.focusNode,
    this.mouseCursor,
    super.key,
  });

  /// The widget before the text, usually an avatar or an [Icon].
  final Widget? leading;

  /// The first line.
  final Widget title;

  /// The quieter line under the title.
  final Widget? subtitle;

  /// The row's current value, as quiet text after the title and before
  /// [trailing]: the language a "Language" row is set to, a count, a
  /// status. It gives way to the title: it takes at most two fifths of the
  /// row and ends in an ellipsis.
  final Widget? value;

  /// The widget after the text: a button, a timestamp, a badge, a control.
  final Widget? trailing;

  /// Whether the row ends in a [ListTileChevron], the mark of a row that
  /// leads somewhere.
  final bool showChevron;

  /// Called when the row is tapped. With neither this nor [onLongPress] the
  /// row is inert.
  final VoidCallback? onTap;

  /// Called when the row is pressed and held.
  final VoidCallback? onLongPress;

  /// Whether the row responds. A row that is not enabled is dimmed, takes
  /// no focus and ignores taps on itself; widgets in [trailing] are the
  /// caller's to disable.
  final bool enabled;

  /// Whether the row is the selected one of its list.
  final bool selected;

  /// Whether the row does something that cannot be undone — "Sign out",
  /// "Delete account": its title and leading icon take the destructive
  /// colour.
  final bool destructive;

  /// Padding around the row's content. Defaults to the enclosing
  /// `ListSection`'s, then to the theme's.
  final EdgeInsetsGeometry? padding;

  /// The gap between [leading], the text and [trailing].
  final double? gap;

  /// How [leading] and [trailing] align against the text.
  final CrossAxisAlignment crossAxisAlignment;

  /// The most lines the title wraps to; null for no limit.
  final int? titleMaxLines;

  /// The most lines the subtitle wraps to; null for no limit.
  final int? subtitleMaxLines;

  /// The title's style. Defaults to the theme's.
  final TextStyle? titleStyle;

  /// The subtitle's style. Defaults to the theme's.
  final TextStyle? subtitleStyle;

  /// The corner radius of the highlight.
  final BorderRadius? borderRadius;

  /// The focus node to use.
  final FocusNode? focusNode;

  /// The cursor over a row that responds. Defaults to the click cursor.
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = theme.listTileTheme;
    final scope = ListSectionScope.maybeOf(context);
    final effectiveGap = gap ?? tile.gap ?? 12;
    final dim = enabled ? 1.0 : theme.disabledOpacity;

    Color dimmed(Color color) =>
        dim == 1 ? color : color.withValues(alpha: color.a * dim);

    Widget line(Widget child, TextStyle style, int? maxLines) =>
        DefaultTextStyle.merge(
          style: style,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          child: child,
        );

    // The scheme's colour is a default: a style that states its own colour —
    // the caller's or the theme's — keeps it. A row that is switched off
    // dims whichever it is.
    TextStyle coloured(TextStyle style, Color fallback) {
      if (style.color != null && dim == 1) return style;
      return style.copyWith(color: dimmed(style.color ?? fallback));
    }

    final destructiveColor =
        tile.destructiveColor ?? theme.colorScheme.destructive;
    final baseTitleStyle =
        titleStyle ?? tile.titleStyle ?? theme.textTheme.large;
    final effectiveTitleStyle = destructive
        ? baseTitleStyle.copyWith(color: dimmed(destructiveColor))
        : coloured(baseTitleStyle, theme.colorScheme.foreground);

    // An icon in the row follows the row: the destructive colour on the
    // leading one, and the dimming of a row that is switched off. A layer
    // of opacity would do it for any widget, at the price of a layer per
    // row.
    Widget tinted(Widget child, {bool isLeading = false}) {
      final recolour = destructive && isLeading;
      if (dim == 1 && !recolour) return child;
      final color = recolour
          ? destructiveColor
          : IconTheme.of(context).color ?? theme.colorScheme.foreground;
      return IconTheme.merge(
        data: IconThemeData(color: dimmed(color)),
        child: child,
      );
    }

    final effectivePadding =
        padding ??
        scope?.tilePadding ??
        tile.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    Widget row = Padding(
      padding: effectivePadding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        spacing: effectiveGap,
        children: [
          if (leading != null) tinted(leading!, isLeading: true),
          Expanded(
            child: _TextAndValue(
              gap: effectiveGap,
              textDirection: Directionality.of(context),
              children: [
                ListDividerAnchor(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: tile.titleGap ?? 0,
                    children: [
                      line(title, effectiveTitleStyle, titleMaxLines),
                      if (subtitle != null)
                        line(
                          subtitle!,
                          coloured(
                            subtitleStyle ??
                                tile.subtitleStyle ??
                                theme.textTheme.muted,
                            theme.colorScheme.mutedForeground,
                          ),
                          subtitleMaxLines,
                        ),
                    ],
                  ),
                ),
                if (value != null)
                  DefaultTextStyle.merge(
                    style: coloured(
                      tile.valueStyle ?? theme.textTheme.muted,
                      theme.colorScheme.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    child: value!,
                  ),
              ],
            ),
          ),
          if (trailing != null) tinted(trailing!),
          if (showChevron)
            ListTileChevron(
              color: dimmed(
                tile.chevronColor ?? theme.colorScheme.mutedForeground,
              ),
            ),
        ],
      ),
    );

    // In a section a row is at least a touch target tall. A floor, not a
    // size: taller content, or larger text, makes the row taller.
    final minHeight = scope?.minTileHeight ?? 0;
    if (minHeight > 0) {
      row = ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          heightFactor: 1,
          child: row,
        ),
      );
    }

    // A section's card clips its rows, so their highlight is square and
    // their focus ring is drawn inside, along the card's corners.
    final radius =
        borderRadius ??
        (scope != null ? BorderRadius.zero : tile.borderRadius ?? theme.radius);
    final ringRadius = scope?.rowBorderRadius ?? radius;
    final selectedColor = tile.selectedColor ?? theme.colorScheme.accent;

    if (onTap == null && onLongPress == null) {
      if (!selected) return row;
      // Selected but inert: highlighted, and not announced as a button.
      return Semantics(
        selected: true,
        child: DecoratedBox(
          decoration: BoxDecoration(color: selectedColor, borderRadius: radius),
          child: row,
        ),
      );
    }

    return Pressable(
      onPressed: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      selected: selected ? true : null,
      focusNode: focusNode,
      cursor: mouseCursor ?? SystemMouseCursors.click,
      // The press gives a little, as a surface does; see `Card`. A row of a
      // section fills its card from edge to edge, where shrinking would
      // open a gap along the sides: it darkens instead.
      pressScale: scope != null
          ? 1
          : tile.pressScale ?? Motion.of(context).surfacePressScale,
      builder: (context, states) {
        final color = selected
            ? selectedColor
            : scope != null && states.contains(WidgetState.pressed)
            ? scope.pressedColor
            : states.contains(WidgetState.hovered)
            ? tile.hoverColor ?? theme.colorScheme.muted
            : const Color(0x00000000);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: ringRadius,
          inset: scope != null,
          child: AnimatedFill(
            color: color,
            borderRadius: radius,
            child: row,
          ),
        );
      },
    );
  }
}

/// The mark at the end of a row that leads somewhere: a small caret
/// pointing along the reading direction.
///
/// `ListTile(showChevron: true)` adds one; use the widget itself in a
/// custom row.
class ListTileChevron extends StatelessWidget {
  /// Creates a chevron.
  const ListTileChevron({this.color, this.size, super.key});

  /// The chevron's colour. Defaults to the list tile theme's.
  final Color? color;

  /// The chevron's size. Defaults to the list tile theme's.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = theme.listTileTheme;
    return ExcludeSemantics(
      child: PhosphorIcon(
        Directionality.of(context) == TextDirection.rtl
            ? PhosphorIconsRegular.caretLeft
            : PhosphorIconsRegular.caretRight,
        size: size ?? tile.chevronSize ?? 16,
        color: color ?? tile.chevronColor ?? theme.colorScheme.mutedForeground,
      ),
    );
  }
}

/// Lays the tile's text out beside its value: the value takes the width it
/// needs, up to [_RenderTextAndValue.valueShare] of the room, and the text
/// takes the rest — so a short value costs the title nothing, and a long
/// one cannot push it out.
class _TextAndValue extends MultiChildRenderObjectWidget {
  const _TextAndValue({
    required this.gap,
    required this.textDirection,
    required super.children,
  });

  final double gap;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTextAndValue(gap: gap, textDirection: textDirection);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTextAndValue renderObject,
  ) {
    renderObject
      ..gap = gap
      ..textDirection = textDirection;
  }
}

class _TextAndValueParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderTextAndValue extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TextAndValueParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TextAndValueParentData> {
  _RenderTextAndValue({
    required double gap,
    required TextDirection textDirection,
  }) : _gap = gap,
       _textDirection = textDirection;

  /// The most of the row's text area the value may take.
  static const valueShare = .45;

  double get gap => _gap;
  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox get _text => firstChild!;
  RenderBox? get _value => childAfter(firstChild!);

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TextAndValueParentData) {
      child.parentData = _TextAndValueParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final value = _value;
    return _text.getMinIntrinsicWidth(height) +
        (value == null ? 0 : _gap + value.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final value = _value;
    return _text.getMaxIntrinsicWidth(height) +
        (value == null ? 0 : _gap + value.getMaxIntrinsicWidth(height));
  }

  double _intrinsicHeight(
    double width,
    double Function(RenderBox child, double width) heightOf,
  ) {
    final value = _value;
    if (value == null) return heightOf(_text, width);
    if (!width.isFinite) {
      return [
        heightOf(_text, width),
        heightOf(value, width),
      ].reduce((a, b) => a > b ? a : b);
    }
    final room = (width - _gap).clamp(0.0, double.infinity);
    final valueWidth = value
        .getMaxIntrinsicWidth(double.infinity)
        .clamp(0.0, room * valueShare);
    final valueHeight = heightOf(value, valueWidth);
    final textHeight = heightOf(_text, room - valueWidth);
    return textHeight > valueHeight ? textHeight : valueHeight;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _intrinsicHeight(width, (child, w) => child.getMinIntrinsicHeight(w));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _intrinsicHeight(width, (child, w) => child.getMaxIntrinsicHeight(w));

  ({Size size, Size text, Size? value}) _measure(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints constraints) layoutChild,
  ) {
    final width = constraints.maxWidth;
    final value = _value;
    Size? valueSize;
    var textWidth = width;
    if (value != null) {
      final room = (width - _gap).clamp(0.0, double.infinity);
      valueSize = layoutChild(
        value,
        BoxConstraints(maxWidth: room * valueShare),
      );
      textWidth = room - valueSize.width;
    }
    final textSize = layoutChild(
      _text,
      width.isFinite
          ? BoxConstraints.tightFor(width: textWidth)
          : const BoxConstraints(),
    );
    final height = valueSize == null || textSize.height > valueSize.height
        ? textSize.height
        : valueSize.height;
    final total = width.isFinite
        ? width
        : textSize.width + (valueSize == null ? 0 : _gap + valueSize.width);
    return (
      size: constraints.constrain(Size(total, height)),
      text: textSize,
      value: valueSize,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _measure(
    constraints,
    (child, constraints) => child.getDryLayout(constraints),
  ).size;

  @override
  void performLayout() {
    final measured = _measure(constraints, (child, constraints) {
      child.layout(constraints, parentUsesSize: true);
      return child.size;
    });
    size = measured.size;
    final ltr = _textDirection == TextDirection.ltr;
    final text = measured.text;
    (_text.parentData! as _TextAndValueParentData).offset = Offset(
      ltr ? 0 : size.width - text.width,
      (size.height - text.height) / 2,
    );
    final value = _value;
    if (value != null) {
      final valueSize = measured.value!;
      (value.parentData! as _TextAndValueParentData).offset = Offset(
        ltr ? size.width - valueSize.width : 0,
        (size.height - valueSize.height) / 2,
      );
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
