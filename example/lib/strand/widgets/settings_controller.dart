import 'package:example/strand/data.dart';
import 'package:example/strand/data/profile_data.dart';
import 'package:flutter/foundation.dart';

/// The pages of the Settings screen.
enum SettingsSection {
  account('Account'),
  privacy('Privacy'),
  notifications('Notifications'),
  appearance('Appearance');

  const SettingsSection(this.label);

  final String label;
}

/// Who can see the profile.
enum ProfileVisibility {
  public('Public', 'Anyone on or off Strand'),
  members('Strand members', 'Only people who are signed in'),
  connections('Connections', 'Only people you are connected to');

  const ProfileVisibility(this.label, this.detail);

  final String label;
  final String detail;
}

/// Who may start a conversation.
enum MessagePolicy {
  anyone('Anyone on Strand'),
  secondDegree('Connections and their connections'),
  connections('Connections only');

  const MessagePolicy(this.label);

  final String label;
}

/// How often the summary email is sent.
enum DigestFrequency {
  daily('Every morning'),
  weekly('Once a week, on Monday'),
  never('Never');

  const DigestFrequency(this.label);

  final String label;
}

/// When videos in the feed start by themselves.
enum Autoplay {
  always('Always'),
  wifi('On Wi-Fi only'),
  never('Never');

  const Autoplay(this.label);

  final String label;
}

/// A kind of activity the user can be told about, on two channels.
enum NotificationTopic {
  reactions('Reactions and comments', 'On your posts and articles'),
  mentions('Mentions', 'When someone tags you'),
  invitations('Invitations', 'Requests to connect and to join groups'),
  jobs('Job matches', 'New roles that fit your profile'),
  messages('Messages', 'New conversations and replies'),
  events('Events', 'Reminders for events you are going to');

  const NotificationTopic(this.label, this.detail);

  final String label;
  final String detail;
}

/// What the Settings screen has been set to since the app started.
///
/// Light or dark and the text size are not here: those two are real, and
/// live in the app's own state (`themeModeProvider`, `themeConfigProvider`).
/// Everything else is a mock preference, kept for the session so the page
/// reads the same when it is opened again. Nothing is persisted.
class SettingsController extends ChangeNotifier {
  SettingsSection section = SettingsSection.account;

  // Account.
  String name = People.me.name;
  String headline = ProfileData.currentRole;
  String email = 'noor@noorhaddad.design';
  String language = ProfileData.language;
  bool twoStep = true;

  // Privacy.
  ProfileVisibility visibility = ProfileVisibility.public;
  MessagePolicy messages = MessagePolicy.secondDegree;
  bool showOnline = true;
  bool readReceipts = true;
  bool shareProfileViews = false;
  bool openToRecruitersOnly = true;

  // Notifications.
  final push = <NotificationTopic>{
    NotificationTopic.reactions,
    NotificationTopic.mentions,
    NotificationTopic.invitations,
    NotificationTopic.messages,
    NotificationTopic.events,
  };
  final emailed = <NotificationTopic>{
    NotificationTopic.invitations,
    NotificationTopic.jobs,
  };
  DigestFrequency digest = DigestFrequency.weekly;

  /// The least a role has to match the profile, from .5 to 1, before a job
  /// notification is sent.
  double jobMatch = .8;
  bool pauseAll = false;

  // Appearance.
  bool reduceMotion = false;
  bool compactFeed = false;
  Autoplay autoplay = Autoplay.wifi;

  /// The languages the profile can be shown in.
  static const languages = [
    'English',
    'Dansk',
    'Svenska',
    'Norsk bokmål',
    'Deutsch',
    'Français',
  ];

  /// Applies [change] to the fields above and notifies listeners.
  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  void toggle(Set<NotificationTopic> channel, NotificationTopic topic) {
    if (!channel.remove(topic)) channel.add(topic);
    notifyListeners();
  }
}
