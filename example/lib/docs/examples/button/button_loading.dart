import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonLoadingExample extends StatefulWidget {
  const ButtonLoadingExample({super.key});

  @override
  State<ButtonLoadingExample> createState() => _ButtonLoadingExampleState();
}

class _ButtonLoadingExampleState extends State<ButtonLoadingExample> {
  final _busy = <String>{};
  final _timers = <Timer>[];

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  // Stands in for a request: two seconds of work.
  void _run(String action) {
    setState(() => _busy.add(action));
    _timers.add(
      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _busy.remove(action));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // With no leading widget the spinner lies over the label, which
        // keeps its room: the button does not change size.
        Button(
          loading: _busy.contains('save'),
          onPressed: () => _run('save'),
          child: const Text('Save changes'),
        ),
        // With one, the spinner takes its place and the label stays.
        Button.outline(
          loading: _busy.contains('export'),
          leading: const PhosphorIcon(PhosphorIconsRegular.downloadSimple),
          onPressed: () => _run('export'),
          child: const Text('Export'),
        ),
        IconButton.outline(
          tooltip: 'Refresh',
          loading: _busy.contains('refresh'),
          onPressed: () => _run('refresh'),
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowsClockwise),
        ),
      ],
    );
  }
}
