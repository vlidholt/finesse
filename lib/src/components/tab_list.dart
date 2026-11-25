import 'dart:ui' show SemanticsRole;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/components/tooltip.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/haptics.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:finesse/src/utils/text_scaled_height.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// How a list of tabs is drawn.
enum TabBarVariant {
  /// Text tabs on the page with a line under the selected one, and a
  /// hairline under the whole row: the sections of a page.
  underline,

  /// A filled strip with a raised pill on the selected tab: a few views of
  /// the same thing, side by side.
  segmented,
}

/// One entry of a [TabList].
@immutable
class TabListItem {
  /// Creates an entry.
  const TabListItem({
    required this.child,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.tooltip,
    this.semanticLabel,
  });

  /// The label.
  final Widget child;

  /// Shown before the label.
  final Widget? leading;

  /// Shown after the label.
  final Widget? trailing;

  /// Whether the entry can be chosen.
  final bool enabled;

  /// Shown when the pointer rests on the entry.
  final String? tooltip;

  /// Read in place of the label.
  final String? semanticLabel;
}

/// The one list of mutually exclusive choices behind `TabBar`, `Tabs` and
/// `SegmentedControl`: the row, its travelling selection indicator, the
/// keyboard, and what a screen reader is told.
///
/// Internal. It knows indices, not values, and holds no selection of its
/// own.
class TabList extends StatefulWidget {
  /// Creates a list of [items] with [selectedIndex] chosen.
  const TabList({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.variant,
    required this.expand,
    this.scrollable = false,
    this.showBorder = true,
    this.track,
    this.radioGroup = false,
    this.slide = false,
    this.alignment,
    this.shrinkWrap = true,
    super.key,
  });

  /// The entries, in order.
  final List<TabListItem> items;

  /// The chosen entry, or null (or out of range) for none.
  final int? selectedIndex;

  /// Called with the entry the user chose. Null makes the list inert.
  final ValueChanged<int>? onSelected;

  /// The look.
  final TabBarVariant variant;

  /// Whether the entries share the width there is.
  final bool expand;

  /// Whether the row scrolls sideways when it does not fit.
  final bool scrollable;

  /// Whether an underline list draws the hairline under its row.
  final bool showBorder;

  /// A fractional index to hold the indicator at while pages are dragged;
  /// see `MovingIndicator.track`.
  final ValueListenable<double?>? track;

  /// Whether this is a set of radio buttons to a screen reader (a value is
  /// picked) rather than a list of tabs (a view is shown).
  final bool radioGroup;

  /// Whether a finger dragged along the row chooses the entry under it.
  final bool slide;

  /// Where a segmented strip sits in a parent wider than it. Defaults to
  /// the start.
  final AlignmentGeometry? alignment;

  /// Whether a segmented strip that does not [expand] makes the list as
  /// narrow as itself where its parent allows.
  final bool shrinkWrap;

  @override
  State<TabList> createState() => _TabListState();
}

class _TabListState extends State<TabList> {
  final _nodes = <FocusNode>[];
  ScrollController? _scrollController;
  HorizontalDragGestureRecognizer? _slide;

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(TabList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
    if (widget.selectedIndex != oldWidget.selectedIndex) _reveal();
  }

  /// Brings the chosen entry into view in a row that scrolls.
  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = _selected;
      final scroll = _scrollController;
      if (index == null || scroll == null || !scroll.hasClients) return;
      final position = scroll.position;
      if (position.maxScrollExtent <= position.minScrollExtent) return;
      final target = _nodes[index].context?.findRenderObject();
      if (target == null || !target.attached) return;
      final motion = Motion.of(context);
      // This row only: `Scrollable.ensureVisible` would scroll the page
      // around it as well.
      position.ensureVisible(
        target,
        alignment: .5,
        duration: motion.normal,
        curve: motion.standard,
      );
    });
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    _scrollController?.dispose();
    _slide?.dispose();
    super.dispose();
  }

  void _syncNodes() {
    final count = widget.items.length;
    while (_nodes.length > count) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < count) {
      _nodes.add(FocusNode(debugLabel: 'tab ${_nodes.length}'));
    }
    // The list is one stop for the Tab key — the chosen entry, or the first
    // that can be chosen — and the arrow keys move within it.
    final stop = _stop;
    for (var i = 0; i < count; i++) {
      _nodes[i].skipTraversal = i != stop;
    }
  }

  bool _enabled(int index) =>
      widget.onSelected != null && widget.items[index].enabled;

  int? get _selected {
    final index = widget.selectedIndex;
    if (index == null || index < 0 || index >= widget.items.length) {
      return null;
    }
    return index;
  }

  int? get _stop {
    final selected = _selected;
    if (selected != null && _enabled(selected)) return selected;
    for (var i = 0; i < widget.items.length; i++) {
      if (_enabled(i)) return i;
    }
    return null;
  }

  void _select(int index) {
    if (!_enabled(index) || index == _selected) return;
    widget.onSelected!(index);
  }

  /// The next entry that can be chosen, [step] entries along from [from],
  /// wrapping at the ends.
  int? _next(int from, int step) {
    final count = widget.items.length;
    for (var i = 1; i <= count; i++) {
      final index = (from + step * i) % count;
      if (_enabled(index)) return index;
    }
    return null;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final focused = _nodes.indexWhere((node) => node.hasPrimaryFocus);
    if (focused < 0) return KeyEventResult.ignored;
    final forward = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final count = widget.items.length;
    final key = event.logicalKey;
    final int? target;
    if (key == LogicalKeyboardKey.arrowRight) {
      target = _next(focused, forward);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      target = _next(focused, -forward);
    } else if (key == LogicalKeyboardKey.home) {
      target = _next(count - 1, 1);
    } else if (key == LogicalKeyboardKey.end) {
      target = _next(0, -1);
    } else {
      return KeyEventResult.ignored;
    }
    if (target != null && target != focused) {
      _nodes[target].requestFocus();
      _select(target);
    }
    return KeyEventResult.handled;
  }

  // A finger sliding along the strip takes the selection with it, as the
  // system's segmented control does.

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.slide || widget.onSelected == null) return;
    (_slide ??=
            HorizontalDragGestureRecognizer(
                debugOwner: this,
                supportedDevices: const {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                },
              )
              ..onStart = ((details) => _slideTo(details.globalPosition))
              ..onUpdate = ((details) => _slideTo(details.globalPosition)))
        .addPointer(event);
  }

  void _slideTo(Offset position) {
    for (var i = 0; i < _nodes.length; i++) {
      final box = _nodes[i].context?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final local = box.globalToLocal(position);
      // Only how far along the strip counts: a finger that drifts off the
      // strip keeps hold of it.
      if (local.dx < 0 || local.dx >= box.size.width) continue;
      if (i != _selected && _enabled(i)) {
        Haptics.selection(context);
        _select(i);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var list = switch (widget.variant) {
      TabBarVariant.segmented => _buildSegmented(context, theme),
      TabBarVariant.underline => _buildUnderline(context, theme),
    };
    list = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: list,
    );
    if (widget.slide) {
      list = Listener(onPointerDown: _handlePointerDown, child: list);
    }
    return list;
  }

  /// What a screen reader is told about the row of entries.
  Widget _describeRow(Widget row) {
    if (widget.radioGroup) {
      return Semantics(
        role: SemanticsRole.radioGroup,
        container: true,
        explicitChildNodes: true,
        child: row,
      );
    }
    // A tab bar must have a tab in it.
    if (widget.items.isEmpty) return row;
    return Semantics(
      role: SemanticsRole.tabBar,
      container: true,
      explicitChildNodes: true,
      child: row,
    );
  }

  /// What a screen reader is told about one entry: one node, with the
  /// button under it folded in.
  Widget _describeItem(
    int index, {
    required bool selected,
    required Widget button,
  }) {
    // The tooltip goes inside: what it adds for a screen reader is part of
    // the entry, and a tab bar may hold nothing but tabs.
    final child = _withTooltip(widget.items[index], button);
    return MergeSemantics(
      child: widget.radioGroup
          ? Semantics(
              inMutuallyExclusiveGroup: true,
              checked: selected,
              child: child,
            )
          : Semantics(
              role: SemanticsRole.tab,
              selected: selected,
              // The role wants a tap action of every tab that is not
              // marked disabled; the button below brings it.
              enabled: _enabled(index),
              child: child,
            ),
    );
  }

  /// The entry's label, read as its `semanticLabel` when it has one. Only
  /// the label is replaced: the button around it keeps its actions.
  Widget _labelOf(TabListItem item) {
    final label = item.semanticLabel;
    // A label that brings its own `Flexible` has to stay the row's child.
    if (label == null || item.child is Flexible) return item.child;
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: item.child),
    );
  }

  Widget _withTooltip(TabListItem item, Widget child) {
    final tooltip = item.tooltip;
    if (tooltip == null) return child;
    return Tooltip(builder: (context) => Text(tooltip), child: child);
  }

  ScrollController get _scroll => _scrollController ??= ScrollController();

  // -----------------------------------------------------------------------
  // The segmented look: a filled strip and a raised pill.
  // -----------------------------------------------------------------------

  Widget _buildSegmented(BuildContext context, ThemeData theme) {
    final tabsTheme = theme.tabsTheme;
    final padding = tabsTheme.padding ?? EdgeInsets.zero;
    final decoration = FinesseDecoration(
      color: theme.colorScheme.muted,
      border: FinesseBorder.all(borderRadius: theme.radius, width: 0),
    ).merge(tabsTheme.decoration);
    final expand = widget.expand && !widget.scrollable;
    final selected = _selected;

    // One selection pill for the whole list, travelling between the tabs,
    // in place of each tab painting its own. Around the row itself — inside
    // the scroll view — so the tabs' rectangles do not move as it scrolls.
    Widget row = MovingIndicator(
      spring: tabsTheme.indicatorSpring,
      stretch: tabsTheme.indicatorStretch,
      track: widget.track,
      child: _describeRow(
        Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          spacing: tabsTheme.tabsGap ?? 0,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              _segment(context, theme, i, selected: i == selected),
          ],
        ),
      ),
    );

    final constraints = tabsTheme.tabBarConstraints;
    if (constraints != null) {
      row = ConstrainedBox(constraints: constraints, child: row);
    }

    // A strip that hugs its tabs scrolls when they do not fit, rather than
    // overflowing; one whose tabs share the width never needs to.
    if (!expand) {
      row = ScrollConfiguration(
        // The scrolling tabs should not show an overscroll indicator.
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          dragStartBehavior:
              tabsTheme.dragStartBehavior ?? DragStartBehavior.start,
          scrollDirection: Axis.horizontal,
          controller: _scroll,
          padding: padding,
          physics: tabsTheme.physics,
          child: row,
        ),
      );
    } else {
      row = Padding(padding: padding, child: row);
    }

    // A strip that hugs its tabs has to be told where to sit, or a parent
    // that stretches it pulls the decoration out to the full width behind
    // the tabs. So the alignment goes *around* the decoration. Expanded
    // tabs fill whatever width there is, so for them this changes nothing —
    // it is built all the same, to keep one tree shape when a theme turns
    // expansion on or off.
    return Align(
      alignment:
          widget.alignment ??
          tabsTheme.tabBarAlignment ??
          AlignmentDirectional.centerStart,
      widthFactor: widget.shrinkWrap && !widget.expand ? 1 : null,
      heightFactor: 1,
      child: Decorator(decoration: decoration, child: row),
    );
  }

  Widget _segment(
    BuildContext context,
    ThemeData theme,
    int index, {
    required bool selected,
  }) {
    const clear = Color(0x00000000);
    final item = widget.items[index];
    final tabsTheme = theme.tabsTheme;
    final expand = widget.expand && !widget.scrollable;

    final background = tabsTheme.tabBackgroundColor ?? clear;
    final selectedFill =
        tabsTheme.tabSelectedBackgroundColor ?? theme.colorScheme.background;
    final hoverBackground = tabsTheme.tabHoverBackgroundColor ?? background;
    final selectedHover =
        tabsTheme.tabSelectedHoverBackgroundColor ?? selectedFill;
    final foreground =
        tabsTheme.tabForegroundColor ?? theme.colorScheme.foreground;
    final selectedForeground =
        tabsTheme.tabSelectedForegroundColor ?? foreground;
    final gradient = tabsTheme.tabGradient;

    // A tab's label is one line, and it is the part of the tab that gives
    // way: in a tab narrower than its content — an expanded one in a narrow
    // strip — the label is cut short with an ellipsis instead of
    // overflowing the row it shares with `leading` and `trailing`. A tab
    // that sizes to its content hands the label all the width it asks for,
    // so nothing changes there. A child that brings its own `Flexible`
    // keeps it (two of them around one child is an error).
    var label = DefaultTextStyle.merge(
      style: tabsTheme.tabTextStyle ?? theme.textTheme.small,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: _labelOf(item),
    );
    if (item.child is! Flexible) label = Flexible(child: label);

    final defaultDecoration = switch (theme.disableSecondaryBorder) {
      true => FinesseDecoration(
        border: FinesseBorder.all(
          borderRadius: BorderRadius.circular(2),
          width: 0,
          padding: const EdgeInsets.all(2),
        ),
        focusedBorder: FinesseBorder.all(
          width: 2,
          borderRadius: BorderRadius.circular(2),
          color: theme.colorScheme.ring,
        ),
      ),
      false => FinesseDecoration(
        border: FinesseBorder.all(
          borderRadius: BorderRadius.circular(2),
          width: 0,
        ),
        // No inner gutter around a tab: the strip's own padding is the only
        // inset. The focus ring is the standard outward ring; it may
        // overlap the strip.
        secondaryFocusedBorder: FinesseBorder.all(
          width: 2,
          borderRadius: theme.radius,
          offset: 2,
          color: theme.colorScheme.ring,
        ),
      ),
    };
    final decoration = defaultDecoration.merge(
      selected
          ? tabsTheme.tabSelectedDecoration ?? tabsTheme.tabDecoration
          : tabsTheme.tabDecoration,
    );

    // The selected tab's fill, radius and shadow are the travelling
    // indicator's, painted once by the list. The tab itself stays clear, so
    // two pills never show at once.
    final border = decoration.border;
    final pillFill = gradient == null ? selectedFill : null;
    final pill = ShadowDecoration(
      shadows: tabsTheme.tabSelectedShadows ?? Shadows.sm,
      decoration: border is FinesseRoundedSuperellipseBorder
          ? ShapeDecoration(
              color: pillFill,
              gradient: gradient,
              shape: border.toBorder(
                textDirection: Directionality.of(context),
                defaultBorderRadius: theme.radius,
              ),
            )
          : BoxDecoration(
              color: pillFill,
              gradient: gradient,
              borderRadius: border?.borderRadius ?? theme.radius,
            ),
    );

    final Widget tab = MovingIndicatorTarget(
      selected: selected,
      index: index,
      decoration: pill,
      child: _describeItem(
        index,
        selected: selected,
        button: Button.secondary(
          leading: item.leading,
          trailing: item.trailing,
          focusNode: _nodes[index],
          style: ButtonTheme(
            height: tabsTheme.tabHeight ?? 32,
            width: tabsTheme.tabWidth ?? (expand ? double.infinity : null),
            backgroundColor: selected ? clear : background,
            hoverBackgroundColor: selected
                ? (selectedHover == selectedFill ? clear : selectedHover)
                : hoverBackground,
            padding:
                tabsTheme.tabPadding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: decoration,
            foregroundColor: selected ? selectedForeground : foreground,
            shadows: selected ? const <BoxShadow>[] : tabsTheme.tabShadows,
            // The gradient belongs to the pill as well.
            gradient: selected ? null : gradient,
            // The label does not shrink away from a pill that stays put.
            pressScale: 1,
            hoverForegroundColor: tabsTheme.tabHoverForegroundColor,
            pressedBackgroundColor: tabsTheme.tabPressedBackgroundColor,
            pressedForegroundColor: tabsTheme.tabPressedForegroundColor,
            textDecoration: tabsTheme.tabTextDecoration,
            hoverTextDecoration: tabsTheme.tabHoverTextDecoration,
            mainAxisAlignment: tabsTheme.tabMainAxisAlignment,
            crossAxisAlignment: tabsTheme.tabCrossAxisAlignment,
          ),
          onPressed: () => _select(index),
          enabled: _enabled(index),
          size: tabsTheme.tabSize,
          mouseCursor: tabsTheme.tabMouseCursor,
          child: label,
        ),
      ),
    );
    return expand ? Expanded(child: tab) : tab;
  }

  // -----------------------------------------------------------------------
  // The underline look: text tabs and a travelling line.
  // -----------------------------------------------------------------------

  Widget _buildUnderline(BuildContext context, ThemeData theme) {
    final scheme = theme.colorScheme;
    final expand = widget.expand && !widget.scrollable;
    final selected = _selected;

    // Around the row, inside the scroll view: the line scrolls with the
    // tabs. In front of them, so it also covers the hairline.
    Widget row = MovingIndicator(
      position: DecorationPosition.foreground,
      spring: theme.tabsTheme.indicatorSpring,
      stretch: theme.tabsTheme.indicatorStretch,
      track: widget.track,
      child: _describeRow(
        Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              _underlined(context, theme, i, selected: i == selected),
          ],
        ),
      ),
    );
    if (!expand) {
      // Clipped at the sides, but one pixel taller than the tabs so the
      // indicator can reach over the hairline.
      row = ClipRect(
        clipper: const _BelowByOneClipper(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scroll,
          clipBehavior: Clip.none,
          child: row,
        ),
      );
    }
    // A `Container`, not a `DecoratedBox`: its border is laid out under the
    // tabs, so the hairline adds to the bar's height as it does in CSS
    // rather than eating into it.
    return Container(
      decoration: BoxDecoration(
        border: widget.showBorder
            ? Border(bottom: BorderSide(color: scheme.border))
            : null,
      ),
      child: row,
    );
  }

  Widget _underlined(
    BuildContext context,
    ThemeData theme,
    int index, {
    required bool selected,
  }) {
    final item = widget.items[index];
    final scheme = theme.colorScheme;
    final tabsTheme = theme.tabsTheme;
    final expand = widget.expand && !widget.scrollable;
    final height = tabsTheme.underlineHeight ?? theme.style.underlineTabHeight;
    final baseStyle = (tabsTheme.underlineTextStyle ?? theme.textTheme.large)
        .copyWith(height: 1);
    final motion = Motion.of(context);
    final indicator = BoxDecoration(
      color: tabsTheme.underlineColor ?? scheme.foreground,
      borderRadius: BorderRadius.circular(2),
    );
    final gap = theme.layoutTheme.gap(GapSize.sm);

    Widget tab = Pressable(
      selected: widget.radioGroup ? null : selected,
      focusNode: _nodes[index],
      onPressed: _enabled(index) ? () => _select(index) : null,
      // The travelling line is the response; a tab that shrank would take
      // its end of the line with it.
      pressScale: 1,
      builder: (context, states) {
        final active = selected || states.contains(WidgetState.hovered);
        final disabled = states.contains(WidgetState.disabled);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: theme.radius,
          // A floor once text is scaled up, so a label is never taller than
          // its tab; at a scale of 1 the two are the same.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height,
              maxHeight: textScaledMaxHeight(context, height),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Padding(
                  // Tabs that share the width need little padding of their
                  // own; tabs that hug their label need room.
                  padding:
                      tabsTheme.underlinePadding ??
                      EdgeInsets.symmetric(horizontal: expand ? 4 : 16),
                  // The colour fades; the weight cannot (a face is one
                  // weight, and a label that changed width every frame
                  // would shake its neighbours), so it switches at once.
                  child: AnimatedColorBuilder(
                    color: active && !disabled
                        ? scheme.foreground
                        : scheme.mutedForeground,
                    duration: motion.fast,
                    curve: motion.standard,
                    builder: (context, color, child) => IconTheme.merge(
                      data: IconThemeData(color: color, size: 18),
                      child: DefaultTextStyle.merge(
                        style: baseStyle.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: child!,
                      ),
                    ),
                    child: item.leading == null && item.trailing == null
                        ? _labelOf(item)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: gap,
                            children: [
                              ?item.leading,
                              Flexible(child: _labelOf(item)),
                              ?item.trailing,
                            ],
                          ),
                  ),
                ),
                // Where the line goes when this tab is selected. The line
                // itself is painted once, by the bar, and travels.
                Positioned(
                  left: 0,
                  right: 0,
                  // Over the bar's own hairline, which sits just below the
                  // tabs.
                  bottom: widget.showBorder ? -1 : 0,
                  height: 2,
                  child: MovingIndicatorTarget(
                    selected: selected,
                    index: index,
                    decoration: indicator,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    tab = _describeItem(index, selected: selected, button: tab);
    return expand ? Expanded(child: tab) : tab;
  }
}

class _BelowByOneClipper extends CustomClipper<Rect> {
  const _BelowByOneClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width, size.height + 1);

  @override
  bool shouldReclip(_BelowByOneClipper oldClipper) => false;
}
