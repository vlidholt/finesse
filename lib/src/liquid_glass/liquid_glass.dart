import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

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
import 'package:una/src/components/bar_button_scope.dart';
import 'package:una/src/liquid_glass/liquid_glass_theme.dart';
import 'package:una/src/theme/components/button.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/backdrop.dart';
import 'package:una/src/utils/scroll_edge_shader.dart';

/// Liquid Glass in una: setting it up, and asking whether a component
/// draws with it.
///
/// On iOS and macOS — natively and in a browser — una draws its
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
  /// app and una's frosted glass is drawn in its place.
  static Future<void> initialize() async {
    _quietPackageLogs();
    // A browser's scroll edge, so a bar that asks for it has it at once.
    if (!hasShaderFilters) unawaited(ScrollEdgeShader.load());
    try {
      await lg.LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);
    } on Object catch (error, stack) {
      _unavailable = true;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'una',
          context: ErrorDescription(
            'while loading the Liquid Glass shaders; una falls back to '
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

  /// Whether the renderer has shader image filters (Impeller), which the
  /// package's graduated blur needs. The web and Skia have none: there a
  /// bar that would be Liquid Glass is drawn solid instead (see `AppBar`).
  static bool get hasShaderFilters =>
      debugHasShaderFilters ?? ui.ImageFilter.isShaderFilterSupported;

  /// Stands in for the renderer's answer to [hasShaderFilters] in tests,
  /// which have no shader filters. Put it back with null.
  @visibleForTesting
  static bool? debugHasShaderFilters;

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

/// The package's theme for a una theme: its style and quality, its glow
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
    settings = withoutInvisibleBlur(settings);
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

/// [settings] without a blur too faint to see when there are no shader
/// filters (the web, Skia).
///
/// The iOS presets blur the page under the glass by 0.6, leaving the
/// frosting to the package's `frost`, which only its Impeller tier draws.
/// Its lighter tier still pushes a backdrop filter for that 0.6 — a copy of
/// the page under every capsule, bar and control, on every frame —
/// and a blur that faint changes nothing anyone sees. At 0 the surface
/// draws its tint, rim and highlights straight onto the page. An overlay,
/// which does need its blur there, gets one of its own
/// ([legibleOverlaySettings]).
@visibleForTesting
lg.GlassThemeSettings withoutInvisibleBlur(lg.GlassThemeSettings settings) {
  final blur = settings.blur;
  if (ui.ImageFilter.isShaderFilterSupported || blur == null || blur >= 1) {
    return settings;
  }
  return settings.copyWith(blur: 0);
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

/// Hands the una theme to the `liquid_glass_widgets` widgets below:
/// the package's own theme, and the Cupertino theme its widgets take their
/// accent and text style from.
///
/// Every una widget that builds a package widget puts one around it, so
/// none of them depends on what the app put above it.
class LiquidGlassBridge extends StatelessWidget {
  /// Bridges the ambient una theme to [child].
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

/// The app-wide part of Liquid Glass that `UnaApp` puts around its
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

/// A surface of Liquid Glass with una content on it: the material a
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
    this.clipBehavior = Clip.antiAlias,
    this.tint,
    this.blur,
    this.saturation,
    super.key,
  });

  /// The glass's own colour, over the page, in place of the theme's.
  ///
  /// `Glass` passes the tint of its level, so the same surface carries the
  /// same weight of colour on Liquid Glass as it does frosted.
  final Color? tint;

  /// The least the page under the glass is blurred, as a sigma; the
  /// theme's own blur when it is more.
  final double? blur;

  /// The least the page under the glass is saturated; the theme's own
  /// saturation when it is more.
  final double? saturation;

  /// Whether the surface sets any of its glass itself.
  bool get _ownsMaterial => tint != null || blur != null || saturation != null;

  /// The content.
  final Widget child;

  /// Whether the content is clipped to the glass. A bar's capsule is not:
  /// a badge on a button hangs over its edge, as on iOS 26.
  final Clip clipBehavior;

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
    // rim all but vanishes over a light page: an overlay keeps una's
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
    // One tree shape whether or not the fade is claimed, as in
    // `BackdropSurface`: a wrapper that came with the exit rebuilt the
    // surface's content from scratch as it left.
    final opacity = fade ?? kAlwaysCompleteAnimation;
    return LiquidGlassBridge(
      child: AnimatedBuilder(
        animation: opacity,
        child: FadeTransition(opacity: opacity, child: child),
        builder: (context, content) {
          final quality = widget.overlay || widget.interactive
              ? lg.GlassQuality.premium
              : null;
          if (fade == null && !widget.overlay && !widget._ownsMaterial) {
            return lg.GlassContainer(
              shape: _shape,
              useOwnLayer: true,
              quality: quality,
              clipBehavior: widget.clipBehavior,
              child: content,
            );
          }
          var settings = lg.GlassThemeHelpers.resolveSettings(
            context,
            isOverlayPlatter: widget.overlay,
          );
          if (legible) settings = legibleOverlaySettings(settings, theme);
          if (widget._ownsMaterial) {
            settings = settings.copyWith(
              glassColor: widget.tint,
              blur: math.max(settings.blur, widget.blur ?? 0),
              saturation: math.max(
                settings.saturation,
                widget.saturation ?? 0,
              ),
            );
          }
          final visibility = opacity.value;
          return lg.GlassContainer(
            shape: _shape,
            useOwnLayer: true,
            quality: quality,
            clipBehavior: widget.clipBehavior,
            settings: visibility == 1
                ? settings
                : settings.copyWith(
                    visibility: settings.visibility * visibility,
                  ),
            child: content,
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
/// sharp. So the body is blurred as una's own floating glass is, and
/// lifted towards white in a light theme — the package's whiten veil,
/// strongest at the rim and lightest in the middle — so text reads over
/// a white page and a busy one alike. The rim is not darkened: over a
/// light page a darker meniscus framed a menu's rows as a white block.
lg.LiquidGlassSettings legibleOverlaySettings(
  lg.LiquidGlassSettings settings,
  ThemeData theme,
) {
  final dark = theme.brightness == Brightness.dark;
  return settings.copyWith(
    blur: math.max(settings.blur, theme.style.glassBlur / 2),
    saturation: math.max(settings.saturation, theme.style.glassSaturation),
    whitenStrength: math.max(settings.whitenStrength, dark ? 0 : .3),
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
    final theme = Theme.of(context);
    return LiquidGlassSurface(
      capsule: true,
      interactive: true,
      // A badge on a button hangs over the capsule's edge, as on iOS 26,
      // instead of being cut off by its round end. Nothing else needs the
      // clip: the buttons on it are round, so a press or hover fill stays
      // inside the capsule's ends.
      clipBehavior: Clip.none,
      child: BarButtonScope(
        variant: BarButtonScope.maybeOf(context)?.variant,
        style: ButtonTheme(
          decoration: theme.buttonDecoration(radius: theme.radii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: gap,
          children: children,
        ),
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
/// does not survive on every renderer. The blur is the package's
/// `ProgressiveBlur`, one graduated pass, which needs shader filters
/// (Impeller). Without them — every browser — a bar that would be Liquid
/// Glass is drawn solid by default (see `AppBar`); with
/// `LiquidGlassTheme.webScrollEdge` the edge is una's own shader over a
/// snapshot of the page under it, taken from the `Scaffold`'s body.
class LiquidGlassScrollEdge extends StatelessWidget {
  /// Creates the scroll edge of a bar, faded in by [visibility].
  const LiquidGlassScrollEdge({
    required this.color,
    this.visibility,
    this.maxSigma = 12,
    this.overhang = 24,
    this.fromBottom = false,
    super.key,
  });

  /// The page colour the content fades into.
  final Color color;

  /// How much of the edge shows; null is all of it.
  final Animation<double>? visibility;

  /// The sigma of the blur at the screen's edge.
  final double maxSigma;

  /// How far the edge reaches past the box it is given: below it, or
  /// above it when [fromBottom].
  final double overhang;

  /// Whether this is the bottom edge of the screen — under a docked bottom
  /// bar — blurred most at the bottom and fading upwards.
  final bool fromBottom;

  Widget _build(double t) {
    if (t <= 0) return const SizedBox.expand();
    // Without shader filters (every browser) the graduated blur is una's
    // own shader over a snapshot of the page; see
    // `LiquidGlassTheme.webScrollEdge`.
    if (!LiquidGlass.hasShaderFilters) {
      return ShaderScrollEdge(
        color: color,
        maxSigma: maxSigma,
        strength: t,
        fromBottom: fromBottom,
      );
    }
    final a = color.a * t;
    return Stack(
      fit: StackFit.expand,
      children: [
        lg.ProgressiveBlur(
          maxSigma: maxSigma * t,
          direction: fromBottom
              ? lg.ProgressiveBlurDirection.bottomToTop
              : lg.ProgressiveBlurDirection.topToBottom,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: fromBottom ? Alignment.bottomCenter : Alignment.topCenter,
              end: fromBottom ? Alignment.topCenter : Alignment.bottomCenter,
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
          top: fromBottom ? -overhang : 0,
          right: 0,
          bottom: fromBottom ? 0 : -overhang,
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
