import 'package:finesse/src/utils/provider.dart';
import 'package:flutter/widgets.dart';

/// Holds a mouse cursor that a [MouseCursorProvider] shows over its whole
/// subtree.
///
/// The resizable panels use it to keep the resize cursor while a divider is
/// dragged, even when the pointer leaves the divider.
class MouseCursorController extends ChangeNotifier {
  /// Creates a controller with [cursor]. Defaults to [MouseCursor.defer], which
  /// lets the widgets below choose the cursor.
  MouseCursorController({MouseCursor cursor = MouseCursor.defer})
    : _cursor = cursor;

  late MouseCursor _cursor;

  /// The cursor shown over the subtree. Setting it notifies listeners.
  MouseCursor get cursor => _cursor;

  set cursor(MouseCursor cursor) {
    if (cursor == _cursor) return;
    _cursor = cursor;
    notifyListeners();
  }
}

/// Shows the cursor of a [MouseCursorController] over its child, and
/// provides the controller to descendants.
///
/// Descendants read the controller with
/// `context.read<MouseCursorController>()`.
class MouseCursorProvider extends StatefulWidget {
  /// Creates a provider. When [controller] is null, it creates its own.
  const MouseCursorProvider({
    super.key,
    this.controller,
    required this.child,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The controller to provide. When null, the provider creates its own.
  final MouseCursorController? controller;

  @override
  State<MouseCursorProvider> createState() => MouseCursorProviderState();
}

/// The state of a [MouseCursorProvider].
class MouseCursorProviderState extends State<MouseCursorProvider> {
  MouseCursorController? _internalController;

  /// The controller in use: [MouseCursorProvider.controller], or an
  /// internal one when that is null.
  MouseCursorController get controller {
    if (widget.controller != null) return widget.controller!;
    return _internalController ??= MouseCursorController();
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      data: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return MouseRegion(
            cursor: controller.cursor,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
