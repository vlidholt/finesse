import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Binds Escape to [onDismiss], but only while [isActive] returns true.
///
/// A tooltip, popover or select binds Escape so a keyboard user can close it.
/// A plain `CallbackShortcuts` consumes the key even while the overlay is
/// closed, so an enclosing dialog, sheet or route never sees its
/// `DismissIntent` — Escape on a focused, closed trigger did nothing. Here the
/// action reports itself disabled while inactive, which leaves the key event
/// unhandled and lets it reach the next handler up the focus chain.
class DismissShortcut extends StatelessWidget {
  /// Creates a shortcut that calls [onDismiss] on Escape while [isActive]
  /// returns true.
  const DismissShortcut({
    super.key,
    required this.isActive,
    required this.onDismiss,
    required this.child,
  });

  /// Whether Escape currently dismisses; read when the key is pressed.
  final bool Function() isActive;

  /// Called on Escape while [isActive] is true.
  final VoidCallback onDismiss;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _DismissIntent(),
      },
      child: Actions(
        actions: {
          _DismissIntent: _DismissAction(isActive, onDismiss),
        },
        child: child,
      ),
    );
  }
}

// A private intent rather than DismissIntent: binding DismissIntent here
// would shadow the enclosing route's own DismissIntent action for everything
// below, even when this action is disabled.
class _DismissIntent extends Intent {
  const _DismissIntent();
}

class _DismissAction extends Action<_DismissIntent> {
  _DismissAction(this._isActive, this._onDismiss);

  final bool Function() _isActive;
  final VoidCallback _onDismiss;

  @override
  bool isEnabled(_DismissIntent intent) => _isActive();

  @override
  bool consumesKey(_DismissIntent intent) => _isActive();

  @override
  void invoke(_DismissIntent intent) => _onDismiss();
}
