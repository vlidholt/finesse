import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Tells the owner of an overlay whether its anchor is *on stage*: in a part
/// of the tree that is shown.
///
/// An overlay is painted in the app's `Overlay`, not where its anchor is, so
/// hiding the anchor's part of the tree does not hide it: a menu left open
/// would sit over whatever replaced the page it belongs to. Nothing in the
/// framework says "this subtree is hidden" in one place, so this asks three
/// times:
///
/// * `TickerMode` — disabled under a route that is covered, and in a
///   `Visibility` that does not maintain its animations.
/// * `Visibility.of` — false in a hidden `Visibility`, and so in the hidden
///   children of an `IndexedStack`, which keeps their tickers *running*.
/// * whether the anchor is painted at all — an `Offstage`, an `Opacity` of
///   zero and a kept-alive page of a `PageView` say nothing to their
///   descendants; they only skip them when painting. Every render object
///   answers `paintsChild` for its children, so the anchor's ancestors are
///   asked.
///
/// The first two are dependencies of the owner's context ([resolve], from
/// `didChangeDependencies`), and take effect in the frame that hides the
/// anchor. The third has no notification: once [watch] has been called it
/// is looked up after every frame that is drawn anyway — a walk up the
/// render tree, with no frame scheduled for it — and the owner hears of a
/// change after the frame that made it, so its overlay is one frame late.
///
/// `Portal` takes its overlay down a frame after it is told to, so an owner
/// also builds nothing in the overlay while [onStage] is false.
///
/// An anchor that is merely scrolled out of view is still on stage: a
/// viewport paints the children it has built.
class AnchorStage {
  /// Creates a stage for the anchor at [context], the owner's own context.
  ///
  /// [onChanged] is called, outside any build, when [onStage] changes for a
  /// reason the owner's dependencies do not cover. [watching] says whether
  /// the look-up after each frame is still wanted; it stops when this
  /// returns false and starts again with [watch].
  AnchorStage({
    required BuildContext context,
    required VoidCallback onChanged,
    required bool Function() watching,
  }) : _context = context,
       _onChanged = onChanged,
       _wanted = watching;

  final BuildContext _context;
  final VoidCallback _onChanged;
  final bool Function() _wanted;

  bool _declared = true;
  bool _painted = true;
  bool _scheduled = false;
  bool _disposed = false;

  /// Whether the anchor is in a part of the tree that is shown.
  bool get onStage => _declared && _painted;

  /// Reads what the tree declares about the anchor's branch, and subscribes
  /// the owner to it. Call from `didChangeDependencies`; returns whether
  /// [onStage] changed.
  bool resolve() {
    final was = onStage;
    _declared =
        TickerMode.valuesOf(_context).enabled && Visibility.of(_context);
    return onStage != was;
  }

  /// Looks up whether the anchor is painted, now, and from then on after
  /// every frame for as long as the `watching` callback says so. Call when
  /// the overlay opens; returns whether [onStage] changed.
  bool watch() {
    final was = onStage;
    _painted = _isPainted();
    _schedule();
    return onStage != was;
  }

  void _schedule() {
    if (_scheduled || _disposed) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback(_check);
  }

  void _check(Duration _) {
    _scheduled = false;
    if (_disposed || !_context.mounted || !_wanted()) return;
    final was = onStage;
    _painted = _isPainted();
    // Before the callback: it may close the overlay, and end the watch.
    _schedule();
    if (onStage != was) _onChanged();
  }

  bool _isPainted() {
    var child = _context.findRenderObject();
    // Not laid out yet: nothing says it is hidden.
    if (child == null || !child.attached) return true;
    var parent = child.parent;
    while (parent != null) {
      if (!parent.paintsChild(child!)) return false;
      child = parent;
      parent = child.parent;
    }
    return true;
  }

  /// Stops the look-ups. Call from the owner's `dispose`.
  void dispose() => _disposed = true;
}
