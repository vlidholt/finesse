import 'dart:math' as math;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/checkbox.dart';
import 'package:finesse/src/components/empty.dart';
import 'package:finesse/src/components/pagination.dart';
import 'package:finesse/src/components/skeleton.dart';
import 'package:finesse/src/components/table.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

/// Width of the leading checkbox column in a selectable [DataTable].
///
/// Wide enough for the default 16px cell inset plus a 16px checkbox.
const _kSelectionColumnExtent = FixedTableSpanExtent(56);

/// Matches the table's default horizontal inset on the leading edge.
const _kSelectionCellPadding = EdgeInsetsDirectional.only(start: 16, end: 8);

/// Matches the table's default horizontal inset on the trailing edge.
const _kTrailingCellPadding = EdgeInsetsDirectional.only(start: 8, end: 16);

/// Fills the viewport after the preceding columns, leaving a fixed number
/// of pixels for trailing fixed-width columns.
class _RemainingMinusTrailingFixedExtent extends TableSpanExtent {
  const _RemainingMinusTrailingFixedExtent(this.trailingFixed);

  final double trailingFixed;

  @override
  double calculateExtent(SpanExtentDelegate delegate) {
    return math.max(
      0,
      delegate.viewportExtent - delegate.precedingExtent - trailingFixed,
    );
  }
}

/// The direction a [DataTable] is sorted in.
enum SortDirection {
  /// Smallest first, in the order the column's `compare` gives.
  ascending,

  /// Largest first, the reverse of [ascending].
  descending;

  /// The opposite direction.
  SortDirection get flipped => this == ascending ? descending : ascending;
}

/// A column definition for a [DataTable].
@immutable
class DataTableColumn<T> {
  /// Creates a column definition.
  const DataTableColumn({
    required this.id,
    required this.header,
    required this.cellBuilder,
    this.compare,
    bool? sortable,
    this.extent,
    this.alignment,
    this.headerAlignment,
    this.visible = true,
  }) : _sortable = sortable;

  /// A stable identifier, used for sorting and column visibility.
  final String id;

  /// The header label.
  final String header;

  /// Builds the cell content for a row.
  final Widget Function(BuildContext context, T row) cellBuilder;

  /// Compares two rows by this column.
  ///
  /// With a controller that holds its rows, a column is sortable when this
  /// is non-null. A [DataTableController.remote] sorts at the source and
  /// never calls it: there, pass `sortable: true`.
  final Comparator<T>? compare;

  final bool? _sortable;

  /// The width of the column.
  ///
  /// When null, this column flexes to fill the viewport minus any trailing
  /// [FixedTableSpanExtent] columns after it. If there is no trailing fixed
  /// column, [FinesseTable]'s default of 100 logical pixels applies.
  final TableSpanExtent? extent;

  /// The alignment of cell content.
  final Alignment? alignment;

  /// The alignment of the header, defaults to [alignment].
  final Alignment? headerAlignment;

  /// Whether the column is shown.
  final bool visible;

  /// Whether a tap on the header sorts by this column. Defaults to whether
  /// [compare] is set; the constructor's `sortable` overrides that, for a
  /// column whose rows are sorted where they come from.
  bool get sortable => _sortable ?? compare != null;
}

/// What a [DataTableController.remote] asks its source for: one page, in
/// the current order, narrowed by the current query.
@immutable
class DataTablePageRequest {
  /// Creates a request for [page].
  const DataTablePageRequest({
    required this.page,
    required this.pageSize,
    this.sortColumnId,
    this.sortDirection = SortDirection.ascending,
    this.query,
  });

  /// The page wanted, 1-based.
  final int page;

  /// How many rows a page holds.
  final int pageSize;

  /// The id of the column to sort by, or null for the source's own order.
  final String? sortColumnId;

  /// The direction of the sort. Meaningless while [sortColumnId] is null.
  final SortDirection sortDirection;

  /// Whatever the app set as [DataTableController.query]: a search string,
  /// a filter object. Null for none.
  final Object? query;

  /// The index of the first row of the page among all rows.
  int get offset => (page - 1) * pageSize;

  @override
  bool operator ==(Object other) =>
      other is DataTablePageRequest &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.sortColumnId == sortColumnId &&
      other.sortDirection == sortDirection &&
      other.query == query;

  @override
  int get hashCode =>
      Object.hash(page, pageSize, sortColumnId, sortDirection, query);

  @override
  String toString() =>
      'DataTablePageRequest(page: $page, pageSize: $pageSize, '
      'sortColumnId: $sortColumnId, sortDirection: ${sortDirection.name}, '
      'query: $query)';
}

/// What the source of a [DataTableController.remote] answers a
/// [DataTablePageRequest] with: the rows of the page and, when it knows,
/// how many rows there are in all.
@immutable
class DataTablePage<T> {
  /// Creates the answer to a request.
  const DataTablePage({required this.rows, this.rowCount});

  /// The rows of the page, in the order they are shown. At most a page
  /// size of them; fewer only on the last page.
  final List<T> rows;

  /// The number of rows the source has in all, with the request's query
  /// applied. It becomes the controller's [DataTableController.rowCount];
  /// null leaves that as it is.
  final int? rowCount;
}

/// Holds the sort, filter, paging and selection state of a [DataTable].
///
/// The unnamed constructor owns the source rows and derives [visibleRows]
/// from them, so sorting or filtering never mutates what the caller passed
/// in. [DataTableController.remote] holds one page at a time and asks a
/// source for each: the sort, the page and the [query] are reported to it,
/// not applied here.
class DataTableController<T> extends ChangeNotifier {
  /// Creates a controller over [rows].
  ///
  /// [sortColumnId] and [sortDirection] set the initial sort, and [filter] the
  /// initial filter.
  DataTableController({
    List<T> rows = const [],
    this.pageSize,
    String? sortColumnId,
    SortDirection sortDirection = SortDirection.ascending,
    bool Function(T row)? filter,
  }) : _rows = List.of(rows),
       _sortColumnId = sortColumnId,
       _sortDirection = sortDirection,
       _filter = filter,
       _onPageRequested = null;

  /// Creates a controller for rows that live somewhere else: a server, a
  /// database, a list too long to hold.
  ///
  /// [onPageRequested] is called for the first page when a [DataTable] (or
  /// any listener) attaches, and again whenever the [page], the sort or the
  /// [query] changes. It answers with the rows of that page; while it is
  /// pending [isLoading] is true and the table shows skeleton rows. An
  /// answer that arrives after a newer request has been made is dropped,
  /// row count and all. When it throws, [error] holds what it threw and
  /// [reload] asks again.
  ///
  /// [rowCount] is the number of rows the source has in all, which is what
  /// gives the pager its last page. A source that reports a total with each
  /// page hands it back in [DataTablePage.rowCount]:
  ///
  /// ```dart
  /// final controller = DataTableController<Order>.remote(
  ///   pageSize: 20,
  ///   onPageRequested: (request) async {
  ///     final result = await api.orders(
  ///       offset: request.offset,
  ///       limit: request.pageSize,
  ///       orderBy: request.sortColumnId,
  ///       descending: request.sortDirection == SortDirection.descending,
  ///       search: request.query as String?,
  ///     );
  ///     return DataTablePage(rows: result.rows, rowCount: result.total);
  ///   },
  /// );
  /// ```
  ///
  /// While it is null the pager offers a next page for as long as the last
  /// one came back full.
  ///
  /// A column is sortable with `DataTableColumn(sortable: true)`; no
  /// comparator is called. Selection is by key, so it survives a change of
  /// page.
  DataTableController.remote({
    required int this.pageSize,
    required Future<DataTablePage<T>> Function(DataTablePageRequest request)
    onPageRequested,
    int? rowCount,
    String? sortColumnId,
    SortDirection sortDirection = SortDirection.ascending,
    Object? query,
  }) : assert(pageSize > 0, 'A remote table needs a page size above 0.'),
       _rows = const [],
       _sortColumnId = sortColumnId,
       _sortDirection = sortDirection,
       _filter = null,
       _onPageRequested = onPageRequested,
       _rowCount = rowCount,
       _query = query,
       // Nothing is shown before the first answer.
       _loading = true;

  /// How many rows to show per page. Null disables paging.
  final int? pageSize;

  final Future<DataTablePage<T>> Function(DataTablePageRequest request)?
  _onPageRequested;

  /// Whether the rows come from a source, a page at a time: the controller
  /// was made with [DataTableController.remote].
  bool get isRemote => _onPageRequested != null;

  int? _rowCount;
  Object? _query;
  bool _loading = false;
  Object? _error;

  /// Counts requests, so that an answer can tell whether it is still wanted.
  int _request = 0;
  bool _started = false;
  bool _disposed = false;

  /// The furthest page known to be there while the row count is not.
  int _reachablePage = 1;

  /// Whether a page has been asked for and has not arrived. Always false
  /// for a controller that holds its rows.
  bool get isLoading => _loading;

  /// What the source threw for the current page, or null. Cleared by the
  /// next request.
  Object? get error => _error;

  /// The number of rows the source has in all, when known. Null for a
  /// controller that holds its rows; see [totalRowCount].
  ///
  /// Set from each [DataTablePage.rowCount] that is not null, and
  /// settable for a total learnt some other way. A count that leaves the
  /// current page past the end goes to the last page.
  int? get rowCount => _rowCount;

  set rowCount(int? value) {
    assert(isRemote, 'rowCount belongs to a DataTableController.remote.');
    if (_rowCount == value) return;
    _rowCount = value;
    if (_page > pageCount) {
      // The page being shown is past the new end.
      _page = pageCount;
      _load();
      return;
    }
    _notify();
  }

  /// What narrows the rows of a remote table: a search string, a filter
  /// object, whatever the source understands. Handed to it in every
  /// [DataTablePageRequest]. Setting it goes back to the first page and
  /// asks again.
  Object? get query => _query;

  set query(Object? value) {
    assert(isRemote, 'query belongs to a DataTableController.remote.');
    if (_query == value) return;
    _query = value;
    _page = 1;
    _reachablePage = 1;
    _load();
  }

  /// Asks the source for the current page again: after an [error], or
  /// because the data behind it changed. Does nothing for a controller that
  /// holds its rows.
  void reload() {
    if (isRemote) _load();
  }

  /// The request the current state amounts to.
  DataTablePageRequest get _currentRequest => DataTablePageRequest(
    page: _page,
    pageSize: pageSize!,
    sortColumnId: _sortColumnId,
    sortDirection: _sortDirection,
    query: _query,
  );

  void _load({bool notify = true}) {
    _started = true;
    final request = ++_request;
    _loading = true;
    _error = null;
    if (notify) _notify();
    Future<DataTablePage<T>>.sync(
      () => _onPageRequested!(_currentRequest),
    ).then(
      (answer) {
        if (request != _request || _disposed) return;
        final rows = answer.rows;
        _rows = List.of(rows);
        _loading = false;
        // A full page may have another behind it; a short one is the last.
        _reachablePage = rows.length >= pageSize! ? _page + 1 : _page;
        final count = answer.rowCount;
        if (count != null) {
          _rowCount = count;
          if (_page > pageCount) {
            // The rows ran out before this page: show the last one.
            _page = pageCount;
            _load();
            return;
          }
        }
        _notify();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (request != _request || _disposed) return;
        _rows = const [];
        _loading = false;
        _error = error;
        _notify();
      },
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    // The first page is asked for when somebody is there to show it. Not
    // announced: whoever just attached reads the state as it is.
    if (isRemote && !_started) _load(notify: false);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<T> _rows;
  String? _sortColumnId;
  SortDirection _sortDirection;
  bool Function(T row)? _filter;
  int _page = 1;
  final Set<Object> _selectedKeys = {};

  /// Set by [DataTable] so the controller can resolve a column id to its
  /// comparator without the caller having to hand it the columns twice.
  List<DataTableColumn<T>> _columns = const [];

  /// The unfiltered, unsorted source rows. For a remote controller, the
  /// rows of the page that was last loaded.
  List<T> get rows => List.unmodifiable(_rows);

  set rows(List<T> value) {
    assert(!isRemote, 'A remote controller gets its rows from its source.');
    _rows = List.of(value);
    _clampPage();
    notifyListeners();
  }

  /// The id of the column the rows are sorted by, or null when unsorted.
  String? get sortColumnId => _sortColumnId;

  /// The direction of the current sort.
  SortDirection get sortDirection => _sortDirection;

  /// Returns true for the rows to keep. Null keeps every row.
  ///
  /// Setting it goes back to the first page.
  bool Function(T row)? get filter => _filter;

  set filter(bool Function(T row)? value) {
    assert(
      !isRemote,
      'A remote controller cannot test rows it does not hold: set query, '
      'which is handed to the source.',
    );
    _filter = value;
    // A new filter changes the row count, so a deep page may no longer exist.
    _page = 1;
    notifyListeners();
  }

  /// The current page, 1-based.
  int get page => _page;

  set page(int value) {
    final clamped = value.clamp(1, pageCount);
    if (_page == clamped) return;
    _page = clamped;
    if (isRemote) {
      _load();
      return;
    }
    notifyListeners();
  }

  /// The number of rows after filtering, on every page together. For a
  /// remote controller this is [rowCount], or — while that is unknown — the
  /// rows seen so far.
  int get totalRowCount {
    if (!isRemote) {
      return _filter == null ? _rows.length : _rows.where(_filter!).length;
    }
    return _rowCount ?? (_page - 1) * pageSize! + _rows.length;
  }

  /// The rows left after filtering and sorting, before paging. For a remote
  /// controller, the rows of the current page as the source returned them.
  List<T> get filteredRows {
    if (isRemote) return List<T>.of(_rows);
    final filtered = _filter == null
        ? List<T>.of(_rows)
        : _rows.where(_filter!).toList();

    final column = _columnById(_sortColumnId);
    if (column?.compare != null) {
      filtered.sort(
        _sortDirection == SortDirection.ascending
            ? column!.compare!
            : (a, b) => column!.compare!(b, a),
      );
    }
    return filtered;
  }

  /// The rows actually rendered: [filteredRows] narrowed to the current page.
  List<T> get visibleRows {
    if (isRemote) {
      return _loading || _error != null ? const [] : List.unmodifiable(_rows);
    }
    final filtered = filteredRows;
    if (pageSize == null) return filtered;
    final start = (_page - 1) * pageSize!;
    if (start >= filtered.length) return const [];
    return filtered.sublist(
      start,
      (start + pageSize!).clamp(0, filtered.length),
    );
  }

  /// The number of pages after filtering. It is at least 1, and 1 when paging
  /// is off.
  int get pageCount {
    if (isRemote) {
      final count = _rowCount;
      // Unknown: as far as has been reached, or the page being shown.
      if (count == null) return math.max(_page, _reachablePage);
      return count == 0 ? 1 : (count / pageSize!).ceil();
    }
    if (pageSize == null) return 1;
    final total = _filter == null ? _rows.length : _rows.where(_filter!).length;
    if (total == 0) return 1;
    return (total / pageSize!).ceil();
  }

  DataTableColumn<T>? _columnById(String? id) {
    if (id == null) return null;
    for (final column in _columns) {
      if (column.id == id) return column;
    }
    return null;
  }

  void _clampPage() {
    final clamped = _page.clamp(1, pageCount);
    if (clamped != _page) _page = clamped;
  }

  /// Sorts by [columnId], flipping the direction if it is already the sort
  /// column, and clearing the sort when it flips back past descending.
  void sortBy(String columnId) {
    if (_sortColumnId == columnId) {
      if (_sortDirection == SortDirection.ascending) {
        _sortDirection = SortDirection.descending;
      } else {
        // Third click clears the sort, matching the shadcn data-table demo.
        _sortColumnId = null;
        _sortDirection = SortDirection.ascending;
      }
    } else {
      _sortColumnId = columnId;
      _sortDirection = SortDirection.ascending;
    }
    if (isRemote) {
      // Another order is another first page.
      _page = 1;
      _load();
      return;
    }
    notifyListeners();
  }

  // --- selection -----------------------------------------------------------

  /// The keys of the selected rows.
  ///
  /// Keys rather than rows so that selection survives a re-sort or a new page
  /// of data without depending on `==` over the row objects.
  Set<Object> get selectedKeys => Set.unmodifiable(_selectedKeys);

  /// Whether the row with [key] is selected.
  bool isSelected(Object key) => _selectedKeys.contains(key);

  /// Selects or deselects the row with [key].
  void setSelected(Object key, {required bool selected}) {
    final changed = selected
        ? _selectedKeys.add(key)
        : _selectedKeys.remove(key);
    if (changed) notifyListeners();
  }

  /// Flips the selection of the row with [key].
  void toggleSelected(Object key) =>
      setSelected(key, selected: !_selectedKeys.contains(key));

  /// Adds every key in [keys] to the selection.
  void selectAll(Iterable<Object> keys) {
    final before = _selectedKeys.length;
    _selectedKeys.addAll(keys);
    if (_selectedKeys.length != before) notifyListeners();
  }

  /// Deselects every row.
  void clearSelection() {
    if (_selectedKeys.isEmpty) return;
    _selectedKeys.clear();
    notifyListeners();
  }
}

/// {@template DataTable}
/// A sortable, selectable, paginated table.
///
/// Mirrors shadcn/ui's Data Table, which is a composition rather than a single
/// primitive: this wraps [FinesseTable] for presentation and adds a
/// [DataTableController] for sort, filter, page and selection state.
///
/// ```dart
/// DataTable<User>(
///   controller: controller,
///   keyOf: (user) => user.id,
///   columns: [
///     DataTableColumn(
///       id: 'name',
///       header: 'Name',
///       cellBuilder: (context, user) => Text(user.name),
///       compare: (a, b) => a.name.compareTo(b.name),
///     ),
///   ],
/// )
/// ```
///
/// [FinesseTable] is built on `TableView`, a two-dimensional scroll view with
/// no shrink-wrap, so this needs a bounded height — give it one via [height],
/// an [Expanded], or a [SizedBox].
/// {@endtemplate}
class DataTable<T> extends StatefulWidget {
  /// {@macro DataTable}
  const DataTable({
    super.key,
    required this.columns,
    required this.controller,
    this.keyOf,
    this.selectable = false,
    this.onRowTap,
    this.height,
    this.rowHeight,
    this.headerHeight,
    this.emptyBuilder,
    this.errorBuilder,
    this.showPagination,
    this.paginationBuilder,
    this.showSelectionCount = true,
  }) : assert(
         !selectable || keyOf != null,
         'A selectable DataTable needs keyOf to identify its rows',
       );

  /// The columns to render, in order. Columns with `visible: false` are
  /// skipped.
  final List<DataTableColumn<T>> columns;

  /// The state of the table.
  final DataTableController<T> controller;

  /// Returns a stable identity for a row, used for selection.
  final Object Function(T row)? keyOf;

  /// Whether to show a leading checkbox column.
  final bool selectable;

  /// Called when a row is tapped.
  final void Function(T row)? onRowTap;

  /// The height of the scrollable table area.
  ///
  /// Required unless an ancestor already bounds the height — see the class
  /// docs.
  final double? height;

  /// The height of each body row. Defaults to the table theme's cell height,
  /// then 48.
  final double? rowHeight;

  /// The height of the header row. Defaults like [rowHeight].
  final double? headerHeight;

  /// Builds the widget shown when there are no rows after filtering.
  final WidgetBuilder? emptyBuilder;

  /// Builds what is shown in place of the rows when a
  /// [DataTableController.remote] could not load a page: `error` is what
  /// the source threw and `retry` asks for the page again. Defaults to a
  /// short message and a retry button.
  final Widget Function(
    BuildContext context,
    Object error,
    VoidCallback retry,
  )?
  errorBuilder;

  /// Whether to show the pagination bar. Defaults to true when the controller
  /// has a `pageSize`.
  final bool? showPagination;

  /// Replaces the default pagination bar.
  final Widget Function(BuildContext context, DataTableController<T>)?
  paginationBuilder;

  /// Whether the footer reports "n of m row(s) selected".
  final bool showSelectionCount;

  @override
  State<DataTable<T>> createState() => _DataTableState<T>();
}

class _DataTableState<T> extends State<DataTable<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller
      .._columns = widget.columns
      ..addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(DataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    widget.controller._columns = widget.columns;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    // A source may answer, or set the row count, while the tree is being
    // built: this table then rebuilds after the frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }
    setState(() {});
  }

  /// How many skeleton rows stand in for a page that is on its way: a full
  /// page, or what is left of the rows on the last one.
  int get _placeholderRowCount {
    final controller = widget.controller;
    final pageSize = controller.pageSize ?? 1;
    final total = controller.rowCount;
    if (total == null) return pageSize;
    final left = total - (controller.page - 1) * pageSize;
    return left.clamp(1, pageSize);
  }

  // Bars of different lengths, the same on every build: a column of equal
  // ones reads as a table that has loaded and is empty.
  static const _placeholderWidths = [.72, .48, .86, .6, .4, .78];

  Widget _buildPlaceholder(int row, int column, Alignment? alignment) {
    final factor =
        _placeholderWidths[(row * 2 + column * 3) % _placeholderWidths.length];
    return ExcludeSemantics(
      child: FractionallySizedBox(
        widthFactor: factor,
        alignment: alignment ?? AlignmentDirectional.centerStart,
        child: const Skeleton(height: 14),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final controller = widget.controller;
    final builder = widget.errorBuilder;
    if (builder != null) return builder(context, error, controller.reload);
    final strings = FinesseLocalizations.of(context);
    return Center(
      child: Empty(
        title: Text(strings.dataTable.loadFailed),
        actions: [
          Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.sm,
            onPressed: controller.reload,
            child: Text(strings.dataTable.retry),
          ),
        ],
      ),
    );
  }

  List<DataTableColumn<T>> get _visibleColumns =>
      widget.columns.where((c) => c.visible).toList();

  TableSpanExtent? _resolveDataColumnExtent(
    List<DataTableColumn<T>> columns,
    int dataColumnIndex,
  ) {
    final column = columns[dataColumnIndex];
    if (column.extent != null) return column.extent;

    final flexIndex = _flexColumnIndex(columns);
    if (flexIndex != dataColumnIndex) return null;

    final trailingFixed = _sumTrailingFixedExtents(columns, dataColumnIndex);
    if (trailingFixed <= 0) return null;

    return _RemainingMinusTrailingFixedExtent(trailingFixed);
  }

  /// The rightmost column without a [DataTableColumn.extent] that sits
  /// before the trailing fixed-width suffix.
  int? _flexColumnIndex(List<DataTableColumn<T>> columns) {
    final trailingStart = _trailingFixedStartIndex(columns);
    for (var i = trailingStart - 1; i >= 0; i--) {
      if (columns[i].extent == null) return i;
    }
    return null;
  }

  int _trailingFixedStartIndex(List<DataTableColumn<T>> columns) {
    var start = columns.length;
    while (start > 0 && columns[start - 1].extent is FixedTableSpanExtent) {
      start--;
    }
    return start;
  }

  double _sumTrailingFixedExtents(
    List<DataTableColumn<T>> columns,
    int fromIndex,
  ) {
    var sum = 0.0;
    for (var i = fromIndex + 1; i < columns.length; i++) {
      final extent = columns[i].extent;
      if (extent is! FixedTableSpanExtent) break;
      sum += extent.pixels;
    }
    return sum;
  }

  Widget _buildHeaderCell(
    BuildContext context,
    DataTableColumn<T> column,
  ) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final isSorted = controller.sortColumnId == column.id;

    final label = Text(column.header, overflow: TextOverflow.ellipsis);
    if (!column.sortable) return label;

    final strings = FinesseLocalizations.of(context).dataTable;
    final ascending = controller.sortDirection == SortDirection.ascending;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Flexible so a narrow column ellipsizes the label instead of
        // overflowing past the sort indicator.
        Flexible(child: label),
        if (isSorted) ...[
          const SizedBox(width: 4),
          PhosphorIcon(
            ascending
                ? PhosphorIconsRegular.arrowDown
                : PhosphorIconsRegular.arrowUp,
            size: 14,
            color: theme.colorScheme.foreground,
          ),
        ],
      ],
    );

    // A button, in the focus order, that says how the table is sorted by
    // it. It looks as it did: the ring is all it adds, and only for the
    // keyboard.
    return Pressable(
      onPressed: () => controller.sortBy(column.id),
      semanticValue: isSorted
          ? (ascending ? strings.sortedAscending : strings.sortedDescending)
          : null,
      pressScale: 1,
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: theme.radii.sm,
        child: content,
      ),
    );
  }

  Widget _buildSelectAllCheckbox(List<T> visibleRows) {
    final controller = widget.controller;
    final keys = visibleRows.map(widget.keyOf!).toList();
    final allSelected = keys.isNotEmpty && keys.every(controller.isSelected);

    return Checkbox(
      value: allSelected,
      // Nothing to select while a page is on its way.
      enabled: !controller.isLoading,
      onChanged: (value) {
        if (value) {
          controller.selectAll(keys);
        } else {
          for (final key in keys) {
            controller.setSelected(key, selected: false);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final controller = widget.controller;
    final columns = _visibleColumns;
    final rows = controller.visibleRows;
    final loading = controller.isLoading;
    final error = controller.error;

    final selectionOffset = widget.selectable ? 1 : 0;
    final columnCount = columns.length + selectionOffset;

    final effectiveShowPagination =
        widget.showPagination ?? (controller.pageSize != null);

    Widget table;
    if (error != null) {
      table = _buildError(context, error);
    } else if (rows.isEmpty && !loading) {
      table =
          widget.emptyBuilder?.call(context) ?? const Center(child: Empty());
    } else {
      table = FinesseTable(
        columnCount: columnCount,
        rowCount: loading ? _placeholderRowCount : rows.length,
        pinnedRowCount: 1,
        columnSpanExtent: (index) {
          if (widget.selectable && index == 0) {
            return _kSelectionColumnExtent;
          }
          return _resolveDataColumnExtent(columns, index - selectionOffset);
        },
        header: (context, column) {
          if (widget.selectable && column == 0) {
            return FinesseTableCell.header(
              height: widget.headerHeight,
              padding: _kSelectionCellPadding,
              child: _buildSelectAllCheckbox(rows),
            );
          }
          final definition = columns[column - selectionOffset];
          final dataColumnIndex = column - selectionOffset;
          final isLastColumn = dataColumnIndex == columns.length - 1;
          return FinesseTableCell.header(
            alignment: definition.headerAlignment ?? definition.alignment,
            height: widget.headerHeight,
            padding: isLastColumn ? _kTrailingCellPadding : null,
            child: _buildHeaderCell(context, definition),
          );
        },
        builder: (context, vicinity) {
          if (loading) {
            final selection = widget.selectable && vicinity.column == 0;
            final dataColumnIndex = vicinity.column - selectionOffset;
            return FinesseTableCell(
              alignment: selection ? null : columns[dataColumnIndex].alignment,
              height: widget.rowHeight,
              padding: selection
                  ? _kSelectionCellPadding
                  : dataColumnIndex == columns.length - 1
                  ? _kTrailingCellPadding
                  : null,
              child: selection
                  ? const ExcludeSemantics(
                      child: Skeleton(width: 16, height: 16),
                    )
                  : _buildPlaceholder(
                      vicinity.row,
                      dataColumnIndex,
                      columns[dataColumnIndex].alignment,
                    ),
            );
          }
          final row = rows[vicinity.row];
          if (widget.selectable && vicinity.column == 0) {
            final key = widget.keyOf!(row);
            return FinesseTableCell(
              height: widget.rowHeight,
              padding: _kSelectionCellPadding,
              child: Checkbox(
                value: controller.isSelected(key),
                onChanged: (_) => controller.toggleSelected(key),
              ),
            );
          }
          final definition = columns[vicinity.column - selectionOffset];
          final dataColumnIndex = vicinity.column - selectionOffset;
          final isLastColumn = dataColumnIndex == columns.length - 1;
          return FinesseTableCell(
            alignment: definition.alignment,
            height: widget.rowHeight,
            padding: isLastColumn ? _kTrailingCellPadding : null,
            child: definition.cellBuilder(context, row),
          );
        },
        // A selected row is filled, as shadcn's `data-state="selected"` is.
        rowSelected: widget.selectable && !loading
            ? (index) =>
                  index > 0 &&
                  index <= rows.length &&
                  controller.isSelected(widget.keyOf!(rows[index - 1]))
            : null,
        onRowTap: widget.onRowTap == null || loading
            ? null
            : (index) {
                // Row 0 is the pinned header, so data rows are offset by one.
                if (index == 0 || index > rows.length) return;
                widget.onRowTap!(rows[index - 1]);
              },
      );
    }

    if (loading) {
      // One announcement for the page, in place of a bar per cell.
      table = Semantics(
        label: FinesseLocalizations.of(context).dataTable.loading,
        liveRegion: true,
        child: table,
      );
    }

    if (widget.height != null) {
      table = SizedBox(height: widget.height, child: table);
    }

    final footerChildren = <Widget>[];
    if (widget.selectable && widget.showSelectionCount) {
      footerChildren.add(
        Text(
          FinesseLocalizations.of(context).dataTable.selectedCount(
            selected: controller.selectedKeys.length,
            total: controller.totalRowCount,
          ),
          style: theme.textTheme.muted,
        ),
      );
    }
    if (effectiveShowPagination) {
      footerChildren
        ..add(const Spacer())
        ..add(
          widget.paginationBuilder?.call(context, controller) ??
              PaginationCompact(
                page: controller.page,
                pageCount: controller.pageCount,
                onPageChanged: (page) => controller.page = page,
              ),
        );
    }

    if (footerChildren.isEmpty) return table;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.height != null) table else Expanded(child: table),
        const SizedBox(height: 12),
        Row(children: footerChildren),
      ],
    );
  }
}
