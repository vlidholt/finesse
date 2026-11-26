import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/divider.dart';
import 'package:una/src/components/sheet.dart';
import 'package:una/src/components/skeleton.dart';
import 'package:una/src/components/tooltip.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/icons/phosphor_icons.dart';
import 'package:una/src/raw_components/focusable.dart';
import 'package:una/src/raw_components/portal.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/components/sheet.dart';
import 'package:una/src/theme/form_factor.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/border.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/gesture_detector.dart';
import 'package:una/src/utils/route_on_top.dart';
import 'package:una/src/utils/shadow.dart';

/// Which edge of the layout the sidebar sits on.
///
/// Directional: `start` is the left edge in LTR and the right edge in RTL.
enum SidebarSide {
  /// The start edge: left in LTR, right in RTL.
  start,

  /// The end edge: right in LTR, left in RTL.
  end,
}

/// The visual treatment of a [Sidebar], mirroring shadcn/ui's `variant`.
enum SidebarVariant {
  /// A full-height panel separated from the content by a hairline.
  sidebar,

  /// A detached, rounded panel floating inside the page.
  floating,

  /// The sidebar owns the page background and the *content* floats on it as
  /// a rounded card.
  inset,
}

/// How a [Sidebar] collapses, mirroring shadcn/ui's `collapsible`.
enum SidebarCollapsible {
  /// Slides fully off-screen.
  offcanvas,

  /// Shrinks to a rail of icons.
  icon,

  /// Does not collapse.
  none,
}

/// The size of a [SidebarMenuButton].
enum SidebarMenuButtonSize {
  /// A short row with smaller text, shadcn's `h-7`.
  sm,

  /// The default row, shadcn's `h-8`.
  regular,

  /// A tall row, shadcn's `h-12`.
  lg,
}

/// The visual variant of a [SidebarMenuButton].
enum SidebarMenuButtonVariant {
  /// Transparent until hovered.
  standard,

  /// Outlined against the page background.
  outline,
}

/// Controls the open state of a [Sidebar].
///
/// Desktop and mobile are independent, exactly as in shadcn/ui: [isOpen] is
/// the inline sidebar, [isMobileOpen] the modal sheet shown under the
/// breakpoint.
class SidebarController extends ChangeNotifier {
  /// Creates a controller. The desktop sidebar starts expanded when [isOpen]
  /// is true, the default. The mobile sheet starts closed.
  SidebarController({bool isOpen = true}) : _open = isOpen;

  bool _open;

  /// Whether the inline (desktop) sidebar is expanded.
  bool get isOpen => _open;

  /// Expands the inline sidebar.
  void open() => setOpen(true);

  /// Collapses the inline sidebar.
  void close() => setOpen(false);

  /// Expands the inline sidebar when [open] is true and collapses it
  /// otherwise.
  void setOpen(bool open) {
    if (_open == open) return;
    _open = open;
    notifyListeners();
  }

  bool _mobileOpen = false;

  /// Whether the mobile sheet is shown.
  bool get isMobileOpen => _mobileOpen;

  /// Shows the mobile sheet.
  void openMobile() => setMobileOpen(true);

  /// Hides the mobile sheet.
  void closeMobile() => setMobileOpen(false);

  /// Shows the mobile sheet when [open] is true and hides it otherwise.
  void setMobileOpen(bool open) {
    if (_mobileOpen == open) return;
    _mobileOpen = open;
    notifyListeners();
  }

  /// Flips the state for the given form factor.
  void toggle({required bool isMobile}) {
    isMobile ? setMobileOpen(!_mobileOpen) : setOpen(!_open);
  }
}

/// What a sidebar descendant needs to know about its host: the controller,
/// the form factor and the configuration of the [Sidebar] it sits in.
///
/// Obtained with [SidebarScope.of] — [SidebarTrigger] uses it to
/// toggle, menu widgets use it to render their collapsed (icon-rail) form.
class SidebarScope extends InheritedWidget {
  /// Creates a scope. [SidebarScaffold] builds one, so you rarely need to.
  const SidebarScope({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.inSheet,
    required this.open,
    required this.side,
    required this.variant,
    required this.collapsible,
    required this.collapsedWidth,
    required super.child,
  });

  /// The controller that holds the open state.
  final SidebarController controller;

  /// Whether the host layout is below the mobile breakpoint.
  final bool isMobile;

  /// Whether this subtree renders inside the mobile sheet.
  final bool inSheet;

  /// The open state this scope was built with.
  final bool open;

  /// The edge of the layout that the sidebar sits on.
  final SidebarSide side;

  /// The visual variant of the sidebar.
  final SidebarVariant variant;

  /// How the sidebar collapses.
  final SidebarCollapsible collapsible;

  /// The resolved icon-rail width, so descendants shrink to the same rail the
  /// sidebar animates to even when [Sidebar.collapsedWidth] overrides the
  /// theme.
  final double collapsedWidth;

  /// Whether descendants should render their icon-rail form.
  bool get collapsed =>
      !inSheet && !open && collapsible == SidebarCollapsible.icon;

  /// Flips the sidebar for the current form factor.
  void toggle() => controller.toggle(isMobile: isMobile);

  /// Returns the nearest scope, or null when there is none.
  static SidebarScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SidebarScope>();

  /// Returns the nearest scope.
  ///
  /// Asserts that there is one: a [SidebarScaffold] provides it, and so
  /// does a [Sidebar] used on its own.
  static SidebarScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'SidebarScope.of() found no SidebarScope. The sidebar widgets '
      '(SidebarMenuButton, SidebarGroup, SidebarTrigger…) belong inside a '
      'Sidebar, or under a SidebarScaffold.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(SidebarScope oldWidget) =>
      controller != oldWidget.controller ||
      isMobile != oldWidget.isMobile ||
      inSheet != oldWidget.inSheet ||
      open != oldWidget.open ||
      side != oldWidget.side ||
      variant != oldWidget.variant ||
      collapsible != oldWidget.collapsible ||
      collapsedWidth != oldWidget.collapsedWidth;
}

/// {@template SidebarScaffold}
/// Lays out a [Sidebar] next to the page content, mirroring shadcn/ui's
/// `SidebarProvider` + `SidebarInset`.
///
/// Above the `md` breakpoint the sidebar renders inline and collapses
/// according to its `collapsible` mode; below it the sidebar disappears and
/// [SidebarTrigger] (or the controller) presents it as a modal sheet. The
/// breakpoint is the theme's form factor: `FormFactor.mobile` is below it.
///
/// `⌘B` on an Apple platform, `Ctrl+B` elsewhere, toggles it — when nothing
/// that has the focus takes the key itself, and only while the scaffold is
/// showing and nothing, a dialog say, covers its route.
///
/// ```dart
/// SidebarScaffold(
///   sidebar: Sidebar(
///     header: ...,
///     children: [SidebarGroup(...)],
///   ),
///   child: page,
/// )
/// ```
/// {@endtemplate}
class SidebarScaffold extends StatefulWidget {
  /// {@macro SidebarScaffold}
  const SidebarScaffold({
    super.key,
    required this.sidebar,
    required this.child,
    this.controller,
    this.initiallyOpen = true,
    this.onOpenChanged,
    this.keyboardShortcut = true,
    this.borderRadius,
  });

  /// The sidebar configuration and content.
  final Sidebar sidebar;

  /// The page content next to the sidebar.
  final Widget child;

  /// An external controller for the open state.
  ///
  /// When null an internal one is created, seeded from [initiallyOpen].
  final SidebarController? controller;

  /// Whether the sidebar starts open. Ignored when [controller] is set.
  final bool initiallyOpen;

  /// Called whenever the desktop open state changes.
  final ValueChanged<bool>? onOpenChanged;

  /// Whether `⌘B` on an Apple platform, `Ctrl+B` elsewhere, toggles the
  /// sidebar.
  final bool keyboardShortcut;

  /// Rounds and clips the scaffold's corners.
  ///
  /// A scaffold usually fills the page, but one embedded in a rounded
  /// container (a demo, a card) needs its own clip or the sidebar's square
  /// surface covers the host's corners. Null means no clip at all.
  final BorderRadiusGeometry? borderRadius;

  @override
  State<SidebarScaffold> createState() => _SidebarScaffoldState();
}

class _SidebarScaffoldState extends State<SidebarScaffold> {
  SidebarController? _internalController;

  SidebarController get controller => widget.controller ?? _internalController!;

  late bool _lastOpen;
  bool _sheetShowing = false;

  /// The mobile drawer's route, captured when it is shown so it can be
  /// dismissed precisely — popping blindly would take down whatever the user
  /// pushed on top of it — and removed if this scaffold is disposed first.
  ModalRoute<void>? _sheetRoute;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = SidebarController(isOpen: widget.initiallyOpen);
    }
    _lastOpen = controller.isOpen;
    controller.addListener(_onControllerChanged);
    if (widget.keyboardShortcut) {
      FocusManager.instance.addLateKeyEventHandler(_onKeyEvent);
    }
  }

  @override
  void didUpdateWidget(SidebarScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _onControllerChanged,
      );
      controller.addListener(_onControllerChanged);
    }
    if (widget.keyboardShortcut != oldWidget.keyboardShortcut) {
      widget.keyboardShortcut
          ? FocusManager.instance.addLateKeyEventHandler(_onKeyEvent)
          : FocusManager.instance.removeLateKeyEventHandler(_onKeyEvent);
    }
  }

  @override
  void dispose() {
    if (widget.keyboardShortcut) {
      FocusManager.instance.removeLateKeyEventHandler(_onKeyEvent);
    }
    controller.removeListener(_onControllerChanged);
    // The drawer is a pushed route, so it would outlive its scaffold — the
    // reference unmounts it with the provider. Removed post-frame, since
    // dispose runs mid-teardown when the navigator cannot be mutated.
    final route = _sheetRoute;
    if (route != null && route.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.isActive) route.navigator?.removeRoute(route);
      });
    }
    _internalController?.dispose();
    super.dispose();
  }

  bool get _isMobile => Theme.of(context).formFactor == FormFactor.mobile;

  static bool get _apple => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => true,
    _ => false,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The reference renders the sheet only in its mobile branch, so growing
    // past the breakpoint unmounts it. Here it is a pushed route, which has
    // to be popped explicitly — after the frame, since this runs mid-build.
    if (!_isMobile && controller.isMobileOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isMobile && controller.isMobileOpen) {
          controller.closeMobile();
        }
      });
    }
  }

  /// The icon-rail width, resolved the same way [Sidebar] resolves it.
  double get _collapsedWidth =>
      widget.sidebar.collapsedWidth ??
      Theme.of(context).sidebarTheme.collapsedWidth ??
      48;

  /// Heard after the focus tree has passed on the key, so a focused
  /// widget that binds the same chord keeps it.
  KeyEventResult _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyB) {
      return KeyEventResult.ignored;
    }
    // One modifier per platform and no other with it: Control+B moves the
    // caret back in a Mac's text fields, and AltGr is reported as
    // Control+Alt on Windows.
    final keyboard = HardwareKeyboard.instance;
    final chord =
        !keyboard.isAltPressed &&
        !keyboard.isShiftPressed &&
        (_apple
            ? keyboard.isMetaPressed && !keyboard.isControlPressed
            : keyboard.isControlPressed && !keyboard.isMetaPressed);
    // Heard wherever the focus is: under a dialog, or in a part of the tree
    // that is not shown, the chord is someone else's.
    if (!chord || !mounted || !isShownOnTop(context)) {
      return KeyEventResult.ignored;
    }
    controller.toggle(isMobile: _isMobile);
    return KeyEventResult.handled;
  }

  void _onControllerChanged() {
    if (controller.isOpen != _lastOpen) {
      _lastOpen = controller.isOpen;
      widget.onOpenChanged?.call(controller.isOpen);
    }
    _syncMobileSheet();
    if (mounted) setState(() {});
  }

  void _syncMobileSheet() {
    if (!mounted) return;
    if (controller.isMobileOpen && !_sheetShowing) {
      _sheetShowing = true;
      _showMobileSheet();
    } else if (!controller.isMobileOpen && _sheetShowing) {
      _sheetShowing = false;
      final route = _sheetRoute;
      if (route != null && route.isActive) {
        // Animate out when the drawer is on top; remove silently when
        // something else is (its exit animation would play under the
        // covering route anyway).
        route.isCurrent
            ? route.navigator!.pop()
            : route.navigator!.removeRoute(route);
      }
    }
  }

  void _showMobileSheet() {
    final sidebar = widget.sidebar;
    final theme = Theme.of(context).sidebarTheme;
    final effectiveMobileWidth =
        sidebar.mobileWidth ?? theme.mobileWidth ?? 288;
    // Resolved here rather than by the sheet: the route is built under the
    // navigator, which need not share this subtree's text direction.
    final sheetSide = switch (sidebar.side) {
      SidebarSide.start => SheetSide.start,
      SidebarSide.end => SheetSide.end,
    }.resolve(Directionality.of(context));
    // The route can outlive this State (dispose removes it a frame later),
    // and its builder re-runs on MediaQuery changes in the meantime — so
    // everything it needs is captured here rather than read through `this`,
    // whose `context` and `widget` are gone after unmount.
    final controller = this.controller;
    final collapsedWidth = _collapsedWidth;
    showSheet<void>(
      context: context,
      side: sheetSide,
      builder: (sheetContext) {
        _sheetRoute = ModalRoute.of(sheetContext);
        return SidebarScope(
          controller: controller,
          isMobile: true,
          inSheet: true,
          open: true,
          side: sidebar.side,
          variant: sidebar.variant,
          collapsible: sidebar.collapsible,
          collapsedWidth: collapsedWidth,
          child: Sheet(
            style: SheetTheme(
              padding: EdgeInsets.zero,
              gap: 0,
              backgroundColor:
                  sidebar.backgroundColor ??
                  Theme.of(sheetContext).sidebarTheme.backgroundColor,
              constraints: BoxConstraints.tightFor(width: effectiveMobileWidth),
            ),
            showCloseButton: false,
            // The sidebar owns its scrolling; the sheet's own scroll view
            // would hand it unbounded height and break its Expanded column.
            scrollable: false,
            child: sidebar,
          ),
        );
      },
    ).whenComplete(() {
      // Runs for every way the route can go away — barrier tap, system back,
      // controller, dispose cleanup — so this is where the state resyncs.
      _sheetShowing = false;
      _sheetRoute = null;
      if (mounted && controller.isMobileOpen) controller.closeMobile();
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;
    final sidebar = widget.sidebar;
    final isMobile = _isMobile;
    final open = controller.isOpen;

    var content = widget.child;

    if (sidebar.variant == SidebarVariant.inset && !isMobile) {
      final margin = (sidebarTheme.insetMargin ?? const EdgeInsets.all(8))
          .resolve(
            Directionality.of(context),
          );
      final collapsed = !open;
      // `m-2 ml-0`, except the start margin comes back when the sidebar is
      // fully collapsed (`peer-data-[state=collapsed]:ml-2` with offcanvas).
      final restoreStart =
          collapsed && sidebar.collapsible == SidebarCollapsible.offcanvas;
      content = Container(
        margin: EdgeInsetsDirectional.only(
          start: restoreStart ? margin.left : 0,
          end: margin.right,
          top: margin.top,
          bottom: margin.bottom,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: ShadowDecoration.box(
          color: theme.colorScheme.background,
          borderRadius: sidebarTheme.insetBorderRadius,
          shadows: sidebarTheme.insetShadows ?? const [],
        ),
        child: content,
      );
      content = ColoredBox(
        color: sidebarTheme.backgroundColor ?? theme.colorScheme.sidebar,
        child: content,
      );
    }

    // The rail only accompanies the icon collapse: with offcanvas the edge
    // disappears along with the panel, so there is nothing to grab.
    if (!isMobile &&
        sidebar.rail &&
        sidebar.collapsible == SidebarCollapsible.icon) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: content),
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: sidebar.side == SidebarSide.start ? -8 : null,
            end: sidebar.side == SidebarSide.end ? -8 : null,
            width: 16,
            child: const _SidebarRail(),
          ),
        ],
      );
    }

    Widget body;
    if (isMobile) {
      body = content;
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: switch (sidebar.side) {
          SidebarSide.start => [sidebar, Expanded(child: content)],
          SidebarSide.end => [Expanded(child: content), sidebar],
        },
      );
    }

    if (widget.borderRadius != null) {
      body = ClipRRect(borderRadius: widget.borderRadius!, child: body);
    }

    return SidebarScope(
      controller: controller,
      isMobile: isMobile,
      inSheet: false,
      open: open,
      side: sidebar.side,
      variant: sidebar.variant,
      collapsible: sidebar.collapsible,
      collapsedWidth: _collapsedWidth,
      child: body,
    );
  }
}

/// {@template Sidebar}
/// A composable, collapsible side navigation panel.
///
/// Mirrors shadcn/ui's `Sidebar`. Always used inside a [SidebarScaffold],
/// which owns the open state and the responsive behaviour. Content is composed
/// from [SidebarGroup]s of [SidebarMenu]s, with optional [header] and
/// [footer] slots pinned outside the scrollable area.
/// {@endtemplate}
class Sidebar extends StatelessWidget {
  /// {@macro Sidebar}
  const Sidebar({
    super.key,
    this.side = SidebarSide.start,
    this.variant = SidebarVariant.sidebar,
    this.collapsible = SidebarCollapsible.offcanvas,
    this.header,
    this.footer,
    this.children = const [],
    this.rail = false,
    this.width,
    this.collapsedWidth,
    this.mobileWidth,
    this.backgroundColor,
    this.borderColor,
    this.scrollController,
  });

  /// The edge of the layout that the sidebar sits on. Defaults to
  /// [SidebarSide.start].
  final SidebarSide side;

  /// The visual variant. Defaults to [SidebarVariant.sidebar].
  final SidebarVariant variant;

  /// How the sidebar collapses. Defaults to [SidebarCollapsible.offcanvas].
  final SidebarCollapsible collapsible;

  /// Pinned above the scrollable content, shadcn's `SidebarHeader`.
  final Widget? header;

  /// Pinned below the scrollable content, shadcn's `SidebarFooter`.
  final Widget? footer;

  /// The scrollable content, typically [SidebarGroup]s.
  final List<Widget> children;

  /// Whether the sidebar shows a grab rail on its inner edge that toggles
  /// it, shadcn/ui's `SidebarRail`: the edge highlights under the pointer,
  /// shows a resize cursor, and a click collapses or expands the sidebar.
  ///
  /// Only takes effect with [SidebarCollapsible.icon] — with the other
  /// modes the edge leaves the screen together with the panel.
  final bool rail;

  /// {@template Sidebar.width}
  /// The expanded width, shadcn's `--sidebar-width` (16rem).
  /// {@endtemplate}
  final double? width;

  /// {@template Sidebar.collapsedWidth}
  /// The icon-rail width, shadcn's `--sidebar-width-icon` (3rem).
  /// {@endtemplate}
  final double? collapsedWidth;

  /// {@template Sidebar.mobileWidth}
  /// The width of the mobile sheet, shadcn's 18rem.
  /// {@endtemplate}
  final double? mobileWidth;

  /// {@template Sidebar.backgroundColor}
  /// The surface colour, defaults to the scheme's `sidebar`.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Sidebar.borderColor}
  /// The hairline colour, defaults to the scheme's `sidebarBorder`.
  /// {@endtemplate}
  final Color? borderColor;

  /// {@template Sidebar.scrollController}
  /// Controls the scrollable content area — the region holding [children],
  /// between [header] and [footer].
  ///
  /// Attach one to drive the sidebar's scroll position from outside: restore
  /// it, jump to the top, or bring a section into view (pairs with
  /// `Scrollable.ensureVisible` on a key inside the content).
  /// {@endtemplate}
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final scope = SidebarScope.maybeOf(context);
    // On its own — a `Scaffold`'s drawer, the content of a sheet, a panel
    // of a split view — the sidebar is its own host.
    if (scope == null) return _StandaloneSidebar(sidebar: this);
    return _buildIn(context, scope);
  }

  Widget _buildIn(BuildContext context, SidebarScope scope) {
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;

    final effectiveBackgroundColor =
        backgroundColor ??
        sidebarTheme.backgroundColor ??
        theme.colorScheme.sidebar;
    final effectiveForegroundColor =
        sidebarTheme.foregroundColor ?? theme.colorScheme.sidebarForeground;
    final effectiveBorderColor =
        borderColor ??
        sidebarTheme.borderColor ??
        theme.colorScheme.sidebarBorder;
    final effectiveWidth = width ?? sidebarTheme.width ?? 256;
    final effectiveCollapsedWidth =
        collapsedWidth ?? sidebarTheme.collapsedWidth ?? 48;
    final duration = sidebarTheme.duration ?? const Duration(milliseconds: 200);
    final curve = sidebarTheme.curve ?? Curves.linear;

    final column = _SidebarColumn(
      header: header,
      footer: footer,
      scrollController: scrollController,
      children: children,
    );

    // Base text and icon treatment for everything inside.
    var content = DefaultTextStyle.merge(
      style: TextStyle(color: effectiveForegroundColor),
      child: IconTheme.merge(
        data: IconThemeData(
          size: sidebarTheme.iconSize ?? 16,
          color: effectiveForegroundColor,
        ),
        child: column,
      ),
    );

    // Inside the mobile sheet the sidebar is just its column on its surface.
    if (scope.inSheet) {
      return ColoredBox(color: effectiveBackgroundColor, child: content);
    }

    final floating = variant == SidebarVariant.floating;
    final floatingMargin =
        (sidebarTheme.floatingMargin ?? const EdgeInsets.all(8)).resolve(
          Directionality.of(context),
        );

    // The icon rail keeps the content laid out at the expanded width and lets
    // the animated container clip it — the same overflow-hidden semantics the
    // reference gets from CSS. A header that doesn't fit the rail truncates
    // at the clip edge instead of throwing a RenderFlex overflow; the widgets
    // that *should* shrink (menu buttons) do so themselves via
    // `scope.collapsed`, independent of the width they are laid out at.
    if (collapsible == SidebarCollapsible.icon) {
      final innerWidth =
          effectiveWidth - (floating ? floatingMargin.horizontal : 0);
      content = OverflowBox(
        minWidth: innerWidth,
        maxWidth: innerWidth,
        alignment: AlignmentDirectional.centerStart,
        child: content,
      );
    }

    switch (variant) {
      case SidebarVariant.sidebar:
        content = DecoratedBox(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            border: BorderDirectional(
              start: side == SidebarSide.end
                  ? BorderSide(color: effectiveBorderColor)
                  : BorderSide.none,
              end: side == SidebarSide.start
                  ? BorderSide(color: effectiveBorderColor)
                  : BorderSide.none,
            ),
          ),
          child: content,
        );
      case SidebarVariant.floating:
        content = Padding(
          padding: floatingMargin,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShadowDecoration.box(
              color: effectiveBackgroundColor,
              borderRadius: sidebarTheme.floatingBorderRadius,
              border: Border.all(color: effectiveBorderColor),
              shadows: sidebarTheme.floatingShadows ?? const [],
            ),
            child: content,
          ),
        );
      case SidebarVariant.inset:
        content = ColoredBox(
          color: effectiveBackgroundColor,
          child: content,
        );
    }

    final open = scope.open;
    final double targetWidth;
    if (collapsible == SidebarCollapsible.none || open) {
      targetWidth = effectiveWidth;
    } else {
      targetWidth = switch (collapsible) {
        SidebarCollapsible.offcanvas => 0,
        // Floating and inset keep their outer margin around the icon rail:
        // `w-[calc(var(--sidebar-width-icon)+(--spacing(4)))]`.
        SidebarCollapsible.icon =>
          effectiveCollapsedWidth +
              (floating || variant == SidebarVariant.inset
                  ? floatingMargin.horizontal
                  : 0),
        SidebarCollapsible.none => effectiveWidth,
      };
    }

    // Offcanvas slides the fixed-width panel out; anchoring it to the inner
    // edge clips the outer part first, like the reference's `left: -width`.
    // Icon mode instead re-lays the content out at the animated width.
    if (collapsible == SidebarCollapsible.offcanvas) {
      content = OverflowBox(
        minWidth: effectiveWidth,
        maxWidth: effectiveWidth,
        alignment: side == SidebarSide.start
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: content,
      );
    }

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      width: targetWidth,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: content,
    );
  }
}

/// Hosts a [Sidebar] that has no [SidebarScaffold] above it, so that its
/// menu widgets find the [SidebarScope] they read.
///
/// The sidebar is shown the way the scaffold's own sheet shows it: its
/// column on its surface, expanded, as large as it is allowed to be. A
/// [SidebarTrigger] inside closes the panel the sidebar is in — a drawer, a
/// sheet — and does nothing in a page.
class _StandaloneSidebar extends StatefulWidget {
  const _StandaloneSidebar({required this.sidebar});

  final Sidebar sidebar;

  @override
  State<_StandaloneSidebar> createState() => _StandaloneSidebarState();
}

class _StandaloneSidebarState extends State<_StandaloneSidebar> {
  late final SidebarController _controller = SidebarController()
    ..setMobileOpen(true)
    ..addListener(_handleToggle);

  ModalRoute<Object?>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
  }

  void _handleToggle() {
    if (_controller.isMobileOpen) return;
    // It is always open; being asked to close means leaving.
    _controller.setMobileOpen(true);
    final route = _route;
    if (route is! PopupRoute || !route.isActive) return;
    if (route.isCurrent) {
      route.navigator?.pop();
    } else {
      route.navigator?.removeRoute(route);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sidebar = widget.sidebar;
    return SidebarScope(
      controller: _controller,
      isMobile: true,
      inSheet: true,
      open: true,
      side: sidebar.side,
      variant: sidebar.variant,
      collapsible: sidebar.collapsible,
      collapsedWidth:
          sidebar.collapsedWidth ??
          Theme.of(context).sidebarTheme.collapsedWidth ??
          48,
      child: Builder(
        builder: (context) =>
            sidebar._buildIn(context, SidebarScope.of(context)),
      ),
    );
  }
}

class _SidebarColumn extends StatelessWidget {
  const _SidebarColumn({
    required this.header,
    required this.footer,
    required this.scrollController,
    required this.children,
  });

  final Widget? header;
  final Widget? footer;
  final ScrollController? scrollController;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sidebarTheme = Theme.of(context).sidebarTheme;
    final contentGap = sidebarTheme.contentGap ?? 8;

    final spaced = <Widget>[
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(height: contentGap),
        children[i],
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: sidebarTheme.headerPadding ?? const EdgeInsets.all(8),
            child: header,
          ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: spaced,
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: sidebarTheme.footerPadding ?? const EdgeInsets.all(8),
            child: footer,
          ),
      ],
    );
  }
}

/// A ghost icon button that toggles the enclosing sidebar, shadcn/ui's
/// `SidebarTrigger`.
class SidebarTrigger extends StatefulWidget {
  /// Creates a trigger for the enclosing sidebar.
  const SidebarTrigger({super.key, this.icon, this.onPressed});

  /// The icon, defaults to `PanelLeft`.
  final Widget? icon;

  /// Called before the sidebar is toggled.
  final VoidCallback? onPressed;

  @override
  State<SidebarTrigger> createState() => _SidebarTriggerState();
}

class _SidebarTriggerState extends State<SidebarTrigger> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = SidebarScope.of(context);
    return Semantics(
      button: true,
      label: UnaLocalizations.of(context).navigation.toggleSidebar,
      child: UnaGestureDetector(
        mouseCursor: SystemMouseCursors.click,
        onHover: (value) => setState(() => hovered = value),
        onTap: () {
          widget.onPressed?.call();
          scope.toggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: hovered ? theme.colorScheme.accent : null,
            borderRadius: theme.radii.sm,
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              size: 16,
              color: hovered
                  ? theme.colorScheme.accentForeground
                  : theme.colorScheme.foreground,
            ),
            child: Center(
              child:
                  widget.icon ??
                  const PhosphorIcon(PhosphorIconsRegular.sidebarSimple),
            ),
          ),
        ),
      ),
    );
  }
}

/// The grab strip on the sidebar's inner edge, shadcn/ui's `SidebarRail`.
class _SidebarRail extends StatefulWidget {
  const _SidebarRail();

  @override
  State<_SidebarRail> createState() => _SidebarRailState();
}

class _SidebarRailState extends State<_SidebarRail> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = SidebarScope.of(context);
    final borderColor =
        theme.sidebarTheme.borderColor ?? theme.colorScheme.sidebarBorder;

    // The cursor points where clicking will move the edge, like the
    // reference: `[[data-side=left]_&]:cursor-w-resize` flipping to
    // `e-resize` when collapsed, and mirrored on the right side.
    final onLeft =
        (scope.side == SidebarSide.start) ==
        (Directionality.of(context) == TextDirection.ltr);
    final cursor = onLeft == scope.open
        ? SystemMouseCursors.resizeLeft
        : SystemMouseCursors.resizeRight;

    return UnaGestureDetector(
      mouseCursor: cursor,
      // The whole strip toggles, not just the 2px line it highlights —
      // deferring to the child left everything but the hairline untappable.
      behavior: HitTestBehavior.opaque,
      onHover: (value) => setState(() => hovered = value),
      onTap: scope.toggle,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 2,
          height: double.infinity,
          color: hovered ? borderColor : const Color(0x00000000),
        ),
      ),
    );
  }
}

/// {@template SidebarGroup}
/// A titled section of sidebar content, shadcn/ui's `SidebarGroup` +
/// `SidebarGroupLabel` + `SidebarGroupContent`.
/// {@endtemplate}
class SidebarGroup extends StatelessWidget {
  /// {@macro SidebarGroup}
  const SidebarGroup({
    super.key,
    this.label,
    this.action,
    required this.children,
  });

  /// The group heading; fades out in the icon rail.
  final Widget? label;

  /// A small trailing control on the heading row, shadcn's
  /// `SidebarGroupAction`.
  final Widget? action;

  /// The content of the group, typically a [SidebarMenu].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sidebarTheme = Theme.of(context).sidebarTheme;
    final scope = SidebarScope.of(context);
    final collapsed = scope.collapsed;

    final labelHeight = sidebarTheme.groupLabelHeight ?? 32;
    final duration = sidebarTheme.duration ?? const Duration(milliseconds: 200);
    final curve = sidebarTheme.curve ?? Curves.linear;

    return Padding(
      padding: sidebarTheme.groupPadding ?? const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            // `-mt-8 opacity-0`: the label slides away and the menu below
            // takes its place.
            AnimatedContainer(
              duration: duration,
              curve: curve,
              height: collapsed ? 0 : labelHeight,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: AnimatedOpacity(
                duration: duration,
                curve: curve,
                opacity: collapsed ? 0 : 1,
                child: OverflowBox(
                  minHeight: labelHeight,
                  maxHeight: labelHeight,
                  alignment: Alignment.bottomCenter,
                  child: _GroupLabelRow(label: label!, action: action),
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _GroupLabelRow extends StatelessWidget {
  const _GroupLabelRow({required this.label, this.action});

  final Widget label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;
    final labelStyle =
        sidebarTheme.groupLabelTextStyle ?? theme.textTheme.muted;

    return Padding(
      padding:
          sidebarTheme.groupLabelPadding ??
          const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle.merge(
              style: labelStyle,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              child: label,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// A vertical list of menu rows, shadcn/ui's `SidebarMenu`.
class SidebarMenu extends StatelessWidget {
  /// Creates a menu with the given rows.
  const SidebarMenu({super.key, required this.children});

  /// The rows, typically [SidebarMenuButton]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gap = Theme.of(context).sidebarTheme.menuGap ?? 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ],
    );
  }
}

/// {@template SidebarMenuButton}
/// A row in a sidebar menu, shadcn/ui's `SidebarMenuButton`.
///
/// Renders an icon, a label and an optional trailing widget; highlights with
/// the sidebar accent on hover, press and when [selected]. In the icon rail
/// it shrinks to a square and, when [tooltip] is given, shows the label as a
/// tooltip instead.
/// {@endtemplate}
class SidebarMenuButton extends StatefulWidget {
  /// {@macro SidebarMenuButton}
  const SidebarMenuButton({
    super.key,
    this.onPressed,
    this.leading,
    required this.child,
    this.trailing,
    this.selected = false,
    this.size = SidebarMenuButtonSize.regular,
    this.variant = SidebarMenuButtonVariant.standard,
    this.tooltip,
    this.focusNode,
    this.enabled = true,
  });

  /// Called when the row is tapped. Not called when [enabled] is false.
  final VoidCallback? onPressed;

  /// The icon at the start of the row.
  final Widget? leading;

  /// The label. Clipped, not wrapped, when space runs out.
  final Widget child;

  /// A badge or action at the end of the row; hidden in the icon rail.
  final Widget? trailing;

  /// Whether this row is the current one; keeps the accent highlight.
  final bool selected;

  /// The height and text size of the row. Defaults to
  /// [SidebarMenuButtonSize.regular].
  final SidebarMenuButtonSize size;

  /// The visual variant. Defaults to [SidebarMenuButtonVariant.standard].
  final SidebarMenuButtonVariant variant;

  /// Shown next to the icon rail when collapsed.
  final String? tooltip;

  /// The focus node of the row. When null, the row creates its own.
  final FocusNode? focusNode;

  /// Whether the row reacts to input. A disabled row is faded and cannot get
  /// focus. Defaults to true.
  final bool enabled;

  /// {@template SidebarMenuButton.height}
  /// Height of a menu button, shadcn's `h-8`.
  /// {@endtemplate}
  @override
  State<SidebarMenuButton> createState() => _SidebarMenuButtonState();
}

class _SidebarMenuButtonState extends State<SidebarMenuButton> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;
    final scope = SidebarScope.of(context);
    final collapsed = scope.collapsed;

    final duration = sidebarTheme.duration ?? const Duration(milliseconds: 200);
    final curve = sidebarTheme.curve ?? Curves.linear;

    final expandedHeight = switch (widget.size) {
      SidebarMenuButtonSize.sm => sidebarTheme.menuButtonHeightSm ?? 28,
      SidebarMenuButtonSize.regular => sidebarTheme.menuButtonHeight ?? 32,
      SidebarMenuButtonSize.lg => sidebarTheme.menuButtonHeightLg ?? 48,
    };

    // In the icon rail every size becomes a square that fills the rail's
    // inner width: `size-8! p-2!`.
    final groupPadding = (sidebarTheme.groupPadding ?? const EdgeInsets.all(8))
        .resolve(
          Directionality.of(context),
        );
    final collapsedSize = scope.collapsedWidth - groupPadding.horizontal;
    final iconSize = sidebarTheme.iconSize ?? 16;

    final height = collapsed ? collapsedSize : expandedHeight;
    final padding = collapsed
        ? EdgeInsets.symmetric(
            horizontal: math.max(0, (collapsedSize - iconSize) / 2),
          )
        : (sidebarTheme.menuButtonPadding ??
              const EdgeInsets.symmetric(horizontal: 8));

    final textStyle = switch (widget.size) {
      SidebarMenuButtonSize.sm =>
        sidebarTheme.menuButtonTextStyleSm ??
            sidebarTheme.menuButtonTextStyle ??
            theme.textTheme.small,
      _ => sidebarTheme.menuButtonTextStyle ?? theme.textTheme.small,
    };

    final accent = sidebarTheme.accentColor ?? theme.colorScheme.sidebarAccent;
    final accentForeground =
        sidebarTheme.accentForegroundColor ??
        theme.colorScheme.sidebarAccentForeground;
    final foreground =
        sidebarTheme.foregroundColor ?? theme.colorScheme.sidebarForeground;

    final highlighted =
        widget.enabled && (hovered || pressed || widget.selected);
    final contentColor = highlighted ? accentForeground : foreground;
    final radius = sidebarTheme.menuButtonBorderRadius ?? theme.radii.sm;
    final gap = sidebarTheme.menuButtonGap ?? 8;

    final outline = widget.variant == SidebarMenuButtonVariant.outline;
    final borderColor =
        sidebarTheme.borderColor ?? theme.colorScheme.sidebarBorder;

    final ringColor = sidebarTheme.ringColor ?? theme.colorScheme.sidebarRing;
    final ringWidth = sidebarTheme.ringWidth ?? 2;

    // Every fixed-width part after the icon animates to zero on the same
    // timeline as the button's width, so at any point of the collapse the
    // row's minimum width fits the animated bounds — a plain SizedBox gap
    // (or an instantly-dropped trailing) overflows the 16px inner width of
    // the 32px square.
    Widget row = Row(
      children: [
        if (widget.leading != null) ...[
          IconTheme.merge(
            data: IconThemeData(size: iconSize, color: contentColor),
            child: widget.leading!,
          ),
          AnimatedContainer(
            duration: duration,
            curve: curve,
            width: collapsed ? 0 : gap,
          ),
        ],
        Expanded(
          child: DefaultTextStyle.merge(
            style: textStyle.copyWith(
              color: contentColor,
              fontWeight: widget.selected ? FontWeight.w500 : null,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            child: widget.child,
          ),
        ),
        // The reference hides badges and actions in the icon rail; here they
        // shrink away instead of vanishing, for the same fits-at-every-frame
        // reason.
        if (widget.trailing != null)
          ClipRect(
            child: AnimatedAlign(
              duration: duration,
              curve: curve,
              alignment: AlignmentDirectional.centerEnd,
              widthFactor: collapsed ? 0 : 1,
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: gap),
                child: IconTheme.merge(
                  data: IconThemeData(size: iconSize, color: contentColor),
                  child: DefaultTextStyle.merge(
                    style: textStyle.copyWith(color: contentColor),
                    child: widget.trailing!,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.leading == null && collapsed) {
      // Nothing to shrink to: keep the label clipped instead of an empty box.
      row = Center(child: row);
    }

    Widget button = Focusable(
      canRequestFocus: widget.enabled,
      focusNode: widget.focusNode,
      builder: (context, focused, child) {
        return Decorator(
          focused: focused,
          decoration: UnaDecoration(
            border: UnaBorder.all(borderRadius: radius, width: 0),
            secondaryFocusedBorder: UnaBorder.all(
              borderRadius: radius.add(BorderRadius.circular(ringWidth)),
              width: ringWidth,
              offset: ringWidth,
              color: ringColor,
            ),
          ),
          child: child,
        );
      },
      child: UnaGestureDetector(
        mouseCursor: widget.enabled
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onHover: widget.enabled
            ? (value) => setState(() => hovered = value)
            : null,
        onTapDown: widget.enabled
            ? (_) => setState(() => pressed = true)
            : null,
        onTapUp: widget.enabled ? (_) => setState(() => pressed = false) : null,
        onTapCancel: widget.enabled
            ? () => setState(() => pressed = false)
            : null,
        onTap: widget.enabled ? widget.onPressed : null,
        // The sidebar lays its content out at the expanded width even while
        // the rail is collapsed (see Sidebar), so the square form needs
        // an explicit width; the LayoutBuilder below supplies the expanded
        // target so both ends of the animation are finite.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final expandedWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : null;
            return AnimatedContainer(
              duration: duration,
              curve: curve,
              width: collapsed ? collapsedSize : expandedWidth,
              height: height,
              padding: padding,
              decoration: ShadowDecoration.box(
                color: highlighted
                    ? accent
                    : outline
                    ? theme.colorScheme.background
                    : null,
                borderRadius: radius,
                // `shadow-[0_0_0_1px_...]`: a spread-only shadow, which the
                // CSS clip turns into a crisp hairline ring outside the
                // button without taking part in layout.
                shadows: outline
                    ? [
                        BoxShadow(
                          color: highlighted ? accent : borderColor,
                          spreadRadius: 1,
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: row,
            );
          },
        ),
      ),
    );

    if (!widget.enabled) {
      button = Opacity(opacity: theme.disabledOpacity, child: button);
    }

    button = Semantics(
      button: true,
      enabled: widget.enabled,
      selected: widget.selected,
      child: button,
    );

    if (widget.tooltip != null && collapsed && !scope.isMobile) {
      // The tooltip hangs off the button's inner side — away from the
      // screen edge the rail sits on — with the arrow pointing back at it.
      final towardEnd = scope.side == SidebarSide.start;
      final physicalRight =
          towardEnd == (Directionality.of(context) == TextDirection.ltr);
      button = Tooltip(
        anchor: Anchor(
          childAlignment: towardEnd
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          overlayAlignment: towardEnd
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          offset: Offset(physicalRight ? 8 : -8, 0),
        ),
        arrowDirection: physicalRight
            ? AxisDirection.left
            : AxisDirection.right,
        builder: (context) => Text(widget.tooltip!),
        child: button,
      );
    }

    // Pin the (possibly square) button to the start edge: its parent stays at
    // the expanded width in the icon rail, and stretch would re-widen it.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      heightFactor: 1,
      child: button,
    );
  }
}

/// A count or status marker at the end of a menu row, shadcn/ui's
/// `SidebarMenuBadge`.
class SidebarMenuBadge extends StatelessWidget {
  /// Creates a badge that shows [child].
  const SidebarMenuBadge({super.key, required this.child});

  /// The content of the badge, usually a short text.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;
    return Container(
      height: 20,
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: sidebarTheme.badgeTextStyle ?? theme.textTheme.small,
        child: child,
      ),
    );
  }
}

/// A small hover-accent icon control, shadcn/ui's `SidebarMenuAction` and
/// `SidebarGroupAction`: put it in a menu button's `trailing` or a group's
/// `action` slot.
class SidebarMenuAction extends StatefulWidget {
  /// Creates an action button that shows [icon].
  const SidebarMenuAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
  });

  /// The icon to show, sized by the sidebar theme's icon size.
  final Widget icon;

  /// Called when the action is tapped.
  final VoidCallback? onPressed;

  /// The label read by screen readers.
  final String? semanticLabel;

  @override
  State<SidebarMenuAction> createState() => _SidebarMenuActionState();
}

class _SidebarMenuActionState extends State<SidebarMenuAction> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;
    final accent = sidebarTheme.accentColor ?? theme.colorScheme.sidebarAccent;
    final accentForeground =
        sidebarTheme.accentForegroundColor ??
        theme.colorScheme.sidebarAccentForeground;
    final foreground =
        sidebarTheme.foregroundColor ?? theme.colorScheme.sidebarForeground;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: UnaGestureDetector(
        mouseCursor: SystemMouseCursors.click,
        onHover: (value) => setState(() => hovered = value),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: hovered ? accent : null,
            borderRadius: sidebarTheme.menuButtonBorderRadius ?? theme.radii.sm,
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              size: sidebarTheme.iconSize ?? 16,
              color: hovered ? accentForeground : foreground,
            ),
            child: Center(child: widget.icon),
          ),
        ),
      ),
    );
  }
}

/// An indented, bordered list nested under a menu row, shadcn/ui's
/// `SidebarMenuSub`. Hidden entirely in the icon rail.
class SidebarMenuSub extends StatelessWidget {
  /// Creates a sub-menu with the given rows.
  const SidebarMenuSub({super.key, required this.children});

  /// The rows, typically [SidebarMenuSubButton]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;
    final scope = SidebarScope.of(context);
    if (scope.collapsed) return const SizedBox.shrink();

    final borderColor =
        sidebarTheme.borderColor ?? theme.colorScheme.sidebarBorder;
    final gap = sidebarTheme.menuGap ?? 4;

    return Container(
      margin:
          sidebarTheme.subMenuMargin ??
          const EdgeInsets.symmetric(horizontal: 14),
      padding:
          sidebarTheme.subMenuPadding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A row inside a [SidebarMenuSub], shadcn/ui's `SidebarMenuSubButton`.
class SidebarMenuSubButton extends StatefulWidget {
  /// Creates a sub-menu row.
  const SidebarMenuSubButton({
    super.key,
    this.onPressed,
    this.leading,
    required this.child,
    this.selected = false,
    this.small = false,
    this.focusNode,
  });

  /// Called when the row is tapped.
  final VoidCallback? onPressed;

  /// The icon at the start of the row.
  final Widget? leading;

  /// The label.
  final Widget child;

  /// Whether this row is the current one; keeps the accent highlight.
  /// Defaults to false.
  final bool selected;

  /// Whether to render at the `sm` (text-xs) size.
  final bool small;

  /// The focus node of the row. When null, the row creates its own.
  final FocusNode? focusNode;

  @override
  State<SidebarMenuSubButton> createState() => _SidebarMenuSubButtonState();
}

class _SidebarMenuSubButtonState extends State<SidebarMenuSubButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarTheme = theme.sidebarTheme;

    final accent = sidebarTheme.accentColor ?? theme.colorScheme.sidebarAccent;
    final accentForeground =
        sidebarTheme.accentForegroundColor ??
        theme.colorScheme.sidebarAccentForeground;
    final foreground =
        sidebarTheme.foregroundColor ?? theme.colorScheme.sidebarForeground;
    final highlighted = hovered || widget.selected;
    final contentColor = highlighted ? accentForeground : foreground;

    var textStyle = sidebarTheme.subButtonTextStyle ?? theme.textTheme.small;
    if (widget.small) textStyle = textStyle.copyWith(fontSize: 12);

    final ringColor = sidebarTheme.ringColor ?? theme.colorScheme.sidebarRing;
    final ringWidth = sidebarTheme.ringWidth ?? 2;
    final radius = sidebarTheme.menuButtonBorderRadius ?? theme.radii.sm;
    final gap = sidebarTheme.menuButtonGap ?? 8;

    return Semantics(
      button: true,
      selected: widget.selected,
      child: Focusable(
        focusNode: widget.focusNode,
        builder: (context, focused, child) {
          return Decorator(
            focused: focused,
            decoration: UnaDecoration(
              border: UnaBorder.all(borderRadius: radius, width: 0),
              secondaryFocusedBorder: UnaBorder.all(
                borderRadius: radius.add(BorderRadius.circular(ringWidth)),
                width: ringWidth,
                offset: ringWidth,
                color: ringColor,
              ),
            ),
            child: child,
          );
        },
        child: UnaGestureDetector(
          mouseCursor: SystemMouseCursors.click,
          onHover: (value) => setState(() => hovered = value),
          onTap: widget.onPressed,
          child: Container(
            height: sidebarTheme.subButtonHeight ?? 28,
            padding:
                sidebarTheme.subButtonPadding ??
                const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: highlighted ? accent : null,
              borderRadius: radius,
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  IconTheme.merge(
                    // `[&>svg]:text-sidebar-accent-foreground`: sub icons
                    // always take the accent foreground.
                    data: IconThemeData(
                      size: sidebarTheme.iconSize ?? 16,
                      color: accentForeground,
                    ),
                    child: widget.leading!,
                  ),
                  SizedBox(width: gap),
                ],
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: textStyle.copyWith(color: contentColor),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A placeholder menu row while content loads, shadcn/ui's
/// `SidebarMenuSkeleton`.
class SidebarMenuSkeleton extends StatefulWidget {
  /// Creates a placeholder row.
  const SidebarMenuSkeleton({super.key, this.showIcon = false});

  /// Whether to show a square placeholder for the icon. Defaults to false.
  final bool showIcon;

  @override
  State<SidebarMenuSkeleton> createState() => _SidebarMenuSkeletonState();
}

class _SidebarMenuSkeletonState extends State<SidebarMenuSkeleton> {
  // Random width between 50% and 90%, stable for this row's lifetime.
  final widthFactor = 0.5 + math.Random().nextDouble() * 0.4;

  @override
  Widget build(BuildContext context) {
    final sidebarTheme = Theme.of(context).sidebarTheme;
    final iconSize = sidebarTheme.iconSize ?? 16;
    final gap = sidebarTheme.menuButtonGap ?? 8;
    return Container(
      height: sidebarTheme.menuButtonHeight ?? 32,
      padding:
          sidebarTheme.menuButtonPadding ??
          const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (widget.showIcon) ...[
            Skeleton(width: iconSize, height: iconSize),
            SizedBox(width: gap),
          ],
          Expanded(
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: widthFactor,
              child: const Skeleton(height: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// A hairline between sidebar sections, shadcn/ui's `SidebarSeparator`.
class SidebarDivider extends StatelessWidget {
  /// Creates a separator.
  const SidebarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.sidebarTheme.borderColor ?? theme.colorScheme.sidebarBorder,
    );
  }
}
