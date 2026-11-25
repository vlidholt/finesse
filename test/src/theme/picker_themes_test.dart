import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The component themes of the pickers: they are derived for every style
/// and form factor, compare by value (or the app re-themes on every build),
/// and can be overridden through `ThemeData` and its `copyWith`.
void main() {
  for (final style in StyleTokens.all) {
    for (final formFactor in FormFactor.values) {
      for (final brightness in Brightness.values) {
        test('${style.name} ${formFactor.name} ${brightness.name}: the '
            'picker themes are complete and equal when built twice', () {
          ThemeData build() => ThemeData(
            style: style,
            formFactor: formFactor,
            brightness: brightness,
          );
          final a = build();
          final b = build();
          expect(a.wheelPickerTheme, b.wheelPickerTheme);
          expect(a.timeFieldTheme, b.timeFieldTheme);
          expect(a.timePickerTheme, b.timePickerTheme);
          expect(a.datePickerTheme, b.datePickerTheme);
          expect(a.chipTheme, b.chipTheme);
          expect(a, b);

          final wheel = a.wheelPickerTheme;
          expect(wheel.itemExtent, a.style.inputHeight);
          expect(wheel.textStyle, isNotNull);
          expect(wheel.selectedTextStyle, isNotNull);
          expect(wheel.lensColor, isNotNull);
          expect(wheel.lensBorderRadius, isNotNull);
          expect(wheel.lensMagnification, greaterThanOrEqualTo(1));
          // The row under the lens reads against the surface; the others
          // recede.
          expect(
            wheel.selectedTextStyle!.color,
            a.colorScheme.foreground,
          );
          expect(a.timeFieldTheme.fieldDecoration, isNotNull);
          // The trigger is a field unless a theme names a button.
          expect(a.datePickerTheme.buttonVariant, isNull);
          expect(a.chipTheme.showCheckmark, isFalse);
        });
      }
    }
  }

  test('ThemeData and copyWith take the new themes', () {
    const wheel = WheelPickerTheme(itemExtent: 52, curvature: 0);
    const field = TimeFieldTheme(fieldWidth: 60);
    final theme = ThemeData(wheelPickerTheme: wheel, timeFieldTheme: field);
    expect(theme.wheelPickerTheme.itemExtent, 52);
    expect(theme.wheelPickerTheme.curvature, 0);
    // What the override leaves out is still the style's.
    expect(theme.wheelPickerTheme.lensBorderRadius, isNotNull);
    expect(theme.timeFieldTheme.fieldWidth, 60);

    final copied = ThemeData().copyWith(
      wheelPickerTheme: wheel,
      timeFieldTheme: field,
    );
    expect(copied.wheelPickerTheme.itemExtent, 52);
    expect(copied.timeFieldTheme.fieldWidth, 60);
    // And they survive a later copy that changes something else.
    final dark = copied.copyWith(brightness: Brightness.dark);
    expect(dark.wheelPickerTheme.itemExtent, 52);
    expect(dark.timeFieldTheme.fieldWidth, 60);
  });

  test('the new themes lerp', () {
    final a = ThemeData().wheelPickerTheme;
    final b = ThemeData(formFactor: FormFactor.mobile).wheelPickerTheme;
    final mid = WheelPickerTheme.lerp(a, b, .5)!;
    expect(
      mid.itemExtent,
      closeTo((a.itemExtent! + b.itemExtent!) / 2, .001),
    );
    expect(TimeFieldTheme.lerp(null, null, .5), isNull);
  });
}
