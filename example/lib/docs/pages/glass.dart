import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/glass/glass_levels.dart';
import 'package:example/docs/examples/glass/glass_scrim.dart';
import 'package:example/docs/examples/glass/glass_toolbar.dart';

final glassDoc = ComponentDoc(
  slug: 'glass',
  title: 'Glass',
  description:
      'A frosted surface: a translucent tint over a blurred, saturated '
      'backdrop, with a hairline border. Blur, saturation and opacity come '
      'from the style, so `Glass` follows the theme and its brightness.',
  examples: [
    ComponentExample(
      id: 'glass_levels',
      title: 'Regular and strong',
      description:
          '`level` picks how much of the backdrop shows through. Use '
          '`GlassLevel.strong` for a surface that carries text.',
      minPreviewHeight: 320,
      builder: (_) => const GlassLevelsExample(),
    ),
    ComponentExample(
      id: 'glass_scrim',
      title: 'A dark scrim',
      description:
          '`color` replaces the tint and is used at its own alpha. A dark '
          'scrim keeps white labels readable over a photo in both light '
          'and dark themes.',
      minPreviewHeight: 320,
      builder: (_) => const GlassScrimExample(),
    ),
    ComponentExample(
      id: 'glass_toolbar',
      title: 'Floating chrome',
      description:
          'Scroll the list beneath the toolbar. `shadows` are painted '
          'outside the surface and never show through it. Each `Glass` is '
          'a compositing layer: a handful on screen is fine, a long list '
          'of them is not.',
      minPreviewHeight: 360,
      builder: (_) => const GlassToolbarExample(),
    ),
  ],
);
