import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// Centres page content, caps its width and gives it the theme's page
/// margins.
///
/// ```dart
/// Scaffold(
///   appBar: const AppBar(title: Text('Jobs')),
///   body: PageContainer(
///     scrollable: true,
///     child: FinesseColumn(gap: GapSize.lg, children: sections),
///   ),
/// )
/// ```
///
/// The content is as wide as the window allows, up to the maximum width.
/// The margins and the maximum width come from the theme's `LayoutTheme`, so
/// they tighten on a phone and every screen built on a `PageContainer` lines
/// up with the app bar. The safe area — which inside a `Scaffold` includes
/// the app and navigation bars — is added to the padding, so content starts
/// below the bar and can still scroll beneath it when [scrollable].
class PageContainer extends StatelessWidget {
  /// Creates a page container.
  const PageContainer({
    required this.child,
    this.scrollable = false,
    this.maxWidth,
    this.padding,
    this.controller,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  /// The page content.
  final Widget child;

  /// Whether the content scrolls vertically.
  final bool scrollable;

  /// The widest the content grows. Defaults to the theme's page width.
  final double? maxWidth;

  /// The padding around the content, in place of the theme's page margins.
  /// The safe area is added to it.
  final EdgeInsetsGeometry? padding;

  /// The scroll controller, when [scrollable].
  final ScrollController? controller;

  /// Where the content sits when it is narrower than the window.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final layout = Theme.of(context).layoutTheme;
    final safeArea = MediaQuery.paddingOf(context);
    final effectivePadding =
        (padding ?? layout.pagePadding ?? const EdgeInsets.all(24)).add(
          safeArea,
        );
    final content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? layout.pageMaxWidth ?? double.infinity,
        ),
        // Fill the page width (up to the maximum) rather than hugging the
        // content, so a column of cards does not need to ask for it.
        child: Container(
          width: double.infinity,
          padding: effectivePadding,
          // The safe area has been spent; descendants must not add it again.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            removeLeft: true,
            removeRight: true,
            child: child,
          ),
        ),
      ),
    );
    if (!scrollable) return content;
    return SingleChildScrollView(controller: controller, child: content);
  }
}

/// Builds one of two layouts from the theme's form factor.
///
/// ```dart
/// FormFactorBuilder(
///   mobile: (context) => const ConversationList(),
///   desktop: (context) => const Row(
///     children: [ConversationList(), Expanded(child: Conversation())],
///   ),
/// )
/// ```
///
/// Use it where a screen is arranged differently on a phone, not merely
/// sized differently: sizes already follow the form factor through the
/// theme. Read `Theme.of(context).formFactor` for a one-off branch.
class FormFactorBuilder extends StatelessWidget {
  /// Creates a form-factor switch.
  const FormFactorBuilder({
    required this.mobile,
    required this.desktop,
    super.key,
  });

  /// Builds the layout for a phone-sized screen.
  final WidgetBuilder mobile;

  /// Builds the layout for a desktop-sized screen.
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) => switch (Theme.of(context).formFactor) {
    FormFactor.mobile => mobile(context),
    FormFactor.desktop => desktop(context),
  };
}
