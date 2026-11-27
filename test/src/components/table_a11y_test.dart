import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

class _User {
  const _User(this.id, this.name);

  final String id;
  final String name;
}

/// Tables for the keyboard and for assistive technology: a row that can be
/// tapped can also be reached with Tab and activated with Enter or Space,
/// and by a screen reader from any of its cells; header cells say they are
/// headers; a selected row's cells say they are selected; and the
/// selection checkboxes are named.
void main() {
  Widget table({
    void Function(int row)? onRowTap,
    bool Function(int row)? rowSelected,
  }) => SizedBox(
    width: 400,
    height: 300,
    child: UnaTable.list(
      onRowTap: onRowTap,
      rowSelected: rowSelected,
      header: const [
        UnaTableCell.header(child: Text('Name')),
        UnaTableCell.header(child: Text('Role')),
      ],
      children: const [
        [UnaTableCell(child: Text('Ann')), UnaTableCell(child: Text('Owner'))],
        [UnaTableCell(child: Text('Bob')), UnaTableCell(child: Text('Guest'))],
      ],
    ),
  );

  Future<void> tab(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }

  testWidgets('header cells are announced as headers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, table());
    expect(
      find.semantics.byLabel('Name').evaluate().single,
      containsSemantics(isHeader: true),
    );
    expect(
      find.semantics.byLabel('Ann').evaluate().single,
      containsSemantics(isHeader: false),
    );
    handle.dispose();
  });

  testWidgets('a tappable row is a Tab stop that Enter and Space tap', (
    tester,
  ) async {
    final taps = <int>[];
    await pumpUna(tester, table(onRowTap: taps.add));

    await tab(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    // Counted as the pointer counts it: the header is row 0.
    expect(taps, [1]);

    await tab(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, [1, 2]);

    // The pointer still taps a row once.
    await tester.tap(find.text('Owner'));
    await tester.pump();
    expect(taps, [1, 2, 1]);
  });

  testWidgets('a row without onRowTap is not a Tab stop', (tester) async {
    await pumpUna(tester, table());
    await tab(tester);
    final focus = FocusManager.instance.primaryFocus?.context;
    final inTable =
        focus != null &&
        find
            .ancestor(
              of: find.byElementPredicate((e) => e == focus),
              matching: find.byType(UnaTable),
            )
            .evaluate()
            .isNotEmpty;
    expect(inTable, isFalse);
  });

  testWidgets('the row with the focus is ringed while the focus shows', (
    tester,
  ) async {
    useTraditionalHighlights();
    await pumpUna(tester, table(onRowTap: (_) {}));

    TableSpanDecoration? ringOf(int row) {
      final table = tester.widget<TableView>(find.byType(TableView));
      final delegate = table.delegate as TableCellListDelegate;
      return delegate.buildRow(row)!.foregroundDecoration;
    }

    expect(ringOf(1), isNull);
    await tab(tester);
    await tester.pump();
    expect(ringOf(1)?.border?.leading.width, greaterThan(0));
    expect(ringOf(2), isNull);
    await tab(tester);
    await tester.pump();
    expect(ringOf(1), isNull);
    expect(ringOf(2)?.border?.trailing.width, greaterThan(0));
  });

  testWidgets('a screen reader can tap a row from any of its cells', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final taps = <int>[];
    await pumpUna(tester, table(onRowTap: taps.add));
    expect(
      find.semantics.byLabel('Guest').evaluate().single,
      containsSemantics(hasTapAction: true),
    );
    tester.semantics.tap(find.semantics.byLabel('Guest'));
    await tester.pump();
    expect(taps, [2]);
    tester.semantics.tap(find.semantics.byLabel('Ann'));
    await tester.pump();
    expect(taps, [2, 1]);
    handle.dispose();
  });

  testWidgets("a selected row's cells are selected", (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, table(rowSelected: (row) => row == 2));
    expect(
      find.semantics.byLabel('Guest').evaluate().single,
      containsSemantics(isSelected: true, hasSelectedState: true),
    );
    expect(
      find.semantics.byLabel('Ann').evaluate().single,
      containsSemantics(isSelected: false, hasSelectedState: true),
    );
    handle.dispose();
  });

  testWidgets('the selection checkboxes of a DataTable are named', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = DataTableController<_User>(
      rows: const [_User('1', 'Ann'), _User('2', 'Bob')],
    );
    addTearDown(controller.dispose);
    await pumpUna(
      tester,
      SizedBox(
        height: 400,
        child: DataTable<_User>(
          controller: controller,
          height: 300,
          keyOf: (user) => user.id,
          selectable: true,
          columns: [
            DataTableColumn(
              id: 'name',
              header: 'Name',
              cellBuilder: (context, user) => Text(user.name),
            ),
          ],
        ),
      ),
    );
    expect(
      find.semantics.byLabel('Select all rows').evaluate().single,
      containsSemantics(hasCheckedState: true),
    );
    expect(
      find.semantics.byLabel('Select row 2').evaluate().single,
      containsSemantics(hasCheckedState: true, isChecked: false),
    );

    controller.toggleSelected('2');
    await tester.pump();
    expect(
      find.semantics.byLabel('Select row 2').evaluate().single,
      containsSemantics(isChecked: true),
    );
    expect(
      find.semantics.byLabel('Bob').evaluate().single,
      containsSemantics(isSelected: true),
    );
    handle.dispose();
  });
}
