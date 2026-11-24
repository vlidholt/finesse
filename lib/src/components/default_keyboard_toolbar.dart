import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// {@template DefaultKeyboardToolbar}
/// A default keyboard toolbar with "Previous", "Next", and "Done" buttons.
/// {@endtemplate}
class DefaultKeyboardToolbar extends StatelessWidget {
  /// {@macro DefaultKeyboardToolbar}
  const DefaultKeyboardToolbar({
    super.key,
    this.backgroundColor,
    this.doneText,
    this.showPreviousButton,
    this.showNextButton,
    this.showDoneButton,
  });

  /// {@template DefaultKeyboardToolbar.backgroundColor}
  /// The background color of the toolbar, defaults to ColorScheme.accent.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template DefaultKeyboardToolbar.doneText}
  /// The text of the "Done" button, defaults to "Done".
  /// {@endtemplate}
  final String? doneText;

  /// {@template DefaultKeyboardToolbar.showPreviousButton}
  /// Whether to show the "Previous" focus button, defaults to true.
  /// {@endtemplate}
  final bool? showPreviousButton;

  /// {@template DefaultKeyboardToolbar.showNextButton}
  /// Whether to show the "Next" focus button, defaults to true.
  /// {@endtemplate}
  final bool? showNextButton;

  /// {@template DefaultKeyboardToolbar.showDoneButton}
  /// Whether to show the "Done" button, defaults to true.
  /// {@endtemplate}
  final bool? showDoneButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor =
        backgroundColor ??
        theme.defaultKeyboardToolbarTheme.backgroundColor ??
        theme.colorScheme.accent;

    final l = FinesseLocalizations.of(context);
    final effectiveDoneText =
        doneText ??
        theme.defaultKeyboardToolbarTheme.doneText ??
        l.keyboardToolbar.done;

    final effectiveShowPreviousButton =
        showPreviousButton ??
        theme.defaultKeyboardToolbarTheme.showPreviousButton ??
        true;

    final effectiveShowNextButton =
        showNextButton ??
        theme.defaultKeyboardToolbarTheme.showNextButton ??
        true;

    final effectiveShowDoneButton =
        showDoneButton ??
        theme.defaultKeyboardToolbarTheme.showDoneButton ??
        true;

    return ColoredBox(
      color: effectiveBackgroundColor,
      child: FocusTraversalGroup(
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        child: Row(
          children: [
            if (effectiveShowPreviousButton)
              IconButton.ghost(
                icon: const Icon(LucideIcons.chevronUp),
                onPressed: () {
                  FocusScope.of(context).previousFocus();
                },
              ),
            if (effectiveShowNextButton)
              IconButton.ghost(
                icon: const Icon(LucideIcons.chevronDown),
                onPressed: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
            const Spacer(),
            if (effectiveShowDoneButton)
              Button.link(
                child: Text(effectiveDoneText),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
              ),
          ],
        ),
      ),
    );
  }
}
