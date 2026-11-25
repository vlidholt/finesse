# Scaffold

The frame of a screen. `Scaffold` lays an app bar, a banner, a bottom bar, a footer and a persistent sheet over the page and tells the page how far to inset itself; floats an action button over its corner; slides drawers in from its edges; keeps everything clear of the keyboard; and styles the status bar. `NavigationScaffold` builds the navigation from one list of destinations and moves it with the form factor; `DestinationStack` keeps each destination's page alive.

## Scaffold

The bars sit over `body`, not above and below it, so a translucent bar shows the page scrolling beneath. The `MediaQuery` padding of the body includes their heights: a `ListView`, a `SafeArea` or a `PageContainer` clears them without being told. Every slot is measured in the frame it is laid out in, so a bar of any height works and nothing jumps on the first frame.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A phone-sized screen. Both bars are laid *over* the list, which insets
/// itself by their heights and scrolls beneath them.
class ScaffoldBasicExample extends StatefulWidget {
  const ScaffoldBasicExample({super.key});

  @override
  State<ScaffoldBasicExample> createState() => _ScaffoldBasicExampleState();
}

class _ScaffoldBasicExampleState extends State<ScaffoldBasicExample> {
  static const _people = [
    ('Omar Rahimi', 'Sent you the workshop notes'),
    ('Mei Tanaka', 'Are we still on for Thursday?'),
    ('Claire Dubois', 'Loved the talk!'),
    ('Julian Reyes', 'Here is the recording'),
    ('Freya Holm', 'Thanks for the intro'),
    ('Rafael Cruz', 'Shared a file with you'),
    ('Elena Petrova', 'Can you review my portfolio?'),
    ('Sara Lindqvist', 'See you at the meetup'),
  ];

  int index = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The frame stands in for a phone: the theme is laid out for one, and the
    // real window's safe area is kept out of it.
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: 340,
        height: 520,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: theme.radii.xl2,
        ),
        // Painted over the content, so nothing covers the frame's corners.
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl2,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Messages'),
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.notePencil),
                  semanticLabel: 'New message',
                  onPressed: () {},
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: const [
                NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsRegular.house),
                  selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
                  selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
                  label: 'Messages',
                ),
                NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsRegular.user),
                  selectedIcon: PhosphorIcon(PhosphorIconsFill.user),
                  label: 'Profile',
                ),
              ],
            ),
            // A ListView pads itself with the MediaQuery padding, which the
            // scaffold has grown by the height of each bar.
            body: ListView(
              children: [
                for (final (name, message) in _people)
                  ListTile(
                    leading: Avatar('', fallback: Text(name[0])),
                    title: Text(name),
                    subtitle: Text(message),
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Footer and keyboard

`footer` rides above the bottom bar and above the software keyboard; `bottomNavigationBar` stays put and is covered. The body ends where the keyboard begins, so a focused field is scrolled into view, and it sees no `viewInsets` of its own. A footer on the bottom edge is told about the safe area and should extend under it, as a bar does: wrap one that is not a bar in a `SafeArea`. `resizeToAvoidBottomInset: false` leaves the page as it is under the keyboard.

```dart
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
```

## Drawer

`drawer` and `endDrawer` take any widget and open as modal panels from the start and end edges, at most 360 wide. An `AppBar` in the scaffold shows the menu button by itself; `Scaffold.of(context).openDrawer()` or a `GlobalKey<ScaffoldState>` opens one from anywhere else. On a touch screen a drag from the edge pulls the drawer out under the finger — only while the page cannot be popped, since that edge is otherwise the way back. The scrim, Escape, the system back gesture and a drag on the panel close it. `onDrawerChanged` reports each change.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A drawer. The app bar shows the menu button by itself; on a touch
/// screen the drawer can also be dragged in from the start edge, and it
/// closes on the scrim, with Escape, with the system back gesture or by
/// dragging it away.
class ScaffoldDrawerExample extends StatefulWidget {
  const ScaffoldDrawerExample({super.key});

  @override
  State<ScaffoldDrawerExample> createState() => _ScaffoldDrawerExampleState();
}

class _ScaffoldDrawerExampleState extends State<ScaffoldDrawerExample> {
  static const _folders = [
    (PhosphorIconsRegular.tray, 'Inbox'),
    (PhosphorIconsRegular.star, 'Starred'),
    (PhosphorIconsRegular.paperPlaneTilt, 'Sent'),
    (PhosphorIconsRegular.archive, 'Archive'),
  ];

  final _scaffold = GlobalKey<ScaffoldState>();
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(title: Text(_folders[_selected].$2)),
        drawer: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
            children: [
              Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
                child: Text('Mail', style: theme.textTheme.h4),
              ),
              for (final (index, (icon, label)) in _folders.indexed)
                ListTile(
                  leading: PhosphorIcon(icon),
                  title: Text(label),
                  selected: index == _selected,
                  onTap: () {
                    setState(() => _selected = index);
                    _scaffold.currentState?.closeDrawer();
                  },
                ),
            ],
          ),
        ),
        body: Center(
          child: Text(
            'Nothing in ${_folders[_selected].$2.toLowerCase()}',
            style: theme.textTheme.muted,
          ),
        ),
      ),
    );
  }
}
```

## Floating action button

`floatingActionButton` floats one page margin from the corner and from whatever is at the bottom: the bottom bar, the footer, the sheet, the keyboard, the safe area. When those change it travels on the surface spring; when it appears, goes or is replaced by a button with another key it pops in and out. `floatingActionButtonLocation` picks `start`, `center` or `end`.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A floating action button. It keeps a page margin from the corner and
/// from whatever is at the bottom: add the footer and it travels up; move
/// it and it travels across; remove it and it pops out.
class ScaffoldFloatingActionButtonExample extends StatefulWidget {
  const ScaffoldFloatingActionButtonExample({super.key});

  @override
  State<ScaffoldFloatingActionButtonExample> createState() =>
      _ScaffoldFloatingActionButtonExampleState();
}

class _ScaffoldFloatingActionButtonExampleState
    extends State<ScaffoldFloatingActionButtonExample> {
  var _location = FloatingActionButtonLocation.end;
  bool _footer = false;
  bool _button = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Notes')),
        floatingActionButtonLocation: _location,
        floatingActionButton: _button
            ? FloatingActionButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.plus),
                label: const Text('New note'),
                onPressed: () {},
              )
            : null,
        footer: _footer
            ? Glass(
                frosted: false,
                borderRadius: BorderRadius.zero,
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
                child: Text('3 notes selected', style: theme.textTheme.small),
              )
            : null,
        body: PageContainer(
          scrollable: true,
          child: FinesseColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            gap: GapSize.md,
            children: [
              Text('Location', style: theme.textTheme.small),
              Wrap(
                spacing: theme.layoutTheme.gap(GapSize.sm),
                runSpacing: theme.layoutTheme.gap(GapSize.sm),
                children: [
                  for (final location in FloatingActionButtonLocation.values)
                    Chip(
                      label: Text(location.name),
                      selected: location == _location,
                      onSelected: (_) => setState(() => _location = location),
                    ),
                ],
              ),
              Switch(
                value: _footer,
                onChanged: (value) => setState(() => _footer = value),
                label: const Text('Footer'),
              ),
              Switch(
                value: _button,
                onChanged: (value) => setState(() => _button = value),
                label: const Text('Button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Persistent sheet

`bottomSheet` stays over the end of the page without blocking it, above the footer: a mini player, a summary. The page is inset for it and scrolls beneath.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A persistent sheet: a mini player that stays over the end of the page
/// without blocking it. The list is inset for it and scrolls beneath.
class ScaffoldBottomSheetExample extends StatefulWidget {
  const ScaffoldBottomSheetExample({super.key});

  @override
  State<ScaffoldBottomSheetExample> createState() =>
      _ScaffoldBottomSheetExampleState();
}

class _ScaffoldBottomSheetExampleState
    extends State<ScaffoldBottomSheetExample> {
  static const _tracks = [
    'Slow Tide',
    'Paper Lanterns',
    'Northbound',
    'Glass Hours',
    'Low Sun',
    'Harbour Lights',
    'Second Wind',
    'Afterglow',
  ];

  int _playing = 0;
  bool _paused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Evening')),
        bottomSheet: Padding(
          padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
          child: Glass(
            level: GlassLevel.strong,
            borderRadius: theme.radii.xl,
            shadows: theme.style.floatingShadow,
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
            child: Row(
              spacing: theme.layoutTheme.gap(GapSize.md),
              children: [
                const IconTile(
                  icon: PhosphorIcon(PhosphorIconsRegular.musicNotes),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_tracks[_playing], style: theme.textTheme.small),
                      Text('Nora Vale', style: theme.textTheme.caption),
                    ],
                  ),
                ),
                IconButton.ghost(
                  icon: PhosphorIcon(
                    _paused ? PhosphorIconsFill.play : PhosphorIconsFill.pause,
                  ),
                  semanticLabel: _paused ? 'Play' : 'Pause',
                  onPressed: () => setState(() => _paused = !_paused),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          children: [
            for (final (index, track) in _tracks.indexed)
              ListTile(
                title: Text(track),
                subtitle: const Text('Nora Vale'),
                selected: index == _playing,
                onTap: () => setState(() => _playing = index),
              ),
          ],
        ),
      ),
    );
  }
}
```

## An inline sheet

A `Sheet` in `bottomSheet` is an inline sheet: it rests at its smallest detent and is pulled up to the next, with no route and no barrier, so the page behind it stays in use.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An inline `Sheet` as the scaffold's `bottomSheet`: a summary resting at
/// the foot of the page that pulls up into the whole order. It has no route
/// and no barrier, so the list behind it stays in use.
class ScaffoldSheetExample extends StatefulWidget {
  const ScaffoldSheetExample({super.key});

  @override
  State<ScaffoldSheetExample> createState() => _ScaffoldSheetExampleState();
}

class _ScaffoldSheetExampleState extends State<ScaffoldSheetExample> {
  static const _menu = {
    'Flat white': 3.6,
    'Cardamom bun': 4.2,
    'Sourdough toast': 5.5,
    'Oat porridge': 6.8,
    'Iced tea': 3.2,
    'Pastel de nata': 2.4,
    'Granola bowl': 7.1,
  };

  final _order = <String, int>{'Flat white': 1, 'Cardamom bun': 2};

  double get _total => _order.entries.fold(
    0,
    (sum, entry) => sum + _menu[entry.key]! * entry.value,
  );

  int get _count => _order.values.fold(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Order')),
        bottomSheet: Sheet(
          detents: const [SheetDetent.height(112), SheetDetent.fraction(.6)],
          draggable: true,
          showDragHandle: true,
          title: Text('$_count items · €${_total.toStringAsFixed(2)}'),
          description: const Text('Pull up to review the order'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final MapEntry(key: item, value: count) in _order.entries)
                ListTile(
                  title: Text(item),
                  subtitle: Text(
                    '$count × €${_menu[item]!.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton.ghost(
                    icon: const PhosphorIcon(PhosphorIconsRegular.minus),
                    semanticLabel: 'Remove one $item',
                    onPressed: () => setState(() {
                      if (count == 1) {
                        _order.remove(item);
                      } else {
                        _order[item] = count - 1;
                      }
                    }),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
                child: Button(
                  expands: true,
                  onPressed: _order.isEmpty ? null : () {},
                  child: const Text('Place order'),
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            for (final MapEntry(key: item, value: price) in _menu.entries)
              ListTile(
                title: Text(item),
                subtitle: Text('€${price.toStringAsFixed(2)}'),
                trailing: const PhosphorIcon(PhosphorIconsRegular.plus),
                onTap: () =>
                    setState(() => _order[item] = (_order[item] ?? 0) + 1),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Banner

`banner` is a message across the page under the app bar. The page makes room for it on the surface spring when it comes and goes, and the banner that is leaving stays drawn until it is gone.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A banner under the app bar. The page makes room for it on the surface
/// spring when it comes and when it goes.
class ScaffoldBannerExample extends StatefulWidget {
  const ScaffoldBannerExample({super.key});

  @override
  State<ScaffoldBannerExample> createState() => _ScaffoldBannerExampleState();
}

class _ScaffoldBannerExampleState extends State<ScaffoldBannerExample> {
  bool _offline = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Inbox')),
        banner: _offline
            ? Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
                child: Glass(
                  level: GlassLevel.strong,
                  frosted: false,
                  borderRadius: theme.radii.lg,
                  padding: EdgeInsetsDirectional.only(
                    start: theme.layoutTheme.gap(GapSize.md),
                    end: theme.layoutTheme.gap(GapSize.xs),
                  ),
                  child: Row(
                    spacing: theme.layoutTheme.gap(GapSize.sm),
                    children: [
                      const PhosphorIcon(PhosphorIconsRegular.wifiSlash),
                      Expanded(
                        child: Text(
                          'You are offline',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Button.ghost(
                        size: ButtonSize.sm,
                        onPressed: () => setState(() => _offline = false),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        body: ListView(
          children: [
            ListTile(
              title: const Text('Go offline'),
              subtitle: const Text('Shows the banner again'),
              leading: const PhosphorIcon(PhosphorIconsRegular.wifiSlash),
              onTap: () => setState(() => _offline = true),
            ),
            for (var i = 1; i <= 8; i++)
              ListTile(
                title: Text('Message $i'),
                subtitle: const Text('Saved on this phone'),
              ),
          ],
        ),
      ),
    );
  }
}
```

## An alert as the banner

An `Alert` with `onDismissed` has a close button; it folds away, and the callback takes it out of the scaffold once it has.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An `Alert` as the scaffold's `banner`. Its close button folds it away,
/// and `onDismissed` takes it out of the scaffold once it has.
class ScaffoldBannerAlertExample extends StatefulWidget {
  const ScaffoldBannerAlertExample({super.key});

  @override
  State<ScaffoldBannerAlertExample> createState() =>
      _ScaffoldBannerAlertExampleState();
}

class _ScaffoldBannerAlertExampleState
    extends State<ScaffoldBannerAlertExample> {
  bool _shown = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Payments')),
        banner: _shown
            ? Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
                child: Alert(
                  variant: AlertVariant.warning,
                  icon: const PhosphorIcon(PhosphorIconsRegular.creditCard),
                  title: const Text('Your card expires this month'),
                  description: const Text(
                    'Update it to keep your subscription.',
                  ),
                  onDismissed: () => setState(() => _shown = false),
                ),
              )
            : null,
        body: ListView(
          children: [
            ListTile(
              title: const Text('Show the reminder again'),
              leading: const PhosphorIcon(PhosphorIconsRegular.bell),
              onTap: () => setState(() => _shown = true),
            ),
            for (final (month, amount) in [
              ('November', '€12.00'),
              ('October', '€12.00'),
              ('September', '€12.00'),
              ('August', '€9.00'),
              ('July', '€9.00'),
              ('June', '€9.00'),
            ])
              ListTile(
                title: Text(month),
                subtitle: const Text('Pro plan'),
                trailing: Text(amount, style: theme.textTheme.small),
              ),
          ],
        ),
      ),
    );
  }
}
```

## NavigationScaffold

On a desktop the destinations sit in the middle of the app bar. On a phone they move to a bottom bar with the `action` in its middle, and the app bar keeps `leading` and `mobileActions`. `layout` overrides the choice, or asks for the third: `NavigationLayout.rail` puts a `NavigationRail` down the start edge under the app bar, for a tablet. A destination can opt out of a bar: Notifications is `showInBottomBar: false` here, and is reached from the bell instead. The body is a `DestinationStack`: scroll a page, visit another, and come back to where you were.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// One `NavigationScaffold`, three arrangements. Desktop and Phone switch
/// the frame's form factor, which is what `FinesseApp` does from the window
/// width, and leave the layout to it; Tablet asks for the rail.
class ScaffoldNavigationExample extends StatefulWidget {
  const ScaffoldNavigationExample({super.key});

  @override
  State<ScaffoldNavigationExample> createState() =>
      _ScaffoldNavigationExampleState();
}

class _ScaffoldNavigationExampleState extends State<ScaffoldNavigationExample> {
  static const _destinations = [
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.house),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
      label: 'Home',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.usersThree),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.usersThree),
      label: 'Network',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
      label: 'Messages',
      badgeCount: 3,
    ),
    // In the top bar on a desktop; behind an app bar button on a phone.
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.bell),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.bell),
      label: 'Notifications',
      showInBottomBar: false,
    ),
  ];

  /// Null until one is chosen: the frame starts as whatever the app is.
  String? chosen;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frame =
        chosen ??
        (theme.formFactor == FormFactor.desktop ? 'desktop' : 'phone');
    final isDesktop = frame == 'desktop';
    final isTablet = frame == 'tablet';
    final formFactor = frame == 'phone'
        ? FormFactor.mobile
        : FormFactor.desktop;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Semantics(
          label: 'Frame',
          container: true,
          child: SegmentedControl<String>(
            value: frame,
            onChanged: (value) => setState(() => chosen = value),
            segments: const [
              Segment(value: 'desktop', label: Text('Desktop')),
              Segment(value: 'tablet', label: Text('Tablet')),
              Segment(value: 'phone', label: Text('Phone')),
            ],
          ),
        ),
        // The desktop frame is wider than a phone's screen, so it scrolls.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: theme.withFormFactor(formFactor),
            child: Container(
              width: isDesktop
                  ? 760
                  : isTablet
                  ? 560
                  : 340,
              height: 460,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: theme.radii.xl2,
              ),
              // Painted over the content, so nothing covers the frame's corners.
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.border),
                borderRadius: theme.radii.xl2,
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: NavigationScaffold(
                  // Auto follows the form factor; the rail is asked for.
                  layout: isTablet
                      ? NavigationLayout.rail
                      : NavigationLayout.auto,
                  destinations: _destinations,
                  selectedIndex: index,
                  onDestinationSelected: (i) => setState(() => index = i),
                  leading: PhosphorIcon(
                    PhosphorIconsFill.waves,
                    size: 28,
                    color: theme.colorScheme.tint,
                  ),
                  title: const Text('Strand'),
                  actions: [
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsRegular.gear),
                      semanticLabel: 'Settings',
                      onPressed: () {},
                    ),
                  ],
                  mobileActions: [
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsRegular.bell),
                      semanticLabel: 'Notifications',
                      onPressed: () => setState(() => index = 3),
                    ),
                  ],
                  action: NavigationAction(
                    icon: const PhosphorIcon(PhosphorIconsBold.plus),
                    label: 'Create post',
                    onPressed: () {},
                  ),
                  // Each destination's page is built when it is first
                  // shown and kept, with its scroll offset, after that.
                  body: DestinationStack(
                    index: index,
                    axis: isTablet ? Axis.vertical : Axis.horizontal,
                    builders: [
                      for (final destination in _destinations)
                        (context) => PageContainer(
                          scrollable: true,
                          child: FinesseColumn(
                            gap: GapSize.lg,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 1; i <= 4; i++)
                                Card(
                                  title: Text('${destination.label} $i'),
                                  description: const Text(
                                    'The page scrolls beneath the bars.',
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```
