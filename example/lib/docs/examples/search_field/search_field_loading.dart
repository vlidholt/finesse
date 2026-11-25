import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SearchFieldLoadingExample extends StatefulWidget {
  const SearchFieldLoadingExample({super.key});

  @override
  State<SearchFieldLoadingExample> createState() =>
      _SearchFieldLoadingExampleState();
}

class _SearchFieldLoadingExampleState extends State<SearchFieldLoadingExample> {
  Timer? request;
  String answer = 'Type to search';

  void search(String query) {
    request?.cancel();
    if (query.isEmpty) {
      setState(() {
        request = null;
        answer = 'Type to search';
      });
      return;
    }
    // A stand-in for a request to a server.
    setState(() {
      request = Timer(const Duration(milliseconds: 900), () {
        setState(() {
          request = null;
          answer = '3 results for "$query"';
        });
      });
    });
  }

  @override
  void dispose() {
    request?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchField(
            // The magnifier is a spinner while results are on their way.
            loading: request != null,
            onChanged: search,
          ),
          const Gap.sm(),
          Text(answer, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
