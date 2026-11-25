import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
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
    this.onPressed,
    this.selected = false,
    this.sectionGap,
    this.semanticLabel,
    this.title,
    this.description,
    this.child,
    this.footer,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
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

  /// {@template Card.borderRadius}
  /// The border radius of the card’s corners.
  /// Defaults to the theme’s radius if not specified.
  /// {@endtemplate}
  final BorderRadius? borderRadius;

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

  /// Called when the card is tapped. Makes the whole card a button: it takes
  /// keyboard focus, shows the theme's focus ring and the click cursor.
  final VoidCallback? onPressed;

  /// Whether the card is the selected one of a set — the open item of a
  /// master-detail list. A selected card takes the theme's accent fill and a
  /// tint outline in place of its hairline.
  final bool selected;

  /// The gap between the card's sections (header, child, footer). Defaults
  /// to the theme's, which is the card padding.
  final double? sectionGap;

  /// What assistive technology reads for a tappable card. The card's content,
  /// including any buttons inside it, is still read after it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGap = gap ?? theme.cardTheme.gap ?? 0;
    // Sections sit `--card-spacing` apart; the small [gap] only separates the
    // title from its description.
    final effectiveSectionGap =
        sectionGap ?? theme.cardTheme.sectionGap ?? effectiveGap;

    final themePadding =
        padding ?? theme.cardTheme.padding ?? const EdgeInsets.all(24);
    final effectiveBackgroundColor = selected
        ? backgroundColor ?? theme.colorScheme.accent
        : backgroundColor ??
              theme.cardTheme.backgroundColor ??
              theme.colorScheme.card;
    final effectiveRadius =
        borderRadius ?? theme.cardTheme.borderRadius ?? theme.radius;
    final effectiveBorder = selected
        ? border ?? FinesseBorder.all(color: theme.colorScheme.tint, width: 1.5)
        : border ??
              theme.cardTheme.border ??
              FinesseBorder.all(color: theme.colorScheme.border, width: 1);
    final effectiveShadows = shadows ?? theme.cardTheme.shadows;

    // A `Container` lays its border out as padding, so the heavier outline
    // of a selected card would push its content inwards and make the card
    // taller than its neighbours. Take the difference back out of the
    // padding so selecting a card moves nothing.
    var effectivePadding = themePadding;
    if (selected) {
      final restingBorder =
          theme.cardTheme.border ??
          FinesseBorder.all(color: theme.colorScheme.border, width: 1);
      effectivePadding = themePadding
          .add(restingBorder.toBorder().dimensions)
          .subtract(effectiveBorder.toBorder().dimensions)
          .clamp(EdgeInsets.zero, EdgeInsetsGeometry.infinity);
    }

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

    final effectiveBlur = theme.cardTheme.blur ?? 0;
    // A blurred card is only worth its backdrop layer while the fill lets
    // the backdrop through.
    final blurs = effectiveBlur > 0 && effectiveBackgroundColor.a < 1;

    final content = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      clipBehavior: effectiveClipBehavior,
      decoration: blurs
          ? BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: effectiveRadius,
              border: effectiveBorder.toBorder(),
            )
          : ShadowDecoration.box(
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
                    // A lone title is centred on its action; with a
                    // description below it, the action stays at the top.
                    crossAxisAlignment: description == null
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
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

    // The clip a backdrop filter needs would cut the card's own shadow off,
    // so the shadow is painted by a box outside it — after the card, so
    // the filter does not blur the shadow back into the glass.
    //
    // Either way the card is a layer of its own. A page is cards, and
    // anything that animates on it — a button's press, a hover fill, the
    // card's own press scale — marks the page for painting on every frame
    // it runs. With each card painted once and kept, that repaint is the
    // page's own few boxes; without, it is every paragraph of every card.
    final card = RepaintBoundary(
      child: blurs
          ? DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: ShadowDecoration.box(
                borderRadius: effectiveRadius,
                shadows: effectiveShadows ?? const [],
              ),
              child: Backdrop(
                blur: effectiveBlur,
                saturation: theme.cardTheme.saturation ?? 1,
                borderRadius: effectiveRadius,
                child: content,
              ),
            )
          : content,
    );

    if (onPressed == null) {
      return selected ? Semantics(selected: true, child: card) : card;
    }
    return Pressable(
      onPressed: onPressed,
      selected: selected ? true : null,
      semanticLabel: semanticLabel,
      // The card's content stays in the semantics tree under its label: a
      // card usually holds buttons of its own, and they must stay reachable.
      excludeSemantics: false,
      // A press is acknowledged by the whole card giving a little: far
      // less than a button, because the same factor moves a large surface
      // much further.
      pressScale:
          theme.cardTheme.pressScale ?? Motion.of(context).surfacePressScale,
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: effectiveRadius,
        child: card,
      ),
    );
  }
}
