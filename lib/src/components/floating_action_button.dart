import 'dart:ui' show lerpDouble;

import 'package:finesse/src/components/glass.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:finesse/src/utils/text_scaled_height.dart';
import 'package:flutter/widgets.dart';

/// What a [FloatingActionButton] is filled with.
enum FloatingActionButtonVariant {
  /// The scheme's primary fill: the one thing to do on this screen.
  primary,

  /// The scheme's secondary fill, for an action that should not shout.
  secondary,

  /// The theme's glass, like the floating bottom bar: for a button over
  /// photographs, a map, or anything else worth seeing through it.
  glass,
}

/// How large a [FloatingActionButton] is.
enum FloatingActionButtonSize {
  /// A small button, for a secondary action beside a regular one.
  small,

  /// The usual size.
  regular,

  /// A large button, for a screen that is about one action.
  large,
}

/// A button that floats over the page for the screen's main action: compose,
/// add, start.
///
/// ```dart
/// Scaffold(
///   floatingActionButton: FloatingActionButton(
///     icon: const PhosphorIcon(PhosphorIconsRegular.plus),
///     label: const Text('New post'),
///     onPressed: _compose,
///   ),
///   body: feed,
/// )
/// ```
///
/// With a [label] it is a pill; without one, a circle. [extended] collapses
/// the label to the icon and back on the theme's surface spring — the usual
/// pattern is `extended: !scrolledDown`, so the button gives the content
/// room while it is being read. A button without a label needs a
/// [semanticLabel].
///
/// It takes its size from the theme's form factor (larger on a phone, where
/// it is a touch target first), its fill from [variant], and the same
/// shadow as the floating bottom bar. A `Scaffold` positions it, moves it
/// out of the way of its bars and the keyboard, and pops it in and out.
///
/// For a menu of actions, anchor a `DropdownMenu` above it.
class FloatingActionButton extends StatelessWidget {
  /// Creates a floating action button.
  const FloatingActionButton({
    required this.icon,
    required this.onPressed,
    this.label,
    this.variant = FloatingActionButtonVariant.primary,
    this.size = FloatingActionButtonSize.regular,
    this.extended = true,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         label != null || semanticLabel != null,
         'A FloatingActionButton with no label has nothing to be read as: '
         'give it a semanticLabel.',
       );

  /// The icon. It takes the button's icon size and foreground.
  final Widget icon;

  /// The text beside the icon, usually a `Text`.
  final Widget? label;

  /// Called when the button is pressed. Null disables it.
  final VoidCallback? onPressed;

  /// What the button is filled with.
  final FloatingActionButtonVariant variant;

  /// How large the button is.
  final FloatingActionButtonSize size;

  /// Whether the [label] shows. False collapses the button to its icon.
  final bool extended;

  /// What assistive technology reads, in place of the [label].
  final String? semanticLabel;

  /// The focus node to use; one is created when null.
  final FocusNode? focusNode;

  /// Whether the button takes focus when it is first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fab = theme.floatingActionButtonTheme;
    final scheme = theme.colorScheme;
    final motion = Motion.of(context);
    final enabled = onPressed != null;

    final (height, iconSize) = switch (size) {
      FloatingActionButtonSize.small => (
        fab.sizeSm ?? 40.0,
        fab.iconSizeSm ?? 20.0,
      ),
      FloatingActionButtonSize.regular => (
        fab.size ?? 48.0,
        fab.iconSize ?? 24.0,
      ),
      FloatingActionButtonSize.large => (
        fab.sizeLg ?? 64.0,
        fab.iconSizeLg ?? 28.0,
      ),
    };
    final radius = fab.radius ?? theme.radii.full;
    final glass = variant == FloatingActionButtonVariant.glass;
    final (Color? fill, Color foreground) = switch (variant) {
      FloatingActionButtonVariant.primary => (
        fab.backgroundColor ?? scheme.primary,
        fab.foregroundColor ?? scheme.primaryForeground,
      ),
      FloatingActionButtonVariant.secondary => (
        fab.secondaryBackgroundColor ?? scheme.secondary,
        fab.secondaryForegroundColor ?? scheme.secondaryForeground,
      ),
      FloatingActionButtonVariant.glass => (
        null,
        fab.glassForegroundColor ?? scheme.foreground,
      ),
    };
    final shadows = fab.shadows ?? theme.style.floatingShadow;
    final edge = fab.padding ?? 20.0;
    final gap = fab.gap ?? 8.0;
    // A circle's worth of padding around the icon alone.
    final outline = glass ? 2 * (theme.glassTheme.borderWidth ?? 1) : 0.0;
    final bare = (height - outline - iconSize) / 2;
    final label = this.label;

    final content = SpringBuilder(
      value: label != null && extended ? 1 : 0,
      spring: motion.smooth,
      // Rebuilt on every frame of the collapse, and only then: a row of
      // two.
      builder: (context, value, child) {
        final t = value.clamp(0.0, 1.0);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: lerpDouble(bare, edge, t)!),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme.merge(
                data: IconThemeData(size: iconSize, color: foreground),
                child: icon,
              ),
              if (child != null)
                // Still there for assistive technology when it is
                // collapsed: it is the button's name.
                ClipRect(
                  clipBehavior: t < 1 ? Clip.hardEdge : Clip.none,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: t,
                    child: Opacity(
                      opacity: t,
                      alwaysIncludeSemantics: true,
                      child: child,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: label == null
          ? null
          : Padding(
              padding: EdgeInsetsDirectional.only(start: gap),
              child: DefaultTextStyle.merge(
                style: (fab.labelStyle ?? theme.textTheme.small).copyWith(
                  color: foreground,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                child: label,
              ),
            ),
    );

    return Pressable(
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        final pressed = states.contains(WidgetState.pressed);
        // A wash of the button's own ink, so the response reads on any
        // fill.
        final wash = foreground.withValues(
          alpha: pressed
              ? .14
              : hovered
              ? .08
              : 0,
        );
        final box = ConstrainedBox(
          // The glass draws its hairline around the box; the button is the
          // theme's size either way.
          constraints: BoxConstraints(
            minWidth: height - outline,
            minHeight: height - outline,
            maxHeight: textScaledMaxHeight(context, height) - outline,
          ),
          child: AnimatedFill(
            color: fill == null ? wash : Color.alphaBlend(wash, fill),
            borderRadius: radius,
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              // A disabled button dims what is on it, not the surface: an
              // opacity around glass would take its blur away.
              child: Opacity(
                opacity: enabled ? 1 : theme.disabledOpacity,
                child: content,
              ),
            ),
          ),
        );
        final Widget surface;
        if (glass) {
          surface = Glass(
            level: GlassLevel.strong,
            borderRadius: radius,
            shadows: shadows,
            child: box,
          );
        } else {
          // After the fill, and clipped to outside it: a shadow under a
          // translucent fill would show through as a grey wash.
          surface = DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: ShadowDecoration.box(
              borderRadius: radius,
              shadows: shadows,
            ),
            child: box,
          );
        }
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: radius,
          child: surface,
        );
      },
    );
  }
}
