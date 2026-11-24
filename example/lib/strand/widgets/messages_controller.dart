import 'package:example/strand/data/messages_data.dart';
import 'package:flutter/widgets.dart';

/// The state of the Messages screen: which conversation is open, the list's
/// filter and search, and what the user has sent or read since the app
/// started.
///
/// It is a plain listenable rather than widget state because a phone shows
/// the conversation in a pushed route, outside the screen's subtree, and
/// both have to see the same messages.
class MessagesController extends ChangeNotifier {
  MessagesController({
    this.conversations = MessagesData.conversations,
    String? selectedId,
  }) : _selectedId = selectedId ?? conversations.first.id {
    search.addListener(notifyListeners);
  }

  /// Every conversation, in list order.
  final List<Conversation> conversations;

  /// What is typed in the list's search field.
  ///
  /// Kept here, not in the field, because the list is rebuilt in a different
  /// place when the window crosses a breakpoint: the text has to survive
  /// that, or the list would stay filtered by a search nobody can see.
  final search = TextEditingController();

  String _selectedId;
  MessageFilter _filter = MessageFilter.focused;
  bool _detailsVisible = true;
  final _sent = <String, List<String>>{};
  final _read = <String>{};
  final _muted = <String>{};

  /// The conversation the desktop panes show.
  Conversation get selected => byId(_selectedId);

  Conversation byId(String id) =>
      conversations.firstWhere((conversation) => conversation.id == id);

  MessageFilter get filter => _filter;

  set filter(MessageFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  /// Whether the details pane is shown when there is room for it.
  bool get detailsVisible => _detailsVisible;

  void toggleDetails() {
    _detailsVisible = !_detailsVisible;
    notifyListeners();
  }

  /// How many message requests are waiting: the number on the chip.
  int get requestCount =>
      conversations.where((conversation) => conversation.request).length;

  /// The conversations the list shows for the current filter and search.
  List<Conversation> get visible {
    final needle = search.text.trim().toLowerCase();
    return [
      for (final conversation in conversations)
        if (_matchesFilter(conversation) &&
            (needle.isEmpty ||
                conversation.name.toLowerCase().contains(needle) ||
                previewOf(conversation).toLowerCase().contains(needle)))
          conversation,
    ];
  }

  bool _matchesFilter(Conversation conversation) => switch (_filter) {
    MessageFilter.focused => !conversation.request,
    // The open conversation stays put: it was unread until it was opened,
    // and a row that vanishes under the pointer is disorienting.
    MessageFilter.unread =>
      !conversation.request &&
          (unreadOf(conversation) > 0 || conversation.id == _selectedId),
    MessageFilter.requests => conversation.request,
    MessageFilter.groups => conversation.isGroup && !conversation.request,
  };

  /// Opens [conversation] and marks it read.
  void select(Conversation conversation) {
    final changed = _selectedId != conversation.id;
    final wasUnread = _read.add(conversation.id) && conversation.unread > 0;
    _selectedId = conversation.id;
    if (changed || wasUnread) notifyListeners();
  }

  /// Appends [text] to [conversation] as a message from the user.
  ///
  /// Returns whether anything was sent; blank text is not.
  bool send(Conversation conversation, String text) {
    final message = text.trim();
    if (message.isEmpty) return false;
    _sent.putIfAbsent(conversation.id, () => []).add(message);
    notifyListeners();
    return true;
  }

  /// The thread of [conversation]: the designed messages, then whatever the
  /// user has sent. Only the newest sent message carries a receipt.
  List<ChatMessage> messagesOf(Conversation conversation) {
    final sent = _sent[conversation.id] ?? const <String>[];
    return [
      ...conversation.messages,
      for (final (index, text) in sent.indexed)
        ChatMessage(
          text,
          outgoing: true,
          receipt: index == sent.length - 1 ? 'Delivered' : null,
        ),
    ];
  }

  int unreadOf(Conversation conversation) =>
      _read.contains(conversation.id) ? 0 : conversation.unread;

  /// The last message, as the list shows it.
  String previewOf(Conversation conversation) {
    final sent = _sent[conversation.id];
    return sent == null ? conversation.preview : 'You: ${sent.last}';
  }

  /// When the last message was sent, as the list shows it.
  String timeOf(Conversation conversation) =>
      _sent.containsKey(conversation.id) ? 'now' : conversation.time;

  bool isMuted(Conversation conversation) => _muted.contains(conversation.id);

  void toggleMuted(Conversation conversation) {
    if (!_muted.remove(conversation.id)) _muted.add(conversation.id);
    notifyListeners();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }
}
