import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The richer controls as form fields: each has a label, a description and
/// a validator, and a failed validation moves the focus to the first field
/// that failed.
class FormMoreFieldsExample extends StatefulWidget {
  const FormMoreFieldsExample({super.key});

  @override
  State<FormMoreFieldsExample> createState() => _FormMoreFieldsExampleState();
}

class _FormMoreFieldsExampleState extends State<FormMoreFieldsExample> {
  final formKey = GlobalKey<FinesseFormState>();

  static const cities = ['Lima', 'Lisbon', 'Ljubljana', 'London', 'Lyon'];
  String? saved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saved = this.saved;
    return FinesseForm(
      key: formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: FinesseColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          gap: GapSize.lg,
          children: [
            AutocompleteFormField<String>(
              id: 'city',
              label: const Text('City'),
              placeholder: const Text('Start typing'),
              optionsBuilder: (value) => cities.where(
                (city) =>
                    city.toLowerCase().startsWith(value.text.toLowerCase()),
              ),
              validator: (text) =>
                  cities.contains(text) ? null : 'Pick a city from the list',
            ),
            DateFormField(
              id: 'arrival',
              label: const Text('Arrival'),
              min: DateTime.now(),
              validator: (date) => date == null ? 'Enter a date' : null,
            ),
            ChipGroupFormField<String>(
              id: 'interests',
              label: const Text('Interests'),
              items: const [
                ChipGroupItem(value: 'food', label: Text('Food')),
                ChipGroupItem(value: 'museums', label: Text('Museums')),
                ChipGroupItem(value: 'hiking', label: Text('Hiking')),
                ChipGroupItem(value: 'music', label: Text('Music')),
              ],
              validator: (chosen) =>
                  chosen.isEmpty ? 'Pick at least one' : null,
            ),
            TagFormField<String>(
              id: 'companions',
              label: const Text('Travelling with'),
              description: const Text('Type a name and press Enter.'),
              placeholder: const Text('Add a name'),
              labelBuilder: (context, name) => Text(name),
              maxTags: 4,
            ),
            RangeSliderFormField(
              id: 'budget',
              label: const Text('Budget per night'),
              max: 400,
              divisions: 40,
              showDivisionMarks: false,
              initialValue: const [80, 200],
              valueIndicator: SliderValueIndicator.whileDragging,
              valueLabel: (value) => '€${value.round()}',
            ),
            RatingFormField(
              id: 'last_trip',
              label: const Text('How was your last trip?'),
              validator: (stars) => stars == 0 ? 'Give it a rating' : null,
            ),
            ColorPickerFormField(
              id: 'tag',
              label: const Text('Colour of the trip in your calendar'),
              initialValue: theme.colorScheme.primary,
            ),
            Button(
              child: const Text('Save'),
              onPressed: () {
                final form = formKey.currentState!;
                if (!form.saveAndValidate()) return;
                setState(() => this.saved = '${form.value['city']}');
              },
            ),
            if (saved != null)
              Text('Saved a trip to $saved', style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
