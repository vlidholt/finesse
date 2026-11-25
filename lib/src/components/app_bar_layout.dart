import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:finesse/src/components/back_button.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/components/scaffold.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icon.dart';
import 'package:finesse/src/icons/phosphor_icons_regular.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// The parts `AppBar` and `SliverAppBar` are both made of: the toolbar row,
// the bar's surface, and the leading button a bar shows by itself. Internal.

/// The button a bar shows at its start when it was given none: a close
/// button on a full-screen dialog, a back button on a page that can be
/// popped, a menu button over a scaffold with a drawer — or nothing.
Widget? impliedLeading(BuildContext context) {
  final route = ModalRoute.of(context);
  if (route is PageRoute && route.fullscreenDialog) return const CloseButton();
  if (route?.impliesAppBarDismissal ?? false) return const BackButton();
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold != null && scaffold.hasDrawer) {
    return IconButton.ghost(
      icon: const PhosphorIcon(PhosphorIconsRegular.list),
      semanticLabel: FinesseLocalizations.of(context).navigation.openMenu,
      onPressed: scaffold.openDrawer,
    );
  }
  return null;
}

/// [actions], or — when there are none and the scaffold has an end drawer
/// — the button that opens it.
List<Widget> impliedActions(BuildContext context, List<Widget> actions) {
  if (actions.isNotEmpty) return actions;
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold == null || !scaffold.hasEndDrawer) return actions;
  return [
    IconButton.ghost(
      icon: const PhosphorIcon(PhosphorIconsRegular.list),
      semanticLabel: FinesseLocalizations.of(context).navigation.openMenu,
      onPressed: scaffold.openEndDrawer,
    ),
  ];
}

/// The least a pulled-out leading button keeps from the edge of the bar.
const _minLeadingMargin = 4.0;

/// The row of a bar: [leading], [title], [middle] and [actions], in the
/// bar's text and icon styles, inside the bar's margins.
class AppBarToolbar extends StatelessWidget {
  /// Creates the row of a bar.
  const AppBarToolbar({
    required this.height,
    this.leading,
    this.title,
    this.middle,
    this.actions = const [],
    this.centerTitle = false,
    this.alignLeadingGlyph = false,
    this.padding,
    this.maxWidth,
    this.gap,
    this.actionsGap,
    super.key,
  });

  /// The row's height.
  final double height;

  /// The widget at the start.
  final Widget? leading;

  /// The widget after [leading], or in the middle with [centerTitle].
  final Widget? title;

  /// A widget centred in the bar.
  final Widget? middle;

  /// The widgets at the end.
  final List<Widget> actions;

  /// Whether [title] is centred in the bar. A [middle] has the centre
  /// first.
  final bool centerTitle;

  /// Whether [leading] is an icon button whose *glyph*, not its box, should
  /// stand on the row's margin: the box is then moved out towards the edge
  /// by its own inner inset, as far as the margin allows.
  final bool alignLeadingGlyph;

  /// Padding around the row. Defaults to the theme's.
  final EdgeInsetsGeometry? padding;

  /// The widest the row grows. Defaults to the theme's.
  final double? maxWidth;

  /// The gap between the row's parts. Defaults to the theme's.
  final double? gap;

  /// The gap between two [actions]. Defaults to the theme's small gap.
  final double? actionsGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.appBarTheme;
    final effectiveGap = gap ?? bar.gap ?? 24;
    final foreground = bar.foregroundColor ?? theme.colorScheme.foreground;
    // A page's bar is headed by its title. In a navigation bar — one with
    // a [middle] — the title's place holds a search field or a product
    // name, and the bar is chrome, not a heading.
    final heading = title == null || middle != null
        ? title
        // A node of its own: merged into the bar's, it would make a
        // heading of everything else that is read there.
        : Semantics(header: true, container: true, child: title);

    final actionsRow = actions.isEmpty
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: actionsGap ?? theme.layoutTheme.gapSm ?? 8,
            children: actions,
          );

    final Widget content;
    if (middle != null) {
      content = Row(
        spacing: effectiveGap,
        children: [
          Expanded(
            child: Row(
              spacing: effectiveGap - 4,
              children: [
                ?leading,
                if (heading != null) Flexible(child: heading),
              ],
            ),
          ),
          middle!,
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: actionsRow,
            ),
          ),
        ],
      );
    } else if (centerTitle) {
      // Centred in the bar, not in what the buttons leave over, and pushed
      // aside rather than under them when it is too long for that.
      content = NavigationToolbar(
        leading: leading,
        middle: heading,
        trailing: actionsRow,
        middleSpacing: effectiveGap / 2,
      );
    } else {
      content = Row(
        spacing: effectiveGap / 2,
        children: [
          ?leading,
          Expanded(child: heading ?? const SizedBox.shrink()),
          ?actionsRow,
        ],
      );
    }

    final direction = Directionality.of(context);
    var effectivePadding =
        (padding ?? bar.padding ?? const EdgeInsets.symmetric(horizontal: 24))
            .resolve(direction);
    if (alignLeadingGlyph && leading != null) {
      final ltr = direction == TextDirection.ltr;
      final margin = ltr ? effectivePadding.left : effectivePadding.right;
      final inset =
          (theme.style.iconButtonSize - theme.style.iconButtonIconSize) / 2;
      // Never right up against the edge.
      final room = margin - _minLeadingMargin;
      final pulled = margin - inset.clamp(0.0, room < 0 ? 0.0 : room);
      effectivePadding = effectivePadding.copyWith(
        left: ltr ? pulled : null,
        right: ltr ? null : pulled,
      );
    }

    return SizedBox(
      height: height,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? bar.maxWidth ?? double.infinity,
          ),
          child: Padding(
            padding: effectivePadding,
            child: DefaultTextStyle.merge(
              style: (bar.titleStyle ?? theme.textTheme.large).copyWith(
                color: foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: IconTheme.merge(
                data: IconThemeData(color: foreground),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The height of a bar's toolbar at the text scale of [context], for a
/// style height of [height].
///
/// A style height is the height at the platform's own text size: it is a
/// floor, not a size, once the user has scaled the text. The toolbar keeps
/// its height for as long as a line of its title fits, which with the
/// shipped styles is up to a little over twice the text size, and is as
/// tall as that line from there on. At a scale of 1 or less it is exactly
/// [height].
double appBarToolbarHeight(BuildContext context, double height) {
  final scaler = MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
  if (scaler == TextScaler.noScaling) return height;
  final theme = Theme.of(context);
  final style = theme.appBarTheme.titleStyle ?? theme.textTheme.large;
  final fontSize = style.fontSize ?? 14;
  final line = scaler.scale(fontSize) * (style.height ?? 1.2);
  return math.max(height, line.ceilToDouble());
}

/// The surface of a bar: its fill over the blurred page, and the hairline
/// under it.
///
/// With a [visibility], the whole surface — fill, hairline and blur — is
/// shown by that much, from 0 (a bare bar: only the content) to 1. It
/// follows the animation at paint time: nothing is rebuilt while it runs.
class AppBarSurface extends StatelessWidget {
  /// Creates the surface of a bar around [child].
  const AppBarSurface({
    required this.child,
    required this.color,
    this.borderColor,
    this.blur = 0,
    this.saturation = 1,
    this.padding = EdgeInsets.zero,
    this.visibility,
    super.key,
  });

  /// The bar's content.
  final Widget child;

  /// The fill.
  final Color color;

  /// The colour of the hairline under the bar; null for none. The hairline
  /// is added below the content, not laid over it.
  final Color? borderColor;

  /// The sigma of the blur of what is behind the bar.
  final double blur;

  /// How much what is behind the bar is saturated.
  final double saturation;

  /// Padding between the surface's edge and the content: the status bar.
  final EdgeInsets padding;

  /// How much of the surface shows, from 0 to 1. Null is all of it, always.
  final Animation<double>? visibility;

  @override
  Widget build(BuildContext context) {
    final border = borderColor;
    final visibility = this.visibility;
    if (visibility == null) {
      return Backdrop(
        blur: blur,
        saturation: saturation,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            border: border == null
                ? null
                : Border(bottom: BorderSide(color: border)),
          ),
          child: child,
        ),
      );
    }
    Widget surface = _FadingFill(
      visibility: visibility,
      color: color,
      borderColor: border,
      child: Padding(
        // The hairline's point, as a `Container` would reserve it.
        padding: padding + EdgeInsets.only(bottom: border == null ? 0 : 1),
        child: child,
      ),
    );
    final filter = Backdrop.filterFor(blur: blur, saturation: saturation);
    if (filter != null) {
      surface = ClipRect(
        child: FadingBackdrop(
          visibility: visibility,
          filter: filter,
          child: surface,
        ),
      );
    }
    return surface;
  }
}

/// A fill and a hairline under it, shown by [visibility].
class _FadingFill extends SingleChildRenderObjectWidget {
  const _FadingFill({
    required this.visibility,
    required this.color,
    required this.borderColor,
    required super.child,
  });

  final Animation<double> visibility;
  final Color color;
  final Color? borderColor;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFadingFill(visibility, color, borderColor);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFadingFill renderObject,
  ) {
    renderObject
      ..visibility = visibility
      ..color = color
      ..borderColor = borderColor;
  }
}

class _RenderFadingFill extends RenderProxyBox {
  _RenderFadingFill(this._visibility, this._color, this._borderColor);

  Animation<double> get visibility => _visibility;
  Animation<double> _visibility;
  set visibility(Animation<double> value) {
    if (identical(value, _visibility)) return;
    if (attached) _visibility.removeListener(markNeedsPaint);
    _visibility = value;
    if (attached) _visibility.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  Color? get borderColor => _borderColor;
  Color? _borderColor;
  set borderColor(Color? value) {
    if (value == _borderColor) return;
    _borderColor = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _visibility.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _visibility.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final shown = _visibility.value.clamp(0.0, 1.0);
    if (shown > 0) {
      final rect = offset & size;
      context.canvas.drawRect(
        rect,
        Paint()..color = _color.withValues(alpha: _color.a * shown),
      );
      if (_borderColor case final border?) {
        context.canvas.drawRect(
          Rect.fromLTRB(rect.left, rect.bottom - 1, rect.right, rect.bottom),
          Paint()..color = border.withValues(alpha: border.a * shown),
        );
      }
    }
    super.paint(context, offset);
  }
}

/// A backdrop filter whose result is shown by [visibility].
///
/// Not an opacity around a filter: under an opacity layer a backdrop filter
/// samples that layer, which is empty. The filter's own output is faded.
class FadingBackdrop extends SingleChildRenderObjectWidget {
  /// Creates a backdrop filter shown by [visibility].
  const FadingBackdrop({
    required this.visibility,
    required this.filter,
    required super.child,
    super.key,
  });

  /// How much of the filter's result shows, from 0 to 1.
  final Animation<double> visibility;

  /// The filter at full strength.
  final ImageFilter filter;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFadingBackdrop(visibility, filter);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBackdropFilter renderObject,
  ) {
    (renderObject as _RenderFadingBackdrop)
      ..visibility = visibility
      ..base = filter;
  }
}

// A `RenderBackdropFilter`, so that whatever counts the backdrop filters on
// screen counts this one.
class _RenderFadingBackdrop extends RenderBackdropFilter {
  _RenderFadingBackdrop(this._visibility, this._base)
    : super(
        filter: Backdrop.faded(_base, _visibility.value) ?? _base,
        enabled: _visibility.value > 0,
      );

  Animation<double> get visibility => _visibility;
  Animation<double> _visibility;
  set visibility(Animation<double> value) {
    if (identical(value, _visibility)) return;
    if (attached) _visibility.removeListener(_follow);
    _visibility = value;
    if (attached) _visibility.addListener(_follow);
    _follow();
  }

  ImageFilter get base => _base;
  ImageFilter _base;
  set base(ImageFilter value) {
    if (identical(value, _base)) return;
    _base = value;
    _follow();
  }

  void _follow() {
    final shown = _visibility.value.clamp(0.0, 1.0);
    enabled = shown > 0;
    if (shown > 0) filter = Backdrop.faded(_base, shown)!;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _visibility.addListener(_follow);
    _follow();
  }

  @override
  void detach() {
    _visibility.removeListener(_follow);
    super.detach();
  }
}
