import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

import '../frames.dart';
import '../harness.dart';
import 'common.dart';

/// The size of the style comparison.
const stylesSize = Size(1440, 600);

/// The same card in each of the four styles, on the default palette.
class StylesScene extends StatelessWidget {
  /// Creates the comparison.
  const StylesScene({super.key});

  static final _styles = [
    ('una', 'The default: glass, springs, soft radii', StyleTokens.una),
    ('nova', "shadcn/ui's compact style", StyleTokens.nova),
    ('maia', "shadcn/ui's rounded style", StyleTokens.maia),
    ('lyra', "shadcn/ui's sharp style", StyleTokens.lyra),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF3F5F5),
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, (name, about, style)) in _styles.indexed) ...[
              if (i > 0) const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SceneLabel(name),
                    const SizedBox(height: 2),
                    Text(
                      about,
                      style: const TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 13,
                        color: Color(0xFF5B6B6A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: Panel(
                        theme: imageTheme(style: style),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: StyleSample(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A card that shows off a style: tabs, fields, a select, a switch, a slider,
/// badges and buttons.
class StyleSample extends StatelessWidget {
  /// Creates the sample.
  const StyleSample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
      ),
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const PersonAvatar(0),
              const Gap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      people[0].name,
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(people[0].role, style: theme.textTheme.muted),
                  ],
                ),
              ),
              const Badge.secondary(child: Text('Pro')),
            ],
          ),
          const Gap.lg(),
          Tabs<String>(
            value: 'profile',
            onChanged: (_) {},
            expandTabs: true,
            tabs: const [
              Tab(value: 'profile', child: Text('Profile')),
              Tab(value: 'billing', child: Text('Billing')),
            ],
          ),
          const Gap.lg(),
          label('Display name'),
          const TextField(initialValue: 'Maya'),
          const Gap.md(),
          label('Time zone'),
          Select<String>(
            value: 'cet',
            onChanged: (_) {},
            options: const [
              SelectOption(value: 'cet', label: 'Central European Time'),
              SelectOption(value: 'utc', label: 'UTC'),
            ],
          ),
          const Gap.lg(),
          Switch(
            value: true,
            onChanged: (_) {},
            controlAffinity: ControlAffinity.trailing,
            label: const Text('Show online status'),
          ),
          const Gap.lg(),
          const Slider(initialValue: 40, max: 100),
          const Gap.lg(),
          Row(
            children: [
              Expanded(
                child: Button.outline(
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
              ),
              const Gap.sm(),
              Expanded(
                child: Button(onPressed: () {}, child: const Text('Save')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
