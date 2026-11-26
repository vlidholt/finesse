import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart' as lg;
import 'package:una/src/components/bar_button_scope.dart';
import 'package:una/src/components/popover.dart';
import 'package:una/src/liquid_glass/liquid_glass.dart';
import 'package:una/src/theme/theme.dart';

/// A menu that morphs out of its trigger, as iOS 26 opens a menu from the
/// button that shows it: the package's `GlassPopover` — the glass of the
/// trigger stretched into the menu on a spring, the content fading in as it
/// settles, and gathered back into the trigger on the way out — opened and
/// closed by a una [PopoverController].
///
/// The controller stays the one source of truth: opening or closing it
/// morphs the menu, and a tap outside (the package's barrier) closes it.
/// The menu is [width] wide, its content's own height, with corners of
/// [radius].
///
/// `ContextMenu` uses it for a root menu on a phone or a tablet, opened at
/// its own trigger rather than at a point. Internal.
class LiquidGlassMorphPopover extends StatefulWidget {
  /// Creates a menu that [controller] morphs out of [child].
  const LiquidGlassMorphPopover({
    required this.controller,
    required this.builder,
    required this.child,
    required this.width,
    required this.radius,
    super.key,
  });

  /// Opens and closes the menu.
  final PopoverController controller;

  /// The menu's content. It brings no surface of its own.
  final WidgetBuilder builder;

  /// The trigger the menu grows out of. It keeps its own taps.
  final Widget child;

  /// The menu's width.
  final double width;

  /// The menu's corner radius.
  final double radius;

  @override
  State<LiquidGlassMorphPopover> createState() =>
      _LiquidGlassMorphPopoverState();
}

class _LiquidGlassMorphPopoverState extends State<LiquidGlassMorphPopover> {
  final _glass = lg.GlassPopoverController();

  /// What the package's popover was last told, or said, it is.
  bool _glassOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    // The package's popover attaches its controller as it is built.
    if (widget.controller.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sync();
      });
    }
  }

  @override
  void didUpdateWidget(covariant LiquidGlassMorphPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final open = widget.controller.isOpen;
    if (open == _glassOpen) return;
    _glassOpen = open;
    if (open) {
      _glass.open();
    } else {
      _glass.close();
    }
  }

  void _onGlassOpen() {
    _glassOpen = true;
    if (!widget.controller.isOpen) widget.controller.open();
  }

  void _onGlassClose() {
    _glassOpen = false;
    if (widget.controller.isOpen) widget.controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Without shader filters the glass is the package's lighter tier, and
    // the menu needs the same help to read as any overlay there.
    final legible = !ui.ImageFilter.isShaderFilterSupported;
    return LiquidGlassBridge(
      child: Builder(
        builder: (context) {
          var settings = lg.GlassThemeHelpers.resolveSettings(
            context,
            isOverlayPlatter: true,
          );
          if (legible) settings = legibleOverlaySettings(settings, theme);
          return lg.GlassPopover(
            controller: _glass,
            // The trigger opens the menu through the una controller.
            triggerBuilder: (context, _) => widget.child,
            contentBuilder: (context, _) {
              // Not the bar's buttons, though the trigger may be in a bar.
              final content = BarButtonScope.none(
                child: widget.builder(context),
              );
              if (!legible) return content;
              return DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(widget.radius),
                    side: BorderSide(color: overlayEdgeColor(theme)),
                  ),
                ),
                child: content,
              );
            },
            popoverWidth: widget.width,
            popoverBorderRadius: widget.radius,
            settings: settings,
            quality: lg.GlassQuality.premium,
            onOpen: _onGlassOpen,
            onClose: _onGlassClose,
          );
        },
      ),
    );
  }
}
