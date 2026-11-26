import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class AutocompleteAsyncExample extends StatelessWidget {
  const AutocompleteAsyncExample({super.key});

  static const packages = [
    'una',
    'flutter_animate',
    'flutter_hooks',
    'flutter_svg',
    'freezed',
    'go_router',
    'google_fonts',
  ];

  /// A stand-in for a request to a server.
  static Future<Iterable<String>> search(TextEditingValue value) async {
    final query = value.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return packages.where((name) => name.contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const padding = EdgeInsets.all(8);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Autocomplete<String>(
        placeholder: const Text('Search packages'),
        leading: PhosphorIcon(
          PhosphorIconsRegular.package,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
        // A builder that answers with a future is asked again only once
        // typing has paused, and a late answer is dropped.
        optionsBuilder: search,
        debounce: const Duration(milliseconds: 250),
        loadingBuilder: (context) => Padding(
          padding: padding,
          child: const Row(
            children: [Spinner(size: 14), Gap.sm(), Text('Searching…')],
          ),
        ),
        emptyBuilder: (context) => Padding(
          padding: padding,
          child: Text('No package found', style: theme.textTheme.muted),
        ),
      ),
    );
  }
}
