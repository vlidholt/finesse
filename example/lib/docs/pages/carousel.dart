import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/carousel/carousel_autoplay.dart';
import 'package:example/docs/examples/carousel/carousel_cards.dart';
import 'package:example/docs/examples/carousel/carousel_photos.dart';

final carouselDoc = ComponentDoc(
  slug: 'carousel',
  title: 'Carousel',
  description:
      'Pages to swipe through, one or a few at a time: a post\'s '
      'photographs, a row of cards, an onboarding flow.',
  examples: [
    ComponentExample(
      id: 'carousel_photos',
      title: 'Photographs',
      description:
          'One page at a time, looping, with the carousel\'s own indicator '
          'over the photograph. Drag with a finger or a trackpad; where a '
          'mouse is connected the previous and next buttons fade in under '
          'the pointer. With the focus on the carousel the arrow keys, '
          'Page Up and Page Down, Home and End turn the pages.',
      minPreviewHeight: 300,
      builder: (_) => const CarouselPhotosExample(),
    ),
    ComponentExample(
      id: 'carousel_cards',
      title: 'Cards with the next one showing',
      description:
          '`viewportFraction` below 1 lets the neighbours show, a themed '
          'gap apart. A `CarouselController` moves the carousel from '
          'outside and reports each change of page, which is how the '
          '`PageIndicator` under it follows along and takes taps.',
      minPreviewHeight: 240,
      builder: (_) => const CarouselCardsExample(),
    ),
    ComponentExample(
      id: 'carousel_autoplay',
      title: 'Moving on by itself',
      description:
          '`autoPlay` turns the page every so often. It waits while the '
          'pointer is over the carousel, while the focus is in it and '
          'while it is touched, and does not run under reduced motion.',
      minPreviewHeight: 220,
      builder: (_) => const CarouselAutoplayExample(),
    ),
  ],
);
