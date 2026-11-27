import 'package:flutter/widgets.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';

/// A widget that displays an avatar image with customizable size, shape, and
/// fallback.
///
/// The [Avatar] widget renders an image from a provided source, falling
/// back to [fallback] while the image loads, if it fails to load, or when
/// there is no source.
///
/// For assistive technology it is one image named [semanticLabel], whatever
/// it shows at the moment. Without a label it is decorative and reads as
/// nothing — the usual case, an avatar beside the name it belongs to — so
/// initials read while the picture loads do not change underfoot.
class Avatar extends StatelessWidget {
  /// Creates an avatar showing the image at [src], a URL or an asset path.
  ///
  /// A `String` starting with `http://` or `https://` is loaded with a
  /// [NetworkImage]; any other is loaded as an asset with [AssetImage], from
  /// [package] if set. Null or an empty string shows [fallback].
  const Avatar(
    this.src, {
    super.key,
    this.fallback,
    this.size,
    this.shape,
    this.backgroundColor,
    this.package,
    this.fit,
    this.semanticLabel,
  }) : image = null;

  /// Creates an avatar showing [image], for any other source: a file, memory
  /// bytes, a cached network image, or an SVG rasterised by an
  /// `ImageProvider`. Null shows [fallback].
  const Avatar.image(
    this.image, {
    super.key,
    this.fallback,
    this.size,
    this.shape,
    this.backgroundColor,
    this.fit,
    this.semanticLabel,
  }) : src = null,
       package = null;

  /// {@template Avatar.src}
  /// The URL or asset path of the image, for the default constructor.
  /// {@endtemplate}
  final String? src;

  /// {@template Avatar.image}
  /// The image, for [Avatar.image].
  /// {@endtemplate}
  final ImageProvider? image;

  /// {@template Avatar.fallback}
  /// The widget shown while the image loads, if it fails to load, or when
  /// there is no image. Usually initials or an icon.
  /// {@endtemplate}
  final Widget? fallback;

  /// {@template Avatar.size}
  /// The size of the avatar, overriding the theme default if specified.
  /// Defines both width and height; defaults to 40x40 if not set.
  /// {@endtemplate}
  final Size? size;

  /// {@template Avatar.shape}
  /// The shape of the avatar's border, overriding the theme default if
  /// specified.
  /// Typically a [CircleBorder], but can be customized
  /// (e.g., [RoundedRectangleBorder]).
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template Avatar.backgroundColor}
  /// The background color of the avatar, displayed behind the image.
  /// Overrides the theme's muted color if provided.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Avatar.package}
  /// The package name for asset images, used when [src] is an asset path.
  /// Optional and only relevant for asset-based images.
  /// {@endtemplate}
  final String? package;

  /// {@template Avatar.fit}
  /// How the image should fit within the avatar's bounds.
  /// Overrides the theme default if specified; affects image scaling and
  /// cropping.
  /// {@endtemplate}
  final BoxFit? fit;

  /// {@template Avatar.semanticLabel}
  /// What assistive technology reads for the avatar: who it shows. Null
  /// makes it decorative.
  /// {@endtemplate}
  final String? semanticLabel;

  /// The provider to load, or null when there is nothing to load.
  ImageProvider? get _image {
    if (image != null) return image;
    final value = src?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    return AssetImage(value, package: package);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final avatarTheme = theme.avatarTheme;
    final size = this.size ?? avatarTheme.size ?? const Size.square(40);
    final shape = this.shape ?? avatarTheme.shape ?? const CircleBorder();
    final backgroundColor =
        this.backgroundColor ??
        avatarTheme.backgroundColor ??
        theme.colorScheme.muted;
    final fit = this.fit ?? avatarTheme.fit;
    final fallback = this.fallback == null
        ? null
        : Center(child: this.fallback);
    final image = _image;

    final avatar = Container(
      width: size.width,
      height: size.height,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: ShapeDecoration(shape: shape, color: backgroundColor),
      child: image == null
          ? fallback
          : Image(
              image: image,
              width: size.width,
              height: size.height,
              fit: fit,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                // An image that is already there is simply shown. One that
                // arrives later fades in over the fallback, which fades out
                // under it — so a picture with transparent parts does not
                // end up with initials showing through.
                if (wasSynchronouslyLoaded) return child;
                final loaded = frame != null;
                final motion = Motion.of(context);
                return Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    if (fallback != null)
                      AnimatedOpacity(
                        opacity: loaded ? 0 : 1,
                        duration: motion.normal,
                        curve: motion.standard,
                        child: fallback,
                      ),
                    AnimatedOpacity(
                      opacity: loaded ? 1 : 0,
                      duration: motion.normal,
                      curve: motion.standard,
                      child: child,
                    ),
                  ],
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  fallback ?? const SizedBox.shrink(),
            ),
    );
    // The same widget with a label or without, so the avatar keeps its
    // state (an image that has loaded) when one comes or goes.
    return Semantics(
      label: semanticLabel,
      image: semanticLabel == null ? null : true,
      excludeSemantics: true,
      child: avatar,
    );
  }
}
