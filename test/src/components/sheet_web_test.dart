// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'action_sheet_test.dart' as action_sheet;
import 'sheet_test.dart' as sheet;

/// `sheet_test.dart` and `action_sheet_test.dart` again, in a browser.
///
/// The web's default shortcuts are not the other platforms': the arrow keys
/// scroll and Enter is bound to `ButtonActivateIntent`. A sheet's handle and
/// an action sheet's rows are walked and chosen from the keyboard, so both
/// are held to working there too.
void main() {
  group('sheet', sheet.main);
  group('action sheet', action_sheet.main);
}
