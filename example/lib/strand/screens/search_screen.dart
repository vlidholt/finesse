import 'package:example/strand/widgets/search_field.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The search page a phone opens from the app bar's magnifier.
///
/// The designs have no search results, so this is only the field and an
/// empty state. It is also the shell's own example of a full-screen route:
/// a `Scaffold` with its own `AppBar`, pushed with `context.pushFullScreen`.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton.ghost(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          semanticLabel: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SearchField(
          autofocus: true,
          showShortcut: false,
          maxWidth: double.infinity,
        ),
      ),
      body: const PageContainer(
        alignment: Alignment.center,
        child: Empty(
          icon: Icon(PhosphorIconsRegular.magnifyingGlass),
          title: Text('Search Strand'),
          description: Text(
            'Find people, posts and jobs. Results are not part of the Strand '
            'designs.',
          ),
        ),
      ),
    );
  }
}
