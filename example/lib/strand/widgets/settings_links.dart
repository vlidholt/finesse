import 'package:example/strand/navigation.dart';
import 'package:example/strand/screens/settings_screen.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:flutter/widgets.dart';

/// Opens the Settings page over whatever Strand is showing, on [section]
/// if one is given and otherwise where it was left.
void openSettings(BuildContext context, [SettingsSection? section]) {
  if (section != null) {
    final settings = context.strand.settings;
    settings.update(() => settings.section = section);
  }
  context.pushFullScreen<void>((context) => const SettingsScreen());
}
