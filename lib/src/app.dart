// ignore_for_file: lines_longer_than_80_chars

import 'package:finesse/src/components/scroll_area.dart';
import 'package:finesse/src/components/toast.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/cross_fade_theme.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/theme_scope.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/mouse_area.dart';
import 'package:finesse/src/utils/mouse_cursor_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;

/// Which of [FinesseApp.theme] and [FinesseApp.darkTheme] the app uses.
enum ThemeMode {
  /// Follow the platform's brightness setting.
  system,

  /// Always use [FinesseApp.theme].
  light,

  /// Always use [FinesseApp.darkTheme], or [FinesseApp.theme] when it is null.
  dark,
}

/// The kind of app that [FinesseApp] builds.
enum FinesseAppType {
  /// The standard finesse app: a [WidgetsApp] with finesse defaults. Used by
  /// [FinesseApp.new] and [FinesseApp.router].
  standard,

  /// Calls [FinesseApp.appBuilder], so you can build your own app widget, for
  /// example a `MaterialApp`. Used by [FinesseApp.custom].
  custom,
}

/// The root widget of a finesse app.
///
/// It provides the [Theme], the localizations and the toaster. Below them
/// it builds a [WidgetsApp], or calls [appBuilder] for [FinesseApp.custom].
///
/// finesse does not depend on Material or Cupertino. To use their widgets in the
/// same app, wrap them in a `FinesseMaterial` from `package:finesse/material.dart`,
/// usually through [builder].
class FinesseApp extends StatefulWidget {
  /// Creates a [FinesseApp] providing a [Theme].
  const FinesseApp({
    super.key,
    this.navigatorKey,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.onNavigationNotification,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.initialRoute,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    this.shortcuts,
    this.actions,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.formFactor,
    this.restorationScopeId,
    this.scrollBehavior = const FinesseScrollBehavior(),
    this.pageRouteBuilder,
    this.themeCurve = Curves.linear,
    this.backgroundColor,
  }) : routeInformationProvider = null,
       routeInformationParser = null,
       routerDelegate = null,
       backButtonDispatcher = null,
       routerConfig = null,
       appBuilder = null,
       type = FinesseAppType.standard;

  /// Creates a [FinesseApp] that uses the [Router] instead of a [Navigator].
  const FinesseApp.router({
    super.key,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.formFactor,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.routerConfig,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.onNavigationNotification,
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior = const FinesseScrollBehavior(),
    this.themeCurve = Curves.linear,
    this.backgroundColor,
  }) : navigatorObservers = null,
       navigatorKey = null,
       onGenerateRoute = null,
       home = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       routes = null,
       initialRoute = null,
       pageRouteBuilder = null,
       appBuilder = null,
       type = FinesseAppType.standard;

  /// Creates a [FinesseApp] that provides the theme but calls [appBuilder] to
  /// build the app widget.
  ///
  /// Use it to put a `MaterialApp` or a `CupertinoApp` below the finesse theme.
  /// Theme it with `materialThemeFrom(Theme.of(context))` from
  /// `package:finesse/material.dart`, and return a [FinesseAppBuilder] from its
  /// `builder` to get the toaster.
  const FinesseApp.custom({
    super.key,
    required WidgetBuilder this.appBuilder,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.formFactor,
  }) : actions = null,
       backButtonDispatcher = null,
       onNavigationNotification = null,
       builder = null,
       color = null,
       debugShowCheckedModeBanner = false,
       home = null,
       initialRoute = null,
       locale = null,
       localeListResolutionCallback = null,
       localeResolutionCallback = null,
       localizationsDelegates = null,
       navigatorKey = null,
       navigatorObservers = null,
       onGenerateInitialRoutes = null,
       onGenerateRoute = null,
       onGenerateTitle = null,
       onUnknownRoute = null,
       pageRouteBuilder = null,
       restorationScopeId = null,
       routeInformationParser = null,
       routeInformationProvider = null,
       routerConfig = null,
       routerDelegate = null,
       routes = null,
       backgroundColor = null,
       scrollBehavior = const FinesseScrollBehavior(),
       shortcuts = null,
       showPerformanceOverlay = false,
       showSemanticsDebugger = false,
       supportedLocales = const <Locale>[Locale('en', 'US')],
       themeCurve = Curves.linear,
       title = '',
       type = FinesseAppType.custom;

  /// The type of app to use.
  ///
  /// If you are going to use only Finesse components, use
  /// [FinesseAppType.standard]. To build your own app widget, such as a
  /// `MaterialApp`, use [FinesseAppType.custom].
  final FinesseAppType type;

  /// Default visual properties, like colors fonts and shapes, for this app's
  /// finesse widgets.
  ///
  /// A second [darkTheme] [ThemeData] value, which is used to provide a
  /// dark version of the user interface can also be specified. [themeMode] will
  /// control which theme will be used if a [darkTheme] is provided.
  ///
  /// The default value of this property is the value of
  /// `ThemeData(brightness: Brightness.light)`.
  final ThemeData? theme;

  /// The [ThemeData] to use when a 'dark mode' is requested by the
  /// system.
  ///
  /// Some host platforms allow the users to select a system-wide 'dark mode',
  /// or the application may want to offer the user the ability to choose a
  /// dark theme just for this application. This is theme that will be used for
  /// such cases. [themeMode] will control which theme will be used.
  ///
  /// This theme should have a [ThemeData.brightness] set to
  /// [Brightness.dark].
  ///
  /// Uses [theme] instead when null. Defaults to the value of
  /// [ThemeData(brightness: Brightness.light)] when both [darkTheme] and
  /// [theme] are null.
  final ThemeData? darkTheme;

  /// Determines which theme will be used by the application if both [theme]
  /// and [darkTheme] are provided.
  ///
  /// If set to [ThemeMode.system], the choice of which theme to use will
  /// be based on the user's system preferences. If the
  /// [MediaQuery.platformBrightnessOf] is [Brightness.light], [theme] will be
  /// used. If it is [Brightness.dark], [darkTheme] will be used (unless it is
  /// null, in which case [theme] will be used.
  ///
  /// If set to [ThemeMode.light] the [theme] will always be used,
  /// regardless of the user's system preference.
  ///
  /// If set to [ThemeMode.dark] the [darkTheme] will be used
  /// regardless of the user's system preference. If [darkTheme] is null
  /// then it will fallback to using [theme].
  ///
  /// The default value is [ThemeMode.system].
  final ThemeMode? themeMode;

  /// The class of screen the theme is laid out for.
  ///
  /// Null, the default, follows the window: narrower than the theme's `md`
  /// breakpoint is [FormFactor.mobile], anything wider [FormFactor.desktop].
  /// Every `StyleTokens` carries metrics for both, so the same widgets come
  /// out with larger touch targets, larger body text and tighter page
  /// margins on a phone. Set it to pin one regardless of width.
  final FormFactor? formFactor;

  /// A key for the [Navigator] that the app creates.
  ///
  /// Use it to push or pop routes without a [BuildContext].
  /// See [WidgetsApp.navigatorKey].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The widget shown at the default route (`/`).
  ///
  /// See [WidgetsApp.home].
  final Widget? home;

  /// The application's top-level routing table.
  ///
  /// When a named route is pushed with [Navigator.pushNamed], the route name is
  /// looked up in this map. If the name is present, the associated
  /// [WidgetBuilder] is used to build a page with [pageRouteBuilder] (by
  /// default a short fade), including [Hero] animations, to the new route.
  ///
  /// See [WidgetsApp.routes].
  final Map<String, WidgetBuilder>? routes;

  /// The name of the first route to show, when the app starts with a
  /// [Navigator].
  ///
  /// See [WidgetsApp.initialRoute].
  final String? initialRoute;

  /// Builds a route for a named route that is not in [routes].
  ///
  /// See [WidgetsApp.onGenerateRoute].
  final RouteFactory? onGenerateRoute;

  /// Builds the first routes from [initialRoute].
  ///
  /// See [WidgetsApp.onGenerateInitialRoutes].
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// Builds a route when [onGenerateRoute] does not give one.
  ///
  /// See [WidgetsApp.onUnknownRoute].
  final RouteFactory? onUnknownRoute;

  /// Called when a [NavigationNotification] reaches the app.
  ///
  /// See [WidgetsApp.onNavigationNotification].
  final NotificationListenerCallback<NavigationNotification>?
  onNavigationNotification;

  /// The observers for the [Navigator] that the app creates.
  ///
  /// See [WidgetsApp.navigatorObservers].
  final List<NavigatorObserver>? navigatorObservers;

  /// Gives route information to the [Router]. Used by [FinesseApp.router].
  ///
  /// See [WidgetsApp.routeInformationProvider].
  final RouteInformationProvider? routeInformationProvider;

  /// Parses route information into a configuration for [routerDelegate].
  /// Used by [FinesseApp.router].
  ///
  /// See [WidgetsApp.routeInformationParser].
  final RouteInformationParser<Object>? routeInformationParser;

  /// Builds the [Navigator] from the route configuration. Used by
  /// [FinesseApp.router].
  ///
  /// See [WidgetsApp.routerDelegate].
  final RouterDelegate<Object>? routerDelegate;

  /// Tells the [Router] when the system back button is pressed. Used by
  /// [FinesseApp.router].
  ///
  /// See [WidgetsApp.backButtonDispatcher].
  final BackButtonDispatcher? backButtonDispatcher;

  /// A single object that holds the router delegates, as an alternative to
  /// [routeInformationProvider], [routeInformationParser], [routerDelegate] and
  /// [backButtonDispatcher]. Used by [FinesseApp.router].
  ///
  /// See [WidgetsApp.routerConfig].
  final RouterConfig<Object>? routerConfig;

  /// The [PageRoute] generator callback used when the app is navigated to a
  /// named route.
  ///
  /// A [PageRoute] represents the page in a [Navigator], so that it can
  /// correctly animate between pages, and to represent the "return value" of
  /// a route (e.g. which button a user selected in a modal dialog).
  ///
  /// Defaults to a short fade. Pass a `MaterialPageRoute` or a
  /// `CupertinoPageRoute` here for their platform transitions, such as the
  /// iOS back swipe.
  ///
  /// The [PageRouteFactory] type is generic, meaning the provided function must
  /// itself be generic. For example (with special emphasis on the `<T>` at the
  /// start of the closure):
  ///
  /// ```dart
  /// pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) => PageRouteBuilder<T>(
  ///   settings: settings,
  ///   pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => builder(context),
  /// ),
  /// ```
  final PageRouteFactory? pageRouteBuilder;

  /// Wraps the widget below the [Navigator] or [Router].
  ///
  /// Use it to insert widgets above every route, such as an inherited widget.
  /// The child it receives already contains the toaster.
  /// See [WidgetsApp.builder].
  final TransitionBuilder? builder;

  /// A one-line description of the app, used by the operating system, for
  /// example in the task switcher.
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String title;

  /// Builds the [title] from a context that has the app's [Localizations].
  /// Use it to localize the title.
  ///
  /// This value is passed unmodified to [WidgetsApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// The primary color of the app, used by the operating system, for example
  /// in the task switcher. Defaults to blue.
  ///
  /// See [WidgetsApp.color].
  final Color? color;

  /// The initial locale of the app. When null, the app uses the system locale.
  ///
  /// See [WidgetsApp.locale].
  final Locale? locale;

  /// Extra localization delegates for the app.
  ///
  /// The app always adds the finesse and widgets delegates after these. Add
  /// `GlobalMaterialLocalizations.delegate` and
  /// `GlobalCupertinoLocalizations.delegate` here for Material or Cupertino
  /// widgets, or wrap them in a `FinesseMaterial`, which adds them. See [WidgetsApp.localizationsDelegates].
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Selects the app locale from the list of system locales.
  ///
  /// See [WidgetsApp.localeListResolutionCallback].
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// Selects the app locale from one system locale, when
  /// [localeListResolutionCallback] is null.
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// The locales that the app supports. Defaults to `en_US`.
  ///
  /// See [WidgetsApp.supportedLocales].
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  final Iterable<Locale> supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/debugging/#performanceoverlay>
  final bool showPerformanceOverlay;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool showSemanticsDebugger;

  /// Shows a "DEBUG" banner in debug mode. Defaults to false.
  ///
  /// See [WidgetsApp.debugShowCheckedModeBanner].
  final bool debugShowCheckedModeBanner;

  /// The default keyboard shortcuts for the app. When null, the app uses
  /// [WidgetsApp.defaultShortcuts].
  ///
  /// {@tool snippet}
  /// This example shows how to add a single shortcut for
  /// LogicalKeyboardKey.select to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [FinesseApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return FinesseApp(
  ///     shortcuts: <ShortcutActivator, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       const SingleActivator(LogicalKeyboardKey.select):
  ///         const ActivateIntent(),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [WidgetsApp.shortcuts], which this value is passed to.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// The default actions for the app. When null, the app uses
  /// [WidgetsApp.defaultActions].
  ///
  /// {@tool snippet}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [FinesseApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return FinesseApp(
  ///     actions: <Type, Action<Intent>>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction: CallbackAction(
  ///         onInvoke: (Intent intent) {
  ///           // Do something here...
  ///           return null;
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [WidgetsApp.actions], which this value is passed to.
  final Map<Type, Action<Intent>>? actions;

  /// The restoration scope ID for the app's state restoration. When null,
  /// state restoration is off.
  ///
  /// See [WidgetsApp.restorationScopeId].
  final String? restorationScopeId;

  /// How [Scrollable] widgets in the app behave. Defaults to
  /// [FinesseScrollBehavior].
  ///
  /// See also:
  ///
  ///  * [ScrollConfiguration], which controls how [Scrollable] widgets behave
  ///    in a subtree.
  final ScrollBehavior scrollBehavior;

  /// The curve of the cross-fade from one [ThemeData] to another (see
  /// [CrossFadeTheme]), defaults to [Curves.linear].
  final Curve themeCurve;

  /// A custom app widget builder.
  final WidgetBuilder? appBuilder;

  /// {@macro FinesseAppBuilder.backgroundColor}
  final Color? backgroundColor;

  @override
  State<FinesseApp> createState() => _AppState();
}

class _AppState extends State<FinesseApp> {
  final heroController = HeroController();

  bool get usesRouter =>
      widget.routerDelegate != null || widget.routerConfig != null;

  /// The app's own delegates, followed by finesse's and the widgets layer's.
  Iterable<LocalizationsDelegate<dynamic>>
  get effectiveLocalizationsDelegates sync* {
    final localizationsDelegates = widget.localizationsDelegates;
    if (localizationsDelegates != null) {
      yield* localizationsDelegates;
    }
    yield GlobalFinesseLocalizations.delegate;
    yield GlobalWidgetsLocalizations.delegate;
  }

  @override
  void dispose() {
    heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: widget.scrollBehavior,
      child: HeroControllerScope(
        controller: heroController,
        // Applied at once, with the previous frame faded out over it:
        // interpolating the theme instead rebuilds the whole app on every
        // frame of the transition.
        child: CrossFadeTheme(
          data: theme(context),
          curve: widget.themeCurve,
          child: MouseAreaSurface(
            child: MouseCursorProvider(
              child: Builder(
                builder: _buildApp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // One instance, not one per build: constructing a `ThemeData` derives
  // every component theme, and a new one each time is also a miss in the
  // form-factor cache and a full comparison in `AnimatedTheme`.
  static final ThemeData _defaultLightTheme = ThemeData(
    brightness: Brightness.light,
  );

  ThemeData get effectiveLightTheme => widget.theme ?? _defaultLightTheme;

  ThemeData? get effectiveDarkTheme => widget.darkTheme;

  ThemeData theme(BuildContext context) {
    final mode = widget.themeMode ?? ThemeMode.system;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final useDarkStyle =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system && platformBrightness == Brightness.dark);

    final data = () {
      late ThemeData result;
      final lightTheme = effectiveLightTheme;
      if (useDarkStyle) {
        result = effectiveDarkTheme ?? lightTheme;
      } else {
        result = lightTheme;
      }
      return result;
    }();
    final formFactor =
        widget.formFactor ??
        (MediaQuery.sizeOf(context).width < data.breakpoints.md.value
            ? FormFactor.mobile
            : FormFactor.desktop);
    return data.withFormFactor(formFactor);
  }

  Widget _builder(BuildContext context, Widget? child) {
    return FinesseAppBuilder(
      backgroundColor: widget.backgroundColor,
      builder: widget.builder,
      child: child,
    );
  }

  Widget _buildApp(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.type) {
      case FinesseAppType.standard:
        if (usesRouter) {
          return DefaultStyles(
            data: theme,
            child: WidgetsApp.router(
              key: GlobalObjectKey(this),
              routeInformationProvider: widget.routeInformationProvider,
              routeInformationParser: widget.routeInformationParser,
              routerDelegate: widget.routerDelegate,
              routerConfig: widget.routerConfig,
              backButtonDispatcher: widget.backButtonDispatcher,
              onNavigationNotification: widget.onNavigationNotification,
              builder: _builder,
              title: widget.title,
              onGenerateTitle: widget.onGenerateTitle,
              color: widget.color ?? _defaultColor,
              locale: widget.locale,
              localeResolutionCallback: widget.localeResolutionCallback,
              localeListResolutionCallback: widget.localeListResolutionCallback,
              supportedLocales: widget.supportedLocales,
              showPerformanceOverlay: widget.showPerformanceOverlay,
              showSemanticsDebugger: widget.showSemanticsDebugger,
              debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
              shortcuts: widget.shortcuts,
              actions: widget.actions,
              restorationScopeId: widget.restorationScopeId,
              localizationsDelegates: effectiveLocalizationsDelegates,
              // A plain `Text` reads as body copy in the theme's own face,
              // the way it would under a Material `Scaffold`.
              textStyle: theme.textTheme.p.copyWith(
                color: theme.colorScheme.foreground,
              ),
            ),
          );
        }

        return DefaultStyles(
          data: theme,
          child: WidgetsApp(
            key: GlobalObjectKey(this),
            navigatorKey: widget.navigatorKey,
            navigatorObservers: widget.navigatorObservers!,
            home: widget.home,
            routes: widget.routes!,
            initialRoute: widget.initialRoute,
            onGenerateRoute: widget.onGenerateRoute,
            onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
            onUnknownRoute: widget.onUnknownRoute,
            onNavigationNotification: widget.onNavigationNotification,
            builder: _builder,
            title: widget.title,
            onGenerateTitle: widget.onGenerateTitle,
            color: widget.color ?? _defaultColor,
            locale: widget.locale,
            localeResolutionCallback: widget.localeResolutionCallback,
            localeListResolutionCallback: widget.localeListResolutionCallback,
            supportedLocales: widget.supportedLocales,
            showPerformanceOverlay: widget.showPerformanceOverlay,
            showSemanticsDebugger: widget.showSemanticsDebugger,
            debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
            shortcuts: widget.shortcuts,
            actions: widget.actions,
            restorationScopeId: widget.restorationScopeId,
            localizationsDelegates: effectiveLocalizationsDelegates,
            // A plain `Text` reads as body copy in the theme's own face,
            // the way it would under a Material `Scaffold`.
            textStyle: theme.textTheme.p.copyWith(
              color: theme.colorScheme.foreground,
            ),
            pageRouteBuilder:
                widget.pageRouteBuilder ??
                <T>(RouteSettings settings, WidgetBuilder builder) =>
                    FinessePageRoute<T>(settings: settings, builder: builder),
          ),
        );
      case FinesseAppType.custom:
        return DefaultStyles(
          data: theme,
          child: Builder(builder: widget.appBuilder!),
        );
    }
  }
}

/// Describes how [Scrollable] widgets behave for [FinesseApp]s.
///
/// Vertical scrollables get a [Scrollbar] on every platform but Android
/// and Fuchsia, where scrollbars are not shown.
///
/// See also:
///
///  * [ScrollBehavior], the default scrolling behavior extended by this class.
class FinesseScrollBehavior extends ScrollBehavior {
  /// Creates a FinesseScrollBehavior that decorates vertical [Scrollable]s with
  /// a [Scrollbar] based on the current platform.
  const FinesseScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (axisDirectionToAxis(details.direction)) {
      case Axis.horizontal:
        return child;
      case Axis.vertical:
        switch (getPlatform(context)) {
          case TargetPlatform.macOS:
          case TargetPlatform.iOS:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            return Scrollbar(controller: details.controller, child: child);
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
            return child;
        }
    }
  }
}

/// The page route [FinesseApp] uses by default: the new page fades in while
/// it moves a short way into place, and leaves the same way, faster.
///
/// On a phone it comes in from the end side — the right, in a left-to-right
/// layout — and the page under it gives way a little; a [fullscreenDialog]
/// rises from below. On a desktop, where a page is not a sheet of paper,
/// it only rises a few pixels. The timing is the theme's `Motion`: with
/// reduced motion the page only fades, and with `Motion.none` it is simply
/// there.
///
/// It is a quick transition, not a platform one: there is no back swipe.
/// For the platform transitions pass a `MaterialPageRoute` or a
/// `CupertinoPageRoute` to [FinesseApp.pageRouteBuilder].
class FinessePageRoute<T> extends PageRoute<T> {
  /// Creates a page route that builds its page with [builder].
  FinessePageRoute({
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
  });

  /// Builds the page.
  final WidgetBuilder builder;

  @override
  final bool maintainState;

  /// The motion tokens where the route was pushed, without making the
  /// navigator depend on them. Null before the route has a navigator.
  Motion? get _motion {
    final context = navigator?.context;
    if (context == null) return null;
    final motion = Theme.maybeOf(context, listen: false)?.motion;
    if (motion == null) return null;
    final reduce =
        context
            .getInheritedWidgetOfExactType<MediaQuery>()
            ?.data
            .disableAnimations ??
        false;
    return reduce ? motion.reduce() : motion;
  }

  @override
  Duration get transitionDuration {
    final motion = _motion;
    if (motion == null) return const Duration(milliseconds: 200);
    return motion.reduced ? motion.fast : motion.snappy.settleDuration;
  }

  // It leaves faster than it arrives.
  @override
  Duration get reverseTransitionDuration {
    final motion = _motion;
    if (motion == null) return const Duration(milliseconds: 200);
    return motion.reduced ? motion.fast : motion.normal;
  }

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  /// Whether the route over this one rises from below rather than coming
  /// in from the side: this page then stays where it is.
  bool _coveredByDialog = false;

  @override
  void didChangeNext(Route<dynamic>? nextRoute) {
    _coveredByDialog = nextRoute is PageRoute && nextRoute.fullscreenDialog;
    super.didChangeNext(nextRoute);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: builder(context),
    );
  }

  /// The animations the transition is drawn from. They depend only on the
  /// route's own animations and the motion curves, so they are made when
  /// those change — not in [buildTransitions], which the framework calls on
  /// every tick of either animation, for this page and the one it covers.
  _PageAnimations? _animations;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final motion = Motion.of(context);
    final mobile = Theme.of(context).formFactor == FormFactor.mobile;
    final side = Directionality.maybeOf(context) == TextDirection.rtl
        ? -1.0
        : 1.0;
    // In on the spring, and back out in a straight line from wherever it
    // is, so a pop in the middle of a push does not jump.
    final enter = motion.reduced ? motion.standard : motion.snappy.curve;
    var animations = _animations;
    if (animations == null ||
        !animations.isFor(
          animation,
          secondaryAnimation,
          enter: enter,
          giveWay: motion.standard,
        )) {
      animations = _animations = _PageAnimations(
        animation,
        secondaryAnimation,
        enter: enter,
        giveWay: motion.standard,
      );
    }
    // Where the page comes from: a fifth of the width from the end side on
    // a phone, from below for a dialog, and a short rise on a desktop.
    var slide = 0.0;
    var rise = 0.0;
    if (motion.reduced) {
      // Only the fade.
    } else if (fullscreenDialog) {
      rise = mobile ? 48 : motion.overlayTravel * 2;
    } else if (mobile) {
      slide = .2 * side;
    } else {
      rise = motion.overlayTravel * 2;
    }
    // Everything below is the same widget from one tick to the next, holding
    // the same animations: updating it is a handful of comparisons, and the
    // movement itself is paint.
    return FadeTransition(
      opacity: animations.fade,
      child: _PageShift(
        progress: animations.progress,
        covered: animations.covered,
        slide: slide,
        rise: rise,
        // The page under this one gives way as the next is pushed over it.
        giveWay: motion.reduced || !mobile || _coveredByDialog
            ? 0
            : -.06 * side,
        child: child,
      ),
    );
  }
}

/// The animations of one [FinessePageRoute]'s transition.
class _PageAnimations {
  _PageAnimations(
    this._animation,
    this._secondaryAnimation, {
    required Curve enter,
    required Curve giveWay,
  }) : _enter = enter,
       _giveWay = giveWay,
       progress = EntranceProgress(_animation, curve: enter),
       covered = _secondaryAnimation.drive(CurveTween(curve: giveWay));

  final Animation<double> _animation;
  final Animation<double> _secondaryAnimation;
  final Curve _enter;
  final Curve _giveWay;

  /// How far the page is into place: 0 where it comes from, 1 at rest.
  final EntranceProgress progress;

  /// How far the route above has come over this page.
  final Animation<double> covered;

  /// The page is readable well before it has settled.
  late final Animation<double> fade = progress.drive(const _FadeInBy(.6));

  /// Whether these were made for the given animations and curves.
  bool isFor(
    Animation<double> animation,
    Animation<double> secondaryAnimation, {
    required Curve enter,
    required Curve giveWay,
  }) =>
      identical(animation, _animation) &&
      identical(secondaryAnimation, _secondaryAnimation) &&
      enter == _enter &&
      giveWay == _giveWay;
}

/// A fade that is finished by [end] of the way: the page is readable well
/// before it has settled.
class _FadeInBy extends Animatable<double> {
  const _FadeInBy(this.end);

  final double end;

  @override
  double transform(double t) => (t / end).clamp(0.0, 1.0);
}

/// Moves a page along its route's transition, in paint.
///
/// While [progress] runs from 0 to 1 the page comes in from [slide] of its
/// own width to the side and [rise] logical pixels below; while [covered]
/// runs from 0 to 1 it moves [giveWay] of its width aside for the page
/// pushed over it.
///
/// A render object rather than an `AnimatedBuilder` around a `Transform`
/// inside a `LayoutBuilder`: the distance is a share of the page's width,
/// which is known at paint, so a tick costs no build and no layout.
class _PageShift extends SingleChildRenderObjectWidget {
  const _PageShift({
    required this.progress,
    required this.covered,
    required this.slide,
    required this.rise,
    required this.giveWay,
    super.child,
  });

  final Animation<double> progress;
  final Animation<double> covered;
  final double slide;
  final double rise;
  final double giveWay;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPageShift(
    progress: progress,
    covered: covered,
    slide: slide,
    rise: rise,
    giveWay: giveWay,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPageShift renderObject,
  ) {
    renderObject
      ..progress = progress
      ..covered = covered
      ..slide = slide
      ..rise = rise
      ..giveWay = giveWay;
  }
}

class _RenderPageShift extends RenderProxyBox {
  _RenderPageShift({
    required Animation<double> progress,
    required Animation<double> covered,
    required double slide,
    required double rise,
    required double giveWay,
  }) : _progress = progress,
       _covered = covered,
       _slide = slide,
       _rise = rise,
       _giveWay = giveWay;

  Animation<double> get progress => _progress;
  Animation<double> _progress;
  set progress(Animation<double> value) {
    if (identical(value, _progress)) return;
    if (attached) {
      _progress.removeListener(_moved);
      value.addListener(_moved);
    }
    _progress = value;
    _moved();
  }

  Animation<double> get covered => _covered;
  Animation<double> _covered;
  set covered(Animation<double> value) {
    if (identical(value, _covered)) return;
    if (attached) {
      _covered.removeListener(_moved);
      value.addListener(_moved);
    }
    _covered = value;
    _moved();
  }

  double get slide => _slide;
  double _slide;
  set slide(double value) {
    if (value == _slide) return;
    _slide = value;
    _moved();
  }

  double get rise => _rise;
  double _rise;
  set rise(double value) {
    if (value == _rise) return;
    _rise = value;
    _moved();
  }

  double get giveWay => _giveWay;
  double _giveWay;
  set giveWay(double value) {
    if (value == _giveWay) return;
    _giveWay = value;
    _moved();
  }

  /// Where the page is painted, relative to where it is laid out.
  Offset get _shift {
    final away = 1 - _progress.value;
    return Offset(
      (_slide * away + _giveWay * _covered.value) * size.width,
      _rise * away,
    );
  }

  /// The shift last painted, to tell a tick that moves the page from one
  /// that does not: a page on a desktop does not give way, yet the
  /// animation of the route over it still runs.
  Offset? _painted;

  void _moved() {
    if (hasSize && _shift == _painted) return;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(_moved);
    _covered.addListener(_moved);
  }

  @override
  void detach() {
    _progress.removeListener(_moved);
    _covered.removeListener(_moved);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final shift = _painted = _shift;
    super.paint(context, offset + shift);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: _shift,
      position: position,
      hitTest: (result, position) =>
          super.hitTestChildren(result, position: position),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final shift = _shift;
    transform.translateByDouble(shift.dx, shift.dy, 0, 1);
  }
}

// The WidgetsApp colour used for the app in the task switcher; Material's
// `Colors.blue`, which this default used to be.
const _defaultColor = Color(0xFF2196F3);

/// {@template FinesseAppBuilder}
/// The builder for an `*App` instance.
///
/// Must be placed in the builder of the `*App` widget.
/// {@endtemplate}
class FinesseAppBuilder extends StatelessWidget {
  /// {@macro FinesseAppBuilder}
  const FinesseAppBuilder({
    super.key,
    this.builder,
    this.child,
    this.backgroundColor,
  });

  /// Wraps the child with more widgets. See [WidgetsApp.builder].
  final TransitionBuilder? builder;

  /// The widget below this one, usually the app's [Navigator].
  final Widget? child;

  /// {@template FinesseAppBuilder.backgroundColor}
  /// The background color of the page, defaults to `Theme.of(context).colorScheme.background`.
  /// {@endtemplate}
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Why are we surrounding a builder with a builder?
    //
    // The widget.builder may contain code that invokes
    // Theme.of(), which should return the theme we selected
    // above in CrossFadeTheme. However, if we invoke
    // widget.builder() directly as the child of CrossFadeTheme
    // then there is no Context separating them, and the
    // widget.builder() will not find the theme. Therefore, we
    // surround widget.builder with yet another builder so that
    // a context separates them and Theme.of() correctly
    // resolves to the theme we passed to AnimatedTheme.
    return Builder(
      builder: (BuildContext context) {
        // The `Toaster` goes around the [child], inside [builder], so that
        // any `InheritedWidget` the [builder] introduces (such as a
        // `Directionality`) is inherited by the toasts.
        final effectiveChild = child != null ? Toaster(child: child!) : child;
        return ColoredBox(
          color: backgroundColor ?? Theme.of(context).colorScheme.background,
          child: builder?.call(context, effectiveChild) ?? effectiveChild,
        );
      },
    );
  }
}
