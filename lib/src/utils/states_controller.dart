import 'package:flutter/widgets.dart';

/// An interaction state of a widget.
enum FinesseState {
  /// The widget has focus.
  focused,

  /// A pointer is over the widget.
  hovered,

  /// The widget is being pressed.
  pressed,

  /// The widget does not react to input.
  disabled,
}

/// Holds the set of [FinesseState]s of a widget and notifies listeners when it
/// changes.
class StatesController extends ValueNotifier<Set<FinesseState>> {
  /// Creates a controller with the given states. Defaults to no states.
  StatesController([Set<FinesseState>? value])
    : super(<FinesseState>{...?value});

  /// Adds [state] to [value] if [add] is true, and removes it otherwise,
  /// and notifies listeners if [value] has changed.
  void update(FinesseState state, bool add) {
    // Emit a new Set rather than mutating in place. A ValueNotifier is
    // expected to replace its value; mutating it meant a listener that cached
    // the previous value saw that value change underneath it, so no listener
    // could tell which state had actually flipped.
    final next = <FinesseState>{...value};
    final valueChanged = add ? next.add(state) : next.remove(state);
    if (valueChanged) {
      value = next;
    }
  }
}
