import 'package:finesse/src/components/bar_button_scope.dart';
import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/components/tooltip.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icon.dart';
import 'package:finesse/src/icons/phosphor_icons_regular.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// The button that goes back: a caret pointing at the start of the line.
///
/// ```dart
/// AppBar(
///   leading: const BackButton(),
///   title: const Text('Settings'),
/// )
/// ```
///
/// An `AppBar` on a page that can be popped shows one by itself. Pressed, it
/// pops the page — `Navigator.maybePop`, so the page gets its say through a
/// `PopScope` — unless [onPressed] says otherwise.
///
/// The caret points left in a left-to-right language and right in a
/// right-to-left one. The button is announced as "Back" in the app's
/// language, and on a desktop the same word is its tooltip.
class BackButton extends StatelessWidget {
  /// Creates a back button.
  const BackButton({
    this.onPressed,
    this.icon,
    this.semanticLabel,
    this.enabled = true,
    super.key,
  });

  /// Called when the button is pressed, in place of popping the page.
  final VoidCallback? onPressed;

  /// The icon, in place of the caret.
  final Widget? icon;

  /// What assistive technology reads, and the tooltip on a desktop.
  /// Defaults to the localized "Back".
  final String? semanticLabel;

  /// Whether the button responds.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return _DismissButton(
      label: semanticLabel ?? FinesseLocalizations.of(context).navigation.back,
      icon:
          icon ??
          PhosphorIcon(
            rtl
                ? PhosphorIconsRegular.caretRight
                : PhosphorIconsRegular.caretLeft,
          ),
      onPressed: onPressed,
      enabled: enabled,
    );
  }
}

/// The button that closes what it is on: a cross.
///
/// ```dart
/// AppBar(
///   leading: const CloseButton(),
///   title: const Text('New message'),
/// )
/// ```
///
/// An `AppBar` on a full-screen dialog shows one by itself. Pressed, it pops
/// the page — `Navigator.maybePop` — unless [onPressed] says otherwise. It
/// is announced as "Close" in the app's language, and on a desktop the same
/// word is its tooltip.
class CloseButton extends StatelessWidget {
  /// Creates a close button.
  const CloseButton({
    this.onPressed,
    this.icon,
    this.semanticLabel,
    this.enabled = true,
    super.key,
  });

  /// Called when the button is pressed, in place of popping the page.
  final VoidCallback? onPressed;

  /// The icon, in place of the cross.
  final Widget? icon;

  /// What assistive technology reads, and the tooltip on a desktop.
  /// Defaults to the localized "Close".
  final String? semanticLabel;

  /// Whether the button responds.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return _DismissButton(
      label: semanticLabel ?? FinesseLocalizations.of(context).dialog.close,
      icon: icon ?? const PhosphorIcon(PhosphorIconsRegular.x),
      onPressed: onPressed,
      enabled: enabled,
    );
  }
}

/// A ghost icon button that pops the page, named by [label].
class _DismissButton extends StatelessWidget {
  const _DismissButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Ghost, or what the bar it is in gives its buttons (an outline disc
    // over a picture).
    final button = IconButton(
      variant: BarButtonScope.variantOf(
        context,
        null,
        fallback: ButtonVariant.ghost,
      ),
      icon: icon,
      semanticLabel: label,
      enabled: enabled,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
    // A pointer can ask what the button does; a finger would only cover it.
    if (Theme.of(context).formFactor != FormFactor.desktop) return button;
    return Tooltip(builder: (context) => Text(label), child: button);
  }
}
