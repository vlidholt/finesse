import 'package:finesse/src/components/context_menu.dart';
import 'package:finesse/src/components/text_magnifier.dart';
import 'package:finesse/src/components/text_selection.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:flutter/widgets.dart';

// What `SelectionArea.onSelectionChanged` reports; the widgets library
// does not export it.
export 'package:flutter/rendering.dart' show SelectedContent;

/// Makes the text under [child] selectable, across widgets: a paragraph,
/// the heading above it and the list after it are one selection.
///
/// With a mouse the text is selected by dragging, double-click selects a
/// word and a right-click opens a menu with Copy and Select all. On a touch
/// screen a long press selects a word and shows this system's handles
/// ([FinesseTextSelectionControls]), toolbar ([TextSelectionToolbar]) and
/// magnifier ([TextMagnifier]). On the web the browser's own menu is used
/// unless the app has disabled it.
///
/// ```dart
/// SelectionArea(
///   child: Column(
///     children: [
///       Text('Terms of service', style: theme.textTheme.h3),
///       const Text('You may copy any part of this page.'),
///     ],
///   ),
/// )
/// ```
///
/// Wrap what should stay out of a selection — a button's label, a badge —
/// in `SelectionContainer.disabled`. A `Text` is selectable under an area
/// without further ado; a `TextField` keeps its own selection.
///
/// One area per page is the usual arrangement. An area keeps a focus node
/// of its own and takes the keyboard focus when a selection starts, so that
/// the copy shortcut reaches it.
class SelectionArea extends StatefulWidget {
  /// Makes the text under [child] selectable.
  const SelectionArea({
    required this.child,
    this.focusNode,
    this.selectionControls,
    this.contextMenuBuilder = defaultContextMenuBuilder,
    this.magnifierConfiguration,
    this.onSelectionChanged,
    super.key,
  });

  /// The content whose text can be selected.
  final Widget child;

  /// The focus node of the area. One is created when null.
  final FocusNode? focusNode;

  /// Builds the selection handles. Defaults to
  /// [FinesseTextSelectionControls.adaptive]: handles on a touch platform,
  /// none on a desktop.
  final TextSelectionControls? selectionControls;

  /// Builds the menu over a selection. Defaults to
  /// [defaultContextMenuBuilder]; null shows no menu.
  final SelectableRegionContextMenuBuilder? contextMenuBuilder;

  /// The magnifier shown while a handle is dragged. Defaults to
  /// [TextMagnifier.adaptiveConfiguration].
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Called when the selected content changes; null when nothing is
  /// selected any more.
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  /// The default menu of a selection: a [TextSelectionToolbar] on a touch
  /// platform and a [ContextMenu] at the pointer on a desktop, with the
  /// region's own actions (Copy, Select all).
  static Widget defaultContextMenuBuilder(
    BuildContext context,
    SelectableRegionState selectableRegionState,
  ) {
    if (FinesseTextSelectionControls.usesTouchSelection) {
      return TextSelectionToolbar.selectableRegion(
        selectableRegionState: selectableRegionState,
      );
    }
    final items = [
      for (final item in selectableRegionState.contextMenuButtonItems)
        if (TextSelectionToolbar.labelFor(context, item) case final label?)
          MenuItem(
            // On the way down, like the text field's menu: the press is
            // also a tap outside the region, which takes the menu away.
            onTapDown: item.onPressed == null ? null : (_) => item.onPressed!(),
            child: Text(label),
          ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return FocusScope(
      // The area keeps the focus: losing it would clear the selection the
      // menu is about.
      canRequestFocus: false,
      child: ContextMenu(
        open: true,
        anchor: GlobalAnchor(
          selectableRegionState.contextMenuAnchors.primaryAnchor,
        ),
        items: items,
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  State<SelectionArea> createState() => SelectionAreaState();
}

/// The state of a [SelectionArea]. Reach it with a
/// `GlobalKey<SelectionAreaState>` to act on the selection from outside —
/// `selectableRegion.selectAll()`, `selectableRegion.clearSelection()`.
class SelectionAreaState extends State<SelectionArea> {
  final _regionKey = GlobalKey<SelectableRegionState>();

  /// The state of the [SelectableRegion] the area is built on.
  SelectableRegionState get selectableRegion => _regionKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return SelectableRegion(
      key: _regionKey,
      focusNode: widget.focusNode,
      selectionControls:
          widget.selectionControls ??
          FinesseTextSelectionControls.adaptive ??
          _noHandles,
      contextMenuBuilder: widget.contextMenuBuilder,
      magnifierConfiguration:
          widget.magnifierConfiguration ?? TextMagnifier.adaptiveConfiguration,
      onSelectionChanged: widget.onSelectionChanged,
      child: widget.child,
    );
  }
}

/// A region needs controls even where it draws no handles.
final TextSelectionControls _noHandles = _NoHandleControls();

class _NoHandleControls extends TextSelectionControls
    with TextSelectionHandleControls {
  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) => const SizedBox.shrink();

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      Offset.zero;

  @override
  Size getHandleSize(double textLineHeight) => Size.zero;
}
