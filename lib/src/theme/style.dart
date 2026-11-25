import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/radii.dart';
import 'package:finesse/src/theme/text_role.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A wash of colour a style paints behind a control or an outline button.
///
/// shadcn's styles disagree about what sits behind an outline button or an
/// unchecked checkbox: `vega` uses the page background in light and a 30%
/// `--input` wash in dark, `maia` uses the wash in both modes, `luma` fills
/// controls with `--input` at 90%, and `sera` leaves everything transparent.
/// Each value names the utility it was read from.
enum SurfaceFill {
  /// No fill at all, `bg-transparent`.
  none,

  /// The page background, `bg-background`.
  background,

  /// The muted surface, `bg-muted`.
  muted,

  /// Half the muted surface, `bg-muted/50`.
  muted50,

  /// `bg-input/20`.
  input20,

  /// `bg-input/30`.
  input30,

  /// `bg-input/50`.
  input50,

  /// `bg-input/90`.
  input90,

  /// The scheme's `card` colour at the style's strong glass opacity.
  glass,

  /// The scheme's `secondary` colour.
  secondary,

  /// The scheme's `card` colour.
  card,
}

/// The metrics that distinguish one shadcn/ui *style* from another.
///
/// shadcn ships eight named styles, of which finesse keeps three — [nova],
/// [maia] and [lyra] — beside its own [finesse]. They are not colour
/// variations — they are full geometry sets. Comparing `registry/styles/style-*.css` shows the same
/// components rebuilt at different sizes: a `mira` button is 28px tall with 8px
/// of horizontal padding while a `sera` button is 40px tall with 24px, and
/// everything around them — inputs, menu rows, card padding, slider tracks,
/// switch dimensions — moves with it.
///
/// They also retype it. Each style redefines a handful of [TextRole]s —
/// title, label, body, caption, overline and field — so `lyra` sets body copy
/// at 12px, `mira` puts it on a relaxed line, and `sera` sets labels in 12px
/// semibold uppercase with wide tracking. Shadows move too: `nova` drops the
/// card shadow entirely, `maia` gives popovers a 2xl one.
///
/// The headline differences, in logical pixels:
///
/// | style | button h / px | body | title | card pad | slider | ring |
/// | ----- | ------------- | ---- | ----- | -------- | ------ | ---- |
/// | vega  | 36 / 10 | 14 | 16 | 24 | 6  | 3 @ 50% |
/// | nova  | 32 / 10 | 14 | 16 | 16 | 4  | 3 @ 50% |
/// | maia  | 36 / 12 | 14 | 16 | 24 | 12 | 3 @ 50% |
/// | lyra  | 32 / 10 | 12 | 14 | 16 | 4  | 1 @ 50% |
/// | mira  | 28 / 8  | 12 | 14 | 16 | 4  | 2 @ 30% |
/// | luma  | 36 / 12 | 14 | 16 | 24 | 8  | 3 @ 30% |
/// | sera  | 40 / 24 | 14 | 18 | 32 | 2  | 2 @ 30% |
/// | rhea  | 32 / 12 | 14 | 16 | 20 | 4  | 3 @ 30% |
///
/// Every value here was read from shadcn's own CSS, converting Tailwind's
/// scale at 4px per unit (`px-2.5` is 10, `h-9` is 36). Passing one of these
/// to a theme variant reshapes every component at once, which is what makes a
/// style switch a single setting rather than a second theme.
///
/// The field defaults here are shadcn's `vega`, so a custom style only has to
/// state what it changes. That is separate from the *theme's* default style,
/// which is [finesse].
@immutable
class StyleTokens {
  /// Creates a style. Only [name] is required; every other field defaults to
  /// the value of shadcn's base style, `vega`.
  const StyleTokens({
    required this.name,
    // Radii.
    this.buttonRadius = RadiusToken.md,
    this.cardRadius = RadiusToken.xl,
    this.dialogRadius = RadiusToken.xl,
    this.popoverRadius = RadiusToken.md,
    this.tooltipRadius = RadiusToken.md,
    this.commandRadius = RadiusToken.xl,
    this.commandItemDialogRadius = RadiusToken.lg,
    this.commandSearchRadius = RadiusToken.lg,
    this.textareaRadius = RadiusToken.md,
    this.itemRadius = RadiusToken.sm,
    this.checkboxRadius = 4,
    // Focus ring.
    this.cardBorderOpacity = .1,
    this.cardBorderOpacityDark,
    this.surfaceBorderOpacity = .1,
    this.surfaceBorderOpacityDark,
    this.dialogBorderOpacity,
    this.dialogBorderOpacityDark,
    this.surfaceRadiusCap,
    this.ringWidth = 3,
    this.ringOpacity = .5,
    // Typography, by role.
    this.title = const TextRole(fontSize: 16, fontWeight: FontWeight.w500),
    this.label = const TextRole(fontSize: 14, fontWeight: FontWeight.w500),
    this.body = const TextRole(fontSize: 14),
    this.caption = const TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.overline = const TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.field = const TextRole(fontSize: 14),
    // Shadows.
    this.cardShadow = Shadows.xs,
    this.popoverShadow = Shadows.md,
    this.dialogShadow = Shadows.none,
    this.sheetShadow = Shadows.lg,
    // Buttons and toggles.
    this.outlineButtonFill = SurfaceFill.background,
    this.outlineButtonFillDark = SurfaceFill.input30,
    this.outlineButtonHoverFill = SurfaceFill.muted,
    this.outlineButtonHoverFillDark = SurfaceFill.input50,
    this.outlineButtonDarkInputBorder = true,
    this.linkUnderline = false,
    this.flatBadges = false,
    this.controlShadow = Shadows.xs,
    this.buttonHeight = 36,
    this.buttonHeightSm = 32,
    this.buttonHeightLg = 40,
    this.buttonPaddingX = 10,
    this.buttonPaddingXSm = 10,
    this.buttonPaddingXLg = 10,
    this.buttonGap = 6,
    this.buttonIconSize = 16,
    this.buttonIconSizeSm = 16,
    this.buttonIconSizeLg = 16,
    this.toggleIconSize = 16,
    this.badgeIconSize = 12,
    this.iconButtonSize = 36,
    this.iconButtonSizeSm = 32,
    this.iconButtonSizeLg = 40,
    this.iconButtonIconSize = 16,
    this.iconButtonIconSizeSm = 16,
    this.iconButtonIconSizeLg = 16,
    // Text fields.
    this.inputHeight = 36,
    this.inputPaddingX = 10,
    this.inputPaddingY = 4,
    this.textareaPaddingX = 10,
    this.textareaPaddingY = 10,
    this.underlinedFields = false,
    this.fieldFill = SurfaceFill.none,
    this.fieldFillDark = SurfaceFill.input30,
    this.fieldBorderless = false,
    // Select and menus.
    this.selectPaddingX = 10,
    this.menuPadding = 4,
    this.menuMinWidth = 128,
    this.itemPaddingX = 8,
    this.itemPaddingY = 6,
    this.menubarHeight = 36,
    this.menubarPadding = 4,
    // Calendar.
    this.calendarCellSize = 32,
    this.calendarCellRadius = RadiusToken.md,
    this.calendarPadding = 12,
    this.calendarCaptionHeight = 32,
    // Command palette.
    this.commandPadding = 4,
    this.commandGroupPadding = 4,
    this.commandSearchHeight = 32,
    this.commandSearchFill = SurfaceFill.input30,
    this.commandSearchFillDark = SurfaceFill.input30,
    this.commandSearchBorderOpacity = .3,
    this.commandSearchUnderline = false,
    // Sidebar.
    this.sidebarItemHeight = 32,
    this.sidebarItemHeightSm = 28,
    this.sidebarItemHeightLg = 48,
    this.sidebarItemPaddingX = 8,
    this.sidebarSubItemPaddingX = 8,
    // Selection controls.
    this.controlFill = SurfaceFill.none,
    this.controlFillDark = SurfaceFill.input30,
    this.controlBorderless = false,
    this.radioCheckedOutline = false,
    this.checkboxSize = 16,
    this.radioSize = 16,
    this.switchWidth = 32,
    this.switchHeight = 18.4,
    this.switchThumbSize = 16,
    this.sliderTrackHeight = 6,
    this.sliderThumbSize = 16,
    this.sliderTrackFill = SurfaceFill.muted,
    this.sliderThumbFilled = false,
    // Surfaces.
    this.cardPadding = 24,
    this.cardGap = 4,
    this.dialogPadding = 24,
    this.dialogGap = 8,
    this.popoverPadding = 16,
    // Everything else.
    this.tabsListPadding = 3,
    this.tabsListRadius = RadiusToken.lg,
    this.tabRadius = RadiusToken.md,
    this.tabSelectedShadow = Shadows.sm,
    this.tabPaddingX = 8,
    this.tabPaddingY = 4,
    this.accordionTitlePaddingY = 16,
    this.alertRadius = RadiusToken.lg,
    this.alertPaddingX = 16,
    this.alertPaddingY = 12,
    this.alertGap = 2,
    this.alertIconGap = 10,
    this.alertIconSize = 16,
    this.alertIconOffset = 2,
    this.alertAccentBar = false,
    this.tableCellPadding = 8,
    this.kbdHeight = 20,
    this.kbdPaddingX = 4,
    this.progressHeight = 6,
    // Finesse additions.
    this.radius = 8,
    this.radiusScale = const RadiusScale(),
    this.iconButtonRadius,
    this.badgeRadius,
    this.badgeHeight,
    this.badgePaddingX = 8,
    this.outlineButtonStrongBorder = false,
    this.glassBlur = 24,
    this.glassSaturation = 1.6,
    this.glassOpacity = .7,
    this.glassOpacityDark,
    this.glassStrongOpacity = .9,
    this.barOpacity = 1,
    this.barOpacityDark,
    this.cardOpacity = 1,
    this.cardOpacityDark,
    this.cardBlur = false,
    this.popoverOpacity = 1,
    this.popoverOpacityDark,
    this.tooltipOpacity = 1,
    this.tooltipOpacityDark,
    this.menuHighlightOpacity,
    this.menuHighlightOpacityDark,
    this.tableHoverOpacity = .5,
    this.tableSelectionTinted = false,
    this.cardShadowDark,
    this.floatingShadow = Shadows.lg,
    this.floatingShadowDark,
    this.pagePaddingX = 24,
    this.pagePaddingY = 24,
    this.pageMaxWidth = 1280,
    this.gapXs = 4,
    this.gapSm = 8,
    this.gapMd = 12,
    this.gapLg = 16,
    this.gapXl = 24,
    this.appBarHeight = 64,
    this.fabSize = 48,
    this.fabSizeSm = 40,
    this.fabSizeLg = 64,
    this.navigationItemWidth = 88,
    this.navigationIconSize = 24,
    this.navigationIndicatorHeight = 3,
    this.bottomNavigationItemWidth = 52,
    this.bottomNavigationItemHeight = 48,
    this.bottomNavigationIconSize = 26,
    this.bottomNavigationPadding = 6,
    this.bottomNavigationFloating = true,
    this.bottomNavigationOpacity,
    this.bottomNavigationOpacityDark,
    this.bottomNavigationLift = 0,
    this.bottomNavigationLiftDark,
    this.bottomNavigationBorderOpacity,
    this.bottomNavigationBorderOpacityDark,
    this.bottomNavigationRimOpacity,
    this.bottomNavigationRimOpacityDark,
    this.chipHeight = 32,
    this.chipPaddingX = 12,
    this.chipGap = 6,
    this.chipIconSize = 16,
    this.chipRadius = RadiusToken.full,
    this.listTilePaddingX = 12,
    this.listTilePaddingY = 10,
    this.listTileGap = 12,
    this.chatBubbleRadius = 18,
    this.chatBubbleTailRadius = 6,
    this.chatBubblePaddingX = 14,
    this.chatBubblePaddingY = 10,
    this.tabHeight,
    this.underlineTabHeight = 48,
    this.avatarSize = 32,
    this.display,
    this.headline,
    this.subtitle,
    this.small,
    this.concentricTabs = false,
    this.secondaryButtonFill = SurfaceFill.secondary,
    this.secondaryBadgeFill = SurfaceFill.secondary,
    this.secondaryBadgeSubtle = false,
    this.progressTrackFill = SurfaceFill.muted,
    this.progressTinted = false,
    this.dividerMargin = 16,
    this.timelineLineGap = 6,
    this.iconOpticalSize = 24,
    this.iconOpticalStrength = .5,
    this.tabsListFill = SurfaceFill.muted,
    this.tabSelectedFill = SurfaceFill.background,
    this.tabUnselectedMuted = false,
    this.tabsGap = 0,
    this.motion = Motion.calm,
    this.mobile,
  });

  /// The shadcn/ui name of this style, e.g. `nova`.
  final String name;

  // --- Radii --------------------------------------------------------------

  /// Corner radius of buttons, inputs, toggles and other controls.
  final RadiusToken buttonRadius;

  /// Corner radius of cards.
  final RadiusToken cardRadius;

  /// Corner radius of dialogs and sheets.
  final RadiusToken dialogRadius;

  /// Corner radius of popovers, select and menu surfaces.
  final RadiusToken popoverRadius;

  /// Corner radius of a tooltip (`.cn-tooltip-content`), `rounded-md` —
  /// tighter than the popover's in most styles.
  final RadiusToken tooltipRadius;

  /// Corner radius of a command palette (`.cn-command`).
  final RadiusToken commandRadius;

  /// Corner radius of a command item shown inside a dialog — shadcn rounds
  /// them a step up there (`in-data-[slot=dialog-content]:rounded-lg!`),
  /// while inline palettes keep [itemRadius].
  final RadiusToken commandItemDialogRadius;

  /// Corner radius of the command palette's search box
  /// (`.cn-command-input-group rounded-lg!`).
  final RadiusToken commandSearchRadius;

  /// Corner radius of a textarea.
  ///
  /// Separate from [buttonRadius] because shadcn keeps it moderate even in the
  /// pill-shaped styles: `maia` has `rounded-4xl` buttons but a `rounded-xl`
  /// textarea, since a 32px radius on a tall box eats into the text.
  final RadiusToken textareaRadius;

  /// Corner radius of rows inside a surface, e.g. menu and select items.
  final RadiusToken itemRadius;

  /// Corner radius of a checkbox, in logical pixels.
  ///
  /// shadcn hardcodes this one (`rounded-[4px]`) rather than deriving it: a
  /// checkbox is too small for the scale to look right on it.
  final double checkboxRadius;

  // --- Focus ring ---------------------------------------------------------

  /// Opacity of a card's hairline outline, shadcn's `ring-foreground/10`.
  ///
  /// A card is outlined with a wash of its own foreground rather than the
  /// `--border` token, so the line stays proportionate on any surface.
  final double cardBorderOpacity;

  /// [cardBorderOpacity] in dark mode, where a wash of a light foreground
  /// needs more alpha to read; `luma` and `rhea` use `/5` light and `/10`
  /// dark. Null means "same as light".
  final double? cardBorderOpacityDark;

  /// Opacity of a popover or menu outline.
  final double surfaceBorderOpacity;

  /// [surfaceBorderOpacity] in dark mode. Null means "same as light".
  final double? surfaceBorderOpacityDark;

  /// Opacity of a dialog or sheet outline, where it differs from
  /// [surfaceBorderOpacity]; `maia` keeps its dialogs at `/5` in both modes
  /// while its menus go `/5` light, `/10` dark. Null means "same as surface".
  final double? dialogBorderOpacity;

  /// [dialogBorderOpacity] in dark mode. Null falls back to
  /// [dialogBorderOpacity], then the surface pair.
  final double? dialogBorderOpacityDark;

  /// A ceiling in logical pixels for card and dialog corner radii.
  ///
  /// `rhea` writes `rounded-[min(var(--radius-4xl),24px)]`: the 4xl step,
  /// capped so a large theme radius cannot balloon a card's corners.
  final double? surfaceRadiusCap;

  /// Focus-ring thickness, shadcn's `focus-visible:ring-N`.
  final double ringWidth;

  /// Focus-ring alpha, the `/50` in `ring-ring/50`.
  final double ringOpacity;

  // --- Typography ---------------------------------------------------------

  /// Card and dialog titles.
  final TextRole title;

  /// Interactive labels: buttons, toggles, tabs and form labels.
  final TextRole label;

  /// Body copy: descriptions, menu rows, popover content, table cells.
  final TextRole body;

  /// Small supporting text: badges, keyboard keys, command shortcuts.
  final TextRole caption;

  /// Section headings inside a surface: menu group labels, table headers.
  final TextRole overline;

  /// Text inside a field: input, textarea, select trigger.
  final TextRole field;

  // --- Shadows ------------------------------------------------------------

  /// The shadow under a card, `shadow-xs` by default.
  final List<BoxShadow> cardShadow;

  /// The shadow under popovers and menus, `shadow-md` by default.
  final List<BoxShadow> popoverShadow;

  /// The shadow under a dialog. None by default.
  final List<BoxShadow> dialogShadow;

  /// The shadow under a sheet, `shadow-lg` by default.
  final List<BoxShadow> sheetShadow;

  // --- Buttons ------------------------------------------------------------

  /// What an outline button paints behind itself in light mode.
  ///
  /// `vega` uses the page background, `maia` an `input/30` wash, `sera`
  /// nothing at all.
  final SurfaceFill outlineButtonFill;

  /// What an outline button paints behind itself in dark mode,
  /// shadcn's `dark:bg-input/30`.
  final SurfaceFill outlineButtonFillDark;

  /// The hover fill of an outline or ghost-adjacent button in light mode,
  /// shadcn's `hover:bg-muted`.
  final SurfaceFill outlineButtonHoverFill;

  /// The hover fill of an outline button in dark mode,
  /// shadcn's `dark:hover:bg-input/50`.
  final SurfaceFill outlineButtonHoverFillDark;

  /// Whether an outline button's dark-mode border uses `--input` rather than
  /// `--border` (`dark:border-input`). True in `vega`, `nova` and `lyra`;
  /// the other styles keep `--border` in both modes.
  final bool outlineButtonDarkInputBorder;

  /// Whether a link button is underlined at rest rather than only on hover.
  /// `sera` does this.
  final bool linkUnderline;

  /// Whether badges are bare text — no fill, border or padding, set in the
  /// style's uppercase caption. `sera` does this.
  final bool flatBadges;

  /// The shadow behind outline buttons and unchecked selection controls,
  /// shadcn's `shadow-xs`. Only `vega` keeps it.
  final List<BoxShadow> controlShadow;

  /// Height of a default-size button, shadcn's `h-9`.
  final double buttonHeight;

  /// Height of a small button, shadcn's `h-8`.
  final double buttonHeightSm;

  /// Height of a large button, shadcn's `h-10`.
  final double buttonHeightLg;

  /// Horizontal padding of a default-size button, shadcn's `px-2.5`.
  final double buttonPaddingX;

  /// Horizontal padding of a small button, shadcn's `px-2.5`.
  final double buttonPaddingXSm;

  /// Horizontal padding of a large button, shadcn's `px-2.5`.
  final double buttonPaddingXLg;

  /// Space between a button's icon and its label, shadcn's `gap-1.5`.
  final double buttonGap;

  /// Side of an icon inside a button, shadcn's
  /// `[&_svg:not([class*='size-'])]:size-4`.
  ///
  /// The `:not` is why an [Icon] with its own `size` still wins: these are
  /// only the default handed down through the button's `IconTheme`. Most
  /// styles keep 16 at every size; `mira` and `sera` shrink it, and `lyra`,
  /// `mira` and `nova` shrink it further on the small button only.
  final double buttonIconSize;

  /// Side of an icon inside a small button. See [buttonIconSize].
  final double buttonIconSizeSm;

  /// Side of an icon inside a large button. See [buttonIconSize].
  final double buttonIconSizeLg;

  /// Icon size inside a toggle: `.cn-toggle`'s
  /// `[&_svg:not([class*='size-'])]:size-*`. 16 in every style but sera (14).
  final double toggleIconSize;

  /// Icon size inside a badge: `.cn-badge`'s `[&>svg]:size-*`. 12 in every
  /// style but mira (10).
  final double badgeIconSize;

  /// Side of a square icon button, shadcn's `size-9`.
  final double iconButtonSize;

  /// Side of a small icon button, shadcn's `size-8`.
  final double iconButtonSizeSm;

  /// Side of a large icon button, shadcn's `size-10`.
  final double iconButtonSizeLg;

  /// Side of the icon inside one.
  ///
  /// Kept apart from [buttonIconSize] because the reference's
  /// `.cn-button-size-icon-sm` does *not* repeat the small button's smaller
  /// glyph: a 28px icon button keeps the 16px icon that a 28px text button
  /// shrinks to 14.
  final double iconButtonIconSize;

  /// Side of the icon inside a small icon button. See [iconButtonIconSize].
  final double iconButtonIconSizeSm;

  /// Side of the icon inside a large icon button. See [iconButtonIconSize].
  final double iconButtonIconSizeLg;

  // --- Text fields --------------------------------------------------------

  /// Minimum height of a single-line input.
  final double inputHeight;

  /// Horizontal padding of a single-line input, shadcn's `px-2.5`.
  final double inputPaddingX;

  /// Vertical padding of a single-line input, shadcn's `py-1`.
  final double inputPaddingY;

  /// Horizontal padding of a textarea, shadcn's `px-2.5`.
  final double textareaPaddingX;

  /// Vertical padding of a textarea.
  ///
  /// Two pixels above shadcn's `py-2`. A browser textarea's first line is
  /// pushed down by half of its line box's leading; Flutter's `EditableText`
  /// starts the glyphs at the top of the box instead, so the same number reads
  /// tighter here.
  final double textareaPaddingY;

  /// Whether fields are drawn as a single underline rather than a box.
  ///
  /// `sera` does this — `border-transparent border-b-input` — and it is the
  /// most visible thing about the style after its uppercase labels.
  final bool underlinedFields;

  /// What a text field, textarea or select trigger paints behind itself in
  /// light mode. `bg-transparent` in most styles; `maia` uses `input/30`,
  /// `mira` `input/20`, `luma` and `rhea` `input/50`.
  final SurfaceFill fieldFill;

  /// The field fill in dark mode, shadcn's `dark:bg-input/30`.
  final SurfaceFill fieldFillDark;

  /// Whether fields drop their `--input` outline (`border-transparent`),
  /// relying on [fieldFill] instead. `luma` and `rhea` do this.
  final bool fieldBorderless;

  // --- Select and menus ---------------------------------------------------

  /// Horizontal padding of a select trigger. There is no vertical
  /// counterpart: the reference pins the trigger at [inputHeight]
  /// (`data-[size=default]:h-9`), which makes its `py-2` inert.
  final double selectPaddingX;

  /// Padding around the rows of a menu surface, shadcn's `p-1`.
  final double menuPadding;

  /// Minimum width of a dropdown or context menu, shadcn's `min-w-32`.
  final double menuMinWidth;

  /// Padding of a single menu or select row.
  final double itemPaddingX;

  /// Vertical padding of a single menu or select row, shadcn's `py-1.5`.
  final double itemPaddingY;

  /// Height of the menubar strip, shadcn's `h-9`.
  final double menubarHeight;

  /// Padding inside the menubar strip around its triggers, shadcn's `p-1`.
  /// A bracketed literal in some styles (`p-[3px]`), so it is not scaled.
  final double menubarPadding;

  // --- Calendar -----------------------------------------------------------

  /// The calendar's `--cell-size`: the square day cells, the navigation
  /// buttons and the caption row are all this tall. `--spacing(8)` in most
  /// styles, `--spacing(7)` in `nova`/`lyra`, `--spacing(6)` in `mira`.
  final double calendarCellSize;

  /// The calendar's `--cell-radius`, rounding day cells and the month/year
  /// dropdown triggers. Deliberately its own token: `vega`'s buttons are
  /// `rounded-lg` while its calendar cells are `rounded-md`.
  final RadiusToken calendarCellRadius;

  /// Padding around the whole calendar, `.cn-calendar`'s `p-3` —
  /// `p-2` in `nova` and `lyra`.
  final double calendarPadding;

  /// Height of the month/year dropdown triggers,
  /// `.cn-calendar-caption-label`'s `h-8` — `h-6` in `nova`/`lyra`,
  /// `h-7` in `mira`. Independent of [calendarCellSize]: `mira`'s caption
  /// is taller than its cells.
  final double calendarCaptionHeight;

  // --- Command palette ----------------------------------------------------

  /// Padding inside the palette around the search box and the list,
  /// `.cn-command`'s `p-1`. `lyra` and `sera` run flush.
  final double commandPadding;

  /// Padding around each group of items, `.cn-command-group`'s `p-1`.
  final double commandGroupPadding;

  /// Height of the search box, `.cn-command-input-group`'s `h-8!` —
  /// `h-9` in the roomier styles, `h-10` in `sera`.
  final double commandSearchHeight;

  /// The wash behind the search box, `bg-input/30` in most styles.
  final SurfaceFill commandSearchFill;

  /// The dark-mode wash behind the search box, where it differs
  /// (`mira` is `bg-input/20 dark:bg-input/30`).
  final SurfaceFill commandSearchFillDark;

  /// Opacity of the search box's `--input` outline, `border-input/30`.
  /// Zero in the borderless styles.
  final double commandSearchBorderOpacity;

  /// Whether the search box underlines instead of boxing: `sera` keeps only
  /// `border-b-input`, and `lyra` puts a `border-b` on the wrapper.
  final bool commandSearchUnderline;

  // --- Sidebar ------------------------------------------------------------

  /// Height of a sidebar menu button, shadcn's `h-8` (`h-9` in the roomier
  /// styles). The sm/lg sizes shift with it.
  final double sidebarItemHeight;

  /// Height of a small sidebar menu button, shadcn's `h-7`.
  final double sidebarItemHeightSm;

  /// Height of a large sidebar menu button, shadcn's `h-12`.
  final double sidebarItemHeightLg;

  /// Horizontal padding of a sidebar menu button and group label, shadcn's
  /// `p-2`/`px-2` (`px-3` in the roomier styles).
  final double sidebarItemPaddingX;

  /// Horizontal padding of a sidebar sub-menu button, shadcn's `px-2`
  /// (`px-3` in `luma`, `sera` and `rhea`).
  final double sidebarSubItemPaddingX;

  // --- Selection controls -------------------------------------------------

  /// The fill of an unchecked checkbox or radio in light mode.
  ///
  /// Transparent in most styles; `luma` and `rhea` fill their controls with
  /// `bg-input/90` instead of outlining them.
  final SurfaceFill controlFill;

  /// The fill of an unchecked checkbox or radio in dark mode,
  /// shadcn's `dark:bg-input/30`.
  final SurfaceFill controlFillDark;

  /// Whether checkboxes and radios draw no outline (`border-transparent`),
  /// relying on [controlFill] instead. `luma` and `rhea` do this.
  final bool controlBorderless;

  /// Whether a checked radio keeps its outline form — border recoloured to
  /// the foreground with a plain dot — rather than filling with the primary.
  /// `sera` does this (`data-checked:border-foreground`).
  final bool radioCheckedOutline;

  /// Side of a checkbox, shadcn's `size-4`.
  final double checkboxSize;

  /// Side of a radio button, shadcn's `size-4`.
  final double radioSize;

  /// Track dimensions of a switch.
  final double switchWidth;

  /// Height of a switch track, shadcn's `h-[18.4px]`. Not scaled.
  final double switchHeight;

  /// Diameter of a switch thumb; the inset is what is left over.
  final double switchThumbSize;

  /// Thickness of a slider track, shadcn's `h-1.5`.
  final double sliderTrackHeight;

  /// Diameter of a slider thumb, shadcn's `size-4`.
  final double sliderThumbSize;

  /// The slider's inactive track, `bg-muted` (`input/90` in `luma` and
  /// `rhea`, `input/50` in `sera`).
  final SurfaceFill sliderTrackFill;

  /// Whether the slider thumb is a solid primary dot rather than a white
  /// bordered one. `sera` does this.
  final bool sliderThumbFilled;

  // --- Surfaces -----------------------------------------------------------

  /// Card padding, shadcn's `--card-spacing`.
  final double cardPadding;

  /// Space between a card's title, description, content and footer.
  final double cardGap;

  /// Padding inside a dialog, shadcn's `p-6`.
  final double dialogPadding;

  /// Space between a dialog's stacked children — title, description, body and
  /// actions.
  ///
  /// shadcn splits this in two: `gap-6` between a dialog's sections and
  /// `gap-2` inside its header. `Dialog` stacks all four children
  /// uniformly, so this carries the header value, which is the one that shows.
  final double dialogGap;

  /// Padding inside a popover, shadcn's `p-4`.
  final double popoverPadding;

  // --- Everything else ----------------------------------------------------

  /// Padding of the strip a tab bar's tabs sit in, shadcn's `p-[3px]`.
  final double tabsListPadding;

  /// Corner radius of the tab strip, shadcn's `rounded-lg`.
  final RadiusToken tabsListRadius;

  /// Corner radius of a single tab, shadcn's `rounded-md` — one step inside
  /// the strip's.
  final RadiusToken tabRadius;

  /// The shadow under the active tab, `data-active:shadow-sm`. Only `vega`
  /// and `nova` keep it.
  final List<BoxShadow> tabSelectedShadow;

  /// Horizontal padding of a single tab, shadcn's `px-2`.
  final double tabPaddingX;

  /// Vertical padding of a single tab, shadcn's `py-1`.
  final double tabPaddingY;

  /// Vertical padding of an accordion's title row.
  final double accordionTitlePaddingY;

  /// Corner radius of an alert, `rounded-lg` — one step below the card's in
  /// most styles.
  final RadiusToken alertRadius;

  /// Horizontal padding of an alert, shadcn's `px-4`.
  final double alertPaddingX;

  /// Vertical padding of an alert, shadcn's `py-3`.
  final double alertPaddingY;

  /// Vertical gap between an alert's title and description, `gap-0.5`.
  final double alertGap;

  /// Column gap between an alert's icon and its text,
  /// `has-[>svg]:gap-x-2.5`.
  final double alertIconGap;

  /// Default size of an alert's icon,
  /// `*:[svg:not([class*='size-'])]:size-4`.
  final double alertIconSize;

  /// The icon's downward nudge, `*:[svg]:translate-y-0.5`, lining the glyph
  /// up with the title's cap height.
  final double alertIconOffset;

  /// Whether alerts draw `sera`'s 2px accent bar along their start edge
  /// (`after:w-0.5 after:bg-foreground`), recoloured per variant.
  final bool alertAccentBar;

  /// Padding inside a table cell, shadcn's `p-2`.
  final double tableCellPadding;

  /// Height of a keyboard key, shadcn's `h-5`.
  final double kbdHeight;

  /// Horizontal padding of a keyboard key, shadcn's `px-1`.
  final double kbdPaddingX;

  /// Thickness of a progress bar, shadcn's `h-1.5`.
  final double progressHeight;

  /// The base (`md`) corner radius this style implies, in logical pixels.
  ///
  /// `ThemeData` uses it when no `radius` is given.
  final double radius;

  /// How the other radius steps are derived from the base radius.
  final RadiusScale radiusScale;

  /// The corner radius of icon buttons. Null follows [buttonRadius].
  final RadiusToken? iconButtonRadius;

  /// The corner radius of badges. Null makes them pills, or squares in a
  /// style whose [buttonRadius] is [RadiusToken.none].
  final RadiusToken? badgeRadius;

  /// The fixed height of a badge. Null sizes it from its padding.
  final double? badgeHeight;

  /// Horizontal padding of a badge.
  final double badgePaddingX;

  /// Whether outline buttons take the scheme's `borderStrong` rather than
  /// its `border`.
  final bool outlineButtonStrongBorder;

  /// The backdrop blur sigma behind glass surfaces and bars.
  final double glassBlur;

  /// How much glass saturates what shows through it; 1 leaves it alone.
  final double glassSaturation;

  /// The opacity of a regular glass surface's tint.
  final double glassOpacity;

  /// [glassOpacity] on a dark scheme. Null uses [glassOpacity].
  final double? glassOpacityDark;

  /// The opacity of a strong glass surface's tint, and of the `glass`
  /// [SurfaceFill].
  final double glassStrongOpacity;

  /// The opacity of app and navigation bars. Below 1 they blur what
  /// scrolls beneath them.
  final double barOpacity;

  /// [barOpacity] on a dark scheme. Null uses [barOpacity].
  final double? barOpacityDark;

  /// The opacity of a card's fill.
  final double cardOpacity;

  /// [cardOpacity] on a dark scheme. Null uses [cardOpacity].
  final double? cardOpacityDark;

  /// Whether a translucent card blurs what is behind it.
  ///
  /// Off in every shipped style. A card normally lies on the flat page,
  /// where a blur shows nothing and still costs a backdrop filter — a
  /// read-back and a blur of everything under the card, on every frame the
  /// card is on screen — and a feed is a card per item. Turn it on for a
  /// style whose cards float over imagery; the bars, popovers, menus and
  /// `Glass` are glass regardless.
  final bool cardBlur;

  /// The opacity of floating surfaces: popovers, dropdown and context
  /// menus, the menubar's menus, a select's list and the command palette.
  /// Below 1 they are glass — the popover colour at this opacity over a
  /// backdrop blurred by [glassBlur] and saturated by [glassSaturation].
  ///
  /// `ThemeData.menuTranslucent` overrides it for the menus: true gives
  /// them shadcn's translucent finish whatever the style, false keeps them
  /// solid.
  final double popoverOpacity;

  /// [popoverOpacity] on a dark scheme. Null uses [popoverOpacity].
  final double? popoverOpacityDark;

  /// The opacity of a tooltip's bubble. Below 1 it is glass, like
  /// [popoverOpacity].
  final double tooltipOpacity;

  /// [tooltipOpacity] on a dark scheme. Null uses [tooltipOpacity].
  final double? tooltipOpacityDark;

  /// How much of the menu's foreground washes the highlighted row of a
  /// menu, a select's list and the command palette, with the row's text
  /// and icons keeping their resting colour.
  ///
  /// Null, the default, is shadcn's `focus:bg-accent
  /// focus:text-accent-foreground` (`bg-muted` in the command palette): an
  /// opaque fill, which is right on a solid menu and reads as a bright slab
  /// on a glass one. A bold `ThemeData.menuAccent` fills the row with the
  /// primary either way — it asks for exactly that.
  final double? menuHighlightOpacity;

  /// [menuHighlightOpacity] on a dark menu. Null uses
  /// [menuHighlightOpacity].
  final double? menuHighlightOpacityDark;

  /// How much of the scheme's `muted` colour a hovered table row is washed
  /// with. shadcn's `hover:bg-muted/50` is the default; a scheme whose
  /// `muted` is already a faint wash, like teal's, takes all of it.
  final double tableHoverOpacity;

  /// Whether a selected table row is tinted with the scheme's `tint` rather
  /// than filled with its `muted` colour (`data-[state=selected]:bg-muted`).
  final bool tableSelectionTinted;

  /// [cardShadow] on a dark scheme. Null uses [cardShadow].
  final List<BoxShadow>? cardShadowDark;

  /// The shadow under floating chrome such as a floating navigation bar.
  final List<BoxShadow> floatingShadow;

  /// [floatingShadow] on a dark scheme. Null uses [floatingShadow].
  ///
  /// A shadow tuned for a light page barely registers on a dark one; this
  /// is where a style asks for a deeper, wider one.
  final List<BoxShadow>? floatingShadowDark;

  /// Horizontal padding between the window edge and page content.
  final double pagePaddingX;

  /// Vertical padding above and below page content.
  final double pagePaddingY;

  /// The widest page content grows before it is centred.
  final double pageMaxWidth;

  /// The `xs` step of the layout gap scale.
  final double gapXs;

  /// The `sm` step of the layout gap scale.
  final double gapSm;

  /// The `md` step of the layout gap scale.
  final double gapMd;

  /// The `lg` step of the layout gap scale.
  final double gapLg;

  /// The `xl` step of the layout gap scale.
  final double gapXl;

  /// The height of an app bar.
  final double appBarHeight;

  /// The height of a floating action button, and its width without a label.
  final double fabSize;

  /// [fabSize] for a small floating action button.
  final double fabSizeSm;

  /// [fabSize] for a large floating action button.
  final double fabSizeLg;

  /// The width of a destination in a top navigation bar.
  final double navigationItemWidth;

  /// The icon size of a navigation destination.
  final double navigationIconSize;

  /// The thickness of a top navigation bar's selection indicator.
  final double navigationIndicatorHeight;

  /// The width of a destination in a bottom navigation bar.
  final double bottomNavigationItemWidth;

  /// The height of a destination in a bottom navigation bar.
  final double bottomNavigationItemHeight;

  /// The icon size of a bottom navigation destination.
  final double bottomNavigationIconSize;

  /// The padding inside a floating bottom navigation bar.
  final double bottomNavigationPadding;

  /// Whether the bottom navigation bar floats as a pill above the page
  /// rather than spanning the bottom edge.
  final bool bottomNavigationFloating;

  /// The opacity of the bottom navigation bar's fill, where it is to be
  /// thinner than the other bars. Null uses [barOpacity].
  ///
  /// It only ever thins the bar: the lower of this and [barOpacity] is
  /// used, and with a [barOpacity] of 1 the bottom bar is solid like the
  /// rest.
  final double? bottomNavigationOpacity;

  /// [bottomNavigationOpacity] on a dark scheme. Null uses
  /// [bottomNavigationOpacity].
  final double? bottomNavigationOpacityDark;

  /// How much of the scheme's foreground is mixed into the bottom
  /// navigation bar's fill before it is made translucent: 0 leaves the
  /// scheme's `bar` colour alone.
  ///
  /// It lifts a floating bar off a page of its own colour — on a dark
  /// scheme the bar and the page are a shade apart, and no shadow shows
  /// between them.
  final double bottomNavigationLift;

  /// [bottomNavigationLift] on a dark scheme. Null uses
  /// [bottomNavigationLift].
  final double? bottomNavigationLiftDark;

  /// The opacity of the foreground wash a floating bottom navigation bar's
  /// hairline is drawn in. Null draws it in the scheme's `border`.
  final double? bottomNavigationBorderOpacity;

  /// [bottomNavigationBorderOpacity] on a dark scheme. Null uses
  /// [bottomNavigationBorderOpacity].
  final double? bottomNavigationBorderOpacityDark;

  /// The opacity of the foreground wash along the top edge of a floating
  /// bottom navigation bar's hairline, which fades into the rest of the
  /// hairline on the way down — the rim of a sheet of glass lit from
  /// above. Null gives the hairline one colour all the way round.
  final double? bottomNavigationRimOpacity;

  /// [bottomNavigationRimOpacity] on a dark scheme. Null uses
  /// [bottomNavigationRimOpacity].
  final double? bottomNavigationRimOpacityDark;

  /// The height of a chip.
  final double chipHeight;

  /// Horizontal padding of a chip.
  final double chipPaddingX;

  /// The gap between a chip's icon and label.
  final double chipGap;

  /// The icon size inside a chip.
  final double chipIconSize;

  /// The corner radius of a chip.
  final RadiusToken chipRadius;

  /// Horizontal padding of a list tile.
  final double listTilePaddingX;

  /// Vertical padding of a list tile.
  final double listTilePaddingY;

  /// The gap between a list tile's leading widget, text and trailing
  /// widget.
  final double listTileGap;

  /// The corner radius of a chat bubble.
  final double chatBubbleRadius;

  /// The radius of a chat bubble's tail corner.
  final double chatBubbleTailRadius;

  /// Horizontal padding of a chat bubble.
  final double chatBubblePaddingX;

  /// Vertical padding of a chat bubble.
  final double chatBubblePaddingY;

  /// The fixed height of a tab. Null sizes it from its padding.
  final double? tabHeight;

  /// The height of an underline-style tab.
  final double underlineTabHeight;

  /// The default avatar diameter.
  final double avatarSize;

  /// The role of page titles (`h1`). Null keeps the text theme's own.
  final TextRole? display;

  /// The role of section titles (`h3`). Null keeps the text theme's own.
  final TextRole? headline;

  /// The role of emphasised single lines such as a person's name
  /// (`large`). Null keeps [title]'s treatment.
  final TextRole? subtitle;

  /// The role of secondary lines (`small` and `muted`). Null keeps
  /// [body]'s treatment.
  final TextRole? small;

  /// Whether a tab's radius is its list's radius less the list's padding,
  /// so the two curves stay concentric, instead of [tabRadius].
  final bool concentricTabs;

  /// The fill of secondary buttons.
  final SurfaceFill secondaryButtonFill;

  /// The fill of secondary badges.
  final SurfaceFill secondaryBadgeFill;

  /// Whether secondary badges take the subtle foreground rather than the
  /// secondary foreground.
  final bool secondaryBadgeSubtle;

  /// The fill of a progress bar's track.
  final SurfaceFill progressTrackFill;

  /// Whether a progress bar fills with the scheme's tint rather than its
  /// primary.
  final bool progressTinted;

  /// The margin a divider keeps on its cross axis.
  final double dividerMargin;

  /// The gap between a timeline marker and the line that leaves it.
  final double timelineLineGap;

  /// The size, in logical pixels, at which a `PhosphorIcon` draws a regular
  /// icon exactly as the font has it. A smaller icon has its line thickened
  /// towards the one this size has: see [iconOpticalStrength]. A
  /// measurement on the screen, like a hairline, so it is not scaled with
  /// the spacing step.
  final double iconOpticalSize;

  /// How far a `PhosphorIcon` smaller than [iconOpticalSize] has its line
  /// thickened, from 0 to 1.
  ///
  /// The regular weight's line is a sixteenth of the icon's size, so it
  /// thins as the icon shrinks. 1 makes up the whole difference — every
  /// icon up to [iconOpticalSize] has that size's line — and 0 none: the
  /// glyph as the font has it, which switches the feature off.
  final double iconOpticalStrength;

  /// The fill of a tab list.
  final SurfaceFill tabsListFill;

  /// The fill of the selected tab.
  final SurfaceFill tabSelectedFill;

  /// Whether unselected tabs take the muted foreground.
  final bool tabUnselectedMuted;

  /// The gap between two tabs.
  final double tabsGap;

  /// The motion vocabulary: the durations, curves and springs the style's
  /// components animate with. [Motion.calm] unless the style says otherwise;
  /// [Motion.none] switches every transition off.
  final Motion motion;

  /// This style's metrics on a touch-sized screen.
  ///
  /// Null derives them: see [forFormFactor].
  final StyleTokens? mobile;

  // --- The shipped styles -------------------------------------------------

  static const _finesseCardShadow = [
    BoxShadow(color: Color(0x0d193c4a), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x2e193c4a),
      offset: Offset(0, 10),
      blurRadius: 30,
      spreadRadius: -14,
    ),
  ];

  static const _finesseCardShadowDark = [
    BoxShadow(color: Color(0x4d000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0xb3000000),
      offset: Offset(0, 14),
      blurRadius: 36,
      spreadRadius: -14,
    ),
  ];

  static const _finesseFloatingShadow = [
    BoxShadow(color: Color(0x0f000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x47000000),
      offset: Offset(0, 16),
      blurRadius: 40,
      spreadRadius: -12,
    ),
  ];

  // A black shadow is nearly lost on a dark page, so the dark one is deeper
  // and reaches further: enough to read as a pool under a floating bar.
  static const _finesseFloatingShadowDark = [
    BoxShadow(color: Color(0x4d000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0xbf000000),
      offset: Offset(0, 16),
      blurRadius: 40,
      spreadRadius: -8,
    ),
  ];

  static const _finesseTabShadow = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  /// Finesse's default style: soft teal glass.
  ///
  /// Controls round to 10, cards to 18; cards and outline buttons are
  /// translucent, and bars, popovers, menus and tooltips are glass over a
  /// blurred backdrop. Cards do not blur theirs ([cardBlur]). Its [mobile]
  /// counterpart is [finesseMobile].
  static const finesse = StyleTokens(
    name: 'finesse',
    radius: 10,
    radiusScale: RadiusScale(
      sm: .6,
      lg: 1.2,
      xl: 1.6,
      xl2: 1.8,
      xl3: 2,
      xl4: 2.4,
    ),
    cardRadius: RadiusToken.xl2,
    dialogRadius: RadiusToken.xl3,
    popoverRadius: RadiusToken.lg,
    tooltipRadius: RadiusToken.sm,
    commandItemDialogRadius: RadiusToken.md,
    commandSearchRadius: RadiusToken.md,
    checkboxRadius: 5,
    iconButtonRadius: RadiusToken.full,
    badgeRadius: RadiusToken.sm,
    badgeHeight: 24,
    badgePaddingX: 8,
    cardBorderOpacity: .09,
    cardBorderOpacityDark: .08,
    surfaceBorderOpacity: .09,
    surfaceBorderOpacityDark: .08,
    ringWidth: 3,
    ringOpacity: .35,
    title: TextRole(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -.16,
      height: 22 / 16,
    ),
    label: TextRole(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
    body: TextRole(fontSize: 14, height: 20 / 14),
    caption: TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
    ),
    overline: TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: .48,
      height: 16 / 12,
      uppercase: true,
    ),
    field: TextRole(fontSize: 14, height: 20 / 14),
    display: TextRole(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -.75,
      height: 36 / 30,
    ),
    headline: TextRole(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -.4,
      height: 24 / 20,
    ),
    subtitle: TextRole(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 20 / 15,
    ),
    small: TextRole(fontSize: 13, height: 18 / 13),
    cardShadow: _finesseCardShadow,
    cardShadowDark: _finesseCardShadowDark,
    popoverShadow: _finesseFloatingShadow,
    dialogShadow: _finesseFloatingShadow,
    sheetShadow: _finesseFloatingShadow,
    floatingShadow: _finesseFloatingShadow,
    floatingShadowDark: _finesseFloatingShadowDark,
    outlineButtonFill: SurfaceFill.glass,
    outlineButtonFillDark: SurfaceFill.glass,
    outlineButtonHoverFillDark: SurfaceFill.muted,
    outlineButtonDarkInputBorder: false,
    outlineButtonStrongBorder: true,
    controlShadow: Shadows.none,
    buttonHeight: 36,
    buttonHeightSm: 32,
    buttonHeightLg: 44,
    buttonPaddingX: 14,
    buttonPaddingXSm: 12,
    buttonPaddingXLg: 22,
    buttonGap: 8,
    buttonIconSize: 18,
    buttonIconSizeSm: 16,
    buttonIconSizeLg: 18,
    toggleIconSize: 18,
    badgeIconSize: 14,
    iconButtonSize: 36,
    iconButtonSizeSm: 32,
    iconButtonSizeLg: 40,
    iconButtonIconSize: 20,
    iconButtonIconSizeSm: 20,
    iconButtonIconSizeLg: 20,
    inputHeight: 40,
    inputPaddingX: 12,
    inputPaddingY: 4,
    textareaPaddingX: 12,
    textareaPaddingY: 10,
    fieldFill: SurfaceFill.muted,
    fieldFillDark: SurfaceFill.muted,
    selectPaddingX: 12,
    menuPadding: 6,
    menuMinWidth: 160,
    itemPaddingX: 10,
    itemPaddingY: 8,
    menubarHeight: 40,
    calendarCellSize: 36,
    commandSearchHeight: 40,
    commandSearchFill: SurfaceFill.muted,
    commandSearchFillDark: SurfaceFill.muted,
    sidebarItemHeight: 36,
    sidebarItemHeightSm: 32,
    sidebarItemPaddingX: 10,
    sidebarSubItemPaddingX: 10,
    controlFillDark: SurfaceFill.none,
    checkboxSize: 18,
    radioSize: 18,
    switchWidth: 36,
    switchHeight: 20,
    switchThumbSize: 16,
    sliderThumbSize: 18,
    cardPadding: 20,
    cardGap: 4,
    dialogPadding: 24,
    dialogGap: 8,
    popoverPadding: 16,
    tabsListPadding: 4,
    concentricTabs: true,
    secondaryButtonFill: SurfaceFill.muted,
    secondaryBadgeFill: SurfaceFill.muted,
    secondaryBadgeSubtle: true,
    progressTrackFill: SurfaceFill.secondary,
    progressTinted: true,
    dividerMargin: 0,
    timelineLineGap: 8,
    tabsListFill: SurfaceFill.secondary,
    tabSelectedFill: SurfaceFill.card,
    tabUnselectedMuted: true,
    tabsGap: 2,
    tabSelectedShadow: _finesseTabShadow,
    tabPaddingX: 14,
    tabPaddingY: 4,
    tabHeight: 32,
    alertPaddingX: 16,
    alertPaddingY: 14,
    tableCellPadding: 12,
    kbdHeight: 20,
    kbdPaddingX: 5,
    progressHeight: 7,
    glassOpacityDark: .66,
    barOpacity: .94,
    barOpacityDark: .95,
    cardOpacity: .88,
    cardOpacityDark: .82,
    popoverOpacity: .8,
    popoverOpacityDark: .82,
    tooltipOpacity: .8,
    tooltipOpacityDark: .84,
    // A highlighted row is a quiet wash in the glass, not a slab on it.
    menuHighlightOpacity: .06,
    menuHighlightOpacityDark: .09,
    // The floating bar on a dark page: the same glass, lifted a shade
    // toward the foreground and a little thinner, inside a brighter
    // hairline whose top edge catches the light.
    bottomNavigationOpacityDark: .84,
    bottomNavigationLiftDark: .08,
    bottomNavigationBorderOpacityDark: .12,
    bottomNavigationRimOpacityDark: .26,
    tableHoverOpacity: 1,
    tableSelectionTinted: true,
    pagePaddingX: 24,
    pagePaddingY: 24,
    avatarSize: 40,
    motion: Motion.lively,
    mobile: finesseMobile,
  );

  /// [finesse] on a touch-sized screen: 44-point controls, 15-point body
  /// text, tighter page margins and rounder cards.
  static const finesseMobile = StyleTokens(
    name: 'finesse',
    radius: 10,
    radiusScale: RadiusScale(
      sm: .6,
      lg: 1.2,
      xl: 1.6,
      xl2: 1.8,
      xl3: 2,
      xl4: 2.4,
    ),
    cardRadius: RadiusToken.xl3,
    // The phone metrics are Liquid Glass's (iOS 26 and 27), so a surface
    // is the same size frosted or liquid: menus and popovers 24 (the
    // package's popover; its menus are 32), dialogs 24.
    dialogRadius: RadiusToken.xl4,
    popoverRadius: RadiusToken.xl4,
    tooltipRadius: RadiusToken.sm,
    commandItemDialogRadius: RadiusToken.md,
    commandSearchRadius: RadiusToken.md,
    checkboxRadius: 5,
    iconButtonRadius: RadiusToken.full,
    badgeRadius: RadiusToken.sm,
    badgeHeight: 24,
    badgePaddingX: 8,
    cardBorderOpacity: .09,
    cardBorderOpacityDark: .08,
    surfaceBorderOpacity: .09,
    surfaceBorderOpacityDark: .08,
    ringWidth: 3,
    ringOpacity: .35,
    title: TextRole(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -.16,
      height: 22 / 16,
    ),
    label: TextRole(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
    body: TextRole(fontSize: 15, height: 22 / 15),
    caption: TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
    ),
    overline: TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: .48,
      height: 16 / 12,
      uppercase: true,
    ),
    field: TextRole(fontSize: 15, height: 20 / 15),
    display: TextRole(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -.7,
      height: 34 / 28,
    ),
    headline: TextRole(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -.4,
      height: 24 / 20,
    ),
    subtitle: TextRole(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 20 / 15,
    ),
    small: TextRole(fontSize: 13, height: 18 / 13),
    cardShadow: _finesseCardShadow,
    cardShadowDark: _finesseCardShadowDark,
    popoverShadow: _finesseFloatingShadow,
    dialogShadow: _finesseFloatingShadow,
    sheetShadow: _finesseFloatingShadow,
    floatingShadow: _finesseFloatingShadow,
    floatingShadowDark: _finesseFloatingShadowDark,
    outlineButtonFill: SurfaceFill.glass,
    outlineButtonFillDark: SurfaceFill.glass,
    outlineButtonHoverFillDark: SurfaceFill.muted,
    outlineButtonDarkInputBorder: false,
    outlineButtonStrongBorder: true,
    controlShadow: Shadows.none,
    buttonHeight: 44,
    buttonHeightSm: 36,
    buttonHeightLg: 48,
    buttonPaddingX: 14,
    buttonPaddingXSm: 12,
    buttonPaddingXLg: 22,
    buttonGap: 8,
    buttonIconSize: 18,
    buttonIconSizeSm: 16,
    buttonIconSizeLg: 18,
    toggleIconSize: 18,
    badgeIconSize: 14,
    iconButtonSize: 44,
    iconButtonSizeSm: 32,
    iconButtonSizeLg: 48,
    iconButtonIconSize: 22,
    iconButtonIconSizeSm: 20,
    iconButtonIconSizeLg: 24,
    inputHeight: 46,
    inputPaddingX: 12,
    inputPaddingY: 4,
    textareaPaddingX: 12,
    textareaPaddingY: 10,
    fieldFill: SurfaceFill.muted,
    fieldFillDark: SurfaceFill.muted,
    selectPaddingX: 12,
    menuPadding: 6,
    menuMinWidth: 160,
    itemPaddingX: 10,
    itemPaddingY: 11,
    menubarHeight: 44,
    calendarCellSize: 40,
    commandSearchHeight: 46,
    commandSearchFill: SurfaceFill.muted,
    commandSearchFillDark: SurfaceFill.muted,
    sidebarItemHeight: 44,
    sidebarItemHeightSm: 40,
    sidebarItemPaddingX: 10,
    sidebarSubItemPaddingX: 10,
    controlFillDark: SurfaceFill.none,
    checkboxSize: 20,
    radioSize: 20,
    // Liquid Glass's switch (58 × 26) and a thumb near its slider's.
    switchWidth: 58,
    switchHeight: 26,
    switchThumbSize: 22,
    sliderThumbSize: 28,
    cardPadding: 16,
    cardGap: 4,
    dialogPadding: 20,
    dialogGap: 8,
    popoverPadding: 16,
    tabsListPadding: 4,
    concentricTabs: true,
    secondaryButtonFill: SurfaceFill.muted,
    secondaryBadgeFill: SurfaceFill.muted,
    secondaryBadgeSubtle: true,
    progressTrackFill: SurfaceFill.secondary,
    progressTinted: true,
    dividerMargin: 0,
    timelineLineGap: 8,
    tabsListFill: SurfaceFill.secondary,
    tabSelectedFill: SurfaceFill.card,
    tabUnselectedMuted: true,
    tabsGap: 2,
    tabSelectedShadow: _finesseTabShadow,
    tabPaddingX: 14,
    tabPaddingY: 4,
    tabHeight: 36,
    alertPaddingX: 16,
    alertPaddingY: 14,
    tableCellPadding: 12,
    kbdHeight: 20,
    kbdPaddingX: 5,
    progressHeight: 7,
    glassOpacityDark: .66,
    barOpacity: .94,
    barOpacityDark: .95,
    cardOpacity: .88,
    cardOpacityDark: .82,
    popoverOpacity: .8,
    popoverOpacityDark: .82,
    tooltipOpacity: .8,
    tooltipOpacityDark: .84,
    // A highlighted row is a quiet wash in the glass, not a slab on it.
    menuHighlightOpacity: .06,
    menuHighlightOpacityDark: .09,
    // The floating bar on a dark page: the same glass, lifted a shade
    // toward the foreground and a little thinner, inside a brighter
    // hairline whose top edge catches the light.
    bottomNavigationOpacityDark: .84,
    bottomNavigationLiftDark: .08,
    bottomNavigationBorderOpacityDark: .12,
    bottomNavigationRimOpacityDark: .26,
    tableHoverOpacity: 1,
    tableSelectionTinted: true,
    pagePaddingX: 16,
    pagePaddingY: 16,
    avatarSize: 40,
    chipHeight: 36,
    underlineTabHeight: 48,
    // iOS's navigation bar, whose glass buttons are 44 tall, and its 64-point
    // tab bar (52 and the bar's padding of 6).
    appBarHeight: 44,
    bottomNavigationItemHeight: 52,
    fabSize: 56,
    fabSizeSm: 44,
    fabSizeLg: 72,
    gapLg: 12,
    gapXl: 16,
    motion: Motion.lively,
  );

  /// shadcn's default style: its `vega` one size down and a step rounder.
  static const nova = StyleTokens(
    name: 'nova',
    // The app-level type scale. Without it `Theme.of(context).textTheme` is
    // shadcn's prose scale — 16-point paragraphs, an 18-point `large` — and
    // a screen written against it comes out a size too big.
    display: TextRole(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -.75,
      height: 36 / 30,
    ),
    headline: TextRole(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -.4,
      height: 28 / 20,
    ),
    subtitle: TextRole(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 20 / 14,
    ),
    small: TextRole(fontSize: 13, height: 18 / 13),
    calendarCellSize: 28,
    calendarPadding: 8,
    calendarCaptionHeight: 24,
    // `leading-snug` on the card title.
    title: TextRole(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.375,
    ),
    cardShadow: Shadows.none,
    controlShadow: Shadows.none,
    buttonRadius: RadiusToken.lg,
    popoverRadius: RadiusToken.lg,
    textareaRadius: RadiusToken.lg,
    itemRadius: RadiusToken.md,
    buttonHeight: 32,
    buttonHeightSm: 28,
    buttonHeightLg: 36,
    buttonIconSizeSm: 14,
    iconButtonSize: 32,
    iconButtonSizeSm: 28,
    iconButtonSizeLg: 36,
    inputHeight: 32,
    itemPaddingX: 6,
    itemPaddingY: 4,
    menubarHeight: 32,
    menubarPadding: 3,
    sliderTrackHeight: 4,
    sliderThumbSize: 12,
    cardPadding: 16,
    dialogPadding: 16,
    popoverPadding: 10,
    tabPaddingX: 6,
    tabPaddingY: 2,
    accordionTitlePaddingY: 10,
    alertPaddingX: 10,
    alertPaddingY: 8,
    alertIconGap: 8,
    progressHeight: 4,
  );

  /// Pill-shaped and roomy.
  static const maia = StyleTokens(
    name: 'maia',
    // The app-level type scale. Without it `Theme.of(context).textTheme` is
    // shadcn's prose scale — 16-point paragraphs, an 18-point `large` — and
    // a screen written against it comes out a size too big.
    display: TextRole(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -.75,
      height: 36 / 30,
    ),
    headline: TextRole(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -.4,
      height: 28 / 20,
    ),
    subtitle: TextRole(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 20 / 14,
    ),
    small: TextRole(fontSize: 13, height: 18 / 13),
    calendarCellRadius: RadiusToken.xl4,
    commandItemDialogRadius: RadiusToken.xl2,
    commandSearchRadius: RadiusToken.xl4,
    commandSearchHeight: 36,
    commandSearchBorderOpacity: 1,
    cardShadow: Shadows.none,
    controlShadow: Shadows.none,
    popoverShadow: Shadows.xl2,
    buttonRadius: RadiusToken.xl4,
    cardRadius: RadiusToken.xl2,
    commandRadius: RadiusToken.xl4,
    dialogRadius: RadiusToken.xl4,
    popoverRadius: RadiusToken.xl2,
    tooltipRadius: RadiusToken.xl2,
    textareaRadius: RadiusToken.xl,
    itemRadius: RadiusToken.xl,
    checkboxRadius: 6,
    surfaceBorderOpacity: .05,
    surfaceBorderOpacityDark: .1,
    dialogBorderOpacity: .05,
    dialogBorderOpacityDark: .05,
    outlineButtonFill: SurfaceFill.input30,
    outlineButtonHoverFill: SurfaceFill.input50,
    outlineButtonDarkInputBorder: false,
    fieldFill: SurfaceFill.input30,
    tabsListRadius: RadiusToken.xl4,
    tabRadius: RadiusToken.xl,
    tabSelectedShadow: Shadows.none,
    menuMinWidth: 192,
    buttonPaddingX: 12,
    buttonPaddingXSm: 12,
    buttonPaddingXLg: 16,
    inputPaddingX: 12,
    textareaPaddingX: 12,
    textareaPaddingY: 12,
    selectPaddingX: 12,
    itemPaddingX: 12,
    itemPaddingY: 8,
    cardGap: 8,
    sliderTrackHeight: 12,
    tableCellPadding: 12,
    progressHeight: 12,
    sidebarItemHeight: 36,
    sidebarItemHeightSm: 32,
    sidebarItemHeightLg: 56,
    sidebarItemPaddingX: 12,
  );

  /// Square and compact.
  static const lyra = StyleTokens(
    name: 'lyra',
    // The app-level type scale, a step smaller like the rest of the style.
    display: TextRole(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -.6,
      height: 32 / 24,
    ),
    headline: TextRole(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 24 / 18,
    ),
    subtitle: TextRole(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 18 / 13,
    ),
    small: TextRole(fontSize: 12, height: 16 / 12),
    calendarCellSize: 28,
    calendarCellRadius: RadiusToken.none,
    calendarPadding: 8,
    calendarCaptionHeight: 24,
    commandItemDialogRadius: RadiusToken.none,
    commandSearchRadius: RadiusToken.none,
    commandPadding: 0,
    commandGroupPadding: 0,
    commandSearchBorderOpacity: 0,
    commandSearchUnderline: true,
    buttonRadius: RadiusToken.none,
    cardRadius: RadiusToken.none,
    commandRadius: RadiusToken.none,
    dialogRadius: RadiusToken.none,
    popoverRadius: RadiusToken.none,
    tooltipRadius: RadiusToken.none,
    textareaRadius: RadiusToken.none,
    itemRadius: RadiusToken.none,
    checkboxRadius: 0,
    ringWidth: 1,
    title: TextRole(fontSize: 14, fontWeight: FontWeight.w500),
    label: TextRole(fontSize: 12, fontWeight: FontWeight.w500),
    body: TextRole(fontSize: 12),
    field: TextRole(fontSize: 12),
    cardShadow: Shadows.none,
    controlShadow: Shadows.none,
    buttonHeight: 32,
    buttonHeightSm: 28,
    buttonHeightLg: 36,
    buttonIconSizeSm: 14,
    iconButtonSize: 32,
    iconButtonSizeSm: 28,
    iconButtonSizeLg: 36,
    inputHeight: 32,
    menuPadding: 0,
    itemPaddingY: 8,
    menubarHeight: 32,
    tabsListRadius: RadiusToken.none,
    tabRadius: RadiusToken.none,
    tabSelectedShadow: Shadows.none,
    sliderTrackHeight: 4,
    sliderThumbSize: 12,
    cardPadding: 16,
    dialogPadding: 16,
    dialogGap: 4,
    popoverPadding: 10,
    tabPaddingX: 6,
    tabPaddingY: 2,
    accordionTitlePaddingY: 10,
    alertPaddingX: 10,
    alertPaddingY: 8,
    alertRadius: RadiusToken.none,
    alertIconGap: 8,
    alertIconOffset: 0,
    progressHeight: 4,
  );

  /// Every built-in style, the default first.
  static const all = <StyleTokens>[finesse, nova, maia, lyra];

  /// Returns the built-in style called [name], such as `finesse` or `nova`.
  ///
  /// Throws an [ArgumentError] for an unknown name.
  static StyleTokens fromName(String name) => all.firstWhere(
    (s) => s.name == name,
    orElse: () => throw ArgumentError.value(name, 'name', 'Unknown style'),
  );

  /// This style's metrics for [formFactor].
  ///
  /// On [FormFactor.mobile] that is [mobile] when the style defines one.
  /// Otherwise the touch metrics are derived: controls grow to at least 44
  /// logical pixels, body and field text to 15, and page margins tighten to
  /// 16.
  StyleTokens forFormFactor(FormFactor formFactor) => switch (formFactor) {
    FormFactor.desktop => this,
    FormFactor.mobile => mobile ?? _derivedMobile,
  };

  StyleTokens get _derivedMobile {
    double atLeast(double value, double min) => value < min ? min : value;
    TextRole grown(TextRole role) => role.fontSize >= 15
        ? role
        : role.copyWith(fontSize: 15, height: 22 / 15);
    return copyWith(
      body: grown(body),
      field: grown(field),
      buttonHeight: atLeast(buttonHeight, 44),
      buttonHeightSm: atLeast(buttonHeightSm, 36),
      buttonHeightLg: atLeast(buttonHeightLg, 48),
      iconButtonSize: atLeast(iconButtonSize, 44),
      iconButtonSizeLg: atLeast(iconButtonSizeLg, 48),
      inputHeight: atLeast(inputHeight, 44),
      commandSearchHeight: atLeast(commandSearchHeight, 44),
      calendarCellSize: atLeast(calendarCellSize, 40),
      sidebarItemHeight: atLeast(sidebarItemHeight, 44),
      menubarHeight: atLeast(menubarHeight, 44),
      itemPaddingY: atLeast(itemPaddingY, 10),
      chipHeight: atLeast(chipHeight, 36),
      checkboxSize: atLeast(checkboxSize, 20),
      radioSize: atLeast(radioSize, 20),
      // At most 60: a style whose bar is already a phone's (finesse's
      // 44, Liquid Glass's) keeps it, so a phone style is a fixed point.
      appBarHeight: appBarHeight < 60 ? appBarHeight : 60,
      fabSize: atLeast(fabSize, 56),
      fabSizeSm: atLeast(fabSizeSm, 44),
      fabSizeLg: atLeast(fabSizeLg, 72),
      pagePaddingX: 16,
      pagePaddingY: 16,
      gapLg: 12,
      gapXl: 16,
    );
  }

  static T? _shared<T>(T? value, T? desktop, T? mobile) {
    if (value == null) return null;
    final same = desktop is List && mobile is List
        ? listEquals<Object?>(desktop, mobile)
        : desktop == mobile;
    return same ? value : null;
  }

  /// Creates a copy of this style with the given fields replaced.
  ///
  /// The replacement reaches the phone metrics too: [mobile] takes each new
  /// value whose field it had in common with this style, so
  /// `StyleTokens.finesse.copyWith(glassBlur: 12)` changes the blur on both
  /// form factors. A field the phone sets differently on purpose (button
  /// height, body text size, page margins) keeps its phone value; change
  /// those with `mobile: style.mobile!.copyWith(...)`, which is used as
  /// given.
  StyleTokens copyWith({
    String? name,
    RadiusToken? buttonRadius,
    RadiusToken? cardRadius,
    RadiusToken? dialogRadius,
    RadiusToken? popoverRadius,
    RadiusToken? tooltipRadius,
    RadiusToken? commandRadius,
    RadiusToken? commandItemDialogRadius,
    RadiusToken? commandSearchRadius,
    RadiusToken? textareaRadius,
    RadiusToken? itemRadius,
    double? checkboxRadius,
    double? cardBorderOpacity,
    double? cardBorderOpacityDark,
    double? surfaceBorderOpacity,
    double? surfaceBorderOpacityDark,
    double? dialogBorderOpacity,
    double? dialogBorderOpacityDark,
    double? surfaceRadiusCap,
    double? ringWidth,
    double? ringOpacity,
    TextRole? title,
    TextRole? label,
    TextRole? body,
    TextRole? caption,
    TextRole? overline,
    TextRole? field,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? popoverShadow,
    List<BoxShadow>? dialogShadow,
    List<BoxShadow>? sheetShadow,
    SurfaceFill? outlineButtonFill,
    SurfaceFill? outlineButtonFillDark,
    SurfaceFill? outlineButtonHoverFill,
    SurfaceFill? outlineButtonHoverFillDark,
    bool? outlineButtonDarkInputBorder,
    bool? linkUnderline,
    bool? flatBadges,
    List<BoxShadow>? controlShadow,
    double? buttonHeight,
    double? buttonHeightSm,
    double? buttonHeightLg,
    double? buttonPaddingX,
    double? buttonPaddingXSm,
    double? buttonPaddingXLg,
    double? buttonGap,
    double? buttonIconSize,
    double? buttonIconSizeSm,
    double? buttonIconSizeLg,
    double? toggleIconSize,
    double? badgeIconSize,
    double? iconButtonSize,
    double? iconButtonSizeSm,
    double? iconButtonSizeLg,
    double? iconButtonIconSize,
    double? iconButtonIconSizeSm,
    double? iconButtonIconSizeLg,
    double? inputHeight,
    double? inputPaddingX,
    double? inputPaddingY,
    double? textareaPaddingX,
    double? textareaPaddingY,
    bool? underlinedFields,
    SurfaceFill? fieldFill,
    SurfaceFill? fieldFillDark,
    bool? fieldBorderless,
    double? selectPaddingX,
    double? menuPadding,
    double? menuMinWidth,
    double? itemPaddingX,
    double? itemPaddingY,
    double? menubarHeight,
    double? menubarPadding,
    double? calendarCellSize,
    RadiusToken? calendarCellRadius,
    double? calendarPadding,
    double? calendarCaptionHeight,
    double? commandPadding,
    double? commandGroupPadding,
    double? commandSearchHeight,
    SurfaceFill? commandSearchFill,
    SurfaceFill? commandSearchFillDark,
    double? commandSearchBorderOpacity,
    bool? commandSearchUnderline,
    double? sidebarItemHeight,
    double? sidebarItemHeightSm,
    double? sidebarItemHeightLg,
    double? sidebarItemPaddingX,
    double? sidebarSubItemPaddingX,
    SurfaceFill? controlFill,
    SurfaceFill? controlFillDark,
    bool? controlBorderless,
    bool? radioCheckedOutline,
    double? checkboxSize,
    double? radioSize,
    double? switchWidth,
    double? switchHeight,
    double? switchThumbSize,
    double? sliderTrackHeight,
    double? sliderThumbSize,
    SurfaceFill? sliderTrackFill,
    bool? sliderThumbFilled,
    double? cardPadding,
    double? cardGap,
    double? dialogPadding,
    double? dialogGap,
    double? popoverPadding,
    double? tabsListPadding,
    RadiusToken? tabsListRadius,
    RadiusToken? tabRadius,
    List<BoxShadow>? tabSelectedShadow,
    double? tabPaddingX,
    double? tabPaddingY,
    double? accordionTitlePaddingY,
    RadiusToken? alertRadius,
    double? alertPaddingX,
    double? alertPaddingY,
    double? alertGap,
    double? alertIconGap,
    double? alertIconSize,
    double? alertIconOffset,
    bool? alertAccentBar,
    double? tableCellPadding,
    double? kbdHeight,
    double? kbdPaddingX,
    double? progressHeight,
    double? radius,
    RadiusScale? radiusScale,
    RadiusToken? iconButtonRadius,
    RadiusToken? badgeRadius,
    double? badgeHeight,
    double? badgePaddingX,
    bool? outlineButtonStrongBorder,
    double? glassBlur,
    double? glassSaturation,
    double? glassOpacity,
    double? glassOpacityDark,
    double? glassStrongOpacity,
    double? barOpacity,
    double? barOpacityDark,
    double? cardOpacity,
    double? cardOpacityDark,
    bool? cardBlur,
    double? popoverOpacity,
    double? popoverOpacityDark,
    double? tooltipOpacity,
    double? tooltipOpacityDark,
    double? menuHighlightOpacity,
    double? menuHighlightOpacityDark,
    double? tableHoverOpacity,
    bool? tableSelectionTinted,
    List<BoxShadow>? cardShadowDark,
    List<BoxShadow>? floatingShadow,
    List<BoxShadow>? floatingShadowDark,
    double? pagePaddingX,
    double? pagePaddingY,
    double? pageMaxWidth,
    double? gapXs,
    double? gapSm,
    double? gapMd,
    double? gapLg,
    double? gapXl,
    double? appBarHeight,
    double? fabSize,
    double? fabSizeSm,
    double? fabSizeLg,
    double? navigationItemWidth,
    double? navigationIconSize,
    double? navigationIndicatorHeight,
    double? bottomNavigationItemWidth,
    double? bottomNavigationItemHeight,
    double? bottomNavigationIconSize,
    double? bottomNavigationPadding,
    bool? bottomNavigationFloating,
    double? bottomNavigationOpacity,
    double? bottomNavigationOpacityDark,
    double? bottomNavigationLift,
    double? bottomNavigationLiftDark,
    double? bottomNavigationBorderOpacity,
    double? bottomNavigationBorderOpacityDark,
    double? bottomNavigationRimOpacity,
    double? bottomNavigationRimOpacityDark,
    double? chipHeight,
    double? chipPaddingX,
    double? chipGap,
    double? chipIconSize,
    RadiusToken? chipRadius,
    double? listTilePaddingX,
    double? listTilePaddingY,
    double? listTileGap,
    double? chatBubbleRadius,
    double? chatBubbleTailRadius,
    double? chatBubblePaddingX,
    double? chatBubblePaddingY,
    double? tabHeight,
    double? underlineTabHeight,
    double? avatarSize,
    TextRole? display,
    TextRole? headline,
    TextRole? subtitle,
    TextRole? small,
    bool? concentricTabs,
    SurfaceFill? secondaryButtonFill,
    SurfaceFill? secondaryBadgeFill,
    bool? secondaryBadgeSubtle,
    SurfaceFill? progressTrackFill,
    bool? progressTinted,
    double? dividerMargin,
    double? timelineLineGap,
    double? iconOpticalSize,
    double? iconOpticalStrength,
    SurfaceFill? tabsListFill,
    SurfaceFill? tabSelectedFill,
    bool? tabUnselectedMuted,
    double? tabsGap,
    Motion? motion,
    StyleTokens? mobile,
  }) {
    // The phone metrics follow an override wherever they did not differ from
    // the desktop ones to begin with. A field the phone sets on purpose — a
    // 44-point button against 36 — keeps its phone value.
    final currentMobile = this.mobile;
    final nextMobile =
        mobile ??
        currentMobile?.copyWith(
          name: name,
          buttonRadius: _shared(
            buttonRadius,
            this.buttonRadius,
            currentMobile.buttonRadius,
          ),
          cardRadius: _shared(
            cardRadius,
            this.cardRadius,
            currentMobile.cardRadius,
          ),
          dialogRadius: _shared(
            dialogRadius,
            this.dialogRadius,
            currentMobile.dialogRadius,
          ),
          popoverRadius: _shared(
            popoverRadius,
            this.popoverRadius,
            currentMobile.popoverRadius,
          ),
          tooltipRadius: _shared(
            tooltipRadius,
            this.tooltipRadius,
            currentMobile.tooltipRadius,
          ),
          commandRadius: _shared(
            commandRadius,
            this.commandRadius,
            currentMobile.commandRadius,
          ),
          commandItemDialogRadius: _shared(
            commandItemDialogRadius,
            this.commandItemDialogRadius,
            currentMobile.commandItemDialogRadius,
          ),
          commandSearchRadius: _shared(
            commandSearchRadius,
            this.commandSearchRadius,
            currentMobile.commandSearchRadius,
          ),
          textareaRadius: _shared(
            textareaRadius,
            this.textareaRadius,
            currentMobile.textareaRadius,
          ),
          itemRadius: _shared(
            itemRadius,
            this.itemRadius,
            currentMobile.itemRadius,
          ),
          checkboxRadius: _shared(
            checkboxRadius,
            this.checkboxRadius,
            currentMobile.checkboxRadius,
          ),
          cardBorderOpacity: _shared(
            cardBorderOpacity,
            this.cardBorderOpacity,
            currentMobile.cardBorderOpacity,
          ),
          cardBorderOpacityDark: _shared(
            cardBorderOpacityDark,
            this.cardBorderOpacityDark,
            currentMobile.cardBorderOpacityDark,
          ),
          surfaceBorderOpacity: _shared(
            surfaceBorderOpacity,
            this.surfaceBorderOpacity,
            currentMobile.surfaceBorderOpacity,
          ),
          surfaceBorderOpacityDark: _shared(
            surfaceBorderOpacityDark,
            this.surfaceBorderOpacityDark,
            currentMobile.surfaceBorderOpacityDark,
          ),
          dialogBorderOpacity: _shared(
            dialogBorderOpacity,
            this.dialogBorderOpacity,
            currentMobile.dialogBorderOpacity,
          ),
          dialogBorderOpacityDark: _shared(
            dialogBorderOpacityDark,
            this.dialogBorderOpacityDark,
            currentMobile.dialogBorderOpacityDark,
          ),
          surfaceRadiusCap: _shared(
            surfaceRadiusCap,
            this.surfaceRadiusCap,
            currentMobile.surfaceRadiusCap,
          ),
          ringWidth: _shared(
            ringWidth,
            this.ringWidth,
            currentMobile.ringWidth,
          ),
          ringOpacity: _shared(
            ringOpacity,
            this.ringOpacity,
            currentMobile.ringOpacity,
          ),
          title: _shared(title, this.title, currentMobile.title),
          label: _shared(label, this.label, currentMobile.label),
          body: _shared(body, this.body, currentMobile.body),
          caption: _shared(caption, this.caption, currentMobile.caption),
          overline: _shared(overline, this.overline, currentMobile.overline),
          field: _shared(field, this.field, currentMobile.field),
          cardShadow: _shared(
            cardShadow,
            this.cardShadow,
            currentMobile.cardShadow,
          ),
          popoverShadow: _shared(
            popoverShadow,
            this.popoverShadow,
            currentMobile.popoverShadow,
          ),
          dialogShadow: _shared(
            dialogShadow,
            this.dialogShadow,
            currentMobile.dialogShadow,
          ),
          sheetShadow: _shared(
            sheetShadow,
            this.sheetShadow,
            currentMobile.sheetShadow,
          ),
          outlineButtonFill: _shared(
            outlineButtonFill,
            this.outlineButtonFill,
            currentMobile.outlineButtonFill,
          ),
          outlineButtonFillDark: _shared(
            outlineButtonFillDark,
            this.outlineButtonFillDark,
            currentMobile.outlineButtonFillDark,
          ),
          outlineButtonHoverFill: _shared(
            outlineButtonHoverFill,
            this.outlineButtonHoverFill,
            currentMobile.outlineButtonHoverFill,
          ),
          outlineButtonHoverFillDark: _shared(
            outlineButtonHoverFillDark,
            this.outlineButtonHoverFillDark,
            currentMobile.outlineButtonHoverFillDark,
          ),
          outlineButtonDarkInputBorder: _shared(
            outlineButtonDarkInputBorder,
            this.outlineButtonDarkInputBorder,
            currentMobile.outlineButtonDarkInputBorder,
          ),
          linkUnderline: _shared(
            linkUnderline,
            this.linkUnderline,
            currentMobile.linkUnderline,
          ),
          flatBadges: _shared(
            flatBadges,
            this.flatBadges,
            currentMobile.flatBadges,
          ),
          controlShadow: _shared(
            controlShadow,
            this.controlShadow,
            currentMobile.controlShadow,
          ),
          buttonHeight: _shared(
            buttonHeight,
            this.buttonHeight,
            currentMobile.buttonHeight,
          ),
          buttonHeightSm: _shared(
            buttonHeightSm,
            this.buttonHeightSm,
            currentMobile.buttonHeightSm,
          ),
          buttonHeightLg: _shared(
            buttonHeightLg,
            this.buttonHeightLg,
            currentMobile.buttonHeightLg,
          ),
          buttonPaddingX: _shared(
            buttonPaddingX,
            this.buttonPaddingX,
            currentMobile.buttonPaddingX,
          ),
          buttonPaddingXSm: _shared(
            buttonPaddingXSm,
            this.buttonPaddingXSm,
            currentMobile.buttonPaddingXSm,
          ),
          buttonPaddingXLg: _shared(
            buttonPaddingXLg,
            this.buttonPaddingXLg,
            currentMobile.buttonPaddingXLg,
          ),
          buttonGap: _shared(
            buttonGap,
            this.buttonGap,
            currentMobile.buttonGap,
          ),
          buttonIconSize: _shared(
            buttonIconSize,
            this.buttonIconSize,
            currentMobile.buttonIconSize,
          ),
          buttonIconSizeSm: _shared(
            buttonIconSizeSm,
            this.buttonIconSizeSm,
            currentMobile.buttonIconSizeSm,
          ),
          buttonIconSizeLg: _shared(
            buttonIconSizeLg,
            this.buttonIconSizeLg,
            currentMobile.buttonIconSizeLg,
          ),
          toggleIconSize: _shared(
            toggleIconSize,
            this.toggleIconSize,
            currentMobile.toggleIconSize,
          ),
          badgeIconSize: _shared(
            badgeIconSize,
            this.badgeIconSize,
            currentMobile.badgeIconSize,
          ),
          iconButtonSize: _shared(
            iconButtonSize,
            this.iconButtonSize,
            currentMobile.iconButtonSize,
          ),
          iconButtonSizeSm: _shared(
            iconButtonSizeSm,
            this.iconButtonSizeSm,
            currentMobile.iconButtonSizeSm,
          ),
          iconButtonSizeLg: _shared(
            iconButtonSizeLg,
            this.iconButtonSizeLg,
            currentMobile.iconButtonSizeLg,
          ),
          iconButtonIconSize: _shared(
            iconButtonIconSize,
            this.iconButtonIconSize,
            currentMobile.iconButtonIconSize,
          ),
          iconButtonIconSizeSm: _shared(
            iconButtonIconSizeSm,
            this.iconButtonIconSizeSm,
            currentMobile.iconButtonIconSizeSm,
          ),
          iconButtonIconSizeLg: _shared(
            iconButtonIconSizeLg,
            this.iconButtonIconSizeLg,
            currentMobile.iconButtonIconSizeLg,
          ),
          inputHeight: _shared(
            inputHeight,
            this.inputHeight,
            currentMobile.inputHeight,
          ),
          inputPaddingX: _shared(
            inputPaddingX,
            this.inputPaddingX,
            currentMobile.inputPaddingX,
          ),
          inputPaddingY: _shared(
            inputPaddingY,
            this.inputPaddingY,
            currentMobile.inputPaddingY,
          ),
          textareaPaddingX: _shared(
            textareaPaddingX,
            this.textareaPaddingX,
            currentMobile.textareaPaddingX,
          ),
          textareaPaddingY: _shared(
            textareaPaddingY,
            this.textareaPaddingY,
            currentMobile.textareaPaddingY,
          ),
          underlinedFields: _shared(
            underlinedFields,
            this.underlinedFields,
            currentMobile.underlinedFields,
          ),
          fieldFill: _shared(
            fieldFill,
            this.fieldFill,
            currentMobile.fieldFill,
          ),
          fieldFillDark: _shared(
            fieldFillDark,
            this.fieldFillDark,
            currentMobile.fieldFillDark,
          ),
          fieldBorderless: _shared(
            fieldBorderless,
            this.fieldBorderless,
            currentMobile.fieldBorderless,
          ),
          selectPaddingX: _shared(
            selectPaddingX,
            this.selectPaddingX,
            currentMobile.selectPaddingX,
          ),
          menuPadding: _shared(
            menuPadding,
            this.menuPadding,
            currentMobile.menuPadding,
          ),
          menuMinWidth: _shared(
            menuMinWidth,
            this.menuMinWidth,
            currentMobile.menuMinWidth,
          ),
          itemPaddingX: _shared(
            itemPaddingX,
            this.itemPaddingX,
            currentMobile.itemPaddingX,
          ),
          itemPaddingY: _shared(
            itemPaddingY,
            this.itemPaddingY,
            currentMobile.itemPaddingY,
          ),
          menubarHeight: _shared(
            menubarHeight,
            this.menubarHeight,
            currentMobile.menubarHeight,
          ),
          menubarPadding: _shared(
            menubarPadding,
            this.menubarPadding,
            currentMobile.menubarPadding,
          ),
          calendarCellSize: _shared(
            calendarCellSize,
            this.calendarCellSize,
            currentMobile.calendarCellSize,
          ),
          calendarCellRadius: _shared(
            calendarCellRadius,
            this.calendarCellRadius,
            currentMobile.calendarCellRadius,
          ),
          calendarPadding: _shared(
            calendarPadding,
            this.calendarPadding,
            currentMobile.calendarPadding,
          ),
          calendarCaptionHeight: _shared(
            calendarCaptionHeight,
            this.calendarCaptionHeight,
            currentMobile.calendarCaptionHeight,
          ),
          commandPadding: _shared(
            commandPadding,
            this.commandPadding,
            currentMobile.commandPadding,
          ),
          commandGroupPadding: _shared(
            commandGroupPadding,
            this.commandGroupPadding,
            currentMobile.commandGroupPadding,
          ),
          commandSearchHeight: _shared(
            commandSearchHeight,
            this.commandSearchHeight,
            currentMobile.commandSearchHeight,
          ),
          commandSearchFill: _shared(
            commandSearchFill,
            this.commandSearchFill,
            currentMobile.commandSearchFill,
          ),
          commandSearchFillDark: _shared(
            commandSearchFillDark,
            this.commandSearchFillDark,
            currentMobile.commandSearchFillDark,
          ),
          commandSearchBorderOpacity: _shared(
            commandSearchBorderOpacity,
            this.commandSearchBorderOpacity,
            currentMobile.commandSearchBorderOpacity,
          ),
          commandSearchUnderline: _shared(
            commandSearchUnderline,
            this.commandSearchUnderline,
            currentMobile.commandSearchUnderline,
          ),
          sidebarItemHeight: _shared(
            sidebarItemHeight,
            this.sidebarItemHeight,
            currentMobile.sidebarItemHeight,
          ),
          sidebarItemHeightSm: _shared(
            sidebarItemHeightSm,
            this.sidebarItemHeightSm,
            currentMobile.sidebarItemHeightSm,
          ),
          sidebarItemHeightLg: _shared(
            sidebarItemHeightLg,
            this.sidebarItemHeightLg,
            currentMobile.sidebarItemHeightLg,
          ),
          sidebarItemPaddingX: _shared(
            sidebarItemPaddingX,
            this.sidebarItemPaddingX,
            currentMobile.sidebarItemPaddingX,
          ),
          sidebarSubItemPaddingX: _shared(
            sidebarSubItemPaddingX,
            this.sidebarSubItemPaddingX,
            currentMobile.sidebarSubItemPaddingX,
          ),
          controlFill: _shared(
            controlFill,
            this.controlFill,
            currentMobile.controlFill,
          ),
          controlFillDark: _shared(
            controlFillDark,
            this.controlFillDark,
            currentMobile.controlFillDark,
          ),
          controlBorderless: _shared(
            controlBorderless,
            this.controlBorderless,
            currentMobile.controlBorderless,
          ),
          radioCheckedOutline: _shared(
            radioCheckedOutline,
            this.radioCheckedOutline,
            currentMobile.radioCheckedOutline,
          ),
          checkboxSize: _shared(
            checkboxSize,
            this.checkboxSize,
            currentMobile.checkboxSize,
          ),
          radioSize: _shared(
            radioSize,
            this.radioSize,
            currentMobile.radioSize,
          ),
          switchWidth: _shared(
            switchWidth,
            this.switchWidth,
            currentMobile.switchWidth,
          ),
          switchHeight: _shared(
            switchHeight,
            this.switchHeight,
            currentMobile.switchHeight,
          ),
          switchThumbSize: _shared(
            switchThumbSize,
            this.switchThumbSize,
            currentMobile.switchThumbSize,
          ),
          sliderTrackHeight: _shared(
            sliderTrackHeight,
            this.sliderTrackHeight,
            currentMobile.sliderTrackHeight,
          ),
          sliderThumbSize: _shared(
            sliderThumbSize,
            this.sliderThumbSize,
            currentMobile.sliderThumbSize,
          ),
          sliderTrackFill: _shared(
            sliderTrackFill,
            this.sliderTrackFill,
            currentMobile.sliderTrackFill,
          ),
          sliderThumbFilled: _shared(
            sliderThumbFilled,
            this.sliderThumbFilled,
            currentMobile.sliderThumbFilled,
          ),
          cardPadding: _shared(
            cardPadding,
            this.cardPadding,
            currentMobile.cardPadding,
          ),
          cardGap: _shared(cardGap, this.cardGap, currentMobile.cardGap),
          dialogPadding: _shared(
            dialogPadding,
            this.dialogPadding,
            currentMobile.dialogPadding,
          ),
          dialogGap: _shared(
            dialogGap,
            this.dialogGap,
            currentMobile.dialogGap,
          ),
          popoverPadding: _shared(
            popoverPadding,
            this.popoverPadding,
            currentMobile.popoverPadding,
          ),
          tabsListPadding: _shared(
            tabsListPadding,
            this.tabsListPadding,
            currentMobile.tabsListPadding,
          ),
          tabsListRadius: _shared(
            tabsListRadius,
            this.tabsListRadius,
            currentMobile.tabsListRadius,
          ),
          tabRadius: _shared(
            tabRadius,
            this.tabRadius,
            currentMobile.tabRadius,
          ),
          tabSelectedShadow: _shared(
            tabSelectedShadow,
            this.tabSelectedShadow,
            currentMobile.tabSelectedShadow,
          ),
          tabPaddingX: _shared(
            tabPaddingX,
            this.tabPaddingX,
            currentMobile.tabPaddingX,
          ),
          tabPaddingY: _shared(
            tabPaddingY,
            this.tabPaddingY,
            currentMobile.tabPaddingY,
          ),
          accordionTitlePaddingY: _shared(
            accordionTitlePaddingY,
            this.accordionTitlePaddingY,
            currentMobile.accordionTitlePaddingY,
          ),
          alertRadius: _shared(
            alertRadius,
            this.alertRadius,
            currentMobile.alertRadius,
          ),
          alertPaddingX: _shared(
            alertPaddingX,
            this.alertPaddingX,
            currentMobile.alertPaddingX,
          ),
          alertPaddingY: _shared(
            alertPaddingY,
            this.alertPaddingY,
            currentMobile.alertPaddingY,
          ),
          alertGap: _shared(alertGap, this.alertGap, currentMobile.alertGap),
          alertIconGap: _shared(
            alertIconGap,
            this.alertIconGap,
            currentMobile.alertIconGap,
          ),
          alertIconSize: _shared(
            alertIconSize,
            this.alertIconSize,
            currentMobile.alertIconSize,
          ),
          alertIconOffset: _shared(
            alertIconOffset,
            this.alertIconOffset,
            currentMobile.alertIconOffset,
          ),
          alertAccentBar: _shared(
            alertAccentBar,
            this.alertAccentBar,
            currentMobile.alertAccentBar,
          ),
          tableCellPadding: _shared(
            tableCellPadding,
            this.tableCellPadding,
            currentMobile.tableCellPadding,
          ),
          kbdHeight: _shared(
            kbdHeight,
            this.kbdHeight,
            currentMobile.kbdHeight,
          ),
          kbdPaddingX: _shared(
            kbdPaddingX,
            this.kbdPaddingX,
            currentMobile.kbdPaddingX,
          ),
          progressHeight: _shared(
            progressHeight,
            this.progressHeight,
            currentMobile.progressHeight,
          ),
          radius: _shared(radius, this.radius, currentMobile.radius),
          radiusScale: _shared(
            radiusScale,
            this.radiusScale,
            currentMobile.radiusScale,
          ),
          iconButtonRadius: _shared(
            iconButtonRadius,
            this.iconButtonRadius,
            currentMobile.iconButtonRadius,
          ),
          badgeRadius: _shared(
            badgeRadius,
            this.badgeRadius,
            currentMobile.badgeRadius,
          ),
          badgeHeight: _shared(
            badgeHeight,
            this.badgeHeight,
            currentMobile.badgeHeight,
          ),
          badgePaddingX: _shared(
            badgePaddingX,
            this.badgePaddingX,
            currentMobile.badgePaddingX,
          ),
          outlineButtonStrongBorder: _shared(
            outlineButtonStrongBorder,
            this.outlineButtonStrongBorder,
            currentMobile.outlineButtonStrongBorder,
          ),
          glassBlur: _shared(
            glassBlur,
            this.glassBlur,
            currentMobile.glassBlur,
          ),
          glassSaturation: _shared(
            glassSaturation,
            this.glassSaturation,
            currentMobile.glassSaturation,
          ),
          glassOpacity: _shared(
            glassOpacity,
            this.glassOpacity,
            currentMobile.glassOpacity,
          ),
          glassOpacityDark: _shared(
            glassOpacityDark,
            this.glassOpacityDark,
            currentMobile.glassOpacityDark,
          ),
          glassStrongOpacity: _shared(
            glassStrongOpacity,
            this.glassStrongOpacity,
            currentMobile.glassStrongOpacity,
          ),
          barOpacity: _shared(
            barOpacity,
            this.barOpacity,
            currentMobile.barOpacity,
          ),
          barOpacityDark: _shared(
            barOpacityDark,
            this.barOpacityDark,
            currentMobile.barOpacityDark,
          ),
          cardOpacity: _shared(
            cardOpacity,
            this.cardOpacity,
            currentMobile.cardOpacity,
          ),
          cardOpacityDark: _shared(
            cardOpacityDark,
            this.cardOpacityDark,
            currentMobile.cardOpacityDark,
          ),
          cardBlur: _shared(cardBlur, this.cardBlur, currentMobile.cardBlur),
          popoverOpacity: _shared(
            popoverOpacity,
            this.popoverOpacity,
            currentMobile.popoverOpacity,
          ),
          popoverOpacityDark: _shared(
            popoverOpacityDark,
            this.popoverOpacityDark,
            currentMobile.popoverOpacityDark,
          ),
          tooltipOpacity: _shared(
            tooltipOpacity,
            this.tooltipOpacity,
            currentMobile.tooltipOpacity,
          ),
          tooltipOpacityDark: _shared(
            tooltipOpacityDark,
            this.tooltipOpacityDark,
            currentMobile.tooltipOpacityDark,
          ),
          menuHighlightOpacity: _shared(
            menuHighlightOpacity,
            this.menuHighlightOpacity,
            currentMobile.menuHighlightOpacity,
          ),
          menuHighlightOpacityDark: _shared(
            menuHighlightOpacityDark,
            this.menuHighlightOpacityDark,
            currentMobile.menuHighlightOpacityDark,
          ),
          tableHoverOpacity: _shared(
            tableHoverOpacity,
            this.tableHoverOpacity,
            currentMobile.tableHoverOpacity,
          ),
          tableSelectionTinted: _shared(
            tableSelectionTinted,
            this.tableSelectionTinted,
            currentMobile.tableSelectionTinted,
          ),
          cardShadowDark: _shared(
            cardShadowDark,
            this.cardShadowDark,
            currentMobile.cardShadowDark,
          ),
          floatingShadow: _shared(
            floatingShadow,
            this.floatingShadow,
            currentMobile.floatingShadow,
          ),
          floatingShadowDark: _shared(
            floatingShadowDark,
            this.floatingShadowDark,
            currentMobile.floatingShadowDark,
          ),
          pagePaddingX: _shared(
            pagePaddingX,
            this.pagePaddingX,
            currentMobile.pagePaddingX,
          ),
          pagePaddingY: _shared(
            pagePaddingY,
            this.pagePaddingY,
            currentMobile.pagePaddingY,
          ),
          pageMaxWidth: _shared(
            pageMaxWidth,
            this.pageMaxWidth,
            currentMobile.pageMaxWidth,
          ),
          gapXs: _shared(gapXs, this.gapXs, currentMobile.gapXs),
          gapSm: _shared(gapSm, this.gapSm, currentMobile.gapSm),
          gapMd: _shared(gapMd, this.gapMd, currentMobile.gapMd),
          gapLg: _shared(gapLg, this.gapLg, currentMobile.gapLg),
          gapXl: _shared(gapXl, this.gapXl, currentMobile.gapXl),
          appBarHeight: _shared(
            appBarHeight,
            this.appBarHeight,
            currentMobile.appBarHeight,
          ),
          fabSize: _shared(fabSize, this.fabSize, currentMobile.fabSize),
          fabSizeSm: _shared(
            fabSizeSm,
            this.fabSizeSm,
            currentMobile.fabSizeSm,
          ),
          fabSizeLg: _shared(
            fabSizeLg,
            this.fabSizeLg,
            currentMobile.fabSizeLg,
          ),
          navigationItemWidth: _shared(
            navigationItemWidth,
            this.navigationItemWidth,
            currentMobile.navigationItemWidth,
          ),
          navigationIconSize: _shared(
            navigationIconSize,
            this.navigationIconSize,
            currentMobile.navigationIconSize,
          ),
          navigationIndicatorHeight: _shared(
            navigationIndicatorHeight,
            this.navigationIndicatorHeight,
            currentMobile.navigationIndicatorHeight,
          ),
          bottomNavigationItemWidth: _shared(
            bottomNavigationItemWidth,
            this.bottomNavigationItemWidth,
            currentMobile.bottomNavigationItemWidth,
          ),
          bottomNavigationItemHeight: _shared(
            bottomNavigationItemHeight,
            this.bottomNavigationItemHeight,
            currentMobile.bottomNavigationItemHeight,
          ),
          bottomNavigationIconSize: _shared(
            bottomNavigationIconSize,
            this.bottomNavigationIconSize,
            currentMobile.bottomNavigationIconSize,
          ),
          bottomNavigationPadding: _shared(
            bottomNavigationPadding,
            this.bottomNavigationPadding,
            currentMobile.bottomNavigationPadding,
          ),
          bottomNavigationFloating: _shared(
            bottomNavigationFloating,
            this.bottomNavigationFloating,
            currentMobile.bottomNavigationFloating,
          ),
          bottomNavigationOpacity: _shared(
            bottomNavigationOpacity,
            this.bottomNavigationOpacity,
            currentMobile.bottomNavigationOpacity,
          ),
          bottomNavigationOpacityDark: _shared(
            bottomNavigationOpacityDark,
            this.bottomNavigationOpacityDark,
            currentMobile.bottomNavigationOpacityDark,
          ),
          bottomNavigationLift: _shared(
            bottomNavigationLift,
            this.bottomNavigationLift,
            currentMobile.bottomNavigationLift,
          ),
          bottomNavigationLiftDark: _shared(
            bottomNavigationLiftDark,
            this.bottomNavigationLiftDark,
            currentMobile.bottomNavigationLiftDark,
          ),
          bottomNavigationBorderOpacity: _shared(
            bottomNavigationBorderOpacity,
            this.bottomNavigationBorderOpacity,
            currentMobile.bottomNavigationBorderOpacity,
          ),
          bottomNavigationBorderOpacityDark: _shared(
            bottomNavigationBorderOpacityDark,
            this.bottomNavigationBorderOpacityDark,
            currentMobile.bottomNavigationBorderOpacityDark,
          ),
          bottomNavigationRimOpacity: _shared(
            bottomNavigationRimOpacity,
            this.bottomNavigationRimOpacity,
            currentMobile.bottomNavigationRimOpacity,
          ),
          bottomNavigationRimOpacityDark: _shared(
            bottomNavigationRimOpacityDark,
            this.bottomNavigationRimOpacityDark,
            currentMobile.bottomNavigationRimOpacityDark,
          ),
          chipHeight: _shared(
            chipHeight,
            this.chipHeight,
            currentMobile.chipHeight,
          ),
          chipPaddingX: _shared(
            chipPaddingX,
            this.chipPaddingX,
            currentMobile.chipPaddingX,
          ),
          chipGap: _shared(chipGap, this.chipGap, currentMobile.chipGap),
          chipIconSize: _shared(
            chipIconSize,
            this.chipIconSize,
            currentMobile.chipIconSize,
          ),
          chipRadius: _shared(
            chipRadius,
            this.chipRadius,
            currentMobile.chipRadius,
          ),
          listTilePaddingX: _shared(
            listTilePaddingX,
            this.listTilePaddingX,
            currentMobile.listTilePaddingX,
          ),
          listTilePaddingY: _shared(
            listTilePaddingY,
            this.listTilePaddingY,
            currentMobile.listTilePaddingY,
          ),
          listTileGap: _shared(
            listTileGap,
            this.listTileGap,
            currentMobile.listTileGap,
          ),
          chatBubbleRadius: _shared(
            chatBubbleRadius,
            this.chatBubbleRadius,
            currentMobile.chatBubbleRadius,
          ),
          chatBubbleTailRadius: _shared(
            chatBubbleTailRadius,
            this.chatBubbleTailRadius,
            currentMobile.chatBubbleTailRadius,
          ),
          chatBubblePaddingX: _shared(
            chatBubblePaddingX,
            this.chatBubblePaddingX,
            currentMobile.chatBubblePaddingX,
          ),
          chatBubblePaddingY: _shared(
            chatBubblePaddingY,
            this.chatBubblePaddingY,
            currentMobile.chatBubblePaddingY,
          ),
          tabHeight: _shared(
            tabHeight,
            this.tabHeight,
            currentMobile.tabHeight,
          ),
          underlineTabHeight: _shared(
            underlineTabHeight,
            this.underlineTabHeight,
            currentMobile.underlineTabHeight,
          ),
          avatarSize: _shared(
            avatarSize,
            this.avatarSize,
            currentMobile.avatarSize,
          ),
          display: _shared(display, this.display, currentMobile.display),
          headline: _shared(headline, this.headline, currentMobile.headline),
          subtitle: _shared(subtitle, this.subtitle, currentMobile.subtitle),
          small: _shared(small, this.small, currentMobile.small),
          concentricTabs: _shared(
            concentricTabs,
            this.concentricTabs,
            currentMobile.concentricTabs,
          ),
          secondaryButtonFill: _shared(
            secondaryButtonFill,
            this.secondaryButtonFill,
            currentMobile.secondaryButtonFill,
          ),
          secondaryBadgeFill: _shared(
            secondaryBadgeFill,
            this.secondaryBadgeFill,
            currentMobile.secondaryBadgeFill,
          ),
          secondaryBadgeSubtle: _shared(
            secondaryBadgeSubtle,
            this.secondaryBadgeSubtle,
            currentMobile.secondaryBadgeSubtle,
          ),
          progressTrackFill: _shared(
            progressTrackFill,
            this.progressTrackFill,
            currentMobile.progressTrackFill,
          ),
          progressTinted: _shared(
            progressTinted,
            this.progressTinted,
            currentMobile.progressTinted,
          ),
          dividerMargin: _shared(
            dividerMargin,
            this.dividerMargin,
            currentMobile.dividerMargin,
          ),
          timelineLineGap: _shared(
            timelineLineGap,
            this.timelineLineGap,
            currentMobile.timelineLineGap,
          ),
          iconOpticalSize: _shared(
            iconOpticalSize,
            this.iconOpticalSize,
            currentMobile.iconOpticalSize,
          ),
          iconOpticalStrength: _shared(
            iconOpticalStrength,
            this.iconOpticalStrength,
            currentMobile.iconOpticalStrength,
          ),
          tabsListFill: _shared(
            tabsListFill,
            this.tabsListFill,
            currentMobile.tabsListFill,
          ),
          tabSelectedFill: _shared(
            tabSelectedFill,
            this.tabSelectedFill,
            currentMobile.tabSelectedFill,
          ),
          tabUnselectedMuted: _shared(
            tabUnselectedMuted,
            this.tabUnselectedMuted,
            currentMobile.tabUnselectedMuted,
          ),
          tabsGap: _shared(tabsGap, this.tabsGap, currentMobile.tabsGap),
          motion: _shared(motion, this.motion, currentMobile.motion),
        );
    return StyleTokens(
      name: name ?? this.name,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      dialogRadius: dialogRadius ?? this.dialogRadius,
      popoverRadius: popoverRadius ?? this.popoverRadius,
      tooltipRadius: tooltipRadius ?? this.tooltipRadius,
      commandRadius: commandRadius ?? this.commandRadius,
      commandItemDialogRadius:
          commandItemDialogRadius ?? this.commandItemDialogRadius,
      commandSearchRadius: commandSearchRadius ?? this.commandSearchRadius,
      textareaRadius: textareaRadius ?? this.textareaRadius,
      itemRadius: itemRadius ?? this.itemRadius,
      checkboxRadius: checkboxRadius ?? this.checkboxRadius,
      cardBorderOpacity: cardBorderOpacity ?? this.cardBorderOpacity,
      cardBorderOpacityDark:
          cardBorderOpacityDark ?? this.cardBorderOpacityDark,
      surfaceBorderOpacity: surfaceBorderOpacity ?? this.surfaceBorderOpacity,
      surfaceBorderOpacityDark:
          surfaceBorderOpacityDark ?? this.surfaceBorderOpacityDark,
      dialogBorderOpacity: dialogBorderOpacity ?? this.dialogBorderOpacity,
      dialogBorderOpacityDark:
          dialogBorderOpacityDark ?? this.dialogBorderOpacityDark,
      surfaceRadiusCap: surfaceRadiusCap ?? this.surfaceRadiusCap,
      ringWidth: ringWidth ?? this.ringWidth,
      ringOpacity: ringOpacity ?? this.ringOpacity,
      title: title ?? this.title,
      label: label ?? this.label,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
      field: field ?? this.field,
      cardShadow: cardShadow ?? this.cardShadow,
      popoverShadow: popoverShadow ?? this.popoverShadow,
      dialogShadow: dialogShadow ?? this.dialogShadow,
      sheetShadow: sheetShadow ?? this.sheetShadow,
      outlineButtonFill: outlineButtonFill ?? this.outlineButtonFill,
      outlineButtonFillDark:
          outlineButtonFillDark ?? this.outlineButtonFillDark,
      outlineButtonHoverFill:
          outlineButtonHoverFill ?? this.outlineButtonHoverFill,
      outlineButtonHoverFillDark:
          outlineButtonHoverFillDark ?? this.outlineButtonHoverFillDark,
      outlineButtonDarkInputBorder:
          outlineButtonDarkInputBorder ?? this.outlineButtonDarkInputBorder,
      linkUnderline: linkUnderline ?? this.linkUnderline,
      flatBadges: flatBadges ?? this.flatBadges,
      controlShadow: controlShadow ?? this.controlShadow,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      buttonHeightSm: buttonHeightSm ?? this.buttonHeightSm,
      buttonHeightLg: buttonHeightLg ?? this.buttonHeightLg,
      buttonPaddingX: buttonPaddingX ?? this.buttonPaddingX,
      buttonPaddingXSm: buttonPaddingXSm ?? this.buttonPaddingXSm,
      buttonPaddingXLg: buttonPaddingXLg ?? this.buttonPaddingXLg,
      buttonGap: buttonGap ?? this.buttonGap,
      buttonIconSize: buttonIconSize ?? this.buttonIconSize,
      buttonIconSizeSm: buttonIconSizeSm ?? this.buttonIconSizeSm,
      buttonIconSizeLg: buttonIconSizeLg ?? this.buttonIconSizeLg,
      toggleIconSize: toggleIconSize ?? this.toggleIconSize,
      badgeIconSize: badgeIconSize ?? this.badgeIconSize,
      iconButtonSize: iconButtonSize ?? this.iconButtonSize,
      iconButtonSizeSm: iconButtonSizeSm ?? this.iconButtonSizeSm,
      iconButtonSizeLg: iconButtonSizeLg ?? this.iconButtonSizeLg,
      iconButtonIconSize: iconButtonIconSize ?? this.iconButtonIconSize,
      iconButtonIconSizeSm: iconButtonIconSizeSm ?? this.iconButtonIconSizeSm,
      iconButtonIconSizeLg: iconButtonIconSizeLg ?? this.iconButtonIconSizeLg,
      inputHeight: inputHeight ?? this.inputHeight,
      inputPaddingX: inputPaddingX ?? this.inputPaddingX,
      inputPaddingY: inputPaddingY ?? this.inputPaddingY,
      textareaPaddingX: textareaPaddingX ?? this.textareaPaddingX,
      textareaPaddingY: textareaPaddingY ?? this.textareaPaddingY,
      underlinedFields: underlinedFields ?? this.underlinedFields,
      fieldFill: fieldFill ?? this.fieldFill,
      fieldFillDark: fieldFillDark ?? this.fieldFillDark,
      fieldBorderless: fieldBorderless ?? this.fieldBorderless,
      selectPaddingX: selectPaddingX ?? this.selectPaddingX,
      menuPadding: menuPadding ?? this.menuPadding,
      menuMinWidth: menuMinWidth ?? this.menuMinWidth,
      itemPaddingX: itemPaddingX ?? this.itemPaddingX,
      itemPaddingY: itemPaddingY ?? this.itemPaddingY,
      menubarHeight: menubarHeight ?? this.menubarHeight,
      menubarPadding: menubarPadding ?? this.menubarPadding,
      calendarCellSize: calendarCellSize ?? this.calendarCellSize,
      calendarCellRadius: calendarCellRadius ?? this.calendarCellRadius,
      calendarPadding: calendarPadding ?? this.calendarPadding,
      calendarCaptionHeight:
          calendarCaptionHeight ?? this.calendarCaptionHeight,
      commandPadding: commandPadding ?? this.commandPadding,
      commandGroupPadding: commandGroupPadding ?? this.commandGroupPadding,
      commandSearchHeight: commandSearchHeight ?? this.commandSearchHeight,
      commandSearchFill: commandSearchFill ?? this.commandSearchFill,
      commandSearchFillDark:
          commandSearchFillDark ?? this.commandSearchFillDark,
      commandSearchBorderOpacity:
          commandSearchBorderOpacity ?? this.commandSearchBorderOpacity,
      commandSearchUnderline:
          commandSearchUnderline ?? this.commandSearchUnderline,
      sidebarItemHeight: sidebarItemHeight ?? this.sidebarItemHeight,
      sidebarItemHeightSm: sidebarItemHeightSm ?? this.sidebarItemHeightSm,
      sidebarItemHeightLg: sidebarItemHeightLg ?? this.sidebarItemHeightLg,
      sidebarItemPaddingX: sidebarItemPaddingX ?? this.sidebarItemPaddingX,
      sidebarSubItemPaddingX:
          sidebarSubItemPaddingX ?? this.sidebarSubItemPaddingX,
      controlFill: controlFill ?? this.controlFill,
      controlFillDark: controlFillDark ?? this.controlFillDark,
      controlBorderless: controlBorderless ?? this.controlBorderless,
      radioCheckedOutline: radioCheckedOutline ?? this.radioCheckedOutline,
      checkboxSize: checkboxSize ?? this.checkboxSize,
      radioSize: radioSize ?? this.radioSize,
      switchWidth: switchWidth ?? this.switchWidth,
      switchHeight: switchHeight ?? this.switchHeight,
      switchThumbSize: switchThumbSize ?? this.switchThumbSize,
      sliderTrackHeight: sliderTrackHeight ?? this.sliderTrackHeight,
      sliderThumbSize: sliderThumbSize ?? this.sliderThumbSize,
      sliderTrackFill: sliderTrackFill ?? this.sliderTrackFill,
      sliderThumbFilled: sliderThumbFilled ?? this.sliderThumbFilled,
      cardPadding: cardPadding ?? this.cardPadding,
      cardGap: cardGap ?? this.cardGap,
      dialogPadding: dialogPadding ?? this.dialogPadding,
      dialogGap: dialogGap ?? this.dialogGap,
      popoverPadding: popoverPadding ?? this.popoverPadding,
      tabsListPadding: tabsListPadding ?? this.tabsListPadding,
      tabsListRadius: tabsListRadius ?? this.tabsListRadius,
      tabRadius: tabRadius ?? this.tabRadius,
      tabSelectedShadow: tabSelectedShadow ?? this.tabSelectedShadow,
      tabPaddingX: tabPaddingX ?? this.tabPaddingX,
      tabPaddingY: tabPaddingY ?? this.tabPaddingY,
      accordionTitlePaddingY:
          accordionTitlePaddingY ?? this.accordionTitlePaddingY,
      alertRadius: alertRadius ?? this.alertRadius,
      alertPaddingX: alertPaddingX ?? this.alertPaddingX,
      alertPaddingY: alertPaddingY ?? this.alertPaddingY,
      alertGap: alertGap ?? this.alertGap,
      alertIconGap: alertIconGap ?? this.alertIconGap,
      alertIconSize: alertIconSize ?? this.alertIconSize,
      alertIconOffset: alertIconOffset ?? this.alertIconOffset,
      alertAccentBar: alertAccentBar ?? this.alertAccentBar,
      tableCellPadding: tableCellPadding ?? this.tableCellPadding,
      kbdHeight: kbdHeight ?? this.kbdHeight,
      kbdPaddingX: kbdPaddingX ?? this.kbdPaddingX,
      progressHeight: progressHeight ?? this.progressHeight,
      radius: radius ?? this.radius,
      radiusScale: radiusScale ?? this.radiusScale,
      iconButtonRadius: iconButtonRadius ?? this.iconButtonRadius,
      badgeRadius: badgeRadius ?? this.badgeRadius,
      badgeHeight: badgeHeight ?? this.badgeHeight,
      badgePaddingX: badgePaddingX ?? this.badgePaddingX,
      outlineButtonStrongBorder:
          outlineButtonStrongBorder ?? this.outlineButtonStrongBorder,
      glassBlur: glassBlur ?? this.glassBlur,
      glassSaturation: glassSaturation ?? this.glassSaturation,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      glassOpacityDark: glassOpacityDark ?? this.glassOpacityDark,
      glassStrongOpacity: glassStrongOpacity ?? this.glassStrongOpacity,
      barOpacity: barOpacity ?? this.barOpacity,
      barOpacityDark: barOpacityDark ?? this.barOpacityDark,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      cardOpacityDark: cardOpacityDark ?? this.cardOpacityDark,
      cardBlur: cardBlur ?? this.cardBlur,
      popoverOpacity: popoverOpacity ?? this.popoverOpacity,
      popoverOpacityDark: popoverOpacityDark ?? this.popoverOpacityDark,
      tooltipOpacity: tooltipOpacity ?? this.tooltipOpacity,
      tooltipOpacityDark: tooltipOpacityDark ?? this.tooltipOpacityDark,
      menuHighlightOpacity: menuHighlightOpacity ?? this.menuHighlightOpacity,
      menuHighlightOpacityDark:
          menuHighlightOpacityDark ?? this.menuHighlightOpacityDark,
      tableHoverOpacity: tableHoverOpacity ?? this.tableHoverOpacity,
      tableSelectionTinted: tableSelectionTinted ?? this.tableSelectionTinted,
      cardShadowDark: cardShadowDark ?? this.cardShadowDark,
      floatingShadow: floatingShadow ?? this.floatingShadow,
      floatingShadowDark: floatingShadowDark ?? this.floatingShadowDark,
      pagePaddingX: pagePaddingX ?? this.pagePaddingX,
      pagePaddingY: pagePaddingY ?? this.pagePaddingY,
      pageMaxWidth: pageMaxWidth ?? this.pageMaxWidth,
      gapXs: gapXs ?? this.gapXs,
      gapSm: gapSm ?? this.gapSm,
      gapMd: gapMd ?? this.gapMd,
      gapLg: gapLg ?? this.gapLg,
      gapXl: gapXl ?? this.gapXl,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      fabSize: fabSize ?? this.fabSize,
      fabSizeSm: fabSizeSm ?? this.fabSizeSm,
      fabSizeLg: fabSizeLg ?? this.fabSizeLg,
      navigationItemWidth: navigationItemWidth ?? this.navigationItemWidth,
      navigationIconSize: navigationIconSize ?? this.navigationIconSize,
      navigationIndicatorHeight:
          navigationIndicatorHeight ?? this.navigationIndicatorHeight,
      bottomNavigationItemWidth:
          bottomNavigationItemWidth ?? this.bottomNavigationItemWidth,
      bottomNavigationItemHeight:
          bottomNavigationItemHeight ?? this.bottomNavigationItemHeight,
      bottomNavigationIconSize:
          bottomNavigationIconSize ?? this.bottomNavigationIconSize,
      bottomNavigationPadding:
          bottomNavigationPadding ?? this.bottomNavigationPadding,
      bottomNavigationFloating:
          bottomNavigationFloating ?? this.bottomNavigationFloating,
      bottomNavigationOpacity:
          bottomNavigationOpacity ?? this.bottomNavigationOpacity,
      bottomNavigationOpacityDark:
          bottomNavigationOpacityDark ?? this.bottomNavigationOpacityDark,
      bottomNavigationLift: bottomNavigationLift ?? this.bottomNavigationLift,
      bottomNavigationLiftDark:
          bottomNavigationLiftDark ?? this.bottomNavigationLiftDark,
      bottomNavigationBorderOpacity:
          bottomNavigationBorderOpacity ?? this.bottomNavigationBorderOpacity,
      bottomNavigationBorderOpacityDark:
          bottomNavigationBorderOpacityDark ??
          this.bottomNavigationBorderOpacityDark,
      bottomNavigationRimOpacity:
          bottomNavigationRimOpacity ?? this.bottomNavigationRimOpacity,
      bottomNavigationRimOpacityDark:
          bottomNavigationRimOpacityDark ?? this.bottomNavigationRimOpacityDark,
      chipHeight: chipHeight ?? this.chipHeight,
      chipPaddingX: chipPaddingX ?? this.chipPaddingX,
      chipGap: chipGap ?? this.chipGap,
      chipIconSize: chipIconSize ?? this.chipIconSize,
      chipRadius: chipRadius ?? this.chipRadius,
      listTilePaddingX: listTilePaddingX ?? this.listTilePaddingX,
      listTilePaddingY: listTilePaddingY ?? this.listTilePaddingY,
      listTileGap: listTileGap ?? this.listTileGap,
      chatBubbleRadius: chatBubbleRadius ?? this.chatBubbleRadius,
      chatBubbleTailRadius: chatBubbleTailRadius ?? this.chatBubbleTailRadius,
      chatBubblePaddingX: chatBubblePaddingX ?? this.chatBubblePaddingX,
      chatBubblePaddingY: chatBubblePaddingY ?? this.chatBubblePaddingY,
      tabHeight: tabHeight ?? this.tabHeight,
      underlineTabHeight: underlineTabHeight ?? this.underlineTabHeight,
      avatarSize: avatarSize ?? this.avatarSize,
      display: display ?? this.display,
      headline: headline ?? this.headline,
      subtitle: subtitle ?? this.subtitle,
      small: small ?? this.small,
      concentricTabs: concentricTabs ?? this.concentricTabs,
      secondaryButtonFill: secondaryButtonFill ?? this.secondaryButtonFill,
      secondaryBadgeFill: secondaryBadgeFill ?? this.secondaryBadgeFill,
      secondaryBadgeSubtle: secondaryBadgeSubtle ?? this.secondaryBadgeSubtle,
      progressTrackFill: progressTrackFill ?? this.progressTrackFill,
      progressTinted: progressTinted ?? this.progressTinted,
      dividerMargin: dividerMargin ?? this.dividerMargin,
      timelineLineGap: timelineLineGap ?? this.timelineLineGap,
      iconOpticalSize: iconOpticalSize ?? this.iconOpticalSize,
      iconOpticalStrength: iconOpticalStrength ?? this.iconOpticalStrength,
      tabsListFill: tabsListFill ?? this.tabsListFill,
      tabSelectedFill: tabSelectedFill ?? this.tabSelectedFill,
      tabUnselectedMuted: tabUnselectedMuted ?? this.tabUnselectedMuted,
      tabsGap: tabsGap ?? this.tabsGap,
      motion: motion ?? this.motion,
      mobile: nextMobile,
    );
  }

  /// Every field, in declaration order — the basis of [==] and [hashCode].
  List<Object?> get _props => [
    name,
    buttonRadius,
    cardRadius,
    dialogRadius,
    popoverRadius,
    tooltipRadius,
    commandRadius,
    commandItemDialogRadius,
    commandSearchRadius,
    textareaRadius,
    itemRadius,
    checkboxRadius,
    cardBorderOpacity,
    cardBorderOpacityDark,
    surfaceBorderOpacity,
    surfaceBorderOpacityDark,
    dialogBorderOpacity,
    dialogBorderOpacityDark,
    surfaceRadiusCap,
    ringWidth,
    ringOpacity,
    title,
    label,
    body,
    caption,
    overline,
    field,
    cardShadow,
    popoverShadow,
    dialogShadow,
    sheetShadow,
    outlineButtonFill,
    outlineButtonFillDark,
    outlineButtonHoverFill,
    outlineButtonHoverFillDark,
    outlineButtonDarkInputBorder,
    linkUnderline,
    flatBadges,
    controlShadow,
    buttonHeight,
    buttonHeightSm,
    buttonHeightLg,
    buttonPaddingX,
    buttonPaddingXSm,
    buttonPaddingXLg,
    buttonGap,
    buttonIconSize,
    buttonIconSizeSm,
    buttonIconSizeLg,
    toggleIconSize,
    badgeIconSize,
    iconButtonSize,
    iconButtonSizeSm,
    iconButtonSizeLg,
    iconButtonIconSize,
    iconButtonIconSizeSm,
    iconButtonIconSizeLg,
    inputHeight,
    inputPaddingX,
    inputPaddingY,
    textareaPaddingX,
    textareaPaddingY,
    underlinedFields,
    fieldFill,
    fieldFillDark,
    fieldBorderless,
    selectPaddingX,
    menuPadding,
    menuMinWidth,
    itemPaddingX,
    itemPaddingY,
    sidebarItemHeight,
    sidebarItemHeightSm,
    sidebarItemHeightLg,
    sidebarItemPaddingX,
    sidebarSubItemPaddingX,
    menubarHeight,
    menubarPadding,
    calendarCellSize,
    calendarCellRadius,
    calendarPadding,
    calendarCaptionHeight,
    commandPadding,
    commandGroupPadding,
    commandSearchHeight,
    commandSearchFill,
    commandSearchFillDark,
    commandSearchBorderOpacity,
    commandSearchUnderline,
    controlFill,
    controlFillDark,
    controlBorderless,
    radioCheckedOutline,
    checkboxSize,
    radioSize,
    switchWidth,
    switchHeight,
    switchThumbSize,
    sliderTrackHeight,
    sliderThumbSize,
    sliderTrackFill,
    sliderThumbFilled,
    cardPadding,
    cardGap,
    dialogPadding,
    dialogGap,
    popoverPadding,
    tabsListPadding,
    tabsListRadius,
    tabRadius,
    tabSelectedShadow,
    tabPaddingX,
    tabPaddingY,
    accordionTitlePaddingY,
    alertRadius,
    alertPaddingX,
    alertPaddingY,
    alertGap,
    alertIconGap,
    alertIconSize,
    alertIconOffset,
    alertAccentBar,
    tableCellPadding,
    kbdHeight,
    kbdPaddingX,
    progressHeight,
    radius,
    radiusScale,
    iconButtonRadius,
    badgeRadius,
    badgeHeight,
    badgePaddingX,
    outlineButtonStrongBorder,
    glassBlur,
    glassSaturation,
    glassOpacity,
    glassOpacityDark,
    glassStrongOpacity,
    barOpacity,
    barOpacityDark,
    cardOpacity,
    cardOpacityDark,
    cardBlur,
    popoverOpacity,
    popoverOpacityDark,
    tooltipOpacity,
    tooltipOpacityDark,
    menuHighlightOpacity,
    menuHighlightOpacityDark,
    tableHoverOpacity,
    tableSelectionTinted,
    cardShadowDark,
    floatingShadow,
    floatingShadowDark,
    pagePaddingX,
    pagePaddingY,
    pageMaxWidth,
    gapXs,
    gapSm,
    gapMd,
    gapLg,
    gapXl,
    appBarHeight,
    fabSize,
    fabSizeSm,
    fabSizeLg,
    navigationItemWidth,
    navigationIconSize,
    navigationIndicatorHeight,
    bottomNavigationItemWidth,
    bottomNavigationItemHeight,
    bottomNavigationIconSize,
    bottomNavigationPadding,
    bottomNavigationFloating,
    bottomNavigationOpacity,
    bottomNavigationOpacityDark,
    bottomNavigationLift,
    bottomNavigationLiftDark,
    bottomNavigationBorderOpacity,
    bottomNavigationBorderOpacityDark,
    bottomNavigationRimOpacity,
    bottomNavigationRimOpacityDark,
    chipHeight,
    chipPaddingX,
    chipGap,
    chipIconSize,
    chipRadius,
    listTilePaddingX,
    listTilePaddingY,
    listTileGap,
    chatBubbleRadius,
    chatBubbleTailRadius,
    chatBubblePaddingX,
    chatBubblePaddingY,
    tabHeight,
    underlineTabHeight,
    avatarSize,
    display,
    headline,
    subtitle,
    small,
    concentricTabs,
    secondaryButtonFill,
    secondaryBadgeFill,
    secondaryBadgeSubtle,
    progressTrackFill,
    progressTinted,
    dividerMargin,
    timelineLineGap,
    iconOpticalSize,
    iconOpticalStrength,
    tabsListFill,
    tabSelectedFill,
    tabUnselectedMuted,
    tabsGap,
    motion,
    mobile,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StyleTokens) return false;
    final a = _props;
    final b = other._props;
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      // Shadow lists are compared by value: two structurally identical lists
      // built at different call sites must not make two themes unequal, or
      // every rebuild re-animates the theme.
      if (x is List && y is List) {
        if (!listEquals<Object?>(x, y)) return false;
      } else if (x != y) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
    _props.map((p) => p is List ? Object.hashAll(p) : p),
  );

  @override
  String toString() => 'StyleTokens($name)';
}
