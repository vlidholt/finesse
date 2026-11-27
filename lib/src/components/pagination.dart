import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/icon_button.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/icons/phosphor_icons.dart';
import 'package:una/src/theme/components/button.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/border.dart';
import 'package:una/src/utils/debug_check.dart';

const _transparent = Color(0x00000000);

/// Reserves the same inset as [ButtonVariant.outline] without showing a
/// border, so page numbers do not shift when the selection moves.
UnaDecoration _inactivePageButtonDecoration(ThemeData theme) {
  final outlineBorder = theme.outlineButtonTheme.decoration?.border;
  if (outlineBorder == null) {
    return UnaDecoration(
      border: UnaBorder.all(width: 1, color: _transparent),
    );
  }

  UnaBorderSide transparentize(UnaBorderSide? side) {
    final effective = side ?? const UnaBorderSide(width: 1);
    return effective.copyWith(color: _transparent);
  }

  return UnaDecoration(
    border: outlineBorder.copyWith(
      top: transparentize(outlineBorder.top),
      right: transparentize(outlineBorder.right),
      bottom: transparentize(outlineBorder.bottom),
      left: transparentize(outlineBorder.left),
    ),
  );
}

/// {@template Pagination}
/// A page navigator.
///
/// Mirrors shadcn/ui's `Pagination`: previous/next buttons around a windowed
/// run of page numbers, with an ellipsis standing in for the pages that were
/// skipped.
///
/// ```dart
/// Pagination(
///   page: page,
///   pageCount: 20,
///   onPageChanged: (p) => setState(() => page = p),
/// )
/// ```
///
/// [page] is 1-based, matching how page numbers are shown to users.
/// {@endtemplate}
class Pagination extends StatelessWidget {
  /// {@macro Pagination}
  const Pagination({
    super.key,
    required this.page,
    required this.pageCount,
    this.onPageChanged,
    this.siblingCount,
    this.boundaryCount,
    this.showEdges,
    this.gap,
    this.mainAxisAlignment,
    this.mainAxisSize = MainAxisSize.min,
    this.previousLabel,
    this.nextLabel,
    this.ellipsisTextStyle,
    this.enabled = true,
  }) : assert(page >= 1, 'page is 1-based, so it must be >= 1'),
       assert(pageCount >= 0, 'pageCount cannot be negative');

  /// The current page, 1-based.
  final int page;

  /// The total number of pages.
  final int pageCount;

  /// Called with the new page when the user navigates.
  final ValueChanged<int>? onPageChanged;

  /// {@template Pagination.siblingCount}
  /// How many pages to show either side of the current one, defaults to 1.
  /// {@endtemplate}
  final int? siblingCount;

  /// {@template Pagination.boundaryCount}
  /// How many pages to always show at each end, defaults to 1.
  /// {@endtemplate}
  final int? boundaryCount;

  /// {@template Pagination.showEdges}
  /// Whether to show the previous/next buttons, defaults to `true`.
  /// {@endtemplate}
  final bool? showEdges;

  /// The gap between items.
  final double? gap;

  /// {@template Pagination.mainAxisAlignment}
  /// How the row of items is aligned.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// How much space the row takes on its main axis. Defaults to
  /// [MainAxisSize.min].
  final MainAxisSize mainAxisSize;

  /// Overrides the localized "Previous" label.
  final Widget? previousLabel;

  /// Overrides the localized "Next" label.
  final Widget? nextLabel;

  /// The style of the ellipsis between page runs.
  final TextStyle? ellipsisTextStyle;

  /// Whether the pagination responds to input.
  final bool enabled;

  /// Computes which page numbers to render, inserting nulls where a run of
  /// pages was skipped.
  ///
  /// Exposed for testing: the windowing is the only real logic here, and it is
  /// far easier to pin down as a pure function than through widget queries.
  static List<int?> buildPageWindow({
    required int page,
    required int pageCount,
    int siblingCount = 1,
    int boundaryCount = 1,
  }) {
    if (pageCount <= 0) return const [];

    // Two boundary runs, two sibling runs, the current page and the two
    // ellipses that would replace them. Below that threshold the windowed
    // form would be no shorter than simply listing every page.
    final maxSlots = boundaryCount * 2 + siblingCount * 2 + 3;
    if (pageCount <= maxSlots) {
      return [for (var i = 1; i <= pageCount; i++) i];
    }

    final pages = <int>{};
    // Always-visible pages at each end.
    for (var i = 1; i <= boundaryCount && i <= pageCount; i++) {
      pages.add(i);
    }
    for (var i = pageCount - boundaryCount + 1; i <= pageCount; i++) {
      if (i >= 1) pages.add(i);
    }
    // The window around the current page.
    final current = page.clamp(1, pageCount);
    for (var i = current - siblingCount; i <= current + siblingCount; i++) {
      if (i >= 1 && i <= pageCount) pages.add(i);
    }

    final sorted = pages.toList()..sort();
    final result = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0) {
        final gap = sorted[i] - sorted[i - 1];
        // A gap of exactly 2 means a single page was skipped, so render the
        // page itself rather than an ellipsis that hides just one number.
        if (gap == 2) {
          result.add(sorted[i] - 1);
        } else if (gap > 2) {
          result.add(null);
        }
      }
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final paginationTheme = theme.paginationTheme;
    final localizations = UnaLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );

    final effectiveGap = gap ?? paginationTheme.gap ?? 4.0;
    final effectiveSiblingCount =
        siblingCount ?? paginationTheme.siblingCount ?? 1;
    final effectiveBoundaryCount =
        boundaryCount ?? paginationTheme.boundaryCount ?? 1;
    final effectiveShowEdges = showEdges ?? paginationTheme.showEdges ?? true;
    final effectiveMainAxisAlignment =
        mainAxisAlignment ??
        paginationTheme.mainAxisAlignment ??
        MainAxisAlignment.center;
    final effectiveEllipsisStyle =
        (paginationTheme.ellipsisTextStyle ?? theme.textTheme.muted).merge(
          ellipsisTextStyle,
        );

    final window = buildPageWindow(
      page: page,
      pageCount: pageCount,
      siblingCount: effectiveSiblingCount,
      boundaryCount: effectiveBoundaryCount,
    );

    final canGoPrevious = enabled && onPageChanged != null && page > 1;
    final canGoNext = enabled && onPageChanged != null && page < pageCount;

    final items = <Widget>[];

    void addGap() {
      if (items.isNotEmpty) items.add(SizedBox(width: effectiveGap));
    }

    if (effectiveShowEdges) {
      items.add(
        Button.ghost(
          enabled: canGoPrevious,
          onPressed: canGoPrevious ? () => onPageChanged!(page - 1) : null,
          leading: const PhosphorIcon(PhosphorIconsRegular.caretLeft, size: 16),
          child: previousLabel ?? Text(localizations.pagination.previous),
        ),
      );
    }

    for (final entry in window) {
      addGap();
      if (entry == null) {
        items.add(
          Semantics(
            label: localizations.pagination.morePages,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text('…', style: effectiveEllipsisStyle),
              ),
            ),
          ),
        );
        continue;
      }

      final isCurrent = entry == page;
      items.add(
        // One node: a button named for its page, selected while current.
        MergeSemantics(
          child: Semantics(
            selected: isCurrent,
            child: Button(
              variant: isCurrent ? ButtonVariant.outline : ButtonVariant.ghost,
              // A square, like an icon button, around the number.
              style: ButtonTheme(
                width: theme.buttonSizesTheme.icon?.width,
                height: theme.buttonSizesTheme.icon?.height,
                padding: theme.buttonSizesTheme.icon?.padding,
                decoration: isCurrent
                    ? null
                    : _inactivePageButtonDecoration(theme),
              ),
              enabled: enabled && onPageChanged != null,
              semanticLabel:
                  '${localizations.pagination.page} '
                  '${numberFormat.format(entry)}',
              // The current page does nothing when pressed, but stays a
              // button, undimmed and in the focus order, as the
              // reference's `aria-current` link does: a button with no
              // callback is a disabled one.
              onPressed: onPageChanged == null
                  ? null
                  : () {
                      if (!isCurrent) onPageChanged!(entry);
                    },
              child: Text(numberFormat.format(entry)),
            ),
          ),
        ),
      );
    }

    if (effectiveShowEdges) {
      addGap();
      items.add(
        Button.ghost(
          enabled: canGoNext,
          onPressed: canGoNext ? () => onPageChanged!(page + 1) : null,
          trailing: const PhosphorIcon(
            PhosphorIconsRegular.caretRight,
            size: 16,
          ),
          child: nextLabel ?? Text(localizations.pagination.next),
        ),
      );
    }

    return Semantics(
      container: true,
      child: Row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: effectiveMainAxisAlignment,
        children: items,
      ),
    );
  }
}

/// A compact pagination showing only previous/next and a page counter.
///
/// Useful in a toolbar or beneath a data table, where a full run of page
/// numbers does not fit.
class PaginationCompact extends StatelessWidget {
  /// Creates a compact pagination for [page] of [pageCount].
  const PaginationCompact({
    super.key,
    required this.page,
    required this.pageCount,
    this.onPageChanged,
    this.gap,
    this.enabled = true,
    this.labelBuilder,
  }) : assert(page >= 1, 'page is 1-based, so it must be >= 1');

  /// The current page, starting at 1.
  final int page;

  /// The total number of pages.
  final int pageCount;

  /// Called with the new page when a button is pressed. When null, both
  /// buttons are disabled.
  final ValueChanged<int>? onPageChanged;

  /// The gap between the buttons and the label. Defaults to the theme's gap,
  /// then 4.
  final double? gap;

  /// Whether the buttons react to input. Defaults to true.
  final bool enabled;

  /// Builds the label between the two buttons. Defaults to "Page 1 / 10".
  final Widget Function(BuildContext context, int page, int pageCount)?
  labelBuilder;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final localizations = UnaLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final effectiveGap = gap ?? theme.paginationTheme.gap ?? 4.0;

    final canGoPrevious = enabled && onPageChanged != null && page > 1;
    final canGoNext = enabled && onPageChanged != null && page < pageCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.ghost(
          icon: const PhosphorIcon(PhosphorIconsRegular.caretLeft),
          semanticLabel: localizations.pagination.previous,
          enabled: canGoPrevious,
          onPressed: canGoPrevious ? () => onPageChanged!(page - 1) : null,
        ),
        SizedBox(width: effectiveGap),
        labelBuilder?.call(context, page, pageCount) ??
            Text(
              '${localizations.pagination.page} '
              '${numberFormat.format(page)} / '
              '${numberFormat.format(pageCount)}',
              style: theme.textTheme.muted,
            ),
        SizedBox(width: effectiveGap),
        IconButton.ghost(
          icon: const PhosphorIcon(PhosphorIconsRegular.caretRight),
          semanticLabel: localizations.pagination.next,
          enabled: canGoNext,
          onPressed: canGoNext ? () => onPageChanged!(page + 1) : null,
        ),
      ],
    );
  }
}
