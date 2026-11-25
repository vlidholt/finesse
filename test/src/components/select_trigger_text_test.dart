import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// A select's trigger is a field: the value it shows is set as a text
/// field sets what is typed into it, and its placeholder as a text field's
/// placeholder. A value in the muted role read as a placeholder beside the
/// text fields of a form.
void main() {
  TextStyle painted(WidgetTester tester, String text) =>
      tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

  Widget form({String? value}) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: TextEditingController(text: 'Typed'),
        placeholder: const Text('Type here'),
      ),
      const TextField(placeholder: Text('Empty field')),
      Select<String>(
        initialValue: value,
        placeholder: const Text('Pick one'),
        options: const [
          SelectOption(value: 'en', child: Text('English')),
          SelectOption(value: 'sv', child: Text('Svenska')),
        ],
        selectedOptionBuilder: (context, value) =>
            Text(value == 'en' ? 'English' : 'Svenska'),
      ),
    ],
  );

  for (final (name, style) in [
    ('finesse', StyleTokens.finesse),
    ('nova', StyleTokens.nova),
    ('maia', StyleTokens.maia),
    ('lyra', StyleTokens.lyra),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets('$name $brightness: the value is a field value, the '
          'placeholder a field placeholder', (tester) async {
        final theme = ThemeData(
          style: style,
          colorScheme: brightness == Brightness.dark
              ? const TealColorScheme.dark()
              : const TealColorScheme.light(),
        );
        final scheme = theme.colorScheme;

        await pumpFinesse(
          tester,
          Center(child: form(value: 'en')),
          theme: theme,
        );
        final typed = tester
            .widget<EditableText>(find.byType(EditableText).first)
            .style;
        final value = painted(tester, 'English');
        expect(value.color, scheme.foreground);
        expect(value.color, typed.color);
        expect(value.fontSize, typed.fontSize);
        expect(value.fontWeight, typed.fontWeight);
        expect(value.height, typed.height);

        // A select holds the value it started with: a fresh one.
        await tester.pumpWidget(const SizedBox.shrink());
        await pumpFinesse(tester, Center(child: form()), theme: theme);
        final fieldPlaceholder = painted(tester, 'Empty field');
        final placeholder = painted(tester, 'Pick one');
        expect(placeholder.color, scheme.mutedForeground);
        expect(placeholder.fontSize, fieldPlaceholder.fontSize);
        expect(placeholder.fontSize, value.fontSize);
      });
    }
  }
}
