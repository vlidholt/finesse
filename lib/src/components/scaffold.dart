import 'package:finesse/src/components/app_bar.dart';
import 'package:finesse/src/components/navigation_bar.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The frame of a screen: a page with an [appBar] over its top and a
/// [bottomNavigationBar] over its bottom.
///
/// ```dart
/// Scaffold(
///   appBar: const AppBar(title: Text('Messages')),
///   body: ListView(children: conversations),
/// )
/// ```
///
/// The bars are laid over [body], not above and below it, so a translucent
/// bar shows the page scrolling beneath it. To keep content clear of them,
/// [body] is given a [MediaQuery] whose padding includes the bars' heights —
/// a `ListView`, a `SafeArea` or a `PageContainer` then insets itself, the
/// same way it would for the status bar. The bars are measured, so a bar of
/// any height works.
class Scaffold extends StatefulWidget {
  /// Creates a scaffold.
  const Scaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.appBarHeight,
    this.bottomNavigationBarHeight,
    super.key,
  });

  /// The page.
  final Widget body;

  /// The bar laid over the top of [body], usually an [AppBar].
  final Widget? appBar;

  /// The bar laid over the bottom of [body], usually a
  /// [BottomNavigationBar]. Any widget works: a glass action bar, a message
  /// composer.
  final Widget? bottomNavigationBar;

  /// The page's colour. Defaults to the theme's background.
  final Color? backgroundColor;

  /// How far [body] is inset for [appBar], in place of its measured height.
  final double? appBarHeight;

  /// How far [body] is inset for [bottomNavigationBar], in place of its
  /// measured height.
  final double? bottomNavigationBarHeight;

  @override
  State<Scaffold> createState() => _ScaffoldState();
}

class _ScaffoldState extends State<Scaffold> {
  // The bars are measured after layout. Until the first measurement arrives
  // the theme's own heights are used, which are exact for an [AppBar] and a
  // [BottomNavigationBar], so the usual case never sees a second layout.
  double? _measuredTop;
  double? _measuredBottom;

  void _onAppBarSize(Size size) {
    if (!mounted || _measuredTop == size.height) return;
    setState(() => _measuredTop = size.height);
  }

  void _onBottomBarSize(Size size) {
    if (!mounted || _measuredBottom == size.height) return;
    setState(() => _measuredBottom = size.height);
  }

  @override
  void didUpdateWidget(Scaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appBar == null) _measuredTop = null;
    if (widget.bottomNavigationBar == null) _measuredBottom = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final top = widget.appBar == null
        ? media.padding.top
        : widget.appBarHeight ?? _measuredTop ?? AppBar.heightOf(context);
    final bottom = widget.bottomNavigationBar == null
        ? media.padding.bottom
        : widget.bottomNavigationBarHeight ??
              _measuredBottom ??
              BottomNavigationBar.heightOf(context);

    return ColoredBox(
      color: widget.backgroundColor ?? theme.colorScheme.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(top: top, bottom: bottom),
            ),
            child: widget.body,
          ),
          if (widget.appBar != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _SizeReporter(
                onSize: _onAppBarSize,
                child: widget.appBar,
              ),
            ),
          if (widget.bottomNavigationBar != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SizeReporter(
                onSize: _onBottomBarSize,
                child: widget.bottomNavigationBar,
              ),
            ),
        ],
      ),
    );
  }
}

/// Reports its child's size after each layout that changes it.
class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({required this.onSize, super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSizeReporter(onSize);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeReporter renderObject,
  ) {
    renderObject.onSize = onSize;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this.onSize);

  ValueChanged<Size> onSize;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final measured = size;
    if (measured == _reported) return;
    _reported = measured;
    // Layout cannot call setState; hand the size over once the frame is
    // done.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (attached) onSize(measured);
    });
  }
}
