import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

enum NotifyAbout {
  all('All new messages'),
  mentions('Direct messages and mentions'),
  nothing('Nothing');

  const NotifyAbout(this.message);

  final String message;
}

class RadioGroupBasicExample extends StatelessWidget {
  const RadioGroupBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaRadioGroup<NotifyAbout>(
      initialValue: NotifyAbout.mentions,
      onChanged: (value) {},
      items: [
        for (final option in NotifyAbout.values)
          Radio(value: option, label: Text(option.message)),
      ],
    );
  }
}
