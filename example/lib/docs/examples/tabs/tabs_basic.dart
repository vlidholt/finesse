import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TabsBasicExample extends StatefulWidget {
  const TabsBasicExample({super.key});

  @override
  State<TabsBasicExample> createState() => _TabsBasicExampleState();
}

class _TabsBasicExampleState extends State<TabsBasicExample> {
  String tab = 'account';

  @override
  Widget build(BuildContext context) {
    // The strip hugs its tabs at the start of the width it is given, so
    // the box around the whole control is what lines it up with its panel.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Tabs<String>(
        value: tab,
        onChanged: (value) => setState(() => tab = value),
        tabs: [
          Tab(
            value: 'account',
            content: Card(
              title: const Text('Account'),
              description: const Text(
                "Make changes to your account here. Click save when you're "
                'done.',
              ),
              footer: const Button(child: Text('Save changes')),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    label: const Text('Name'),
                    initialValue: 'Ale',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    label: const Text('Username'),
                    initialValue: 'nank1ro',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            child: const Text('Account'),
          ),
          Tab(
            value: 'password',
            content: Card(
              title: const Text('Password'),
              description: const Text(
                "Change your password here. After saving, you'll be logged "
                'out.',
              ),
              footer: const Button(child: Text('Save password')),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    label: const Text('Current password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    label: const Text('New password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            child: const Text('Password'),
          ),
        ],
      ),
    );
  }
}
