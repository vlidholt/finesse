import 'package:flutter/widgets.dart';
import 'package:una/src/icons/phosphor_icon.dart';
import 'package:una/src/icons/phosphor_icons_regular.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';

/// How a [RevealImage] appears once it has loaded.
enum ImageReveal {
  /// Material's image-loading pattern: the picture fades in quickly,
  /// starts over-exposed and colourless, and settles into its own
  /// exposure and then its full colour — as a photograph develops.
  exposure,

  /// A plain fade from the placeholder.
  fade,
}

/// An image that shows a placeholder while it loads and then reveals
/// itself, by default with Material's exposure effect.
///
/// ```dart
/// RevealImage.network(
///   'https://example.com/photo.jpg',
///   fit: BoxFit.cover,
///   semanticLabel: 'A lake at dawn',
/// )
/// ```
///
/// An image that is already in the cache — one put there with
/// [precache], or shown before — appears at once, with no reveal: the
/// effect is for a picture arriving, not for one scrolled back into view.
/// So an app that knows what comes next (the next card of a stack, the
/// next page of a feed) calls [precache] for it, and it is simply there.
///
/// The reveal follows the theme's motion (`Motion.of`): under reduced
/// motion it is a short fade, and under `Motion.none` there is none.
/// While loading, [placeholder] shows, by default a box in the theme's
/// muted colour; if loading fails, [errorBuilder] does, by default the
/// same box with a broken-image icon.
class RevealImage extends StatelessWidget {
  /// Shows [image].
  const RevealImage({
    required this.image,
    super.key,
    this.reveal = ImageReveal.exposure,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.placeholder,
    this.errorBuilder,
    this.filterQuality = FilterQuality.medium,
  });

  /// Shows the image at [url].
  RevealImage.network(
    String url, {
    super.key,
    double scale = 1,
    Map<String, String>? headers,
    this.reveal = ImageReveal.exposure,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.placeholder,
    this.errorBuilder,
    this.filterQuality = FilterQuality.medium,
  }) : image = NetworkImage(url, scale: scale, headers: headers);

  /// Shows the asset [name].
  RevealImage.asset(
    String name, {
    super.key,
    AssetBundle? bundle,
    String? package,
    this.reveal = ImageReveal.exposure,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.placeholder,
    this.errorBuilder,
    this.filterQuality = FilterQuality.medium,
  }) : image = AssetImage(name, bundle: bundle, package: package);

  /// The image to show.
  final ImageProvider image;

  /// How the image appears once loaded.
  final ImageReveal reveal;

  /// The image's width, as [Image.width].
  final double? width;

  /// The image's height, as [Image.height].
  final double? height;

  /// How the image fills its box, as [Image.fit].
  final BoxFit? fit;

  /// Where the image sits in its box, as [Image.alignment].
  final AlignmentGeometry alignment;

  /// What the image shows, for a screen reader.
  final String? semanticLabel;

  /// Whether the image is left out of the semantics tree (a decorative
  /// picture).
  final bool excludeFromSemantics;

  /// Shown while the image loads. Defaults to a box in the theme's muted
  /// colour.
  final Widget? placeholder;

  /// Shown when the image cannot be loaded. Defaults to the placeholder
  /// box with a broken-image icon.
  final ImageErrorWidgetBuilder? errorBuilder;

  /// The quality the image is scaled with, as [Image.filterQuality].
  final FilterQuality filterQuality;

  /// Starts loading [image] into the cache, so a [RevealImage] of it
  /// appears at once when it is built. The future completes when it has
  /// loaded (or failed; a failure is not reported).
  static Future<void> precache(BuildContext context, ImageProvider image) =>
      precacheImage(image, context, onError: (_, _) {});

  /// [precache] for the image at [url].
  static Future<void> precacheNetwork(BuildContext context, String url) =>
      precache(context, NetworkImage(url));

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.muted;
    final empty = placeholder ?? ColoredBox(color: background);
    return Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      filterQuality: filterQuality,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return _Reveal(
          // A new picture is revealed afresh.
          key: ObjectKey(image),
          loaded: frame != null,
          reveal: reveal,
          placeholder: empty,
          width: width,
          height: height,
          child: child,
        );
      },
      errorBuilder:
          errorBuilder ??
          (context, error, stackTrace) => SizedBox(
            width: width,
            height: height,
            child: ColoredBox(
              color: background,
              child: Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.imageBroken,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ),
          ),
    );
  }
}

/// The placeholder, then the picture developing over it.
class _Reveal extends StatefulWidget {
  const _Reveal({
    required this.loaded,
    required this.reveal,
    required this.placeholder,
    required this.width,
    required this.height,
    required this.child,
    super.key,
  });

  final bool loaded;
  final ImageReveal reveal;
  final Widget placeholder;
  final double? width;
  final double? height;
  final Widget child;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);
  bool _started = false;
  bool _exposure = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStart();
  }

  @override
  void didUpdateWidget(_Reveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeStart();
  }

  void _maybeStart() {
    if (_started || !widget.loaded) return;
    _started = true;
    final motion = Motion.of(context);
    // Under reduced motion the picture still fades; it does not develop.
    _exposure = widget.reveal == ImageReveal.exposure && !motion.reduced;
    _controller.duration = _exposure ? motion.slow * 4 : motion.slow;
    if (_controller.duration == Duration.zero) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loaded) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.placeholder,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        if (t >= 1) return child!;
        return Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(child: widget.placeholder),
            ColorFiltered(
              colorFilter: ColorFilter.matrix(
                _exposure ? _developing(t) : _fading(t),
              ),
              child: child,
            ),
          ],
        );
      },
    );
  }

  /// A plain fade: the alpha alone.
  static List<double> _fading(double t) {
    final a = Curves.easeOut.transform(t);
    return [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, a, 0, //
    ];
  }

  /// Material's three overlapping steps: opacity over the first 40%,
  /// exposure settling over the first 70%, saturation over the whole.
  static List<double> _developing(double t) {
    double phase(double end) =>
        Curves.easeOut.transform((t / end).clamp(0.0, 1.0));
    final alpha = phase(.4);
    // How far the picture is pushed towards white: half way at first.
    final exposure = .5 * (1 - phase(.7));
    final saturation = phase(1);

    // Saturation, with Rec. 709 luminance weights.
    const r = .2126;
    const g = .7152;
    const b = .0722;
    final s = saturation;
    final i = 1 - saturation;
    final sat = [
      [r * i + s, g * i, b * i],
      [r * i, g * i + s, b * i],
      [r * i, g * i, b * i + s],
    ];
    // Then exposure: c' = (1 - e)·c + e·white.
    final keep = 1 - exposure;
    final lift = exposure * 255;
    return [
      for (final row in sat) ...[
        row[0] * keep,
        row[1] * keep,
        row[2] * keep,
        0,
        lift,
      ],
      0, 0, 0, alpha, 0, //
    ];
  }
}
