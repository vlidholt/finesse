import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/reveal_image/reveal_image_network.dart';

final revealImageDoc = ComponentDoc(
  slug: 'reveal_image',
  title: 'Reveal Image',
  description:
      'A `RevealImage` shows a placeholder while its picture loads and then '
      'reveals it. By default it develops as Material describes: it fades '
      'in quickly, starts over-exposed and without colour, and settles into '
      'its exposure and then its full colour. `reveal: ImageReveal.fade` '
      'makes it a plain fade. `RevealImage.network` and `.asset` take a URL '
      'or an asset name.',
  examples: [
    ComponentExample(
      id: 'reveal_image_network',
      title: 'A network image',
      description:
          'An image already in the cache appears at once, so an app that '
          'knows what comes next calls `RevealImage.precache` (or '
          '`precacheNetwork`) for it, and it is simply there when shown. '
          'Under reduced motion the reveal is a short fade.',
      builder: (_) => const RevealImageNetworkExample(),
    ),
  ],
);
