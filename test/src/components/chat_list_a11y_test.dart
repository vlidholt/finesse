import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A [ChatList] for assistive technology: a message that arrives at the end
/// is announced in the words the app gives, a message on its way out can
/// be neither focused nor read, and the built-in labels are localised.
void main() {
  /// Starts recording announcements, for the rest of the test.
  List<String> recordAnnouncements(WidgetTester tester) {
    final announcements = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (
        message,
      ) async {
        final data = (message as Map<dynamic, dynamic>)['data'];
        if (message['type'] == 'announce' && data is Map) {
          announcements.add(data['message'] as String);
        }
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

  Widget list(ValueNotifier<List<String>> messages) => Align(
    alignment: Alignment.topLeft,
    child: SizedBox(
      width: 320,
      height: 400,
      child: ValueListenableBuilder(
        valueListenable: messages,
        builder: (context, messages, _) => ChatList<String>(
          messages: messages,
          idOf: (message) => message,
          announcementOf: (message) =>
              message.startsWith('me:') ? null : 'Omar: $message',
          itemBuilder: (context, item) => Focus(child: Text(item.message)),
        ),
      ),
    ),
  );

  testWidgets('a message that arrives at the end is announced', (
    tester,
  ) async {
    final announcements = recordAnnouncements(tester);
    final messages = ValueNotifier(['hi', 'me: hello']);
    addTearDown(messages.dispose);
    await pumpUna(tester, list(messages));
    // The conversation as it was is not news.
    expect(announcements, isEmpty);

    messages.value = [...messages.value, 'see you at six'];
    await settle(tester);
    expect(announcements, ['Omar: see you at six']);

    // One the app does not word is not announced, and neither is history
    // added at the start.
    messages.value = ['older', ...messages.value, 'me: ok'];
    await settle(tester);
    expect(announcements, ['Omar: see you at six']);
  });

  testWidgets('a message on its way out takes no focus and is not read', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final messages = ValueNotifier(['hi', 'bye']);
    addTearDown(messages.dispose);
    await pumpUna(tester, list(messages));
    messages.value = ['hi'];
    await tester.pump();
    // Mid-exit: still built, gone for the keyboard and assistive
    // technology.
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('bye', skipOffstage: false), findsOneWidget);
    expect(
      Focus.of(tester.element(find.text('bye', skipOffstage: false)))
          .canRequestFocus,
      isFalse,
    );
    expect(find.semantics.byLabel('bye'), findsNothing);
    expect(find.semantics.byLabel('hi'), findsOne);
    await settle(tester);
    handle.dispose();
  });

  testWidgets('the typing indicator is named in the app language', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, const Center(child: TypingIndicator()));
    expect(find.semantics.byLabel('Typing'), findsOne);
    handle.dispose();
  });
}
