import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The same controls frosted and liquid. On iOS and macOS una draws
/// them with Liquid Glass by itself (`LiquidGlassMode.auto`); `always`
/// shows it here on any platform and `never` switches it off. A switch,
/// a slider and a segmented control are flat at rest and turn into a lens
/// of glass under the finger.
class LiquidGlassControlsExample extends StatefulWidget {
  const LiquidGlassControlsExample({super.key});

  @override
  State<LiquidGlassControlsExample> createState() =>
      _LiquidGlassControlsExampleState();
}

/// One derived theme per ambient theme and mode: `copyWith` re-runs the
/// whole theme factory, which is not something to do on every build.
final _themes = Expando<Map<LiquidGlassMode, ThemeData>>();

ThemeData _themeFor(ThemeData ambient, LiquidGlassMode mode) {
  final byMode = _themes[ambient] ??= {};
  return byMode[mode] ??= ambient.copyWith(
    liquidGlass: ambient.liquidGlass.copyWith(mode: mode),
  );
}

class _LiquidGlassControlsExampleState
    extends State<LiquidGlassControlsExample> {
  var mode = LiquidGlassMode.always;
  var wifi = true;
  var volume = .6;
  var range = 'Week';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        SegmentedControl<LiquidGlassMode>(
          value: mode,
          onChanged: (value) => setState(() => mode = value),
          segments: const [
            Segment(value: LiquidGlassMode.auto, label: Text('Auto')),
            Segment(value: LiquidGlassMode.always, label: Text('Liquid')),
            Segment(value: LiquidGlassMode.never, label: Text('Frosted')),
          ],
        ),
        Theme(
          data: _themeFor(theme, mode),
          child: ClipRRect(
            borderRadius: theme.radii.xl2,
            child: DecoratedBox(
              // Glass needs something behind it to bend.
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0EA5E9),
                    Color(0xFFA855F7),
                    Color(0xFFF97316),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Glass(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        Switch(
                          value: wifi,
                          onChanged: (value) => setState(() => wifi = value),
                          label: const Text('Wi-Fi'),
                        ),
                        Slider(
                          value: volume,
                          onChanged: (value) => setState(() => volume = value),
                        ),
                        SegmentedControl<String>(
                          value: range,
                          expand: true,
                          onChanged: (value) => setState(() => range = value),
                          segments: const [
                            Segment(value: 'Day', label: Text('Day')),
                            Segment(value: 'Week', label: Text('Week')),
                            Segment(value: 'Month', label: Text('Month')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
