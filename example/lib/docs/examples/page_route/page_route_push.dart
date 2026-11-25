import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A navigator in a phone-sized frame. Pages are pushed with
/// `FinessePageRoute`; `backGesture: true` offers the swipe from the start
/// edge on every platform, where it is otherwise iOS's alone.
class PageRoutePushExample extends StatelessWidget {
  const PageRoutePushExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: 340,
        height: 460,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: theme.radii.xl2),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl2,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Navigator(
            onGenerateRoute: (settings) => FinessePageRoute<void>(
              settings: settings,
              builder: (context) => const _Page(depth: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.depth, this.dialog = false});

  final int depth;
  final bool dialog;

  void _push(BuildContext context, {bool fullscreenDialog = false}) {
    Navigator.of(context).push(
      FinessePageRoute<void>(
        fullscreenDialog: fullscreenDialog,
        // Drag the page away from its left edge.
        backGesture: true,
        builder: (context) => _Page(depth: depth + 1, dialog: fullscreenDialog),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        // The bar shows the way back by itself: a caret on a page that
        // can be popped, a cross on a full-screen dialog.
        title: Text(dialog ? 'New note' : 'Page $depth'),
      ),
      body: PageContainer(
        child: FinesseColumn(
          gap: GapSize.md,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              title: Text(dialog ? 'A full-screen dialog' : 'Page $depth'),
              description: Text(
                dialog
                    ? 'It rises from below and is closed, not swiped away.'
                    : canPop
                    ? 'Drag from the left edge to go back, or let go '
                          'early and it springs into place again.'
                    : 'The first page of a navigator has nowhere to go '
                          'back to.',
              ),
            ),
            Button(
              onPressed: () => _push(context),
              child: const Text('Push a page'),
            ),
            Button.outline(
              onPressed: () => _push(context, fullscreenDialog: true),
              child: const Text('Open a full-screen dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
