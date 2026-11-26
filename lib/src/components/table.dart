import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:una/src/theme/color_scheme/base.dart';
import 'package:una/src/theme/components/table.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/extensions/text_style.dart';

/// Builder function for creating [UnaTableCell] widgets.
typedef TableCellBuilder = UnaTableCell Function(
  BuildContext context,
  TableVicinity vicinity,
);

/// Enum representing different variants of [UnaTableCell].
enum TableCellVariant {
  /// Variant for header cells.
  header,

  /// Variant for regular data cells.
  cell,

  /// Variant for footer cells.
  footer,
}

/// {@template UnaTableCell}
/// A cell widget for use within [UnaTable].
///
/// Provides styling and structure for table cells, including header and footer
/// variants.
/// {@endtemplate}
class UnaTableCell extends TableViewCell {
  /// {@macro UnaTableCell}
  const UnaTableCell({
    super.key,
    this.variant = TableCellVariant.cell,
    required super.child,
    this.alignment,
    this.height,
    this.padding,
    this.style,
  });

  /// Creates a [UnaTableCell] with the header variant.
  ///
  /// {@macro UnaTableCell}
  const UnaTableCell.header({
    super.key,
    required super.child,
    this.alignment,
    this.height,
    this.padding,
    this.style,
  }) : variant = TableCellVariant.header;

  /// Creates a [UnaTableCell] with the footer variant.
  ///
  /// {@macro UnaTableCell}
  const UnaTableCell.footer({
    super.key,
    required super.child,
    this.alignment,
    this.height,
    this.padding,
    this.style,
  }) : variant = TableCellVariant.footer;

  /// {@template UnaTableCell.variant}
  /// The variant of the table cell, determining its styling.
  /// {@endtemplate}
  final TableCellVariant variant;

  /// {@template UnaTableCell.alignment}
  /// Alignment of the cell's content.
  /// {@endtemplate}
  final AlignmentGeometry? alignment;

  /// {@template UnaTableCell.height}
  /// Height of the table cell.
  /// {@endtemplate}
  final double? height;

  /// {@template UnaTableCell.padding}
  /// Padding within the table cell.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template UnaTableCell.style}
  /// Text style for the cell's content.
  /// {@endtemplate}
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveAlignment =
        alignment ??
        theme.tableTheme.cellAlignment ??
        AlignmentDirectional.centerStart;

    final effectiveHeight = height ?? theme.tableTheme.cellHeight ?? 48;

    final effectivePadding =
        padding ??
        theme.tableTheme.cellPadding ??
        const EdgeInsets.symmetric(horizontal: 16);

    final textStyle =
        style ??
        switch (variant) {
          TableCellVariant.cell =>
            (theme.tableTheme.cellStyle ?? theme.textTheme.muted).fallback(
              color: theme.colorScheme.foreground,
            ),
          TableCellVariant.header =>
            (theme.tableTheme.cellHeaderStyle ??
                    theme.textTheme.muted.copyWith(fontWeight: FontWeight.w500))
                .fallback(color: theme.colorScheme.foreground),
          TableCellVariant.footer =>
            (theme.tableTheme.cellFooterStyle ??
                    theme.textTheme.muted.copyWith(fontWeight: FontWeight.w500))
                .fallback(color: theme.colorScheme.foreground),
        };

    return TableViewCell(
      child: Container(
        width: double.infinity,
        height: effectiveHeight,
        alignment: effectiveAlignment,
        padding: effectivePadding,
        child: DefaultTextStyle(
          style: textStyle,
          child: child,
        ),
      ),
    );
  }
}

/// {@template UnaTable}
/// A customizable table widget for displaying tabular data.
///
/// Supports on-demand cell building, fixed lists of cells, headers, footers,
/// and various interactions.
/// {@endtemplate}
class UnaTable extends StatefulWidget {
  /// Creates a [UnaTable] of widgets that are created on demand.
  ///
  /// This constructor is appropriate for table views with a large
  /// number of cells because the [builder] is called only for those
  /// cells that are actually visible.
  const UnaTable({
    super.key,
    required TableCellBuilder this.builder,
    required this.columnCount,
    required this.rowCount,
    UnaTableCell Function(BuildContext context, int column)? header,
    UnaTableCell Function(BuildContext context, int column)? footer,
    this.columnBuilder,
    this.rowBuilder,
    this.rowSpanExtent,
    this.columnSpanExtent,
    this.rowSpanBackgroundDecoration,
    this.rowSpanForegroundDecoration,
    this.rowSelected,
    this.columnSpanBackgroundDecoration,
    this.columnSpanForegroundDecoration,
    this.onHoveredRowIndex,
    this.horizontalScrollController,
    this.verticalScrollController,
    this.pinnedRowCount,
    this.pinnedColumnCount,
    this.primary,
    this.diagonalDragBehavior,
    this.dragStartBehavior,
    this.keyboardDismissBehavior,
    this.verticalScrollPhysics,
    this.horizontalScrollPhysics,
    this.onRowTap,
    this.onColumnTap,
    this.supportedDevices,
    this.onRowTapDown,
    this.onRowTapUp,
    this.onRowTapCancel,
    this.onRowSecondaryTap,
    this.onRowSecondaryTapDown,
    this.onRowSecondaryTapUp,
    this.onRowSecondaryTapCancel,
    this.onColumnTapDown,
    this.onColumnTapUp,
    this.onColumnTapCancel,
    this.onColumnSecondaryTap,
    this.onColumnSecondaryTapDown,
    this.onColumnSecondaryTapUp,
    this.onColumnSecondaryTapCancel,
  }) : children = null,
       headerBuilder = header,
       footerBuilder = footer,
       header = null,
       footer = null;

  /// Creates a [UnaTable] from an explicit two dimensional array of
  /// [children].
  ///
  /// This constructor is appropriate for list views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the list view instead of just
  /// those children that are actually visible.
  UnaTable.list({
    super.key,
    required Iterable<Iterable<UnaTableCell>> this.children,
    this.header,
    this.footer,
    this.columnBuilder,
    this.rowBuilder,
    this.rowSpanExtent,
    this.columnSpanExtent,
    this.rowSpanBackgroundDecoration,
    this.rowSpanForegroundDecoration,
    this.rowSelected,
    this.columnSpanBackgroundDecoration,
    this.columnSpanForegroundDecoration,
    this.onHoveredRowIndex,
    this.horizontalScrollController,
    this.verticalScrollController,
    this.pinnedRowCount,
    this.pinnedColumnCount,
    this.primary,
    this.diagonalDragBehavior,
    this.dragStartBehavior,
    this.keyboardDismissBehavior,
    this.verticalScrollPhysics,
    this.horizontalScrollPhysics,
    this.onRowTap,
    this.onColumnTap,
    this.supportedDevices,
    this.onRowTapDown,
    this.onRowTapUp,
    this.onRowTapCancel,
    this.onRowSecondaryTap,
    this.onRowSecondaryTapDown,
    this.onRowSecondaryTapUp,
    this.onRowSecondaryTapCancel,
    this.onColumnTapDown,
    this.onColumnTapUp,
    this.onColumnTapCancel,
    this.onColumnSecondaryTap,
    this.onColumnSecondaryTapDown,
    this.onColumnSecondaryTapUp,
    this.onColumnSecondaryTapCancel,
  }) : builder = null,
       assert(children.isNotEmpty, 'children cannot be empty'),
       headerBuilder = null,
       footerBuilder = null,
       columnCount = children.elementAt(0).length,
       rowCount = children.length;

  /// {@template UnaTable.headerBuilder}
  /// Builder function for creating header cells.
  /// {@endtemplate}
  final UnaTableCell Function(BuildContext context, int column)? headerBuilder;

  /// {@template UnaTable.footerBuilder}
  /// Builder function for creating footer cells.
  /// {@endtemplate}
  final UnaTableCell Function(BuildContext context, int column)? footerBuilder;

  /// {@template UnaTable.header}
  /// Explicit list of header cells.
  /// {@endtemplate}
  final Iterable<UnaTableCell>? header;

  /// {@template UnaTable.footer}
  /// Explicit list of footer cells.
  /// {@endtemplate}
  final Iterable<UnaTableCell>? footer;

  /// {@template UnaTable.builder}
  /// Builder function for creating table cells on demand.
  /// {@endtemplate}
  final TableCellBuilder? builder;

  /// {@template UnaTable.columnCount}
  /// Number of columns in the table.
  /// {@endtemplate}
  final int columnCount;

  /// {@template UnaTable.rowCount}
  /// Number of rows in the table (excluding header and footer).
  /// {@endtemplate}
  final int rowCount;

  /// {@template UnaTable.children}
  /// Explicit 2D list of [UnaTableCell] widgets.
  /// {@endtemplate}
  final Iterable<Iterable<UnaTableCell>>? children;

  /// {@template UnaTable.columnBuilder}
  /// Builder for defining column properties.
  /// {@endtemplate}
  final TableSpanBuilder? columnBuilder;

  /// {@template UnaTable.rowBuilder}
  /// Builder for defining row properties.
  /// {@endtemplate}
  final TableSpanBuilder? rowBuilder;

  /// {@template UnaTable.rowSpanExtent}
  /// Function to define custom row span extents.
  /// {@endtemplate}
  final TableSpanExtent? Function(int row)? rowSpanExtent;

  /// {@template UnaTable.columnSpanExtent}
  /// Function to define custom column span extents.
  /// {@endtemplate}
  final TableSpanExtent? Function(int column)? columnSpanExtent;

  /// {@template UnaTable.rowSpanBackgroundDecoration}
  /// Function to define background decoration for rows.
  /// {@endtemplate}
  final TableSpanDecoration? Function(int row)? rowSpanBackgroundDecoration;

  /// {@template UnaTable.rowSpanForegroundDecoration}
  /// Function to define foreground decoration for rows.
  /// {@endtemplate}
  final TableSpanDecoration? Function(int row)? rowSpanForegroundDecoration;

  /// {@template UnaTable.rowSelected}
  /// Whether the row at an index is selected, shadcn's
  /// `data-state="selected"`: a selected row is filled with the theme's
  /// `rowSelectedColor`, under the pointer or not. The index counts the
  /// header row, as [rowSpanBackgroundDecoration]'s does. Not consulted for
  /// a row that [rowSpanBackgroundDecoration] decorates.
  /// {@endtemplate}
  final bool Function(int row)? rowSelected;

  /// {@template UnaTable.columnSpanBackgroundDecoration}
  /// Function to define background decoration for columns.
  /// {@endtemplate}
  final TableSpanDecoration? Function(int column)?
  columnSpanBackgroundDecoration;

  /// {@template UnaTable.columnSpanForegroundDecoration}
  /// Function to define foreground decoration for columns.
  /// {@endtemplate}
  final TableSpanDecoration? Function(int column)?
  columnSpanForegroundDecoration;

  /// {@template UnaTable.onHoveredRowIndex}
  /// Callback for when a row is hovered, providing the row index.
  /// {@endtemplate}
  final ValueChanged<int?>? onHoveredRowIndex;

  /// {@template UnaTable.verticalScrollController}
  /// Controller for vertical scrolling.
  /// {@endtemplate}
  final ScrollController? verticalScrollController;

  /// {@template UnaTable.horizontalScrollController}
  /// Controller for horizontal scrolling.
  /// {@endtemplate}
  final ScrollController? horizontalScrollController;

  /// {@template UnaTable.pinnedRowCount}
  /// Number of pinned rows at the top.
  /// {@endtemplate}
  final int? pinnedRowCount;

  /// {@template UnaTable.pinnedColumnCount}
  /// Number of pinned columns at the start.
  /// {@endtemplate}
  final int? pinnedColumnCount;

  /// {@template UnaTable.primary}
  /// Whether this is the primary scroll view.
  /// {@endtemplate}
  final bool? primary;

  /// {@template UnaTable.diagonalDragBehavior}
  /// Drag behavior when dragging diagonally.
  /// {@endtemplate}
  final DiagonalDragBehavior? diagonalDragBehavior;

  /// {@template UnaTable.dragStartBehavior}
  /// Determines when a drag formally starts.
  /// {@endtemplate}
  final DragStartBehavior? dragStartBehavior;

  /// {@template UnaTable.keyboardDismissBehavior}
  /// Configures how the keyboard is dismissed when a drag starts.
  /// {@endtemplate}
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// {@template UnaTable.verticalScrollPhysics}
  /// Physics for vertical scrolling.
  /// {@endtemplate}
  final ScrollPhysics? verticalScrollPhysics;

  /// {@template UnaTable.horizontalScrollPhysics}
  /// Physics for horizontal scrolling.
  /// {@endtemplate}
  final ScrollPhysics? horizontalScrollPhysics;

  /// {@template UnaTable.onRowTap}
  /// Callback for tap gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowTap;

  /// {@template UnaTable.onRowTapDown}
  /// Callback for tap down gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowTapDown;

  /// {@template UnaTable.onRowTapUp}
  /// Callback for tap up gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowTapUp;

  /// {@template UnaTable.onRowTapCancel}
  /// Callback for tap cancel gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowTapCancel;

  /// {@template UnaTable.onRowSecondaryTap}
  /// Callback for secondary tap gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowSecondaryTap;

  /// {@template UnaTable.onRowSecondaryTapDown}
  /// Callback for secondary tap down gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowSecondaryTapDown;

  /// {@template UnaTable.onRowSecondaryTapUp}
  /// Callback for secondary tap up gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowSecondaryTapUp;

  /// {@template UnaTable.onRowSecondaryTapCancel}
  /// Callback for secondary tap cancel gestures on a row.
  /// {@endtemplate}
  final void Function(int row)? onRowSecondaryTapCancel;

  /// {@template UnaTable.onColumnTap}
  /// Callback for tap gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnTap;

  /// {@template UnaTable.onColumnTapDown}
  /// Callback for tap down gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnTapDown;

  /// {@template UnaTable.onColumnTapUp}
  /// Callback for tap up gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnTapUp;

  /// {@template UnaTable.onColumnTapCancel}
  /// Callback for tap cancel gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnTapCancel;

  /// {@template UnaTable.onColumnSecondaryTap}
  /// Callback for secondary tap gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnSecondaryTap;

  /// {@template UnaTable.onColumnSecondaryTapDown}
  /// Callback for secondary tap down gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnSecondaryTapDown;

  /// {@template UnaTable.onColumnSecondaryTapUp}
  /// Callback for secondary tap up gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnSecondaryTapUp;

  /// {@template UnaTable.onColumnSecondaryTapCancel}
  /// Callback for secondary tap cancel gestures on a column.
  /// {@endtemplate}
  final void Function(int column)? onColumnSecondaryTapCancel;

  /// The kind of devices that are allowed to be recognized.
  ///
  /// If set to null, events from all device types will be recognized. Defaults
  /// to null.
  final Set<PointerDeviceKind>? supportedDevices;

  @override
  State<UnaTable> createState() => _TableState();
}

class _TableState extends State<UnaTable> {
  final hoveredRowIndex = ValueNotifier<int?>(null);

  /// This is a workaround to avoid rebuilding the same row when the pointer
  /// doesn't move, because when you call setState, the onExit callback is
  /// called, even if the pointer is still hovering, and the onEnter callback is
  /// called again, causing an infinite loop.
  Offset? previousPointerOffset;

  int get effectiveRowCount =>
      widget.rowCount +
      (widget.header != null || widget.headerBuilder != null ? 1 : 0) +
      (widget.footer != null || widget.footerBuilder != null ? 1 : 0);

  @override
  void initState() {
    super.initState();
    hoveredRowIndex.addListener(() {
      widget.onHoveredRowIndex?.call(hoveredRowIndex.value);
    });
  }

  @override
  void dispose() {
    hoveredRowIndex.dispose();
    super.dispose();
  }

  TableSpan _buildColumnSpan(int index) {
    final gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    final requestedColumnSpanExtent = widget.columnSpanExtent?.call(index);
    final effectiveColumnSpanExtent =
        requestedColumnSpanExtent ?? const FixedTableSpanExtent(100);

    return TableSpan(
      extent: effectiveColumnSpanExtent,
      backgroundDecoration: widget.columnSpanBackgroundDecoration?.call(index),
      foregroundDecoration: widget.columnSpanForegroundDecoration?.call(index),
      recognizerFactories: {
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(
                debugOwner: this,
                supportedDevices: widget.supportedDevices,
              ),
              (TapGestureRecognizer instance) {
                if (widget.onColumnTap != null) {
                  instance.onTap = () => widget.onColumnTap!(index);
                }
                if (widget.onColumnTapDown != null) {
                  instance.onTapDown = (d) => widget.onColumnTapDown!(index);
                }
                if (widget.onColumnTapUp != null) {
                  instance.onTapUp = (d) => widget.onColumnTapUp!(index);
                }
                if (widget.onColumnTapCancel != null) {
                  instance.onTapCancel = () => widget.onColumnTapCancel!(index);
                }
                if (widget.onColumnSecondaryTap != null) {
                  instance.onSecondaryTap = () =>
                      widget.onColumnSecondaryTap!(index);
                }
                if (widget.onColumnSecondaryTapDown != null) {
                  instance.onSecondaryTapDown = (d) =>
                      widget.onColumnSecondaryTapDown!(index);
                }
                if (widget.onColumnSecondaryTapUp != null) {
                  instance.onSecondaryTapUp = (d) =>
                      widget.onColumnSecondaryTapUp!(index);
                }
                if (widget.onColumnSecondaryTapCancel != null) {
                  instance.onSecondaryTapCancel = () =>
                      widget.onColumnSecondaryTapCancel!(index);
                }

                instance
                  ..gestureSettings = gestureSettings
                  ..supportedDevices = widget.supportedDevices;
              },
            ),
      },
      cursor: widget.onColumnTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
    );
  }

  /// The fill behind a row: selection first, then the footer's own fill,
  /// then the hover wash.
  ///
  /// The fallbacks are fractions *of* the muted colour — its alpha is
  /// multiplied, not replaced. A scheme whose `muted` is a 4% wash of the
  /// foreground used to come out as a 50% wash of it here, which is how a
  /// hovered row ended up nearly as dark as the text on it.
  static Color? _rowColor(
    TableTheme tableTheme,
    ColorScheme colorScheme, {
    required bool hovered,
    required bool selected,
    required bool isFooter,
  }) {
    final muted = colorScheme.muted;
    final half = muted.withValues(alpha: muted.a * .5);
    if (selected) return tableTheme.rowSelectedColor ?? muted;
    if (isFooter) {
      return hovered
          ? tableTheme.footerHoverColor ?? muted
          : tableTheme.footerColor ?? half;
    }
    return hovered ? tableTheme.rowHoverColor ?? half : null;
  }

  TableSpan _buildRowSpan(int index, int effectiveRowCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tableTheme = theme.tableTheme;
    final gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    final isLast = index == effectiveRowCount - 1;
    final isFooter =
        isLast && (widget.footer != null || widget.footerBuilder != null);

    final requestedRowSpanExtent = widget.rowSpanExtent?.call(index);
    final effectiveRowSpanExtent =
        requestedRowSpanExtent ?? const FixedTableSpanExtent(48);

    return TableSpan(
      backgroundDecoration:
          widget.rowSpanBackgroundDecoration?.call(index) ??
          TableSpanDecoration(
            color: _rowColor(
              tableTheme,
              colorScheme,
              hovered: hoveredRowIndex.value == index,
              selected: widget.rowSelected?.call(index) ?? false,
              isFooter: isFooter,
            ),
            border: TableSpanBorder(
              trailing: isLast
                  ? BorderSide.none
                  : BorderSide(color: colorScheme.border),
            ),
          ),
      foregroundDecoration: widget.rowSpanForegroundDecoration?.call(index),
      extent: effectiveRowSpanExtent,
      onEnter: (p) {
        previousPointerOffset = p.position;
        hoveredRowIndex.value = index;
      },
      onExit: (p) {
        if (!mounted) return;
        if (previousPointerOffset == p.position) return;
        hoveredRowIndex.value = null;
      },
      recognizerFactories: {
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(
                debugOwner: this,
                supportedDevices: widget.supportedDevices,
              ),
              (TapGestureRecognizer instance) {
                if (widget.onRowTap != null) {
                  instance.onTap = () => widget.onRowTap!(index);
                }
                if (widget.onRowTapDown != null) {
                  instance.onTapDown = (d) => widget.onRowTapDown!(index);
                }
                if (widget.onRowTapUp != null) {
                  instance.onTapUp = (d) => widget.onRowTapUp!(index);
                }
                if (widget.onRowTapCancel != null) {
                  instance.onTapCancel = () => widget.onRowTapCancel!(index);
                }
                if (widget.onRowSecondaryTap != null) {
                  instance.onSecondaryTap = () =>
                      widget.onRowSecondaryTap!(index);
                }
                if (widget.onRowSecondaryTapDown != null) {
                  instance.onSecondaryTapDown = (d) =>
                      widget.onRowSecondaryTapDown!(index);
                }
                if (widget.onRowSecondaryTapUp != null) {
                  instance.onSecondaryTapUp = (d) =>
                      widget.onRowSecondaryTapUp!(index);
                }
                if (widget.onRowSecondaryTapCancel != null) {
                  instance.onSecondaryTapCancel = () =>
                      widget.onRowSecondaryTapCancel!(index);
                }

                instance
                  ..gestureSettings = gestureSettings
                  ..supportedDevices = widget.supportedDevices;
              },
            ),
      },
      cursor: widget.onRowTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final customRowBuilder = widget.rowBuilder ?? theme.tableTheme.rowBuilder;

    final effectiveColumnBuilder =
        widget.columnBuilder ??
        theme.tableTheme.columnBuilder ??
        _buildColumnSpan;

    final effectivePinnedRowCount = widget.pinnedRowCount ?? 0;
    final effectivePinnedColumnCount = widget.pinnedColumnCount ?? 0;
    final effectivePrimary = widget.primary;

    final effectiveDiagonalDragBehavior =
        widget.diagonalDragBehavior ??
        theme.tableTheme.diagonalDragBehavior ??
        DiagonalDragBehavior.none;

    final effectiveDragStartBehavior =
        widget.dragStartBehavior ??
        theme.tableTheme.dragStartBehavior ??
        DragStartBehavior.start;

    final effectiveKeyboardDismissBehavior =
        widget.keyboardDismissBehavior ??
        theme.tableTheme.keyboardDismissBehavior ??
        ScrollViewKeyboardDismissBehavior.manual;

    final textDirection = Directionality.of(context);

    // Materialised once per build rather than once per hover tick. The
    // ValueListenableBuilder below re-runs on every pointer move that crosses
    // a row boundary, and this allocates one List per row plus the outer list
    // — pathological on a large table. Only the row-span decoration actually
    // depends on the hovered index.
    final cells = widget.children == null
        ? null
        : <List<UnaTableCell>>[
            if (widget.header != null) widget.header!.toList(),
            ...widget.children!.map((row) => row.toList()),
            if (widget.footer != null) widget.footer!.toList(),
          ];

    return ValueListenableBuilder(
      valueListenable: hoveredRowIndex,
      builder: (context, value, child) {
        // A new closure for every hovered row, on purpose: the table's
        // delegate only rebuilds its row spans — which carry the hover
        // wash — when the row builder it is handed differs. Built once per
        // `build` instead, a `UnaTable.list` never repainted its
        // hover at all.
        final effectiveRowBuilder =
            customRowBuilder ?? (i) => _buildRowSpan(i, effectiveRowCount);
        if (cells != null) {
          return TableView.list(
            primary: effectivePrimary,
            diagonalDragBehavior: effectiveDiagonalDragBehavior,
            dragStartBehavior: effectiveDragStartBehavior,
            keyboardDismissBehavior: effectiveKeyboardDismissBehavior,
            columnBuilder: effectiveColumnBuilder,
            rowBuilder: effectiveRowBuilder,
            verticalDetails: ScrollableDetails.vertical(
              controller: widget.verticalScrollController,
              physics: widget.verticalScrollPhysics,
            ),
            horizontalDetails: ScrollableDetails.horizontal(
              controller: widget.horizontalScrollController,
              physics: widget.horizontalScrollPhysics,
              reverse: textDirection == TextDirection.rtl,
            ),
            cells: cells,
            pinnedRowCount: effectivePinnedRowCount,
            pinnedColumnCount: effectivePinnedColumnCount,
          );
        }
        return TableView.builder(
          primary: effectivePrimary,
          diagonalDragBehavior: effectiveDiagonalDragBehavior,
          dragStartBehavior: effectiveDragStartBehavior,
          keyboardDismissBehavior: effectiveKeyboardDismissBehavior,
          verticalDetails: ScrollableDetails.vertical(
            controller: widget.verticalScrollController,
            physics: widget.verticalScrollPhysics,
          ),
          horizontalDetails: ScrollableDetails.horizontal(
            controller: widget.horizontalScrollController,
            physics: widget.horizontalScrollPhysics,
            reverse: textDirection == TextDirection.rtl,
          ),
          cellBuilder: (context, index) {
            if (widget.headerBuilder != null && index.row == 0) {
              return widget.headerBuilder!(context, index.column);
            }
            if (widget.footerBuilder != null &&
                index.row == effectiveRowCount - 1) {
              return widget.footerBuilder!(context, index.column);
            }

            final realVicinity = TableVicinity(
              row: widget.headerBuilder != null ? index.row - 1 : index.row,
              column: index.column,
            );

            return widget.builder!(context, realVicinity);
          },
          columnCount: widget.columnCount,
          columnBuilder: effectiveColumnBuilder,
          rowCount: effectiveRowCount,
          rowBuilder: effectiveRowBuilder,
          pinnedRowCount: effectivePinnedRowCount,
          pinnedColumnCount: effectivePinnedColumnCount,
        );
      },
    );
  }
}
