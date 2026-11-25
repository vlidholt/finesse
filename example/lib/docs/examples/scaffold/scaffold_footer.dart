import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A composer in the `footer`. Focus the field: the stand-in keyboard comes
/// up, the page ends where it begins, and the footer rides above it. The
/// bottom bar stays where it is and is covered.
class ScaffoldFooterExample extends StatefulWidget {
  const ScaffoldFooterExample({super.key});

  @override
  State<ScaffoldFooterExample> createState() => _ScaffoldFooterExampleState();
}

class _ScaffoldFooterExampleState extends State<ScaffoldFooterExample> {
  final _focus = FocusNode();
  final _draft = TextEditingController();
  final _messages = ['Are we still on for Thursday?', 'Yes — 10 at the studio'];

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    _draft.dispose();
    super.dispose();
  }

  void _send() {
    if (_draft.text.trim().isEmpty) return;
    setState(() => _messages.add(_draft.text.trim()));
    _draft.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      // On a real phone the platform reports the keyboard; here a stand-in
      // is raised while the field has the focus.
      keyboardHeight: _focus.hasFocus ? 180 : 0,
      child: Scaffold(
        appBar: const AppBar(title: Text('Mei Tanaka')),
        bottomNavigationBar: BottomNavigationBar(
          selectedIndex: 1,
          onDestinationSelected: (_) {},
          destinations: const [
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
              selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.user),
              label: 'Profile',
            ),
          ],
        ),
        // Above the bottom bar, and above the keyboard when it is up.
        footer: Padding(
          padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
          child: Glass(
            level: GlassLevel.strong,
            borderRadius: theme.radii.full,
            shadows: theme.style.floatingShadow,
            padding: EdgeInsetsDirectional.only(
              start: theme.layoutTheme.gap(GapSize.md),
              end: theme.layoutTheme.gap(GapSize.xs),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _draft,
                    focusNode: _focus,
                    placeholder: const Text('Write a message…'),
                    decoration: FinesseDecoration.none,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: const PhosphorIcon(PhosphorIconsRegular.paperPlaneTilt),
                  semanticLabel: 'Send',
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
        // The list's padding already includes the footer and the bar: its
        // last message stops above them, and scrolls under them.
        body: Builder(
          builder: (context) => GestureDetector(
            onTap: _focus.unfocus,
            child: ListView(
              padding:
                  MediaQuery.paddingOf(context) +
                  EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
              children: [
                for (final (index, message) in _messages.indexed)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: theme.layoutTheme.gap(GapSize.sm),
                    ),
                    child: ChatBubble(
                      direction: index.isOdd
                          ? ChatBubbleDirection.outgoing
                          : ChatBubbleDirection.incoming,
                      child: Text(message),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
