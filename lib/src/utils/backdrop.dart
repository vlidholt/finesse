import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Blurs and saturates whatever is painted behind [child], clipped to
/// [borderRadius].
///
/// This is the filter half of a frosted-glass surface: `Glass`, `AppBar`,
/// `BottomNavigationBar` and translucent `Card`s put their tint on top of
/// one. With no [blur] and a [saturation] of 1 it builds nothing and returns
/// [child] as is, so an opaque style pays for no backdrop layer.
///
/// [blur] is the Gaussian sigma in logical pixels, the same number CSS takes
/// in `backdrop-filter: blur(24px)`.
class Backdrop extends StatelessWidget {
  /// Creates a backdrop filter around [child].
  const Backdrop({
    required this.child,
    this.blur = 0,
    this.saturation = 1,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  /// The sigma of the Gaussian blur; 0 or less disables it.
  final double blur;

  /// How much the backdrop is saturated; 1 leaves it alone.
  final double saturation;

  /// The corners the filtered area is clipped to.
  final BorderRadiusGeometry borderRadius;

  /// The widget painted over the filtered backdrop.
  final Widget child;

  static final _filters = <(double, double), ImageFilter>{};

  /// The filter for [blur] and [saturation], or null when neither does
  /// anything.
  ///
  /// Filters are cached per pair of values: a theme holds a handful of them
  /// and every glass surface on screen would otherwise allocate its own on
  /// each build.
  static ImageFilter? filterFor({required double blur, double saturation = 1}) {
    if (blur <= 0 && saturation == 1) return null;
    // A theme uses a handful of values; an animated blur would otherwise
    // add an entry per frame for ever.
    if (_filters.length > 32) _filters.clear();
    return _filters.putIfAbsent(
      (blur, saturation),
      () => _build(blur, saturation)!,
    );
  }

  /// [filter] with its result faded to [opacity], for fading glass in and
  /// out: the filtered backdrop is laid over the unfiltered one at that
  /// opacity, so the blur cross-fades in rather than growing.
  ///
  /// Returns null at zero, where there is nothing to filter, and [filter]
  /// itself at one.
  static ImageFilter? faded(ImageFilter filter, double opacity) {
    if (opacity <= 0) return null;
    if (opacity >= 1) return filter;
    return ImageFilter.compose(
      outer: ColorFilter.matrix([
        1, 0, 0, 0, 0, //
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, opacity, 0,
      ]),
      inner: filter,
    );
  }

  static ImageFilter? _build(double blur, double saturation) {
    final blurs = blur > 0;
    final saturates = saturation != 1;
    if (!blurs && !saturates) return null;
    final blurFilter = blurs
        ? ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
            tileMode: TileMode.mirror,
          )
        : null;
    if (!saturates) return blurFilter;
    // The luminance-preserving saturation matrix CSS's `saturate()` uses.
    final s = saturation;
    final matrix = ColorFilter.matrix([
      .213 + .787 * s, .715 - .715 * s, .072 - .072 * s, 0, 0, //
      .213 - .213 * s, .715 + .285 * s, .072 - .072 * s, 0, 0,
      .213 - .213 * s, .715 - .715 * s, .072 + .928 * s, 0, 0,
      0, 0, 0, 1, 0,
    ]);
    if (blurFilter == null) return matrix;
    return ImageFilter.compose(outer: matrix, inner: blurFilter);
  }

  @override
  Widget build(BuildContext context) {
    final filter = filterFor(blur: blur, saturation: saturation);
    if (filter == null) return child;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(filter: filter, child: child),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('blur', blur))
      ..add(DoubleProperty('saturation', saturation));
  }
}

/// The fade of an entrance or exit animation, offered to the glass surface
/// below it.
///
/// A backdrop filter under an opacity layer does not survive on every
/// renderer: the filter samples the layer it is in, which is empty while the
/// layer is being faded, so the blur vanishes for the length of the
/// animation and snaps in when it ends. A [BackdropFadeHost] therefore
/// publishes its fade here instead of only applying it, and a
/// [BackdropSurface] with a filter *claims* it: the host stops fading, and
/// the surface fades its own tint, content and shadow while the filter —
/// kept outside any opacity layer — fades its own result in step, so that
/// what is on screen is still a plain cross-fade from the page to the
/// finished glass.
///
/// Only the outermost surface under a host is offered the fade. A claim
/// stops the host fading *everything* under it, so the claimant has to be
/// the whole of what the host shows; a solid surface claims nothing and its
/// host fades it, and the glass inside it, as one.
class BackdropFade extends InheritedWidget {
  /// Publishes [handle] to the surfaces under [child].
  const BackdropFade({required this.handle, required super.child, super.key});

  /// Hides any fade above from the surfaces under [child].
  ///
  /// Every surface wraps its content in this, whether it claimed the fade
  /// or not: the fade belongs to the outermost surface under its host. A
  /// glass surface inside a claimed one would otherwise fade twice, and one
  /// inside a *solid* surface — an inline command list in a dialog — would
  /// take the fade away from the surface around it, which then would not
  /// fade at all.
  const BackdropFade.none({required super.child, super.key}) : handle = null;

  /// The fade on offer, or null for none.
  final BackdropFadeHandle? handle;

  /// The fade offered to [context], or null.
  static BackdropFadeHandle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BackdropFade>()?.handle;

  @override
  bool updateShouldNotify(BackdropFade oldWidget) =>
      !identical(handle, oldWidget.handle);
}

/// A fade that a [BackdropSurface] can take over from its [BackdropFadeHost].
class BackdropFadeHandle extends ChangeNotifier {
  /// Creates a handle on [opacity].
  BackdropFadeHandle(Animation<double> opacity)
    : _opacity = ProxyAnimation(opacity);

  final ProxyAnimation _opacity;
  int _claims = 0;

  /// The fade itself, from 0 (gone) to 1 (fully shown). The same object for
  /// the life of the handle, whatever the host animates it with.
  Animation<double> get opacity => _opacity;

  /// Whether a surface has taken the fade over.
  bool get claimed => _claims > 0;

  bool _disposed = false;

  /// Takes the fade over: the host stops applying it. Balance every call
  /// with [release].
  void claim() {
    if (_claims++ == 0 && !_disposed) notifyListeners();
  }

  /// Hands the fade back to the host.
  void release() {
    // A surface can outlive its host by a frame when both are removed.
    if (--_claims == 0 && !_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Fades [child] by [opacity] unless a [BackdropSurface] inside it claims
/// the fade — see [BackdropFade].
///
/// With nothing to claim it, this is a [FadeTransition].
class BackdropFadeHost extends StatefulWidget {
  /// Creates a host for [opacity].
  const BackdropFadeHost({
    required this.opacity,
    required this.child,
    super.key,
  });

  /// The fade to apply, or to hand to a surface.
  final Animation<double> opacity;

  /// The widget to fade.
  final Widget child;

  @override
  State<BackdropFadeHost> createState() => _BackdropFadeHostState();
}

class _BackdropFadeHostState extends State<BackdropFadeHost> {
  late final _handle = BackdropFadeHandle(widget.opacity);
  late final _hostOpacity = _UnclaimedOpacity(_handle);

  @override
  void didUpdateWidget(BackdropFadeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handle._opacity.parent = widget.opacity;
  }

  @override
  void dispose() {
    _handle._opacity.parent = null;
    _handle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The switch between fading here and fading in the surface is made by
    // the animation's value, not by rebuilding: a surface claims the fade
    // while it is being built, below this widget, when this widget can no
    // longer be rebuilt for the frame.
    return FadeTransition(
      opacity: _hostOpacity,
      child: BackdropFade(handle: _handle, child: widget.child),
    );
  }
}

/// A handle's fade while nobody has claimed it, and fully opaque once
/// somebody has.
class _UnclaimedOpacity extends Animation<double> {
  _UnclaimedOpacity(this._handle);

  final BackdropFadeHandle _handle;

  @override
  double get value => _handle.claimed ? 1 : _handle.opacity.value;

  @override
  AnimationStatus get status => _handle.opacity.status;

  @override
  void addListener(VoidCallback listener) {
    _handle.opacity.addListener(listener);
    _handle.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _handle.opacity.removeListener(listener);
    _handle.removeListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) =>
      _handle.opacity.addStatusListener(listener);

  @override
  void removeStatusListener(AnimationStatusListener listener) =>
      _handle.opacity.removeStatusListener(listener);
}

/// A floating surface over a filtered backdrop: [child] painted on top of
/// whatever is behind it after [filter], clipped to its shape, with its
/// [shadow] outside the clip.
///
/// It is what `Popover`, menus, `Tooltip` and `Dialog` paint glass with.
/// Unlike a bare [Backdrop] it takes part in entrance animations: under a
/// [BackdropFadeHost] it claims the fade (see [BackdropFade]), so the glass
/// stays glass while it fades in and out. Without a [filter] it adds nothing
/// but the optional shadow.
class BackdropSurface extends StatefulWidget {
  /// Creates a surface over a filtered backdrop.
  const BackdropSurface({
    required this.child,
    this.filter,
    this.tintOpacity = 0,
    this.borderRadius = BorderRadius.zero,
    this.clipper,
    this.shadow,
    super.key,
  });

  /// The filter applied to the backdrop; null applies none.
  final ImageFilter? filter;

  /// The opacity of the tint [child] lays over the filtered backdrop: the
  /// alpha of its fill.
  ///
  /// Only used while fading. The tint hides part of the backdrop, more of
  /// it as it fades in, so the filter's own fade is weighted by this to
  /// keep the whole a straight cross-fade — without it the blur runs ahead
  /// of the tint and a bright backdrop dips darker halfway.
  final double tintOpacity;

  /// The corners the filtered area is clipped to.
  final BorderRadiusGeometry borderRadius;

  /// The shape the filtered area is clipped to, in place of
  /// [borderRadius].
  final CustomClipper<Path>? clipper;

  /// A decoration painted around the surface, outside its clip: its
  /// shadow, as a `ShadowDecoration`, which paints nothing inside the
  /// shape. The clip that bounds the filter would cut a shadow painted by
  /// [child] off. It is painted after [child], so the filter does not
  /// sample it.
  final Decoration? shadow;

  /// The surface: its tint, border and content.
  final Widget child;

  @override
  State<BackdropSurface> createState() => _BackdropSurfaceState();
}

class _BackdropSurfaceState extends State<BackdropSurface> {
  BackdropFadeHandle? _claimed;

  void _sync(BackdropFadeHandle? offered) {
    final wanted = widget.filter == null ? null : offered;
    if (identical(wanted, _claimed)) return;
    _claimed?.release();
    _claimed = wanted?..claim();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync(BackdropFade.maybeOf(context));
  }

  @override
  void didUpdateWidget(BackdropSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(BackdropFade.maybeOf(context));
  }

  @override
  void dispose() {
    _claimed?.release();
    _claimed = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter;
    final fade = _claimed?.opacity;

    // Whatever this surface does with the fade, nothing inside it is
    // offered it. Always there, so the content keeps its place in the tree
    // when a filter comes or goes.
    Widget surface = BackdropFade.none(child: widget.child);
    if (filter != null) {
      if (fade == null) {
        surface = BackdropFilter(filter: filter, child: surface);
      } else {
        surface = AnimatedBuilder(
          animation: fade,
          child: FadeTransition(opacity: fade, child: surface),
          builder: (context, child) {
            // At fade t the tint covers t·tint of the backdrop. For the
            // rest to be the page fading into its filtered self, the
            // filter's share of what still shows has to be this.
            final t = fade.value;
            final tint = widget.tintOpacity.clamp(0.0, 1.0);
            final share = t >= 1 ? 1.0 : t * (1 - tint) / (1 - t * tint);
            final faded = Backdrop.faded(filter, share);
            return BackdropFilter(
              filter: faded ?? filter,
              enabled: faded != null,
              child: child,
            );
          },
        );
      }
      surface = widget.clipper != null
          ? ClipPath(clipper: widget.clipper, child: surface)
          : ClipRRect(borderRadius: widget.borderRadius, child: surface);
    }

    final shadow = widget.shadow;
    if (shadow == null) return surface;
    // Painted *after* the surface, not under it. The shadow only covers the
    // outside of the shape (see `ShadowDecoration`), so the order makes no
    // difference to what overlaps what — but a backdrop filter samples
    // everything painted before it, and a blur that reaches past the edge
    // would pull a shadow painted first back into the glass as a grey rim.
    Widget cast = DecoratedBox(decoration: shadow);
    if (fade != null) cast = FadeTransition(opacity: fade, child: cast);
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        surface,
        // A decorated box claims the taps inside its box.
        Positioned.fill(child: IgnorePointer(child: cast)),
      ],
    );
  }
}
