@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/generate_style_fields.dart' as fields;

/// The theme editor lists every `StyleTokens` field from a table generated
/// from `style.dart`. This fails when a field was added, removed or
/// redocumented and the table was not regenerated, so the editor can never
/// quietly miss a token.
void main() {
  test("the editor's table of style fields is in step with StyleTokens", () {
    final generated = fields.generate(
      File('lib/src/theme/style.dart').readAsStringSync(),
    );
    final onDisk = File(
      'example/lib/common/theme_editor/style_fields.g.dart',
    ).readAsStringSync();
    expect(
      fields.sameIgnoringWhitespace(onDisk, generated),
      isTrue,
      reason: 'Run `dart run scripts/generate_style_fields.dart`.',
    );
  });
}
