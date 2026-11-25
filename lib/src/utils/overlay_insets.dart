import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// What covers the edges of the screen right now, as reported by the widgets
/// that cover them: a `Scaffold`'s bars, its footer, its floating action
/// button, the software keyboard.
///
/// Something that floats over the whole app — a toast, a snack of any kind —
/// reads [insets] to stay clear of them, and listens for changes:
///
/// ```dart
/// final insets = OverlayInsets.maybeOf(context)?.insets ?? EdgeInsets.zero;
/// ```
///
/// A widget that covers an edge calls [report] with an owner (itself, or its
/// `State`) whenever its extent changes and [remove] when it goes away.
/// [insets] is the largest report on each edge.
///
/// An [OverlayInsetsScope] puts one in the tree. Without a scope above them
/// reporters do nothing, so a `Scaffold` works the same either way.
class OverlayInsets extends ChangeNotifier {
  final Map<Object, EdgeInsets> _reports = {};
  EdgeInsets _insets = EdgeInsets.zero;

  /// The space taken at each edge: on every side, the largest of the
  /// reports.
  EdgeInsets get insets => _insets;

  /// Records that [owner] covers [insets] of the screen's edges, in place of
  /// whatever it reported before.
  ///
  /// Listeners are told when the result changes. Do not call it while the
  /// tree is being built or laid out; report after the frame.
  void report(Object owner, EdgeInsets insets) {
    if (_disposed || _reports[owner] == insets) return;
    _reports[owner] = insets;
    _resolve();
  }

  /// Forgets what [owner] reported.
  void remove(Object owner) {
    // A reporter that goes away with the scope lets go after it is gone.
    if (_disposed || _reports.remove(owner) == null) return;
    _resolve();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _resolve() {
    var left = 0.0;
    var top = 0.0;
    var right = 0.0;
    var bottom = 0.0;
    for (final report in _reports.values) {
      left = math.max(left, report.left);
      top = math.max(top, report.top);
      right = math.max(right, report.right);
      bottom = math.max(bottom, report.bottom);
    }
    final resolved = EdgeInsets.fromLTRB(left, top, right, bottom);
    if (resolved == _insets) return;
    _insets = resolved;
    notifyListeners();
  }

  /// The registry of the nearest [OverlayInsetsScope], or null when there is
  /// none.
  ///
  /// The caller does not come to depend on it: a reporter only writes, and a
  /// reader listens to the returned object (or uses [watch]).
  static OverlayInsets? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_OverlayInsetsMarker>()?.notifier;

  /// The insets reported under the nearest [OverlayInsetsScope], rebuilding
  /// [context] whenever they change. [EdgeInsets.zero] without a scope.
  static EdgeInsets watch(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_OverlayInsetsMarker>()
          ?.notifier
          ?.insets ??
      EdgeInsets.zero;
}

/// Collects the [OverlayInsets] reported beneath it.
///
/// Put it above both the reporters and the readers: around an app's
/// navigator, say, with the toast layer inside it.
///
/// ```dart
/// OverlayInsetsScope(
///   child: Stack(children: [app, const ToastLayer()]),
/// )
/// ```
class OverlayInsetsScope extends StatefulWidget {
  /// Creates a scope that collects the insets reported under [child].
  const OverlayInsetsScope({required this.child, super.key});

  /// The subtree whose reports are collected.
  final Widget child;

  @override
  State<OverlayInsetsScope> createState() => _OverlayInsetsScopeState();
}

class _OverlayInsetsScopeState extends State<OverlayInsetsScope> {
  final _insets = OverlayInsets();

  @override
  void dispose() {
    _insets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _OverlayInsetsMarker(notifier: _insets, child: widget.child);
}

class _OverlayInsetsMarker extends InheritedNotifier<OverlayInsets> {
  const _OverlayInsetsMarker({required super.notifier, required super.child});
}
