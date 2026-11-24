import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/separated_iterable.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';

// A customizable card widget for displaying structured content.
///
/// The [Card] widget provides a container with a title, description, main
/// content, and optional footer, styled with a background, border, and shadows.
/// It integrates with [Theme] for consistent styling and supports leading
/// and trailing widgets for additional layout flexibility.
class Card extends StatelessWidget {
  /// Creates a card widget with optional content and styling.
  const Card({
    super.key,
    this.title,
    this.description,
    this.child,
    this.footer,
    this.padding,
    this.backgroundColor,
    this.radius,
    this.border,
    this.shadows,
    this.width,
    this.height,
    this.leading,
    this.trailing,
    this.rowMainAxisAlignment,
    this.rowCrossAxisAlignment,
    this.columnMainAxisAlignment,
    this.columnCrossAxisAlignment,
    this.rowMainAxisSize,
    this.columnMainAxisSize,
    this.clipBehavior,
    this.titleStyle,
    this.descriptionStyle,
    this.gap,
    this.action,
  });

  /// {@template Card.title}
  /// The title widget displayed at the top of the card.
  /// Typically a [Text] widget, styled with the theme’s h3 style.
  /// {@endtemplate}
  final Widget? title;

  /// {@template Card.description}
  /// The description widget displayed below the title.
  /// Typically a [Text] widget, styled with the theme’s muted style.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Card.child}
  /// The main content widget of the card, displayed below the description.
  /// Expands flexibly within the card’s column layout.
  /// {@endtemplate}
  final Widget? child;

  /// {@template Card.footer}
  /// The footer widget displayed at the bottom of the card.
  /// Useful for actions or additional information.
  /// {@endtemplate}
  final Widget? footer;

  /// {@template Card.padding}
  /// The padding inside the card, surrounding all content.
  /// Defaults to EdgeInsets.all(24) if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Card.backgroundColor}
  /// The background color of the card.
  /// Defaults to the theme’s card color if not specified.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Card.radius}
  /// The border radius of the card’s corners.
  /// Defaults to the theme’s radius if not specified.
  /// {@endtemplate}
  final BorderRadius? radius;

  /// {@template Card.border}
  /// The border surrounding the card.
  /// Defaults to a border with the theme’s border color if not specified.
  /// {@endtemplate}
  final FinesseBorder? border;

  /// {@template Card.shadows}
  /// The list of box shadows applied to the card for elevation.
  /// Defaults to the theme’s card shadows if not specified.
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Card.width}
  /// The explicit width of the card.
  /// If null, the card sizes to its content or constraints.
  /// {@endtemplate}
  final double? width;

  /// {@template Card.height}
  /// The explicit height of the card.
  /// If null, the card sizes to its content or constraints.
  /// {@endtemplate}
  final double? height;

  /// {@template Card.leading}
  /// The widget displayed at the start of the card’s row.
  /// Typically an icon or small graphic, positioned before the main content.
  /// {@endtemplate}
  final Widget? leading;

  /// {@template Card.trailing}
  /// The widget displayed at the end of the card’s row.
  /// Typically an icon or small graphic, positioned after the main content.
  /// {@endtemplate}
  final Widget? trailing;

  /// {@template Card.rowMainAxisAlignment}
  /// The main axis alignment of the card’s row (horizontal).
  /// Defaults to [MainAxisAlignment.spaceBetween] if not specified.
  /// {@endtemplate}
  final MainAxisAlignment? rowMainAxisAlignment;

  /// {@template Card.rowCrossAxisAlignment}
  /// The cross axis alignment of the card’s row (vertical).
  /// Defaults to [CrossAxisAlignment.start] if not specified.
  /// {@endtemplate}
  final CrossAxisAlignment? rowCrossAxisAlignment;

  /// {@template Card.columnMainAxisAlignment}
  /// The main axis alignment of the card’s column (vertical).
  /// Defaults to [MainAxisAlignment.start] if not specified.
  /// {@endtemplate}
  final MainAxisAlignment? columnMainAxisAlignment;

  /// {@template Card.columnCrossAxisAlignment}
  /// The cross axis alignment of the card’s column (horizontal).
  /// Defaults to [CrossAxisAlignment.start] if not specified.
  /// {@endtemplate}
  final CrossAxisAlignment? columnCrossAxisAlignment;

  /// {@template Card.rowMainAxisSize}
  /// The main axis size of the card’s row.
  /// Defaults to [MainAxisSize.min] if not specified.
  /// {@endtemplate}
  final MainAxisSize? rowMainAxisSize;

  /// {@template Card.columnMainAxisSize}
  /// The main axis size of the card’s column.
  /// Defaults to [MainAxisSize.min] if not specified.
  /// {@endtemplate}
  final MainAxisSize? columnMainAxisSize;

  /// {@template Card.clipBehavior}
  /// The clip behavior of the card, controlling how content is clipped.
  /// Defaults to [Clip.antiAlias] if not specified.
  /// {@endtemplate}
  final Clip? clipBehavior;

  /// {@template Card.titleStyle}
  /// The text style of [title].
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template Card.descriptionStyle}
  /// The text style of [description].
  /// {@endtemplate}
  final TextStyle? descriptionStyle;

  /// {@template Card.gap}
  /// The vertical space between the title, description, content and footer.
  /// {@endtemplate}
  final double? gap;

  /// {@template Card.action}
  /// A widget pinned to the end of the header row, shadcn/ui's `CardAction` —
  /// typically a dismiss or overflow button.
  ///
  /// Unlike [trailing], which sits beside the card's whole content column,
  /// this occupies only the header, so the body keeps the card's full width.
  /// {@endtemplate}
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGap = gap ?? theme.cardTheme.gap ?? 0;
    // Sections sit `--card-spacing` apart; the small [gap] only separates the
    // title from its description.
    final effectiveSectionGap = theme.cardTheme.sectionGap ?? effectiveGap;

    final effectivePadding =
        padding ?? theme.cardTheme.padding ?? const EdgeInsets.all(24);
    final effectiveBackgroundColor =
        backgroundColor ??
        theme.cardTheme.backgroundColor ??
        theme.colorScheme.card;
    final effectiveRadius = radius ?? theme.cardTheme.radius ?? theme.radius;
    final effectiveBorder =
        border ??
        theme.cardTheme.border ??
        FinesseBorder.all(color: theme.colorScheme.border, width: 1);
    final effectiveShadows = shadows ?? theme.cardTheme.shadows;

    final effectiveRowMainAxisSize =
        rowMainAxisSize ?? theme.cardTheme.rowMainAxisSize ?? MainAxisSize.min;

    final effectiveRowMainAxisAlignment =
        rowMainAxisAlignment ??
        theme.cardTheme.rowMainAxisAlignment ??
        MainAxisAlignment.spaceBetween;

    final effectiveRowCrossAxisAlignment =
        rowCrossAxisAlignment ??
        theme.cardTheme.rowCrossAxisAlignment ??
        CrossAxisAlignment.start;

    final effectiveColumnMainAxisSize =
        columnMainAxisSize ??
        theme.cardTheme.columnMainAxisSize ??
        MainAxisSize.min;

    final effectiveColumnMainAxisAlignment =
        columnMainAxisAlignment ??
        theme.cardTheme.columnMainAxisAlignment ??
        MainAxisAlignment.start;

    final effectiveColumnCrossAxisAlignment =
        columnCrossAxisAlignment ??
        theme.cardTheme.columnCrossAxisAlignment ??
        CrossAxisAlignment.start;

    final effectiveClipBehavior =
        clipBehavior ?? theme.cardTheme.clipBehavior ?? Clip.antiAlias;

    return Container(
      width: width,
      height: height,
      padding: effectivePadding,
      clipBehavior: effectiveClipBehavior,
      decoration: ShadowDecoration.box(
        color: effectiveBackgroundColor,
        borderRadius: effectiveRadius,
        border: effectiveBorder.toBorder(),
        shadows: effectiveShadows ?? const [],
      ),
      child: Row(
        mainAxisSize: effectiveRowMainAxisSize,
        mainAxisAlignment: effectiveRowMainAxisAlignment,
        crossAxisAlignment: effectiveRowCrossAxisAlignment,
        children: [
          ?leading,
          Flexible(
            child: Column(
              mainAxisSize: effectiveColumnMainAxisSize,
              crossAxisAlignment: effectiveColumnCrossAxisAlignment,
              mainAxisAlignment: effectiveColumnMainAxisAlignment,
              children: [
                if (title != null || description != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: effectiveColumnCrossAxisAlignment,
                          children: [
                            if (title != null)
                              DefaultTextStyle(
                                style:
                                    (titleStyle ??
                                            theme.cardTheme.titleStyle ??
                                            theme.textTheme.h3)
                                        .copyWith(
                                          color:
                                              theme.colorScheme.cardForeground,
                                        ),
                                child: title!,
                              ),
                            if (description != null)
                              DefaultTextStyle(
                                style:
                                    (descriptionStyle ??
                                            theme.cardTheme.descriptionStyle ??
                                            theme.textTheme.muted)
                                        .fallback(
                                          color:
                                              theme.colorScheme.mutedForeground,
                                        ),
                                child: description!,
                              ),
                          ].separatedBy(SizedBox(height: effectiveGap)),
                        ),
                      ),
                      ?action,
                    ],
                  ),
                if (child != null) Flexible(child: child!),
                ?footer,
              ].separatedBy(SizedBox(height: effectiveSectionGap)),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
