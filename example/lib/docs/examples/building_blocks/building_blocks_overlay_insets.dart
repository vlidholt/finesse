import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Something that floats over every screen reads `OverlayInsets` to stay
/// clear of what the screens put at their edges. The pill is not part of
/// the scaffold, and still rides above its footer.
class BuildingBlocksOverlayInsetsExample extends StatefulWidget {
  const BuildingBlocksOverlayInsetsExample({super.key});

  @override
  State<BuildingBlocksOverlayInsetsExample> createState() =>
      _BuildingBlocksOverlayInsetsExampleState();
}

class _BuildingBlocksOverlayInsetsExampleState
    extends State<BuildingBlocksOverlayInsetsExample> {
  bool _footer = true;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 420,
      // Above both: the scaffold that reports and the pill that reads.
      child: OverlayInsetsScope(
        child: Stack(
          children: [
            Scaffold(
              appBar: const AppBar(title: Text('Cart')),
              footer: _footer
                  ? Button(onPressed: () {}, child: const Text('Check out'))
                  : null,
              body: Center(
                child: Switch(
                  value: _footer,
                  onChanged: (value) => setState(() => _footer = value),
                  label: const Text('Show the footer'),
                ),
              ),
            ),
            const _Pill(),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Rebuilds when a bar appears, grows or goes away.
    final insets = OverlayInsets.watch(context);

    return SpringBuilder(
      value: insets.bottom,
      spring: Motion.of(context).smooth,
      builder: (context, bottom, child) => Positioned(
        left: 0,
        right: 0,
        bottom: bottom + theme.layoutTheme.gap(GapSize.md),
        child: child!,
      ),
      child: Center(
        child: Glass(
          borderRadius: theme.radii.full,
          padding: EdgeInsets.symmetric(
            horizontal: theme.layoutTheme.gap(GapSize.md),
            vertical: theme.layoutTheme.gap(GapSize.sm),
          ),
          child: Text('2 items added', style: theme.textTheme.small),
        ),
      ),
    );
  }
}
