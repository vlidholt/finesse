import 'package:finesse/finesse.dart' hide Scaffold;
import 'package:finesse/material.dart';
import 'package:flutter/material.dart'
    hide
        Badge,
        Card,
        Checkbox,
        Dialog,
        Slider,
        Switch,
        Tab,
        TextField,
        ThemeData;
import 'package:flutter_test/flutter_test.dart';

/// Every outward shadow has to go through [ShadowDecoration] so it is
/// clipped to the element it belongs to. A shadow left on a plain
/// [BoxDecoration] paints behind the whole box — a grey wash under anything
/// translucent — and one wearing [BlurStyle.outer] instead is cut out along its
/// own displaced rectangle, which leaves a hard-edged gap beside the element.
///
/// The styles disagree about which surfaces are shadowed at all — nova shadows
/// only its popovers, sera nearly everything — so this walks all eight rather
/// than trusting the default.
///
/// See `lib/src/utils/shadow.dart`.
void main() {
  final surfaces = <Widget>[
    const Card(title: Text('Card'), child: Text('Body')),
    const TextField(placeholder: Text('Input')),
    const Textarea(placeholder: Text('Textarea')),
    Button(onPressed: () {}, child: const Text('Button')),
    Button.outline(onPressed: () {}, child: const Text('Button')),
    Checkbox(value: true, onChanged: (_) {}),
    Switch(value: true, onChanged: (_) {}),
    const Slider(initialValue: 50, max: 100),
    Select<String>(
      onChanged: (_) {},
      options: const [SelectOption(value: 'a', child: Text('A'))],
      selectedOptionBuilder: (context, value) => Text(value),
      placeholder: const Text('Select'),
    ),
    const Tabs<String>(
      value: 'a',
      tabs: [Tab(value: 'a', child: Text('A'))],
    ),
    const Menubar(
      items: [MenubarItem(items: [], child: Text('File'))],
    ),
    const Toast(title: Text('Toast')),
    const Dialog(title: Text('Dialog'), child: Text('Body')),
    const Badge(child: Text('Badge')),
    const ProgressBar(value: 0.5),
  ];

  for (final style in StyleTokens.all) {
    testWidgets('${style.name} paints no shadow on a raw BoxDecoration', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          theme: ThemeData(
            colorScheme: const NeutralColorScheme.light(),
            style: style,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [for (final surface in surfaces) surface],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final offenders = <String>{};
      // `tester.allWidgets`, not `find.byType(Widget)` — byType matches the
      // exact runtime type, so it finds nothing at all for Widget itself.
      for (final widget in tester.allWidgets) {
        final decoration = switch (widget) {
          Container(:final decoration) => decoration,
          DecoratedBox(:final decoration) => decoration,
          AnimatedContainer(:final decoration) => decoration,
          _ => null,
        };
        if (decoration
            case BoxDecoration(
              boxShadow: final shadows?,
            )
            when shadows.isNotEmpty) {
          offenders.add('${widget.runtimeType}: $shadows');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'wrap these in ShadowDecoration:\n${offenders.join('\n')}',
      );
    });
  }
}
