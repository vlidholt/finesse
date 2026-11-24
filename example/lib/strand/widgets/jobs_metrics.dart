/// The Jobs designs' off-scale gaps.
///
/// Spacing on this screen comes from the theme's gap scale (4 / 8 / 12 / 16 /
/// 24) wherever the design is on it. These are the in-between values the
/// design uses in more than a couple of places; a one-off stays a literal,
/// with a comment, where it is used.
library;

/// 6: between inline neighbours — two tags, an icon and its caption, a title
/// and the meta line under it.
const jobsInlineGap = 6.0;

/// 10: a tight gap, between the scale's 8 and 12 — fields in a row, a heading
/// and its text, a card's text and the tags under it.
const jobsTightGap = 10.0;

/// 14: between the scale's 12 and 16 — a logo and the text beside it, the
/// rhythm inside the search card and the match panel.
const jobsSnugGap = 14.0;

/// 20: between the scale's 16 and 24 — the two columns, the blocks inside the
/// detail pane.
const jobsWideGap = 20.0;
