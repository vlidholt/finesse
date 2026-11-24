import 'package:disco/disco.dart';
import 'package:example/strand/widgets/network_controller.dart';
import 'package:example/strand/widgets/notifications_controller.dart';
import 'package:example/strand/widgets/search_history.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:flutter/widgets.dart';

/// The state Strand's screens share for as long as the app runs: what has
/// been read, answered, requested, searched for and switched on.
///
/// A screen's own state stays in the screen (`JobsState`,
/// `MessagesController`, `HomeFeedModel`). These four are here instead
/// because more than one place shows them:
///
/// * [notifications] — the shell's bell counts the unread ones.
/// * [network] — an invitation can be accepted from a notification, and a
///   request to connect sent from a search result or a profile preview.
/// * [search] — the app-bar field and the search page list the same recent
///   searches.
/// * [settings] — the page is a pushed route, and has to read the same when
///   it is opened again.
///
/// Nothing is persisted.
class StrandSession {
  final notifications = NotificationsController();
  final network = NetworkController();
  final search = SearchHistory();
  final settings = SettingsController();

  void dispose() {
    notifications.dispose();
    network.dispose();
    search.dispose();
    settings.dispose();
  }
}

/// The [StrandSession], provided above the whole app beside
/// `strandDestinationProvider` so that full-screen routes reach it too.
///
/// ```dart
/// final network = context.strand.network;
/// ```
final strandSessionProvider = Provider<StrandSession>(
  (_) => StrandSession(),
  dispose: (session) => session.dispose(),
);

/// Shorthand for the session.
extension StrandSessionContext on BuildContext {
  /// The [StrandSession] above this context.
  StrandSession get strand => strandSessionProvider.of(this);
}
