# una example

A minimal app: a themed `UnaApp` with a card, a text field, a select
and a button that shows a toast.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaApp(
      theme: ThemeData(
        colorScheme: const ZincColorScheme.light(),
        // One of the four styles: una (the default), or shadcn/ui's
        // nova, maia or lyra.
        style: StyleTokens.nova,
      ),
      darkTheme: ThemeData(
        colorScheme: const ZincColorScheme.dark(),
        style: StyleTokens.nova,
      ),
      home: const Center(child: SignUpCard()),
    );
  }
}

class SignUpCard extends StatelessWidget {
  const SignUpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      style: const CardTheme(width: 360),
      title: const Text('Create an account'),
      description: const Text('Enter your details to get started.'),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Button(
            onPressed: () => Toaster.of(context).show(
              const Toast(title: Text('Account created')),
            ),
            child: const Text('Sign up'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const TextField(placeholder: Text('Email')),
          Select<String>(
            placeholder: const Text('Plan'),
            options: const [
              SelectOption(value: 'free', child: Text('Free')),
              SelectOption(value: 'pro', child: Text('Pro')),
            ],
            selectedOptionBuilder: (context, value) => Text(value),
          ),
        ],
      ),
    );
  }
}
```

## Fonts

una bundles no fonts, so the example above renders in the platform font.
To match shadcn/ui's Inter, add `google_fonts` and set:

```dart
ThemeData(textTheme: TextTheme.fromGoogleFont(GoogleFonts.inter))
```

## More

The rest of this directory is the [live docs site](https://vlidholt.github.io/una/):
every component with live previews, the exact source of each, and a theme
editor. See `README.md` here for running it locally.
