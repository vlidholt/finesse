# Reveal Image

A `RevealImage` shows a placeholder while its picture loads and then reveals it. By default it develops as Material describes: it fades in quickly, starts over-exposed and without colour, and settles into its exposure and then its full colour. `reveal: ImageReveal.fade` makes it a plain fade. `RevealImage.network` and `.asset` take a URL or an asset name.

## A network image

An image already in the cache appears at once, so an app that knows what comes next calls `RevealImage.precache` (or `precacheNetwork`) for it, and it is simply there when shown. Under reduced motion the reveal is a short fade.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class RevealImageNetworkExample extends StatefulWidget {
  const RevealImageNetworkExample({super.key});

  @override
  State<RevealImageNetworkExample> createState() =>
      _RevealImageNetworkExampleState();
}

class _RevealImageNetworkExampleState extends State<RevealImageNetworkExample> {
  static const _photos = [
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e',
  ];

  ImageReveal _reveal = ImageReveal.exposure;

  /// Asked of the server at a new width each time, so the picture is not
  /// in the cache and the reveal plays again.
  int _load = 0;

  String _url(int index) => '${_photos[index]}?w=${600 + _load}&q=70';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: UnaColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: ClipRRect(
              borderRadius: Theme.of(context).radii.xl,
              child: RevealImage.network(
                _url(_load % _photos.length),
                key: ValueKey(_load),
                reveal: _reveal,
                fit: BoxFit.cover,
                semanticLabel: 'A landscape',
              ),
            ),
          ),
          UnaRow(
            gap: GapSize.sm,
            children: [
              Expanded(
                child: SegmentedControl<ImageReveal>(
                  value: _reveal,
                  onChanged: (v) => setState(() => _reveal = v),
                  segments: const [
                    Segment(value: ImageReveal.exposure, label: Text('Exposure')),
                    Segment(value: ImageReveal.fade, label: Text('Fade')),
                  ],
                ),
              ),
              Button.outline(
                onPressed: () => setState(() => _load++),
                leading: const PhosphorIcon(
                  PhosphorIconsRegular.arrowClockwise,
                ),
                child: const Text('Load again'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```
