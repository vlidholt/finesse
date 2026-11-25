import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
// The SDK's Cupertino, deprecated in favour of `cupertino_ui`: the package
// reads the SDK's `CupertinoTheme`, and one from `cupertino_ui` is another
// class it would not see.
// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show CupertinoTextThemeData, CupertinoTheme, CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
// Not in the package's barrel, but a public library of it (outside `src/`):
// the settings a `GlassContainer` would resolve, so a surface can fade them.
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart' as lg;

/// Liquid Glass in finesse: setting it up, and asking whether a component
/// draws with it.
///
/// On iOS and macOS — natively and in a browser — finesse draws its
/// navigation chrome, floating surfaces and lens controls with the
/// `liquid_glass_widgets` package, and its own frosted glass everywhere
/// else. `ThemeData(liquidGlass: LiquidGlassTheme(...))` changes where and
/// how; see [LiquidGlassTheme].
///
/// Call [initialize] before `runApp` so the shaders are in memory before
/// the first frame:
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await LiquidGlass.initialize();
///   runApp(const MyApp());
/// }
/// ```
///
/// Without it the package loads each shader the first time it is drawn,
/// and the first glass surfaces come in a frame or two late.
abstract final class LiquidGlass {
  static bool _unavailable = false;

  /// Loads the Liquid Glass shaders.
  ///
  /// If they fail to load, Liquid Glass is switched off for the life of the
  /// app and finesse's frosted glass is drawn in its place.
  static Future<void> initialize() async {
    _quietPackageLogs();
    try {
      await lg.LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);
    } on Object catch (error, stack) {
      _unavailable = true;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'finesse',
          context: ErrorDescription(
            'while loading the Liquid Glass shaders; finesse falls back to '
            'its frosted glass',
          ),
        ),
      );
    }
  }

  /// Whether Liquid Glass can be drawn at all: false once [initialize]
  /// failed to load the shaders.
  static bool get available => !_unavailable;

  static bool _logsQuiet = false;

  /// The package's progress messages, which it prints with `debugPrint` in
  /// every build mode and has no switch for. Its warnings and failures are
  /// not among them.
  static const _progressMessages = [
    '[LiquidGlass] Initializing library',
    '[LiquidGlass] Initialization complete',
    '[LightweightGlass] ✓ Created web shader',
  ];

  /// Keeps the package's progress messages out of the console (a browser's
  /// included, where they showed in release builds), by putting a filter
  /// in front of whatever `debugPrint` is at the time. Once per app, from
  /// [initialize]: an app that does not call it hears them (and a test,
  /// whose binding owns `debugPrint`, never does).
  static void _quietPackageLogs() {
    if (_logsQuiet) return;
    _logsQuiet = true;
    final print = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null && _progressMessages.any(message.startsWith)) {
        return;
      }
      print(message, wrapWidth: wrapWidth);
    };
  }

  /// Whether Liquid Glass was made unavailable, as a failed [initialize]
  /// does. For tests; put it back with false.
  @visibleForTesting
  static bool get debugUnavailable => _unavailable;

  @visibleForTesting
  static set debugUnavailable(bool value) => _unavailable = value;

  /// Whether [platform] is one where [LiquidGlassMode.auto] means Liquid
  /// Glass: iOS and macOS. On the web Flutter reports the browser's
  /// platform, so Safari on an iPhone or a Mac counts too.
  static bool isApplePlatform(TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  /// Whether a component under [context] draws with Liquid Glass.
  ///
  /// [mode] is the component theme's own setting, which wins over
  /// `ThemeData.liquidGlass.mode` when it is not null.
  static bool isActive(BuildContext context, [LiquidGlassMode? mode]) {
    final theme = Theme.of(context).liquidGlass;
    return resolve(
      mode: mode ?? theme.mode,
      platform: defaultTargetPlatform,
      highContrast:
          theme.respectSystemAccessibility &&
          (MediaQuery.maybeHighContrastOf(context) ?? false),
    );
  }

  /// The decision [isActive] makes, from its inputs.
  @visibleForTesting
  static bool resolve({
    required LiquidGlassMode mode,
    required TargetPlatform platform,
    bool highContrast = false,
  }) {
    if (_unavailable || highContrast) return false;
    return switch (mode) {
      LiquidGlassMode.never => false,
      LiquidGlassMode.always => true,
      LiquidGlassMode.auto => isApplePlatform(platform),
    };
  }
}

/// The package's theme for a finesse theme: its style and quality, its glow
/// in the scheme's primary, and the glass tinted with the scheme's bar
/// colour, under the caller's own settings.
final _glassThemes = Expando<lg.GlassThemeData>('liquid glass theme');

/// The Cupertino theme the package's widgets read their accent and text
/// from.
final _cupertinoThemes = Expando<CupertinoThemeData>('liquid glass cupertino');

/// The package's [lg.GlassThemeData] for [theme], derived once per theme.
lg.GlassThemeData glassThemeDataOf(ThemeData theme) =>
    _glassThemes[theme] ??= _deriveGlassTheme(theme);

lg.GlassThemeData _deriveGlassTheme(ThemeData theme) {
  final config = theme.liquidGlass;
  final base = switch (config.style) {
    lg.GlassStyle.classic => const lg.GlassThemeData.classic(),
    lg.GlassStyle.ios26 => const lg.GlassThemeData.ios26(),
    lg.GlassStyle.ios27 => const lg.GlassThemeData.ios27(),
  };
  final scheme = theme.colorScheme;
  final glow = lg.GlassGlowColors(primary: scheme.primary);

  lg.GlassThemeVariant variant(
    lg.GlassThemeVariant preset,
    Brightness brightness,
    lg.GlassThemeSettings? custom,
  ) {
    var settings = preset.settings ?? const lg.GlassThemeSettings();
    final presetColor = settings.glassColor;
    // Light glass takes the scheme's bar colour at the preset's strength. A
    // dark preset is a light wash over the page, which a dark bar colour
    // would turn into a dark one: there only the hue is borrowed, faintly.
    if (config.tintFromColorScheme && presetColor != null) {
      final bar = scheme.bar;
      settings = settings.copyWith(
        glassColor: brightness == Brightness.light
            ? bar.withValues(alpha: presetColor.a)
            : Color.lerp(presetColor, bar.withValues(alpha: presetColor.a), .2),
      );
    }
    if (custom != null) settings = _merge(settings, custom);
    return preset.copyWith(
      settings: settings,
      quality: config.quality,
      glowColors: glow,
    );
  }

  return lg.GlassThemeData(
    style: base.style,
    brightness: theme.brightness,
    light: variant(base.light, Brightness.light, config.light),
    dark: variant(base.dark, Brightness.dark, config.dark),
  );
}

lg.GlassThemeSettings _merge(lg.GlassThemeSettings a, lg.GlassThemeSettings b) {
  return a.copyWith(
    visibility: b.visibility,
    glassColor: b.glassColor,
    thickness: b.thickness,
    blur: b.blur,
    frost: b.frost,
    frostOpacity: b.frostOpacity,
    frostClamp: b.frostClamp,
    frostWeight: b.frostWeight,
    blurWeight: b.blurWeight,
    chromaticAberration: b.chromaticAberration,
    lightAngle: b.lightAngle,
    lightIntensity: b.lightIntensity,
    ambientStrength: b.ambientStrength,
    fresnelStrength: b.fresnelStrength,
    refractiveIndex: b.refractiveIndex,
    saturation: b.saturation,
    specularSharpness: b.specularSharpness,
    edgeAbsorption: b.edgeAbsorption,
    rimShade: b.rimShade,
    rimShadeEnds: b.rimShadeEnds,
    rimLight: b.rimLight,
    bodyShade: b.bodyShade,
    lensModel: b.lensModel,
    shadowElevation: b.shadowElevation,
    shadow: b.shadow,
  );
}

CupertinoThemeData _cupertinoThemeOf(ThemeData theme) =>
    _cupertinoThemes[theme] ??= CupertinoThemeData(
      brightness: theme.brightness,
      primaryColor: theme.colorScheme.primary,
      primaryContrastingColor: theme.colorScheme.primaryForeground,
      scaffoldBackgroundColor: theme.colorScheme.background,
      barBackgroundColor: theme.colorScheme.bar,
      textTheme: CupertinoTextThemeData(
        primaryColor: theme.colorScheme.primary,
        textStyle: theme.textTheme.p.copyWith(
          color: theme.colorScheme.foreground,
        ),
      ),
    );

/// Hands the finesse theme to the `liquid_glass_widgets` widgets below:
/// the package's own theme, and the Cupertino theme its widgets take their
/// accent and text style from.
///
/// Every finesse widget that builds a package widget puts one around it, so
/// none of them depends on what the app put above it.
class LiquidGlassBridge extends StatelessWidget {
  /// Bridges the ambient finesse theme to [child].
  const LiquidGlassBridge({required this.child, super.key});

  /// The package widgets.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoTheme(
      data: _cupertinoThemeOf(theme),
      child: lg.GlassTheme(data: glassThemeDataOf(theme), child: child),
    );
  }
}

/// The app-wide part of Liquid Glass that `FinesseApp` puts around its
/// navigator: the package's accessibility switch and, when the theme asks
/// for it, its adaptive quality.
class LiquidGlassAppScope extends StatelessWidget {
  /// Applies the theme's app-wide Liquid Glass options to [child].
  const LiquidGlassAppScope({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final config = Theme.of(context).liquidGlass;
    lg.LiquidGlassWidgets.respectSystemAccessibility =
        config.respectSystemAccessibility;
    if (!config.adaptiveQuality) return child;
    return lg.GlassAdaptiveScope(child: child);
  }
}

/// A surface of Liquid Glass with finesse content on it: the material a
/// bar, a popover or a dialog swaps its frosted glass for.
///
/// The content brings no tint, border or shadow of its own; the glass has
/// them. Under a `BackdropFadeHost` the surface claims the fade (see
/// `BackdropFade`) and fades the glass's own visibility with its content,
/// as a backdrop filter does not survive under an opacity layer.
class LiquidGlassSurface extends StatefulWidget {
  /// Creates a glass surface with corners of [radius].
  const LiquidGlassSurface({
    required this.child,
    this.radius = 0,
    this.topRadius,
    this.capsule = false,
    this.overlay = false,
    this.interactive = false,
    super.key,
  });

  /// The content.
  final Widget child;

  /// The corner radius, drawn as a continuous (superellipse) corner.
  final double radius;

  /// The radius of the top corners when they differ from the bottom ones,
  /// which then take [radius].
  final double? topRadius;

  /// Whether the surface is a capsule: fully rounded ends whatever its
  /// height.
  final bool capsule;

  /// Whether the surface floats over the page as an overlay (a menu, a
  /// dialog, a sheet, a toast): the package then renders it at its overlay
  /// quality.
  final bool overlay;

  /// Whether the glass lights up under the finger.
  final bool interactive;

  @override
  State<LiquidGlassSurface> createState() => _LiquidGlassSurfaceState();
}

class _LiquidGlassSurfaceState extends State<LiquidGlassSurface> {
  BackdropFadeHandle? _claimed;

  void _sync() {
    final offered = BackdropFade.maybeOf(context);
    if (identical(offered, _claimed)) return;
    _claimed?.release();
    _claimed = offered?..claim();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void dispose() {
    _claimed?.release();
    _claimed = null;
    super.dispose();
  }

  lg.LiquidShape get _shape {
    if (widget.capsule) {
      return const lg.LiquidRoundedSuperellipse(borderRadius: 9999);
    }
    final top = widget.topRadius;
    if (top != null && top != widget.radius) {
      return lg.LiquidVerticalRoundedSuperellipse(
        topRadius: top,
        bottomRadius: widget.radius,
      );
    }
    return lg.LiquidRoundedSuperellipse(borderRadius: widget.radius);
  }

  @override
  Widget build(BuildContext context) {
    final fade = _claimed?.opacity;
    final theme = Theme.of(context);
    Widget child = BackdropFade.none(child: widget.child);
    // Without shader filters the package draws its lighter glass, whose
    // rim all but vanishes over a light page: an overlay keeps finesse's
    // hairline there, so a menu over white still has an edge.
    final legible = widget.overlay && !ui.ImageFilter.isShaderFilterSupported;
    if (legible) {
      child = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(widget.topRadius ?? widget.radius),
              bottom: Radius.circular(widget.radius),
            ),
            side: BorderSide(color: overlayEdgeColor(theme)),
          ),
        ),
        child: child,
      );
    }
    return LiquidGlassBridge(
      child: Builder(
        builder: (context) {
          final quality = widget.overlay || widget.interactive
              ? lg.GlassQuality.premium
              : null;
          if (fade == null && !widget.overlay) {
            return lg.GlassContainer(
              shape: _shape,
              useOwnLayer: true,
              quality: quality,
              clipBehavior: Clip.antiAlias,
              child: child,
            );
          }
          var settings = lg.GlassThemeHelpers.resolveSettings(
            context,
            isOverlayPlatter: widget.overlay,
          );
          if (legible) settings = legibleOverlaySettings(settings, theme);
          Widget glass(double visibility, Widget content) => lg.GlassContainer(
            shape: _shape,
            useOwnLayer: true,
            quality: quality,
            clipBehavior: Clip.antiAlias,
            settings: visibility == 1
                ? settings
                : settings.copyWith(
                    visibility: settings.visibility * visibility,
                  ),
            child: content,
          );
          if (fade == null) return glass(1, child);
          return AnimatedBuilder(
            animation: fade,
            child: FadeTransition(opacity: fade, child: child),
            builder: (context, content) => glass(fade.value, content!),
          );
        },
      ),
    );
  }
}

/// The hairline an overlay of Liquid Glass keeps without shader filters:
/// the surfaces' own `ring-foreground/10`, a little stronger in the dark.
Color overlayEdgeColor(ThemeData theme) {
  final ink = theme.colorScheme.foreground;
  return ink.withValues(
    alpha: ink.a * (theme.brightness == Brightness.dark ? .16 : .1),
  );
}

/// [settings] for an overlay (a menu, a popover, a dialog) drawn without
/// shader filters — in a browser, or under Skia.
///
/// The iOS styles make an overlay legible with the package's frost, a
/// cloud only its full (Impeller) tier draws: its lighter tier keeps the
/// presets' near-zero blur and shows the page through the glass almost
/// sharp. So the body is blurred as finesse's own floating glass is, and
/// lifted towards white in a light theme — the package's whiten veil,
/// strongest at the rim and lightest in the middle — so text reads over
/// a white page and a busy one alike.
lg.LiquidGlassSettings legibleOverlaySettings(
  lg.LiquidGlassSettings settings,
  ThemeData theme,
) {
  final dark = theme.brightness == Brightness.dark;
  return settings.copyWith(
    blur: math.max(settings.blur, theme.style.glassBlur / 2),
    saturation: math.max(settings.saturation, theme.style.glassSaturation),
    whitenStrength: math.max(settings.whitenStrength, dark ? 0 : .3),
    edgeAbsorption: math.max(settings.edgeAbsorption, .08),
  );
}

/// Buttons in a bar on one capsule of Liquid Glass, as iOS 26 groups the
/// buttons at either end of a navigation bar.
class LiquidGlassBarGroup extends StatelessWidget {
  /// Puts [children] on one capsule, [gap] apart.
  const LiquidGlassBarGroup({
    required this.children,
    this.gap = 0,
    super.key,
  });

  /// The buttons.
  final List<Widget> children;

  /// The space between two of them.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      capsule: true,
      interactive: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: gap,
        children: children,
      ),
    );
  }
}

/// The top edge of a page under a Liquid Glass bar: the content scrolled
/// under it blurred more the nearer it is to the screen's edge, and faded
/// into the page colour, as iOS 26 softens a scroll edge.
///
/// It reaches [overhang] past the bottom of the box it is given, so the
/// content dissolves into the bar instead of meeting a line where the bar
/// ends; the box it sits in must not clip.
///
/// [visibility] shows it from 0 (nothing) to 1. The blur's strength is
/// what changes, not an opacity: a backdrop filter under an opacity layer
/// does not survive on every renderer. With shader filters (Impeller) the
/// blur is the package's `ProgressiveBlur`, one graduated pass. Without
/// them — the web, Skia — the package would blur uniformly and end on a
/// hard edge, which reads as a solid bar; there the blur is built from a
/// few nested bands instead, each blurring a little more of the top, in
/// steps too small to see.
class LiquidGlassScrollEdge extends StatelessWidget {
  /// Creates the scroll edge of a bar, faded in by [visibility].
  const LiquidGlassScrollEdge({
    required this.color,
    this.visibility,
    this.maxSigma = 12,
    this.overhang = 24,
    super.key,
  });

  /// The page colour the content fades into.
  final Color color;

  /// How much of the edge shows; null is all of it.
  final Animation<double>? visibility;

  /// The sigma of the blur at the screen's edge.
  final double maxSigma;

  /// How far the edge reaches below the box it is given.
  final double overhang;

  /// How many nested bands make the graduated blur without shader filters.
  static const _bands = 6;

  /// The sigma of each band of the graduated blur without shader filters,
  /// the band reaching furthest down first.
  ///
  /// Band `k` covers the top `(k + 1) / n` of the edge. Blurs compose as
  /// the root of the sum of their squares, so the slice `j` from the top,
  /// covered by bands `j` to `n - 1`, is blurred by
  /// `maxSigma × (n − j) / n`: a straight ramp down to a last step of
  /// `maxSigma / n`.
  @visibleForTesting
  static List<double> bandSigmas(double maxSigma, [int n = _bands]) => [
    for (var k = n - 1; k >= 0; k--)
      math.sqrt(
        math.pow(maxSigma * (n - k) / n, 2) -
            math.pow(maxSigma * (n - k - 1) / n, 2),
      ),
  ];

  Widget _blur(double sigma) {
    if (ui.ImageFilter.isShaderFilterSupported) {
      return lg.ProgressiveBlur(maxSigma: sigma);
    }
    final sigmas = bandSigmas(sigma);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < sigmas.length; i++)
          FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: (_bands - i) / _bands,
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: sigmas[i],
                  sigmaY: sigmas[i],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _build(double t) {
    if (t <= 0) return const SizedBox.expand();
    final a = color.a * t;
    return Stack(
      fit: StackFit.expand,
      children: [
        _blur(maxSigma * t),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Eased, so the fade has no knee where it ends.
              stops: const [0, .4, .75, 1],
              colors: [
                color.withValues(alpha: a * .8),
                color.withValues(alpha: a * .5),
                color.withValues(alpha: a * .15),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibility = this.visibility;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: -overhang,
          child: IgnorePointer(
            child: visibility == null
                ? _build(1)
                : _LayoutSafeBuilder(
                    animation: visibility,
                    builder: (context) => _build(visibility.value),
                  ),
          ),
        ),
      ],
    );
  }
}

/// An `AnimatedBuilder` for an animation that may change while the tree is
/// being laid out — a `SliverAppBar` moves its surface at layout — where a
/// rebuild cannot be asked for: that change is built after the frame, one
/// frame late, which a fading blur does not show.
class _LayoutSafeBuilder extends StatefulWidget {
  const _LayoutSafeBuilder({required this.animation, required this.builder});

  final Listenable animation;
  final WidgetBuilder builder;

  @override
  State<_LayoutSafeBuilder> createState() => _LayoutSafeBuilderState();
}

class _LayoutSafeBuilderState extends State<_LayoutSafeBuilder> {
  bool _deferred = false;

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant _LayoutSafeBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.animation, oldWidget.animation)) {
      oldWidget.animation.removeListener(_changed);
      widget.animation.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.animation.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      setState(() {});
      return;
    }
    if (_deferred) return;
    _deferred = true;
    scheduler.addPostFrameCallback((_) {
      _deferred = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
