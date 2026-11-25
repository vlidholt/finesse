import 'package:collection/collection.dart';
import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/components/divider.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/extensions/double.dart';
import 'package:finesse/src/utils/mouse_cursor_provider.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The result of resizing a panel.
///
/// Plumbing between a [ResizablePanelGroup] and its controller; not part
/// of the package's public API.
@internal
enum ResizeResult {
  /// The whole drag distance was applied.
  success,

  /// The leading panels could not shrink or grow enough, so only part of a
  /// backward drag was applied.
  failedLeading,

  /// The trailing panels could not shrink or grow enough, so only part of a
  /// forward drag was applied.
  failedTrailing,
}

/// The size information of a panel.
///
/// Plumbing between a [ResizablePanelGroup] and its controller; not part
/// of the package's public API. Read sizes with
/// [ResizableController.sizes].
@internal
class PanelInfo {
  /// Creates the size information of a panel. All sizes are fractions of the
  /// group, from 0 to 1.
  PanelInfo({
    required this.id,
    required this.defaultSize,
    this.minSize = 0,
    this.maxSize = 0,
  }) : _size = defaultSize,
       assert(
         minSize >= 0 && minSize <= 1.0,
         'minSize must be between 0 and 1',
       ),
       assert(
         maxSize >= 0 && maxSize <= 1.0,
         'maxSize must be between 0 and 1',
       ),
       assert(defaultSize >= 0 && defaultSize <= 1);

  /// The current size of the panel, as a fraction of the group.
  ///
  /// Setting a value below [minSize] or above [maxSize] throws.
  double get size => _size;

  set size(double value) {
    if (value < minSize) throw Exception('Size must be greater than minSize');
    if (value > maxSize) throw Exception('Size must be less than maxSize');
    _size = value;
  }

  /// {@template PanelInfo.defaultSize}
  /// The default size of the panel, which is set during initialization.
  /// Must be between [minSize] and [maxSize].
  /// {@endtemplate}
  final double defaultSize;

  /// {@template PanelInfo.minSize}
  /// The minimum size the panel can be resized to.
  /// Must be between 0 and 1.
  /// {@endtemplate}
  final double minSize;

  /// {@template PanelInfo.maxSize}
  /// The maximum size the panel can be resized to.
  /// Must be between 0 and 1.
  /// {@endtemplate}
  final double maxSize;

  /// {@template PanelInfo.id}
  /// The unique identifier for the panel.
  /// This must be unique among all panels in the group.
  /// {@endtemplate}
  final Object id;
  double _size;

  @override
  String toString() {
    return '''PanelInfo(size: $size, minSize: $minSize, maxSize: $maxSize, defaultSize: $defaultSize)''';
  }
}

/// Holds the sizes of the panels in a [ResizablePanelGroup] and resizes
/// them.
///
/// Pass one to [ResizablePanelGroup.controller] to read or change the
/// sizes from outside: [sizes] are the current fractions, [setSizes] applies
/// new ones and [reset] goes back to each panel's default. It notifies its
/// listeners whenever a size changes. When none is given, the group creates
/// its own.
class ResizableController extends ChangeNotifier {
  /// Creates a controller with no panels.
  ResizableController();

  /// The size information of each panel, in layout order.
  @internal
  final panelsInfo = <PanelInfo>[];

  /// The default size of each panel, in layout order. Used to reset sizes.
  final defaultSizes = <double>[];

  /// The size of each panel as a fraction of the group, in layout order.
  ///
  /// Empty until a [ResizablePanelGroup] has been built with this
  /// controller.
  List<double> get sizes => [for (final panel in panelsInfo) panel.size];

  /// Gives each panel the size at its index in [sizes], a fraction of the
  /// group, and notifies listeners.
  ///
  /// There must be one size per panel, each within the panel's minimum and
  /// maximum.
  void setSizes(List<double> sizes) {
    assert(
      sizes.length == panelsInfo.length,
      'setSizes was given ${sizes.length} sizes for ${panelsInfo.length} '
      'panels.',
    );
    for (var i = 0; i < sizes.length && i < panelsInfo.length; i++) {
      panelsInfo[i].size = sizes[i];
    }
    notifyListeners();
  }

  /// Gives every panel its default size again and notifies listeners.
  void reset() {
    for (var i = 0; i < panelsInfo.length; i++) {
      panelsInfo[i]._size = defaultSizes[i];
    }
    notifyListeners();
  }

  /// {@template ResizableController.registerPanel}
  /// This method adds a new panel to the controller and returns its index.
  /// {@endtemplate}
  @internal
  int registerPanel(PanelInfo info) {
    panelsInfo.add(info);
    defaultSizes.add(info.defaultSize);
    return panelsInfo.length - 1;
  }

  /// Inserts a panel at [index] and notifies listeners.
  @internal
  void insertPanel(int index, PanelInfo info) {
    panelsInfo.insert(index, info);
    defaultSizes.insert(index, info.defaultSize);
    notifyListeners();
  }

  /// Removes the panel with the given [id] and notifies listeners.
  ///
  /// Does nothing if no panel has that id.
  @internal
  void unregisterPanel(Object id) {
    final index = panelsInfo.indexWhere((e) => e.id == id);
    if (index == -1) return;
    panelsInfo.removeAt(index);
    defaultSizes.removeAt(index);
    notifyListeners();
  }

  /// {@template ResizableController.getPanelInfo}
  /// This method retrieves the information of a panel at the specified index.
  /// Throws an exception if the index is out of bounds.
  /// {@endtemplate}
  @internal
  PanelInfo getPanelInfo(int index) {
    final contains = panelsInfo.length > index;
    if (!contains) throw Exception('Panel info not found for index: $index');
    return panelsInfo[index];
  }

  /// Update the panel info with the given [panels]
  @internal
  void update(List<PanelInfo> panels) {
    clear();
    panels.forEach(registerPanel);
    notifyListeners();
  }

  /// Clear all the panel info and default sizes
  @internal
  void clear() {
    panelsInfo.clear();
    defaultSizes.clear();
  }

  /// Adjusts the layout using an absolute percentage delta from the initial
  /// layout snapshot (captured at drag start).
  ///
  /// This mirrors the react-resizable-panels approach: rather than applying
  /// incremental deltas, the entire layout is recalculated from the snapshot
  /// on every pointer move event. This eliminates floating-point drift and
  /// produces natural drag reversal behavior.
  ///
  /// [delta] is the total drag distance as a fraction of the total available
  /// width (positive = forward/right/down, negative = backward/left/up).
  ///
  /// [initialLayout] is the layout snapshot taken at drag start.
  ///
  /// [pivotIndices] is the pair of panel indices adjacent to the dragged
  /// divider: `[leadingIndex, trailingIndex]`.
  @internal
  ResizeResult resize({
    required double delta,
    required List<double> initialLayout,
    required List<int> pivotIndices,
  }) {
    if (delta.abs() < 1e-9) {
      _applyLayout(initialLayout);
      return ResizeResult.success;
    }

    final leadingPivot = pivotIndices[0];
    final trailingPivot = pivotIndices[1];
    final nextLayout = List<double>.from(initialLayout);
    var deltaApplied = 0.0;

    final originalDelta = delta;

    if (delta > 0) {
      // Forward drag: shrink trailing panels, grow leading pivot panel.

      // Phase 0: cap delta to min(totalShrinkable, totalExpandable).
      var totalShrinkable = 0.0;
      for (var i = trailingPivot; i < panelsInfo.length; i++) {
        totalShrinkable += initialLayout[i] - panelsInfo[i].minSize;
      }
      var totalExpandable =
          panelsInfo[leadingPivot].maxSize - initialLayout[leadingPivot];
      for (var i = leadingPivot - 1; i >= 0; i--) {
        totalExpandable += panelsInfo[i].maxSize - initialLayout[i];
      }
      final maxDelta = totalShrinkable < totalExpandable
          ? totalShrinkable
          : totalExpandable;
      final cappedDelta = delta > maxDelta ? maxDelta : delta;

      // Phase 1: shrink trailing panels from pivot outward.
      for (var i = trailingPivot; i < panelsInfo.length; i++) {
        final info = panelsInfo[i];
        final available = nextLayout[i] - info.minSize;
        if (available < 1e-9) continue;
        final shrink = (cappedDelta - deltaApplied).clamp(0.0, available);
        nextLayout[i] = (nextLayout[i] - shrink).asFixed(6);
        deltaApplied = (deltaApplied + shrink).asFixed(6);
        if ((cappedDelta - deltaApplied).abs() < 1e-9) break;
      }

      // Phase 2: grow leading pivot panel.
      final pivotInfo = panelsInfo[leadingPivot];
      final canGrow = pivotInfo.maxSize - nextLayout[leadingPivot];
      final grow = deltaApplied.clamp(0.0, canGrow);
      nextLayout[leadingPivot] = (nextLayout[leadingPivot] + grow).asFixed(6);
      var overflow = (deltaApplied - grow).asFixed(6);

      // Phase 3: cascade overflow to other leading panels.
      if (overflow > 1e-9) {
        for (var i = leadingPivot - 1; i >= 0; i--) {
          final info = panelsInfo[i];
          final canGrowI = info.maxSize - nextLayout[i];
          final growI = overflow.clamp(0.0, canGrowI);
          nextLayout[i] = (nextLayout[i] + growI).asFixed(6);
          overflow = (overflow - growI).asFixed(6);
          if (overflow < 1e-9) break;
        }
      }
    } else {
      // Backward drag: shrink leading panels, grow trailing pivot panel.
      final absDelta = -delta;
      var absApplied = 0.0;

      // Phase 0: cap delta to min(totalShrinkable, totalExpandable).
      var totalShrinkable = 0.0;
      for (var i = leadingPivot; i >= 0; i--) {
        totalShrinkable += initialLayout[i] - panelsInfo[i].minSize;
      }
      var totalExpandable =
          panelsInfo[trailingPivot].maxSize - initialLayout[trailingPivot];
      for (var i = trailingPivot + 1; i < panelsInfo.length; i++) {
        totalExpandable += panelsInfo[i].maxSize - initialLayout[i];
      }
      final maxDelta = totalShrinkable < totalExpandable
          ? totalShrinkable
          : totalExpandable;
      final cappedDelta = absDelta > maxDelta ? maxDelta : absDelta;

      // Phase 1: shrink leading panels from pivot outward.
      for (var i = leadingPivot; i >= 0; i--) {
        final info = panelsInfo[i];
        final available = nextLayout[i] - info.minSize;
        if (available < 1e-9) continue;
        final shrink = (cappedDelta - absApplied).clamp(0.0, available);
        nextLayout[i] = (nextLayout[i] - shrink).asFixed(6);
        absApplied = (absApplied + shrink).asFixed(6);
        if ((cappedDelta - absApplied).abs() < 1e-9) break;
      }

      deltaApplied = absApplied;

      // Phase 2: grow trailing pivot panel.
      final pivotInfo = panelsInfo[trailingPivot];
      final canGrow = pivotInfo.maxSize - nextLayout[trailingPivot];
      final grow = deltaApplied.clamp(0.0, canGrow);
      nextLayout[trailingPivot] = (nextLayout[trailingPivot] + grow).asFixed(6);
      var overflow = (deltaApplied - grow).asFixed(6);

      // Phase 3: cascade overflow to other trailing panels.
      if (overflow > 1e-9) {
        for (var i = trailingPivot + 1; i < panelsInfo.length; i++) {
          final info = panelsInfo[i];
          final canGrowI = info.maxSize - nextLayout[i];
          final growI = overflow.clamp(0.0, canGrowI);
          nextLayout[i] = (nextLayout[i] + growI).asFixed(6);
          overflow = (overflow - growI).asFixed(6);
          if (overflow < 1e-9) break;
        }
      }
    }

    // Validation: layout must sum to ~1.0.
    final sum = nextLayout.fold<double>(0, (a, b) => a + b);
    if ((sum - 1.0).abs() > 0.01) {
      // Layout is invalid; keep the current layout unchanged.
      return delta > 0
          ? ResizeResult.failedTrailing
          : ResizeResult.failedLeading;
    }

    _applyLayout(nextLayout);

    // Determine result based on whether the full original delta was consumed.
    if (originalDelta > 0) {
      // Total shrinkage on trailing side = total growth on leading side.
      var totalGrowth = 0.0;
      for (var i = 0; i <= leadingPivot; i++) {
        totalGrowth += nextLayout[i] - initialLayout[i];
      }
      if ((totalGrowth - originalDelta).abs() > 1e-6) {
        return ResizeResult.failedTrailing;
      }
    } else {
      var totalGrowth = 0.0;
      for (var i = trailingPivot; i < nextLayout.length; i++) {
        totalGrowth += nextLayout[i] - initialLayout[i];
      }
      if ((totalGrowth - (-originalDelta)).abs() > 1e-6) {
        return ResizeResult.failedLeading;
      }
    }

    return ResizeResult.success;
  }

  /// Applies a pre-validated layout directly to panel sizes.
  void _applyLayout(List<double> layout) {
    for (var i = 0; i < layout.length && i < panelsInfo.length; i++) {
      panelsInfo[i]._size = layout[i];
    }
    notifyListeners();
  }

  /// Reset the default sizes of the leading and trailing panels.
  @internal
  void resetDefaultSizes(int leadingIndex, int trailingIndex) {
    assert(
      (leadingIndex - trailingIndex).abs() == 1,
      'The indexes resized must be adjacent',
    );
    final leadingPanelInfo = getPanelInfo(leadingIndex);
    final trailingPanelInfo = getPanelInfo(trailingIndex);
    leadingPanelInfo.size = defaultSizes[leadingIndex];
    trailingPanelInfo.size = defaultSizes[trailingIndex];
    notifyListeners();
  }

  /// The size of the group along its axis, in logical pixels.
  ///
  /// The group sets this value during layout. It converts drag distances into
  /// fractions.
  @internal
  double totalAvailableWidth = 0;

  /// The total size of all registered panels, used to calculate available
  /// space for resizing.
  @internal
  double get base => panelsInfo
      .fold<double>(
        0,
        (previousValue, element) => previousValue + element.size,
      )
      .asFixed(6);
}

/// {@template ResizablePanelGroup}
/// A widget that provides a group of resizable panels, allowing users to
/// adjust the size of each panel dynamically.
///
/// The [ResizablePanelGroup] manages multiple [ResizablePanel] widgets
/// and provides functionality to resize them by dragging dividers between them.
/// It supports both horizontal and vertical arrangements of panels, and allows
/// customization of the appearance and behavior of the dividers and handles.
///
/// This widget is useful for creating flexible layouts where users can adjust
/// the size of different sections of the UI according to their preferences.
/// {@endtemplate}
class ResizablePanelGroup extends StatefulWidget {
  /// {@macro ResizablePanelGroup}
  const ResizablePanelGroup({
    super.key,
    required this.children,
    this.axis = Axis.horizontal,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,
    this.verticalDirection,
    this.controller,
    this.showHandle,
    this.handleIcon,
    this.dividerSize,
    this.dividerThickness,
    this.onDividerDoubleTap,
    this.resetOnDoubleTap,
    this.dividerColor,
    this.handleDecoration,
    this.handlePadding,
    this.handleSize,
  });

  /// {@template ResizablePanelGroup.axis}
  /// The axis along which the panels are arranged.
  /// Can be either [Axis.horizontal] or [Axis.vertical].
  /// {@endtemplate}
  final Axis axis;

  /// {@template ResizablePanelGroup.children}
  /// The list of resizable panels to be displayed in the group.
  /// Each panel must be a [ResizablePanel].
  /// {@endtemplate}
  final List<ResizablePanel> children;

  /// {@template ResizablePanelGroup.mainAxisAlignment}
  /// The alignment of the panels along the main axis.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template ResizablePanelGroup.crossAxisAlignment}
  /// The alignment of the panels along the cross axis.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template ResizablePanelGroup.mainAxisSize}
  /// The size of the main axis for the panels.
  /// {@endtemplate}
  final MainAxisSize? mainAxisSize;

  /// {@template ResizablePanelGroup.verticalDirection}
  /// The vertical direction for the panels' layout.
  /// Can be set to [VerticalDirection.down] or [VerticalDirection.up].
  /// {@endtemplate}
  final VerticalDirection? verticalDirection;

  /// {@template ResizablePanelGroup.controller}
  /// The controller that manages the resizable panels.
  /// If not provided, a new controller will be created.
  /// {@endtemplate}
  final ResizableController? controller;

  /// {@template ResizablePanelGroup.showHandle}
  /// Whether to show the resize handle between panels.
  /// {@endtemplate}
  final bool? showHandle;

  /// {@template ResizablePanelGroup.handleIcon}
  /// A custom widget to use as the resize handle.
  /// If provided, this will be displayed instead of the default grip and
  /// its decoration. Defaults to `ResizableTheme.handleIcon`.
  /// {@endtemplate}
  final Widget? handleIcon;

  /// {@template ResizablePanelGroup.dividerSize}
  /// The size of the divider between panels.
  /// {@endtemplate}
  final double? dividerSize;

  /// {@template ResizablePanelGroup.dividerThickness}
  /// The thickness of the divider between panels.
  /// {@endtemplate}
  final double? dividerThickness;

  /// {@template ResizablePanelGroup.onDividerDoubleTap}
  /// Callback function that is triggered when the divider is double-tapped.
  /// {@endtemplate}
  final VoidCallback? onDividerDoubleTap;

  /// {@template ResizablePanelGroup.resetOnDoubleTap}
  /// Whether to reset the panel sizes on double-tap of the divider.
  /// {@endtemplate}
  final bool? resetOnDoubleTap;

  /// {@template ResizablePanelGroup.dividerColor}
  /// The color of the divider between panels.
  /// {@endtemplate}
  final Color? dividerColor;

  /// {@template ResizablePanelGroup.handleDecoration}
  /// Custom decoration for the resize handle.
  /// {@endtemplate}
  final FinesseDecoration? handleDecoration;

  /// {@template ResizablePanelGroup.handlePadding}
  /// Padding around the resize handle.
  /// {@endtemplate}
  final EdgeInsetsGeometry? handlePadding;

  /// {@template ResizablePanelGroup.handleSize}
  /// The size of the resize handle icon.
  /// {@endtemplate}
  final double? handleSize;

  @override
  State<ResizablePanelGroup> createState() => _ResizablePanelGroupState();
}

class _ResizablePanelGroupState extends State<ResizablePanelGroup> {
  ResizableController? _internalController;

  /// Sets the mouse cursor while a divider is dragged.
  late final mouseCursorController = context.read<MouseCursorController>();

  /// Whether a divider is being dragged.
  final dragging = ValueNotifier<bool>(false);

  /// The constraints of the group from the last layout.
  BoxConstraints? currentConstraints;

  /// Snapshot of panel sizes at drag start (absolute-delta approach).
  List<double>? _initialLayout;

  /// Global pointer position at drag start.
  double? _pointerDownPosition;

  /// Whether the panels are laid out in a row.
  bool get isHorizontal => widget.axis == Axis.horizontal;

  /// Whether the panels are laid out in a column.
  bool get isVertical => widget.axis == Axis.vertical;

  /// The number of dividers, one fewer than the number of panels.
  int get dividersCount => widget.children.length - 1;

  /// The controller in use: [ResizablePanelGroup.controller], or an
  /// internal one when that is null.
  ResizableController get controller {
    if (widget.controller != null) return widget.controller!;
    return _internalController ??= ResizableController();
  }

  @override
  void initState() {
    super.initState();
    dragging.addListener(() {
      if (!dragging.value) mouseCursorController.cursor = MouseCursor.defer;
    });
    registerPanels();
  }

  @override
  void didUpdateWidget(covariant ResizablePanelGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Adding and removing panels
    if (oldWidget.children.length != widget.children.length) {
      oldWidget.children
          .map((e) => e.id)
          .where((e) => !widget.children.map((e) => e.id).contains(e))
          .forEach(controller.unregisterPanel);
      final addedIds = widget.children
          .map((e) => e.id)
          .where((e) => !oldWidget.children.map((e) => e.id).contains(e))
          .toList();

      final totalSize = controller.panelsInfo.fold<double>(
        0,
        (previousValue, element) => previousValue + element.size,
      );
      final availableSize = 1 - totalSize;
      final availableSizePerPanel = availableSize / addedIds.length;
      for (final id in addedIds) {
        final index = widget.children.indexWhere((e) => e.id == id);
        final info = widget.children[index];
        controller.insertPanel(
          index,
          PanelInfo(
            id: info.id,
            defaultSize: availableSizePerPanel,
            minSize: info.minSize,
            maxSize: info.maxSize,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    dragging.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  /// Registers every child panel with the [controller].
  void registerPanels() {
    for (final c in widget.children) {
      controller.registerPanel(
        PanelInfo(
          id: c.id,
          defaultSize: c.defaultSize,
          minSize: c.minSize,
          maxSize: c.maxSize,
        ),
      );
    }
  }

  /// Starts a drag of the divider after the panel at [index].
  ///
  /// Saves the current sizes, so each update can resize from them.
  void onHandleDragStart({
    required int index,
    required DragStartDetails details,
  }) {
    dragging.value = true;
    _initialLayout = controller.panelsInfo.map((p) => p.size).toList();
    _pointerDownPosition = widget.axis == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;
  }

  /// Ends the current divider drag.
  void onHandleDragEnd() {
    dragging.value = false;
    _initialLayout = null;
    _pointerDownPosition = null;
  }

  /// Resizes the panels on each side of the divider after the panel at
  /// [index], from the sizes saved at drag start.
  ///
  /// Also sets the mouse cursor to show in which directions the divider can
  /// still move.
  void onHandleDragUpdate({
    required int index,
    required DragUpdateDetails details,
  }) {
    if (_initialLayout == null || _pointerDownPosition == null) return;

    final rtl = Directionality.of(context) == TextDirection.rtl;
    final currentPosition = widget.axis == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;

    var pixelDelta = (currentPosition - _pointerDownPosition!).asFixed(6);

    // Invert the offset for RTL horizontal dragging
    if (rtl && widget.axis == Axis.horizontal) {
      pixelDelta = -pixelDelta;
    }

    // Convert pixel delta to percentage of total available width.
    final delta = (pixelDelta / controller.totalAvailableWidth).asFixed(6);

    final result = controller.resize(
      delta: delta,
      initialLayout: _initialLayout!,
      pivotIndices: [index, index + 1],
    );

    switch (result) {
      case ResizeResult.success:
        final cursor = switch (widget.axis) {
          Axis.horizontal => SystemMouseCursors.resizeLeftRight,
          Axis.vertical => SystemMouseCursors.resizeUpDown,
        };
        mouseCursorController.cursor = cursor;
      case ResizeResult.failedLeading:
        final cursor = switch (widget.axis) {
          Axis.horizontal => SystemMouseCursors.resizeRight,
          Axis.vertical => SystemMouseCursors.resizeDown,
        };
        mouseCursorController.cursor = cursor;
      case ResizeResult.failedTrailing:
        final cursor = switch (widget.axis) {
          Axis.horizontal => SystemMouseCursors.resizeLeft,
          Axis.vertical => SystemMouseCursors.resizeUp,
        };
        mouseCursorController.cursor = cursor;
    }
  }

  /// Resets the two panels on each side of a divider to their default sizes.
  ///
  /// The indexes must be adjacent.
  void resetDefaultSizes(int leadingIndex, int trailingIndex) {
    assert((leadingIndex - trailingIndex).abs() == 1);
    controller.resetDefaultSizes(leadingIndex, trailingIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveShowHandle =
        widget.showHandle ?? theme.resizableTheme.showHandle ?? false;
    final effectiveDividerSize =
        widget.dividerSize ?? theme.resizableTheme.dividerSize ?? 8.0;

    final effectiveDividerThickness =
        widget.dividerThickness ?? theme.resizableTheme.dividerThickness ?? 1.0;
    final effectiveResetOnDoubleTap =
        widget.resetOnDoubleTap ??
        theme.resizableTheme.resetOnDoubleTap ??
        true;

    final effectiveDividerColor =
        widget.dividerColor ??
        theme.resizableTheme.dividerColor ??
        theme.colorScheme.border;

    final effectiveHandleDecoration =
        FinesseDecoration(
              color: theme.colorScheme.border,
              border: FinesseBorder.all(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                width: 0,
              ),
              disableSecondaryBorder: true,
            )
            .merge(theme.resizableTheme.handleDecoration)
            .merge(widget.handleDecoration);

    final effectiveHandlePadding =
        widget.handlePadding ??
        theme.resizableTheme.handlePadding ??
        EdgeInsets.symmetric(
          horizontal: widget.axis == Axis.vertical ? 3 : 1,
          vertical: widget.axis == Axis.vertical ? 1 : 3,
        );
    final effectiveHandleSize =
        widget.handleSize ?? theme.resizableTheme.handleSize ?? 10;

    final effectiveMainAxisAlignment =
        widget.mainAxisAlignment ??
        theme.resizableTheme.mainAxisAlignment ??
        MainAxisAlignment.start;
    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        theme.resizableTheme.crossAxisAlignment ??
        CrossAxisAlignment.center;
    final effectiveMainAxisSize =
        widget.mainAxisSize ??
        theme.resizableTheme.mainAxisSize ??
        MainAxisSize.max;
    final effectiveVerticalDirection =
        widget.verticalDirection ??
        theme.resizableTheme.verticalDirection ??
        VerticalDirection.down;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final effectivesSizes = controller.panelsInfo
            .map((e) => e.size)
            .toList();

        final rtl = Directionality.of(context) == TextDirection.rtl;

        final divider = switch (widget.axis) {
          Axis.horizontal => Divider.vertical(
            margin: EdgeInsets.symmetric(horizontal: effectiveDividerSize / 2),
            thickness: effectiveDividerThickness,
            color: effectiveDividerColor,
          ),
          Axis.vertical => SizedBox(
            // double.infinity doesn't work, just providing a big number
            width: 50000,
            child: Divider(
              margin: EdgeInsets.symmetric(vertical: effectiveDividerSize / 2),
              thickness: effectiveDividerThickness,
              color: effectiveDividerColor,
            ),
          ),
        };

        return LayoutBuilder(
          builder: (context, constraints) {
            currentConstraints = constraints;

            controller.totalAvailableWidth = isHorizontal
                ? currentConstraints!.maxWidth
                : currentConstraints!.maxHeight;
            final child = Flex(
              direction: widget.axis,
              mainAxisAlignment: effectiveMainAxisAlignment,
              crossAxisAlignment: effectiveCrossAxisAlignment,
              mainAxisSize: effectiveMainAxisSize,
              verticalDirection: effectiveVerticalDirection,
              children: widget.children.mapIndexed(
                (i, e) {
                  final flex =
                      ((effectivesSizes.elementAtOrNull(i) ?? 1) * 1000)
                          .toInt();
                  return KeyedSubtree(
                    key: ValueKey(e.id),
                    child: Expanded(
                      flex: flex,
                      child: Offstage(
                        offstage: flex <= 0.015,
                        child: e,
                      ),
                    ),
                  );
                },
              ).toList(),
            );

            // lazy, will be initialized when the handle is needed
            late final handle =
                widget.handleIcon ??
                theme.resizableTheme.handleIcon ??
                Decorator(
                  decoration: effectiveHandleDecoration,
                  child: Padding(
                    padding: effectiveHandlePadding,
                    child: PhosphorIcon(
                      isHorizontal
                          ? PhosphorIconsRegular.dotsSixVertical
                          : PhosphorIconsRegular.dotsSix,
                      size: effectiveHandleSize,
                    ),
                  ),
                );

            final dividers = <Widget>[];
            for (var i = 0; i < dividersCount; i++) {
              var leadingPosition = effectivesSizes
                  .sublist(0, i + 1)
                  .fold<double>(
                    0,
                    (previousValue, element) => previousValue + element,
                  );

              leadingPosition = isHorizontal
                  ? leadingPosition * constraints.maxWidth / controller.base
                  : leadingPosition * constraints.maxHeight / controller.base;

              leadingPosition -= effectiveDividerSize > effectiveHandleSize
                  ? effectiveDividerSize / 2
                  : effectiveHandleSize / 2;

              dividers.add(
                Positioned(
                  top: isHorizontal ? 0 : leadingPosition,
                  left: isHorizontal && !rtl ? leadingPosition : null,
                  right: isHorizontal && rtl ? leadingPosition : null,
                  bottom: isHorizontal ? 0 : null,
                  child: GestureDetector(
                    onDoubleTap:
                        widget.onDividerDoubleTap ??
                        () {
                          if (!effectiveResetOnDoubleTap) return;
                          resetDefaultSizes(i, i + 1);
                        },
                    onHorizontalDragStart: isHorizontal
                        ? (details) =>
                              onHandleDragStart(index: i, details: details)
                        : null,
                    onHorizontalDragEnd: (_) =>
                        isHorizontal ? onHandleDragEnd() : null,
                    onHorizontalDragCancel: () =>
                        isHorizontal ? onHandleDragEnd() : null,
                    onHorizontalDragUpdate: (details) => isHorizontal
                        ? onHandleDragUpdate(
                            details: details,
                            index: i,
                          )
                        : null,
                    onVerticalDragStart: isVertical
                        ? (details) =>
                              onHandleDragStart(index: i, details: details)
                        : null,
                    onVerticalDragEnd: (_) =>
                        isVertical ? onHandleDragEnd() : null,
                    onVerticalDragCancel: () =>
                        isVertical ? onHandleDragEnd() : null,
                    onVerticalDragUpdate: (details) => isVertical
                        ? onHandleDragUpdate(
                            details: details,
                            index: i,
                          )
                        : null,
                    child: MouseRegion(
                      onEnter: (_) {
                        final cursor = switch (widget.axis) {
                          Axis.horizontal => SystemMouseCursors.resizeLeftRight,
                          Axis.vertical => SystemMouseCursors.resizeUpDown,
                        };

                        mouseCursorController.cursor = cursor;
                      },
                      onExit: (details) async {
                        if (dragging.value) return;
                        mouseCursorController.cursor = MouseCursor.defer;
                      },
                      child: effectiveShowHandle
                          ? Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                divider,
                                handle,
                              ],
                            )
                          : divider,
                    ),
                  ),
                ),
              );
            }

            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                child,
                ...dividers,
              ],
            );
          },
        );
      },
    );
  }
}

/// {@template ResizablePanel}
/// A widget that represents a single resizable panel within a
/// [ResizablePanelGroup].
///
/// The [ResizablePanel] allows users to define a panel that can be resized
/// dynamically. It requires an ID for uniqueness, a child widget to display,
/// and size constraints to control the resizing behavior. This panel can be
/// part of a larger group of panels that can be resized relative to each other.
/// {@endtemplate}
class ResizablePanel extends StatelessWidget {
  /// {@macro ResizablePanel}
  const ResizablePanel({
    super.key,
    required this.id,
    required this.child,
    required this.defaultSize,
    this.minSize = 0.0,
    this.maxSize = 1.0,
  }) : assert(
         minSize >= 0,
         'minSize must be greater than or equal to 0',
       ),
       assert(
         maxSize >= 0,
         'maxSize must be greater than or equal to 0',
       ),
       assert(
         minSize <= maxSize,
         'minSize must be less than or equal to maxSize',
       ),
       assert(
         defaultSize >= minSize && defaultSize <= maxSize,
         'defaultSize must be greater than or equal to minSize and less than'
         ' or equal to maxSize',
       );

  /// {@template ResizablePanel.id}
  /// The unique identifier for the panel.
  /// This ID must be unique among all panels in the group to ensure proper
  /// management and resizing behavior.
  /// {@endtemplate}
  final Object id;

  /// {@template ResizablePanel.child}
  /// The child widget displayed within the panel.
  /// This can be any widget that represents the content of the panel.
  /// {@endtemplate}
  final Widget child;

  /// {@template ResizablePanel.defaultSize}
  /// The default size of the panel when it is first displayed.
  /// This value must be between [minSize] and [maxSize].
  /// {@endtemplate}
  final double defaultSize;

  /// {@template ResizablePanel.minSize}
  /// The minimum size the panel can be resized to.
  /// This value must be greater than or equal to 0.
  /// {@endtemplate}
  final double minSize;

  /// {@template ResizablePanel.maxSize}
  /// The maximum size the panel can be resized to.
  /// This value must be greater than or equal to 0.
  /// {@endtemplate}
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}
