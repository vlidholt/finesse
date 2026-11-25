import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/card.dart';
import 'package:finesse/src/components/form/fields/text_field.dart';
import 'package:finesse/src/components/tabs.dart';
import 'package:finesse/src/theme/color_scheme/zinc.dart';
import 'package:finesse/src/theme/components/tabs.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:flutter/material.dart'
    hide Card, Tab, TextFormField, Theme, ThemeData;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      theme: ThemeData(
        tabsTheme: const TabsTheme(
          tabBarConstraints: BoxConstraints(maxWidth: 400),
          contentConstraints: BoxConstraints(maxWidth: 400),
        ),
      ),
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  Widget createColorTestWidget({
    ({Color selected, Color unselected})? themeForegroundColor,
  }) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      theme: ThemeData(
        colorScheme: const ZincColorScheme.light(),
        brightness: Brightness.light,
        tabsTheme: TabsTheme(
          tabBarConstraints: const BoxConstraints(maxWidth: 400),
          contentConstraints: const BoxConstraints(maxWidth: 400),
          tabSelectedForegroundColor: themeForegroundColor?.selected,
          tabForegroundColor: themeForegroundColor?.unselected,
        ),
      ),
      home: Scaffold(
        body: Tabs<String>(
          value: 'account',
          // Without it the tabs are inert, and drawn so.
          onChanged: (_) {},
          tabs: [
            Tab(
              value: 'account',
              content: Card(
                title: const Text('Account'),
                description: const Text(
                  """Make changes to your account here. Click save when you're done.""",
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
              child: const Text('AccountTab'),
            ),
            Tab(
              value: 'password',
              content: Card(
                title: const Text('Password'),
                description: const Text(
                  """Change your password here. After saving, you'll be logged out.""",
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
              child: const Text('PasswordTab'),
            ),
          ],
        ),
      ),
    );
  }

  group('Tabs', () {
    testWidgets('Tabs matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Tabs<String>(
            value: 'account',
            // Without it the tabs are inert, and drawn so.
            onChanged: (_) {},
            tabs: [
              Tab(
                value: 'account',
                content: Card(
                  title: const Text('Account'),
                  description: const Text(
                    """Make changes to your account here. Click save when you're done.""",
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
                    """Change your password here. After saving, you'll be logged out.""",
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
        ),
      );

      await expectLater(
        find.byType(Tabs<String>),
        matchesGoldenFile('goldens/tabs.png'),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('Tab applies the correct color to the button when provided '
        'from Theme', (tester) async {
      const redColor = Color(0xFFFF0000);
      const blueColor = Color(0xFF0000FF);
      await tester.pumpWidget(
        createColorTestWidget(
          themeForegroundColor: (selected: blueColor, unselected: redColor),
        ),
      );

      // Test the color of the tab buttons
      final accountTextStyle = tester.widget<DefaultTextStyle>(
        find.widgetWithText(DefaultTextStyle, 'AccountTab').first,
      );
      final passwordTextStyle = tester.widget<DefaultTextStyle>(
        find.widgetWithText(DefaultTextStyle, 'PasswordTab').first,
      );
      expect(accountTextStyle.style.color, blueColor);
      expect(passwordTextStyle.style.color, redColor);

      await tester.pumpAndSettle();
    });
  });
}
