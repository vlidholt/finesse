import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/widgets.dart';

/// {@template Empty}
/// An empty-state placeholder.
///
/// Mirrors shadcn/ui's `Empty`: an icon, a title, a description and optional
/// actions, centred in the space where content would otherwise be.
///
/// ```dart
/// Empty(
///   icon: const Icon(PhosphorIconsRegular.tray),
///   title: const Text('No messages'),
///   description: const Text('Messages you receive will show up here.'),
///   actions: [Button(onPressed: refresh, child: const Text('Refresh'))],
/// )
/// ```
///
/// [title] falls back to a localized "No results" so the widget is never
/// silently blank.
/// {@endtemplate}
class Empty extends StatelessWidget {
  /// {@macro Empty}
  const Empty({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.actions = const [],
    this.padding,
    this.gap,
    this.iconSize,
    this.iconColor,
    this.titleStyle,
    this.descriptionStyle,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.mainAxisSize = MainAxisSize.min,
  });

  /// An illustration shown above the title, usually an [Icon].
  final Widget? icon;

  /// The headline. Defaults to a localized "No results".
  final Widget? title;

  /// A sentence explaining the empty state, or how to leave it.
  final Widget? description;

  /// Actions offered to the user, laid out in a row below the description.
  final List<Widget> actions;

  /// {@template Empty.padding}
  /// The padding around the content.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// The vertical gap between the icon, title, description and actions.
  final double? gap;

  /// {@template Empty.iconSize}
  /// The size of [icon].
  /// {@endtemplate}
  final double? iconSize;

  /// The color applied to [icon].
  final Color? iconColor;

  /// {@template Empty.titleStyle}
  /// The style of [title].
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template Empty.descriptionStyle}
  /// The style of [description].
  /// {@endtemplate}
  final TextStyle? descriptionStyle;

  /// {@template Empty.crossAxisAlignment}
  /// The horizontal alignment of the content.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template Empty.mainAxisAlignment}
  /// The vertical alignment of the content.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// How much height the content takes when the height is unbounded. Defaults
  /// to [MainAxisSize.min]. With a bounded height, the content always fills it.
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final emptyTheme = theme.emptyTheme;
    final localizations = FinesseLocalizations.of(context);

    final effectivePadding =
        padding ??
        emptyTheme.padding ??
        const EdgeInsets.symmetric(horizontal: 24, vertical: 48);
    final effectiveGap = gap ?? emptyTheme.gap ?? 8.0;
    final effectiveIconSize = iconSize ?? emptyTheme.iconSize ?? 40.0;
    final effectiveIconColor =
        iconColor ?? emptyTheme.iconColor ?? theme.colorScheme.mutedForeground;
    // The text theme's styles carry no colour of their own; without a
    // fallback the engine paints colourless glyphs white — an invisible
    // empty state on a light surface.
    final effectiveTitleStyle = (emptyTheme.titleStyle ?? theme.textTheme.large)
        .merge(titleStyle)
        .fallback(color: theme.colorScheme.foreground);
    final effectiveDescriptionStyle =
        (emptyTheme.descriptionStyle ?? theme.textTheme.muted)
            .merge(descriptionStyle)
            .fallback(color: theme.colorScheme.mutedForeground);
    final effectiveCrossAxisAlignment =
        crossAxisAlignment ??
        emptyTheme.crossAxisAlignment ??
        CrossAxisAlignment.center;
    final effectiveMainAxisAlignment =
        mainAxisAlignment ??
        emptyTheme.mainAxisAlignment ??
        MainAxisAlignment.center;

    final effectiveTitle = title ?? Text(localizations.empty.title);

    return Semantics(
      container: true,
      child: Padding(
        padding: effectivePadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boundedHeight = constraints.hasBoundedHeight;
            return SizedBox(
              width: double.infinity,
              height: boundedHeight ? constraints.maxHeight : null,
              child: Column(
                mainAxisSize: boundedHeight ? MainAxisSize.max : mainAxisSize,
                mainAxisAlignment: effectiveMainAxisAlignment,
                crossAxisAlignment: effectiveCrossAxisAlignment,
                children: [
                  if (icon != null) ...[
                    // shadcn's `EmptyMedia variant="icon"`: the glyph
                    // sits centred in a `size-10 bg-muted rounded-lg` chip
                    // at `size-6`, rather than being blown up to the chip's
                    // own size.
                    Container(
                      width: effectiveIconSize,
                      height: effectiveIconSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted,
                        borderRadius: theme.radii.lg,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          size: effectiveIconSize * .6,
                          color: effectiveIconColor,
                        ),
                        child: icon!,
                      ),
                    ),
                    SizedBox(height: effectiveGap * 2),
                  ],
                  DefaultTextStyle(
                    style: effectiveTitleStyle,
                    textAlign: TextAlign.center,
                    child: effectiveTitle,
                  ),
                  if (description != null) ...[
                    SizedBox(height: effectiveGap),
                    DefaultTextStyle(
                      style: effectiveDescriptionStyle,
                      textAlign: TextAlign.center,
                      child: description!,
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: effectiveGap * 2),
                    // A Wrap, not a Row: two buttons side by side do not
                    // fit a phone-width empty state, and should stack
                    // rather than overflow.
                    Wrap(
                      alignment: switch (effectiveCrossAxisAlignment) {
                        CrossAxisAlignment.start => WrapAlignment.start,
                        CrossAxisAlignment.end => WrapAlignment.end,
                        _ => WrapAlignment.center,
                      },
                      spacing: effectiveGap,
                      runSpacing: effectiveGap,
                      children: actions,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
