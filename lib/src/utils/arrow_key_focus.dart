import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Binds the arrow keys to directional focus under [child], on every
/// platform.
///
/// An app's default shortcuts move the focus with the arrow keys everywhere
/// but on the web, where the arrows scroll instead. A list that is walked
/// with the arrows — a menu, a select's options — and left that to the
/// defaults could therefore be opened from the keyboard in a browser and
/// then not walked, while the page behind it scrolled. Around such a list
/// this makes the arrows mean the same thing wherever the app runs.
///
/// A text field inside keeps its own use of the arrows: its bindings are
/// nearer to the focus than these.
class ArrowKeyFocus extends StatelessWidget {
  /// Binds the arrow keys to directional focus under [child].
  const ArrowKeyFocus({required this.child, super.key});

  /// The list the arrow keys move through.
  final Widget child;

  static const _shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
      TraversalDirection.up,
    ),
    SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
      TraversalDirection.down,
    ),
    SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(
      TraversalDirection.left,
    ),
    SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(
      TraversalDirection.right,
    ),
  };

  @override
  Widget build(BuildContext context) =>
      Shortcuts(shortcuts: _shortcuts, child: child);
}
