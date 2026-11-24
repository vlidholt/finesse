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
}

/// The metrics that distinguish one shadcn/ui *style* from another.
///
/// shadcn ships eight named styles. They are not colour variations — they are
/// full geometry sets. Comparing `registry/styles/style-*.css` shows the same
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
/// The field defaults here are `vega`'s, so a custom style only has to state
/// what it changes. That is separate from the *theme's* default style, which
/// is [nova] — shadcn's own `DEFAULT_CONFIG.style`.
@immutable
class StyleTokens {
  /// Creates a style. Only [name] is required; every other field defaults to
  /// [vega]'s value.
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

  // --- shadcn/ui's eight styles ------------------------------------------

  /// The registry's baseline: 36px controls, 24px card padding, a 3px ring.
  /// Every other style is expressed as a delta from it.
  static const vega = StyleTokens(name: 'vega');

  /// vega, one size down and a step rounder — and shadcn's default style,
  /// which is what a theme uses when none is given.
  static const nova = StyleTokens(
    name: 'nova',
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

  /// The densest of the eight: 28px controls.
  static const mira = StyleTokens(
    name: 'mira',
    calendarCellSize: 24,
    calendarCaptionHeight: 28,
    commandItemDialogRadius: RadiusToken.md,
    commandSearchRadius: RadiusToken.md,
    commandSearchFill: SurfaceFill.input20,
    commandSearchBorderOpacity: 1,
    cardRadius: RadiusToken.lg,
    popoverRadius: RadiusToken.lg,
    itemRadius: RadiusToken.md,
    ringWidth: 2,
    ringOpacity: .3,
    // `text-xs/relaxed` throughout: 12px on a 1.625 line.
    title: TextRole(fontSize: 14, fontWeight: FontWeight.w500),
    label: TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.625,
    ),
    body: TextRole(fontSize: 12, height: 1.625),
    caption: TextRole(fontSize: 10, fontWeight: FontWeight.w500),
    field: TextRole(fontSize: 12, height: 1.625),
    cardShadow: Shadows.none,
    controlShadow: Shadows.none,
    outlineButtonFill: SurfaceFill.none,
    outlineButtonHoverFill: SurfaceFill.input50,
    outlineButtonDarkInputBorder: false,
    fieldFill: SurfaceFill.input20,
    tabSelectedShadow: Shadows.none,
    buttonHeight: 28,
    buttonHeightSm: 24,
    buttonHeightLg: 32,
    buttonPaddingX: 8,
    buttonPaddingXSm: 8,
    buttonGap: 4,
    // The only style whose icons follow the size step all the way down.
    buttonIconSize: 14,
    buttonIconSizeSm: 12,
    badgeIconSize: 10,
    iconButtonSize: 28,
    iconButtonSizeSm: 24,
    iconButtonSizeLg: 32,
    iconButtonIconSize: 14,
    iconButtonIconSizeSm: 12,
    inputHeight: 28,
    inputPaddingX: 8,
    inputPaddingY: 2,
    textareaPaddingX: 8,
    textareaPaddingY: 8,
    selectPaddingX: 8,
    itemPaddingY: 4,
    switchWidth: 28,
    switchHeight: 16.6,
    switchThumbSize: 14,
    sliderTrackHeight: 4,
    sliderThumbSize: 12,
    cardPadding: 16,
    dialogPadding: 16,
    dialogGap: 4,
    popoverPadding: 10,
    tabPaddingX: 6,
    tabPaddingY: 2,
    accordionTitlePaddingY: 8,
    alertPaddingX: 8,
    alertPaddingY: 6,
    alertIconGap: 6,
    alertIconSize: 14,
    progressHeight: 4,
  );

  /// Soft and pill-shaped, with a wide switch and a thick slider.
  static const luma = StyleTokens(
    name: 'luma',
    calendarCellRadius: RadiusToken.xl4,
    commandRadius: RadiusToken.xl4,
    commandItemDialogRadius: RadiusToken.xl3,
    commandSearchRadius: RadiusToken.xl4,
    commandGroupPadding: 6,
    commandSearchHeight: 36,
    commandSearchFill: SurfaceFill.input50,
    commandSearchFillDark: SurfaceFill.input50,
    commandSearchBorderOpacity: 0,
    buttonRadius: RadiusToken.xl4,
    cardRadius: RadiusToken.xl4,
    alertRadius: RadiusToken.xl2,
    dialogRadius: RadiusToken.xl4,
    popoverRadius: RadiusToken.xl4,
    tooltipRadius: RadiusToken.xl,
    textareaRadius: RadiusToken.xl2,
    itemRadius: RadiusToken.xl2,
    checkboxRadius: 5,
    cardBorderOpacity: .05,
    cardBorderOpacityDark: .1,
    surfaceBorderOpacity: .05,
    surfaceBorderOpacityDark: .1,
    ringOpacity: .3,
    cardGap: 6,
    cardShadow: Shadows.md,
    controlShadow: Shadows.none,
    popoverShadow: Shadows.lg,
    dialogShadow: Shadows.xl,
    sheetShadow: Shadows.xl,
    outlineButtonFillDark: SurfaceFill.none,
    outlineButtonHoverFillDark: SurfaceFill.input30,
    outlineButtonDarkInputBorder: false,
    controlFill: SurfaceFill.input90,
    controlFillDark: SurfaceFill.input90,
    controlBorderless: true,
    fieldFill: SurfaceFill.input50,
    fieldFillDark: SurfaceFill.input50,
    fieldBorderless: true,
    sliderTrackFill: SurfaceFill.input90,
    tabsListRadius: RadiusToken.full,
    tabRadius: RadiusToken.full,
    tabSelectedShadow: Shadows.none,
    buttonPaddingX: 12,
    buttonPaddingXSm: 12,
    buttonPaddingXLg: 16,
    inputPaddingX: 12,
    textareaPaddingX: 12,
    textareaPaddingY: 12,
    selectPaddingX: 12,
    menuPadding: 6,
    menuMinWidth: 192,
    itemPaddingX: 12,
    itemPaddingY: 8,
    dialogGap: 6,
    switchWidth: 44,
    switchHeight: 20,
    sliderTrackHeight: 8,
    tabsListPadding: 4,
    tabPaddingX: 12,
    tableCellPadding: 12,
    kbdHeight: 22,
    kbdPaddingX: 6,
    progressHeight: 12,
    sidebarItemHeight: 36,
    sidebarItemHeightSm: 32,
    sidebarItemHeightLg: 56,
    sidebarItemPaddingX: 12,
    sidebarSubItemPaddingX: 12,
  );

  /// Editorial: square, uppercase, letter-spaced, and the largest of the eight.
  static const sera = StyleTokens(
    name: 'sera',
    calendarCellRadius: RadiusToken.none,
    commandRadius: RadiusToken.none,
    commandItemDialogRadius: RadiusToken.none,
    commandSearchRadius: RadiusToken.none,
    commandPadding: 0,
    commandGroupPadding: 6,
    commandSearchHeight: 40,
    commandSearchFill: SurfaceFill.none,
    commandSearchFillDark: SurfaceFill.none,
    commandSearchBorderOpacity: 0,
    commandSearchUnderline: true,
    buttonRadius: RadiusToken.none,
    cardRadius: RadiusToken.none,
    alertRadius: RadiusToken.none,
    alertGap: 4,
    alertAccentBar: true,
    dialogRadius: RadiusToken.none,
    popoverRadius: RadiusToken.none,
    tooltipRadius: RadiusToken.none,
    textareaRadius: RadiusToken.none,
    itemRadius: RadiusToken.none,
    checkboxRadius: 0,
    cardBorderOpacity: .05,
    ringWidth: 2,
    ringOpacity: .3,
    // Uppercase and tracked out, at Tailwind's `tracking-wider` (0.05em) and
    // `tracking-widest` (0.1em) converted to pixels at each size.
    title: TextRole(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9,
      uppercase: true,
    ),
    label: TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      uppercase: true,
    ),
    body: TextRole(fontSize: 14, height: 1.625),
    caption: TextRole(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      uppercase: true,
    ),
    overline: TextRole(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      uppercase: true,
    ),
    cardShadow: Shadows.sm,
    controlShadow: Shadows.none,
    dialogShadow: Shadows.md,
    sheetShadow: Shadows.md,
    outlineButtonFill: SurfaceFill.none,
    outlineButtonFillDark: SurfaceFill.none,
    outlineButtonHoverFillDark: SurfaceFill.input30,
    outlineButtonDarkInputBorder: false,
    linkUnderline: true,
    flatBadges: true,
    controlFillDark: SurfaceFill.none,
    fieldFillDark: SurfaceFill.none,
    radioCheckedOutline: true,
    sliderTrackFill: SurfaceFill.input50,
    sliderThumbFilled: true,
    tabsListRadius: RadiusToken.none,
    tabRadius: RadiusToken.none,
    tabSelectedShadow: Shadows.none,
    buttonHeight: 40,
    buttonHeightSm: 36,
    buttonHeightLg: 44,
    buttonPaddingX: 24,
    buttonPaddingXSm: 16,
    buttonPaddingXLg: 32,
    // The one style whose base glyph is `size-3.5` rather than `size-4`.
    buttonIconSize: 14,
    toggleIconSize: 14,
    buttonIconSizeSm: 14,
    buttonIconSizeLg: 14,
    iconButtonSize: 40,
    iconButtonSizeSm: 36,
    iconButtonSizeLg: 44,
    iconButtonIconSize: 14,
    iconButtonIconSizeSm: 14,
    iconButtonIconSizeLg: 14,
    inputHeight: 40,
    // sera's fields are underlined rather than boxed, so they carry no
    // horizontal inset at all.
    inputPaddingX: 0,
    textareaPaddingX: 0,
    textareaPaddingY: 12,
    underlinedFields: true,
    selectPaddingX: 0,
    menuPadding: 6,
    menuMinWidth: 192,
    itemPaddingX: 12,
    itemPaddingY: 8,
    menubarHeight: 40,
    checkboxSize: 18,
    radioSize: 18,
    switchWidth: 33,
    switchHeight: 18,
    switchThumbSize: 14,
    sliderTrackHeight: 2,
    sliderThumbSize: 12,
    cardPadding: 32,
    cardGap: 6,
    tabsListPadding: 4,
    tabPaddingX: 16,
    tabPaddingY: 6,
    tableCellPadding: 12,
    kbdHeight: 22,
    kbdPaddingX: 6,
    progressHeight: 2,
    sidebarItemHeight: 36,
    sidebarItemHeightSm: 32,
    sidebarItemHeightLg: 56,
    sidebarItemPaddingX: 12,
    sidebarSubItemPaddingX: 12,
  );

  /// Rounded and compact.
  static const rhea = StyleTokens(
    name: 'rhea',
    calendarCellRadius: RadiusToken.xl2,
    commandRadius: RadiusToken.xl3,
    commandItemDialogRadius: RadiusToken.xl2,
    commandSearchRadius: RadiusToken.xl2,
    commandSearchFill: SurfaceFill.input50,
    commandSearchFillDark: SurfaceFill.input50,
    commandSearchBorderOpacity: 0,
    buttonRadius: RadiusToken.xl2,
    // Card and dialog corners are the 4xl step, capped:
    // `rounded-[min(var(--radius-4xl),24px)]`.
    cardRadius: RadiusToken.xl4,
    alertRadius: RadiusToken.xl2,
    dialogRadius: RadiusToken.xl4,
    surfaceRadiusCap: 24,
    popoverRadius: RadiusToken.xl2,
    tooltipRadius: RadiusToken.xl,
    textareaRadius: RadiusToken.xl2,
    itemRadius: RadiusToken.xl,
    checkboxRadius: 5,
    cardBorderOpacity: .05,
    cardBorderOpacityDark: .1,
    surfaceBorderOpacity: .05,
    surfaceBorderOpacityDark: .1,
    ringOpacity: .3,
    cardShadow: Shadows.sm,
    controlShadow: Shadows.none,
    popoverShadow: Shadows.lg,
    dialogShadow: Shadows.xl,
    sheetShadow: Shadows.xl,
    outlineButtonFillDark: SurfaceFill.none,
    outlineButtonHoverFillDark: SurfaceFill.input30,
    outlineButtonDarkInputBorder: false,
    controlFill: SurfaceFill.input90,
    controlFillDark: SurfaceFill.input90,
    controlBorderless: true,
    fieldFill: SurfaceFill.input50,
    fieldFillDark: SurfaceFill.input50,
    fieldBorderless: true,
    sliderTrackFill: SurfaceFill.input90,
    tabsListRadius: RadiusToken.xl2,
    tabRadius: RadiusToken.xl2,
    tabSelectedShadow: Shadows.none,
    buttonHeight: 32,
    buttonHeightSm: 28,
    buttonHeightLg: 36,
    buttonPaddingX: 12,
    buttonPaddingXSm: 12,
    buttonPaddingXLg: 16,
    iconButtonSize: 32,
    iconButtonSizeSm: 28,
    iconButtonSizeLg: 36,
    inputHeight: 32,
    selectPaddingX: 12,
    menubarHeight: 32,
    menubarPadding: 3,
    dialogGap: 6,
    switchHeight: 20,
    sliderTrackHeight: 4,
    cardPadding: 20,
    cardGap: 6,
    tabPaddingX: 6,
    tabPaddingY: 2,
    progressHeight: 8,
    sidebarItemPaddingX: 12,
    sidebarSubItemPaddingX: 12,
  );

  /// All eight, in shadcn/ui's order.
  static const all = <StyleTokens>[
    vega,
    nova,
    maia,
    lyra,
    mira,
    luma,
    sera,
    rhea,
  ];

  /// Returns the style shadcn/ui calls [name], such as `nova`.
  ///
  /// Throws an [ArgumentError] for an unknown name.
  static StyleTokens fromName(String name) => all.firstWhere(
    (s) => s.name == name,
    orElse: () => throw ArgumentError.value(name, 'name', 'Unknown style'),
  );

  /// Creates a copy of this style with the given fields replaced.
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
  }) {
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
