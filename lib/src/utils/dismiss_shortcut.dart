import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Binds Escape to [onDismiss], but only while [isActive] returns true.
///
/// A tooltip, popover or select binds Escape so a keyboard user can close it.
/// A plain `CallbackShortcuts` consumes the key even while the overlay is
/// closed, so an enclosing dialog, sheet or route never sees its
/// `DismissIntent` — Escape on a focused, closed trigger did nothing. Here an
/// inactive shortcut leaves the key event unhandled, which lets it reach the
/// next handler up the focus chain — another [DismissShortcut] included, so
/// one press closes one layer, innermost first.
///
/// `Popover`, `Tooltip` and `Select` use it for their own overlays. Wrap
/// anything else of yours that Escape should close — a search panel under a
/// field, an inline editor — the same way, around the widget that holds the
/// focus while it is open:
///
/// ```dart
/// DismissShortcut(
///   isActive: () => _panelOpen,
///   onDismiss: _closePanel,
///   child: TextField(controller: _query),
/// )
/// ```
///
/// [isActive] is read once, when the key is pressed, so the widget does not
/// have to rebuild when the answer changes. While it returns true, the press
/// calls [onDismiss] and is handled: nothing that encloses this sees it and
/// the platform is told the key was used. While it returns false, Escape
/// goes on to whatever encloses this — the dialog the field is in, for one.
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

  static const _escape = SingleActivator(LogicalKeyboardKey.escape);

  // A key handler on the focus chain rather than a `Shortcuts` + `Actions`
  // pair. An action is looked up from the focused widget by its intent's
  // type, so the *nearest* one answers for every `Shortcuts` on the way up:
  // nested, an inactive inner `DismissShortcut` shadowed the active one
  // around it (a closed popover inside a shown tooltip), exactly as binding
  // `DismissIntent` would shadow the enclosing route's. A handler asks only
  // itself.
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // The answer is taken once, before [onDismiss] closes the overlay:
    // asked afterwards, [isActive] would answer for the *next* press and
    // the Escape that closed the panel would be reported as unhandled (the
    // platform beeps, or a browser leaves full screen).
    if (!_escape.accepts(event, HardwareKeyboard.instance) || !isActive()) {
      return KeyEventResult.ignored;
    }
    onDismiss();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKeyEvent,
      child: child,
    );
  }
}
