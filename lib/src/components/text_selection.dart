import 'dart:math' as math;

import 'package:finesse/src/components/surface.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/i18n/strings.g.dart';
import 'package:finesse/src/icons/phosphor_icon.dart';
import 'package:finesse/src/icons/phosphor_icons_regular.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The selection handles of a touch screen, in this system's look: a thin
/// stem the height of the line with a dot at its end, in the scheme's tint.
///
/// The start handle carries its dot above the line and the end handle below
/// it, so the two never cover each other on a one-word selection; a caret
/// with no selection gets the dot alone, hanging under it. Each is a touch
/// target of at least 48 points whatever its drawn size (the framework
/// widens it).
///
/// `TextField`, `Textarea` and `SelectionArea` use
/// [FinesseTextSelectionControls.adaptive] by default: these controls where
/// the platform is touch-first (iOS, Android, Fuchsia) and none on a
/// desktop, where a selection is made with the pointer and has no handles.
/// Pass an instance as `selectionControls` to get handles everywhere:
///
/// ```dart
/// TextField(selectionControls: finesseTextSelectionControls)
/// ```
///
/// Colour and size come from `ThemeData.textSelectionTheme`.
///
/// The controls draw handles only. The menu over a selection is built by
/// the field's `contextMenuBuilder` — a [TextSelectionToolbar] by default
/// on touch platforms.
class FinesseTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  /// Creates the controls. They hold no state: one instance,
  /// [finesseTextSelectionControls], serves the whole app.
  FinesseTextSelectionControls();

  /// The controls for the platform the app runs on:
  /// [finesseTextSelectionControls] on iOS, Android and Fuchsia, and null —
  /// no handles — on macOS, Windows and Linux.
  static TextSelectionControls? get adaptive =>
      usesTouchSelection ? finesseTextSelectionControls : null;

  /// Whether the platform edits text by touch: handles at the ends of a
  /// selection, a toolbar over it, a magnifier under the finger.
  ///
  /// True on iOS, Android and Fuchsia, in a browser as well.
  static bool get usesTouchSelection => switch (defaultTargetPlatform) {
    TargetPlatform.iOS ||
    TargetPlatform.android ||
    TargetPlatform.fuchsia => true,
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => false,
  };

  // Used when no theme is in reach, which only a handle built outside any
  // `FinesseApp` is.
  static const _fallbackDot = 12.0;
  static const _fallbackStem = 2.0;

  /// How far the collapsed handle's dot hangs under the caret.
  static const _neck = 3.0;

  // `getHandleSize` and `getHandleAnchor` are given no context, so they use
  // the metrics of the last handle built. Every handle of a selection is
  // built before it is placed, and one app has one handle size.
  double _dot = _fallbackDot;

  @override
  Size getHandleSize(double textLineHeight) =>
      Size(_dot, textLineHeight + _dot);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    // The framework places the handle so that this point of its box is at
    // the bottom of the selection's edge.
    return switch (type) {
      // Dot above: the stem ends at the bottom of the box.
      TextSelectionHandleType.left => Offset(_dot / 2, textLineHeight + _dot),
      // Dot below: the stem fills the top of the box.
      TextSelectionHandleType.right => Offset(_dot / 2, textLineHeight),
      // The dot alone, under the caret.
      TextSelectionHandleType.collapsed => Offset(_dot / 2, -_neck),
    };
  }

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final theme = Theme.of(context);
    final selection = theme.textSelectionTheme;
    final dot = _dot = selection.handleSize ?? _fallbackDot;
    return SizedBox.fromSize(
      // The same box for every type — the framework sizes the touch target
      // from [getHandleSize], which is not told the type.
      size: getHandleSize(textLineHeight),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: CustomPaint(
          painter: _HandlePainter(
            color: selection.handleColor ?? theme.colorScheme.tint,
            dot: dot,
            stemWidth: selection.handleStemWidth ?? _fallbackStem,
            type: type,
          ),
        ),
      ),
    );
  }
}

/// The one instance of [FinesseTextSelectionControls].
final TextSelectionControls finesseTextSelectionControls =
    FinesseTextSelectionControls();

class _HandlePainter extends CustomPainter {
  const _HandlePainter({
    required this.color,
    required this.dot,
    required this.stemWidth,
    required this.type,
  });

  final Color color;
  final double dot;
  final double stemWidth;
  final TextSelectionHandleType type;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = dot / 2;
    final centerX = size.width / 2;
    switch (type) {
      case TextSelectionHandleType.collapsed:
        canvas.drawCircle(Offset(centerX, radius), radius, paint);
      case TextSelectionHandleType.left:
        // One path, so a translucent colour is not doubled where the stem
        // meets the dot.
        canvas.drawPath(
          Path()
            ..addOval(
              Rect.fromCircle(center: Offset(centerX, radius), radius: radius),
            )
            ..addRect(
              Rect.fromLTRB(
                centerX - stemWidth / 2,
                radius,
                centerX + stemWidth / 2,
                size.height,
              ),
            ),
          paint,
        );
      case TextSelectionHandleType.right:
        canvas.drawPath(
          Path()
            ..addOval(
              Rect.fromCircle(
                center: Offset(centerX, size.height - radius),
                radius: radius,
              ),
            )
            ..addRect(
              Rect.fromLTRB(
                centerX - stemWidth / 2,
                0,
                centerX + stemWidth / 2,
                size.height - radius,
              ),
            ),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_HandlePainter oldDelegate) =>
      color != oldDelegate.color ||
      dot != oldDelegate.dot ||
      stemWidth != oldDelegate.stemWidth ||
      type != oldDelegate.type;
}

/// The menu over a text selection on a touch screen: a horizontal pill of
/// actions on the menu surface — glass in the default style — above the
/// selection, or below it when there is no room above.
///
/// When the actions do not fit the screen's width, a caret at the end pages
/// to the rest and one at the start pages back.
///
/// `TextField`, `Textarea` and `SelectionArea` show one by default on iOS
/// and Android. To add an action of your own, build one from the field's
/// items:
///
/// ```dart
/// TextField(
///   contextMenuBuilder: (context, editableTextState) {
///     return TextSelectionToolbar.buttonItems(
///       anchors: editableTextState.contextMenuAnchors,
///       buttonItems: [
///         ...editableTextState.contextMenuButtonItems,
///         ContextMenuButtonItem(
///           label: 'Translate',
///           onPressed: () {
///             ContextMenuController.removeAny();
///             translate(editableTextState.textEditingValue);
///           },
///         ),
///       ],
///     );
///   },
/// )
/// ```
///
/// The toolbar never takes the keyboard focus: the field keeps its caret
/// and its keyboard while the toolbar shows. Height, colours and the gap to
/// the selection come from `ThemeData.textSelectionTheme`.
class TextSelectionToolbar extends StatelessWidget {
  /// Creates a toolbar of [children] — usually
  /// [TextSelectionToolbarButton]s — that sits above [anchorAbove] when it
  /// fits there and below [anchorBelow] otherwise.
  const TextSelectionToolbar({
    required this.anchorAbove,
    required this.anchorBelow,
    required this.children,
    super.key,
  });

  /// Creates the toolbar for a list of framework button items, such as
  /// `EditableTextState.contextMenuButtonItems`, placed by [anchors].
  ///
  /// The standard actions take their labels from `FinesseLocalizations`; a
  /// custom one shows its own [ContextMenuButtonItem.label], and an item
  /// with no label at all is left out.
  static Widget buttonItems({
    required TextSelectionToolbarAnchors anchors,
    required List<ContextMenuButtonItem> buttonItems,
    Key? key,
  }) {
    return _ButtonItemsToolbar(
      key: key,
      anchors: anchors,
      buttonItems: buttonItems,
    );
  }

  /// Creates the toolbar for an [EditableText]: its cut, copy, paste and
  /// select-all actions and whatever else the platform offers for the
  /// selection.
  static Widget editableText({
    required EditableTextState editableTextState,
    Key? key,
  }) {
    return _ButtonItemsToolbar(
      key: key,
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: editableTextState.contextMenuButtonItems,
    );
  }

  /// Creates the toolbar for a [SelectableRegion], which is what a
  /// `SelectionArea` is: copy and select all.
  static Widget selectableRegion({
    required SelectableRegionState selectableRegionState,
    Key? key,
  }) {
    return _ButtonItemsToolbar(
      key: key,
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: selectableRegionState.contextMenuButtonItems,
    );
  }

  /// The localized label of a framework [item]: the package's own string
  /// for a standard action, the item's label for a custom one, and null
  /// when there is neither.
  static String? labelFor(BuildContext context, ContextMenuButtonItem item) {
    final label = item.label;
    if (label != null && label.isNotEmpty) return label;
    final l = FinesseLocalizations.of(context);
    return _standardLabel(item.type, l);
  }

  static String? _standardLabel(
    ContextMenuButtonType type,
    FinesseLocalizationsData l,
  ) {
    return switch (type) {
      ContextMenuButtonType.cut => l.input.cut,
      ContextMenuButtonType.copy => l.input.copy,
      ContextMenuButtonType.paste => l.input.paste,
      ContextMenuButtonType.selectAll => l.input.selectAll,
      ContextMenuButtonType.delete => l.input.delete,
      ContextMenuButtonType.lookUp => l.input.lookUp,
      ContextMenuButtonType.searchWeb => l.input.searchWeb,
      ContextMenuButtonType.share => l.input.share,
      ContextMenuButtonType.liveTextInput => l.input.liveText,
      // A custom item names itself; so must a type a later Flutter adds.
      _ => null,
    };
  }

  /// The point the toolbar sits above, in global coordinates: the top of
  /// the selection.
  final Offset anchorAbove;

  /// The point the toolbar sits below when it does not fit above
  /// [anchorAbove], in global coordinates: the bottom of the selection.
  final Offset anchorBelow;

  /// The actions, in order. Must not be empty.
  final List<Widget> children;

  /// The margin kept between the toolbar and the edges of the screen.
  static const _screenPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    assert(children.isNotEmpty, 'A selection toolbar needs an action.');
    final theme = Theme.of(context);
    final selection = theme.textSelectionTheme;
    final motion = Motion.of(context);
    final direction = Directionality.of(context);
    final gap = selection.toolbarGap ?? 8;
    final handle = selection.handleSize ?? 12;
    final height = selection.toolbarHeight ?? 40;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final scaledHeight = scale > 1 ? height * scale : height;

    final padding = MediaQuery.paddingOf(context);
    final paddingAbove = padding.top + _screenPadding;
    // Clear of the handles' dots: the start handle carries its dot above
    // the line and the end handle below it.
    final above = anchorAbove - Offset(0, gap + handle);
    final below = anchorBelow + Offset(0, gap + handle);
    final fitsAbove = scaledHeight <= above.dy - paddingAbove;
    final localAdjustment = Offset(
      padding.left + _screenPadding,
      paddingAbove,
    );

    final decoration = selection.toolbarDecoration;
    final radius =
        (decoration?.border?.borderRadius ??
                theme.popoverTheme.decoration?.border?.borderRadius ??
                BorderRadius.zero)
            .resolve(direction);

    // The height is the surface's, border included, so it is asked for
    // outside the decoration and reaches the row as a minimum.
    Widget toolbar = ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Surface(
        kind: SurfaceKind.menu,
        padding: EdgeInsets.zero,
        decoration: decoration,
        textStyle: selection.toolbarTextStyle,
        // The buttons fill the pill to its edge, so their pressed fill is
        // cut to its corners.
        child: ClipRRect(
          borderRadius: radius,
          child: _ToolbarPager(
            dividerColor:
                selection.toolbarDividerColor ?? theme.colorScheme.border,
            children: children,
          ),
        ),
      ),
    );

    final entrance = EntranceSpec.of(motion);
    if (!entrance.isInstant) {
      // The surface may be glass, which an opacity layer would hide: the
      // fade goes through a host.
      toolbar = OverlayEntrance(spec: entrance, child: toolbar);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding.left + _screenPadding,
        paddingAbove,
        padding.right + _screenPadding,
        padding.bottom + _screenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(
          anchorAbove: above - localAdjustment,
          anchorBelow: below - localAdjustment,
          fitsAbove: fitsAbove,
        ),
        // It grows out of the edge that faces the selection.
        child: MotionOrigin(
          alignment: fitsAbove ? Alignment.bottomCenter : Alignment.topCenter,
          // The field keeps the focus, and with it the caret and the
          // keyboard, while the toolbar is used.
          child: FocusScope(
            canRequestFocus: false,
            child: Semantics(container: true, child: toolbar),
          ),
        ),
      ),
    );
  }
}

/// Builds a [TextSelectionToolbar] from framework button items.
class _ButtonItemsToolbar extends StatelessWidget {
  const _ButtonItemsToolbar({
    required this.anchors,
    required this.buttonItems,
    super.key,
  });

  final TextSelectionToolbarAnchors anchors;
  final List<ContextMenuButtonItem> buttonItems;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      for (final item in buttonItems)
        if (TextSelectionToolbar.labelFor(context, item) case final label?)
          TextSelectionToolbarButton(
            onPressed: item.onPressed,
            child: Text(label),
          ),
    ];
    if (children.isEmpty) return const SizedBox.shrink();
    return TextSelectionToolbar(
      anchorAbove: anchors.primaryAnchor,
      anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
      children: children,
    );
  }
}

/// One action of a [TextSelectionToolbar]: a label, or an icon, that fills
/// the toolbar's height.
///
/// Pressed or hovered it takes the wash a highlighted menu row takes, at
/// once. It does not take the keyboard focus.
class TextSelectionToolbarButton extends StatelessWidget {
  /// Creates a toolbar action showing [child].
  const TextSelectionToolbarButton({
    required this.child,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  /// Called when the action is tapped. Null disables it.
  final VoidCallback? onPressed;

  /// The label: usually a [Text], or an icon with a [semanticLabel].
  final Widget child;

  /// What assistive technology reads in place of [child].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selection = theme.textSelectionTheme;
    final pressedColor =
        selection.toolbarPressedColor ??
        theme.colorScheme.foreground.withValues(alpha: .06);
    final padding =
        selection.toolbarItemPadding ??
        const EdgeInsets.symmetric(horizontal: 12);
    return Pressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      // The fill is the response; a pill of buttons that each shrink would
      // open gaps between them.
      pressScale: 1,
      builder: (context, states) {
        final lit =
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered);
        final enabled = !states.contains(WidgetState.disabled);
        return ColoredBox(
          color: lit ? pressedColor : const Color(0x00000000),
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1,
              child: Opacity(
                opacity: enabled ? 1 : theme.disabledOpacity,
                child: DefaultTextStyle.merge(
                  maxLines: 1,
                  softWrap: false,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lays the toolbar's actions out in a row and, when they do not fit,
/// splits them into pages with a caret to move between them.
class _ToolbarPager extends StatefulWidget {
  const _ToolbarPager({
    required this.dividerColor,
    required this.children,
  });

  final Color dividerColor;
  final List<Widget> children;

  @override
  State<_ToolbarPager> createState() => _ToolbarPagerState();
}

class _ToolbarPagerState extends State<_ToolbarPager> {
  int _page = 0;

  @override
  void didUpdateWidget(_ToolbarPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Other actions (the clipboard filled up, the selection changed) are
    // another menu: it starts at its first page.
    if (widget.children.length != oldWidget.children.length) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = FinesseLocalizations.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final size = Theme.of(context).textSelectionTheme.toolbarTextStyle;
    final iconSize = (size?.fontSize ?? 14) + 2;
    return _ToolbarItems(
      page: _page,
      dividerColor: widget.dividerColor,
      textDirection: Directionality.of(context),
      children: [
        TextSelectionToolbarButton(
          semanticLabel: l.input.previousActions,
          onPressed: () => setState(() => _page = math.max(0, _page - 1)),
          child: PhosphorIcon(
            rtl
                ? PhosphorIconsRegular.caretRight
                : PhosphorIconsRegular.caretLeft,
            size: iconSize,
          ),
        ),
        TextSelectionToolbarButton(
          semanticLabel: l.input.moreActions,
          onPressed: () => setState(() => _page++),
          child: PhosphorIcon(
            rtl
                ? PhosphorIconsRegular.caretLeft
                : PhosphorIconsRegular.caretRight,
            size: iconSize,
          ),
        ),
        ...widget.children,
      ],
    );
  }
}

class _ToolbarItems extends MultiChildRenderObjectWidget {
  const _ToolbarItems({
    required this.page,
    required this.dividerColor,
    required this.textDirection,
    required super.children,
  });

  final int page;
  final Color dividerColor;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderToolbarItems(
    page: page,
    dividerColor: dividerColor,
    textDirection: textDirection,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderToolbarItems renderObject,
  ) {
    renderObject
      ..page = page
      ..dividerColor = dividerColor
      ..textDirection = textDirection;
  }
}

class _ToolbarParentData extends ContainerBoxParentData<RenderBox> {
  /// Whether the child is on the page that shows.
  bool shown = false;
}

/// The first two children are the "back" and "more" carets; the rest are
/// the actions. One page of them is laid out in a row, with a hairline
/// between neighbours.
class _RenderToolbarItems extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ToolbarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ToolbarParentData> {
  _RenderToolbarItems({
    required int page,
    required Color dividerColor,
    required TextDirection textDirection,
  }) : _page = page,
       _dividerColor = dividerColor,
       _textDirection = textDirection;

  static const _divider = 1.0;

  /// How far a hairline stops short of the toolbar's top and bottom.
  static const _dividerInset = 8.0;

  int get page => _page;
  int _page;
  set page(int value) {
    if (value == _page) return;
    _page = value;
    markNeedsLayout();
  }

  Color get dividerColor => _dividerColor;
  Color _dividerColor;
  set dividerColor(Color value) {
    if (value == _dividerColor) return;
    _dividerColor = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  /// Where the hairlines of the current page are, as x offsets.
  final _dividers = <double>[];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ToolbarParentData) {
      child.parentData = _ToolbarParentData();
    }
  }

  @override
  void performLayout() {
    _dividers.clear();
    final children = getChildrenAsList();
    assert(children.length > 2, 'The pager adds the two carets itself.');
    final minHeight = constraints.minHeight;
    final loose = BoxConstraints(minHeight: minHeight);
    var height = minHeight;
    for (final child in children) {
      child.layout(loose, parentUsesSize: true);
      height = math.max(height, child.size.height);
      (child.parentData! as _ToolbarParentData).shown = false;
    }
    final back = children[0];
    final more = children[1];
    final actions = children.sublist(2);
    final maxWidth = constraints.maxWidth;

    double widthOf(Iterable<RenderBox> row) {
      var width = 0.0;
      for (final child in row) {
        width += child.size.width;
      }
      return width + _divider * math.max(0, row.length - 1);
    }

    // Split the actions into pages. Every page but the last ends in the
    // "more" caret and every page but the first starts with "back"; a page
    // always holds at least one action, however narrow the screen.
    final pages = <List<RenderBox>>[];
    var start = 0;
    while (start < actions.length) {
      final first = pages.isEmpty;
      if (first && widthOf(actions) <= maxWidth) {
        pages.add(actions);
        break;
      }
      final lead = first ? const <RenderBox>[] : [back];
      // The rest fits without a "more" caret: this is the last page.
      final rest = actions.sublist(start);
      if (widthOf([...lead, ...rest]) <= maxWidth) {
        pages.add([...lead, ...rest]);
        break;
      }
      var end = start + 1;
      while (end < actions.length &&
          widthOf([...lead, ...actions.sublist(start, end + 1), more]) <=
              maxWidth) {
        end++;
      }
      pages.add([
        ...lead,
        ...actions.sublist(start, end),
        if (end < actions.length) more,
      ]);
      start = end;
    }

    final row = pages[page.clamp(0, pages.length - 1)];
    final tight = BoxConstraints(minHeight: height, maxHeight: height);
    final width = math.min(widthOf(row), maxWidth);
    final rtl = textDirection == TextDirection.rtl;
    var x = 0.0;
    for (var i = 0; i < row.length; i++) {
      final child = row[i]..layout(tight, parentUsesSize: true);
      final data = child.parentData! as _ToolbarParentData..shown = true;
      data.offset = Offset(rtl ? width - x - child.size.width : x, 0);
      x += child.size.width;
      if (i < row.length - 1) {
        _dividers.add(rtl ? width - x - _divider / 2 : x + _divider / 2);
        x += _divider;
      }
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    visitShown(
      (child, data) => context.paintChild(child, offset + data.offset),
    );
    final paint = Paint()
      ..color = dividerColor
      ..strokeWidth = _divider;
    for (final x in _dividers) {
      context.canvas.drawLine(
        offset + Offset(x, _dividerInset),
        offset + Offset(x, size.height - _dividerInset),
        paint,
      );
    }
  }

  /// Calls [visitor] for each child on the page that shows.
  void visitShown(
    void Function(RenderBox child, _ToolbarParentData data) visitor,
  ) {
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _ToolbarParentData;
      if (data.shown) visitor(child, data);
      child = data.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final data = child.parentData! as _ToolbarParentData;
      if (data.shown) {
        final hit = result.addWithPaintOffset(
          offset: data.offset,
          position: position,
          hitTest: (result, transformed) =>
              child!.hitTest(result, position: transformed),
        );
        if (hit) return true;
      }
      child = data.previousSibling;
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitShown((child, _) => visitor(child));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('page', page));
  }
}
