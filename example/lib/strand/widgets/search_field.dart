import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Strand's global search box: a magnifier, the prompt, and the ⌘K hint.
///
/// It is the desktop app bar's title and the field at the top of the search
/// route on a phone. Its metrics are the theme's `TextField`; only the width
/// cap comes from the design.
///
/// The field gives way before it overflows: the shortcut hint goes first,
/// and below [collapseBelow] nothing is drawn at all, so a narrow app bar
/// keeps its logo and navigation rather than a sliver of a text field.
class SearchField extends StatelessWidget {
  const SearchField({
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.showShortcut = true,
    this.maxWidth = defaultWidth,
    this.collapseBelow = 120,
    this.placeholder = defaultPlaceholder,
    super.key,
  });

  /// The width the designs give the field in the desktop app bar.
  static const defaultWidth = 280.0;

  static const defaultPlaceholder = 'Search people, posts, jobs';

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  /// Whether the ⌘K key cap is shown at the end of the field.
  final bool showShortcut;

  /// The widest the field grows. Pass [double.infinity] to fill the parent.
  final double maxWidth;

  /// The width under which the field is not drawn.
  final double collapseBelow;

  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width < collapseBelow) return const SizedBox.shrink();
          return Semantics(
            label: 'Search',
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              placeholder: Text(
                placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: Icon(
                PhosphorIconsRegular.magnifyingGlass,
                size: 18,
                color: colors.mutedForeground,
              ),
              trailing: showShortcut && width >= 200
                  // The design's key cap is outlined, not filled: a hairline
                  // in the strong border colour, 11px text, 5px corners.
                  ? Kbd(
                      '⌘K',
                      backgroundColor: const Color(0x00000000),
                      border: FinesseBorder.all(
                        color: colors.borderStrong,
                        width: 1,
                        radius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      textStyle: const TextStyle(fontSize: 11, height: 1),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
