import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Shows focus the way a browser's `:focus-visible` does: after a key, and
/// not after a click.
///
/// Flutter's focus manager decides whether focus highlights show from the
/// last interaction, but a mouse is not one: a click leaves the mode as it
/// was, which on a desktop and in a desktop browser is the traditional mode
/// that shows them. So whatever was focused *by* a click showed its ring —
/// the first action of a sheet a button opened (it takes the focus), and
/// the button itself once the sheet closed and the focus came back to it.
/// That read as the last thing chosen still being selected.
///
/// Installed once, this switches the focus manager to
/// [FocusHighlightStrategy.alwaysTouch] on any pointer going down and back
/// to [FocusHighlightStrategy.automatic] on a key that is not a modifier
/// (which the manager then reads as traditional, as before). It leaves the
/// strategy alone while someone else has set it, so an app or a test that
/// pins the strategy keeps it.
///
/// Every component that shows focus through the highlight mode follows:
/// `Pressable` (and so buttons, rows, tiles and tabs), and the components
/// that ask `FocusManager.highlightMode` themselves.
abstract final class FocusVisibility {
  static bool _installed = false;

  /// The focus manager the strategy was last set on, and the strategy set.
  /// A test binding makes a new manager per test.
  static FocusManager? _manager;
  static FocusHighlightStrategy? _strategy;

  /// Starts following pointers and keys, if it has not already.
  static void ensureInstalled() {
    if (_installed) return;
    _installed = true;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  static void _apply(FocusHighlightStrategy strategy) {
    final manager = FocusManager.instance;
    final current = manager.highlightStrategy;
    final ours = identical(_manager, manager) ? _strategy : null;
    if (current != FocusHighlightStrategy.automatic && current != ours) return;
    _manager = manager;
    _strategy = strategy;
    manager.highlightStrategy = strategy;
  }

  static void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent) _apply(FocusHighlightStrategy.alwaysTouch);
  }

  static bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent && !_modifiers.contains(event.logicalKey)) {
      _apply(FocusHighlightStrategy.automatic);
    }
    return false;
  }

  /// Keys held for a click (⌘-click, shift-click) that are not the keyboard
  /// being used to move about.
  static final _modifiers = <LogicalKeyboardKey>{
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.fn,
  };
}
