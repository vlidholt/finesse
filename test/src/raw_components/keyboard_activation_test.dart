import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Everything that is pressed is pressed from the keyboard too: Enter, the
/// number pad's Enter and Space activate whatever has the focus.
///
/// The keys are not bound alike everywhere. Off the web all three are
/// `ActivateIntent`; on the web Enter and the number pad's Enter are
/// `ButtonActivateIntent`, and Space is `ActivateIntent` ahead of a scroll.
/// `keyboard_activation_web_test.dart` runs this file in a browser.
void main() {
  const keys = {
    'Enter': LogicalKeyboardKey.enter,
    'numpad Enter': LogicalKeyboardKey.numpadEnter,
    'Space': LogicalKeyboardKey.space,
  };

  final targets = <String, Widget Function(VoidCallback activate)>{
    'Pressable': (activate) => Pressable(
      onPressed: activate,
      builder: (context, states) => const Text('Row'),
    ),
    'Button': (activate) => Button(
      onPressed: activate,
      child: const Text('Save'),
    ),
    'IconButton': (activate) => IconButton(
      onPressed: activate,
      semanticLabel: 'Add',
      icon: const PhosphorIcon(PhosphorIconsRegular.plus),
    ),
    'ListTile': (activate) => ListTile(
      title: const Text('Account'),
      onTap: activate,
    ),
    'SwitchListTile': (activate) => SwitchListTile(
      title: const Text('Read receipts'),
      value: false,
      onChanged: (_) => activate(),
    ),
    'Chip': (activate) => Chip(
      label: const Text('Remote'),
      onPressed: activate,
    ),
    'Checkbox': (activate) => Checkbox(
      value: false,
      onChanged: (_) => activate(),
    ),
    'Switch': (activate) => Switch(
      value: false,
      onChanged: (_) => activate(),
    ),
    'Card': (activate) => Card(
      onPressed: activate,
      child: const Text('Open'),
    ),
  };

  for (final MapEntry(key: name, value: build) in targets.entries) {
    for (final MapEntry(key: keyName, value: key) in keys.entries) {
      testWidgets('$keyName activates a focused $name', (tester) async {
        var activations = 0;
        await tester.pumpWidget(
          FinesseApp(
            home: Scaffold(
              // Scrollable: on the web Space scrolls unless something
              // takes it first.
              body: ListView(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: build(() => activations++),
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(
          FocusManager.instance.primaryFocus?.context,
          isNotNull,
          reason: 'Tab reaches it',
        );
        expect(activations, 0);

        await tester.sendKeyEvent(key);
        await tester.pump();
        expect(activations, 1);
        // And again: one press, one activation.
        await tester.sendKeyEvent(key);
        await tester.pump();
        expect(activations, 2);
        await tester.pump(const Duration(seconds: 1));
      });
    }
  }

  testWidgets('a Pressable with nothing to do takes no key', (tester) async {
    var scrolled = false;
    final controller = ScrollController()..addListener(() => scrolled = true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      FinesseApp(
        home: Scaffold(
          body: ListView(
            controller: controller,
            children: [
              Pressable(builder: (context, states) => const Text('Row')),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(scrolled, isFalse);
  });
}
