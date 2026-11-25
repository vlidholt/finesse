import 'package:finesse/src/components/card.dart';
import 'package:finesse/src/theme/components/list_section.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// How a [ListSection] presents its rows.
enum ListSectionVariant {
  /// The rows sit on a card: the style's card fill, outline, corners and
  /// shadow, which clips them. The grouped, inset list of a settings page.
  card,

  /// The rows run edge to edge with only hairlines between them.
  plain,
}

/// Where a row sits in its [ListSection].
enum ListSectionPosition {
  /// The first of several rows.
  first,

  /// A row with rows above and below it.
  middle,

  /// The last of several rows.
  last,

  /// The section's one row.
  only;

  /// Whether the row is at the top of its section.
  bool get isFirst => this == first || this == only;

  /// Whether the row is at the bottom of its section.
  bool get isLast => this == last || this == only;
}

/// A group of rows under one heading: the grouped list of a settings page,
/// the sections of a form, a menu of destinations.
///
/// ```dart
/// ListSection(
///   header: const Text('Notifications'),
///   footer: const Text('Mentions are always delivered.'),
///   children: [
///     SwitchListTile(
///       title: const Text('Push notifications'),
///       value: push,
///       onChanged: (value) => setState(() => push = value),
///     ),
///     ListTile(
///       title: const Text('Sound'),
///       value: const Text('Chime'),
///       showChevron: true,
///       onTap: _pickSound,
///     ),
///   ],
/// )
/// ```
///
/// The rows are usually `ListTile`s (or `SwitchListTile`,
/// `CheckboxListTile`, `RadioListTile`), which read the [ListSectionScope]
/// around them: inside a section a tile takes the section's padding, is at
/// least a touch target tall, highlights edge to edge and draws its focus
/// ring along the card's corners. Any other widget works as a row too.
///
/// A hairline separates two rows. It starts where the row's text does — a
/// `ListTile` marks the spot with a [ListDividerAnchor] — unless
/// [dividerIndent] says otherwise, and runs to the end edge.
///
/// A form row is a `ListTile` with a control as its `trailing`: a
/// `TextField`, a `Select`, a `Switch`.
///
/// The section is as wide as it is allowed to be and as tall as its rows;
/// put several in a scrolling column. It builds all of its children: a very
/// long list of rows is a [SliverListSection], which builds them as they
/// scroll into view.
class ListSection extends StatelessWidget {
  /// Creates a section of [children].
  const ListSection({
    required this.children,
    this.header,
    this.headerTrailing,
    this.footer,
    this.variant = ListSectionVariant.card,
    this.dividers = true,
    this.dividerIndent,
    this.margin,
    super.key,
  });

  /// The rows.
  final List<Widget> children;

  /// The heading above the rows, in the theme's overline style and muted
  /// colour. A style that sets its overlines in capitals leaves a caller's
  /// text alone: pass it through `theme.style.overline.applyCase`.
  final Widget? header;

  /// A widget at the end of the header's line: a "See all" link, a count.
  final Widget? headerTrailing;

  /// The explanation under the rows, a muted caption.
  final Widget? footer;

  /// How the rows are presented.
  final ListSectionVariant variant;

  /// Whether a hairline is drawn between two rows.
  final bool dividers;

  /// How far from the start edge the hairlines begin. Null starts each one
  /// at its row's text.
  final double? dividerIndent;

  /// The space around the section. Defaults to the theme's.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final look = _SectionLook.of(context, variant, dividerIndent);
    final section = look.section;
    final count = children.length;

    Widget body = Semantics(
      role: SemanticsRole.list,
      container: true,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < count; i++)
            look.row(i, count, children[i], dividers: dividers),
        ],
      ),
    );

    if (look.isCard) {
      body = Card(
        padding: EdgeInsets.zero,
        backgroundColor: section.backgroundColor,
        borderRadius: section.borderRadius,
        rowMainAxisSize: MainAxisSize.max,
        columnCrossAxisAlignment: CrossAxisAlignment.stretch,
        child: body,
      );
    }

    final top = look.header(header, headerTrailing);
    final bottom = look.footer(footer);
    if (top == null && bottom == null) {
      return Padding(
        padding: margin ?? section.margin ?? EdgeInsets.zero,
        child: body,
      );
    }

    return Padding(
      padding: margin ?? section.margin ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [?top, body, ?bottom],
      ),
    );
  }
}

/// A [ListSection] as a sliver, whose rows are built as they scroll into
/// view: a long grouped list — every contact, every package, every setting
/// a search found — among the other slivers of a `CustomScrollView`.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverListSection.builder(
///       header: const Text('Packages'),
///       itemCount: packages.length,
///       itemBuilder: (context, index) => ListTile(
///         title: Text(packages[index].name),
///         showChevron: true,
///         onTap: () => open(packages[index]),
///       ),
///     ),
///   ],
/// )
/// ```
///
/// It looks as a [ListSection] does — the header, the rows on the card or
/// edge to edge, the hairlines inset to the text, the footer — and its rows
/// read the same [ListSectionScope]. The card is painted once behind all
/// the rows; nothing is clipped or composited per row, so a row that fills
/// its own background rounds the section's corners itself, as `ListTile`
/// does, with [ListSectionScope.rowBorderRadius]. Unlike a [ListSection]'s
/// card, the sliver's never blurs what is behind it.
///
/// See also:
///
///  * [ListSection], which builds all of its rows and can sit anywhere.
class SliverListSection extends StatelessWidget {
  /// Creates a section of [children] as a sliver. The children are laid out
  /// as they scroll into view; to build them lazily too, use
  /// [SliverListSection.builder].
  SliverListSection({
    required List<Widget> children,
    this.header,
    this.headerTrailing,
    this.footer,
    this.variant = ListSectionVariant.card,
    this.dividers = true,
    this.dividerIndent,
    this.margin,
    super.key,
  }) : itemCount = children.length,
       itemBuilder = ((context, index) => children[index]),
       findChildIndexCallback = null;

  /// Creates a section whose rows are built as they scroll into view.
  const SliverListSection.builder({
    required this.itemCount,
    required this.itemBuilder,
    this.findChildIndexCallback,
    this.header,
    this.headerTrailing,
    this.footer,
    this.variant = ListSectionVariant.card,
    this.dividers = true,
    this.dividerIndent,
    this.margin,
    super.key,
  });

  /// The number of rows.
  final int itemCount;

  /// Builds the row at an index.
  final IndexedWidgetBuilder itemBuilder;

  /// Finds the new index of a row by the key of the widget [itemBuilder]
  /// built for it, so that rows keep their state when the list is
  /// reordered. See `SliverChildBuilderDelegate.findChildIndexCallback`.
  final ChildIndexGetter? findChildIndexCallback;

  /// The heading above the rows; see [ListSection.header].
  final Widget? header;

  /// A widget at the end of the header's line.
  final Widget? headerTrailing;

  /// The explanation under the rows, a muted caption.
  final Widget? footer;

  /// How the rows are presented.
  final ListSectionVariant variant;

  /// Whether a hairline is drawn between two rows.
  final bool dividers;

  /// How far from the start edge the hairlines begin. Null starts each one
  /// at its row's text.
  final double? dividerIndent;

  /// The space around the section. Defaults to the theme's.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final look = _SectionLook.of(context, variant, dividerIndent);
    final section = look.section;
    final theme = look.theme;
    final count = itemCount;

    Widget body = SliverSemantics(
      role: SemanticsRole.list,
      container: true,
      explicitChildNodes: true,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final child = itemBuilder(context, index);
            return KeyedSubtree(
              // The caller's key says which row this is.
              key: child.key,
              child: look.row(
                index,
                count,
                child,
                dividers: dividers,
                indexed: true,
              ),
            );
          },
          childCount: count,
          findChildIndexCallback: findChildIndexCallback,
          // The row's own node carries its index: a node of the list's
          // between the two would stand between a list and its items.
          addSemanticIndexes: false,
        ),
      ),
    );

    if (look.isCard && count > 0) {
      final border =
          (theme.cardTheme.border ??
                  FinesseBorder.all(color: theme.colorScheme.border, width: 1))
              .toBorder();
      // The card is one decoration behind every row, built or not. It is
      // painted with the list, so it costs a rounded rectangle a frame.
      body = DecoratedSliver(
        decoration: ShadowDecoration.box(
          color:
              section.backgroundColor ??
              theme.cardTheme.backgroundColor ??
              theme.colorScheme.card,
          borderRadius: look.cardRadius,
          border: border,
          shadows: theme.cardTheme.shadows ?? const [],
        ),
        // As a `Container` does, the outline takes its width from the rows.
        sliver: SliverPadding(padding: border.dimensions, sliver: body),
      );
    }

    final top = look.header(header, headerTrailing);
    final bottom = look.footer(footer);
    return SliverPadding(
      padding: margin ?? section.margin ?? EdgeInsets.zero,
      sliver: top == null && bottom == null
          ? body
          : SliverMainAxisGroup(
              slivers: [
                if (top != null) SliverToBoxAdapter(child: top),
                body,
                if (bottom != null) SliverToBoxAdapter(child: bottom),
              ],
            ),
    );
  }
}

/// What [ListSection] and [SliverListSection] share: the metrics a section
/// resolves from the theme once, and the widgets it makes of them.
class _SectionLook {
  _SectionLook._({
    required this.theme,
    required this.variant,
    required this.cardRadius,
    required this.innerRadius,
    required this.fallbackIndent,
    required this.indent,
    required this.direction,
  });

  factory _SectionLook.of(
    BuildContext context,
    ListSectionVariant variant,
    double? dividerIndent,
  ) {
    final theme = Theme.of(context);
    final section = theme.listSectionTheme;
    final direction = Directionality.of(context);
    final isCard = variant == ListSectionVariant.card;
    final cardRadius =
        section.borderRadius ?? theme.cardTheme.borderRadius ?? theme.radius;
    final borderWidth = isCard
        ? (theme.cardTheme.border?.top?.width ?? 1)
        : 0.0;
    final tilePadding = (section.tilePadding ?? EdgeInsets.zero).resolve(
      direction,
    );
    return _SectionLook._(
      theme: theme,
      variant: variant,
      cardRadius: cardRadius,
      // The corners of the rows' own area, inside the card's outline.
      innerRadius: isCard
          ? _deflate(cardRadius, borderWidth)
          : BorderRadius.zero,
      fallbackIndent: direction == TextDirection.ltr
          ? tilePadding.left
          : tilePadding.right,
      indent: dividerIndent,
      direction: direction,
    );
  }

  final ThemeData theme;
  final ListSectionVariant variant;
  final BorderRadius cardRadius;
  final BorderRadius innerRadius;
  final double fallbackIndent;
  final double? indent;
  final TextDirection direction;

  ListSectionTheme get section => theme.listSectionTheme;

  bool get isCard => variant == ListSectionVariant.card;

  /// The row at [index] of [count]: its hairline, its place in the
  /// semantics list and the scope its tile reads.
  Widget row(
    int index,
    int count,
    Widget child, {
    required bool dividers,
    bool indexed = false,
  }) {
    final section = this.section;
    final scheme = theme.colorScheme;
    return _SectionRow(
      divider: dividers && index < count - 1,
      color: section.dividerColor ?? scheme.border,
      thickness: section.dividerThickness ?? 1,
      indent: indent,
      fallbackIndent: fallbackIndent,
      textDirection: direction,
      child: Semantics(
        role: SemanticsRole.listItem,
        container: true,
        child: ListSectionScope(
          position: count == 1
              ? ListSectionPosition.only
              : index == 0
              ? ListSectionPosition.first
              : index == count - 1
              ? ListSectionPosition.last
              : ListSectionPosition.middle,
          variant: variant,
          borderRadius: innerRadius,
          tilePadding: section.tilePadding,
          minTileHeight: section.minTileHeight ?? 0,
          pressedColor: section.pressedColor ?? scheme.muted,
          child: indexed ? IndexedSemantics(index: index, child: child) : child,
        ),
      ),
    );
  }

  /// The line above the rows, or null when there is nothing to put on it.
  Widget? header(Widget? header, Widget? trailing) {
    if (header == null && trailing == null) return null;
    final section = this.section;
    return Padding(
      padding: section.headerPadding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: header == null
                ? const SizedBox.shrink()
                : Semantics(
                    header: true,
                    child: DefaultTextStyle.merge(
                      style: section.headerStyle ?? theme.textTheme.caption,
                      child: header,
                    ),
                  ),
          ),
          if (trailing != null)
            DefaultTextStyle.merge(
              style: theme.textTheme.small,
              child: trailing,
            ),
        ],
      ),
    );
  }

  /// The caption under the rows, or null without one.
  Widget? footer(Widget? footer) {
    if (footer == null) return null;
    final section = this.section;
    return Padding(
      padding: section.footerPadding ?? EdgeInsets.zero,
      child: DefaultTextStyle.merge(
        style: section.footerStyle ?? theme.textTheme.caption,
        child: footer,
      ),
    );
  }

  static BorderRadius _deflate(BorderRadius radius, double by) {
    Radius corner(Radius r) => Radius.elliptical(
      (r.x - by).clamp(0.0, double.infinity),
      (r.y - by).clamp(0.0, double.infinity),
    );
    return BorderRadius.only(
      topLeft: corner(radius.topLeft),
      topRight: corner(radius.topRight),
      bottomLeft: corner(radius.bottomLeft),
      bottomRight: corner(radius.bottomRight),
    );
  }
}

/// What a [ListSection] tells each of its rows: where the row sits and the
/// metrics the section's rows share.
///
/// `ListTile` reads it; a custom row can too.
///
/// ```dart
/// final scope = ListSectionScope.maybeOf(context);
/// final padding = scope?.tilePadding ?? const EdgeInsets.all(12);
/// ```
class ListSectionScope extends InheritedWidget {
  /// Creates a scope around one row.
  const ListSectionScope({
    required this.position,
    required this.variant,
    required this.borderRadius,
    required this.minTileHeight,
    required this.pressedColor,
    required super.child,
    this.tilePadding,
    super.key,
  });

  /// Where the row sits in its section.
  final ListSectionPosition position;

  /// How the section presents its rows.
  final ListSectionVariant variant;

  /// The corners of the area the section's rows fill: the card's, less its
  /// outline, or square for a plain section.
  final BorderRadius borderRadius;

  /// The padding of a row's content, or null to keep the row's own.
  final EdgeInsetsGeometry? tilePadding;

  /// The least height of a row.
  final double minTileHeight;

  /// The fill of a row while it is pressed.
  final Color pressedColor;

  /// The corners of this row: the section's at the top of the first row and
  /// the bottom of the last, square between rows.
  BorderRadius get rowBorderRadius => BorderRadius.only(
    topLeft: position.isFirst ? borderRadius.topLeft : Radius.zero,
    topRight: position.isFirst ? borderRadius.topRight : Radius.zero,
    bottomLeft: position.isLast ? borderRadius.bottomLeft : Radius.zero,
    bottomRight: position.isLast ? borderRadius.bottomRight : Radius.zero,
  );

  /// The scope of the nearest enclosing section row, or null outside one.
  static ListSectionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ListSectionScope>();

  @override
  bool updateShouldNotify(ListSectionScope oldWidget) =>
      position != oldWidget.position ||
      variant != oldWidget.variant ||
      borderRadius != oldWidget.borderRadius ||
      tilePadding != oldWidget.tilePadding ||
      minTileHeight != oldWidget.minTileHeight ||
      pressedColor != oldWidget.pressedColor;
}

/// Marks where the hairline under a row of a [ListSection] starts: the
/// start edge of [child].
///
/// `ListTile` wraps its text in one, so the hairline lines up with the
/// titles whatever the rows lead with. A custom row does the same:
///
/// ```dart
/// Row(
///   children: [
///     const Avatar('assets/omar.jpg'),
///     const Gap.md(),
///     Expanded(child: ListDividerAnchor(child: Text(name))),
///   ],
/// )
/// ```
///
/// Outside a section it does nothing. The position is the child's place in
/// layout, so a row that is slid or scaled in paint keeps its hairline
/// still.
class ListDividerAnchor extends SingleChildRenderObjectWidget {
  /// Creates an anchor at the start edge of [child].
  const ListDividerAnchor({required Widget super.child, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderDividerAnchor();
}

class _RenderDividerAnchor extends RenderProxyBox {
  _RenderSectionRow? _row;

  @override
  void performLayout() {
    super.performLayout();
    // The row is found again on each layout: cheap (a handful of parents),
    // and right after the anchor has been moved to another row.
    var node = parent;
    while (node != null && node is! _RenderSectionRow) {
      node = node.parent;
    }
    if (!identical(node, _row)) {
      _row?._release(this);
      _row = node as _RenderSectionRow?;
    }
    _row?._adopt(this);
  }

  @override
  void detach() {
    _row?._release(this);
    _row = null;
    super.detach();
  }
}

/// One row of a section, and the hairline under it.
class _SectionRow extends SingleChildRenderObjectWidget {
  const _SectionRow({
    required this.divider,
    required this.color,
    required this.thickness,
    required this.indent,
    required this.fallbackIndent,
    required this.textDirection,
    required Widget super.child,
  });

  final bool divider;
  final Color color;
  final double thickness;
  final double? indent;
  final double fallbackIndent;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSectionRow(
    divider: divider,
    color: color,
    thickness: thickness,
    indent: indent,
    fallbackIndent: fallbackIndent,
    textDirection: textDirection,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSectionRow renderObject,
  ) {
    renderObject
      ..divider = divider
      ..color = color
      ..thickness = thickness
      ..indent = indent
      ..fallbackIndent = fallbackIndent
      ..textDirection = textDirection;
  }
}

class _RenderSectionRow extends RenderProxyBox {
  _RenderSectionRow({
    required bool divider,
    required Color color,
    required double thickness,
    required double? indent,
    required double fallbackIndent,
    required TextDirection textDirection,
  }) : _divider = divider,
       _color = color,
       _thickness = thickness,
       _indent = indent,
       _fallbackIndent = fallbackIndent,
       _textDirection = textDirection;

  _RenderDividerAnchor? _anchor;

  void _adopt(_RenderDividerAnchor anchor) {
    if (identical(_anchor, anchor)) return;
    _anchor = anchor;
    markNeedsPaint();
  }

  void _release(_RenderDividerAnchor anchor) {
    if (!identical(_anchor, anchor)) return;
    _anchor = null;
    if (attached) markNeedsPaint();
  }

  bool get divider => _divider;
  bool _divider;
  set divider(bool value) {
    if (value == _divider) return;
    _divider = value;
    markNeedsPaint();
  }

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  double get thickness => _thickness;
  double _thickness;
  set thickness(double value) {
    if (value == _thickness) return;
    _thickness = value;
    markNeedsPaint();
  }

  double? get indent => _indent;
  double? _indent;
  set indent(double? value) {
    if (value == _indent) return;
    _indent = value;
    markNeedsPaint();
  }

  double get fallbackIndent => _fallbackIndent;
  double _fallbackIndent;
  set fallbackIndent(double value) {
    if (value == _fallbackIndent) return;
    _fallbackIndent = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  /// How far from the start edge the hairline begins.
  double get effectiveIndent {
    if (_indent != null) return _indent!;
    final anchor = _anchor;
    if (anchor == null || !anchor.attached || !anchor.hasSize) {
      return _fallbackIndent;
    }
    // Where the anchor was laid out, not where it is painted: the parent
    // data's offsets on the way up, without any paint transform.
    var x = 0.0;
    RenderObject? node = anchor;
    while (node != null && !identical(node, this)) {
      final data = node.parentData;
      if (data is BoxParentData) x += data.offset.dx;
      node = node.parent;
    }
    if (node == null) return _fallbackIndent;
    final indent = _textDirection == TextDirection.ltr
        ? x
        : size.width - x - anchor.size.width;
    return indent.clamp(0.0, size.width);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (!_divider || _thickness <= 0 || _color.a == 0) return;
    final indent = effectiveIndent;
    final top = offset.dy + size.height - _thickness;
    final rect = _textDirection == TextDirection.ltr
        ? Rect.fromLTWH(
            offset.dx + indent,
            top,
            size.width - indent,
            _thickness,
          )
        : Rect.fromLTWH(offset.dx, top, size.width - indent, _thickness);
    context.canvas.drawRect(rect, Paint()..color = _color);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('divider', value: _divider, ifTrue: 'divider'))
      ..add(DoubleProperty('indent', effectiveIndentForDebug));
  }

  /// [effectiveIndent] when the row has been laid out, else null.
  double? get effectiveIndentForDebug => hasSize ? effectiveIndent : null;
}

/// Reads the hairline of the section row at or above [object], for tests:
/// whether it is drawn and where it starts.
@visibleForTesting
({bool divider, double indent})? debugListSectionDivider(RenderObject? object) {
  var node = object;
  while (node != null && node is! _RenderSectionRow) {
    node = node.parent;
  }
  if (node is! _RenderSectionRow) return null;
  return (divider: node.divider, indent: node.effectiveIndent);
}
