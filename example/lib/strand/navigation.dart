import 'package:disco/disco.dart';
import 'package:example/common/app_state.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

/// The places the Strand shell can show.
///
/// Home, Jobs, Messages and Profile are the four designed screens. Network
/// and Notifications exist in the navigation but have no design, so they
/// show a placeholder.
enum StrandDestination { home, network, jobs, messages, notifications, profile }

/// The destination the Strand shell is showing.
///
/// Provided above the whole app, so a screen — or a full-screen route a
/// screen pushed — navigates by writing to it:
///
/// ```dart
/// strandDestinationProvider.of(context).value = StrandDestination.jobs;
/// // or, shorter:
/// context.goTo(StrandDestination.jobs);
/// ```
final strandDestinationProvider = Provider(
  (_) => Signal(StrandDestination.home),
);

/// Navigation shortcuts for the Strand screens.
extension StrandNavigation on BuildContext {
  /// Switches the Strand shell to [destination].
  void goTo(StrandDestination destination) =>
      strandDestinationProvider.of(this).value = destination;

  /// Leaves Strand for the component-library browser.
  void openComponentLibrary() =>
      appSectionProvider.of(this).value = AppSection.components;

  /// Shows or hides the theme editor panel docked beside the app.
  void toggleThemeEditor() =>
      themeEditorOpenProvider.of(this).updateValue((open) => !open);
}

/// Routes for the Strand screens.
extension StrandRoutes on BuildContext {
  /// Pushes a page that takes the whole Strand viewport, covering the
  /// shell's app bar and bottom navigation — a conversation on a phone, a
  /// search page. See the note on full-screen routes in `strand_shell.dart`.
  ///
  /// The page should be a `Scaffold` with its own `AppBar`; it pops itself
  /// with `Navigator.of(context).pop()`.
  Future<T?> pushFullScreen<T>(WidgetBuilder builder) =>
      Navigator.of(this).push<T>(FinessePageRoute<T>(builder: builder));
}
