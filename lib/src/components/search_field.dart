import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/spinner.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icon.dart';
import 'package:finesse/src/icons/phosphor_icons_regular.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A text field for a search: a magnifier at the start, a clear button
/// while it has text, and the keyboard's search action.
///
/// Its height, radius, padding and type are the theme's `TextField`'s, so it
/// lines up with every other control.
///
/// ```dart
/// SearchField(
///   placeholder: const Text('Search people'),
///   onChanged: (query) => setState(() => results = search(query)),
///   onSubmitted: openResults,
/// )
/// ```
///
/// * [loading] swaps the magnifier for a spinner while results are on
///   their way.
/// * [showCancel] is the phone pattern: while the field has the focus a
///   "Cancel" button slides in beside it, which clears the field and puts
///   the keyboard away.
/// * [trailing] takes a hint or an action — a `Kbd` naming the shortcut
///   ([shortcutLabel]), a filter button.
///
/// Escape clears a field that has text ([clearOnEscape]). With nothing to
/// clear the key is left for whatever encloses the field — the panel under
/// it, a dialog, the page — which knows what dismissing means there.
///
/// For a field with suggestions under it see `Autocomplete`; for a
/// full-screen search, `showSearch`.
class SearchField extends StatefulWidget {
  /// Creates a search field.
  const SearchField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
    this.onTap,
    this.onCancel,
    this.leading,
    this.trailing,
    this.loading = false,
    this.showCancel = false,
    this.clearable = true,
    this.clearOnEscape = true,
    this.autofocus = false,
    this.enabled = true,
    this.decoration,
    this.constraints,
    this.padding,
    this.groupId,
    this.semanticLabel,
  }) : assert(
         initialValue == null || controller == null,
         'Pass either an initialValue or a controller, not both.',
       );

  /// Controls the query. One is created when null.
  final TextEditingController? controller;

  /// The query the field starts with, when it has no [controller].
  final String? initialValue;

  /// The focus node of the field. One is created when null.
  final FocusNode? focusNode;

  /// The prompt shown while the field is empty, usually a [Text], on one
  /// line. Defaults to the localized "Search".
  final Widget? placeholder;

  /// Called when the query changes: as the user types, and with an empty
  /// string when the field is cleared.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the query — Return, or the keyboard's
  /// search key.
  final ValueChanged<String>? onSubmitted;

  /// Called after the field was emptied by its clear button, by Escape or
  /// by the Cancel button. [onChanged] is called first.
  final VoidCallback? onCleared;

  /// Called when the field is tapped, whether or not it had the focus
  /// already.
  final VoidCallback? onTap;

  /// Called by the Cancel button of [showCancel], after it has cleared the
  /// field and taken the focus from it.
  final VoidCallback? onCancel;

  /// The widget at the start of the field. Defaults to a magnifier, and to
  /// a spinner while [loading].
  final Widget? leading;

  /// A widget at the end of the field, after the clear button.
  final Widget? trailing;

  /// Whether results are being fetched: the leading magnifier becomes a
  /// spinner.
  final bool loading;

  /// Whether a "Cancel" button slides in at the end while the field has
  /// the focus. It clears the field, unfocuses it and calls [onCancel].
  ///
  /// With it the field needs a bounded width, like any text field in a row.
  final bool showCancel;

  /// Whether a clear button shows while the field has text. Defaults to
  /// true.
  final bool clearable;

  /// Whether Escape empties a field that has text. Defaults to true.
  ///
  /// Set it to false where Escape belongs to something around the field
  /// even while there is a query — a panel of results that Escape closes.
  final bool clearOnEscape;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  /// Whether the field can be used.
  final bool enabled;

  /// Merged over the theme's text field decoration.
  final FinesseDecoration? decoration;

  /// The constraints of the field, in place of the theme's text field
  /// height: a search box set into a denser surface.
  final BoxConstraints? constraints;

  /// The padding inside the field, in place of the theme's.
  final EdgeInsetsGeometry? padding;

  /// The tap-region group of the field: a tap in another region of the
  /// same group — a panel of suggestions under the field — is not a tap
  /// outside it, and so does not take the focus away.
  final Object? groupId;

  /// What assistive technology calls the field. Defaults to the localized
  /// "Search".
  final String? semanticLabel;

  /// Whether the platform has a Command key, which is then the modifier of
  /// the search shortcut; elsewhere it is Control.
  static bool get _apple => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => true,
    _ => false,
  };

  /// The conventional search shortcut as a key cap reads it: `⌘K` on an
  /// Apple platform, `Ctrl K` elsewhere. Show it in a `Kbd` as [trailing].
  static String get shortcutLabel => _apple ? '⌘K' : 'Ctrl K';

  /// Whether [event] is the conventional search shortcut: K with Command
  /// alone on an Apple platform, with Control alone elsewhere.
  ///
  /// One modifier per platform, and no other with it, because the other
  /// chords are taken: Ctrl+K deletes to the end of the line in every
  /// macOS text field, and AltGr — which types a character on many
  /// layouts — reports itself as Control and Alt together on Windows.
  ///
  /// The field does not listen for it; the app decides where the shortcut
  /// applies. A `HardwareKeyboard` handler hears a key wherever the focus
  /// is, a dialog included, so check that the field is what the user is
  /// looking at before moving the focus to it:
  ///
  /// ```dart
  /// bool onKey(KeyEvent event) {
  ///   if (!SearchField.isSearchShortcut(event)) return false;
  ///   if (!(ModalRoute.of(context)?.isCurrent ?? true)) return false;
  ///   searchFocusNode.requestFocus();
  ///   return true;
  /// }
  /// ```
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

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  /// The focus as the Cancel button follows it.
  final _focused = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = TextEditingController(text: widget.initialValue ?? '');
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
      _onFocusChanged();
    }
    if (widget.controller != null && _ownController != null) {
      _ownController!.dispose();
      _ownController = null;
    } else if (widget.controller == null && oldWidget.controller != null) {
      // Keep what was typed when the caller stops controlling the text.
      _ownController = TextEditingController.fromValue(
        oldWidget.controller!.value,
      );
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
    _ownFocusNode?.dispose();
    _ownController?.dispose();
    _focused.dispose();
    super.dispose();
  }

  void _onFocusChanged() => _focused.value = _focusNode.hasFocus;

  /// Empties the field and says so. The focus stays where it is.
  void _clear() {
    if (_controller.text.isEmpty) return;
    _controller.clear();
    widget.onChanged?.call('');
    widget.onCleared?.call();
  }

  void _cancel() {
    _clear();
    _focusNode.unfocus();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = FinesseLocalizations.of(context);
    final colors = theme.colorScheme;
    // A glyph a little larger than the text beside it, as the designs set
    // an icon in a line of text.
    final iconSize = (theme.textFieldTheme.style?.fontSize ?? 14) + 2;

    final leading =
        widget.leading ??
        SizedBox.square(
          dimension: iconSize,
          child: widget.loading
              ? Spinner(size: iconSize, color: colors.mutedForeground)
              : PhosphorIcon(
                  PhosphorIconsRegular.magnifyingGlass,
                  size: iconSize,
                  color: colors.mutedForeground,
                ),
        );

    final Widget field = Semantics(
      label: widget.semanticLabel ?? l.search.placeholder,
      // Directly around the field: a focused text field swallows Escape,
      // so nothing further out would hear it. With nothing to clear the
      // key goes on to whatever encloses the search.
      child: DismissShortcut(
        isActive: () =>
            widget.clearOnEscape &&
            widget.enabled &&
            _controller.text.isNotEmpty,
        onDismiss: _clear,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          decoration: widget.decoration,
          constraints: widget.constraints,
          padding: widget.padding,
          groupId: widget.groupId,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          // A tap on a field that has the focus already is one too.
          onTapAlwaysCalled: widget.onTap != null,
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          autocorrect: false,
          clearable: widget.clearable,
          onCleared: widget.onCleared,
          placeholder: DefaultTextStyle.merge(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: widget.placeholder ?? Text(l.search.placeholder),
          ),
          leading: leading,
          trailing: widget.trailing,
        ),
      ),
    );

    if (!widget.showCancel) return field;

    final gap = theme.textFieldTheme.gap ?? 8;
    return Row(
      children: [
        Expanded(child: field),
        ValueListenableBuilder(
          valueListenable: _focused,
          builder: (context, focused, child) => SpringBuilder(
            value: focused && widget.enabled ? 1 : 0,
            spring: Motion.of(context).smooth,
            builder: (context, t, child) => _SlideIn(factor: t, child: child!),
            child: child,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: gap),
            child: Button.link(
              onPressed: _cancel,
              style: const ButtonTheme(padding: EdgeInsets.zero),
              child: Text(l.search.cancel),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows [factor] of its child's width, from the start, fading it in: the
/// Cancel button arriving beside the field.
///
/// The same widgets at every factor, so the button keeps its state through
/// the whole transition; fully in, each of them is a no-op.
class _SlideIn extends StatelessWidget {
  const _SlideIn({required this.factor, required this.child});

  final double factor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = factor.clamp(0.0, 1.0);
    return ExcludeFocus(
      excluding: t == 0,
      child: IgnorePointer(
        ignoring: t < 1,
        child: ClipRect(
          clipBehavior: t < 1 ? Clip.hardEdge : Clip.none,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: t,
            child: Opacity(
              opacity: ((t - .15) / .85).clamp(0.0, 1.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
