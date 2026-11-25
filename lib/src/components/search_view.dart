import 'dart:async';

import 'package:finesse/src/components/app_bar.dart';
import 'package:finesse/src/components/back_button.dart';
import 'package:finesse/src/components/dialog.dart';
import 'package:finesse/src/components/scaffold.dart';
import 'package:finesse/src/components/search_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/page_route.dart';
import 'package:finesse/src/theme/components/dialog.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Builds the body of a search view for [query].
///
/// Call [close] with a value to dismiss the view and complete the
/// `showSearch` future with it.
typedef SearchViewBuilder<T> = Widget Function(
  BuildContext context,
  String query,
  ValueChanged<T> close,
);

/// Shows a search: a field and, under it, whatever [builder] makes of what
/// is typed. The future completes with the value the builder closed the
/// view with, or null when the user left it.
///
/// On a phone it is a page of its own — a bar with a back button and the
/// field, focused, over the results. On a desktop it is a palette: the
/// surface of the command dialog, with the field on top and the results
/// scrolling beneath it. Which one follows the theme's form factor.
///
/// ```dart
/// final person = await showSearch<Person>(
///   context: context,
///   placeholder: const Text('Search people'),
///   builder: (context, query, close) {
///     if (query.isEmpty) return const RecentSearches();
///     return Column(
///       children: [
///         for (final person in directory.search(query))
///           ListTile(
///             title: Text(person.name),
///             onTap: () => close(person),
///           ),
///       ],
///     );
///   },
/// );
/// ```
///
/// [builder] is called again when the query changes — once typing has
/// paused for [debounce], so a builder that starts a request per query does
/// not start one per keystroke. An emptied field is reported at once. The
/// view scrolls what the builder returns; return the results themselves,
/// not a scroll view.
///
/// The arrow keys move from the field into the results and between them,
/// Tab does too, and Escape clears the query and then closes the view.
///
/// `Command` and `showCommandDialog` remain the choice for a fixed set of
/// actions filtered in memory; this is for results looked up per query.
Future<T?> showSearch<T>({
  required BuildContext context,
  required SearchViewBuilder<T> builder,
  Widget? placeholder,
  String initialQuery = '',
  Duration debounce = const Duration(milliseconds: 200),
  bool useRootNavigator = true,
}) {
  final theme = Theme.of(context);
  if (theme.formFactor == FormFactor.mobile) {
    return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
      FinessePageRoute<T>(
        fullscreenDialog: true,
        builder: (context) => _SearchView<T>(
          builder: builder,
          placeholder: placeholder,
          initialQuery: initialQuery,
          debounce: debounce,
          fullScreen: true,
        ),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final commandTheme = Theme.of(context).commandTheme;
      final direction = Directionality.of(context);
      final size = MediaQuery.sizeOf(context);
      // Like the command dialog: the top edge stays put while the results
      // change the height, so the field never moves under the cursor.
      final top = size.height / 5;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, top, 16, 16),
        child: Dialog(
          style: DialogTheme(
            alignment: Alignment.topCenter,
            constraints: const BoxConstraints(maxWidth: 560),
            borderRadius: commandTheme.decoration?.border?.borderRadius
                ?.resolve(
                  direction,
                ),
            padding: EdgeInsets.zero,
            shadows: Shadows.none,
            backgroundColor: commandTheme.backgroundColor,
            filter: commandTheme.surfaceFilter,
          ),
          scrollable: false,
          child: _SearchView<T>(
            builder: builder,
            placeholder: placeholder,
            initialQuery: initialQuery,
            debounce: debounce,
            fullScreen: false,
          ),
        ),
      );
    },
  );
}

class _SearchView<T> extends StatefulWidget {
  const _SearchView({
    required this.builder,
    required this.placeholder,
    required this.initialQuery,
    required this.debounce,
    required this.fullScreen,
  });

  final SearchViewBuilder<T> builder;
  final Widget? placeholder;
  final String initialQuery;
  final Duration debounce;
  final bool fullScreen;

  @override
  State<_SearchView<T>> createState() => _SearchViewState<T>();
}

class _SearchViewState<T> extends State<_SearchView<T>> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  final _fieldNode = FocusNode(debugLabel: 'Search view field');

  /// Around the field and the results: where the arrow keys walk.
  final _scopeNode = FocusNode(
    debugLabel: 'Search view',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The query the results are built for: what is typed, once typing has
  /// paused.
  late String _query = widget.initialQuery;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _fieldNode.dispose();
    _scopeNode.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    // Nothing to wait for when the field was emptied, or when the caller
    // wants every keystroke.
    if (text.isEmpty || widget.debounce <= Duration.zero) {
      _setQuery(text);
    } else {
      _debounce = Timer(widget.debounce, () => _setQuery(text));
    }
  }

  void _setQuery(String text) {
    if (!mounted || text == _query) return;
    setState(() => _query = text);
  }

  void _close(T value) {
    _debounce?.cancel();
    Navigator.of(context).pop(value);
  }

  void _leave() => Navigator.of(context).maybePop();

  /// Moves the focus one stop along the field and the results, in reading
  /// order, and stops at either end.
  void _step(int by) {
    final current = FocusManager.instance.primaryFocus;
    if (current == null) return;
    final stops = ReadingOrderTraversalPolicy()
        .sortDescendants(_scopeNode.traversalDescendants, current)
        // From the field on: the back button before it is Tab's to reach.
        .skipWhile((node) => node != _fieldNode)
        .toList();
    final index = stops.indexOf(current);
    final next = index + by;
    if (index < 0 || next < 0 || next >= stops.length) return;
    FocusTraversalPolicy.defaultTraversalRequestFocusCallback(
      stops[next],
      alignmentPolicy: by > 0
          ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
          : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = FinesseLocalizations.of(context);
    final commandTheme = theme.commandTheme;

    final results = Builder(
      builder: (context) => widget.builder(context, _query, _close),
    );
    // The inset of a command palette's list, on every side: the results
    // clear the surface's edge, and a focused row has room for its ring.
    final optionsPadding =
        (commandTheme.optionsPadding ?? const EdgeInsets.all(4)).resolve(
          Directionality.of(context),
        );
    final inset = EdgeInsets.fromLTRB(
      optionsPadding.left,
      optionsPadding.bottom,
      optionsPadding.right,
      optionsPadding.bottom,
    );

    final Widget view;
    if (widget.fullScreen) {
      final field = SearchField(
        controller: _controller,
        focusNode: _fieldNode,
        autofocus: true,
        placeholder: widget.placeholder,
        onChanged: _onChanged,
        // The keyboard's search key asks for the results now.
        onSubmitted: (text) {
          _debounce?.cancel();
          _setQuery(text);
        },
      );
      view = Scaffold(
        appBar: AppBar(
          leading: BackButton(
            semanticLabel: l.search.close,
            onPressed: _leave,
          ),
          title: field,
        ),
        body: Builder(
          builder: (context) {
            // The bars and the keyboard: the results scroll under the
            // first and stop short of the second.
            final media = MediaQuery.of(context);
            return RepaintBoundary(
              child: SingleChildScrollView(
                padding:
                    inset +
                    media.padding.copyWith(
                      bottom: media.padding.bottom + media.viewInsets.bottom,
                    ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: results,
              ),
            );
          },
        ),
      );
    } else {
      final maxHeight = MediaQuery.sizeOf(context).height * .55;
      view = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                commandTheme.searchPadding ??
                const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: SearchField(
              controller: _controller,
              focusNode: _fieldNode,
              autofocus: true,
              placeholder: widget.placeholder,
              decoration: commandTheme.searchDecoration,
              constraints: BoxConstraints(
                minHeight: commandTheme.searchHeight ?? 32,
              ),
              padding:
                  commandTheme.searchInputPadding ??
                  const EdgeInsets.symmetric(horizontal: 8),
              onChanged: _onChanged,
              onSubmitted: (text) {
                _debounce?.cancel();
                _setQuery(text);
              },
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SingleChildScrollView(padding: inset, child: results),
            ),
          ),
        ],
      );
    }

    // Escape: the field clears a query first; with none, or from a
    // result, the view goes.
    return DismissShortcut(
      isActive: () => true,
      onDismiss: _leave,
      child: FocusTraversalGroup(
        child: Focus(
          focusNode: _scopeNode,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _step(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _step(-1),
            },
            child: view,
          ),
        ),
      ),
    );
  }
}
