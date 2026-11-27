import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Collects the messages announced to assistive technology from now until
/// the end of the test, with their assertiveness (0 polite, 1 assertive).
List<({String message, int assertiveness})> captureAnnouncements(
  WidgetTester tester,
) {
  final announcements = <({String message, int assertiveness})>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (message) async {
      final map = (message as Map<Object?, Object?>?) ?? const {};
      if (map['type'] != 'announce') return;
      final data = map['data']! as Map<Object?, Object?>;
      announcements.add((
        message: data['message']! as String,
        assertiveness: (data['assertiveness'] as int?) ?? 0,
      ));
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger
        .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
  );
  return announcements;
}
