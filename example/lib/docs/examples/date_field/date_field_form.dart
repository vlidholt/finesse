import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `DateFormField` puts the field in a form. A failed validation moves the
/// focus to the first field.
class DateFieldFormExample extends StatefulWidget {
  const DateFieldFormExample({super.key});

  @override
  State<DateFieldFormExample> createState() => _DateFieldFormExampleState();
}

class _DateFieldFormExampleState extends State<DateFieldFormExample> {
  final formKey = GlobalKey<FinesseFormState>();
  String? saved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saved = this.saved;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: FinesseForm(
        key: formKey,
        child: FinesseColumn(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          gap: GapSize.md,
          children: [
            DateFormField(
              id: 'born',
              label: const Text('Date of birth'),
              description: const Text('As it is written in your passport.'),
              max: DateTime.now(),
              validator: (date) =>
                  date == null ? 'Enter your date of birth' : null,
            ),
            Button(
              onPressed: () {
                if (!formKey.currentState!.saveAndValidate()) return;
                final date = formKey.currentState!.value['born'] as DateTime;
                setState(() => this.saved = formatPickedDate(context, date));
              },
              child: const Text('Save'),
            ),
            if (saved != null)
              Text('Saved: $saved', style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
