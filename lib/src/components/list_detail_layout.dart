import 'package:finesse/src/components/resizable.dart';
import 'package:finesse/src/page_route.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A list and the detail of what is chosen in it: side by side on a
/// desktop, and one over the other on a phone.
///
/// ```dart
/// ListDetailLayout(
///   list: ConversationList(
///     selected: open,
///     onSelected: (id) => setState(() => open = id),
///   ),
///   detail: open == null
///       ? null
///       : Conversation(key: ValueKey(open), id: open!),
///   placeholder: const Empty(title: Text('Pick a conversation')),
///   onDetailClosed: () => setState(() => open = null),
/// )
/// ```
///
/// On a desktop the [list] is a column [listWidth] wide at the start, a
/// hairline, and the [detail] in the rest — or the [placeholder] while
/// nothing is chosen. With [resizable] the hairline can be dragged.
///
/// On a phone the list has the whole width. Giving it a [detail] pushes
/// that over the list as a page, with the page route's transition, and
/// taking it away pops it. The user can go back too — the system's back
/// button or gesture, a swipe from the start edge on iOS — which calls
/// [onDetailClosed]: clear your selection there, so that [detail] becomes
/// null. The list keeps its state underneath, and both keep theirs when the
/// form factor changes.
///
/// It follows the theme's form factor, not the window: read
/// `Theme.of(context).formFactor` in [detail] to decide whether its app bar
/// needs a back button.
class ListDetailLayout extends StatefulWidget {
  /// Creates a list-detail layout.
  const ListDetailLayout({
    required this.list,
    this.detail,
    this.placeholder,
    this.listWidth = 360,
    this.resizable = false,
    this.onDetailClosed,
    super.key,
  });

  /// The list: conversations, files, settings sections.
  final Widget list;

  /// The detail of what is chosen in the list, or null while nothing is.
  ///
  /// Give it a key that changes with the choice — `ValueKey(id)` — so that
  /// each item's detail has its own state.
  final Widget? detail;

  /// Shown in the detail's place on a desktop while [detail] is null.
  final Widget? placeholder;

  /// The width of the list's column on a desktop.
  final double listWidth;

  /// Whether the user can drag the line between the two on a desktop.
  final bool resizable;

  /// Called when the user goes back from the [detail] on a phone. Make
  /// [detail] null in answer.
  final VoidCallback? onDetailClosed;

  @override
  State<ListDetailLayout> createState() => _ListDetailLayoutState();
}

class _ListDetailLayoutState extends State<ListDetailLayout> {
  // The two keep their state when the form factor moves them from one
  // arrangement to the other.
  final _listKey = GlobalKey(debugLabel: 'list');
  final _detailKey = GlobalKey(debugLabel: 'detail');
  final _navigatorKey = GlobalKey<NavigatorState>();

  static const _listPageKey = ValueKey('list');
  static const _detailPageKey = ValueKey('detail');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = KeyedSubtree(key: _listKey, child: widget.list);
    final detail = widget.detail == null
        ? null
        : KeyedSubtree(key: _detailKey, child: widget.detail!);

    if (theme.formFactor == FormFactor.mobile) {
      // System back goes to the app's navigator, which knows nothing of
      // the one in here: catch it while there is a detail to go back from.
      return NavigatorPopHandler<Object?>(
        enabled: detail != null,
        onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
        child: Navigator(
          key: _navigatorKey,
          pages: [
            FinessePage<void>(key: _listPageKey, child: list),
            if (detail != null)
              FinessePage<void>(key: _detailPageKey, child: detail),
          ],
          onDidRemovePage: (page) {
            if (page.key == _detailPageKey && widget.detail != null) {
              widget.onDetailClosed?.call();
            }
          },
        ),
      );
    }

    final second = detail ?? widget.placeholder ?? const SizedBox.shrink();
    if (widget.resizable) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final share = width.isFinite && width > 0
              ? (widget.listWidth / width).clamp(.15, .6)
              : .3;
          return ResizablePanelGroup(
            children: [
              ResizablePanel(
                id: 'list',
                defaultSize: share,
                minSize: .15,
                maxSize: .6,
                child: list,
              ),
              ResizablePanel(
                id: 'detail',
                defaultSize: 1 - share,
                minSize: .4,
                child: second,
              ),
            ],
          );
        },
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: widget.listWidth, child: list),
        // A hairline, on the theme's border colour.
        SizedBox(
          width: 1,
          child: ColoredBox(color: theme.colorScheme.border),
        ),
        Expanded(child: second),
      ],
    );
  }
}
