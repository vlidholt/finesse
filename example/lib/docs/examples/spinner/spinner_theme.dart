import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `SpinnerTheme.variant` changes every spinner below that does not choose
/// one — here the buttons' loading spinners.
class SpinnerThemeExample extends StatefulWidget {
  const SpinnerThemeExample({super.key});

  @override
  State<SpinnerThemeExample> createState() => _SpinnerThemeExampleState();
}

class _SpinnerThemeExampleState extends State<SpinnerThemeExample> {
  var _variant = SpinnerVariant.goo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        SegmentedControl<SpinnerVariant>(
          value: _variant,
          onChanged: (variant) => setState(() => _variant = variant),
          segments: [
            for (final variant in SpinnerVariant.values)
              Segment(value: variant, label: Text(variant.name)),
          ],
        ),
        SpinnerThemeScope(variant: _variant),
      ],
    );
  }
}

/// The part of the app that the spinner theme reaches.
class SpinnerThemeScope extends StatelessWidget {
  const SpinnerThemeScope({super.key, required this.variant});

  final SpinnerVariant variant;

  @override
  Widget build(BuildContext context) {
    // In an app this is `ThemeData(spinnerTheme: ...)`; here it is set for
    // the buttons below only.
    final ambient = Theme.of(context);
    return Theme(
      data: _themes[variant]![ambient] ??= ambient.copyWith(
        spinnerTheme: SpinnerTheme(variant: variant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          Button(loading: true, onPressed: () {}, child: const Text('Pay')),
          Button.outline(
            loading: true,
            onPressed: () {},
            child: const Text('Publishing'),
          ),
        ],
      ),
    );
  }

  /// A theme is derived once per variant and ambient theme, not on every
  /// build: `copyWith` derives every component theme again.
  static final _themes = {
    for (final variant in SpinnerVariant.values) variant: Expando<ThemeData>(),
  };
}
