import 'package:disco/disco.dart';
import 'package:example/common/app_state.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

/// The places the Strand shell can show.
///
/// Home, Jobs, Messages and Profile are the four designed screens. Network
/// and Notifications are in the designs' navigation but were never drawn;
/// they are built in the same style, from the same pieces.
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

  /// Switches the Strand shell to [destination] from anywhere, closing
  /// whatever full-screen routes are open over it — a search page, a
  /// settings page — on the way.
  ///
  /// Call it with the context of a screen or of a pushed page, not with a
  /// dialog's own: a dialog lives in another navigator, and closes itself.
  void leaveTo(StrandDestination destination) {
    Navigator.of(this).popUntil((route) => route.isFirst);
    goTo(destination);
  }

  /// Leaves Strand for the component-library browser.
  void openComponentLibrary() =>
      appSectionProvider.of(this).value = AppSection.components;

  /// Shows or hides the theme editor panel docked beside the app.
  void toggleThemeEditor() =>
      themeEditorOpenProvider.of(this).updateValue((open) => !open);
}

/// Routes for the Strand screens.
extension StrandRoutes on BuildContext {
  /// Whether the page this context is on is what the user is looking at:
  /// its route is the top one of its navigator, and the same holds for the
  /// route that navigator is in, all the way out.
  ///
  /// Strand's pages live in the navigator `AppShell` hosts in its page
  /// area, but a dialog or a sheet is pushed on the *root* navigator, so a
  /// page's own route stays "current" under every dialog. Asking only
  /// `ModalRoute.of(context).isCurrent` therefore says yes behind a modal
  /// barrier. Anything that acts from outside the focus tree — a global
  /// keyboard shortcut — has to ask this instead, or it reaches through
  /// the barrier.
  bool get isOnTopRoute {
    BuildContext? at = this;
    while (at != null && at.mounted) {
      final route = ModalRoute.of(at);
      if (route == null) return true;
      if (!route.isCurrent) return false;
      // The navigator's own context is inside the route that hosts it.
      at = route.navigator?.context;
    }
    return true;
  }

  /// Pushes a page that takes the whole Strand viewport, covering the
  /// shell's app bar and bottom navigation — a conversation on a phone, a
  /// search page. See the note on full-screen routes in `strand_shell.dart`.
  ///
  /// The page should be a `Scaffold` with its own `AppBar`; it pops itself
  /// with `Navigator.of(context).pop()`.
  Future<T?> pushFullScreen<T>(WidgetBuilder builder) =>
      Navigator.of(this).push<T>(FinessePageRoute<T>(builder: builder));
}
