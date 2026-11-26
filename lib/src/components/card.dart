import 'package:flutter/widgets.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/components/card.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/backdrop.dart';
import 'package:una/src/utils/border.dart';
import 'package:una/src/utils/extensions/text_style.dart';
import 'package:una/src/utils/separated_iterable.dart';
import 'package:una/src/utils/shadow.dart';

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
    this.onTap,
    this.selected = false,
    this.semanticLabel,
    this.title,
    this.description,
    this.child,
    this.footer,
    this.leading,
    this.trailing,
    this.action,
    this.style,
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
  final VoidCallback? onTap;

  /// Whether the card is the selected one of a set — the open item of a
  /// master-detail list. A selected card takes the theme's accent fill and a
  /// tint outline in place of its hairline.
  final bool selected;

  /// Overrides of the theme's `CardTheme` for this card: its padding,
  /// size, fill, border, corners, shadows, the gaps between its sections,
  /// the styles of [title] and [description] and how its row and column
  /// are laid out. It is merged over the theme, so only the fields that are
  /// set change anything.
  final CardTheme? style;

  /// What assistive technology reads for a tappable card. The card's content,
  /// including any buttons inside it, is still read after it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme.merge(style);
    final effectiveGap = cardTheme.gap ?? 0;
    // Sections sit `--card-spacing` apart; the small [gap] only separates the
    // title from its description.
    final effectiveSectionGap = cardTheme.sectionGap ?? effectiveGap;

    final themePadding = cardTheme.padding ?? const EdgeInsets.all(24);
    final effectiveBackgroundColor = selected
        ? style?.backgroundColor ?? theme.colorScheme.accent
        : cardTheme.backgroundColor ?? theme.colorScheme.card;
    final effectiveRadius = cardTheme.borderRadius ?? theme.radius;
    final effectiveBorder = selected
        ? style?.border ??
              UnaBorder.all(color: theme.colorScheme.tint, width: 1.5)
        : cardTheme.border ??
              UnaBorder.all(color: theme.colorScheme.border, width: 1);
    final effectiveShadows = cardTheme.shadows;

    // A `Container` lays its border out as padding, so the heavier outline
    // of a selected card would push its content inwards and make the card
    // taller than its neighbours. Take the difference back out of the
    // padding so selecting a card moves nothing.
    var effectivePadding = themePadding;
    if (selected) {
      final restingBorder =
          theme.cardTheme.border ??
          UnaBorder.all(color: theme.colorScheme.border, width: 1);
      effectivePadding = themePadding
          .add(restingBorder.toBorder().dimensions)
          .subtract(effectiveBorder.toBorder().dimensions)
          .clamp(EdgeInsets.zero, EdgeInsetsGeometry.infinity);
    }

    final effectiveRowMainAxisSize =
        cardTheme.rowMainAxisSize ?? MainAxisSize.min;

    final effectiveRowMainAxisAlignment =
        cardTheme.rowMainAxisAlignment ?? MainAxisAlignment.spaceBetween;

    final effectiveRowCrossAxisAlignment =
        cardTheme.rowCrossAxisAlignment ?? CrossAxisAlignment.start;

    final effectiveColumnMainAxisSize =
        cardTheme.columnMainAxisSize ?? MainAxisSize.min;

    final effectiveColumnMainAxisAlignment =
        cardTheme.columnMainAxisAlignment ?? MainAxisAlignment.start;

    final effectiveColumnCrossAxisAlignment =
        cardTheme.columnCrossAxisAlignment ?? CrossAxisAlignment.start;

    final effectiveClipBehavior = cardTheme.clipBehavior ?? Clip.antiAlias;

    final effectiveBlur = cardTheme.blur ?? 0;
    // A blurred card is only worth its backdrop layer while the fill lets
    // the backdrop through.
    final blurs = effectiveBlur > 0 && effectiveBackgroundColor.a < 1;

    final content = Container(
      width: cardTheme.width,
      height: cardTheme.height,
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
                                    (cardTheme.titleStyle ?? theme.textTheme.h3)
                                        .copyWith(
                                          color:
                                              theme.colorScheme.cardForeground,
                                        ),
                                child: title!,
                              ),
                            if (description != null)
                              DefaultTextStyle(
                                style:
                                    (cardTheme.descriptionStyle ??
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
                saturation: cardTheme.saturation ?? 1,
                borderRadius: effectiveRadius,
                child: content,
              ),
            )
          : content,
    );

    if (onTap == null) {
      return selected ? Semantics(selected: true, child: card) : card;
    }
    return Pressable(
      onPressed: onTap,
      selected: selected ? true : null,
      semanticLabel: semanticLabel,
      // The card's content stays in the semantics tree under its label: a
      // card usually holds buttons of its own, and they must stay reachable.
      excludeSemantics: false,
      // A press is acknowledged by the whole card giving a little: far
      // less than a button, because the same factor moves a large surface
      // much further.
      pressScale: cardTheme.pressScale ?? Motion.of(context).surfacePressScale,
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: effectiveRadius,
        child: card,
      ),
    );
  }
}
