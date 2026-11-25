import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Declared pages: the list of `FinessePage`s *is* the stack. A swipe back
/// or the back button removes the page, and `onDidRemovePage` brings the
/// state in line. A router package takes the same pages from its
/// `pageBuilder`.
class PageRoutePagesExample extends StatefulWidget {
  const PageRoutePagesExample({super.key});

  @override
  State<PageRoutePagesExample> createState() => _PageRoutePagesExampleState();
}

class _PageRoutePagesExampleState extends State<PageRoutePagesExample> {
  static const _people = ['Ada Okafor', 'Jonas Lind', 'Mei Tanaka'];

  String? open;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: 340,
        height: 420,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: theme.radii.xl2),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl2,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Navigator(
            pages: [
              FinessePage<void>(
                key: const ValueKey('people'),
                child: Scaffold(
                  appBar: const AppBar(title: Text('People')),
                  body: PageContainer(
                    scrollable: true,
                    child: FinesseColumn(
                      gap: GapSize.sm,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final person in _people)
                          ListTile(
                            title: Text(person),
                            trailing: const PhosphorIcon(
                              PhosphorIconsRegular.caretRight,
                            ),
                            onTap: () => setState(() => open = person),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (open case final person?)
                FinessePage<void>(
                  key: ValueKey(person),
                  backGesture: true,
                  child: Scaffold(
                    // The bar's back button pops the page, and
                    // `onDidRemovePage` below clears the state.
                    appBar: AppBar(title: Text(person)),
                    body: PageContainer(
                      child: Card(
                        title: Text(person),
                        description: const Text(
                          'Shown because the state says so. Going back '
                          'clears it.',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
            onDidRemovePage: (page) => setState(() => open = null),
          ),
        ),
      ),
    );
  }
}
