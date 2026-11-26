import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// None of these bars is given a `leading`. The first page has nothing to
/// go back to; the pushed one gets a back button; the full-screen dialog
/// gets a close button.
class AppBarLeadingExample extends StatelessWidget {
  const AppBarLeadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhoneFrame(height: 420, child: _Page(depth: 0));
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.depth, this.dialog = false});

  final int depth;
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          dialog
              ? 'New message'
              : depth == 0
              ? 'Inbox'
              : 'Thread $depth',
        ),
      ),
      body: Center(
        child: UnaColumn(
          mainAxisSize: MainAxisSize.min,
          gap: GapSize.md,
          children: [
            Button.outline(
              onPressed: () => Navigator.of(context).push(
                UnaPageRoute<void>(builder: (_) => _Page(depth: depth + 1)),
              ),
              child: const Text('Push a page'),
            ),
            Button.outline(
              onPressed: () => Navigator.of(context).push(
                UnaPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => _Page(depth: depth, dialog: true),
                ),
              ),
              child: const Text('Open a full-screen dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
