import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `Backdrop` is the filter half of glass: it blurs and saturates what is
/// behind it, clipped to its corners. The tint on top is yours.
class BuildingBlocksBackdropExample extends StatefulWidget {
  const BuildingBlocksBackdropExample({super.key});

  @override
  State<BuildingBlocksBackdropExample> createState() =>
      _BuildingBlocksBackdropExampleState();
}

class _BuildingBlocksBackdropExampleState
    extends State<BuildingBlocksBackdropExample> {
  double _blur = 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = theme.radii.xl;

    return SizedBox(
      width: 420,
      child: UnaColumn(
        mainAxisSize: MainAxisSize.min,
        gap: GapSize.md,
        children: [
          ClipRRect(
            borderRadius: theme.radii.xl2,
            child: SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/photo_alpine_lake.jpg',
                    fit: BoxFit.cover,
                  ),
                  Center(
                    // With a blur of 0 and a saturation of 1 this builds no
                    // filter at all and returns its child.
                    child: Backdrop(
                      blur: _blur,
                      saturation: 1.6,
                      borderRadius: radius,
                      child: Container(
                        padding: EdgeInsets.all(
                          theme.layoutTheme.gap(GapSize.lg),
                        ),
                        decoration: BoxDecoration(
                          // The tint: the card colour, mostly see-through.
                          color: scheme.card.withValues(alpha: .55),
                          borderRadius: radius,
                          border: Border.all(
                            color: scheme.foreground.withValues(alpha: .1),
                          ),
                        ),
                        child: Text(
                          'Blur ${_blur.round()}',
                          style: theme.textTheme.large,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Slider(
            value: _blur,
            max: 32,
            semanticLabel: 'Blur',
            onChanged: (value) => setState(() => _blur = value),
          ),
        ],
      ),
    );
  }
}
