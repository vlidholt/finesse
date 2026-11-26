@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/generate_skills.dart' as skills;

/// The skill under `skills/una-overview/` is generated in part from the
/// example app's docs pages. This fails when a docs page changed and the
/// skill was not regenerated, when the registry gained a page the skill
/// does not cover, or when a link in the skill leads nowhere.
void main() {
  test('the skill is in step with the docs pages', () {
    final output = skills.generateSkills();

    expect(output.problems, isEmpty, reason: output.problems.join('\n'));

    final stale = [
      for (final MapEntry(key: path, value: content) in output.files.entries)
        if (!File(path).existsSync() ||
            File(path).readAsStringSync() != content)
          path,
    ];
    final onDisk = Directory('skills/una-overview/components')
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.md'))
        .toSet();
    final leftOver = onDisk.difference(output.files.keys.toSet());

    expect(
      [...stale, ...leftOver],
      isEmpty,
      reason: 'Run `dart run scripts/generate_skills.dart`.',
    );
  });
}
