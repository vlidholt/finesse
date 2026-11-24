import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Strand's global search box: a magnifier, the prompt, and the hint for
/// the search shortcut — ⌘K on an Apple platform, Ctrl K elsewhere (see
/// [isSearchShortcut]).
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
    this.onPressed,
    this.groupId,
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

  /// Called when the field is tapped, focused already or not.
  final VoidCallback? onPressed;

  /// The tap-region group of the field: a tap in another region of the
  /// same group — a panel shown under the field — is not a tap outside it,
  /// and so does not take the focus away.
  final Object? groupId;

  final bool autofocus;

  /// Whether the platform has a Command key, which is then the modifier of
  /// the search shortcut; elsewhere it is Control.
  static bool get _apple => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => true,
    _ => false,
  };

  /// The search shortcut as a key cap reads it.
  static String get shortcutLabel => _apple ? '⌘K' : 'Ctrl K';

  /// Whether [event] is the search shortcut: K with Command alone on an
  /// Apple platform, with Control alone elsewhere.
  ///
  /// One modifier per platform, and no other with it, because the other
  /// chords are taken: Ctrl+K deletes to the end of the line in every
  /// macOS text field, and AltGr — which types a character on many
  /// layouts — reports itself as Control and Alt together on Windows.
  static bool isSearchShortcut(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyK) {
      return false;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isAltPressed) return false;
    return _apple
        ? keyboard.isMetaPressed && !keyboard.isControlPressed
        : keyboard.isControlPressed && !keyboard.isMetaPressed;
  }

  /// Whether the key cap of the search shortcut is shown at the end of the
  /// field.
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
              onPressed: onPressed,
              // A tap on a field that has the focus already is one too.
              onPressedAlwaysCalled: onPressed != null,
              groupId: groupId,
              textInputAction: TextInputAction.search,
              placeholder: Text(
                placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: PhosphorIcon(
                PhosphorIconsRegular.magnifyingGlass,
                size: theme.glyph,
                color: colors.mutedForeground,
              ),
              trailing: showShortcut && width >= 200
                  // The design's key cap is outlined, not filled: a hairline
                  // in the strong border colour.
                  ? Kbd(
                      shortcutLabel,
                      backgroundColor: const Color(0x00000000),
                      border: FinesseBorder.all(
                        color: colors.borderStrong,
                        width: 1,
                        radius: theme.radii.sm,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
