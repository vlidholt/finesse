# Page Container

`PageContainer` centres page content, caps its width and gives it the page margins of the theme, so every screen lines up with the app bar. `FormFactorBuilder` picks between two layouts where a screen is arranged differently on a phone.

## PageContainer

Margins and the maximum width come from `ThemeData.layoutTheme`, so they tighten on a phone. The safe area, which inside a `Scaffold` includes the bars, is added to the padding; with `scrollable` the content still scrolls beneath them.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A page inside a stand-in window. The content takes the theme's page
/// margins, stops growing at `maxWidth` and is centred beyond it.
class PageContainerBasicExample extends StatelessWidget {
  const PageContainerBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 640,
      height: 340,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl,
      ),
      // Painted over the content, so nothing covers the frame's corners.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radii.xl,
      ),
      child: PageContainer(
        scrollable: true,
        // The theme's page width is 1280; narrowed so the cap shows here.
        maxWidth: 440,
        child: FinesseColumn(
          gap: GapSize.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Jobs for you', style: theme.textTheme.h4),
            for (final role in const [
              'Senior product designer',
              'Design systems lead',
              'UX researcher',
              'Content designer',
            ])
              Card(
                title: Text(role),
                description: const Text('Copenhagen, hybrid'),
              ),
          ],
        ),
      ),
    );
  }
}
```

## FormFactorBuilder

Use it where the layout is rearranged, not merely resized: sizes already follow the form factor through the theme. For a one-off branch read `Theme.of(context).formFactor`.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A screen that is *arranged* differently on a phone: the list alone, where
/// a desktop shows the list beside the conversation.
class FormFactorBuilderExample extends StatefulWidget {
  const FormFactorBuilderExample({super.key});

  @override
  State<FormFactorBuilderExample> createState() =>
      _FormFactorBuilderExampleState();
}

class _FormFactorBuilderExampleState extends State<FormFactorBuilderExample> {
  /// Null until a tab is chosen: the frame starts as whatever the app is.
  FormFactor? chosen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formFactor = chosen ?? theme.formFactor;
    final scheme = theme.colorScheme;

    final list = ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final name in const ['Omar Rahimi', 'Mei Tanaka', 'Freya Holm'])
          ListTile(
            leading: Avatar('', fallback: Text(name[0])),
            title: Text(name),
            subtitle: const Text('Sent you a message'),
            onTap: () {},
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        SizedBox(
          width: 220,
          child: Tabs<FormFactor>(
            value: formFactor,
            expandTabs: true,
            onChanged: (value) => setState(() => chosen = value),
            tabs: const [
              Tab(value: FormFactor.desktop, child: Text('Desktop')),
              Tab(value: FormFactor.mobile, child: Text('Phone')),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // In an app the form factor comes from `FinesseApp`; here the
          // frame's theme is switched by hand.
          child: Theme(
            data: theme.withFormFactor(formFactor),
            child: Container(
              width: formFactor == FormFactor.desktop ? 620 : 320,
              height: 280,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: scheme.background,
                borderRadius: theme.radii.xl,
              ),
              // Painted over the content, so nothing covers the frame's corners.
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: scheme.border),
                borderRadius: theme.radii.xl,
              ),
              child: FormFactorBuilder(
                mobile: (context) => list,
                desktop: (context) => Row(
                  children: [
                    SizedBox(width: 260, child: list),
                    const Divider.vertical(margin: EdgeInsets.zero),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Select a conversation',
                          style: theme.textTheme.muted,
                        ),
                      ),
                    ),
                  ],
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

